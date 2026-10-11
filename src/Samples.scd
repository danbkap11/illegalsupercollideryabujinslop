(
~ism[\scanSamples] = {
    var records = List.new;
    var bytes = 0;
    [["assets/optional", \artifact], ["assets/vocals", \phrase]].do { |bank|
        var directory = PathName(~ism[\root] +/+ bank[0]);
        if(directory.isFolder) {
            directory.files.sort { |a,b| a.fileName < b.fileName }.do { |file|
                var sound = SoundFile.new;
                if(file.extension.toLower == "wav") {
                    if(sound.openRead(file.fullPath)) {
                        if((sound.numChannels <= 2) and: { sound.numFrames > 64 }
                            and: { (bytes + (sound.numFrames * sound.numChannels * 4)) < (128 * 1024 * 1024) }) {
                            records.add((path: file.fullPath, name: file.fileName, role: bank[1],
                                channels: sound.numChannels, frames: sound.numFrames,
                                rate: sound.sampleRate, duration: sound.duration));
                            bytes = bytes + (sound.numFrames * sound.numChannels * 4);
                        };
                        sound.close;
                    };
                };
            };
        };
    };
    ~ism[\samples] = records.asArray;
    ~ism[\phraseIndices] = records.collect { |record, i| if(record[\role] == \phrase) { i } }.reject(_.isNil).asArray;
    ("Sample bank: " ++ records.size ++ " sounds / " ++ ~ism[\phraseIndices].size ++ " spoken phrases").postln;
};

// Same deterministic substitution for realtime and NRT; composition never reads buffers.
~ism[\prepareEvents] = { |composition, sliders, switches|
    var samples = ~ism[\samples];
    var probability = ~ism[\map].value(sliders, switches)[\sampleBlend];
    var result = composition.copy;
    var artifactIndices = samples.collect { |sample, index| if(sample[\role] != \phrase) { index } }.reject(_.isNil);
    var phraseIndices = samples.collect { |sample, index| if(sample[\role] == \phrase) { index } }.reject(_.isNil);
    result[\events] = composition[\events].collect { |original|
        var event = original.copy;
        var chosen, sample, eligible, ratePair, playbackRate;
        if(event[\voice] == \ismPhrase) {
            if(phraseIndices.isEmpty) { event = nil } {
                chosen = phraseIndices[(event[\phraseIndex] ? 0) % phraseIndices.size];
                sample = samples[chosen];
                event[\sampleIndex] = chosen;
                event[\phraseName] = sample[\name];
                ratePair = event[\args].clump(2).detect { |pair| pair[0] == \rate };
                playbackRate = if(ratePair.isNil) { 1 } { ratePair[1].clip(0.85,1.08) };
                event[\dur] = (sample[\duration] / playbackRate) + 0.35;
                event[\args] = event[\args] ++ [\rate, playbackRate];
            };
        } {
            eligible = [\ismGhost, \ismNoise, \ismHat].includes(event[\voice]);
            if(artifactIndices.notEmpty and: { eligible } and: { ((event[\seed] % 997) / 997) < probability }) {
                chosen = artifactIndices[event[\seed] % artifactIndices.size];
                sample = samples[chosen];
                event[\voice] = if(sample[\channels] == 1, { \ismSampleMono }, { \ismSampleStereo });
                event[\sampleIndex] = chosen;
                event[\args] = event[\args] ++ [\rate, 0.72 + ((event[\seed] % 71) / 100), \start, 0];
                event[\dur] = event[\dur].clip(0.045, sample[\duration].max(0.045).min(1.5));
            };
        };
        event;
    }.reject(_.isNil);
    result;
};
)
