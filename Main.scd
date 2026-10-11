// Open this file in SuperCollider, select everything, and evaluate (Ctrl/Cmd+Enter).
(
var entry = thisProcess.nowExecutingPath;
var old = ~ism;
if(entry.isNil) { entry = \Document.asClass.tryPerform(\current).tryPerform(\path) };
if(entry.isNil) { Error("Save/open Main.scd or load it by its absolute path first.").throw };
if(old.notNil and: { old[\close].notNil }) { old[\close].value };
~ism = (
    root: PathName(entry.absolutePath).pathOnly,
    sliders: [0.43, 0.48, 0.50, 0.67, 0.46, 0.55, 0.42, 0.44, 0.34, 0.56],
    switches: [0, 1, 0, 0, 0, 0, 0, 0, 1, 0],
    seed: 16168888, running: false, scene: \vacantRoom, status: "SUMMONING", buffers: [], samples: []
);
["Composer", "Voices", "Samples", "Render", "App", "GUI"].do { |name|
    (~ism[\root] +/+ "src" +/+ (name ++ ".scd")).load;
};
~ism[\scanSamples].value;
~ism[\defineSynths].value;
~ism[\params] = ~ism[\map].value(~ism[\sliders], ~ism[\switches]);
~ism[\makeGUI].value;
if("ISM_NO_BOOT".getenv != "1") { ~ism[\boot].value } {
    ~ism[\status] = "OFFLINE / EXPORT AVAILABLE";
    ~ism[\refreshGUI].value;
};
"ILLEGAL SUPERCOLLIDER YABUJINSLOP MACHINE / F1 reveals the legend".postln;
)
