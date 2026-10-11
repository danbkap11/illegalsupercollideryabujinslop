# Verification

Run from the repository root with SuperCollider's `sclang` and `scsynth` on `PATH`.
The cloud setup uses `/workspace/ism-toolchain/bin/sclang`; a desktop installation
uses its ordinary `sclang` command. All scripts return a nonzero exit status on
failure. Use a shell timeout as an additional guard against language parse errors.

```sh
python3 -m unittest discover -s tests -p 'test_*.py' -v
QT_QPA_PLATFORM=offscreen timeout 120 sclang -D tests/composer_tests.scd
QT_QPA_PLATFORM=offscreen timeout 120 sclang -D tests/vocal_tests.scd
ISM_NO_BOOT=1 DISPLAY=:97 timeout 90 sclang -D tests/gui_tests.scd
ISM_NO_BOOT=1 DISPLAY=:97 timeout 40 sclang -D tests/gui_fit_tests.scd
python3 tests/audio_controls.py --sclang sclang
python3 tests/vocal_audio.py --sclang sclang --report /tmp/ism-vocal-audio.json
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

The vocal scheduler check verifies that T02 suppresses speech when off, that
complete phrases appear occasionally when enabled, and that S07 changes both
appearance frequency and the vocal filter coefficient. Eight seeded comparisons
exercise frequency endpoints. Short scene continuations check that cooldowns and
transcript history survive scene boundaries, avoid overlap and immediate repeats,
and preserve caller memory. Actual scanned recordings determine prepared phrase
lifetimes, including their playback rate and bounded effect tail.

`vocal_audio.py` checks the eight recordings against their provenance manifest,
then renders every recording through the actual vocal DSP at closed/open filter
settings and with different filter coefficients at a fixed cutoff. It measures
every phrase in both output channels, rejects nonfinite or
silent signals, checks signal change, and verifies an identical render repeat.
Source transcripts are provenance metadata; this test does not claim speech
recognition or subjective listening. `--keep-audio /path` retains the comparison
WAVs. The default report goes to `/tmp/ism-vocal-audio.json`.

`audio_controls.py` renders each slider endpoint with the other sliders at 0.5
and all switches on. It compares each switch off/on while other switches are
off. It measures finite stereo samples, duration, headroom and signal change,
checks an identical-seed repeat, and renders without optional samples. Up to two
independent NRT processes run at once. A permitted behavior that does not occur
in the first short switch comparison gets one longer, documented seeded retry.
The report is saved to `docs/CONTROL_VALIDATION.json`. Temporary audio is removed
unless `--keep-audio /path` is supplied.

`realtime_tests.scd` requires an audio backend. In the cloud, run dummy JACK and
the test in the same shell so they share sandbox IPC:

```sh
jackd -r -d dummy -r 48000 -p 1024 > /tmp/ism-jack-test.log 2>&1 &
ISM_TEST_JACK_PID=$!
trap 'kill "$ISM_TEST_JACK_PID" 2>/dev/null || true' EXIT
sleep 1
DISPLAY=:97 timeout 80 sclang -D tests/realtime_tests.scd
```

The realtime check uses all loaded buffers, waits for an actual spoken phrase,
turns T02 off and observes the vocal synthesizer's release, then reenables speech
while making rapid macro edits. It verifies elapsed-time cooldowns, reseeding
during playback, transport restarts, and cleanup of owned synthesizers.

Objective signal changes and an offscreen Qt window do not establish artistic
quality or desktop playback. Human listening and the separate realtime backend
check remain part of the release validation.
