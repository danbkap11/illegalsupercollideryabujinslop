# Validation

Validated on Debian 13 x86_64 with SuperCollider language/server 3.13.0 and stock UGens. Toolchain packages were signature/checksum-verified through Debian apt and extracted locally without root installation. FFmpeg 7.1.5 is used for asset restoration and demo excerpts.

| Check | Result |
|---|---|
| Composer/macro tests | Passed: 582,842 assertions, including every switch mask at three slider extrema, deterministic traces and memory continuation |
| Native GUI integration | Passed: 75 assertions; exact 10 sliders/10 switches, every callback, presets, reseeding, legend, ASCII labels, repeated close/reopen |
| Actual control audio comparisons | Passed: 33 NRT renders; all 20 controls measurably change the stereo signal; same-seed repeat byte-identical |
| Synthesized fallback | Passed: complete non-silent stereo export without optional samples |
| Full preset exports | Passed: four 90-second arrangements plus 3.25-second tails; finite samples, correct stereo/rate/duration, bounded peaks, negligible DC |
| Demo excerpts | Passed: three 30-second stereo PCM16 files, checked independently |
| Asset integrity | Passed: all 28 bundled CC0 WAVs, headers and SHA256 checksums; missing-file restoration tested from all three packs |
| Audio analyzer tests | Passed: five tests, including nonfinite, silent, truncated and malformed output rejection |
| Realtime audio/lifecycle | Passed: 15 assertions with actual 48 kHz stereo recording through dummy JACK; playback, immediate control revision, panic/restart, stop/restart, and owned-node cleanup |

The final all-on realtime check measured about **0.92% peak server CPU** on this cloud host at 48 kHz/1024 frames. This is a measurement of this host and dummy backend, not a performance promise for other computers. A fresh `/status.reply` showed zero owned synthesizers after closing the window. Recorded panic output was exactly silent after settling; restarted playback was non-silent.

The ten-minute event stress trace contains thousands of events and hundreds of variable-length scenes. Tested stress cases remained well below the enforced 48-voice/96-events-per-second limits. Same-seed rendering includes explicit per-voice and FX noise seeds; byte reproducibility is verified on this toolchain and bank.

Detailed audio comparison results are in [CONTROL_VALIDATION.json](CONTROL_VALIDATION.json). Full preset and excerpt measurements are in [PRESET_METRICS.json](PRESET_METRICS.json) and [DEMO_METRICS.json](DEMO_METRICS.json). These reports correspond to the packaged code and asset mappings. Full WAVs are generated into ignored `renders/`; checked-in excerpts are in `demos/`.

Integration testing found and corrected equal-time dependent group ordering, concurrent temporary OSC score collisions, incomplete master restart after panic, quiet output calibration, and one CLI-only Document-class fallback issue. The affected tests were rerun after corrections. Required checks above have no unresolved failures.

## Limits

No subjective listening audition occurred in the cloud session. The demos and measured comparisons demonstrate audio behavior, not a claim that an artist's production has been reproduced. Reference notes distinguish written research from recording analysis.

Native GUI construction and callbacks were exercised under Xvfb/offscreen; a screenshot was visually inspected. Realtime output was recorded from the actual server using dummy JACK. This validates scheduling and output without testing physical headphones/speakers. Desktop macOS and Windows installations have not been exercised; their audio-device configuration depends on the user's system.

The current implementation has seven scene families, original motif pools, reverse envelopes/sample playback, coordinated retriggers, pitch/tempo collapse events, and bounded effects. Optional plugin hosts, MIDI and full live-performance session serialization are outside this release. Presets save controls/seed; export generates an arrangement rather than recording past live actions.
