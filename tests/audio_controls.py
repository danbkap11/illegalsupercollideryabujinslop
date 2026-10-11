#!/usr/bin/env python3
"""Render real audio for every control; report objective coverage without listening claims."""

from __future__ import annotations

import argparse
from concurrent.futures import ThreadPoolExecutor
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import math
import struct
import wave


ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("analyze_audio", ROOT / "tools" / "analyze_audio.py")
analysis = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(analysis)


def difference(before: Path, after: Path) -> dict:
    """Measure signal change, including quiet tails, rather than only differing headers."""
    squared = 0.0
    count = 0
    changed = 0
    maximum = 0.0
    with wave.open(str(before), "rb") as left, wave.open(str(after), "rb") as right:
        if left.getparams() != right.getparams() or left.getsampwidth() != 2:
            raise ValueError("Comparison requires matching stereo PCM16 WAV format")
        while True:
            a = left.readframes(16384)
            b = right.readframes(16384)
            if not a:
                break
            for a_sample, b_sample in zip(struct.iter_unpack("<h", a), struct.iter_unpack("<h", b)):
                delta = (a_sample[0] - b_sample[0]) / 32768.0
                squared += delta * delta
                maximum = max(maximum, abs(delta))
                changed += delta != 0
                count += 1
    return {"difference_rms": math.sqrt(squared / max(1, count)),
            "difference_peak": maximum, "changed_sample_fraction": changed / max(1, count)}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--sclang", default=os.environ.get("ISM_SCLANG") or shutil.which("sclang") or "/workspace/ism-toolchain/bin/sclang")
    parser.add_argument("--seconds", type=float, default=16)
    parser.add_argument("--report", type=Path, default=ROOT / "docs" / "CONTROL_VALIDATION.json")
    parser.add_argument("--keep-audio", type=Path, help="Keep comparison WAVs and logs; default removes temporary output")
    args = parser.parse_args()
    temporary = None
    if args.keep_audio:
        directory = args.keep_audio.resolve()
        directory.mkdir(parents=True, exist_ok=True)
    else:
        temporary = tempfile.TemporaryDirectory(prefix="ism-control-audio-")
        directory = Path(temporary.name)
    jobs = []

    def job(name, sliders, switches, seed=302, no_samples=False, seconds=None):
        item = {"name": name, "sliders": sliders.copy(), "switches": switches.copy(),
                "seed": seed, "no_samples": no_samples, "seconds": seconds or args.seconds}
        jobs.append(item)
        return item

    sliders = [0.5] * 10
    all_on = [1] * 10
    all_off = [0] * 10
    baseline = job("switch-baseline", sliders, all_off)
    pairs = []
    for index in range(10):
        low = sliders.copy(); high = sliders.copy()
        low[index] = 0; high[index] = 1
        pairs.append({"kind": "slider", "index": index,
                      "before": job(f"slider-{index:02d}-low", low, all_on),
                      "after": job(f"slider-{index:02d}-high", high, all_on)})
    for index in range(10):
        switches = all_off.copy(); switches[index] = 1
        pairs.append({"kind": "switch", "index": index, "before": baseline,
                      "after": job(f"switch-{index:02d}-on", sliders, switches)})
    repeated = job("repeat-identical-seed", sliders, all_off)
    fallback = job("synthesis-only-no-samples", sliders, all_on, no_samples=True)

    def render(item):
        output = directory / (item["name"] + ".wav")
        output.unlink(missing_ok=True)
        env = os.environ.copy()
        env.update({"QT_QPA_PLATFORM": "offscreen", "ISM_SECONDS": str(item["seconds"]),
                    "ISM_OUTPUT": str(output), "ISM_SEED": str(item["seed"]),
                    "ISM_SLIDERS": ",".join(map(str, item["sliders"])),
                    "ISM_SWITCHES": ",".join(map(str, item["switches"])),
                    "ISM_NO_SAMPLES": "1" if item["no_samples"] else "0"})
        result = dict(item)
        try:
            process = subprocess.run([args.sclang, "-D", str(ROOT / "tools" / "render.scd")],
                                     cwd=ROOT, env=env, stdout=subprocess.PIPE,
                                     stderr=subprocess.STDOUT, timeout=185, text=True)
            (directory / (item["name"] + ".log")).write_text(process.stdout)
            result["exit_code"] = process.returncode
            if process.returncode:
                result["failures"] = ["Render process failed", process.stdout[-3000:]]
            elif not output.exists():
                result["failures"] = ["Successful process did not create its WAV"]
            else:
                measured = analysis.inspect_wav(output)
                measured["file"] = output.name
                result["audio"] = measured
                result["sha256"] = hashlib.sha256(output.read_bytes()).hexdigest()
                result["failures"] = analysis.failures(measured, expected_seconds=item["seconds"] + 3.25)
                # A nonzero scsynth exit can be hidden by Score's completion action.
                # Server /fail or bad-value messages remain validation failures.
                fatal = [line for line in process.stdout.splitlines()
                         if line.startswith(("FAILURE IN SERVER", "ERROR:", "exception in real time:"))
                         or "CheckBadValues: NaN" in line or "CheckBadValues: infinity" in line]
                result["failures"].extend(fatal)
        except (OSError, subprocess.TimeoutExpired, ValueError) as error:
            result["failures"] = [str(error)]
        result["passed"] = not result["failures"]
        print(f"{'PASS' if result['passed'] else 'FAIL'} {item['name']}", flush=True)
        return result

    # Two renderers at most: preserve headroom while avoiding a serial compile bottleneck.
    with ThreadPoolExecutor(max_workers=2) as pool:
        results = list(pool.map(render, jobs))
    by_name = {item["name"]: item for item in results}
    coverage = []
    for pair in pairs:
        before = by_name[pair["before"]["name"]]
        after = by_name[pair["after"]["name"]]
        different = before.get("sha256") != after.get("sha256")
        # Permission-style switches can need a longer scene sequence to exercise
        # the allowed intervention. Retry a documented alternative seed once.
        if before["passed"] and after["passed"] and not different and pair["kind"] == "switch":
            before_job = dict(pair["before"], name=f"switch-{pair['index']:02d}-retry-off", seed=1337, seconds=45)
            after_job = dict(pair["after"], name=f"switch-{pair['index']:02d}-retry-on", seed=1337, seconds=45)
            with ThreadPoolExecutor(max_workers=2) as pool:
                retried = list(pool.map(render, [before_job, after_job]))
            before, after = retried
            results.extend(retried)
            different = before.get("sha256") != after.get("sha256")
        signal_change = difference(directory / (before["name"] + ".wav"), directory / (after["name"] + ".wav")) \
            if before["passed"] and after["passed"] else {}
        coverage.append({"kind": pair["kind"], "index": pair["index"], "seed": before["seed"],
                         "seconds": before["seconds"], "before": before["name"], "after": after["name"],
                         "audio_bytes_differ": different,
                         **signal_change,
                         "passed": before["passed"] and after["passed"] and different
                             and signal_change.get("difference_rms", 0) > 1e-4})
    deterministic = (by_name[baseline["name"]]["passed"] and by_name[repeated["name"]]["passed"]
                     and by_name[baseline["name"]].get("sha256") == by_name[repeated["name"]].get("sha256"))
    report = {"passed": all(item["passed"] for item in results) and all(item["passed"] for item in coverage) and deterministic,
              "method": "Stock SuperCollider NRT, real stereo PCM output measured; SHA256 and signal-difference RMS > 0.0001 establish signal changes, not musical quality or subjective audibility.",
              "slider_comparison_patch": "All switches on; other sliders fixed at 0.5.",
              "switch_comparison_patch": "All other switches off; all sliders fixed at 0.5.",
              "seed_repeat_byte_identical": deterministic,
              "optional_samples_absent_passed": by_name[fallback["name"]]["passed"],
              "control_pairs": coverage, "renders": results}
    args.report.parent.mkdir(parents=True, exist_ok=True)
    args.report.write_text(json.dumps(report, indent=2) + "\n")
    print(f"CONTROL AUDIO: {sum(item['passed'] for item in coverage)}/20 pairs; "
          f"{len(results)} renders; deterministic={deterministic}; passed={report['passed']}", flush=True)
    if temporary:
        temporary.cleanup()
    return 0 if report["passed"] else 1


if __name__ == "__main__":
    sys.exit(main())
