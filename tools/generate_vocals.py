#!/usr/bin/env python3
"""Regenerate the original, occasional spoken-phrase bank.

Playback uses the committed WAVs and does not need this developer tool. Generate
with eSpeak NG's stock formant voices, never MBROLA or a cloned human voice.
"""

from __future__ import annotations

import argparse
from array import array
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile
import wave


ROOT = Path(__file__).resolve().parent.parent
SAMPLE_RATE = 44100
PHRASES = (
    ("00_angels_offline.wav", "The angels are offline.", "en-us+f2", 140, 45, 5),
    ("01_line_open.wav", "Keep the line open.", "en-gb+m2", 135, 35, 7),
    ("02_remember_this_place.wav", "Do you remember this place?", "en-us+f3", 145, 52, 4),
    ("03_other_end.wav", "There is nobody at the other end.", "en-gb+m3", 150, 32, 3),
    ("04_voice_here.wav", "You left your voice here.", "en-us+f1", 140, 58, 5),
    ("05_no_floor.wav", "The room has no floor.", "en-gb+m1", 135, 40, 6),
    ("06_hear_the_forest.wav", "I can hear the forest.", "en-us+f2", 142, 50, 5),
    ("07_empty_city.wav", "Return to the empty city.", "en-gb+m2", 138, 38, 5),
)


def run(arguments: list[str]) -> subprocess.CompletedProcess[str]:
    return subprocess.run(arguments, check=True, capture_output=True, text=True)


def executable(value: str) -> str:
    result = shutil.which(value)
    if result is None:
        raise RuntimeError(f"Missing {value!r}. Install eSpeak NG / ffmpeg for regeneration only.")
    return result


def read_pcm(path: Path) -> tuple[array, int]:
    with wave.open(str(path), "rb") as audio:
        if audio.getnchannels() != 1 or audio.getsampwidth() != 2:
            raise RuntimeError(f"Expected mono PCM16: {path}")
        samples = array("h", audio.readframes(audio.getnframes()))
        if sys.byteorder != "little":
            samples.byteswap()
        return samples, audio.getframerate()


