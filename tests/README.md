# Verification

Run from the repository root with SuperCollider's `sclang` and `scsynth` on `PATH`.
The cloud setup uses `/workspace/ism-toolchain/bin/sclang`; a desktop installation
uses its ordinary `sclang` command. All scripts return a nonzero exit status on
failure. Use a shell timeout as an additional guard against language parse errors.

```sh
python3 -m unittest discover -s tests -p 'test_*.py' -v
QT_QPA_PLATFORM=offscreen timeout 120 sclang -D tests/composer_tests.scd
ISM_NO_BOOT=1 DISPLAY=:97 timeout 90 sclang -D tests/gui_tests.scd
python3 tests/audio_controls.py --sclang sclang
python3 tools/analyze_audio.py renders/*.wav
```

For the GUI check, `DISPLAY=:97` must refer to an existing Xvfb server or be
replaced with your desktop's display. The test saves an actual window capture
to `/tmp/ism-gui-smoke.png`, or the path in `ISM_GUI_SCREENSHOT`.

The composer check exercises every switch mask at three slider extrema,
individual macro and switch changes, reproducible seeds and musical memory,
finite OSC arguments, event density, voice lifetime overlap, phrase variation,
and a ten-minute trace. The GUI check exercises the actual 20 widget callbacks,
state bounds, numeric preset roundtrips, reseeding, label fallback, the legend,
and repeated closing/reopening.

`audio_controls.py` renders each slider endpoint with the other sliders at 0.5
and all switches on. It compares each switch off/on while other switches are
off. It measures finite stereo samples, duration, headroom and signal change,
checks an identical-seed repeat, and renders without optional samples. Up to two
independent NRT processes run at once. A permitted behavior that does not occur
in the first short switch comparison gets one longer, documented seeded retry.
The report is saved to `docs/CONTROL_VALIDATION.json`. Temporary audio is removed
unless `--keep-audio /path` is supplied.

Objective signal changes and an offscreen Qt window do not establish artistic
quality or desktop playback. Human listening and the separate realtime backend
check remain part of the release validation.
