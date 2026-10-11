# ILLEGAL SUPERCOLLIDER YABUJINSLOP MACHINE

## Implementation handoff: development plan and agent orchestration

Historical planning brief, retained for context. The implementation and current validation results are documented in README.md and docs/VALIDATION.md. At the time this brief was written, no application implementation, dependency installation, or sample acquisition had been performed. The selected checkout is `/workspace/illegalsupercollideryabujinslop`; it currently has no commits or application files. `sclang` and `scsynth` are not installed in this instance. `ffmpeg` is available. Use the existing checkout: each cloud task already has an isolated environment; do not create a worktree unless explicitly requested.

Build an original, playable SuperCollider instrument with a native GUI, exactly **10 sliders and 10 two-state switches**, and the exact project title displayed prominently. It must make rhythmically convincing, emotionally strange music with recurring identity and unpredictable interruptions. Controls must interact with multiple algorithms. The surface should resemble a cursed obsolete desktop artifact: visually abrasive, operationally dependable.

### 1. Research basis and remaining reference work

Read these sources before implementing:

- Pitchfork, *Chasing Yabujin, the Artist Who Secretly Shaped the Underground Sound of the 2020s*: https://pitchfork.com/thepitch/chasing-yabujin-the-artist-who-secretly-shaped-the-underground-sound-of-the-2020s/
- Artist profile, useful for identity but not a production manual: https://yabujin.bandcamp.com/
- A public listening reference likely matching the user's `idontwant2go`: https://www.youtube.com/watch?v=bfkEY4F0THU — circulated as `。302？ionwan2go 。`. Confirm this identification before making track-specific claims.
- Fan/archive listening reference for NOKIA ANGELZ: https://dismissyourselfarchive.bandcamp.com/track/yabujin-hardstyle-drill-2009-nokia-angelz-16
- Archive collection listing BAROQUE, `ionwan2go`, and NOKIA ANGELZ: https://yabujinarchive1.bandcamp.com/album/gates-to-azeroy
- GUI: https://doc.sccode.org/Guides/GUI-Introduction.html
- Scheduling: https://doc.sccode.org/Classes/TempoClock.html and https://doc.sccode.org/Classes/AppClock.html
- Buses and order: https://doc.sccode.org/Classes/Bus.html and https://doc.sccode.org/Guides/Order-of-execution.html
- Playback: https://doc.sccode.org/Classes/PlayBuf.html and https://doc.sccode.org/Classes/BufRateScale.html
- Offline rendering: https://doc.sccode.org/Guides/Non-Realtime-Synthesis.html

The feature describes shimmering but unsettling synthetic melodies, defective-ocarina-like timbres, muffled or mangled voices, and deserted game-world atmosphere. It distinguishes the artist's wider aesthetic from generic repetitive jumpstyle imitation. Translate these observations into synthesis and arrangement decisions rather than treating a genre label as a recipe.

**Research limit:** the planning pass consulted text sources and official technical documentation; it did not listen to or measure the three requested recordings. Do not invent BPMs, exact patches, or transcriptions. The reference agent's first task is to audition BAROQUE, the likely `ionwan2go` reference, and NOKIA ANGELZ, verify titles and provenance, and write timestamped observations of drum placement, melodic contour, texture, transitions, and space. Public archive metadata is secondary evidence, not proof of an original upload or permission to redistribute recordings. If audition is unavailable, state that limitation and proceed with the documented aesthetic brief; do not claim audio analysis happened.

The requested Azeroyska language has no complete, reliable dictionary established by this research. All control names below are **original invented labels inspired by the visual and phonetic presentation of Azeroy**, not authenticated translations. Separate their display names from stable ASCII implementation IDs. Verified vocabulary can replace display labels later without changing their mappings.

### 2. Musical target

The default patch should feel like a melodic apparition crossing a damaged rave transmission. Preserve recognizable pitch material while the drum topology, playback speed, bandwidth, and spatial perspective mutate.

