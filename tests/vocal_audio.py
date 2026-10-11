#!/usr/bin/env python3
"""Render all real phrase buffers through the vocal DSP; verify signals and provenance."""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import math
import os
from pathlib import Path
import shutil
import struct
import subprocess
import tempfile
import wave


ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("ism_audio_analysis", ROOT / "tools/analyze_audio.py")
analysis = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(analysis)

SCRIPT = r"""(
var root = "ISM_TEST_ROOT".getenv, output = "ISM_TEST_OUTPUT".getenv;
var coefficient = "ISM_TEST_COEFF".getenv.asFloat;
var cutoff = "ISM_TEST_CUTOFF".getenv.asFloat, messages = List.new, options, score;
~ism = (root: root, samples: []);
["Voices", "Samples"].do { |name| (root +/+ "src" +/+ (name ++ ".scd")).load };
~ism[\scanSamples].value;
if(~ism[\phraseIndices].size != 8) { "ERROR: missing phrase bank".postln; 1.exit };
~ism[\defineSynths].value;
~ism[\defs].do { |definition| messages.add([0.0, [\d_recv, definition.asBytes]]) };
~ism[\samples].do { |sample, index| messages.add([0.0, [\b_allocRead, 100 + index, sample[\path]]]) };
messages.add([0.001, [\g_new, 10, 0, 0]]);
messages.add([0.002, [\g_new, 12, 3, 10]]);
messages.add([0.003, [\s_new, \ismMaster, 21, 0, 12, \in, 18, \out, 0, \gain, 0.72]]);
~ism[\phraseIndices].do { |sampleIndex, index|
    var sample = ~ism[\samples][sampleIndex];
    var dur = (sample[\duration] / 0.95) + 0.35;
    messages.add([1.0 + (index * 4), [\s_new, \ismPhrase, 1000 + index, 0, 10,
        \out, 18, \buf, 100 + sampleIndex, \seed, 302 + index, \dur, dur,
        \rate, 0.95, \amp, 0.09, \pan, 0.15, \drive, 1.15, \tone, 0.6,
        \cutoff, cutoff, \filterCoeff, coefficient, \echoMix, 0.0]]);
};
messages.add([33.0, [\n_set, 21, \gate, 0]]);
messages.add([33.25, [\c_set, 0, 0]]);
options = ServerOptions.new.numOutputBusChannels_(2).numInputBusChannels_(0)
    .sampleRate_(44100).memSize_(262144).maxNodes_(4096);
score = Score(messages.asArray.sort { |a, b| a[0] < b[0] });
AppClock.sched(100, { "ERROR: phrase NRT test timed out".postln; 1.exit });
score.recordNRT(oscFilePath: output ++ ".osc", outputFilePath: output, sampleRate: 44100,
    headerFormat: "WAV", sampleFormat: "int16", options: options, duration: 33.25,
    action: { |exitCode| File.delete(output ++ ".osc"); exitCode.exit });
)"""


def window_metrics(path: Path, start: float, seconds: float) -> dict:
    with wave.open(str(path), "rb") as audio:
        audio.setpos(round(start * audio.getframerate()))
        data = audio.readframes(round(seconds * audio.getframerate()))
        if audio.getnchannels() != 2 or audio.getsampwidth() != 2:
            raise ValueError("Expected stereo PCM16 phrase output")
    values = list(struct.iter_unpack("<hh", data))
    squares = [0.0, 0.0]
    derivative = 0.0
    previous = (0, 0)
    for pair in values:
        for channel, value in enumerate(pair):
            squares[channel] += (value / 32768.0) ** 2
            derivative += ((value - previous[channel]) / 32768.0) ** 2
        previous = pair
    return {"rms": [math.sqrt(value / max(1, len(values))) for value in squares],
            "first_difference_rms": math.sqrt(derivative / max(1, 2 * len(values)))}


