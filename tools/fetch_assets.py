#!/usr/bin/env python3
"""Verify bundled CC0 assets, or restore missing files from pinned source packs.

The instrument ships its samples. This tool is for maintenance, not startup.
Uses only Python's standard library; restoring files additionally needs ffmpeg.
TLS verification and archive/member/file checksums are never bypassed.
"""

from __future__ import annotations

import argparse
import hashlib
import io
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import urllib.request
import wave
import zipfile


ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "assets" / "LICENSES.json"
MAX_ARCHIVE_BYTES = 16 * 1024 * 1024


def checksum(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def safe_path(relative: str) -> Path:
    destination = (ROOT / relative).resolve()
    if not destination.is_relative_to(ROOT / "assets"):
        raise ValueError(f"Asset path outside assets directory: {relative}")
    return destination


def verify(asset: dict) -> None:
    path = safe_path(asset["path"])
    if not path.is_file():
        raise FileNotFoundError(asset["path"])
    if checksum(path.read_bytes()) != asset["sha256"]:
        raise ValueError(f"Checksum differs: {asset['path']}; existing file preserved")
    with wave.open(str(path)) as sound:
        expected = asset["format"]
        actual = (sound.getnchannels(), sound.getframerate(), sound.getsampwidth(), sound.getnframes())
        wanted = (expected["channels"], expected["sample_rate"], expected["sample_width_bytes"], expected["frames"])
        if actual != wanted:
            raise ValueError(f"Audio format differs: {asset['path']}")


def fetch_pack(pack: dict) -> zipfile.ZipFile:
    url = pack["download_url"]
    if not url.startswith("https://"):
        raise ValueError("Only verified HTTPS downloads are permitted")
    request = urllib.request.Request(url, headers={"User-Agent": "ISM-sample-restorer/1.0"})
    with urllib.request.urlopen(request, timeout=60) as response:
        if not response.url.startswith("https://"):
            raise ValueError("Download redirected away from HTTPS")
        data = response.read(MAX_ARCHIVE_BYTES + 1)
    if len(data) > MAX_ARCHIVE_BYTES:
        raise ValueError("Source archive exceeds download limit")
    if checksum(data) != pack["archive_sha256"]:
        raise ValueError(f"Archive checksum differs for {pack['title']}; source changed")
    return zipfile.ZipFile(io.BytesIO(data))


def restore(pack: dict, missing: list[dict]) -> None:
    decoder = shutil.which("ffmpeg")
    if decoder is None:
        raise RuntimeError("Install ffmpeg to restore missing WAVs")
    print(f"Fetching verified CC0 source: {pack['title']}")
    with fetch_pack(pack) as archive, tempfile.TemporaryDirectory(prefix="ism-assets-") as scratch:
        for asset in missing:
            # Read named members directly; never extract archive paths onto disk.
            source = archive.read(asset["source_member"])
            if checksum(source) != asset["source_sha256"]:
                raise ValueError(f"Source member checksum differs: {asset['source_member']}")
            input_path = Path(scratch) / "source.ogg"
            output_path = Path(scratch) / "decoded.wav"
            input_path.write_bytes(source)
            subprocess.run(
                [decoder, "-v", "error", "-y", "-i", str(input_path), "-map_metadata", "-1",
                 "-ac", "1", "-ar", "44100", "-c:a", "pcm_s16le",
                 "-fflags", "+bitexact", "-flags:a", "+bitexact", str(output_path)],
                check=True,
            )
            data = output_path.read_bytes()
            if checksum(data) != asset["sha256"]:
                raise ValueError(
                    f"Decoded checksum differs for {asset['path']}; use the shipped WAV "
                    "or a matching ffmpeg decoder (bank built with ffmpeg 7.1.5). "
                    "No file was replaced."
                )
            destination = safe_path(asset["path"])
            destination.parent.mkdir(parents=True, exist_ok=True)
            # Exclusive create preserves files produced or edited concurrently.
            with destination.open("xb") as handle:
                handle.write(data)
            verify(asset)
            print(f"Restored {asset['path']}")
        license_path = safe_path(pack["bundled_license_file"])
        if not license_path.exists():
            with license_path.open("xb") as handle:
                handle.write(archive.read("License.txt"))


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--verify-only", action="store_true", help="Do not download or change anything")
    args = parser.parse_args()
    manifest = json.loads(MANIFEST.read_text())
    missing = []
    for asset in manifest["assets"]:
        if safe_path(asset["path"]).exists():
            verify(asset)
        else:
            missing.append(asset)
    if missing and args.verify_only:
        raise FileNotFoundError("Missing assets: " + ", ".join(a["path"] for a in missing))
    for pack in manifest["packs"]:
        pack_missing = [asset for asset in missing if asset["pack"] == pack["id"]]
        if pack_missing:
            restore(pack, pack_missing)
    for asset in manifest["assets"]:
        verify(asset)
    total_bytes = sum(safe_path(asset["path"]).stat().st_size for asset in manifest["assets"])
    print(f"Verified {len(manifest['assets'])} CC0 WAVs ({total_bytes:,} bytes); mono, 44,100 Hz, PCM16")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (OSError, ValueError, RuntimeError, subprocess.CalledProcessError, zipfile.BadZipFile) as error:
        print(f"Asset verification failed: {error}", file=sys.stderr)
        sys.exit(1)
