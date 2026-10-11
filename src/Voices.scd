/*
ILLEGAL SUPERCOLLIDER YABUJINSLOP MACHINE — stock-UGen voices.
Every event has one finite amplitude envelope whose doneAction frees the synth.
Noise/random phase is seeded inside each synth; the optional FX seed makes its
wear/echo residue repeatable too. No Quarks or extension UGens are required.
*/
(
~ism[\defineSynths] = {
    var defs;
    defs = [
        SynthDef(\ismKick, { |out=0, freq=55, amp=0.24, pan=0, dur=0.32,
            seed=1, drive=1.8, tone=0.5, reverse=0, bend=0|
            var d, f, attack, env, pitch, body, click, sig, pressure;
            RandSeed.ir(1, seed);
            d = dur.clip(0.025, 16);
            f = freq.clip(25, 240) * Line.kr(bend.clip(-24, 24), 0, d).midiratio;
            attack = Select.kr(reverse.clip(0, 1).round, [0.002, d * 0.76]);
            env = EnvGen.kr(Env.perc(attack, (d - attack).max(0.002), 1, -4), doneAction: 2);
            pressure = tone.clip(0, 1);
            pitch = EnvGen.kr(Env([3.8 + (pressure * 3.5), 1.35, 1],
                [(d * 0.075).max(0.002), (d * 0.33).max(0.005)], [-7, -4]));
            body = SinOsc.ar(f * pitch, 0, 0.82)
                + (SinOsc.ar(f * 2 * pitch, 0, 0.11) * pressure)
                + (LFTri.ar(f * 0.5, 0, 0.1) * (1 - (pressure * 0.5)));
            click = HPF.ar(WhiteNoise.ar(0.28), 2300)
                * EnvGen.kr(Env.perc(0.001, 0.016 + (pressure * 0.015)));
            sig = ((body + click) * drive.clip(1, 4)).tanh
                / drive.clip(1, 4).sqrt;
            // The pitch-bearing tail stays centered even when hard accents pan.
            Out.ar(out, Pan2.ar(LeakDC.ar(sig) * env * amp.clip(0, 1), pan.clip(-1, 1)));
        }),

        SynthDef(\ismSnare, { |out=0, freq=175, amp=0.15, pan=0, dur=0.22,
            seed=1, drive=1.4, tone=0.5, reverse=0, bend=0|
            var d, f, attack, env, crack, body, clap, sig;
            RandSeed.ir(1, seed);
            d = dur.clip(0.025, 16);
            f = freq.clip(90, 650) * Line.kr(bend.clip(-24, 24), 0, d).midiratio;
            attack = Select.kr(reverse.clip(0, 1).round, [0.0015, d * 0.77]);
            env = EnvGen.kr(Env.perc(attack, (d - attack).max(0.002), 1, -3.5), doneAction: 2);
            crack = HPF.ar(WhiteNoise.ar(0.7), 1050 + (tone.clip(0, 1) * 1450));
            crack = LPF.ar(crack, 4500 + (tone.clip(0, 1) * 9500));
            body = SinOsc.ar(f * EnvGen.kr(Env([1.45, 1], [0.035], -5)), 0, 0.28)
                + SinOsc.ar(f * 1.7, 0, 0.1);
            clap = BPF.ar(PinkNoise.ar(0.65), 1500 + (tone * 2000), 0.6)
                * (1 + (SinOsc.kr(110, 0, 0.3) * EnvGen.kr(Env.perc(0.001, 0.05))));
            sig = ((crack + body + clap) * drive.clip(1, 4)).tanh
                / drive.clip(1, 4).sqrt;
            Out.ar(out, Pan2.ar(LeakDC.ar(sig) * env * amp.clip(0, 1), pan.clip(-1, 1)));
        }),

        SynthDef(\ismHat, { |out=0, freq=8000, amp=0.08, pan=0, dur=0.09,
            seed=1, drive=1.2, tone=0.5, reverse=0, bend=0|
            var d, f, attack, env, metal, dust, sig;
            RandSeed.ir(1, seed);
            d = dur.clip(0.018, 16);
            f = freq.clip(2400, 14000) * Line.kr(bend.clip(-12, 12), 0, d).midiratio;
            attack = Select.kr(reverse.clip(0, 1).round, [0.001, d * 0.78]);
            env = EnvGen.kr(Env.perc(attack, (d - attack).max(0.002), 1, -6), doneAction: 2);
            metal = Mix(LFPulse.ar(f * [0.071, 0.099, 0.137, 0.181],
                Rand(0.0, 1.0), [0.23, 0.37, 0.41, 0.17], 0.12));
            dust = WhiteNoise.ar(0.65);
            sig = HPF.ar((metal * (0.6 + tone)) + dust, (f * 0.4).clip(1200, 6000));
            sig = BPF.ar(sig, f.clip(2500, 14000), 0.65) + (sig * 0.3);
            sig = (sig * drive.clip(1, 4)).tanh / drive.clip(1, 4).sqrt;
            Out.ar(out, Pan2.ar(sig * env * amp.clip(0, 1), pan.clip(-1, 1)));
        }),

        SynthDef(\ismBass, { |out=0, freq=65, amp=0.16, pan=0, dur=0.32,
            seed=1, drive=1.6, tone=0.45, reverse=0, bend=0|
            var d, f, attack, env, sig, cutoff;
            RandSeed.ir(1, seed);
            d = dur.clip(0.025, 16);
            f = freq.clip(25, 900) * Line.kr(bend.clip(-24, 24), 0, d).midiratio;
            attack = Select.kr(reverse.clip(0, 1).round, [0.008, d * 0.74]);
            env = EnvGen.kr(Env.perc(attack, (d - attack).max(0.003), 1, -2.8), doneAction: 2);
            sig = SinOsc.ar(f, 0, 0.72)
                + VarSaw.ar(f * 0.5003, Rand(0.0, 1.0), 0.3, 0.18)
                + LFPulse.ar(f * 1.002, 0, 0.32, 0.13);
            cutoff = (250 + (tone.clip(0, 1) * 4700)) * (0.62 + (env * 0.6));
            sig = RLPF.ar(sig, cutoff.clip(120, 6500), 0.5);
            sig = (sig * drive.clip(1, 4)).tanh / drive.clip(1, 4).sqrt;
            Out.ar(out, Pan2.ar(LeakDC.ar(sig) * env * amp.clip(0, 1), pan.clip(-1, 1) * 0.55));
        }),

        SynthDef(\ismBell, { |out=0, freq=660, amp=0.12, pan=0, dur=1.2,
            seed=1, drive=1.1, tone=0.4, reverse=0, bend=0|
            var d, f, attack, env, bell, flute, breath, vibrato, sig;
            RandSeed.ir(1, seed);
            d = dur.clip(0.03, 20);
            vibrato = SinOsc.kr(4.6 + Rand(-0.6, 0.6), Rand(0.0, 6.28), 0.0025)
                + LFNoise2.kr(1.7, 0.0018);
            f = freq.clip(80, 6000) * (1 + vibrato)
                * Line.kr(bend.clip(-24, 24), 0, d).midiratio;
            attack = Select.kr(reverse.clip(0, 1).round, [0.006, d * 0.76]);
            env = EnvGen.kr(Env.perc(attack, (d - attack).max(0.005), 1, -3), doneAction: 2);
            bell = Mix(SinOsc.ar(f * [1, 2.009, 3.91, 5.41],
                [0, 0.3, 1.3, 0.7], [0.55, 0.21, 0.105, 0.04]));
            flute = SinOsc.ar(f + SinOsc.ar(f * 2.001, 0, f * 0.045), 0, 0.67)
                + SinOsc.ar(f * 2, 0, 0.075);
            breath = BPF.ar(WhiteNoise.ar(0.06), (f * 2.5).clip(800, 8000), 0.7);
            sig = XFade2.ar(bell, flute + breath, (tone.clip(0, 1) * 2) - 1);
            sig = LPF.ar(sig, (f * 8).clip(2500, 14000));
            sig = (sig * drive.clip(1, 4)).tanh / drive.clip(1, 4).sqrt;
            Out.ar(out, Pan2.ar(sig * env * amp.clip(0, 1), pan.clip(-1, 1)));
        }),

        SynthDef(\ismPad, { |out=0, freq=220, amp=0.08, pan=0, dur=4,
            seed=1, drive=1.1, tone=0.5, reverse=0, bend=0|
            var d, f, rise, env, sig, detune;
            RandSeed.ir(1, seed);
            d = dur.clip(0.08, 24);
            rise = Select.kr(reverse.clip(0, 1).round, [0.32, 0.76]);
            env = EnvGen.kr(Env([0, 0.9, 0.74, 0],
                [d * rise, d * 0.08, d * (0.92 - rise)], [3, 0, -3]), doneAction: 2);
            detune = LFNoise2.kr([0.31, 0.37, 0.23], 0.003)
                + [-0.006, 0, 0.005];
            f = freq.clip(45, 1800) * Line.kr(bend.clip(-24, 24), 0, d).midiratio;
            sig = Mix(VarSaw.ar(f * (1 + detune), [0, 0.17, 0.59],
                0.35 + (SinOsc.kr(0.12, 0, 0.15)), 0.18));
            sig = sig + SinOsc.ar(f * 0.5, 0, 0.11)
                + SinOsc.ar(f * 2.003, 0, tone.clip(0, 1) * 0.09);
            sig = LPF.ar(sig, 750 + (tone.clip(0, 1) * 5200));
            sig = (sig * drive.clip(1, 4)).tanh / drive.clip(1, 4).sqrt;
            sig = [sig, DelayC.ar(sig, 0.04, 0.011 + SinOsc.kr(0.18, 0, 0.003))];
            Out.ar(out, Balance2.ar(sig[0], sig[1], pan.clip(-1, 1)) * env * amp.clip(0, 1));
        }),

        SynthDef(\ismGhost, { |out=0, freq=330, amp=0.09, pan=0, dur=0.7,
            seed=1, drive=1.3, tone=0.5, reverse=0, bend=0|
            var d, f, attack, env, vowel, formants, voiced, whisper, syllable, sig;
            RandSeed.ir(1, seed);
            d = dur.clip(0.035, 16);
            attack = Select.kr(reverse.clip(0, 1).round, [0.025.min(d * 0.2), d * 0.75]);
            env = EnvGen.kr(Env.perc(attack, (d - attack).max(0.005), 1, -2), doneAction: 2);
            f = freq.clip(70, 1400) * (1 + LFNoise2.kr(7, 0.011))
                * Line.kr(bend.clip(-24, 24), 0, d).midiratio;
            vowel = (tone.clip(0, 1) + SinOsc.kr(1.2, Rand(0.0, 6.28), 0.17)).clip(0, 1);
            formants = [380 + (vowel * 470), 1400 + (vowel * 1450), 3100 - (vowel * 500)];
            voiced = Mix(BPF.ar(Pulse.ar(f * 0.5, 0.32, 0.55), formants,
                [0.14, 0.11, 0.12], [0.8, 0.6, 0.28]));
            voiced = voiced + Formant.ar(f * 0.5, formants[1], 260, 0.11);
            whisper = BPF.ar(WhiteNoise.ar(0.12), formants[2], 0.4);
            syllable = 0.55 + (LFPulse.kr(6 + (vowel * 12), Rand(0.0, 1.0), 0.58) * 0.45);
            sig = ((voiced + whisper) * syllable * drive.clip(1, 4)).tanh
                / drive.clip(1, 4).sqrt;
            Out.ar(out, Pan2.ar(HPF.ar(sig, 160) * env * amp.clip(0, 1), pan.clip(-1, 1)));
        }),

        SynthDef(\ismNoise, { |out=0, freq=1800, amp=0.055, pan=0, dur=0.22,
            seed=1, drive=1.2, tone=0.5, reverse=0, bend=0|
            var d, f, attack, env, air, sparks, hum, sig;
            RandSeed.ir(1, seed);
            d = dur.clip(0.02, 16);
            attack = Select.kr(reverse.clip(0, 1).round, [0.002, d * 0.78]);
            env = EnvGen.kr(Env.perc(attack, (d - attack).max(0.002), 1, -2.2), doneAction: 2);
            f = freq.clip(180, 14000) * Line.kr(bend.clip(-24, 24), 0, d).midiratio;
            air = BPF.ar(PinkNoise.ar(0.65), f, 0.15 + (tone.clip(0, 1) * 0.75));
            sparks = HPF.ar(Dust2.ar(18 + (tone * 170), 0.16), 1800);
            hum = SinOsc.ar([49.8, 100.1], 0, [0.04, 0.016]).sum;
            sig = ((air + sparks + hum) * drive.clip(1, 4)).tanh
                / drive.clip(1, 4).sqrt;
            Out.ar(out, Pan2.ar(sig * env * amp.clip(0, 1), pan.clip(-1, 1)));
        }),

        SynthDef(\ismSampleMono, { |out=0, freq=440, amp=0.15, pan=0, dur=0.4,
            seed=1, drive=1.2, tone=0.6, reverse=0, bend=0, buf=0, rate=1, start=0|
            var d, attack, env, direction, position, playbackRate, sig;
            RandSeed.ir(1, seed);
            d = dur.clip(0.025, 24);
            direction = Select.kr(reverse.clip(0, 1).round, [1, -1]);
            position = Select.kr(reverse.clip(0, 1).round,
                [start.clip(0, 0.9999), (1 - start).clip(0, 0.9999)]);
            playbackRate = rate.clip(-4, 4) * BufRateScale.kr(buf) * direction
                * Line.kr(bend.clip(-24, 24), 0, d).midiratio;
            attack = Select.kr(reverse.clip(0, 1).round, [0.003, d * 0.7]);
            env = EnvGen.kr(Env.perc(attack, (d - attack).max(0.003), 1, -1.8), doneAction: 2);
            sig = PlayBuf.ar(1, buf, playbackRate, 1,
                position * (BufFrames.kr(buf) - 1).max(0), 0);
            sig = LPF.ar(HPF.ar(sig, 35), 1000 + (tone.clip(0, 1) * 17000));
            sig = (sig * drive.clip(1, 4)).tanh / drive.clip(1, 4).sqrt;
            Out.ar(out, Pan2.ar(sig * env * amp.clip(0, 1), pan.clip(-1, 1)));
        }),

        SynthDef(\ismSampleStereo, { |out=0, freq=440, amp=0.15, pan=0, dur=0.4,
            seed=1, drive=1.2, tone=0.6, reverse=0, bend=0, buf=0, rate=1, start=0|
            var d, attack, env, direction, position, playbackRate, sig;
            RandSeed.ir(1, seed);
            d = dur.clip(0.025, 24);
            direction = Select.kr(reverse.clip(0, 1).round, [1, -1]);
            position = Select.kr(reverse.clip(0, 1).round,
                [start.clip(0, 0.9999), (1 - start).clip(0, 0.9999)]);
            playbackRate = rate.clip(-4, 4) * BufRateScale.kr(buf) * direction
                * Line.kr(bend.clip(-24, 24), 0, d).midiratio;
            attack = Select.kr(reverse.clip(0, 1).round, [0.003, d * 0.7]);
            env = EnvGen.kr(Env.perc(attack, (d - attack).max(0.003), 1, -1.8), doneAction: 2);
            sig = PlayBuf.ar(2, buf, playbackRate, 1,
                position * (BufFrames.kr(buf) - 1).max(0), 0);
            sig = LPF.ar(HPF.ar(sig, 35), 1000 + (tone.clip(0, 1) * 17000));
            sig = (sig * drive.clip(1, 4)).tanh / drive.clip(1, 4).sqrt;
            Out.ar(out, Balance2.ar(sig[0], sig[1], pan.clip(-1, 1)) * env * amp.clip(0, 1));
        }),

        SynthDef(\ismFX, { |in=0, out=0, bits=14, holdRate=32000, drive=1.2,
            wear=0.15, delayTime=0.23, delayMix=0.15, feedback=0.3,
            reverbMix=0.16, width=0.8, phone=0, seed=1|
            var sig, aged, hold, quantum, resolution, grit, wow, mechanical,
                p, loop, tap, fb, dt, wet, mid, side, w;
            RandSeed.ir(1, seed);
            sig = LeakDC.ar(HPF.ar(In.ar(in, 2), 28));
            w = Lag.kr(wear.clip(0, 1), 0.14);
            // DZER is digital resolution; SHOR is spectral/mechanical damage.
            hold = Latch.ar(sig, Impulse.ar(Lag.kr(holdRate.clip(1000,
                SampleRate.ir * 0.95), 0.08)));
            quantum = 2.pow(1 - Lag.kr(bits.clip(4, 16), 0.08));
            resolution = hold.round(quantum);
            grit = Lag.kr(drive.clip(1, 4), 0.06);
            sig = (resolution * grit).tanh / grit.sqrt;
            wow = SinOsc.kr([0.19, 0.23], [0, 1.8], 0.0014)
                + LFNoise2.kr([1.1, 1.3], 0.00035);
            aged = DelayC.ar(sig, 0.04, 0.004 + (wow * w));
            aged = LPF.ar(aged, 17000 * (0.095.pow(w)));
            mechanical = HPF.ar(PinkNoise.ar(0.003) + Dust2.ar(7, 0.007), 550)
                * w * Amplitude.kr(sig.sum, 0.005, 0.25).clip(0, 1);
            sig = aged + mechanical;
            p = Lag.kr(phone.clip(0, 1), 0.09);
            sig = XFade2.ar(sig, LPF.ar(HPF.ar(sig, 360), 3400), (p * 2) - 1);
            // Filtered cross-feedback never exceeds .8 and sheds bass every lap.
            loop = LocalIn.ar(2);
            fb = Lag.kr(feedback.clip(0, 0.8), 0.12);
            dt = Lag.kr(delayTime.clip(0.02, 1.5), 0.15);
            tap = DelayC.ar(sig + (loop.reverse * fb), 1.6,
                (dt + [0, 0.013]).clip(0.02, 1.55));
            tap = LPF.ar(HPF.ar(LeakDC.ar(tap), 170), 6200 - (w * 4100));
            tap = (tap * 1.15).tanh / 1.15;
            LocalOut.ar(tap);
            wet = Lag.kr(delayMix.clip(0, 0.5), 0.08);
            sig = (sig * (1 - (wet * 0.24))) + (tap * wet);
            sig = FreeVerb2.ar(sig[0], sig[1], Lag.kr(reverbMix.clip(0, 0.45), 0.15),
                0.81, 0.27 + (w * 0.5));
            mid = (sig[0] + sig[1]) * 0.5;
            side = (sig[0] - sig[1]) * 0.5 * Lag.kr(width.clip(0, 1), 0.08);
            Out.ar(out, LeakDC.ar([mid + side, mid - side]));
        }),

        SynthDef(\ismMaster, { |in=0, out=0, gain=0.72, gate=1, mute=1|
            var sig, fade;
            fade = EnvGen.kr(Env.asr(0.025, 1, 0.14, -4), gate, doneAction: 2);
            sig = LeakDC.ar(In.ar(in, 2)) * 6 * Lag.kr(gain.clip(0, 1.5), 0.04);
            // Fade after the look-ahead limiter so panic/stop closes its tail too.
            Out.ar(out, Limiter.ar(sig, 0.84, 0.01) * fade * Lag.kr(mute.clip(0, 1), 0.005));
        })
    ];
    ~ism[\defs] = defs;
    defs.do({ |def| def.add });
    defs
};
)
