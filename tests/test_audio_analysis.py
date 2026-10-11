"""Evidence that the render checker rejects dangerous/broken output."""

import importlib.util
import math
import pathlib
import struct
import tempfile
import unittest

MODULE_PATH = pathlib.Path(__file__).resolve().parents[1] / "tools" / "analyze_audio.py"
SPEC = importlib.util.spec_from_file_location("analyze_audio", MODULE_PATH)
analysis = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(analysis)


class RenderMeasurementTests(unittest.TestCase):
    def fixture(self, samples, bits=32, encoding=3, channels=2):
        handle = tempfile.NamedTemporaryFile(suffix=".wav", delete=False)
        path = pathlib.Path(handle.name)
        self.addCleanup(path.unlink, missing_ok=True)
        code = "f" if encoding == 3 else "h"
        audio = struct.pack("<" + code * len(samples), *samples)
        alignment = channels * (bits // 8)
        fmt = struct.pack("<HHIIHH", encoding, channels, 48000, 48000 * alignment, alignment, bits)
        body = b"WAVEfmt " + struct.pack("<I", len(fmt)) + fmt + b"data" + struct.pack("<I", len(audio)) + audio
        handle.write(b"RIFF" + struct.pack("<I", len(body)) + body)
        handle.close()
        return path

    def test_real_float_audio_passes(self):
        samples = [0.2 * math.sin(i * 0.1) for i in range(2000)]
        report = analysis.inspect_wav(self.fixture(samples))
        self.assertEqual(report["frames"], 1000)
        self.assertAlmostEqual(max(report["peak"]), 0.2, places=5)
        self.assertEqual(analysis.failures(report), [])

    def test_nan_and_infinity_rejected(self):
        report = analysis.inspect_wav(self.fixture([float("nan"), float("inf"), 0.2, -0.2] * 100))
        self.assertEqual(report["nonfinite_samples"], 200)
        self.assertIn("Non-finite audio samples", analysis.failures(report))

    def test_silence_and_peak_overrun_rejected(self):
        silent = analysis.inspect_wav(self.fixture([0.0] * 2000))
        self.assertTrue(analysis.failures(silent))
        loud = analysis.inspect_wav(self.fixture([1.1, -1.1] * 1000))
        self.assertTrue(any("Peak" in issue for issue in analysis.failures(loud)))

    def test_integer_stereo_decode_and_duration(self):
        report = analysis.inspect_wav(self.fixture([1000, -1000] * 4800, bits=16, encoding=1))
        self.assertAlmostEqual(report["duration_seconds"], 0.1)
        self.assertAlmostEqual(report["peak"][0], 1000 / 32768)
        self.assertEqual(analysis.failures(report, expected_seconds=0.1), [])
        self.assertTrue(any("Duration" in issue for issue in analysis.failures(report, expected_seconds=1)))

    def test_truncated_file_rejected(self):
        path = self.fixture([0.1, -0.1] * 100)
        path.write_bytes(path.read_bytes()[:-7])
        with self.assertRaises(ValueError):
            analysis.inspect_wav(path)


if __name__ == "__main__":
    unittest.main()