def difference(left: Path, right: Path) -> float:
    squared = 0.0
    samples = 0
    with wave.open(str(left), "rb") as a, wave.open(str(right), "rb") as b:
        if a.getparams() != b.getparams():
            raise ValueError("Vocal comparison WAV parameters differ")
        while True:
            first, second = a.readframes(16384), b.readframes(16384)
            if not first:
                break
            for x, y in zip(struct.iter_unpack("<h", first), struct.iter_unpack("<h", second)):
                squared += ((x[0] - y[0]) / 32768.0) ** 2
                samples += 1
    return math.sqrt(squared / max(1, samples))


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--sclang", default=os.environ.get("ISM_SCLANG") or shutil.which("sclang") or "/workspace/ism-toolchain/bin/sclang")
    parser.add_argument("--report", type=Path, default=Path("/tmp/ism-vocal-audio.json"))
    parser.add_argument("--keep-audio", type=Path)
    args = parser.parse_args()
    manifest = json.loads((ROOT / "assets/vocals/MANIFEST.json").read_text())
    failures = []
    sources = []
    if len(manifest["phrases"]) != 8 or not manifest.get("source") or not manifest.get("license"):
        failures.append("Incomplete phrase bank or provenance manifest")
    for phrase in manifest["phrases"]:
        path = ROOT / "assets/vocals" / phrase["filename"]
        measured = analysis.inspect_wav(path)
        problems = []
        if hashlib.sha256(path.read_bytes()).hexdigest() != phrase["sha256"]:
            problems.append("Source SHA256 differs from asset manifest")
        if measured["channels"] != 1 or measured["frames"] != phrase["frames"] or measured["sample_rate"] != phrase["sample_rate"]:
            problems.append("Source audio metadata differs from asset manifest")
        if measured["nonfinite_samples"] or min(measured["rms"]) < 1e-3:
            problems.append("Source is nonfinite or silent")
        if len(phrase.get("transcript", "").split()) < 3:
            problems.append("Source lacks a recorded phrase transcript")
        sources.append({"file": phrase["filename"], "transcript": phrase["transcript"],
                        "duration_seconds": measured["duration_seconds"], "failures": problems})
        failures.extend(f"{phrase['filename']}: {problem}" for problem in problems)

    temporary = tempfile.TemporaryDirectory(prefix="ism-vocal-audio-")
    directory = args.keep_audio.resolve() if args.keep_audio else Path(temporary.name)
    directory.mkdir(parents=True, exist_ok=True)
    script = Path(temporary.name) / "vocal_render.scd"
    script.write_text(SCRIPT)
    renders = []
    paths = {}
    for name, coefficient, cutoff in [("closed-filter", 0, 1100), ("open-filter", 1, 9000),
                                      ("repeat-open-filter", 1, 9000),
                                      ("coefficient-zero", 0, 5500), ("coefficient-one", 1, 5500)]:
        output = directory / (name + ".wav")
        output.unlink(missing_ok=True)
        env = os.environ.copy()
        env.update({"QT_QPA_PLATFORM": "offscreen", "ISM_TEST_ROOT": str(ROOT),
                    "ISM_TEST_OUTPUT": str(output), "ISM_TEST_COEFF": str(coefficient),
                    "ISM_TEST_CUTOFF": str(cutoff)})
        result = {"name": name, "filter_coefficient": coefficient, "cutoff": cutoff, "failures": []}
        try:
            process = subprocess.run([args.sclang, "-D", str(script)], cwd=ROOT, env=env,
                                     stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=120, text=True)
            (directory / (name + ".log")).write_text(process.stdout)
            fatal = [line for line in process.stdout.splitlines()
                     if line.startswith(("FAILURE IN SERVER", "ERROR:", "exception in real time:"))
                     or "CheckBadValues: NaN" in line or "CheckBadValues: infinity" in line]
            result["failures"].extend(fatal)
            if process.returncode or not output.exists():
                result["failures"].append(f"Render process failed ({process.returncode}) or WAV absent")
            else:
                result["audio"] = analysis.inspect_wav(output)
                result["audio"]["file"] = output.name
                result["failures"].extend(analysis.failures(result["audio"], expected_seconds=33.25))
                result["phrases"] = []
                for index, source in enumerate(sources):
                    metrics = window_metrics(output, 1 + index * 4, source["duration_seconds"] / 0.95 + 0.35)
                    if min(metrics["rms"]) < 1e-4:
                        result["failures"].append(f"Phrase {index} failed to produce signal in both channels")
                    result["phrases"].append({"index": index, **metrics})
                result["sha256"] = hashlib.sha256(output.read_bytes()).hexdigest()
                paths[name] = output
        except (OSError, ValueError, subprocess.TimeoutExpired) as error:
            result["failures"].append(str(error))
        result["passed"] = not result["failures"]
        failures.extend(f"{name}: {problem}" for problem in result["failures"])
        renders.append(result)
        print(f"{'PASS' if result['passed'] else 'FAIL'} {name}", flush=True)

    by_name = {item["name"]: item for item in renders}
    delta = difference(paths["closed-filter"], paths["open-filter"]) if len(paths) == 5 else 0
    coefficient_delta = difference(paths["coefficient-zero"], paths["coefficient-one"]) if len(paths) == 5 else 0
    deterministic = bool(len(paths) == 5 and by_name["open-filter"]["sha256"] == by_name["repeat-open-filter"]["sha256"])
    if delta <= 1e-4:
        failures.append("Vocal cutoff/coefficient endpoints failed to change the real signal")
    if not deterministic:
        failures.append("Identical phrase DSP settings failed deterministic replay")
    if coefficient_delta <= 1e-4:
        failures.append("Vocal filter algorithm coefficient failed to change the real signal at a fixed cutoff")
    report = {"passed": not failures,
              "method": "All eight checked-in phrase buffers rendered separately through stock ismPhrase DSP and limiter; finite stereo signals, manifest hashes, numeric signal differences and deterministic replay verified. Transcript text is provenance metadata; speech recognition and subjective listening are not claimed.",
              "sources": sources, "renders": renders, "filter_signal_difference_rms": delta,
              "coefficient_only_signal_difference_rms": coefficient_delta,
              "identical_settings_byte_identical": deterministic, "failures": failures}
    args.report.parent.mkdir(parents=True, exist_ok=True)
    args.report.write_text(json.dumps(report, indent=2) + "\n")
    print(f"VOCAL AUDIO: 8 source buffers, {len(renders)} renders, difference RMS={delta:.6f}, passed={report['passed']}")
    temporary.cleanup()
    return 0 if report["passed"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
