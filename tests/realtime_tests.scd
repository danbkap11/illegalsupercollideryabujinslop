// Start dummy JACK and this script in one shell for sandbox shared-memory IPC.
(
var root = thisProcess.nowExecutingPath.absolutePath.dirname.dirname;
var assertions = 0, failures = 0, check;
check = { |condition, message|
    assertions = assertions + 1;
    if(condition.not) { failures = failures + 1; ("FAIL: " ++ message).postln };
};
AppClock.sched(75, { "FAIL: realtime test timed out".postln; 1.exit });
(root +/+ "Main.scd").load;
Routine({
    var attempts = 0, server, output, peakCPU = 0, initialSeed, beforeMemory, synthCount;
    var originalPlay, phraseOnsets = List.new, activeNode, phraseWait = 0;
    while { (~ism[\ready] != true) and: { attempts < 100 } } { 0.1.wait; attempts = attempts + 1 };
    try {
        check.value(~ism[\ready] == true, "server boots and app graph is ready");
        if(~ism[\ready] != true) { Error("Server failed to boot").throw };
        server = ~ism[\server];
        check.value(~ism[\samples].notEmpty and: {
            ~ism[\buffers].size == ~ism[\samples].size
        }, "complete scanned sample bank loaded into server");
        check.value(~ism[\samples].count { |sample| sample[\role] == \phrase } >= 8,
            "spoken phrase bank present in realtime buffer map");
        ~ism[\samples].do { |sample, index|
            if(sample[\role] == \phrase) {
                check.value(~ism[\buffers][index].numFrames == sample[\frames]
                    and: { ~ism[\buffers][index].numChannels == sample[\channels] },
                    "phrase buffer metadata matches " ++ sample[\name]);
            };
        };
        ~ism[\applyPreset].value(3);
        ~ism[\setSlider].value(6, 1);
        originalPlay = ~ism[\playEvent];
        ~ism[\playEvent] = { |event|
            var started = originalPlay.value(event);
            if(started and: { event[\voice] == \ismPhrase }) { phraseOnsets.add(Main.elapsedTime) };
            started
        };
        initialSeed = ~ism[\seed];
        output = root +/+ "renders/realtime.wav";
        PathName(output).pathOnly.mkdir;
        server.record(path: output, numChannels: 2);
        0.5.wait;
        ~ism[\start].value;
        check.value(~ism[\running], "transport starts");
        while { phraseOnsets.isEmpty and: { phraseWait < 90 } } {
            0.1.wait; phraseWait = phraseWait + 1; peakCPU = peakCPU.max(server.peakCPU);
        };
        check.value(phraseOnsets.notEmpty, "actual realtime scheduler starts a phrase recording");
        check.value(~ism[\activePhrases].notEmpty and: { ~ism[\vocalText].size > 3 }, "active phrase appears in GUI caption state");
        activeNode = ~ism[\activePhrases].last[\node];
        NodeWatcher.register(activeNode, true);
        ~ism[\setSwitch].value(1, 0);
        0.25.wait;
        check.value(~ism[\activePhrases].isEmpty and: { ~ism[\vocalText].isEmpty }, "T02 off clears active phrase and caption state");
        check.value(activeNode.isPlaying.not, "T02 off releases the actual vocal synthesizer after a short fade");
        phraseOnsets.clear;
        ~ism[\setSwitch].value(1, 1);
        // Repeated scene interruptions must subtract elapsed time rather than
        // copying a projected cooldown and making speech vanish or repeat early.
        40.do { |index| ~ism[\setSlider].value(0, 0.45 + ((index % 5) * 0.08)); 0.1.wait };
        165.do { 0.1.wait; peakCPU = peakCPU.max(server.peakCPU) };
        ("LIVE VOCAL ONSETS: " ++ phraseOnsets.asArray).postln;
        check.value(phraseOnsets.size >= 2, "vocal scheduler recovers and produces phrases despite rapid macro edits");
        phraseOnsets.doAdjacentPairs { |before, after|
            check.value((after - before) >= 7.9, "actual phrase cooldown persists across realtime scene changes");
        };
        check.value(~ism[\memory].notNil, "realtime composer stores scene memory");
        beforeMemory = ~ism[\memory][\sceneNumber];
        ~ism[\setSlider].value(0, 0.6);
        0.35.wait;
        check.value(~ism[\memory][\sceneNumber] > beforeMemory, "macro changes reach composer promptly");
        check.value(~ism[\activeVoiceEnds].size <= 48, "live polyphony budget enforced");
        ~ism[\reseed].value;
        0.35.wait;
        check.value(~ism[\seed] != initialSeed and: { ~ism[\running] and: { ~ism[\memory].notNil } },
            "reseed during playback safely replaces composition memory and continues scheduling");
        initialSeed = ~ism[\seed];
        ~ism[\panic].value;
        check.value(~ism[\running].not, "panic stops scheduler");
        1.7.wait;
        ~ism[\start].value;
        3.0.wait;
        check.value(~ism[\running] and: { ~ism[\memory].notNil }, "panic permits clean restart");
        ~ism[\stop].value;
        0.25.wait;
        check.value(~ism[\routine].isNil and: { ~ism[\clock].isNil }, "stop clears routine and clock");
        ~ism[\start].value;
        1.5.wait;
        check.value(~ism[\running], "second restart succeeds");
        ~ism[\stop].value;
        3.5.wait;
        server.stopRecording;
        server.sync;
        check.value(File.exists(output), "actual realtime stereo output recorded");
        check.value(~ism[\seed] == initialSeed, "transport preserves seed");
        ~ism[\window].close;
        0.4.wait;
        server.sync;
        check.value(~ism[\ready] == false and: { ~ism[\window].isNil }, "window close releases owned graph");
        check.value(~ism[\guiRoutine].isNil, "window close stops GUI update routine");
        OSCFunc({ |message| synthCount = message[3] }, '/status.reply', server.addr).oneShot;
        server.sendMsg('/status');
        0.3.wait;
        check.value(synthCount == 0, "fresh server status shows no leaked owned synthesizers after close");
        ("REALTIME CPU PEAK: " ++ peakCPU).postln;
        server.quit;
    } { |error| failures = failures + 1; error.reportError; if(~ism[\close].notNil) { ~ism[\close].value } };
    ("REALTIME TESTS: " ++ assertions ++ " assertions, " ++ failures ++ " failures").postln;
    if(failures == 0) { 0.exit } { 1.exit };
}).play(AppClock);
)
