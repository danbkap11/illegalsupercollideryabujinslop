(
~ism[\presetNames] = ["AZEROY / DEFAULT", "VACANT ANGEL", "PHONE RAVE", "1616 FRACTURE"];
~ism[\presets] = [
    (sliders: [0.43,0.48,0.50,0.67,0.46,0.55,0.42,0.44,0.34,0.56], switches: [0,1,0,0,0,0,0,0,1,0], seed: 16168888),
    (sliders: [0.27,0.28,0.24,0.86,0.71,0.29,0.65,0.62,0.70,0.83], switches: [0,1,1,0,0,0,0,1,1,0], seed: 8888302),
    (sliders: [0.55,0.63,0.84,0.65,0.49,0.84,0.49,0.40,0.19,0.43], switches: [1,1,0,1,1,0,0,0,1,0], seed: 200916),
    (sliders: [0.90,0.83,0.68,0.47,0.79,0.67,0.76,0.77,0.58,0.69], switches: [1,1,1,1,1,1,1,1,1,1], seed: 161616)
];
~ism[\notify] = { if(~ism[\refreshGUI].notNil) { ~ism[\refreshGUI].value } };
~ism[\updateParams] = {
    var app = ~ism;
    var settings = app[\map].value(app[\sliders], app[\switches]);
    var args = List.new;
    app[\params] = settings;
    app[\revision] = (app[\revision] ? 0) + 1;
    [\bits, \holdRate, \drive, \wear, \delayTime, \delayMix, \feedback, \reverbMix, \width, \phone].do { |key|
        args.add(key); args.add(settings[key]);
    };
    if(app[\fx].notNil and: { app[\ready] == true }) { app[\fx].set(*args.asArray) };
    if(app[\master].notNil and: { app[\ready] == true }) { app[\master].set(\gain, settings[\gain]) };
    app[\activePhrases] = (app[\activePhrases] ? []).select { |entry| entry[\end] > Main.elapsedTime };
    if(app[\ready] == true) {
        if(app[\switches][1] == 0) {
            app[\activePhrases].do { |entry| entry[\node].set(\gate,0) };
            app[\activePhrases] = [];
            app[\vocalText] = "";
        } {
            app[\activePhrases].do { |entry|
                entry[\node].set(\cutoff,settings[\vocalCutoff],\filterCoeff,settings[\vocalFilterCoeff],
                    \echoMix,settings[\vocalDelayMix]);
            };
        };
    };
    app[\notify].value;
};
~ism[\setSlider] = { |index, value|
    ~ism[\sliders][index] = value.clip(0, 1);
    ~ism[\updateParams].value;
};
~ism[\setSwitch] = { |index, value|
    ~ism[\switches][index] = value.asInteger.clip(0, 1);
    ~ism[\updateParams].value;
};
~ism[\applyPreset] = { |name|
    var app = ~ism;
    var index = if(name.isNumber, { name.asInteger }, { app[\presetNames].indexOfEqual(name) });
    var preset;
    if(index.notNil and: { index >= 0 } and: { index < app[\presets].size }) {
        preset = app[\presets][index];
        app[\sliders] = preset[\sliders].copy;
        app[\switches] = preset[\switches].copy;
        app[\seed] = preset[\seed];
        app[\memory] = nil;
        app[\status] = app[\presetNames][index];
        app[\updateParams].value;
    };
};
~ism[\reseed] = {
    ~ism[\seed] = ((~ism[\seed] * 16807) % 2147483647).abs.max(1);
    ~ism[\memory] = nil;
    ~ism[\status] = "NEW MEMORY " ++ ~ism[\seed];
    ~ism[\updateParams].value;
};
// Numeric-only text format avoids evaluating executable preset files.
~ism[\savePreset] = { |path|
    var app = ~ism;
    var destination = path ? (app[\root] +/+ "local/last-patch.ism");
    var file;
    PathName(destination).pathOnly.mkdir;
    file = File(destination, "w");
    if(file.isOpen) {
        file.write("ISM1\n" ++ app[\seed].asString ++ "\n");
        file.write(app[\sliders].collect(_.asString).join(" ") ++ "\n");
        file.write(app[\switches].collect(_.asString).join(" ") ++ "\n");
        file.close;
        app[\status] = "PATCH SAVED";
    } { app[\status] = "CANNOT SAVE PATCH" };
    app[\notify].value;
};
~ism[\loadPreset] = { |path|
    var app = ~ism;
    var source = path ? (app[\root] +/+ "local/last-patch.ism");
    var file = File(source, "r");
    var header, seed, sliders, switches;
    if(file.isOpen) {
        header = file.getLine; seed = file.getLine;
        sliders = file.getLine; switches = file.getLine; file.close;
        if((header == "ISM1") and: { seed.notNil } and: { sliders.notNil } and: { switches.notNil }) {
            sliders = sliders.split($ ).reject(_.isEmpty).collect(_.asFloat);
            switches = switches.split($ ).reject(_.isEmpty).collect(_.asInteger);
            if((sliders.size == 10) and: { switches.size == 10 }) {
                app[\seed] = seed.asInteger.abs.max(1);
                app[\memory] = nil;
                app[\sliders] = sliders.collect { |v| v.clip(0,1) };
                app[\switches] = switches.collect { |v| v.clip(0,1) };
                app[\status] = "MEMORY RESTORED";
                app[\updateParams].value;
            } { app[\status] = "INVALID PATCH DIMENSIONS" };
        } { app[\status] = "INVALID PATCH FORMAT" };
    } { app[\status] = "NO SAVED PATCH YET" };
    app[\notify].value;
};

~ism[\stop] = {
    var app = ~ism;
    app[\running] = false;
    if(app[\routine].notNil) { app[\routine].stop; app[\routine] = nil };
    if(app[\clock].notNil) { app[\clock].clear; app[\clock].stop; app[\clock] = nil };
    if(app[\sources].notNil and: { app[\ready] == true }) { app[\sources].freeAll };
    app[\activePhrases] = [];
    app[\vocalText] = "";
    app[\status] = "STOPPED / TAIL REMAINS";
    app[\notify].value;
};
~ism[\panic] = {
    ~ism[\stop].value;
    if(~ism[\master].notNil and: { ~ism[\ready] == true }) { ~ism[\master].set(\mute, 0) };
    ~ism[\status] = "SILENCED / PRESS START TO RETURN";
    ~ism[\notify].value;
};
~ism[\playEvent] = { |event|
    var app = ~ism;
    var args, buffer, now = Main.elapsedTime, node, started = false;
    if(app[\running] and: { app[\ready] == true } and: {
        (event[\voice] != \ismPhrase) or: {
            (app[\switches][1] == 1) and: { now >= (app[\vocalEarliestAt] ? 0) }
        }
    }) {
        args = [\out, if(event[\voice] == \ismPhrase) { app[\fxBus].index } { app[\sourceBus].index },
            \dur, event[\dur], \seed, event[\seed]] ++ event[\args];
        if(event[\sampleIndex].notNil) {
            buffer = app[\buffers][event[\sampleIndex]];
            if(buffer.notNil) { args = args ++ [\buf, buffer.bufnum] };
        };
        app[\activeVoiceEnds] = (app[\activeVoiceEnds] ? []).select { |time| time > now };
        if(app[\activeVoiceEnds].size < 48) {
            node = Synth(event[\voice], args, app[\sources]);
            started = true;
            app[\activeVoiceEnds] = app[\activeVoiceEnds].add(now + event[\dur].max(0.035));
            if(event[\voice] == \ismPhrase) {
                app[\vocalEarliestAt] = now + 8;
                app[\activePhrases] = (app[\activePhrases] ? []).add((node:node,end:now+event[\dur]));
                app[\vocalText] = ["The angels are offline.","Keep the line open.","Do you remember this place?",
                    "There is nobody at the other end.","You left your voice here.","The room has no floor.",
                    "I can hear the forest.","Return to the empty city."][event[\phraseIndex] % 8];
                app[\vocalUntil] = now + event[\dur];
                app[\notify].value;
            };
        };
    };
    started;
};
~ism[\start] = {
    var app = ~ism;
    if(app[\ready] != true) {
        app[\status] = "WAIT FOR AUDIO BOOT / OFFLINE EXPORT WORKS";
        app[\notify].value;
    } {
        if(app[\running].not) {
            app[\running] = true;
            app[\memory] = nil;
            app[\activeVoiceEnds] = [];
            app[\master].set(\mute, 1);
            app[\clock] = TempoClock.new(1);
            app[\routine] = Routine({
                var batch = 0;
                while { app[\running] } {
                    var seconds = 20;
                    var composition = app[\compose].value((app[\seed] + (batch * 7919)).abs.max(1),
                        app[\sliders].copy, app[\switches].copy, seconds, app[\memory], true,
                        ((app[\vocalEarliestAt] ? 0) - Main.elapsedTime + 0.025).max(0));
                    var cursor = 0.0, index = 0, revision = app[\revision], remainder;
                    var lastPhrase = if(app[\memory].isNil) { -1 } { app[\memory][\phraseLastIndex] ? -1 };
                    var vocalDue = composition[\vocalInitialRemaining], sceneMemory = composition[\memory];
                    app[\memory] = sceneMemory;
                    seconds = composition[\duration];
                    composition = app[\prepareEvents].value(composition, app[\sliders], app[\switches]);
                    app[\scene] = composition[\scenes][0][\name];
                    app[\status] = "TRANSMITTING / " ++ app[\scene].asString;
                    app[\notify].value;
                    while { (index < composition[\events].size) and: { app[\running] }
                        and: { revision == app[\revision] } } {
                        var event = composition[\events][index];
                        remainder = (event[\time] - cursor).max(0);
                        while { (remainder > 0) and: { app[\running] } and: { revision == app[\revision] } } {
                            var step = remainder.min(0.12);
                            step.wait; cursor = cursor + step; remainder = remainder - step;
                        };
                        if(revision == app[\revision]) {
                            if(app[\playEvent].value(event) and: { event[\voice] == \ismPhrase }) {
                                vocalDue = cursor + event[\nextVocalGap];
                                lastPhrase = event[\phraseIndex];
                            };
                        };
                        index = index + 1;
                    };
                    remainder = (seconds - cursor).max(0);
                    while { (remainder > 0) and: { app[\running] } and: { revision == app[\revision] } } {
                        var step = remainder.min(0.12);
                        step.wait; cursor = cursor + step; remainder = remainder - step;
                    };
                    // A reseed/preset can deliberately discard memory while this
                    // scene is waiting. Do not resurrect its old phrase cooldown.
                    if(app[\memory] === sceneMemory) {
                        sceneMemory[\vocalRemaining] = (vocalDue - cursor).max(0);
                        sceneMemory[\phraseLastIndex] = lastPhrase;
                        sceneMemory[\vocalWasEnabled] = app[\switches][1];
                    };
                    batch = batch + 1;
                };
            }).play(app[\clock]);
            app[\status] = "TRANSMITTING";
            app[\notify].value;
        };
    };
};

~ism[\boot] = {
    var app = ~ism;
    var server = Server.default;
    app[\server] = server;
    server.options.numOutputBusChannels = 2;
    server.options.numInputBusChannels = 0;
    server.options.memSize = 262144;
    server.options.maxNodes = 4096;
    app[\status] = "BOOTING AUDIO / FIRST START MAY TAKE A MOMENT";
    server.waitForBoot({
        Routine({
            if(app[\closed] == true) { nil.alwaysYield };
            app[\defineSynths].value;
            server.sync;
            if(app[\closed] == true) { nil.alwaysYield };
            app[\sourceBus] = Bus.audio(server, 2);
            app[\fxBus] = Bus.audio(server, 2);
            app[\sources] = Group.head(server);
            app[\fxGroup] = Group.after(app[\sources]);
            app[\masterGroup] = Group.after(app[\fxGroup]);
            app[\buffers] = app[\samples].collect { |sample| Buffer.read(server, sample[\path]) };
            server.sync;
            if(app[\closed] == true) {
                app[\buffers].do(_.free);
                [\sources, \fxGroup, \masterGroup, \sourceBus, \fxBus].do { |key| app[key].free };
                nil.alwaysYield;
            };
            app[\fx] = Synth(\ismFX, [\in, app[\sourceBus].index, \out, app[\fxBus].index,
                \seed, app[\seed]], app[\fxGroup]);
            app[\master] = Synth(\ismMaster, [\in, app[\fxBus].index, \out, 0], app[\masterGroup]);
            app[\ready] = true;
            app[\status] = "READY / PRESS START";
            app[\updateParams].value;
        }).play(AppClock);
    }, 100, {
        app[\status] = "AUDIO UNAVAILABLE / CHECK DEVICE / EXPORT STILL WORKS";
        app[\notify].value;
    });
};
~ism[\export] = { |path, seconds = 90|
    var app = ~ism;
    if(app[\exporting] != true) {
        app[\exporting] = true;
        app[\render].value(seconds, path, { app[\exporting] = false });
    };
};
~ism[\close] = {
    var app = ~ism;
    app[\closed] = true;
    app[\stop].value;
    if(app[\meterRoutine].notNil) { app[\meterRoutine].stop };
    if(app[\guiRoutine].notNil) { app[\guiRoutine].stop; app[\guiRoutine] = nil };
    if(app[\legendWindow].notNil) { { app[\legendWindow].close }.defer };
    if(app[\ready] == true) {
        [\sources, \fxGroup, \masterGroup].do { |key| if(app[key].notNil) { app[key].free } };
        app[\buffers].do { |buffer| buffer.free };
        [\sourceBus, \fxBus].do { |key| if(app[key].notNil) { app[key].free } };
        app[\ready] = false;
    };
    if(app[\window].notNil) { { app[\window].onClose = nil; app[\window].close }.defer };
};
)