- **Rhythm:** dirty short kicks with occasional pitched hardstyle tails; brittle snares/claps; sparse metallic hats; abrupt rolls and missing downbeats. Alternate half-time/cloud-rap weight with short double-time or jumpstyle eruptions. Do not maintain a relentless four-on-the-floor kick throughout.
- **Melody:** create an original small motif pool using minor/pentatonic material, occasional semitone friction, naive bells, breathy digital flutes, thin trance voices, and cheap ROMpler-like layers. Variants should preserve enough contour to remain identifiable.
- **Atmosphere:** formant-shaped pseudo-voices, wavering pads, coarse telephone/filter coloration, electrical hum, haunted notification tones, static, and tiny foreground artifacts. Voices are self-recorded with consent, synthesized, or sourced under usable licenses; a vocal layer is optional.
- **Damage:** separate bit depth, effective sample rate, clipping, filtering, sample wear, and pitch instability. Their interaction should create character rather than merely making everything equally loud and distorted.
- **Space:** filtered short slapback, tempo-linked echo, occasional displaced repeats, and restrained washed-out reverb. Dry kick/sub should retain a useful center even when the upper layers disintegrate.
- **Identity:** return to transformed material. An unpredictable composition needs memory, contrast, and groove; arbitrary independent random notes are insufficient.

Starting tuning ranges, not claims about the reference recordings: 110–180 BPM, default around 145; occasional internal half/double-time interpretations; short scene durations of 2–28 beats. Tune these by listening before expanding ranges.

### 3. Arrangement: recurrent material with impulsive changes

Use a seeded event composer with a weighted, history-aware scene graph. Do not encode a mandatory intro/build/drop/break template, a fixed scene order, or a single loop with random fills.

Seven initial scene families:

1. **Vacant room:** sparse melodic fragments, noise, ghost kick, narrow bandwidth.
2. **False club:** a convincing groove interrupted by omitted steps and displaced accents.
3. **Rush:** bounded kick/hat acceleration and bright motif fragments.
4. **Phone corridor:** filtered sample/formant fragments and delayed responses.
5. **Fracture:** tiny retriggers, reverse fragments, tape dragging, rhythm interruption.
6. **Suspension:** held harmony, disappearing transients, one distant percussion source.
7. **Return:** a remembered motif or drum cell recast through the current damage and space settings.

Use irregular phrase lengths, including 3, 5, 7, and 11 beats, mixed with stable 4/8-beat passages. Most events remain locally intelligible; rare events bend that expectation. Tempo changes are bounded ramps or deliberate scene changes, not uncontrolled clock jumps.

Each scene proposes rhythm density, melodic prominence, register, bandwidth, effect sends, duration, and legal successors. Transition weights depend on macro settings, recent scenes, energy, and an intervention cooldown. Track recent rhythmic fingerprints, motif variants, and interventions. Penalize immediate repeated scenes and repeated identical event strings while permitting intentional motif returns. Silence is a bounded compositional event; avoid accidental indefinite silence.

Illustrative result, never a required template: a two-note flute phrase → three heavy beats → six seconds of strangely spacious snares → an 11-beat fast passage → a tiny reversed tail → the opening motif at the wrong octave → a long echo with one dry kick.

### 4. The 10 sliders

All values are normalized to 0–1. The audible front panel uses only the invented name and a small number/indicator. F1 opens a read-only technical legend. These are macro dimensions, not ordinary volume/EQ sliders.

| ID | Visible name | Shared influence | Low → high character |
|---|---|---|---|
| S01 | AZHŪR | Scene-transition hazard, pattern mutation, fill probability, motif variation | Familiar recurring cells → unstable but remembered fragments |
| S02 | DŽÆR | Bit-depth reduction, sample/hold rate, saturation drive, compensating gain | Fragile digital clarity → coarse damaged transmission |
| S03 | VØRZ | Half/double-time weighting, roll subdivision, bass articulation, tempo target | Dragging lurch → restless propulsion |
| S04 | NAŶA | Motif persistence, harmonic tension, bell/flute blend, pad voicing | Bleak sparse phrases → luminous dissonant apparition |
| S05 | THÆL | Delay send, repeat density, stereo offset, motif-answer timing | Close dry fragments → displaced echo conversations |
| S06 | KHUZ | Kick pitch envelope, controlled distortion, sub/harmonic balance, groove accents | Hollow thud → hostile pitched impact |
| S07 | ÆZRI | Formant/sample prominence, grain/retrigger duration, pitch instability, telephone filtering | Almost absent voice → ghost syllable swarm |
| S08 | SHØR | Bandwidth loss, dust/noise, slow wow/flutter, high-frequency damping | New plastic → rotten tape and electrical residue |
| S09 | UZH | Percussion sparsity, gate/dropout chance, scene duration, negative space | Busy continuous surface → interrupted empty architecture |
| S10 | YŌR | Reverb send, pitch-linked resonances, stereo width, pad attack/release | Small room → distant implausible landscape |

