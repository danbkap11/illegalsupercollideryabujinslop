(
~ism[\scanSamples] = {
    var directory = PathName(~ism[\root] +/+ "assets/optional");
    var records = List.new;
    var bytes = 0;
    if(directory.isFolder) {
        directory.files.sort { |a,b| a.fileName < b.fileName }.do { |file|
            var sound = SoundFile.new;
            if(file.extension.toLower == "wav") {
                if(sound.openRead(file.fullPath)) {
                    if((sound.numChannels <= 2) and: { sound.numFrames > 64 }
                        and: { (bytes + (sound.numFrames * sound.numChannels * 4)) < (128 * 1024 * 1024) }) {
                        records.add((path: file.fullPath, name: file.fileName,
                            channels: sound.numChannels, frames: sound.numFrames,
                            rate: sound.sampleRate, duration: sound.duration));
                        bytes = bytes + (sound.numFrames * sound.numChannels * 4);
                    };
                    sound.close;
                };
            };
        };
    };
    ~ism[\samples] = records.asArray;
    ("Sample bank: " ++ records.size ++ " licensed optional sounds").postln;
};

// Same deterministic substitution for realtime and NRT; composition never reads buffers.
~ism[\prepareEvents] = { |composition, sliders, switches|
    var samples = ~ism[\samples];
    var probability = ~ism[\map].value(sliders, switches)[\sampleBlend];
    var result = composition.copy;
    result[\events] = composition[\events].collect { |original|
        var event = original.copy;
        var chosen, sample, eligible;
        eligible = [\ismGhost, \ismNoise, \ismHat].includes(event[\voice]);
        if(samples.notEmpty and: { eligible } and: { ((event[\seed] % 997) / 997) < probability }) {
            chosen = event[\seed] % samples.size;
            sample = samples[chosen];
            event[\voice] = if(sample[\channels] == 1, { \ismSampleMono }, { \ismSampleStereo });
            event[\sampleIndex] = chosen;
            event[\args] = event[\args] ++ [\rate, 0.72 + ((event[\seed] % 71) / 100), \start, 0];
            event[\dur] = event[\dur].clip(0.045, sample[\duration].max(0.045).min(1.5));
        };
        event;
    };
    result;
};
)
