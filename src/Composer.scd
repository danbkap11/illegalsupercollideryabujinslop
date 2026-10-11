/* Deterministic scene composer. No server, GUI, clock or global random state. */
(
~ism[\map] = { |sliders, switches|
    var x, z, p, tempo, damage, wear, phone, vocalFilterCoeff;
    x = Array.fill(10, { |i| ((sliders.at(i) ? 0.5).asFloat).clip(0, 1) });
    z = Array.fill(10, { |i| ((switches.at(i) ? 0).asInteger).clip(0, 1) });
    tempo = (110 + (70 * x[2])).clip(110, 180);
    damage = x[1]; wear = x[7]; phone = z[3];
    vocalFilterCoeff = (x[6] * (1 - (0.32 * wear)) * (1 - (0.18 * phone))).clip(0, 1);
    p = (
        bpm: tempo,
        bits: (16 - (11 * damage)).clip(5, 16),
        holdRate: (32000 * (2500 / 32000).pow(damage)).clip(2500, 32000),
        drive: (1 + (2.7 * damage) + (0.3 * x[5])).clip(1, 4),
        wear: (wear + (0.10 * z[5])).clip(0, 1),
        delayTime: ((60 / tempo) * (0.25 + (0.5 * x[4]) + (0.125 * z[7]))).clip(0.02, 1.5),
        delayMix: (0.015 + (0.37 * x[4]) + (0.08 * z[7]) + (0.025 * phone)).clip(0, 0.5),
        feedback: (0.08 + (0.42 * x[4]) + (0.25 * z[7])).clip(0, 0.8),
        reverbMix: (0.025 + (0.40 * x[9]) + (0.025 * z[1])).clip(0, 0.45),
        width: (0.10 + (0.75 * x[9]) + (0.15 * x[4])).clip(0, 1),
        phone: phone,
        gain: (0.72 / (1 + (0.55 * damage))).clip(0.46, 0.72),
        sceneEntropy: (0.12 + (0.70 * x[0]) + (0.18 * z[9])).clip(0, 1),
        motifMutation: (0.04 + (0.52 * x[0]) + (0.18 * z[6])).clip(0, 0.8),
        fillChance: (0.08 + (0.42 * x[0]) + (0.15 * z[4])).clip(0, 0.8),
        swing: (0.015 + (0.08 * (1 - x[2])) + (0.025 * x[0])).clip(0, 0.13),
        rushWeight: (0.25 + (1.4 * x[2]) + (1.3 * z[0])),
        rollCount: (2 + (2 * x[2])).round.asInteger.clip(2, 4),
        bassDuration: (0.18 + (0.52 * (1 - x[2]))).clip(0.18, 0.70),
        motifChance: (0.45 + (0.52 * x[3])).clip(0.45, 0.97),
        tension: (0.04 + (0.34 * x[3]) + (0.24 * z[6])).clip(0, 0.75),
        bellTone: (0.18 + (0.70 * x[3]) - (0.28 * wear) - (0.22 * phone)).clip(0, 1),
        melodyAmp: (0.065 + (0.055 * x[3])).clip(0.065, 0.12),
        answerChance: (0.10 + (0.52 * x[4]) + (0.22 * z[7])).clip(0, 0.85),
        answerOffset: (0.50 + (0.75 * x[4]) + (0.375 * z[7])),
        panSpread: (0.12 + (0.38 * x[4]) + (0.36 * x[9])).clip(0, 0.86),
        kickFreq: (42 + (35 * x[5])),
        kickBend: (-3 + (12 * x[5]) + (3 * z[0])).clip(-3, 12),
        kickDrive: (1 + (2.3 * x[5]) + (0.6 * z[0])).clip(1, 4),
        kickAccent: (0.22 + (0.13 * x[5])).clip(0.22, 0.35),
        bassTone: (0.20 + (0.62 * x[5]) - (0.16 * wear)).clip(0, 1),
        vocalGap: (8 + (40 * (1 - x[6]).pow(1.6))).clip(8, 48),
        vocalFilterCoeff: vocalFilterCoeff,
        vocalCutoff: (1100 + (7900 * vocalFilterCoeff)).clip(1100, 9000),
        vocalRate: (0.85 + (0.23 * x[6])).clip(0.85, 1.08),
        vocalAmp: (0.06 + (0.04 * x[6])).clip(0.06, 0.10),
        vocalDelayMix: (0.02 + (0.27 * x[4]) + (0.06 * z[7])).clip(0, 0.35),
        voiceBend: (0.15 + (1.25 * x[6]) + (0.45 * z[6])),
        sampleBlend: (0.12 + (0.63 * x[6]) + (0.20 * phone)).clip(0, 0.95),
        noiseChance: (0.05 + (0.42 * wear)).clip(0.05, 0.47),
        noiseAmp: (0.008 + (0.031 * wear)).clip(0.008, 0.039),
        sourceTone: (0.95 - (0.65 * wear) - (0.20 * phone)).clip(0, 1),
        wowCents: (0.4 + (9.6 * wear)).clip(0.4, 10),
        dropout: (0.035 + (0.48 * x[8]) + (0.16 * z[9])).clip(0, 0.70),
        drumDensity: (1 - (0.60 * x[8])).clip(0.40, 1),
        sceneStretch: (0.85 + (0.50 * x[8]) + (0.12 * z[9])),
        noteGate: (0.92 - (0.37 * x[8])).clip(0.55, 0.92),
        padDuration: (1.8 + (4.5 * x[9])),
        padVoices: (1 + (2 * x[9])).round.asInteger.clip(1, 3),
        padTone: (0.23 + (0.45 * x[9]) - (0.20 * wear)).clip(0, 1),
        padAmp: (0.025 + (0.020 * x[9])),
        resonanceOffset: (0.005 + (0.020 * x[9])),
        hardstyle: z[0], ghosts: z[1], reverse: z[2],
        stutter: z[4], collapse: z[5], unstable: z[6],
        ritual: z[7], memory: z[8], rupture: z[9],
        sliders: x, switches: z
    );
    p
};

~ism[\compose] = { |seed = 302, sliders, switches, seconds = 60, memory, singleScene = false, vocalFloor = 0|
    var p, x, z, rng, rand, coin, pick, weighted, add, events, scenes;
    var names, transitions, motifs, melodyTimes, melodyDurations, grooves;
    var rememberedMotif, rememberedGroove, motifIndex, grooveIndex, rootMidi;
    var at, length, beat, previous, recent, sceneIndex, sceneNumber, weights;
    var sceneBeats, sceneDuration, sceneEnd, stepCount, sceneEnergy, melodyWeight;
    var shape, groove, tape, tapeStart, sparseHole, holeStart, holeEnd, lastMotif;
    var eventIndex, ordered, bounded, active, recentTimes, accepted, composedScenes;
    var vocalNext, vocalInitialRemaining, phraseLastIndex, vocalWasEnabled, phraseDuration;

    p = ~ism[\map].value(sliders, switches); x = p[\sliders]; z = p[\switches];
    length = seconds.asFloat.clip(0.1, 36000); beat = 60 / p[\bpm];
    rng = if(memory.isNil, { (seed.asInteger.abs % 2147483646) + 1 }, {
        (memory[\rng] ? 1).asInteger.clip(1, 2147483646)
    });
    // Park-Miller local state: predictable across language runs without changing
    // thisThread.randSeed or relying on audio-server random generators.
    rand = { rng = (rng * 16807) % 2147483647; rng / 2147483647 };
    coin = { |chance| rand.value < chance.clip(0, 1) };
    pick = { |array| array[(rand.value * array.size).floor.asInteger.min(array.size - 1)] };
    weighted = { |array|
        var probe, index;
        probe = rand.value * array.sum; index = 0;
        while { (index < (array.size - 1)) and: { probe >= array[index] } } {
            probe = probe - array[index]; index = index + 1;
        };
        index
    };
    events = List.new; scenes = List.new; eventIndex = 0;
    add = { |time, voice, dur, freq, amp, pan = 0, drive = 1, tone = 0.5, reverse = 0, bend = 0|
        var clippedDur, eventSeed;
        if((time >= 0) and: { time < length }, {
            clippedDur = dur.clip(0.035, 12).min(length - time);
            eventSeed = (rand.value * 2147483645).floor.asInteger + 1;
            if(clippedDur > 0.005, {
                events.add((time: time.asFloat, voice: voice, dur: clippedDur,
                    args: [\freq, freq.clip(20, 16000), \amp, amp.clip(0, 0.5),
                        \pan, pan.clip(-1, 1), \drive, drive.clip(1, 4),
                        \tone, tone.clip(0, 1), \reverse, reverse.asInteger.clip(0, 1),
                        \bend, bend.clip(-24, 24)], seed: eventSeed, order: eventIndex));
                eventIndex = eventIndex + 1;
            });
        });
    };

    names = [\vacantRoom, \falseClub, \rush, \phoneCorridor, \fracture, \suspension, \return];
    // All transitions are legal; weights provide history-aware movement rather
    // than a fixed song-section ladder. A same-scene repeat is heavily penalized.
    transitions = [
        [0.08, 1.5, 0.7, 1.2, 0.8, 0.4, 1.4],
        [0.6, 0.08, 1.4, 0.7, 1.4, 0.6, 1.3],
        [0.9, 0.8, 0.08, 1.2, 1.7, 1.5, 1.2],
        [0.9, 1.3, 0.5, 0.08, 0.8, 1.2, 1.7],
        [0.8, 1.8, 1.4, 1.0, 0.08, 0.6, 2.0],
        [1.2, 1.5, 1.2, 0.8, 0.6, 0.08, 2.0],
        [1.0, 1.4, 1.0, 1.2, 1.0, 0.7, 0.08]
    ];
    // Original pentatonic contours: the same identifiable cell returns with
    // altered register, articulation and small substitutions, not random notes.
    motifs = [
        [0, 7, 10, 12, 15, 12, 10, 5],
        [12, 10, 7, 3, 5, 7, 3, 0],
        [0, 3, 7, 10, 7, 5, 3, -2],
        [7, 12, 10, 7, 3, 5, 10, 7]
    ];
    melodyTimes = [0, 0.75, 1.5, 2.75, 3.5, 4.5, 5.25, 6.5];
    melodyDurations = [0.55, 0.45, 0.85, 0.45, 0.70, 0.42, 0.85, 1.10];
    grooves = [
        [0, 1.5, 2.75, 4, 5.25, 6.5, 7.5],
        [0, 0.75, 3.25, 4.5, 5.75, 7],
        [0, 1.75, 3.5, 4, 6.25, 7.75]
    ];
    if(memory.isNil, {
        rememberedMotif = pick.value([0, 1, 2, 3]); rememberedGroove = pick.value([0, 1, 2]);
        motifIndex = rememberedMotif; grooveIndex = rememberedGroove;
        rootMidi = pick.value([45, 48, 50, 53]);
        previous = -1; recent = List.new; sceneNumber = 0; lastMotif = -1;
    }, {
        rememberedMotif = (memory[\rememberedMotif] ? 0).asInteger.clip(0, 3);
        rememberedGroove = (memory[\rememberedGroove] ? 0).asInteger.clip(0, 2);
        motifIndex = (memory[\motifIndex] ? rememberedMotif).asInteger.clip(0, 3);
        grooveIndex = (memory[\grooveIndex] ? rememberedGroove).asInteger.clip(0, 2);
        rootMidi = (memory[\rootMidi] ? 45).asInteger.clip(36, 60);
        previous = (memory[\previous] ? -1).asInteger.clip(-1, 6);
        recent = List.new.addAll((memory[\recent] ? []).copy);
        sceneNumber = (memory[\sceneNumber] ? 0).asInteger;
        lastMotif = (memory[\lastMotif] ? -1).asInteger;
    });
    // This is a wall-time countdown, not a per-scene Bernoulli trial. Short
    // scenes and live macro edits must not multiply vocal appearances. Runtime
    // reconciles this projected countdown with time actually played when a
    // revision interrupts a scene; the pure composer retains it in memory.
    phraseDuration = 6.0; // Conservative placeholder; Samples resolves the clip's actual lifetime.
    phraseLastIndex = if(memory.isNil, { -1 }, {
        (memory[\phraseLastIndex] ? -1).asInteger.clip(-1, 7)
    });
    vocalWasEnabled = if(memory.isNil, { 0 }, {
        (memory[\vocalWasEnabled] ? 0).asInteger.clip(0, 1)
    });
    vocalNext = if(memory.isNil or: { memory[\vocalRemaining].isNil }, {
        3 + (5 * rand.value)
    }, { memory[\vocalRemaining].asFloat.clip(0, 60) });
    if((z[1] == 1) and: { vocalWasEnabled == 0 }, {
        vocalNext = vocalNext.max(3 + (5 * rand.value));
    });
    // Runtime can supply its actual most-recent vocal deadline after a manual
    // reseed or toggle; ordinary offline composition leaves this at zero.
    vocalNext = vocalNext.max(vocalFloor.asFloat.clip(0,60));
    vocalInitialRemaining = vocalNext;
    at = 0.0; composedScenes = 0;
    while { (at < length) and: { singleScene.not or: { composedScenes < 1 } } } {
        weights = if(previous < 0, { [1.2, 2.2, 0.6, 0.7, 0.5, 0.25, 1.1] }, { transitions[previous].copy });
        weights[2] = weights[2] * p[\rushWeight];
        weights[3] = weights[3] * (1 + (0.8 * z[1]) + (0.9 * z[3]) + (0.3 * z[7]));
        weights[4] = weights[4] * (0.55 + (1.8 * p[\sceneEntropy]) + (1.4 * z[9]));
        weights[5] = weights[5] * (0.65 + (1.3 * x[8]) + (0.7 * z[7]));
        weights[6] = weights[6] * (1 + (1.5 * z[8]));
        recent.do { |index| weights[index] = weights[index] * 0.42 };
        sceneIndex = weighted.value(weights);
        sceneBeats = if(coin.value(p[\sceneEntropy]), {
            pick.value([3, 5, 7, 11])
        }, { pick.value([4, 8, 8]) });
        if(sceneIndex == 2, { sceneBeats = sceneBeats.min(8) });
        if(sceneIndex == 5, { sceneBeats = sceneBeats.min(7) });
        sceneBeats = (sceneBeats * p[\sceneStretch]).round.asInteger.clip(2, 15);
        sceneDuration = (sceneBeats * beat).min(length - at); sceneEnd = at + sceneDuration;
        scenes.add((time: at, name: names[sceneIndex], beats: sceneBeats, duration: sceneDuration));

        if((sceneIndex == 6) and: { z[8] == 1 }, {
            motifIndex = rememberedMotif; grooveIndex = rememberedGroove;
        }, {
            if(coin.value(0.24 + (0.48 * x[0]) + (0.18 * (1 - z[8]))), {
                motifIndex = (motifIndex + pick.value([1, 2, 3])) % motifs.size;
            });
            if(coin.value(0.30 + (0.42 * x[0])), { grooveIndex = pick.value([0, 1, 2]) });
            if((z[8] == 1) and: { coin.value(0.26) }, {
                rememberedMotif = motifIndex; rememberedGroove = grooveIndex;
            });
        });
        shape = motifs[motifIndex]; groove = grooves[grooveIndex];
        sceneEnergy = [0.30, 1.0, 1.14, 0.34, 0.72, 0.12, 0.88][sceneIndex];
        melodyWeight = [0.92, 0.85, 0.60, 0.96, 0.58, 0.67, 1.0][sceneIndex];
        tape = (z[5] == 1) and: { (sceneIndex == 4) or: { (sceneNumber % 4) == 2 } };
        tapeStart = sceneBeats * 0.58;
        sparseHole = coin.value(p[\dropout]) or: { (z[9] == 1) and: { sceneIndex == 4 } };
        holeStart = if(z[9] == 1, { sceneBeats * 0.28 }, { sceneBeats * 0.57 });
        holeEnd = (holeStart + (0.35 + (1.7 * x[8]) + (0.60 * z[9]))).min(sceneBeats - 0.25);

        // Stable local rhythmic cells anchor the listener. Every scene has one
        // low/melodic landmark, including suspension; no indefinite rest.
        if(sceneIndex != 5, {
            add.value(at, \ismKick, beat * (0.40 + (0.18 * z[0])), p[\kickFreq],
                p[\kickAccent] * if(sceneIndex == 0, { 0.55 }, { 1.0 }), 0,
                p[\kickDrive], p[\sourceTone], 0, p[\kickBend]);
        });
        stepCount = (sceneDuration / beat * 4).ceil.asInteger;
        stepCount.do { |step|
            var b, time, inHole, kickHit, hardHit, slowed, localBend, hatHit, snareHit, accent;
            b = step * 0.25;
            time = at + (b * beat) + if(step.odd, { beat * p[\swing] }, { 0 });
            inHole = sparseHole and: { (b >= holeStart) and: { b < holeEnd } };
            slowed = tape and: { b >= tapeStart };
            if(slowed, { time = time + ((b - tapeStart) * beat * 0.25) });
            localBend = if(slowed, { -3 - (9 * ((b - tapeStart) / (sceneBeats - tapeStart)).clip(0, 1)) }, { 0 });
            hardHit = (z[0] == 1) and: { sceneIndex == 2 } and: {
                if(x[2] > 0.78, { (step % 2) == 0 }, { (step % 4) == 0 })
            };
            kickHit = groove.any { |position| ((b % 8) - position).abs < 0.01 };
            if((step > 0) and: { (kickHit or: { hardHit }) and: { inHole.not } }, {
                if(coin.value((sceneEnergy * p[\drumDensity]).clip(0.1, 1)), {
                    accent = if((step % 4) == 0, { 1.0 }, { 0.77 });
                    add.value(time, \ismKick, beat * if(hardHit, { 0.75 }, { 0.43 }),
                        p[\kickFreq] * if(hardHit, { 1.12 }, { 1 }),
                        p[\kickAccent] * accent, 0, p[\kickDrive], p[\sourceTone],
                        0, p[\kickBend] + localBend);
                });
            });
            // A half-time snare lattice. Rush changes the kick interpretation
            // without destroying the remembered backbeat.
            snareHit = ((step % 16) == 8) or: { (sceneIndex == 2) and: { (step % 16) == 12 } };
            if(snareHit and: { inHole.not } and: { coin.value((sceneEnergy * p[\drumDensity] * 1.1).clip(0.10, 1)) }, {
                add.value(time, \ismSnare, beat * 0.40, 170 + (50 * x[0]),
                    (0.12 + (0.035 * x[5])) * if(sceneIndex == 0, { 0.45 }, { 1 }),
                    (rand.value - 0.5) * 0.14, 1 + (0.6 * x[1]), p[\sourceTone], 0, localBend);
            });
            hatHit = ((step % 2) == 0) or: { (x[2] > 0.72) and: { sceneIndex == 2 } };
            if(hatHit and: { inHole.not } and: { coin.value((0.46 * sceneEnergy * p[\drumDensity]).clip(0.05, 0.8)) }, {
                add.value(time, \ismHat, beat * if((step % 4) == 2, { 0.26 }, { 0.12 }),
                    6300 + (3500 * x[2]), 0.030 + (0.035 * rand.value),
                    (rand.value - 0.5) * p[\panSpread], 1, p[\sourceTone],
                    if((z[2] == 1) and: { (step % 16) == 14 }, { 1 }, { 0 }), localBend);
            });
            if(kickHit and: { (step % 8) != 7 } and: { inHole.not } and: {
                coin.value((sceneEnergy * 0.62 + (0.16 * z[0])).clip(0.08, 0.95))
            }, {
                add.value(time + (0.022 * beat), \ismBass,
                    beat * p[\bassDuration] * if(slowed, { 1.45 }, { 1 }),
                    (rootMidi - 12 + if((b % 8) >= 5, { 7 }, { 0 })).midicps,
                    0.085 + (0.035 * x[5]), 0, 1 + (1.2 * x[5]), p[\bassTone], 0,
                    localBend + if((z[6] == 1) and: { (step % 8) == 0 }, { -0.8 }, { 0 }));
            });
        };

        // Repeat the contour only when a scene lasts beyond one eight-beat
        // cell. Mutation touches articulation/register before replacing notes.
        ((sceneBeats / 8).ceil.asInteger).do { |cycle|
            shape.do { |interval, i|
                var b, time, pitch, dur, pan, reversed, localBend, emitNote, inHole;
                b = (cycle * 8) + melodyTimes[i]; time = at + (b * beat);
                inHole = sparseHole and: { b >= holeStart } and: { b < holeEnd };
                emitNote = (b < sceneBeats) and: { inHole.not } and: {
                    (i == 0) or: { coin.value(p[\motifChance] * melodyWeight) }
                };
                if(emitNote, {
                    pitch = rootMidi + 24 + interval;
                    if((sceneIndex == 6) and: { lastMotif == motifIndex }, { pitch = pitch - 12 });
                    if(coin.value(p[\motifMutation] * 0.35), { pitch = pitch + pick.value([-12, 12]) });
                    if((z[6] == 1) and: { (i % 3) == 2 }, {
                        pitch = pitch + if(coin.value(p[\tension]), { -1 }, { 1 });
                    });
                    dur = melodyDurations[i] * beat * p[\noteGate];
                    reversed = if((z[2] == 1) and: { (i == 0) or: { i == 6 } }, { 1 }, { 0 });
                    localBend = (rand.value - 0.5) * p[\wowCents] / 100;
                    // ÆZRI still affects bell articulation when phrases are off.
                    localBend = localBend + ((rand.value - 0.5) * p[\voiceBend] * 0.24);
                    if(tape and: { b >= tapeStart }, {
                        localBend = localBend - 7; dur = dur * 1.45;
                        time = time + ((b - tapeStart) * beat * 0.25);
                    });
                    pan = (rand.value - 0.5) * 2 * p[\panSpread];
                    add.value(time, \ismBell, dur, pitch.midicps,
                        p[\melodyAmp] * if(i == 0, { 1.15 }, { 0.88 }), pan,
                        1 + (0.2 * x[0]), p[\bellTone], reversed, localBend);
                    if((i == 2) and: { coin.value(p[\answerChance]) }, {
                        add.value(time + (beat * p[\answerOffset]), \ismBell, dur * 0.80,
                            (pitch + 12).midicps, p[\melodyAmp] * 0.38, pan.neg,
                            1, (p[\bellTone] + 0.15).clip(0, 1), reversed, localBend);
                    });
                    if((z[4] == 1) and: { (i == 3) or: { (sceneIndex == 4) and: { i == 0 } } }, {
                        p[\rollCount].do { |roll|
                            add.value(time + ((roll + 1) * beat / 12), \ismBell,
                                beat / 16, (pitch + if(roll.odd, { 7 }, { 0 })).midicps,
                                p[\melodyAmp] * (0.48 / (1 + (roll * 0.25))), pan,
                                1.3, p[\bellTone], reversed, localBend);
                        };
                    });
                });
            };
        };
        lastMotif = motifIndex;

        // Harmonic haze uses related root/fifth/minor-third voicings, not
        // unrestricted note clouds. YŌR changes lifetime, density and voicing.
        if((sceneIndex == 0) or: { sceneIndex == 3 } or: { sceneIndex == 5 } or: {
            coin.value(0.30 + (0.35 * x[3]))
        }, {
            p[\padVoices].do { |i|
                var degree, freq, reversed;
                degree = [0, 7, if(z[6] == 1, { 2 }, { 3 })][i];
                freq = (rootMidi + 12 + degree).midicps * (1 + (p[\resonanceOffset] * i));
                reversed = if((z[2] == 1) and: { sceneIndex == 5 }, { 1 }, { 0 });
                add.value(at + (i * beat * 0.18), \ismPad,
                    p[\padDuration].min(sceneDuration + beat), freq,
                    p[\padAmp] / (1 + (0.25 * i)),
                    [-0.65, 0.65, 0][i] * p[\panSpread], 1, p[\padTone], reversed,
                    if(tape, { -3 }, { 0 }));
            };
        });
        if(z[1] == 1, {
            // Complete foreground sentences replace the old per-scene ghost
            // loop. Phrases remain forwards and are never ratcheted/reversed;
            // their rate, spectral decay and echo are the expressive controls.
            while { vocalNext < sceneEnd } {
                var phraseIndex, nextGap, eventSeed;
                if(singleScene or: { (vocalNext + phraseDuration) <= length }, {
                    phraseIndex = pick.value((0..7).reject { |index| index == phraseLastIndex });
                    nextGap = (p[\vocalGap] * (0.94 + (0.12 * rand.value))).clip(8, 52);
                    eventSeed = (rand.value * 2147483645).floor.asInteger + 1;
                    events.add((time: vocalNext.asFloat, voice: \ismPhrase,
                        dur: phraseDuration, phraseIndex: phraseIndex,
                        nextVocalGap: nextGap, seed: eventSeed, order: eventIndex,
                        args: [\freq, 300, \amp, p[\vocalAmp],
                            \pan, (rand.value - 0.5) * p[\panSpread],
                            \drive, 1 + (0.12 * x[1]), \tone, p[\sourceTone],
                            \reverse, 0, \bend, 0, \cutoff, p[\vocalCutoff],
                            \filterCoeff, p[\vocalFilterCoeff],
                            \rate, p[\vocalRate], \echoMix, p[\vocalDelayMix]]));
                    eventIndex = eventIndex + 1; phraseLastIndex = phraseIndex;
                    vocalNext = vocalNext + nextGap;
                }, {
                    // An offline request ends with room for the full sentence.
                    // Keep it due for a continuation, rather than clipping it.
                    vocalNext = length;
                });
            };
        });
        if(z[3] == 1, {
            // Cheap two-note phone notification, distinct from the motif.
            add.value(at + (beat * 0.20), \ismBell, beat * 0.22,
                (rootMidi + 43).midicps, 0.050, 0.38, 1, 0.08, 0, 0);
            add.value(at + (beat * 0.52), \ismBell, beat * 0.32,
                (rootMidi + 38).midicps, 0.043, -0.38, 1, 0.08, 0, 0);
        });
        if((sceneIndex == 4) or: { coin.value(p[\noiseChance]) }, {
            add.value(at + (sceneDuration * 0.73), \ismNoise,
                beat * (0.25 + x[7]), 800 + (2600 * (1 - x[7])),
                p[\noiseAmp], (rand.value - 0.5) * 1.6, 1,
                p[\sourceTone], if(z[2] == 1, { 1 }, { 0 }), if(tape, { -8 }, { 0 }));
        });
        if((z[4] == 1) or: { coin.value(p[\fillChance] * sceneEnergy) }, {
            var rollStart;
            rollStart = at + (sceneDuration - (beat * 0.55)).max(0);
            p[\rollCount].do { |roll|
                add.value(rollStart + (roll * beat / 12), \ismSnare, beat / 10,
                    180 + (roll * 32), 0.056 / (1 + (0.12 * roll)),
                    (roll - 1.5) * 0.16, 1 + x[1], p[\sourceTone],
                    if((z[2] == 1) and: { roll == 0 }, { 1 }, { 0 }), 0);
            };
        });
        if((z[7] == 1) and: { sceneIndex != 2 }, {
            // A tail-focused final response excites the bounded echo loop.
            add.value(at + (sceneDuration * 0.86), \ismBell, beat * 0.36,
                (rootMidi + 36 + shape[2]).midicps, 0.042, 0.65,
                1, 0.2, if(z[2] == 1, { 1 }, { 0 }), 0);
        });
        if((z[9] == 1) and: { sparseHole }, {
            // Rupture has a recognizable recovery, not permanent thinning.
            add.value(at + (holeEnd * beat), \ismKick, beat * 0.28,
                p[\kickFreq] * 0.84, p[\kickAccent] * 0.80, 0,
                p[\kickDrive], 0.18, 0, -3);
        });
        previous = sceneIndex; recent.add(sceneIndex);
        if(recent.size > 3, { recent.removeAt(0) });
        at = sceneEnd; sceneNumber = sceneNumber + 1; composedScenes = composedScenes + 1;
    };

    // Sliding one-second cap and exact lifetime cap enforce the contract even
    // at all-on extremes. Deterministic order preserves simultaneous accents.
    ordered = events.asArray.sort { |a, b|
        if(a[\time] == b[\time], { a[\order] < b[\order] }, { a[\time] < b[\time] })
    };
    bounded = List.new; active = List.new; recentTimes = List.new;
    ordered.do { |event|
        active = active.select { |endTime| endTime > event[\time] };
        recentTimes = recentTimes.select { |time| time > (event[\time] - 1.0) };
        accepted = (active.size < 48) and: { recentTimes.size < 96 };
        if(accepted and: { singleScene.not or: { event[\time] < at } }, {
            // select returns Array; assign add's result when its storage grows.
            active = active.add(event[\time] + event[\dur]);
            recentTimes = recentTimes.add(event[\time]);
            event.removeAt(\order); bounded.add(event);
        });
    };
    (events: bounded.asArray, scenes: scenes.asArray, bpm: p[\bpm],
        duration: if(singleScene, { at }, { length }),
        vocalInitialRemaining: vocalInitialRemaining,
        memory: (rng: rng, rememberedMotif: rememberedMotif, rememberedGroove: rememberedGroove,
            motifIndex: motifIndex, grooveIndex: grooveIndex, rootMidi: rootMidi,
            previous: previous, recent: recent.asArray.copy, sceneNumber: sceneNumber,
            lastMotif: lastMotif, vocalRemaining: (vocalNext - at).max(0),
            phraseLastIndex: phraseLastIndex, vocalWasEnabled: z[1]))
};
)
