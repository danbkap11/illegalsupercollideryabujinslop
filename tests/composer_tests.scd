// Run: QT_QPA_PLATFORM=offscreen sclang -D tests/composer_tests.scd
// No server or GUI is used. A failed assertion or unexpected exception exits nonzero.
(
var root, checks = 0, failures = 0, check, finite, bounds, validateMap, validateTrace;
var baseSliders, baseSwitches, baseMap, first, second, longTrace, maps, stress;
var sliderMetrics = List.new, switchMetrics = List.new, voices;
var continuation, repeatedContinuation, memorySnapshot;

root = thisProcess.nowExecutingPath.standardizePath.dirname.dirname;
~ism = (root: root, sliders: Array.fill(10, 0.5), switches: Array.fill(10, 0));
check = { |condition, message|
    checks = checks + 1;
    if(condition.not, {
        failures = failures + 1;
        if(failures <= 25, { ("FAIL: " ++ message).postln });
    });
};
finite = { |value| value.isNumber and: { value.abs < 1e12 } };
bounds = [
    [\bpm, 110, 180], [\bits, 5, 16], [\holdRate, 2500, 32000],
    [\drive, 1, 4], [\wear, 0, 1], [\delayTime, 0.02, 1.5],
    [\delayMix, 0, 0.5], [\feedback, 0, 0.8], [\reverbMix, 0, 0.45],
    [\width, 0, 1], [\phone, 0, 1]
];
voices = [\ismKick, \ismSnare, \ismHat, \ismBass, \ismBell, \ismPad,
    \ismGhost, \ismPhrase, \ismNoise, \ismSampleMono, \ismSampleStereo];
baseSliders = [0.58, 0.43, 0.54, 0.64, 0.45, 0.58, 0.54, 0.35, 0.28, 0.5];
baseSwitches = [0, 1, 0, 0, 0, 0, 0, 0, 1, 0];
validateMap = { |params, context|
    check.value(params.isKindOf(Event), context ++ " returns an Event");
    bounds.do { |spec|
        var value = params[spec[0]];
        check.value(finite.value(value) and: {
            (value >= (spec[1] - 1e-7)) and: { value <= (spec[2] + 1e-7) }
        }, context ++ " bounded " ++ spec[0]);
    };
    params.keysValuesDo { |key, value|
        if(value.isNumber, { check.value(finite.value(value), context ++ " finite " ++ key) });
    };
};
validateTrace = { |trace, seconds, context|
    var events = trace[\events], scenes = trace[\scenes], previous = -1.0;
    var markers = List.new, active = 0, peakVoices = 0, left = 0, peakDensity = 0, peakGap = 0.0;
    check.value(events.isArray and: { scenes.isArray }, context ++ " event/scene arrays");
    check.value(events.size > 4, context ++ " contains meaningful events");
    check.value(finite.value(trace[\bpm]) and: { trace[\bpm].inclusivelyBetween(110, 180) }, context ++ " BPM");
    check.value(finite.value(trace[\duration]) and: { (trace[\duration] - seconds).abs < 0.1 }, context ++ " requested duration");
    events.do { |event, index|
        var time = event[\time], dur = event[\dur], args = event[\args];
        check.value(finite.value(time) and: { time >= 0 and: { time < seconds } }, context ++ " onset " ++ index);
        check.value(time >= previous, context ++ " sorted onset " ++ index);
        check.value(finite.value(dur) and: { dur > 0 and: { dur <= 16 } }, context ++ " finite lifetime " ++ index);
        check.value(voices.includes(event[\voice]), context ++ " supported voice " ++ index);
        check.value(event[\seed].isInteger, context ++ " server noise seed " ++ index);
        if(event[\sampleIndex].notNil, {
            check.value(event[\sampleIndex].isInteger and: {
                event[\sampleIndex] >= 0
            }, context ++ " valid sample index " ++ index);
        });
        check.value(args.isArray and: { args.size.even }, context ++ " OSC argument pairs " ++ index);
        args.pairsDo { |key, value|
            check.value(key.isKindOf(Symbol) and: { finite.value(value) }, context ++ " finite OSC argument " ++ key);
            if(key == \amp, { check.value(value.inclusivelyBetween(0, 2), context ++ " amplitude range") });
            if(key == \pan, { check.value(value.inclusivelyBetween(-1, 1), context ++ " pan range") });
            if(key == \freq, { check.value(value.inclusivelyBetween(15, 20000), context ++ " frequency range") });
        };
        if(index > 0, { peakGap = peakGap.max(time - previous) });
        previous = time;
        markers.add([time, 1]);
        markers.add([time + dur, -1]);
        while({ (left < index) and: { events[left][\time] <= (time - 1) } }, { left = left + 1 });
        peakDensity = peakDensity.max(index - left + 1);
    };
    markers = markers.asArray.sort { |a, b| (a[0] < b[0]) or: { (a[0] == b[0]) and: { a[1] < b[1] } } };
    markers.do { |marker| active = active + marker[1]; peakVoices = peakVoices.max(active) };
    check.value(peakDensity <= 96, context ++ " <=96 onsets per sliding second (" ++ peakDensity ++ ")");
    check.value(peakVoices <= 48, context ++ " <=48 overlapping lifetimes (" ++ peakVoices ++ ")");
    check.value(peakGap <= 16, context ++ " no pathological accidental silence (" ++ peakGap ++ ")");
    previous = -1;
    scenes.do { |scene|
        check.value(finite.value(scene[\time]) and: { scene[\time] >= previous and: { scene[\time] < seconds } }, context ++ " scene timing");
        check.value([\vacantRoom, \falseClub, \rush, \phoneCorridor, \fracture, \suspension, \return].includes(scene[\name])
            and: { scene[\beats].isInteger and: { scene[\beats] > 0 } }, context ++ " scene identity/length");
        previous = scene[\time];
    };
    ("TRACE " ++ context ++ ": events=" ++ events.size ++ " scenes=" ++ scenes.size
        ++ " peakVoices=" ++ peakVoices ++ " peakOnsetsPerSecond=" ++ peakDensity ++ " maxGap=" ++ peakGap.round(0.01)).postln;
};

try {
    (root +/+ "src/Composer.scd").load;
    check.value(~ism[\map].isKindOf(Function), "mapper exists");
    check.value(~ism[\compose].isKindOf(Function), "composer exists");
    // Exhaustive switch combinations are cheap at mapper level; exercise all extrema too.
    1024.do { |bits|
        var switches = Array.fill(10, { |index| (bits >> index).bitAnd(1) });
        [0.0, 0.5, 1.0].do { |value|
            validateMap.value(~ism[\map].value(Array.fill(10, value), switches), "map " ++ bits ++ "/" ++ value);
        };
    };
    baseMap = ~ism[\map].value(baseSliders, baseSwitches);
    first = ~ism[\compose].value(7331, baseSliders, baseSwitches, 45);
    second = ~ism[\compose].value(7331, baseSliders, baseSwitches, 45);
    check.value(first.asCompileString == second.asCompileString, "identical seed/control trace is reproducible");
    check.value(first.asCompileString != ~ism[\compose].value(7332, baseSliders, baseSwitches, 45).asCompileString,
        "different seeds produce different music");
    validateTrace.value(first, 45, "balanced");
    memorySnapshot = first[\memory].asCompileString;
    continuation = ~ism[\compose].value(7331, baseSliders, baseSwitches, 4, first[\memory]);
    repeatedContinuation = ~ism[\compose].value(7331, baseSliders, baseSwitches, 4, first[\memory]);
    check.value(continuation.asCompileString == repeatedContinuation.asCompileString,
        "saved musical memory resumes deterministically");
    check.value(first[\memory].asCompileString == memorySnapshot, "continuation preserves caller's memory snapshot");
    check.value(continuation[\memory][\sceneNumber] > first[\memory][\sceneNumber],
        "realtime-sized batch advances scene history");
    check.value(continuation[\memory][\rootMidi] == first[\memory][\rootMidi],
        "realtime-sized batch retains tonal identity");
    check.value(continuation[\memory][\rng] != first[\memory][\rng], "musical random state advances across batches");
    check.value(continuation[\memory][\recent].size <= 3, "scene memory stays bounded");
    validateTrace.value(continuation, 4, "realtime continuation");
    10.do { |index|
        var low = baseSliders.copy, high = baseSliders.copy, lowMap, highMap, changed, lowTrace, highTrace;
        low[index] = 0; high[index] = 1;
        lowMap = ~ism[\map].value(low, baseSwitches);
        highMap = ~ism[\map].value(high, baseSwitches);
        changed = lowMap.keys.select { |key| lowMap[key].isNumber and: { lowMap[key] != highMap[key] } };
        check.value(changed.size >= 3, "slider " ++ index ++ " has at least three meaningful destinations");
        lowTrace = ~ism[\compose].value(7331, low, baseSwitches, 45);
        highTrace = ~ism[\compose].value(7331, high, baseSwitches, 45);
        check.value((lowTrace.asCompileString != highTrace.asCompileString) or: {
            changed.any { |key| bounds.any { |spec| spec[0] == key } }
        }, "slider " ++ index ++ " affects composition or audible DSP");
        sliderMetrics.add((index: index, destinations: changed.asArray.sort));
        validateTrace.value(lowTrace, 45, "slider " ++ index ++ " low");
        validateTrace.value(highTrace, 45, "slider " ++ index ++ " high");
    };
    10.do { |index|
        var off = baseSwitches.copy, on = baseSwitches.copy, offMap, onMap, changed, offTrace, onTrace;
        off[index] = 0; on[index] = 1;
        offMap = ~ism[\map].value(baseSliders, off);
        onMap = ~ism[\map].value(baseSliders, on);
        changed = offMap.keys.select { |key| offMap[key].isNumber and: { offMap[key] != onMap[key] } };
        offTrace = ~ism[\compose].value(1337, baseSliders, off, 60);
        onTrace = ~ism[\compose].value(1337, baseSliders, on, 60);
        check.value((changed.size >= 2) or: { offTrace.asCompileString != onTrace.asCompileString },
            "switch " ++ index ++ " changes behavior or multiple DSP destinations");
        switchMetrics.add((index: index, destinations: changed.asArray.sort,
            traceChanged: offTrace.asCompileString != onTrace.asCompileString));
        validateTrace.value(onTrace, 60, "switch " ++ index ++ " on");
    };
    [[Array.fill(10, 0.0), Array.fill(10, 0)], [Array.fill(10, 1.0), Array.fill(10, 1)],
        [Array.fill(10, 0.5), Array.fill(10, 0)], [Array.fill(10, 0.5), Array.fill(10, 1)]].do { |patch, index|
        [101, 202, 303].do { |seed|
            stress = ~ism[\compose].value(seed, patch[0], patch[1], 90);
            validateTrace.value(stress, 90, "stress " ++ index ++ " seed " ++ seed);
        };
    };
    longTrace = ~ism[\compose].value(7331, baseSliders, baseSwitches, 600);
    validateTrace.value(longTrace, 600, "ten minutes");
    check.value(longTrace[\scenes].collect { |scene| scene[\name] }.asSet.size >= 5,
        "long trace visits at least five scene families");
    check.value(longTrace[\scenes].collect { |scene| scene[\beats] }.asSet.size >= 4,
        "long trace has varied phrase lengths");
    check.value(longTrace[\events].collect { |event| event[\voice] }.asSet.size >= 6,
        "long trace uses at least six sound families");
    check.value(baseSliders == [0.58, 0.43, 0.54, 0.64, 0.45, 0.58, 0.54, 0.35, 0.28, 0.5],
        "composer/mapper preserve caller slider array");
    check.value(baseSwitches == [0, 1, 0, 0, 0, 0, 0, 0, 1, 0],
        "composer/mapper preserve caller switch array");
    "SLIDER COVERAGE".postln; sliderMetrics.do(_.postln);
    "SWITCH COVERAGE".postln; switchMetrics.do(_.postln);
} { |error|
    failures = failures + 1;
    error.reportError;
};
("COMPOSER TESTS: " ++ checks ++ " assertions, " ++ failures ++ " failures").postln;
if(failures == 0, { 0.exit }, { 1.exit });
)
