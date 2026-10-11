// ISM_NO_BOOT=1 sclang -D tests/gui_fit_tests.scd (desktop/Xvfb or offscreen).
(
var root = thisProcess.nowExecutingPath.absolutePath.dirname.dirname;
var checks = 0, failures = 0, check;
if("ISM_NO_BOOT".getenv != "1") { "Set ISM_NO_BOOT=1 for GUI-only validation".postln; 1.exit };
AppClock.sched(30, { "GUI FIT timed out".postln; 1.exit });
check = { |condition, message|
    checks = checks + 1;
    if(condition.not) { failures = failures + 1; ("FAIL: " ++ message).postln };
};
Routine({
    var w, available, bounds, legend;
    try {
        (root +/+ "Main.scd").load;
        0.4.wait;
        w = ~ism[\window]; available = Window.availableBounds; bounds = w.bounds;
        check.value(~ism[\guiScale] > 0 and: { ~ism[\guiScale] <= 1 }, "positive non-enlarging fit scale");
        check.value(bounds.width <= (available.width - 40), "window preserves horizontal margin");
        check.value(bounds.height <= (available.height - 60), "window preserves vertical margin");
        check.value(bounds.left >= available.left and: { bounds.right <= available.right }, "window fits screen horizontally");
        check.value(bounds.top >= available.top and: { bounds.bottom <= available.bottom }, "window fits screen vertically");
        w.view.children.do { |view, index|
            var rect = view.bounds, parent = view.parent.bounds;
            check.value(rect.left >= 0 and: { rect.top >= 0 } and: { rect.right <= (parent.width + 1) } and: { rect.bottom <= (parent.height + 1) }, "all native child bounds " ++ index);
            if(view.isKindOf(Button) or: { view.isKindOf(Slider) } or: { view.isKindOf(PopUpMenu) }) {
                check.value(rect.width >= 12 and: { rect.height >= 12 }, "usable scaled native hit area " ++ index);
            };
        };
        ~ism[\showLegend].value; 0.2.wait; legend = ~ism[\legendWindow];
        check.value(legend.bounds.width <= (available.width - 40) and: { legend.bounds.height <= (available.height - 60) }, "legend fits screen");
        legend.close;
        ("GUI FIT: " ++ available.asString ++ " scale " ++ ~ism[\guiScale] ++ " window " ++ bounds.asString ++ "; " ++ checks ++ " assertions, " ++ failures ++ " failures").postln;
        w.close; 0.2.wait;
    } { |error| error.reportError; failures = failures + 1 };
    if(failures == 0) { 0.exit } { 1.exit };
}).play(AppClock);
)