Mapping rules: give each slider 3–6 meaningful destinations spanning at least two modules; document curves, bounds, smoothing, and compensation. A slider must remain useful regardless of switch positions, using alternate destinations where a processing mode is disabled. Avoid allowing S02 and S08 to become indistinguishable: S02 is digital resolution, S08 is spectral/mechanical wear. S03 should not collapse to global BPM; it also changes interpretation of the grid. S09 should change spatial rhythm rather than simply turn down volume.

Example DŽÆR mapping: effective hold rate from 32 kHz toward 2.5 kHz with sample-rate-aware bounds; bit depth from 14 toward 5 bits; drive from 1 toward 4; simultaneous output trim. These are initial audition ranges, not universal safe gain guarantees. Bound resonance and noise separately.

Implement a central mapper from `{sliders, switches, scene, seed}` to bounded musical/DSP parameters. Slew continuous DSP controls with roughly 20–200 ms smoothing depending on parameter. Rhythm edits generally apply at the next useful subdivision; an intentional fracture may interrupt sooner with short fades. Cap downstream parameter values after composing macro influences.

### 5. The 10 switches

Exactly ten latching, two-state performance switches. Transport, export, reseed, and panic are momentary buttons or keyboard commands and must not add more latching controls.

| ID | Visible name | When enabled, it changes multiple systems |
|---|---|---|
| T01 | ÆKRA | Allows short hardstyle/jumpstyle eruptions: kick recipe, accent grammar, bass-following behavior |
| T02 | ZHŪN | Enables ghost voices/formants, vocal-answer placement, telephone spatial treatment |
| T03 | VÆSH | Permits reverse slices, reversed-envelope instruments, reverse-prelude transitions |
| T04 | NØZA | Activates a phone-like spectral regime across selected layers plus notification motifs and short slap echoes |
| T05 | DZYR | Allows clustered stutter interventions affecting drums, melody gates, and effect-send bursts |
| T06 | ŪZHA | Enables tape-collapse events: synchronized slowing, falling pitch, bandwidth loss, recovery |
| T07 | KÆR | Enables unstable pitch/scale variants, inharmonic timbres, and harmonic scene substitutions |
| T08 | THØN | Permits bounded feedback echo rituals, irregular delay ratios, repeat filtering, and tail-focused transitions |
| T09 | AYZ | Remembers selected motif/rhythm cells and biases future returns; this is compositional memory, not a UI freeze |
| T10 | ŠÆL | Biases the scene graph toward rupture and negative space while changing dropout shape and recovery grammar |

Off means that specific behavior family is excluded; on permits or biases it, rather than making it happen continuously. Start with T02 and T09 on and the disruptive modes mostly off. All-off must remain musically viable; all-on must remain bounded and responsive. Every switch must have a demonstrable audible consequence in a suitable seeded render; placebo controls fail acceptance.

### 6. Audio architecture

Use standard SuperCollider and stock UGens. Do not make the core dependent on SC3plugins, VST hosts, commercial plugins, Quarks, a network connection, or a downloaded pack. `Decimator` is an extension; implement the default crusher using stock sample-and-hold (`Latch`/`Impulse`) and quantization (`round`) instead. Extra plugins can be an optional later enhancement after the core passes.

Modules and ownership contracts:

- `State`: normalized controls, switches, deterministic seed, preset schema/version, lifecycle state.
- `MacroMap`: pure mapping and validated parameter bounds; the only authority on user-control interpretation.
- `Composer`: scene graph, motif/rhythm memory, bounded interventions, seeded event list; no GUI references and no dependency on audio-server replies.
- `Voices`: kick, snare/clap, hats/metal, bass, bell/flute, unstable pad, formant/noise, mono/stereo sample voices.
- `AudioGraph`: buses/groups, effect nodes, final output, server resources and teardown.
- `Samples`: relative-path loading, generated defaults, license manifest, mono/stereo classification, completion tracking.
- `GUI`: 10 sliders, 10 switches, title, meters and momentary transport/export actions; sends state changes through `State`/`MacroMap`.
- `Render`: translates the same events and automation to NRT Score messages and export metadata.

Signal flow:

`voices → private dry/sub, music, percussion, atmosphere buses → per-layer coloration/crush → filtered delay + reverb sends → master mix → DC removal / bounded dynamics / final limiter → stereo output`

Keep source groups before processing groups and processing before master. Allocate private buses using `Bus.audio`; never assume a private bus starts at hardware output index 0. Preserve an undamaged low-end route when appropriate. Feedback requires explicit maximum gain, damping, and tests; begin below 0.85 and refine within a verified bound. Limiting is a final backstop, not a replacement for sensible source gains. Select and document headroom and peak limits through render analysis.

