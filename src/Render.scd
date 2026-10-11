(
~ism[\render] = { |seconds = 90, path, done|
    var app = ~ism;
    var settings = app[\map].value(app[\sliders], app[\switches]);
    var composition = app[\compose].value(app[\seed], app[\sliders].copy, app[\switches].copy, seconds);
    var events, messages = List.new, options, server, score, fxArgs;
    var output = path ? (app[\root] +/+ "renders" +/+ ("summoning-" ++ Date.localtime.stamp ++ ".wav"));
    var count = 1000;
    PathName(output).pathOnly.mkdir;
    composition = app[\prepareEvents].value(composition, app[\sliders], app[\switches]);
    events = composition[\events];
    options = ServerOptions.new.numOutputBusChannels_(2).numInputBusChannels_(0)
        .sampleRate_(44100).memSize_(262144).maxNodes_(4096);
    server = Server(\ismNRT, NetAddr("127.0.0.1", 0), options);
    app[\defs].do { |definition| messages.add([0.0, [\d_recv, definition.asBytes]]) };
    app[\samples].do { |sample, index|
        messages.add([0.0, [\b_allocRead, 100 + index, sample[\path]]]);
    };
    messages.add([0.001, [\g_new, 10, 0, 0]]);
    messages.add([0.002, [\g_new, 11, 3, 10]]);
    messages.add([0.003, [\g_new, 12, 3, 11]]);
    fxArgs = [\in, 16, \out, 18, \seed, app[\seed]];
    [\bits, \holdRate, \drive, \wear, \delayTime, \delayMix, \feedback, \reverbMix, \width, \phone].do { |key|
        fxArgs = fxArgs ++ [key, settings[key]];
    };
    messages.add([0.004, [\s_new, \ismFX, 20, 0, 11] ++ fxArgs]);
    messages.add([0.005, [\s_new, \ismMaster, 21, 0, 12, \in, 18, \out, 0, \gain, settings[\gain]]]);
    events.do { |event|
        var args = [\out, if(event[\voice] == \ismPhrase) { 18 } { 16 },
            \seed, event[\seed], \dur, event[\dur]] ++ event[\args];
        if(event[\sampleIndex].notNil) { args = args ++ [\buf, 100 + event[\sampleIndex]] };
        messages.add([event[\time] + 0.01, [\s_new, event[\voice], count, 0, 10] ++ args]);
        count = count + 1;
    };
    // Stop sources but preserve a bounded tail, then fade after the final limiter.
    messages.add([seconds, [\g_freeAll, 10]]);
    messages.add([seconds + 3, [\n_set, 21, \gate, 0]]);
    messages.add([seconds + 3.25, [\c_set, 0, 0]]);
    score = Score(messages.asArray.sort { |a,b| a[0] < b[0] });
    app[\status] = "EXPORTING " ++ PathName(output).fileName;
    if(app[\refreshGUI].notNil) { app[\refreshGUI].value };
    score.recordNRT(oscFilePath: output ++ ".osc", outputFilePath: output, sampleRate: 44100, headerFormat: "WAV",
        sampleFormat: "int16", options: options, duration: seconds + 3.25,
        action: { |exitCode|
            File.delete(output ++ ".osc");
            if(exitCode != 0) {
                app[\status] = "EXPORT FAILED / CHECK POST WINDOW";
                app[\exporting] = false;
                ("ERROR: scsynth export exited " ++ exitCode).postln;
                if(app[\refreshGUI].notNil) { app[\refreshGUI].value };
                if("ISM_CLI_RENDER".getenv == "1") { 1.exit };
            } {
            app[\status] = "EXPORTED " ++ PathName(output).fileName;
            ("Rendered " ++ events.size ++ " events to " ++ output).postln;
            if(app[\refreshGUI].notNil) { app[\refreshGUI].value };
            if(done.notNil) { done.value(output, composition) };
            };
        });
    server.remove;
    output;
};
)
