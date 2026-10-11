// ISM_SECONDS=90 ISM_PRESET=2 ISM_OUTPUT=/absolute/path.wav sclang tools/render.scd
(
var here = PathName(thisProcess.nowExecutingPath.absolutePath).pathOnly.dirname;
var seconds = ("ISM_SECONDS".getenv ? "90").asFloat.clip(1,600);
var preset = ("ISM_PRESET".getenv ? "0").asInteger.clip(0,3);
var path = "ISM_OUTPUT".getenv;
var sliderText = "ISM_SLIDERS".getenv, switchText = "ISM_SWITCHES".getenv;
"ISM_CLI_RENDER".setenv("1");
~ism = (root: here, sliders: Array.fill(10,0.5), switches: Array.fill(10,0), seed: 16168888,
    buffers: [], samples: [], running: false);
["Composer", "Voices", "Samples", "Render", "App"].do { |name|
    (here +/+ "src" +/+ (name ++ ".scd")).load;
};
if(~ism[\compose].isNil or: { ~ism[\defineSynths].isNil } or: { ~ism[\render].isNil }) {
    "ERROR: module loading failed".postln; 1.exit;
};
AppClock.sched(180, { "ERROR: render timed out".postln; 1.exit });
~ism[\applyPreset].value(preset);
if("ISM_SEED".getenv.notNil) { ~ism[\seed] = "ISM_SEED".getenv.asInteger.abs.max(1) };
if(sliderText.notNil) {
    var values = sliderText.split($,).collect(_.asFloat);
    if(values.size != 10) { "ISM_SLIDERS needs ten comma-separated numbers".postln; 1.exit };
    ~ism[\sliders] = values.collect { |v| v.clip(0,1) };
};
if(switchText.notNil) {
    var values = switchText.split($,).collect(_.asInteger);
    if(values.size != 10) { "ISM_SWITCHES needs ten comma-separated integers".postln; 1.exit };
    ~ism[\switches] = values.collect { |v| v.clip(0,1) };
};
~ism[\scanSamples].value;
if("ISM_NO_SAMPLES".getenv == "1") { ~ism[\samples] = [] };
~ism[\defineSynths].value;
~ism[\render].value(seconds, path, { |output, composition|
    var trace = File(output ++ ".events.txt", "w");
    if(trace.isOpen) {
        trace.write("seed=" ++ ~ism[\seed] ++ "\nbpm=" ++ composition[\bpm] ++ "\n");
        composition[\scenes].do { |scene| trace.write(scene.asCompileString ++ "\n") };
        composition[\events].do { |event| trace.write(event.asCompileString ++ "\n") };
        trace.close;
    };
    0.exit;
});
)