def finish_pcm(samples: array) -> array:
    """Trim TTS padding, preserve words, add short guards, peak-normalize."""
    audible = [i for i, sample in enumerate(samples) if abs(sample) > 64]
    if not audible:
        raise RuntimeError("Speech synthesizer supplied silence.")
    # Keep 25 ms beyond each detected boundary so quiet final consonants survive.
    margin = round(SAMPLE_RATE * 0.025)
    first = max(0, audible[0] - margin)
    last = min(len(samples), audible[-1] + margin + 1)
    clean = samples[first:last]
    gain = (32767 * 0.60) / max(abs(sample) for sample in clean)
    clean = array("h", (round(sample * gain) for sample in clean))
    fade = round(SAMPLE_RATE * 0.004)
    for i in range(min(fade, len(clean) // 2)):
        clean[i] = round(clean[i] * i / fade)
        clean[-1 - i] = round(clean[-1 - i] * i / fade)
    lead = round(SAMPLE_RATE * 0.060)
    tail = round(SAMPLE_RATE * 0.120)
    result = array("h", [0] * lead) + clean + array("h", [0] * tail)
    # Fixed minimum slot length is useful for scheduling, with no truncated words.
    result.extend([0] * max(0, 2 * SAMPLE_RATE - len(result)))
    if len(result) > 4 * SAMPLE_RATE:
        raise RuntimeError("Phrase exceeds four seconds; increase its recipe speech speed.")
    return result


def write_pcm(path: Path, samples: array) -> None:
    data = array("h", samples)
    if sys.byteorder != "little":
        data.byteswap()
    with wave.open(str(path), "wb") as audio:
        audio.setparams((1, 2, SAMPLE_RATE, 0, "NONE", "not compressed"))
        audio.writeframes(data.tobytes())


def verify(output: Path) -> None:
    manifest = json.loads((output / "MANIFEST.json").read_text())
    expected = {item["filename"] for item in manifest["phrases"]}
    actual = {path.name for path in output.glob("*.wav")}
    if actual != expected or len(actual) != 8:
        raise RuntimeError(f"Expected exactly the eight indexed phrase WAVs: {actual}")
    for item in manifest["phrases"]:
        path = output / item["filename"]
        data = path.read_bytes()
        if hashlib.sha256(data).hexdigest() != item["sha256"]:
            raise RuntimeError(f"SHA-256 mismatch: {path}")
        if hashlib.sha512(data).hexdigest() != item["sha512"]:
            raise RuntimeError(f"SHA-512 mismatch: {path}")
        samples, rate = read_pcm(path)
        duration = len(samples) / rate
        if rate != SAMPLE_RATE or len(samples) != item["frames"] or not 2 <= duration <= 4:
            raise RuntimeError(f"Format / duration mismatch: {path}")
        peak = max(abs(sample) for sample in samples) / 32768
        if not 0.599 <= peak <= 0.601:
            raise RuntimeError(f"Unexpected peak: {path}: {peak}")
        print(f"OK {path.name}: {duration:.6f}s, peak {peak:.4f}")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--espeak", default="espeak-ng", help="eSpeak NG executable / wrapper")
    parser.add_argument("--ffmpeg", default="ffmpeg", help="ffmpeg executable")
    parser.add_argument("--output", type=Path, default=ROOT / "assets" / "vocals")
    parser.add_argument("--verify", action="store_true", help="verify the bank without TTS tools")
    options = parser.parse_args()
    output = options.output.resolve()
    if options.verify:
        verify(output)
        return
    espeak = executable(options.espeak)
    ffmpeg = executable(options.ffmpeg)
    engine_version = run([espeak, "--version"]).stdout.splitlines()[0]
    # A rootless eSpeak wrapper can report its compiled data directory here.
    engine_version = re.sub(r"\s+Data at:.*", "", engine_version).strip()
    ffmpeg_version = run([ffmpeg, "-version"]).stdout.splitlines()[0]
    output.mkdir(parents=True, exist_ok=True)
    existing = {path.name for path in output.glob("*.wav")}
    unexpected = existing - {phrase[0] for phrase in PHRASES}
    if unexpected:
        raise RuntimeError(f"Preserve unknown WAVs by choosing another --output: {unexpected}")
    manifest = {
        "schema_version": 1,
        "bank_name": "Lost Line / Original Phrase Bank",
        "license": "MIT",
        "license_file": "assets/vocals/LICENSE.txt",
        "creator": "ILLEGAL SUPERCOLLIDER YABUJINSLOP MACHINE contributors",
        "source": "Original project text rendered by stock synthetic formant voices; no cloned voice or third-party recording.",
        "engine": {"name": "eSpeak NG", "version": engine_version, "license": "GPL-3.0-or-later", "deterministic_random_mode": True},
        "resampler": {"name": "ffmpeg", "version": ffmpeg_version},
        "references": [
            "https://github.com/espeak-ng/espeak-ng#license-information",
            "https://github.com/espeak-ng/espeak-ng#espeak-ng-text-to-speech",
            "https://www.gnu.org/licenses/gpl-faq.html#GPLOutput",
        ],
        "processing": "Mono PCM16, deterministic 44.1 kHz resampling, boundary trim with 25 ms guards, peak normalized to 0.60, 4 ms fades, 60 ms lead / 120 ms tail, two-second minimum by silence padding. No distortion, delay, filtering, or musical background baked in.",
        "phrases": [],
    }
    with tempfile.TemporaryDirectory(prefix="ism-vocals-") as temporary:
        temp = Path(temporary)
        for index, (name, text, voice, speed, pitch, gap) in enumerate(PHRASES):
            raw, converted = temp / "raw.wav", temp / "converted.wav"
            run([espeak, "-D", "-v", voice, "-s", str(speed), "-p", str(pitch), "-g", str(gap), "-a", "100", "-w", str(raw), text])
            run([ffmpeg, "-hide_banner", "-loglevel", "error", "-y", "-i", str(raw), "-map_metadata", "-1", "-ac", "1", "-ar", str(SAMPLE_RATE), "-af", "aresample=resampler=swr:dither_method=none", "-c:a", "pcm_s16le", str(converted)])
            samples, rate = read_pcm(converted)
            if rate != SAMPLE_RATE:
                raise RuntimeError("Resampling failed.")
            samples = finish_pcm(samples)
            path = output / name
            write_pcm(path, samples)
            data = path.read_bytes()
            manifest["phrases"].append({
                "index": index, "filename": name, "transcript": text,
                "voice": voice, "speed_words_per_minute": speed,
                "pitch": pitch, "word_gap_10ms": gap, "amplitude": 100,
                "channels": 1, "sample_rate": SAMPLE_RATE, "sample_width_bytes": 2,
                "frames": len(samples), "duration_seconds": round(len(samples) / SAMPLE_RATE, 6),
                "sha256": hashlib.sha256(data).hexdigest(),
                "sha512": hashlib.sha512(data).hexdigest(),
            })
    (output / "MANIFEST.json").write_text(json.dumps(manifest, indent=2, ensure_ascii=False) + "\n")
    verify(output)


if __name__ == "__main__":
    try:
        main()
    except (RuntimeError, subprocess.CalledProcessError, OSError, ValueError) as error:
        print(f"Phrase-bank error: {error}", file=sys.stderr)
        if isinstance(error, subprocess.CalledProcessError):
            print(error.stderr, file=sys.stderr)
        sys.exit(1)