Concrete initial engineering limits: delay allocation 2 seconds with normal delay times 0.02–1.5 seconds; feedback coefficient 0–0.8 with filtering and saturation inside the loop; 48 concurrent voices, at most four ratchets per event, at most 96 emitted events per second, and 128 MiB loaded sample data. The composer must enforce both voice and event budgets under all control combinations. Treat more permissive limits as deliberate profiled revisions. An initial master `Limiter` at 0.85 with 0.005-second lookahead adds 10 ms latency; put emergency mute after it. `LocalIn` adds one block to feedback timing. Neither limiting nor saturation repairs NaNs: constrain divisors, frequencies and indices and use `CheckBadValues` while validating. See https://doc.sccode.org/Classes/Limiter.html and https://doc.sccode.org/Classes/LocalIn.html.

Use one music scheduler on `TempoClock`; GUI actions/updates go through `AppClock` or `.defer`. Throttle meters/redrawing to about 15–30 Hz. Audio automation must not depend on GUI redraw frequency. Account for asynchronous server boot, synth definition loading, and buffer reads before starting. Use `s.sync`/completion callbacks where appropriate. `PlayBuf` has a fixed channel count: provide separate mono/stereo SynthDefs and use `BufRateScale` for playback-rate correction. Reverse playback starts from a valid end frame. Mono/stereo buffers, different sample rates, and short files must all be handled.

Use bounded polyphony and finite voice lifetimes. Initial cap: roughly 48–64 transient voices plus a few managed sustained/effect nodes, then tune to actual hardware. Avoid per-event permanent synths or unbounded buffers. Stop releases voices; panic mutes/releases immediately; closing the window cancels schedulers, frees owned resources, and leaves a clean restart. Avoid globally killing unrelated user synths on a shared server.

### 7. Visual direction

The complete exact title, **ILLEGAL SUPERCOLLIDER YABUJINSLOP MACHINE**, appears in the window and in the main collage header. Use native `Window`, `UserView`, `Slider`, two-state `Button`, and `StaticText` components. Ship the appearance inside the project; no live remote images.

Picture a rotten 2001 control panel found in a vacant apartment: photocopied apartment blocks, forest edge and streetlights inspired by Visaginas, ugly bevels, cheap violet/chlorine-green panels, gray concrete, artificial red warning fragments, huge pixelated stickers, scratched scanlines, low-resolution dusk, and tiny obsolete-banner debris. Use original/licensed landscape imagery or procedural silhouettes; create a coherent art direction rather than an arbitrary meme dump.

For the requested creepy regional internet atmosphere, use haunted forum/signature collage, aged satellite/phone motifs, compression scars and custom pseudo-script glyphs. Keep the work specific to invented worldbuilding. Do not present random Arabic as a translation of Azeroyska or imply the invented language is a real regional language. Readable native controls can sit inside aggressively unpleasant artwork.

Layout: title/banner across the top; ten vertical sliders in two groups of five; ten switches in two corresponding rows of five; central low-rate waveform/oscilloscope-like artifact; small status/meter region; bottom momentary actions. Labels remain readable and click targets usable at 1280×720 and larger. Supply an ASCII fallback if decorative fonts lack glyphs. Effects must not obscure controls or require aggressive screen flashing. F1 shows the technical legend without introducing additional editable sliders/switches.

Ship three original visual variants/palette states tied to musical scenes, not ten unrelated themes. Keep low-rate animation optional and inexpensive. A rough ASCII/procedural skin is acceptable during integration; a generic clean dashboard is not the final deliverable.

### 8. Assets and downloads

Generate a complete default sound set locally first: synth drums, wavetable-like bell/flute sounds, pseudo-vocal formants, phone tones, electrical noises, and texture buffers. The instrument must work on first launch with this set alone.

The asset agent may add a small carefully chosen pack: metallic hits, unusual snares, disposable-camera/phone sounds, wind, room tone, and original vocal fragments. Prefer CC0 or clearly documented redistribution-compatible licenses. Freesound licenses differ by file and downloads can need authentication; do not treat the website as a blanket CC0 pack or make an API key a startup requirement. Other potential sources are explicitly CC0 OpenGameArt sound collections or self-recordings; verify each exact asset. Archive songs are listening references, not automatically distributable sample libraries.

