// Run with ISM_NO_BOOT=1 DISPLAY=:97 sclang -D tests/gui_tests.scd (Xvfb or desktop).
// Exercises actual Qt controls and App callbacks. No audio backend is required.
(
var root = thisProcess.nowExecutingPath.standardizePath.dirname.dirname;
var checks = 0, failures = 0, check;
var patchPath = "/tmp/ism-gui-validation.ism";
var invalidPath = "/tmp/ism-gui-invalid.ism";
check = { |condition, message|
    checks = checks + 1;
    if(condition.not, { failures = failures + 1; ("FAIL: " ++ message).postln });
};
Routine({
    var w, children, allViews, visit, buttons, savedSliders, savedSwitches, savedSeed;
    var beforeSliders, beforeSwitches, beforeSeed, file, image, screenshotPath, closeCount = 0;
    try {
        check.value("ISM_NO_BOOT".getenv == "1", "test explicitly disables realtime boot");
        (root +/+ "Main.scd").load;
        0.4.wait;
        w = ~ism[\window];
        check.value(w.notNil and: { w.isClosed.not }, "entry point creates a visible window");
        check.value(w.name == "ILLEGAL SUPERCOLLIDER YABUJINSLOP MACHINE", "exact project title");
        check.value(~ism[\ready] != true and: { ~ism[\running].not }, "offline load needs no audio backend");
        allViews = List.new;
        visit = { |view| allViews.add(view); view.children.do { |child| visit.value(child) } };
        visit.value(w.view);
        buttons = allViews.select { |view| view.isKindOf(Button) };
        check.value(allViews.count { |view| view.isKindOf(Slider) } == 10, "exactly ten native Slider widgets");
        check.value(buttons.count { |view| view.states.size == 2 } == 10, "exactly ten two-state Button switches");
        check.value(buttons.every { |view| [1, 2].includes(view.states.size) }, "transports and auxiliary actions remain momentary");
        check.value(~ism[\sliderViews].size == 10 and: { ~ism[\switchViews].size == 10 }, "stored control arrays cover all widgets");
        (~ism[\sliderViews] ++ ~ism[\switchViews]).do { |view, index|
            var box = view.bounds, parent = view.parent.bounds;
            check.value(box.width >= 12 and: { box.height >= 12 }, "control remains a usable hit target " ++ index);
            check.value((box.left >= 0) and: { box.top >= 0 } and: {
                box.right <= parent.width
            } and: { box.bottom <= parent.height }, "control stays inside its parent " ++ index);
        };
        ~ism[\sliderViews].do { |slider, index|
            var value = 0.07 + (0.08 * index);
            slider.valueAction = value;
            check.value((~ism[\sliders][index] - value).abs < 1e-5, "slider callback " ++ index);
            check.value((~ism[\params][\sliders][index] - value).abs < 1e-5, "slider mapper receives callback " ++ index);
        };
        ~ism[\switchViews].do { |button, index|
            button.valueAction = 1;
            check.value(~ism[\switches][index] == 1, "switch on callback " ++ index);
            button.valueAction = 0;
            check.value(~ism[\switches][index] == 0, "switch off callback " ++ index);
        };
        ~ism[\setSlider].value(0, -5);
        ~ism[\setSlider].value(1, 8);
        ~ism[\setSwitch].value(0, -1);
        ~ism[\setSwitch].value(1, 7);
        check.value(~ism[\sliders][0] == 0 and: { ~ism[\sliders][1] == 1 }, "slider bounds at public API");
        check.value(~ism[\switches][0] == 0 and: { ~ism[\switches][1] == 1 }, "switch bounds at public API");
        ~ism[\refreshGUI].value;
        0.2.wait;
        check.value(~ism[\sliderViews][0].value == 0 and: { ~ism[\sliderViews][1].value == 1 }, "GUI follows state changes");
        savedSliders = ~ism[\sliders].copy;
        savedSwitches = ~ism[\switches].copy;
        savedSeed = ~ism[\seed];
        ~ism[\savePreset].value(patchPath);
        check.value(File.exists(patchPath), "preset file saved");
        file = File(patchPath, "r");
        check.value(file.getLine == "ISM1", "numeric versioned preset format");
        file.close;
        ~ism[\applyPreset].value(0);
        ~ism[\reseed].value;
        ~ism[\loadPreset].value(patchPath);
        check.value(~ism[\seed] == savedSeed, "preset roundtrip restores seed");
        check.value(~ism[\switches] == savedSwitches, "preset roundtrip restores all switches");
        check.value(~ism[\sliders].collect { |value, index| (value - savedSliders[index]).abs }.maxItem < 1e-5,
            "preset roundtrip restores all sliders");
        beforeSliders = ~ism[\sliders].copy; beforeSwitches = ~ism[\switches].copy; beforeSeed = ~ism[\seed];
        ~ism[\reseed].value;
        check.value(~ism[\seed] != beforeSeed and: { ~ism[\seed] > 0 }, "reseed changes positive composition seed");
        check.value(~ism[\sliders] == beforeSliders and: { ~ism[\switches] == beforeSwitches }, "reseed preserves the user's patch");
        file = File(invalidPath, "w"); file.write("WRONG_VERSION\n1\n0\n0\n"); file.close;
        beforeSeed = ~ism[\seed];
        ~ism[\loadPreset].value(invalidPath);
        check.value(~ism[\seed] == beforeSeed and: { ~ism[\sliders] == beforeSliders }, "invalid preset cannot replace current state");
        ~ism[\presetNames].do { |name, index|
            ~ism[\applyPreset].value(name);
            check.value(~ism[\seed] == ~ism[\presets][index][\seed], "named demonstration preset " ++ name);
        };
        ~ism[\applyPreset].value(0);
        ~ism[\start].value;
        check.value(~ism[\running].not and: { ~ism[\routine].isNil }, "offline start reports unavailable audio without a scheduler");
        ~ism[\stop].value; ~ism[\panic].value;
        check.value(~ism[\running].not, "stop/panic are safe before server boot");
        // Actual auxiliary button callbacks exercise label fallback and the technical legend.
        buttons.detect { |button| button.states[0][0] == "Aa / GLYPH" }.doAction;
        check.value(~ism[\guiAscii] == true, "ASCII label fallback button");
        buttons.detect { |button| button.states[0][0] == "F1 / RECEIPT" }.doAction;
        check.value(~ism[\legendWindow].notNil, "technical legend opens");
        ~ism[\legendWindow].close;
        buttons.detect { |button| button.states[0][0] == "Aa / GLYPH" }.doAction;
        check.value(~ism[\guiAscii] == false, "decorative labels restored");
        ~ism[\refreshGUI].value;
        0.3.wait;
        screenshotPath = "ISM_GUI_SCREENSHOT".getenv ? "/tmp/ism-gui-smoke.png";
        image = Image.fromWindow(w);
        image.write(screenshotPath, "png"); image.free;
        check.value(File.exists(screenshotPath), "actual Qt window screenshot captured");
        3.do {
            w.close;
            0.25.wait;
            closeCount = closeCount + 1;
            check.value(~ism[\window].isNil and: { ~ism[\guiRoutine].isNil }, "close cleans GUI lifecycle " ++ closeCount);
            w = ~ism[\makeGUI].value;
            0.25.wait;
            check.value(w.notNil and: { w.isClosed.not }, "clean GUI reopen " ++ closeCount);
        };
        w.close;
        0.25.wait;
    } { |error|
        failures = failures + 1;
        error.reportError;
        if(~ism.notNil and: { ~ism[\window].notNil }, { ~ism[\window].close });
    };
    [patchPath, invalidPath].do { |path| if(File.exists(path), { File.delete(path) }) };
    ("GUI TESTS: " ++ checks ++ " assertions, " ++ failures ++ " failures").postln;
    if(failures == 0, { 0.exit }, { 1.exit });
}).play(AppClock);
)
