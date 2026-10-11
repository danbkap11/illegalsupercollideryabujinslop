// Start dummy JACK and this script in one shell for sandbox shared-memory IPC.
(
var root = thisProcess.nowExecutingPath.absolutePath.dirname.dirname;
var assertions = 0, failures = 0, check;
check = { |condition, message|
    assertions = assertions + 1;
    if(condition.not) { failures = failures + 1; ("FAIL: " ++ message).postln };
};
AppClock.sched(50, { "FAIL: realtime test timed out".postln; 1.exit });
(root +/+ "Main.scd").load;
Routine({
    var attempts = 0, server, output, peakCPU = 0, initialSeed, beforeMemory, synthCount;
    while { (~ism[\ready] != true) and: { attempts < 100 } } { 0.1.wait; attempts = attempts + 1 };
    try {
        check.value(~ism[\ready] == true, "server boots and app graph is ready");
        if(~ism[\ready] != true) { Error("Server failed to boot").throw };
        server = ~ism[\server];
        check.value(~ism[\buffers].size == 28, "all licensed samples loaded into server");
        ~ism[\applyPreset].value(3);
        initialSeed = ~ism[\seed];
        output = root +/+ "renders/realtime.wav";
        PathName(output).pathOnly.mkdir;
        server.record(path: output, numChannels: 2);
        0.5.wait;
        ~ism[\start].value;
        check.value(~ism[\running], "transport starts");
        35.do { 0.1.wait; peakCPU = peakCPU.max(server.peakCPU) };
        check.value(~ism[\memory].notNil, "realtime composer stores scene memory");
        beforeMemory = ~ism[\memory][\sceneNumber];
        ~ism[\setSlider].value(0, 0.6);
        0.35.wait;
        check.value(~ism[\memory][\sceneNumber] > beforeMemory, "macro changes reach composer promptly");
        check.value(~ism[\activeVoiceEnds].size <= 48, "live polyphony budget enforced");
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