For every external file, record source URL, creator, asset title, license, download date, checksum and transformation notes in `assets/LICENSES.json` or CSV. Include required attribution text. Keep optional content below a practical initial budget (about 50 MB) unless a clear sonic need justifies more. Cache usable downloads and preserve TLS/checksum verification. Missing optional downloads fall back to the generated bank; missing user samples produce a concise message rather than a startup crash.

### 9. Repository structure and launch

Suggested structure; implementation may simplify without losing ownership boundaries:

```text
Main.scd
src/State.scd
src/MacroMap.scd
src/Composer.scd
src/Voices.scd
src/AudioGraph.scd
src/Samples.scd
src/GUI.scd
src/Render.scd
assets/generated/
assets/optional/
assets/gui/
assets/LICENSES.json
presets/
tests/
tools/
docs/REFERENCE_NOTES.md
docs/CONTROL_MAP.md
docs/ARCHITECTURE.md
README.md
```

Prefer loadable `.scd` modules and environments/functions over custom class-library extensions that require a language recompile. Resolve paths from the entry-point location, not the user's current working directory. Establish and document a tested language/server version pair; current online documentation is 3.14, but verify package availability before choosing a pin. Document desktop audio backends per supported OS.

Required workflows: open/evaluate `Main.scd` on a desktop and hear the instrument; deterministic offline WAV export; save/load/reseed a patch. A snapshot stores all 20 controls, the seed, bank/preset version and relevant configuration. Reseeding changes composition without resetting the user's controls. If exact mid-performance continuation is promised later, also serialize PRNG and scene memory; do not promise that from a control snapshot alone.

Cloud validation uses headless language/NRT execution and a GUI smoke check through Xvfb if available. Realtime audio on Linux may need an available audio backend or a documented dummy JACK test setup; an offscreen GUI or NRT render alone does not prove desktop playback. Startup scripts must distinguish retained assets/dependencies from processes requiring restart. Do not publish localhost preview links. During a future environment setup, save tested install/start instructions through the onboarding draft tool only after implementation establishes the actual requirements.

### 10. Agent orchestration

The next model is the integration lead. Freeze the state schema, event schema, bus layout, parameter names and limits first. Give every specialist this full brief and the frozen contracts. Assign file ownership; shared-file edits go through the lead. Parallel agents should communicate interface changes before implementing them. Use the existing checkout, not separate worktrees.

| Agent | Owned work | Inputs/dependencies | Required handoff |
|---|---|---|---|
| Lead/integrator | Entry point, state contracts, integration, launch docs, final review | Entire brief; empty repository | Runnable integrated project, conflict resolution, truthful validation report |
| Reference/asset specialist | Reference notes, asset provenance, optional sample bank and GUI source imagery | Named recordings; licensing requirements | Timestamped listening notes where audition is possible, original sonic targets, verified manifest and small assets |
| DSP specialist | Voices and AudioGraph | Frozen bus/parameter contracts; generated-default plan | Stock-UGen SynthDefs, signal graph, resource/feedback limits, solo renders |
| Composition specialist | Composer and MacroMap | Frozen event/state schemas; reference targets | Seeded events, scene graph, motif memory, all 20 multi-target mappings, trace/export compatibility |
| GUI/art specialist | GUI and local visual assets | Frozen state API and control names | Exact 10+10 interface, title, legend, ugly coherent skin, working callbacks and lifecycle |
| Validation/render specialist | Render, test harness, measurements and QA artifacts | Shared event model, voices, lifecycle API | Reproducible renders, stress/GUI/lifecycle checks, control audit, exit-status reporting |

Do not run six agents before their interfaces exist. Recommended sequence:

1. **Lead + reference specialist:** verify references/toolchain; draft original sonic palette. Lead writes schemas and module stubs. Reference work can continue without blocking skeleton audio.
2. **DSP + composition + GUI:** work in parallel against those contracts. Use generated defaults and provisional textures. The validation specialist can build the harness once event/render contracts are frozen.
3. **Lead integrates one playable slice:** kick + snare + motif + crusher + delay; full 20-control front panel connected to real state. Do not stop at a disconnected mockup.
4. **Complete musical systems:** remaining voices, history-aware scenes, all mapping destinations, reversible interventions, assets and skin. Specialist agents return reproducible demo artifacts, not only claims of completion.
5. **Validation + lead:** deterministic audio checks, resource/lifecycle stress, GUI operation, listening review; reopen narrow defects with the owning agent.
6. **Lead final pass:** launch from a clean process using documented commands; package sources/assets/docs/demo renders; report exactly what was verified and what requires desktop/human listening.

