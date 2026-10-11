/*
ILLEGAL SUPERCOLLIDER YABUJINSLOP MACHINE
Original procedural artwork; no remote images, fonts, or plugins required.
Display labels are invented Azeroy-inspired words, not translations.
*/
(
~ism[\makeGUI] = {
    var w, art, status, seedText, sceneText, legendButton, asciiButton;
    var sliderNames, sliderASCII, switchNames, switchASCII, sliderLabels;
    var sliderNumbers, switchLabels, colours, labelFont, tinyFont, makeText;
    var momentary, showLegend, paletteForScene, updateNames, presetMenu;
    var sliderHelp, switchHelp, refresh, closeLegend;

    sliderNames = ["AZHŪR", "DŽÆR", "VØRZ", "NAŶA", "THÆL", "KHUZ", "ÆZRI", "SHØR", "UZH", "YŌR"];
    sliderASCII = ["AZHUR", "DZAER", "VORZ", "NAYA", "THAEL", "KHUZ", "AEZRI", "SHOR", "UZH", "YOR"];
    switchNames = ["ÆKRA", "ZHŪN", "VÆSH", "NØZA", "DZYR", "ŪZHA", "KÆR", "THØN", "AYZ", "ŠÆL"];
    switchASCII = ["AEKRA", "ZHUN", "VAESH", "NOZA", "DZYR", "UZHA", "KAER", "THON", "AYZ", "SHAEL"];
    sliderHelp = [
        "S01 AZHUR: scene-change hazard, pattern mutations, fills, and motif variation. Familiar cells become unstable remembered fragments.",
        "S02 DZAER: digital bit depth, sample/hold rate, saturation, and level compensation. Clarity becomes coarse damaged transmission.",
        "S03 VORZ: tempo target, half/double-time grammar, drum rolls, and bass articulation. A dragging lurch becomes restless propulsion.",
        "S04 NAYA: motif persistence, harmonic tension, bell/flute blend, and pad voicing. Sparse phrases become luminous dissonant apparitions.",
        "S05 THAEL: delay send, repeat density, stereo displacement, and melodic answers. Dry fragments become echo conversations.",
        "S06 KHUZ: kick pitch envelope, distortion, sub/harmonic balance, and groove accents. Hollow thuds become hostile pitched impacts.",
        "S07 AEZRI: formant/sample presence, retrigger duration, pitch instability, and telephone coloration. Faint voices become ghost syllables.",
        "S08 SHOR: bandwidth decay, dust/noise, slow wow/flutter, and high-frequency damping. New plastic becomes rotten tape.",
        "S09 UZH: percussion sparsity, dropout probability, scene length, and negative space. Busy surfaces become interrupted architecture.",
        "S10 YOR: reverb, pitch-linked resonance, stereo width, and pad envelopes. Small rooms become implausible distant landscapes."
    ];
    switchHelp = [
        "T01 AEKRA: permits brief hardstyle eruptions, kick variants, accent changes, and bass following.",
        "T02 ZHUN: enables ghost voices, answering phrases, and spectral/spatial telephone treatment.",
        "T03 VAESH: permits reversed samples, reversed envelopes, and reverse-prelude transitions.",
        "T04 NOZA: enables phone-band coloration, notification motifs, and short slap echoes.",
        "T05 DZYR: permits coordinated drum/melody stutters and effect bursts.",
        "T06 UZHA: permits tape-collapse interventions: slowing, falling pitch, narrowed bandwidth, and recovery.",
        "T07 KAER: enables unstable tuning, inharmonic timbres, and harmonic substitutions.",
        "T08 THON: permits bounded feedback echoes, irregular delay ratios, and tail-focused transitions.",
        "T09 AYZ: remembers motif/rhythm fragments and biases transformed future returns.",
        "T10 SHAEL: biases ruptures, negative space, dropout shapes, and unusual recovery grammar."
    ];

    colours = (
        black: Color(0.035, 0.03, 0.075), concrete: Color(0.42, 0.43, 0.43),
        violet: Color(0.43, 0.15, 0.70), chlorine: Color(0.72, 0.96, 0.20),
        rust: Color(0.77, 0.19, 0.17), paper: Color(0.90, 0.88, 0.76),
        ash: Color(0.66, 0.67, 0.61), turquoise: Color(0.28, 0.78, 0.73)
    );
    labelFont = Font("DejaVu Sans", 15, true);
    tinyFont = Font("DejaVu Sans Mono", 10);
    ~ism[\guiAscii] = ~ism[\guiAscii] ? false;
    ~ism[\visualFrame] = 0;
    sliderLabels = Array.newClear(10);
    sliderNumbers = Array.newClear(10);
    switchLabels = Array.newClear(10);

    if(~ism[\window].notNil) { ~ism[\window].front } {
        w = Window("ILLEGAL SUPERCOLLIDER YABUJINSLOP MACHINE", Rect(40, 35, 1200, 660), false);
        w.background = colours[\black];
        ~ism[\window] = w;
        ~ism[\guiArt] = nil;

        makeText = { |text, rect, font, colour, background|
            StaticText(w, rect).string_(text).font_(font ? tinyFont)
                .stringColor_(colour ? colours[\paper]).background_(background ? Color.clear);
        };
        momentary = { |text, rect, callback, colour|
            Button(w, rect).font_(Font("DejaVu Sans Mono", 11, true))
                .states_([[text, colours[\black], colour ? colours[\ash]]])
                .action_({ callback.value });
        };

        paletteForScene = {
            var scene;
            scene = ~ism[\scene] ? \vacant;
            if([\rush, \falseClub, \false_club, \club, \fracture].includes(scene)) {
                [Color(0.31, 0.08, 0.32), Color(0.69, 0.32, 0.25), colours[\chlorine]]
            } {
                if([\phone, \phoneCorridor, \phone_corridor, \suspension].includes(scene)) {
                    [Color(0.05, 0.25, 0.27), Color(0.16, 0.40, 0.35), Color(0.60, 0.76, 0.89)]
                } {
                    [Color(0.15, 0.11, 0.30), Color(0.38, 0.25, 0.45), colours[\chlorine]]
                }
            }
        };

        art = UserView(w, Rect(0, 0, 1200, 660)).background_(colours[\black]);
        ~ism[\guiArt] = art;
        art.canFocus = false;
        art.drawFunc = {
            var palette, phase, scene, block, bevel, glyph, p, height, xx, yy;
            palette = paletteForScene.value;
            phase = (~ism[\visualFrame] ? 0) * 0.13;
            scene = (~ism[\scene] ? \vacant).asString;
            block = { |rect, colour|
                Pen.fillColor = colour;
                Pen.fillRect(rect);
            };
            bevel = { |rect, dark, light|
                Pen.strokeColor = light;
                Pen.width = 2;
                Pen.moveTo(Point(rect.left, rect.bottom));
                Pen.lineTo(Point(rect.left, rect.top));
                Pen.lineTo(Point(rect.right, rect.top));
                Pen.stroke;
                Pen.strokeColor = dark;
                Pen.moveTo(Point(rect.right, rect.top));
                Pen.lineTo(Point(rect.right, rect.bottom));
                Pen.lineTo(Point(rect.left, rect.bottom));
                Pen.stroke;
            };
            glyph = { |x, y, scale, colour|
                Pen.strokeColor = colour;
                Pen.width = 1.6;
                Pen.moveTo(Point(x, y + (scale * 1.0)));
                Pen.lineTo(Point(x + (scale * 0.45), y));
                Pen.lineTo(Point(x + scale, y + (scale * 0.55)));
                Pen.lineTo(Point(x + (scale * 0.30), y + (scale * 0.70)));
                Pen.lineTo(Point(x + (scale * 0.75), y + (scale * 1.25)));
                Pen.stroke;
                Pen.strokeRect(Rect(x + (scale * 0.20), y + (scale * 0.25), scale * 0.22, scale * 0.28));
            };

            block.value(Rect(0, 0, 1200, 660), colours[\black]);
            block.value(Rect(8, 8, 1184, 108), colours[\concrete]);
            bevel.value(Rect(8, 8, 1184, 108), Color.black, colours[\paper]);
            block.value(Rect(14, 14, 1172, 26), colours[\violet]);
            block.value(Rect(20, 53, 1160, 51), colours[\chlorine]);
            block.value(Rect(20, 100, 1160, 4), colours[\rust]);

            // Dusk and vertical compression strips: a fictional empty town.
            26.do { |i|
                p = i / 25;
                block.value(Rect(12, 126 + (i * 4), 1176, 4), palette[0].blend(palette[1], p));
            };
            15.do { |i|
                xx = 36 + (i * 79);
                height = 31 + ((i * 47) % 55);
                block.value(Rect(xx, 231 - height, 57, height), Color(0.17, 0.18, 0.18));
                block.value(Rect(xx + 4, 233 - height, 50, 3), colours[\ash]);
                6.do { |floor|
                    5.do { |column|
                        if((floor * 5 + column + i) % 4 == 0) {
                            block.value(Rect(xx + 7 + (column * 9), 239 - height + (floor * 9), 4, 4), Color(0.54, 0.64, 0.32));
                        };
                    };
                };
            };
            // Forest needles, telephone poles, and dead satellite dishes.
            55.do { |i|
                xx = (i * 73) % 1194;
                height = 12 + ((i * 37) % 31);
                Pen.fillColor = Color(0.035, 0.095, 0.073);
                Pen.moveTo(Point(xx, 235 - height));
                Pen.lineTo(Point(xx + 10, 236));
                Pen.lineTo(Point(xx - 10, 236));
                Pen.lineTo(Point(xx, 235 - height));
                Pen.fill;
            };
            Pen.strokeColor = colours[\ash];
            Pen.width = 1;
            [202, 873, 1096].do { |pole|
                Pen.moveTo(Point(pole, 224)); Pen.lineTo(Point(pole, 160));
                Pen.moveTo(Point(pole - 12, 168)); Pen.lineTo(Point(pole + 12, 168));
                Pen.stroke;
            };
            Pen.moveTo(Point(202, 168)); Pen.lineTo(Point(535, 184));
            Pen.lineTo(Point(873, 168)); Pen.lineTo(Point(1096, 168)); Pen.stroke;
            Pen.strokeOval(Rect(917, 143, 24, 12));
            Pen.moveTo(Point(929, 154)); Pen.lineTo(Point(925, 174)); Pen.stroke;

            // Rough modular panels and obsolete desktop bevels.
            [Rect(16, 249, 570, 296), Rect(614, 249, 570, 296)].do { |panel|
                block.value(panel, Color(0.20, 0.19, 0.23));
                bevel.value(panel, Color.black, colours[\ash]);
            };
            10.do { |i|
                xx = if(i < 5) { 35 + (i * 109) } { 633 + ((i - 5) * 109) };
                block.value(Rect(xx - 1, 279, 99, 207), Color(0.10, 0.095, 0.14));
                bevel.value(Rect(xx - 1, 279, 99, 207), Color.black, Color(0.34, 0.31, 0.37));
                9.do { |tick|
                    yy = 304 + (tick * 17);
                    Pen.strokeColor = if(tick % 2 == 0) { colours[\ash] } { Color(0.34, 0.34, 0.33) };
                    Pen.moveTo(Point(xx + 14, yy)); Pen.lineTo(Point(xx + 24, yy));
                    Pen.moveTo(Point(xx + 68, yy)); Pen.lineTo(Point(xx + 78, yy)); Pen.stroke;
                };
                glyph.value(xx + 75, 466, 8, palette[2]);
            };

            // Low-rate synthetic trace. It visualizes state, not audio metering.
            block.value(Rect(21, 552, 1157, 32), Color(0.02, 0.07, 0.06));
            Pen.strokeColor = palette[2].alpha_(0.65);
            Pen.width = 1;
            390.do { |i|
                xx = 24 + (i * 2.94);
                yy = 568 + ((((i * 0.11 + phase).sin * 7) + ((i * 0.37).sin * 3))
                    * if(~ism[\running] ? false) { 1 } { 0.18 });
                if(i == 0) { Pen.moveTo(Point(xx, yy)) } { Pen.lineTo(Point(xx, yy)) };
            };
            Pen.stroke;
            5.do { |i| glyph.value(590, 287 + (i * 43), 10, colours[\violet].blend(colours[\chlorine], i / 6)) };

            // Static damage only: no strobing or hostile flicker.
            21.do { |i|
                yy = 127 + (i * 5);
                block.value(Rect(12, yy, 1176, 1), Color(0.03, 0.02, 0.07, 0.16));
            };
            9.do { |i|
                xx = (i * 193 + 87) % 1140;
                block.value(Rect(xx, 131 + ((i * 29) % 84), 24 + ((i * 7) % 39), 3), Color(0.50, 0.55, 0.37, 0.19));
            };
            block.value(Rect(22, 630, 1155, 20), Color(0.10, 0.12, 0.08));
        };

        makeText.value("[ A Z E R / 09 ]  ::  EMPTY TOWN TRANSMISSION  ::  FORUM CACHE 2001", Rect(23, 16, 1110, 22), tinyFont, colours[\paper]);
        makeText.value("ILLEGAL SUPERCOLLIDER YABUJINSLOP MACHINE", Rect(30, 59, 1140, 33), Font("DejaVu Sans", 26, true), colours[\black]);
        makeText.value("NO SIGNAL / THE ANGELS ARE BUSY", Rect(29, 105, 710, 16), tinyFont, colours[\paper]);
        makeText.value("/// 8888 : THE LINE IS STILL OPEN ///", Rect(830, 105, 350, 16), tinyFont, colours[\paper]);
        makeText.value("g h o s t   c i t y   /   0 0 4", Rect(33, 132, 320, 17), tinyFont, colours[\paper]);
        makeText.value("YOU HAVE 0 NEW FRIENDS", Rect(931, 207, 230, 20), tinyFont, colours[\chlorine], Color(0.09, 0.04, 0.12));
        makeText.value("I / THE APARTMENT HAS NO FLOOR", Rect(30, 255, 540, 20), tinyFont, colours[\chlorine]);
        makeText.value("II / SOMEBODY KEPT THE RECEIPT", Rect(628, 255, 540, 20), tinyFont, colours[\turquoise]);

        ~ism[\sliderViews] = Array.fill(10, { |i|
            var x, slider;
            x = if(i < 5) { 35 + (i * 109) } { 633 + ((i - 5) * 109) };
            sliderLabels[i] = makeText.value(sliderNames[i], Rect(x + 2, 283, 92, 23), labelFont, colours[\paper]);
            sliderLabels[i].align = \center;
            makeText.value((i + 1).asString.padLeft(2, "0"), Rect(x + 6, 310, 23, 16), tinyFont, colours[\ash]);
            slider = Slider(w, Rect(x + 33, 315, 27, 137))
                .orientation_(\vertical).background_(Color(0.36, 0.31, 0.43))
                .knobColor_(colours[\chlorine]).value_((~ism[\sliders] ? Array.fill(10, 0.5))[i]);
            slider.action = { |view|
                if(~ism[\setSlider].notNil) { ~ism[\setSlider].value(i, view.value) };
                sliderNumbers[i].string = (view.value * 100).round.asInteger.asString.padLeft(3, "0");
            };
            sliderNumbers[i] = makeText.value("000", Rect(x + 25, 459, 42, 21), tinyFont, colours[\chlorine]);
            sliderNumbers[i].align = \center;
            slider;
        });

        ~ism[\switchViews] = Array.fill(10, { |i|
            var x, switch;
            x = if(i < 5) { 35 + (i * 109) } { 633 + ((i - 5) * 109) };
            switch = Button(w, Rect(x, 501, 98, 32)).font_(labelFont)
                .states_([
                    [switchNames[i] ++ " .", colours[\paper], Color(0.29, 0.25, 0.33)],
                    [switchNames[i] ++ " *", colours[\black], colours[\chlorine]]
                ]).value_((~ism[\switches] ? Array.fill(10, 0))[i]);
            switch.action = { |view|
                if(~ism[\setSwitch].notNil) { ~ism[\setSwitch].value(i, view.value) };
            };
            switchLabels[i] = switch;
            switch;
        });

        sceneText = makeText.value("[ VACANT ]", Rect(36, 590, 260, 20), Font("DejaVu Sans Mono", 12, true), colours[\chlorine]);
        seedText = makeText.value("SEED ?", Rect(296, 590, 176, 20), tinyFont, colours[\ash]);
        status = makeText.value("WAITING FOR THE SERVER", Rect(480, 590, 699, 20), tinyFont, colours[\paper]);

        momentary.value("START", Rect(25, 613, 73, 26), { if(~ism[\start].notNil) { ~ism[\start].value } }, colours[\chlorine]);
        momentary.value("STOP", Rect(103, 613, 70, 26), { if(~ism[\stop].notNil) { ~ism[\stop].value } });
        momentary.value("PANIC", Rect(178, 613, 74, 26), { if(~ism[\panic].notNil) { ~ism[\panic].value } }, colours[\rust]);
        momentary.value("RESEED", Rect(257, 613, 81, 26), { if(~ism[\reseed].notNil) { ~ism[\reseed].value } });
        momentary.value("SAVE", Rect(343, 613, 65, 26), {
            Dialog.savePanel({ |path| if(path.notNil and: { ~ism[\savePreset].notNil }) { ~ism[\savePreset].value(path) } });
        });
        momentary.value("LOAD", Rect(413, 613, 65, 26), {
            Dialog.openPanel({ |path| if(path.notNil and: { ~ism[\loadPreset].notNil }) { ~ism[\loadPreset].value(path) } });
        });
        momentary.value("WAV / 90s", Rect(483, 613, 104, 26), {
            Dialog.savePanel({ |path|
                if(path.notNil and: { ~ism[\export].notNil }) {
                    if(path.endsWith(".wav").not) { path = path ++ ".wav" };
                    ~ism[\export].value(path, 90);
                };
            });
        }, colours[\turquoise]);

        presetMenu = PopUpMenu(w, Rect(596, 613, 284, 26))
            .items_(~ism[\presetNames] ? ["Balanced", "Sparse Haunted", "Corrupted Club", "Severe Fracture"])
            .font_(Font("DejaVu Sans", 11)).background_(colours[\ash]);
        presetMenu.action = { |menu|
            if(~ism[\applyPreset].notNil) { ~ism[\applyPreset].value(menu.items[menu.value]) };
        };
        ~ism[\presetMenu] = presetMenu;

        closeLegend = {
            if(~ism[\legendWindow].notNil) { ~ism[\legendWindow].close; ~ism[\legendWindow] = nil };
        };
        showLegend = {
            var legend, notes;
            if(~ism[\legendWindow].notNil) { ~ism[\legendWindow].front } {
                legend = Window("The receipt / control legend", Rect(130, 90, 890, 610));
                legend.background = colours[\black];
                ~ism[\legendWindow] = legend;
                notes = "ILLEGAL SUPERCOLLIDER YABUJINSLOP MACHINE\n\n"
                    ++ "These labels are invented Azeroy-inspired words; no authentic translations are claimed.\n"
                    ++ "Ten sliders are shared musical/DSP macros. Ten switches permit behavior families.\n"
                    ++ "A switch permits events; it need not make the event happen continuously.\n\n"
                    ++ "SLIDERS / LOW TO HIGH\n\n"
                    ++ sliderHelp.join("\n\n") ++ "\n\nSWITCHES / ENABLED\n\n"
                    ++ switchHelp.join("\n\n")
                    ++ "\n\nF1: this receipt. Space: start/stop. Escape: panic.\n"
                    ++ "Aa changes label glyphs to ASCII for fonts that lack the decorative letters.\n"
                    ++ "The moving trace follows the control state.\n"
                    ++ "SAVE/LOAD store controls and seed; RESEED preserves the controls. WAV exports 90 seconds.\n"
                    ++ "See docs/CONTROL_MAP.md for the final parameter bounds and implementation details.";
                TextView(legend, Rect(12, 12, 866, 586)).string_(notes)
                    .font_(Font("DejaVu Sans Mono", 12)).stringColor_(colours[\paper])
                    .background_(Color(0.09, 0.07, 0.12)).editable_(false).resize_(5);
                legend.onClose = { ~ism[\legendWindow] = nil };
                legend.front;
            };
        };
        ~ism[\showLegend] = showLegend;
        legendButton = momentary.value("F1 / RECEIPT", Rect(889, 613, 145, 26), showLegend, colours[\violet].blend(colours[\paper], 0.5));

        updateNames = {
            var sliders, switches;
            sliders = if(~ism[\guiAscii]) { sliderASCII } { sliderNames };
            switches = if(~ism[\guiAscii]) { switchASCII } { switchNames };
            10.do { |i|
                sliderLabels[i].string = sliders[i];
                switchLabels[i].states = [
                    [switches[i] ++ " .", colours[\paper], Color(0.29, 0.25, 0.33)],
                    [switches[i] ++ " *", colours[\black], colours[\chlorine]]
                ];
            };
        };
        asciiButton = momentary.value("Aa / GLYPH", Rect(1043, 613, 133, 26), {
            ~ism[\guiAscii] = ~ism[\guiAscii].not;
            updateNames.value;
        });
        makeText.value("A SYNTHETIC TOWN / ORIGINAL SOUNDS / NO ONE LIVES HERE", Rect(30, 640, 1144, 16), Font("DejaVu Sans Mono", 9), colours[\ash]);

        refresh = {
            {
                if(w.isClosed.not) {
                    10.do { |i|
                        ~ism[\sliderViews][i].value = (~ism[\sliders] ? Array.fill(10, 0.5))[i];
                        sliderNumbers[i].string = ((~ism[\sliders] ? Array.fill(10, 0.5))[i] * 100).round.asInteger.asString.padLeft(3, "0");
                        ~ism[\switchViews][i].value = (~ism[\switches] ? Array.fill(10, 0))[i];
                    };
                    seedText.string = "SEED " ++ (~ism[\seed] ? 0).asString;
                    sceneText.string = "[ " ++ (~ism[\scene] ? \vacant).asString.toUpper ++ " ]";
                    status.string = (~ism[\status] ? "READY").asString;
                    status.stringColor = if(~ism[\running] ? false) { colours[\chlorine] } { colours[\paper] };
                    art.refresh;
                };
            }.defer;
        };
        ~ism[\refreshGUI] = refresh;
        w.view.keyDownAction = { |view, char, modifiers, unicode, keycode, key|
            if(key == 16777264) { showLegend.value };
            if(key == 16777216) { if(~ism[\panic].notNil) { ~ism[\panic].value } };
            if(unicode == 32) {
                if(~ism[\running] ? false) {
                    if(~ism[\stop].notNil) { ~ism[\stop].value };
                } {
                    if(~ism[\start].notNil) { ~ism[\start].value };
                };
            };
        };
        w.onClose = {
            if(~ism[\guiRoutine].notNil) { ~ism[\guiRoutine].stop; ~ism[\guiRoutine] = nil };
            closeLegend.value;
            ~ism[\window] = nil;
            ~ism[\guiArt] = nil;
            if(~ism[\close].notNil) { ~ism[\close].value };
        };
        updateNames.value;
        refresh.value;
        w.front;
        ~ism[\guiRoutine] = Routine({
            while({ w.isClosed.not }, {
                ~ism[\visualFrame] = (~ism[\visualFrame] ? 0) + 1;
                refresh.value;
                0.20.wait;
            });
        }).play(AppClock);
        w;
    };
};
)
