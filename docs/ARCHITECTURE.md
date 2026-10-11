# Architecture

`Main.scd` resolves its own path, replaces an earlier instance, loads modules, scans optional samples, builds the GUI and asynchronously boots the server. The application state and functions live in `~ism`. Modules are ordinary loadable files; no class-library recompilation is necessary.

`Composer.scd` provides a pure normalized macro mapper and a deterministic local-PRNG composer. Original motif/groove cells move through seven weighted scene families. A memory value retains tonal center, recent scenes, PRNG state and remembered material. Live scheduling requests one variable-duration scene at a time. Control edits smooth effect changes immediately and request a fresh musical scene at the next scheduler check (at most approximately 120 ms); sounding notes keep their finite envelopes. Runtime tracks source lifetimes and caps 48 simultaneous voices. The pure composer independently enforces 48 voices and96 onsets/second.

`Voices.scd` defines ten finite source synths and two persistent processing synths using stock UGens. Each random voice receives an explicit seed. Drum synthesis, FM-like bell/flute, pads, formants and noise form the complete sample-free foundation. Mono/stereo sample players use sample-rate correction, direction-aware start frames and bounded finite envelopes.

```text
source group → private stereo bus → FX group → private stereo bus → master group → hardware stereo
```

FX combines sample/hold rate reduction, quantization, saturation, spectral/mechanical wear, optional telephone band, filtered cross-feedback delay, reverb and stereo width. Feedback is bounded 0–0.8. The master applies fixed 6× source calibration and macro-dependent gain compensation, DC removal, a 0.84 limiter, finite shutdown fade and separate fast mute after limiting. Panic stops sources and mutes without freeing the master, so restart restores playback.

`Samples.scd` scans the bundled WAV bank, rejects unsupported headers and caps loaded sample data 128 MiB. Deterministic event substitutions use the same file ordering and seed rules in live and offline paths. No network operation is required at launch. If no optional samples exist, the synthesized arrangement remains available.

The unified buffer bank now distinguishes artifact samples from eight spoken phrase samples. Pure composition emits sparse `ismPhrase` events with a stable phrase index, cutoff parameters and next-appearance interval. Preparation resolves the phrase to its own bank entry and replaces the conservative six-second scheduling placeholder with source duration/playback rate plus a 350 ms tail. No phrase sample can enter random percussion/texture substitutions. Missing speech assets suppress only phrase events.

`ismPhrase` plays a complete forward sentence with a held envelope. Its cutoff follows speech amplitude and the mapped coefficient, with a bounded short echo. Vocal output joins the post-music-FX bus before the shared master so words remain identifiable when music crushing is severe. Live cutoff/echo edits reach sounding phrases; ZHŪN off releases them with a 65 ms fade. Runtime cooldowns reconcile actual elapsed time and successful vocal starts when control revisions interrupt a scene. A projected actual deadline and final onset guard enforce at least eight seconds between accepted utterances, including manual reseeds/toggles.

`Render.scd` converts composed events to NRT OSC. SynthDefs and buffers precede groups; dependent groups use distinct timestamps; effects/master start before source notes. The renderer uses private buses 16/18 on its dedicated unbooted server allocator, unique per-output OSC paths, and checks scsynth's exit status. End-of-arrangement source cleanup preserves a bounded 3-second tail followed by fade. NRT does not depend on realtime replies or an audio device.

`GUI.scd` owns ten native sliders, ten latching switches and momentary actions. Its original Pen artwork now uses curved chrome filaments, an asymmetric opal orb, staggered capsule sliders, elliptical switches and a rounded utility dock. A faint city afterimage remains behind the abstract forms. GUI callbacks write through the central mapper; refresh runs on AppClock. F1 exposes a read-only legend, and the glyph button selects ASCII names. The moving line is procedural artwork; vocal captions appear only during actual phrase playback.

`App.scd` manages presets, numeric non-executable patch persistence, server readiness, transport, scene scheduling and ownership-aware cleanup. STOP cancels schedulers and clears source voices while effects tails continue; PANIC also mutes output. Closing cancels GUI routines and frees only owned resources. If closure happens during server/buffer preparation, readiness checks prevent orphan nodes. Manual server reboot requires re-evaluating Main.

Snapshots save controls, seed and preset format version. They do not serialize a previous live performance; export generates a reproducible arrangement for the chosen controls and length. Exact audio reproducibility also requires matching server version and asset bank.