If the next environment offers fewer slots, serialize assets and validation while keeping DSP, composition and GUI separate. Do not delegate a monolithic rewrite of a file owned by someone else. Technical and aesthetic review are both gates; passing DSP tests does not establish musical quality.

### 11. Acceptance criteria and useful tests

**Functional:** entry point loads; generated bank works without network; all 20 controls update state and affect declared systems; title is exact; preset roundtrip restores values/seed; transport stops/restarts cleanly; export creates the intended stereo WAV; optional asset failures degrade gracefully.

**Determinism and composition:** same seed/control automation produces the same event trace. Audio reproducibility also requires explicit seeds for server-side random UGens. Render at least three seeds for approximately 90–180 seconds, plus a 10-minute event-only trace. Review scene and motif recurrence, interventions, and silence durations. Assert permitted transitions, bounded event density/durations and no pathological infinite rest. Record variation metrics as diagnostics; human listening judges whether novelty serves the track.

**Control coverage:** sweep each slider through 0, 0.5 and 1 while holding a documented comparison patch and seed. Verify at least two modules receive meaningful parameter changes, then inspect/listen to paired audio. Check each switch enabled/disabled with a seed/patch that can exercise it. Include all-off, all-on, pairwise switch coverage, and several seeded random combinations; 1024 exhaustive long renders are unnecessary initially. Sweep extremes while running realtime to expose clicks and scheduling failure.

**DSP/render:** compile every SynthDef. Use the shared event composer to produce an NRT `Score`; use an unbooted dedicated server object for allocation and placeholder `basicNew`/message APIs rather than accidentally sending realtime OSC. Front-load definitions/buffers, then start musical events at a positive offset. NRT cannot depend on `SendReply`, bus reads or node notifications. Confirm current output files, render completion and original command exit status. Check finite samples, channels/rate/duration, peak limits, meaningful non-silence and excessive DC. Include effects tails and the final stop/fade in export. Do not judge intentional distortion merely by a low crest factor.

**GUI:** instrument exact slider and latching-switch counts; verify every callback against state; test Unicode/ASCII fallback and representative window sizes; capture a real GUI screenshot. Xvfb/offscreen confirms construction and callbacks, not an actual desktop audio session. Update UI from the proper clock; close/reopen and stop/start several times without stale schedulers, voices or buffers.

**Resources:** run an all-on bounded-density stress patch on measured hardware; record CPU and voice/buffer counts. Set a realistic CPU budget after profiling rather than claiming performance on an untested laptop. Prove old nodes/buffers are released after repeated restart. Test a missing file, mono/stereo asset and sample-rate mismatch.

**Listening/art review:** the lead or available listener should hear memorable melodic material, convincing locally stable grooves, at least three distinct spatial/texture regimes, and interruptions that avoid a predictable song-section ladder. If actual listening is unavailable, supply WAVs and label aesthetic approval pending. Do not call FFmpeg statistics a listening test.

### 12. Required deliverables

1. Complete source and assets with one obvious entry point and practical desktop/headless instructions.
2. Documented mapping of all 10 sliders and 10 switches, including bounds and interactions.
3. At least three original preset/seed demonstrations: sparse haunted melody, corrupted club rhythm, and severe fracture, plus a balanced default.
4. Short stereo demo renders and event/parameter traces that match the packaged version.
5. Reference notes with honest evidence limits and verified external-asset licensing.
6. Validation report separating passed, failed, skipped and unrun checks, measured platform/toolchain, known defects and listening status.

Implementation priority: make one convincing musical slice audible first; complete interacting composition and sound systems next; integrate the complete visual artifact; validate and package. Extra plugins, large sample packs, MIDI, network features and DAW integration are optional later work, never substitutes for the requested core instrument.

### Copyable instruction for the implementation model

Implement this brief in the existing repository. Start by inspecting the current checkout and installing a verified compatible SuperCollider language/server pair where needed. Use the planned specialist orchestration only after freezing shared interfaces. Produce a complete native SuperCollider project with the exact title and exactly 10 sliders plus 10 latching switches, stock-UGen audio, generated default assets, multi-target macro mappings, an impulsive history-aware composer, grotesque usable GUI, deterministic offline export and meaningful validation. Research the named recordings honestly; do not fabricate listening observations, authentic Azeroyska vocabulary, test results, or asset licenses. Continue through integration and correction of setup/runtime failures. Provide demo WAVs, source, control documentation and a truthful final verification report. Do not stop at a GUI mockup or a repetitive loop.
