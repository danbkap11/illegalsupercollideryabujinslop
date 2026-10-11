# Lost Line phrase bank

The machine has eight complete, original spoken phrases. They are prerecorded
synthetic voices, so ordinary playback and WAV export work offline with only
SuperCollider. No speech engine, plugin, account, API key, or extra download is
needed to run the instrument.

| Index | File | Words | Source length |
| --- | --- | --- | --- |
| 00 | `00_angels_offline.wav` | The angels are offline. | 2.025442 s |
| 01 | `01_line_open.wav` | Keep the line open. | 2.036735 s |
| 02 | `02_remember_this_place.wav` | Do you remember this place? | 2.282971 s |
| 03 | `03_other_end.wav` | There is nobody at the other end. | 2.341066 s |
| 04 | `04_voice_here.wav` | You left your voice here. | 2.383991 s |
| 05 | `05_no_floor.wav` | The room has no floor. | 2.383447 s |
| 06 | `06_hear_the_forest.wav` | I can hear the forest. | 2.199773 s |
| 07 | `07_empty_city.wav` | Return to the empty city. | 2.381837 s |

The files are mono 44,100 Hz PCM16, with a peak of approximately 0.60. The bank
contains clear speech without baked reverb, crushing, music, or echoes. The
instrument applies its coloration at playback, which keeps the controls useful.
The phonetic character deliberately resembles a damaged computer or a lost
telephone announcement. All voices are stock synthetic formant variants; none
imitates a performer or uses a cloned voice.

## Performing the voices

- **ZHŪN** permits occasional spoken messages. Turn it off to fade the active
  phrase and allow instrumental passages. The phrase scheduler carries its
  cooldown across scene changes, rather than restarting a vocal each time the
  music changes direction.
- **ÆZRI** increases phrase frequency. At the low end, nominal spacing is about
  48 seconds; at the high end, about 8 seconds. Small seeded variations make
  the arrivals less mechanical. Consecutive messages use different phrases.
- **ÆZRI** also opens the vocal filter, adjusts its modulation coefficient,
  and changes playback rate from 0.85 to 1.08. Words play as complete phrases;
  this is not a permanently looping voice layer.
- **SHØR** darkens the phrase, and **NØZA** adds telephone coloration.
- **THÆL** adds short vocal echoes; **THØN** contributes a little more echo.

The composer calculates the spectral coefficient from multiple controls:

```text
coefficient = ÆZRI × (1 − 0.32 × SHØR) × (1 − 0.18 × NØZA)
base cutoff = 1100 + 7900 × coefficient  Hz
nominal phrase spacing = 8 + 40 × (1 − ÆZRI)^1.6  seconds
```

Control values in these formulas range from 0 to 1. The speech amplitude opens
and closes the filter around that base cutoff; its modulation depth also uses
the coefficient. The DSP clamps cutoff to a bounded range of 700–10,000 Hz.
Changes to cutoff and coefficient update phrases already playing. The phrases
have room to finish before another starts, including at the most frequent
setting, with a short tail after the complete source clip.

## Regeneration

This is an optional developer operation. Install **eSpeak NG**, **ffmpeg**, and
Python 3, then run from the repository directory:

```sh
python3 tools/generate_vocals.py
python3 tools/generate_vocals.py --verify
```

To keep the committed bank intact while trying another tool version:

```sh
python3 tools/generate_vocals.py --output /tmp/lost-line-vocals
```

Executable paths can be supplied with `--espeak /path/to/espeak-ng` and
`--ffmpeg /path/to/ffmpeg`. Verification alone needs Python, without either
audio tool. The script refuses to overwrite a directory containing unrelated
WAVs. Regeneration intentionally replaces the eight known phrase files and
their manifest.

The tested recipe uses **eSpeak NG 1.52.0** with its supported `-D` deterministic
random mode. Two complete generations produced byte-identical WAVs and manifest.
Individual recipes specify English
accent, stock female or male variant, speech rate, pitch, and word gap. The
script resamples to 44.1 kHz, strips container metadata, trims boundary silence
with 25 ms guards, normalizes peaks, applies tiny 4 ms boundary fades, and adds
60 ms of leading and at least 120 ms of trailing quiet. Any phrase shorter than
two seconds receives quiet padding. A phrase longer than four seconds fails
the build instead of losing words. Different speech-engine versions can change
pronunciation or durations; the manifest records the versions actually used.

[`assets/vocals/MANIFEST.json`](../assets/vocals/MANIFEST.json) contains every
transcript and recipe, frame count, duration, format, and SHA-256 / SHA-512
checksum. The regenerating helper verifies all eight assets after generation.

## Provenance and permission

The text and generated phrase bank are original project material, distributed
under the repository's **MIT license**; a copy is included at
[`assets/vocals/LICENSE.txt`](../assets/vocals/LICENSE.txt). This bank contains
no sampled commercial vocal recording.

eSpeak NG itself is independently licensed under **GPL version 3 or later**;
its executable and data are not bundled with the application. This recipe uses
its built-in formant voices, with no MBROLA or external recorded voice packs.
See the [eSpeak NG project](https://github.com/espeak-ng/espeak-ng) for its engine
license and synthesis method, and the GNU project's
[explanation of program-output licensing](https://www.gnu.org/licenses/gpl-faq.html#GPLOutput).
Using the optional generation tool does not change the project's source-code
license.
