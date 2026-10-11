#!/usr/bin/env python3
"""Check actual PCM/IEEE-float stereo WAV output using Python's standard library."""

from __future__ import annotations

import argparse
import json
import math
import pathlib
import struct
import sys


def inspect_wav(path: pathlib.Path) -> dict:
    """Stream samples; do not let a WAV header alone stand in for audio evidence."""
    with path.open("rb") as handle:
        header = handle.read(12)
        if len(header) != 12 or header[:4] != b"RIFF" or header[8:] != b"WAVE":
            raise ValueError("Expected a little-endian RIFF/WAVE file")
        fmt = None
        data = None
        file_size = path.stat().st_size
        while handle.tell() + 8 <= file_size:
            chunk_id, chunk_size = struct.unpack("<4sI", handle.read(8))
            offset = handle.tell()
            if offset + chunk_size > file_size:
                raise ValueError("Truncated WAV chunk")
            if chunk_id == b"fmt ":
                fmt = handle.read(chunk_size)
            elif chunk_id == b"data":
                data = (offset, chunk_size)
            handle.seek(offset + chunk_size + (chunk_size & 1))
        if fmt is None or len(fmt) < 16 or data is None:
            raise ValueError("Missing WAV format or data chunk")
        encoding, channels, rate, byte_rate, alignment, bits = struct.unpack("<HHIIHH", fmt[:16])
        if encoding == 0xFFFE:
            if len(fmt) < 40:
                raise ValueError("Incomplete extensible WAV format")
            encoding = struct.unpack("<I", fmt[24:28])[0]
        if channels < 1 or rate < 1 or bits not in (8, 16, 24, 32, 64):
            raise ValueError("Invalid channel/rate/sample-size metadata")
        sample_bytes = bits // 8
        if alignment != sample_bytes * channels or byte_rate != rate * alignment:
            raise ValueError("Inconsistent WAV format metadata")
        if encoding not in (1, 3) or (encoding == 3 and bits not in (32, 64)):
            raise ValueError(f"Unsupported WAV encoding {encoding}, {bits} bits")
        offset, size = data
        if not size or size % alignment:
            raise ValueError("Empty data or incomplete sample frame")
        frames = size // alignment
        peaks = [0.0] * channels
        sums = [0.0] * channels
        squares = [0.0] * channels
        audible = [0] * channels
        clipped = [0] * channels
        nonfinite = 0
        handle.seek(offset)
        remaining = size
        while remaining:
            chunk = handle.read(min(remaining, alignment * 16384))
            if not chunk:
                raise ValueError("Truncated sample data")
            remaining -= len(chunk)
            if encoding == 3:
                code = "f" if bits == 32 else "d"
                values = (item[0] for item in struct.iter_unpack("<" + code, chunk))
            elif bits == 8:
                values = ((item - 128) / 128.0 for item in chunk)
            elif bits == 24:
                values = (
                    int.from_bytes(chunk[i:i + 3], "little", signed=True) / 8388608.0
                    for i in range(0, len(chunk), 3)
                )
            else:
                code = {16: "h", 32: "i", 64: "q"}[bits]
                scale = float(1 << (bits - 1))
                values = (item[0] / scale for item in struct.iter_unpack("<" + code, chunk))
            for index, value in enumerate(values):
                channel = index % channels
                if not math.isfinite(value):
                    nonfinite += 1
                    continue
                magnitude = abs(value)
                peaks[channel] = max(peaks[channel], magnitude)
                sums[channel] += value
                squares[channel] += value * value
                audible[channel] += magnitude > 1e-5
                clipped[channel] += magnitude >= 0.999
        return {
            "file": str(path),
            "channels": channels,
            "sample_rate": rate,
            "encoding": "float" if encoding == 3 else "pcm",
            "bits": bits,
            "frames": frames,
            "duration_seconds": frames / rate,
            "peak": peaks,
            "rms": [math.sqrt(total / frames) for total in squares],
            "dc": [total / frames for total in sums],
            "non_silent_fraction": [count / frames for count in audible],
            "clipped_samples": clipped,
            "nonfinite_samples": nonfinite,
        }


def failures(result: dict, *, expected_seconds: float | None = None,
             peak_ceiling: float = 0.86, min_rms: float = 1e-5) -> list[str]:
    problems = []
    if result["channels"] != 2:
        problems.append("Output is not stereo")
    if result["sample_rate"] not in (44100, 48000, 88200, 96000):
        problems.append("Unexpected sample rate")
    if result["nonfinite_samples"]:
        problems.append("Non-finite audio samples")
    if max(result["peak"]) > peak_ceiling:
        problems.append(f"Peak exceeds {peak_ceiling:g}")
    if min(result["rms"]) < min_rms:
        problems.append("Silent or negligible signal in an output channel")
    if min(result["non_silent_fraction"]) < 0.01:
        problems.append("Less than 1% meaningful signal in an output channel")
    if max(map(abs, result["dc"])) > 0.04:
        problems.append("Excessive DC offset")
    if expected_seconds is not None and abs(result["duration_seconds"] - expected_seconds) > 0.05:
        problems.append(f"Duration differs from expected {expected_seconds:g} seconds")
    return problems


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("files", nargs="+", type=pathlib.Path)
    parser.add_argument("--expected-seconds", type=float)
    parser.add_argument("--peak-ceiling", type=float, default=0.86)
    parser.add_argument("--min-rms", type=float, default=1e-5)
    parser.add_argument("--json", type=pathlib.Path, help="Also save the complete report")
    args = parser.parse_args()
    reports = []
    for path in args.files:
        try:
            report = inspect_wav(path)
            report["failures"] = failures(
                report, expected_seconds=args.expected_seconds,
                peak_ceiling=args.peak_ceiling, min_rms=args.min_rms,
            )
        except (OSError, ValueError, struct.error) as exc:
            report = {"file": str(path), "failures": [str(exc)]}
        report["passed"] = not report["failures"]
        reports.append(report)
    output = json.dumps({"passed": all(item["passed"] for item in reports), "files": reports}, indent=2)
    print(output)
    if args.json:
        args.json.parent.mkdir(parents=True, exist_ok=True)
        args.json.write_text(output + "\n", encoding="utf-8")
    return 0 if all(item["passed"] for item in reports) else 1


if __name__ == "__main__":
    sys.exit(main())
