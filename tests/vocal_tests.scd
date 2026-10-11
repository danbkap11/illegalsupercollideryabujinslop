// QT_QPA_PLATFORM=offscreen timeout 120 sclang -D tests/vocal_tests.scd
// No audio server: verify sparse phrase scheduling, continuity and real buffer metadata.
(
var root = thisProcess.nowExecutingPath.standardizePath.dirname.dirname;
var checks = 0, failures = 0, check, argumentValue, phrases, validatePhrases;
var sliders = [0.58, 0.43, 0.54, 0.64, 0.45, 0.58, 0.54, 0.35, 0.28, 0.5];
var enabled = [0, 1, 0, 0, 0, 0, 0, 0, 1, 0], disabled;
var low, high, lowCount = 0, highCount = 0, trace, prepared;
var memory, snapshot, elapsed, livePhrases, batch, beforeMap, afterMap;

~ism = (root: root, sliders: sliders.copy, switches: enabled.copy, samples: []);
check = { |condition, message|
    checks = checks + 1;
    if(condition.not, { failures = failures + 1; ("FAIL: " ++ message).postln });
};
argumentValue = { |event, key|
    var index = event[\args].indexOfEqual(key);
    if(index.notNil, { event[\args][index + 1] }, { nil })
};
phrases = { |composition| composition[\events].select { |event| event[\voice] == \ismPhrase } };
validatePhrases = { |events, context|
    var lastTime = -100, lastIndex = -1, lastDuration = 0;
    events.do { |event, index|
        check.value(event[\phraseIndex].isInteger and: {
            event[\phraseIndex].inclusivelyBetween(0, 7)
        }, context ++ " valid phrase identity " ++ index);
        check.value(event[\phraseIndex] != lastIndex, context ++ " avoids immediate transcript repeat " ++ index);
        check.value((event[\time] - lastTime) >= 7.99, context ++ " at least eight seconds between phrases " ++ index);
        check.value((event[\time] - lastTime) >= lastDuration, context ++ " complete phrases cannot overlap " ++ index);
        check.value(argumentValue.value(event, \reverse) == 0, context ++ " words play forwards " ++ index);
        check.value(argumentValue.value(event, \rate).inclusivelyBetween(0.85, 1.08), context ++ " bounded speech rate " ++ index);
        check.value(argumentValue.value(event, \cutoff).inclusivelyBetween(1100, 9000), context ++ " bounded vocal cutoff " ++ index);
        check.value(argumentValue.value(event, \filterCoeff).inclusivelyBetween(0, 1), context ++ " bounded filter coefficient " ++ index);
        lastTime = event[\time]; lastIndex = event[\phraseIndex]; lastDuration = event[\dur];
    };
};

try {
    ["Composer", "Samples"].do { |name| (root +/+ "src" +/+ (name ++ ".scd")).load };
    ~ism[\scanSamples].value;
    check.value(~ism[\phraseIndices].size == 8, "eight phrase recordings are mapped into the unified sample bank");
    ~ism[\phraseIndices].do { |index|
        var sample = ~ism[\samples][index], sound = SoundFile.new;
        check.value(sample[\role] == \phrase, "phrase index cannot resolve to percussion or texture");
        check.value(sound.openRead(sample[\path]), "phrase recording opens " ++ sample[\name]);
        check.value(sound.numChannels == 1, "phrase source is mono " ++ sample[\name]);
        check.value((sound.duration - sample[\duration]).abs < 0.001,
            "recorded phrase duration matches metadata " ++ sample[\name]);
        check.value(sound.duration.inclusivelyBetween(1, 5), "phrase contains a bounded full utterance " ++ sample[\name]);
        sound.close;
    };
    disabled = enabled.copy; disabled[1] = 0;
    trace = ~ism[\compose].value(7331, sliders, disabled, 180);
    check.value(phrases.value(trace).isEmpty, "T02 off suppresses all spoken phrase events");
    check.value(trace[\events].any { |event| event[\voice] == \ismGhost }.not, "T02 off leaves no legacy background vocal loop");
    trace = ~ism[\compose].value(7331, sliders, enabled, 180);
    check.value(phrases.value(trace).size >= 3, "T02 on produces occasional full spoken phrases");
    check.value(trace[\events].any { |event| event[\voice] == \ismGhost }.not, "speech replaces continuous ghost formants");
    validatePhrases.value(phrases.value(trace), "offline");
    prepared = ~ism[\prepareEvents].value(trace, sliders, enabled);
    prepared[\events].do { |event|
        if(event[\sampleIndex].notNil and: { event[\voice] != \ismPhrase }, {
            check.value(~ism[\samples][event[\sampleIndex]][\role] != \phrase,
                "speech recordings cannot leak into short background texture substitutions");
        });
    };
    phrases.value(prepared).do { |event|
        var sample = ~ism[\samples][event[\sampleIndex]], rate = argumentValue.value(event, \rate);
        var expected = (sample[\duration] / rate) + 0.35;
        check.value(sample[\role] == \phrase, "prepared phrase uses a speech recording");
        check.value((event[\dur] - expected).abs < 0.002, "phrase lifetime follows complete buffer/rate plus bounded tail");
        check.value((event[\time] + event[\dur]) <= 180, "offline export reserves space for the final complete phrase");
    };
    low = sliders.copy; high = sliders.copy; low[6] = 0; high[6] = 1;
    beforeMap = ~ism[\map].value(low, enabled); afterMap = ~ism[\map].value(high, enabled);
    check.value(beforeMap[\vocalGap] > afterMap[\vocalGap], "S07 controls time between utterances");
    check.value(beforeMap[\vocalFilterCoeff] < afterMap[\vocalFilterCoeff], "S07 also changes the vocal cutoff algorithm coefficient");
    8.do { |index|
        var seed = 302 + (index * 7919), lowTrace, highTrace;
        lowTrace = ~ism[\compose].value(seed, low, enabled, 240);
        highTrace = ~ism[\compose].value(seed, high, enabled, 240);
        lowCount = lowCount + phrases.value(lowTrace).size;
        highCount = highCount + phrases.value(highTrace).size;
        validatePhrases.value(phrases.value(highTrace), "high frequency seed " ++ seed);
    };
    check.value(highCount > (lowCount * 2), "S07 high increases phrase frequency across eight independent seeds");
    trace = ~ism[\compose].value(7331, high, enabled, 90, nil, false, 12);
    check.value((phrases.value(trace).first[\time] - 12).abs < 1e-6,
        "runtime wall-clock floor projects into the first scheduled phrase instead of dropping it");
    snapshot = trace[\memory].asCompileString;
    batch = ~ism[\compose].value(7331, high, enabled, 90, trace[\memory], false, 12);
    check.value(phrases.value(batch).first[\time] >= 12,
        "runtime cooldown floor also applies when continuing existing scene memory");
    check.value(trace[\memory].asCompileString == snapshot, "runtime floor preserves caller scene memory");

    // Realtime consumes one scene per batch. Cooldown and transcript history must
    // survive those short batches, including scene changes with no speech event.
    memory = nil; elapsed = 0; livePhrases = List.new;
    while { elapsed < 180 } {
        snapshot = if(memory.notNil, { memory.asCompileString }, { nil });
        batch = ~ism[\compose].value(7331, high, enabled, 20, memory, true);
        if(snapshot.notNil, { check.value(memory.asCompileString == snapshot, "batch preserves caller memory snapshot") });
        prepared = ~ism[\prepareEvents].value(batch, high, enabled);
        phrases.value(prepared).do { |original|
            var event = original.copy;
            event[\time] = event[\time] + elapsed; livePhrases.add(event);
        };
        elapsed = elapsed + batch[\duration]; memory = batch[\memory];
        check.value(memory[\vocalRemaining].isNumber and: { memory[\vocalRemaining] >= 0 },
            "scene returns a nonnegative remaining vocal cooldown");
    };
    check.value(livePhrases.size >= 10, "single-scene playback produces speech across many scenes");
    validatePhrases.value(livePhrases.asArray, "single-scene playback");
    check.value(memory[\phraseLastIndex] == livePhrases.last[\phraseIndex], "memory retains the final spoken transcript identity");
    ("VOCAL COUNTS: low=" ++ lowCount ++ " high=" ++ highCount ++ " live=" ++ livePhrases.size).postln;
} { |error| failures = failures + 1; error.reportError };
("VOCAL TESTS: " ++ checks ++ " assertions, " ++ failures ++ " failures").postln;
if(failures == 0, { 0.exit }, { 1.exit });
)
