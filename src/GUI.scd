/*
ILLEGAL SUPERCOLLIDER YABUJINSLOP MACHINE / LIQUID CACHE 02
Original procedural chrome artwork. Native Qt controls; no fonts/plugins/assets required.
The inscriptions are invented Azeroy-inspired words, not translations.
*/
(
~ism[\makeGUI] = {
    var w, art, status, seedText, sceneText, vocalCaption, sliderNames, sliderASCII, switchNames, switchASCII;
    var sliderLabels, sliderNumbers, switchLabels, colours, labelFont, tinyFont, makeText;
    var momentary, showLegend, paletteForScene, updateNames, presetMenu, sliderHelp, switchHelp;
    var refresh, closeLegend, sliderRects, switchRects, buttonDecor, pearl, capsule, orbit, star;
    var switchStyle, available, fitScale, fitBounds;

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
        "S07 AEZRI: spoken phrase frequency, cutoff sensitivity, pitch drift, and artifact blend. Low settings leave long absences; high settings allow more messages and deeper spectral movement. ZHUN enables the phrases.",
        "S08 SHOR: bandwidth decay, dust/noise, slow wow/flutter, and high-frequency damping. Also closes the vocal phrase bandwidth.",
        "S09 UZH: percussion sparsity, dropout probability, scene length, and negative space. Busy surfaces become interrupted architecture.",
        "S10 YOR: reverb, pitch-linked resonance, stereo width, and pad envelopes. Small rooms become implausible distant landscapes."
    ];
    switchHelp = [
        "T01 AEKRA: permits brief hardstyle eruptions, kick variants, accent changes, and bass following.",
        "T02 ZHUN: permits occasional complete spoken phrases. They arrive as messages with quiet gaps between them, rather than a continuous vocal bed. AEZRI controls frequency and spectral sensitivity.",
        "T03 VAESH: permits reversed samples, reversed envelopes, and reverse-prelude transitions.",
        "T04 NOZA: enables phone-band coloration, notification motifs, short slap echoes, and telephone filtering of spoken phrases.",
        "T05 DZYR: permits coordinated drum/melody stutters and effect bursts.",
        "T06 UZHA: permits tape-collapse interventions: slowing, falling pitch, narrowed bandwidth, and recovery.",
        "T07 KAER: enables unstable tuning, inharmonic timbres, and harmonic substitutions.",
        "T08 THON: permits bounded feedback echoes, irregular delay ratios, and tail-focused transitions.",
        "T09 AYZ: remembers motif/rhythm fragments and biases transformed future returns.",
        "T10 SHAEL: biases ruptures, negative space, dropout shapes, and unusual recovery grammar."
    ];
    colours = (
        black: Color(0.024, 0.020, 0.075), ink: Color(0.07, 0.055, 0.15),
        cyan: Color(0.30, 0.96, 1.00), violet: Color(0.60, 0.36, 1.00),
        pink: Color(1.00, 0.48, 0.83), acid: Color(0.81, 1.00, 0.42),
        pearl: Color(0.91, 0.94, 1.00), ash: Color(0.54, 0.56, 0.72),
        chrome: Color(0.44, 0.50, 0.72), rust: Color(1.00, 0.36, 0.49)
    );
    labelFont = Font("DejaVu Sans", 14, true);
    tinyFont = Font("DejaVu Sans Mono", 10);
    ~ism[\guiAscii] = ~ism[\guiAscii] ? false;
    ~ism[\visualFrame] = 0;
    sliderLabels = Array.newClear(10);
    sliderNumbers = Array.newClear(10);
    switchLabels = Array.newClear(10);
    buttonDecor = List.new;

    // The controls follow two broken arcs; their interaction is still ordinary native Qt.
    sliderRects = [
        Rect(80, 269, 22, 169), Rect(169, 218, 22, 192), Rect(270, 181, 22, 180),
        Rect(367, 224, 22, 168), Rect(427, 347, 22, 148),
        Rect(769, 342, 22, 151), Rect(830, 222, 22, 170), Rect(927, 183, 22, 180),
        Rect(1028, 218, 22, 192), Rect(1117, 269, 22, 169)
    ];
    switchRects = [
        Rect(46, 506, 102, 39), Rect(170, 474, 102, 39), Rect(282, 480, 102, 39),
        Rect(370, 550, 102, 39), Rect(477, 599, 102, 39), Rect(621, 599, 102, 39),
        Rect(731, 550, 102, 39), Rect(816, 480, 102, 39), Rect(928, 474, 102, 39),
        Rect(1052, 506, 102, 39)
    ];

    if(~ism[\window].notNil) { ~ism[\window].front } {
        // Fit laptops and smaller displays without separating widgets from their artwork.
        available = Window.availableBounds;
        fitScale = ((available.width - 40).max(1) / 1200)
            .min((available.height - 60).max(1) / 760).min(1);
        fitBounds = Rect(0, 0, (1200 * fitScale).floor, (760 * fitScale).floor).center_(available.center);
        ~ism[\guiScale] = fitScale;
        ~ism[\guiAvailableBounds] = available;
        w = Window("ILLEGAL SUPERCOLLIDER YABUJINSLOP MACHINE", fitBounds, false);
        w.background = colours[\black];
        ~ism[\window] = w;
        makeText = { |text, rect, font, colour|
            StaticText(w, rect).string_(text).font_(font ? tinyFont)
                .stringColor_(colour ? colours[\pearl]).background_(Color.clear);
        };
        // QcButton paints its own states. Transparent state backgrounds reveal the capsule
        // drawing beneath it while keeping keyboard navigation, labels and native hit areas.
        switchStyle = "QPushButton { background: transparent; border: none; }";
        momentary = { |text, rect, callback, colour|
            var button;
            buttonDecor.add([rect, colour ? colours[\chrome]]);
            button = Button(w, rect).font_(Font("DejaVu Sans Mono", 10, true))
                .states_([[text, colour ? colours[\pearl], Color.clear]])
                .action_({ callback.value });
            button.setProperty(\styleSheet, switchStyle);
            button;
        };
        paletteForScene = {
            var scene;
            scene = ~ism[\scene] ? \vacant;
            if([\rush, \falseClub, \false_club, \club, \fracture].includes(scene)) {
                [colours[\pink], colours[\acid], colours[\violet]]
            } {
                if([\phone, \phoneCorridor, \phone_corridor, \suspension].includes(scene)) {
                    [colours[\cyan], colours[\pearl], colours[\violet]]
                } {
                    [colours[\violet], colours[\pink], colours[\cyan]]
                }
            }
        };

        art = UserView(w, Rect(0, 0, 1200, 760)).background_(colours[\black]);
        ~ism[\guiArt] = art;
        art.canFocus = false;
        art.drawFunc = {
            var palette, phase, playing, chromatic, value, rect, glow, angle, radius, x, y;
            palette = paletteForScene.value;
            playing = ~ism[\running] ? false;
            phase = (~ism[\visualFrame] ? 0) * 0.025;
            Pen.smoothing = true;
            Pen.scale(fitScale, fitScale);
            // An inky web-cache sky with slow opal light, rather than desktop panel banks.
            Pen.addRect(Rect(0, 0, 1200, 760));
            Pen.fillAxialGradient(Point(80, 0), Point(1000, 760), Color(0.08, 0.045, 0.19), colours[\black]);
            Pen.addOval(Rect(120, 125, 960, 580));
            Pen.fillRadialGradient(Point(600, 355), Point(600, 380), 30, 530,
                Color(0.31, 0.15, 0.42, 0.31), Color(0.03, 0.025, 0.08, 0));

            star = { |xx, yy, size, colour|
                Pen.strokeColor = colour;
                Pen.width = 0.8;
                Pen.moveTo(Point(xx - size, yy)); Pen.lineTo(Point(xx + size, yy));
                Pen.moveTo(Point(xx, yy - size)); Pen.lineTo(Point(xx, yy + size));
                Pen.stroke;
                Pen.fillColor = colour;
                Pen.fillOval(Rect(xx - 1, yy - 1, 2, 2));
            };
            87.do { |i|
                x = ((i * 193) + 17) % 1180;
                y = ((i * 89) + 31) % 637;
                star.value(x, y, if(i % 13 == 0) { 4 } { 1.1 }, colours[\pearl].copy.alpha_(0.10 + ((i % 5) * 0.035)));
            };

            // Chrome filaments. Tilted elliptical orbits join independent control islands.
            orbit = { |centre, rx, ry, rotation, colour, weight|
                Pen.use {
                    Pen.translate(centre.x, centre.y);
                    Pen.rotate(rotation);
                    Pen.strokeColor = Color(0.005, 0.005, 0.02, 0.85);
                    Pen.width = weight + 4;
                    Pen.strokeOval(Rect(rx.neg, ry.neg, rx * 2, ry * 2));
                    Pen.strokeColor = colour.copy.alpha_(0.34);
                    Pen.width = weight;
                    Pen.strokeOval(Rect(rx.neg, ry.neg, rx * 2, ry * 2));
                    Pen.strokeColor = colours[\pearl].copy.alpha_(0.55);
                    Pen.width = 0.6;
                    Pen.strokeOval(Rect(rx.neg, ry.neg - 1, rx * 2, ry * 2));
                };
            };
            orbit.value(Point(603, 389), 496, 159, -0.13, colours[\violet], 5);
            orbit.value(Point(593, 378), 417, 244, 0.18, colours[\cyan], 2);
            orbit.value(Point(592, 382), 286, 300, -0.55, colours[\pink], 1);
            orbit.value(Point(601, 387), 252, 107, 0.59, colours[\pearl], 8);

            // A distant fictional apartment horizon dissolves into wireframes below the orbit.
            28.do { |i|
                x = (i * 47) - 22;
                y = 574 - ((i * 29) % 43);
                Pen.strokeColor = Color(0.42, 0.38, 0.65, 0.12);
                Pen.width = 0.7;
                Pen.strokeRect(Rect(x, y, 34, 631 - y));
                5.do { |floor|
                    Pen.moveTo(Point(x, y + 8 + (floor * 11)));
                    Pen.lineTo(Point(x + 34, y + 8 + (floor * 11)));
                };
                Pen.stroke;
            };
            11.do { |i|
                y = 623 + (i.squared * 0.38);
                Pen.strokeColor = Color(0.42, 0.38, 0.65, 0.11);
                Pen.width = 0.7;
                Pen.moveTo(Point(18, y)); Pen.lineTo(Point(1182, y)); Pen.stroke;
            };

            // The central object has a deliberately asymmetric liquid outline.
            pearl = {
                Pen.moveTo(Point(586, 235));
                Pen.curveTo(Point(729, 350), Point(699, 203), Point(746, 269));
                Pen.curveTo(Point(686, 508), Point(714, 422), Point(747, 451));
                Pen.curveTo(Point(585, 565), Point(662, 584), Point(618, 585));
                Pen.curveTo(Point(480, 459), Point(523, 531), Point(457, 518));
                Pen.curveTo(Point(500, 318), Point(464, 391), Point(467, 351));
                Pen.curveTo(Point(586, 235), Point(547, 284), Point(525, 251));
            };
            // Quiet halo; motion changes the detail, never the whole screen brightness.
            Pen.addOval(Rect(444, 214, 330, 379));
            Pen.fillRadialGradient(Point(609, 401), Point(609, 401), 83, 213,
                palette[0].copy.alpha_(0.18), palette[0].copy.alpha_(0));
            pearl.value;
            Pen.fillRadialGradient(Point(550, 295), Point(595, 392), 3, 219,
                Color(0.97, 0.96, 1), Color(0.17, 0.17, 0.31));
            pearl.value;
            Pen.strokeColor = colours[\pearl].copy.alpha_(0.88);
            Pen.width = 1.2; Pen.stroke;
            // Nested stretched membranes and liquid metal refraction lines.
            17.do { |i|
                Pen.strokeColor = colours[\cyan].blend(colours[\pink], i / 16).copy.alpha_(0.22 + ((i % 3) * 0.06));
                Pen.width = if(i % 4 == 0) { 2.5 } { 0.7 };
                Pen.moveTo(Point(510 + (i * 2.9), 305 + (i * 5.1)));
                Pen.curveTo(Point(637 + (i * 1.8), 518 - (i * 1.4)),
                    Point(680 - (i * 1.9), 235 + (i * 7)), Point(418 + (i * 12), 488 - (i * 3.9)));
                Pen.stroke;
            };
            Pen.strokeColor = Color(1, 1, 1, 0.73); Pen.width = 7;
            Pen.moveTo(Point(541, 271));
            Pen.curveTo(Point(685, 285), Point(575, 233), Point(653, 229)); Pen.stroke;
            Pen.strokeColor = colours[\cyan].copy.alpha_(0.66); Pen.width = 3;
            Pen.moveTo(Point(701, 383));
            Pen.curveTo(Point(632, 537), Point(715, 472), Point(717, 493)); Pen.stroke;
            Pen.strokeColor = Color(1, 1, 1, 0.30); Pen.width = 12;
            Pen.moveTo(Point(502, 351));
            Pen.curveTo(Point(545, 492), Point(491, 414), Point(493, 463)); Pen.stroke;

            // Orbital eye / transmission aperture, with a seeded-looking state trace.
            Pen.addOval(Rect(528, 344, 146, 98));
            Pen.fillAxialGradient(Point(580, 344), Point(580, 442), Color(0.20, 0.16, 0.31), colours[\black]);
            Pen.strokeColor = colours[\pearl].copy.alpha_(0.67); Pen.width = 1;
            Pen.strokeOval(Rect(528, 344, 146, 98));
            Pen.use {
                Pen.addOval(Rect(532, 348, 138, 90)); Pen.clip;
                Pen.strokeColor = palette[1].copy.alpha_(0.75);
                Pen.width = 1.15;
                138.do { |i|
                    x = 532 + i;
                    y = 393 + (((((i * 0.12) + phase).sin * 15) + (((i * 0.41) - phase).sin * 5))
                        * if(playing) { 1 } { 0.16 });
                    if(i == 0) { Pen.moveTo(Point(x, y)) } { Pen.lineTo(Point(x, y)) };
                };
                Pen.stroke;
                11.do { |i|
                    Pen.strokeColor = colours[\cyan].copy.alpha_(0.06); Pen.width = 1;
                    Pen.moveTo(Point(532, 351 + (i * 8))); Pen.lineTo(Point(670, 351 + (i * 8))); Pen.stroke;
                };
            };
            star.value(711, 293, 14, colours[\pearl].copy.alpha_(0.88));
            star.value(490, 456, 9, colours[\cyan].copy.alpha_(0.62));
            star.value(698, 512, 7, colours[\pink].copy.alpha_(0.74));

            // Each slider is a narrow native groove embedded in a chrome droplet.
            capsule = { |r, colour, strength|
                Pen.addRoundedRect(r, r.width * 0.47, r.width * 0.47);
                Pen.fillAxialGradient(Point(r.left, r.top), Point(r.right, r.bottom),
                    Color(0.28, 0.29, 0.43, 0.90), colours[\ink].copy.alpha_(0.94));
                Pen.addRoundedRect(r, r.width * 0.47, r.width * 0.47);
                Pen.strokeColor = colour.copy.alpha_(strength); Pen.width = 1; Pen.stroke;
                Pen.strokeColor = colours[\pearl].copy.alpha_(0.40); Pen.width = 0.7;
                Pen.moveTo(Point(r.left + 5, r.top + 35));
                Pen.curveTo(Point(r.left + 16, r.top + 6), Point(r.left + 4, r.top + 9), Point(r.left + 13, r.top + 6));
                Pen.stroke;
            };
            sliderRects.do { |r, i|
                chromatic = if(i % 3 == 0) { colours[\cyan] } { if(i % 3 == 1) { colours[\pink] } { colours[\violet] } };
                value = (~ism[\sliders] ? Array.fill(10, 0.5))[i];
                capsule.value(Rect(r.left - 19, r.top - 21, 60, r.height + 59), chromatic, 0.4 + (value * 0.3));
                Pen.fillColor = chromatic.copy.alpha_(0.14 + (value * 0.12));
                Pen.fillOval(Rect(r.left - 11, r.top + ((1 - value) * (r.height - 20)) - 2, 44, 26));
                7.do { |tick|
                    y = r.top + 12 + (tick * ((r.height - 24) / 6));
                    Pen.strokeColor = colours[\pearl].copy.alpha_(0.30);
                    Pen.width = 0.7;
                    Pen.moveTo(Point(r.left - 8, y)); Pen.lineTo(Point(r.left - 4, y));
                    Pen.moveTo(Point(r.right + 4, y)); Pen.lineTo(Point(r.right + 8, y)); Pen.stroke;
                };
            };

            // Latching switches form a broken crescent, never a rectangular rack.
            switchRects.do { |r, i|
                value = (~ism[\switches] ? Array.fill(10, 0))[i];
                glow = if(value == 1) { colours[\cyan] } { colours[\violet] };
                if(value == 1) {
                    Pen.addOval(Rect(r.left - 7, r.top - 5, r.width + 14, r.height + 10));
                    Pen.fillRadialGradient(r.center, r.center, 6, 63, glow.copy.alpha_(0.25), glow.copy.alpha_(0));
                };
                Pen.addOval(r);
                Pen.fillAxialGradient(Point(r.left, r.top), Point(r.left, r.bottom),
                    if(value == 1) { Color(0.13, 0.33, 0.40, 0.95) } { Color(0.19, 0.16, 0.31, 0.94) }, colours[\ink]);
                Pen.strokeColor = glow.copy.alpha_(if(value == 1) { 0.9 } { 0.47 }); Pen.width = 1;
                Pen.strokeOval(r);
                Pen.strokeColor = colours[\pearl].copy.alpha_(0.33); Pen.width = 0.7;
                Pen.moveTo(Point(r.left + 18, r.top + 8));
                Pen.curveTo(Point(r.right - 18, r.top + 8), Point(r.left + 43, r.top + 2), Point(r.right - 42, r.top + 2));
                Pen.stroke;
                Pen.fillColor = glow.copy.alpha_(if(value == 1) { 1 } { 0.35 });
                Pen.fillOval(Rect(r.left + 10, r.top + 17, 4, 4));
                Pen.stringAtPoint("T" ++ (i + 1).asString.padLeft(2, "0"), Point(r.center.x - 10, r.bottom + 3),
                    Font("DejaVu Sans Mono", 8), colours[\ash].copy.alpha_(0.82));
            };

            // A detached rounded dock carries utilities without overpowering the artwork.
            Pen.addRoundedRect(Rect(17, 679, 1166, 59), 29, 29);
            Pen.fillAxialGradient(Point(0, 679), Point(0, 738), Color(0.12, 0.12, 0.23), Color(0.055, 0.05, 0.12));
            Pen.strokeColor = colours[\chrome].copy.alpha_(0.5); Pen.width = 0.8;
            Pen.addRoundedRect(Rect(17, 679, 1166, 59), 29, 29); Pen.stroke;
            buttonDecor.do { |item|
                rect = item[0];
                Pen.addRoundedRect(rect, rect.height / 2, rect.height / 2);
                Pen.fillAxialGradient(Point(rect.left, rect.top), Point(rect.left, rect.bottom),
                    item[1].copy.alpha_(0.14), colours[\ink].copy.alpha_(0.8));
                Pen.strokeColor = item[1].copy.alpha_(0.49); Pen.width = 0.8;
                Pen.addRoundedRect(rect, rect.height / 2, rect.height / 2); Pen.stroke;
            };
            // A small slanted inscription is decoration; the exact full title remains above.
            Pen.use {
                Pen.translate(461, 164); Pen.rotate(-0.10);
                Pen.stringAtPoint("liquid memory / 02", Point(0, 0), Font("DejaVu Sans", 13, false, true), colours[\pink].copy.alpha_(0.75));
            };
        };

        makeText.value("A Z E R / 0002    .    LOST IN THE CACHE    .    VISAGINAS AFTERIMAGE", Rect(43, 18, 1000, 20), tinyFont, colours[\ash]);
        makeText.value("ILLEGAL SUPERCOLLIDER YABUJINSLOP MACHINE", Rect(43, 47, 1134, 43),
            Font("DejaVu Sans", 25, true, true), colours[\pearl]);
        makeText.value("a message arrives / then the line forgets", Rect(45, 98, 643, 20),
            Font("DejaVu Sans Mono", 11), colours[\cyan]);
        makeText.value("NOTHING HERE IS REAL EXCEPT THE DAMAGE", Rect(762, 100, 398, 18),
            Font("DejaVu Sans Mono", 9), colours[\pink]);

        ~ism[\sliderViews] = Array.fill(10, { |i|
            var r, slider, colour;
            r = sliderRects[i];
            colour = if(i % 3 == 0) { colours[\cyan] } { if(i % 3 == 1) { colours[\pink] } { colours[\violet] } };
            sliderLabels[i] = makeText.value(sliderNames[i], Rect(r.left - 34, r.top - 54, 91, 23), labelFont, colours[\pearl]);
            sliderLabels[i].align = \center;
            makeText.value("S" ++ (i + 1).asString.padLeft(2, "0"), Rect(r.left - 12, r.top - 31, 46, 14),
                Font("DejaVu Sans Mono", 8), colour).align_(\center);
            slider = Slider(w, r).orientation_(\vertical).background_(Color(0.018, 0.012, 0.05, 0.35))
                .knobColor_(colour).thumbSize_(14).value_((~ism[\sliders] ? Array.fill(10, 0.5))[i]);
            slider.toolTip = sliderHelp[i];
            slider.action = { |view|
                if(~ism[\setSlider].notNil) { ~ism[\setSlider].value(i, view.value) };
                sliderNumbers[i].string = (view.value * 100).round.asInteger.asString.padLeft(3, "0");
                art.refresh;
            };
            sliderNumbers[i] = makeText.value("000", Rect(r.left - 10, r.bottom + 11, 43, 18), tinyFont, colour);
            sliderNumbers[i].align = \center;
            slider;
        });
        ~ism[\switchViews] = Array.fill(10, { |i|
            var switch;
            switch = Button(w, switchRects[i]).font_(labelFont)
                .states_([[switchNames[i], colours[\pearl], Color.clear], [switchNames[i], colours[\cyan], Color.clear]])
                .value_((~ism[\switches] ? Array.fill(10, 0))[i]);
            switch.setProperty(\styleSheet, switchStyle);
            switch.toolTip = switchHelp[i];
            switch.action = { |view|
                if(~ism[\setSwitch].notNil) { ~ism[\setSwitch].value(i, view.value) };
                art.refresh;
            };
            switchLabels[i] = switch;
            switch;
        });
        sceneText = makeText.value("VACANT", Rect(471, 465, 265, 22), Font("DejaVu Sans Mono", 13, true), colours[\ink]);
        sceneText.align = \center;
        seedText = makeText.value("SEED ?", Rect(518, 493, 167, 19), Font("DejaVu Sans Mono", 9), colours[\ink]);
        seedText.align = \center;
        vocalCaption = makeText.value("", Rect(475, 573, 252, 21), Font("DejaVu Sans", 9), colours[\pink]);
        vocalCaption.align = \center;
        ~ism[\vocalCaption] = vocalCaption;
        status = makeText.value("WAITING FOR THE SERVER", Rect(248, 651, 710, 18), tinyFont, colours[\pearl]);
        status.align = \center;

        momentary.value("START", Rect(31, 692, 68, 30), { if(~ism[\start].notNil) { ~ism[\start].value } }, colours[\acid]);
        momentary.value("STOP", Rect(106, 692, 64, 30), { if(~ism[\stop].notNil) { ~ism[\stop].value } });
        momentary.value("PANIC", Rect(177, 692, 66, 30), { if(~ism[\panic].notNil) { ~ism[\panic].value } }, colours[\rust]);
        momentary.value("RESEED", Rect(250, 692, 79, 30), { if(~ism[\reseed].notNil) { ~ism[\reseed].value } }, colours[\violet]);
        momentary.value("SAVE", Rect(336, 692, 57, 30), {
            Dialog.savePanel({ |path| if(path.notNil and: { ~ism[\savePreset].notNil }) { ~ism[\savePreset].value(path) } });
        });
        momentary.value("LOAD", Rect(400, 692, 57, 30), {
            Dialog.openPanel({ |path| if(path.notNil and: { ~ism[\loadPreset].notNil }) { ~ism[\loadPreset].value(path) } });
        });
        momentary.value("WAV / 90s", Rect(464, 692, 103, 30), {
            Dialog.savePanel({ |path|
                if(path.notNil and: { ~ism[\export].notNil }) {
                    if(path.endsWith(".wav").not) { path = path ++ ".wav" };
                    ~ism[\export].value(path, 90);
                };
            });
        }, colours[\cyan]);
        presetMenu = PopUpMenu(w, Rect(576, 696, 240, 24))
            .items_(~ism[\presetNames] ? ["Balanced", "Sparse Haunted", "Corrupted Club", "Severe Fracture"])
            .font_(Font("DejaVu Sans", 10)).background_(colours[\ink]).stringColor_(colours[\pearl]);
        presetMenu.setProperty(\styleSheet,
            "QComboBox { border: 1px solid #646384; border-radius: 12px; padding-left: 10px; background-color: #211d37; color: #e6e9ff; } QComboBox QAbstractItemView { background-color: #211d37; color: #e6e9ff; selection-background-color: #4b356b; }");
        presetMenu.action = { |menu|
            if(~ism[\applyPreset].notNil) { ~ism[\applyPreset].value(menu.items[menu.value]) };
        };
        ~ism[\presetMenu] = presetMenu;

        closeLegend = {
            if(~ism[\legendWindow].notNil) { ~ism[\legendWindow].close; ~ism[\legendWindow] = nil };
        };
        showLegend = {
            var legend, notes, legendBounds;
            if(~ism[\legendWindow].notNil) { ~ism[\legendWindow].front } {
                legendBounds = Rect(0, 0, 890.min((available.width - 40).max(1)),
                    610.min((available.height - 60).max(1))).center_(available.center);
                legend = Window("The receipt / control legend", legendBounds);
                legend.background = colours[\black];
                ~ism[\legendWindow] = legend;
                notes = "ILLEGAL SUPERCOLLIDER YABUJINSLOP MACHINE\n\n"
                    ++ "The labels are invented Azeroy-inspired words; no authentic translations are claimed.\n"
                    ++ "Ten sliders are shared musical/DSP macros. Ten switches permit behavior families.\n"
                    ++ "A switch permits events; it need not make an event happen continuously.\n\n"
                    ++ "SLIDERS / LOW TO HIGH\n\n" ++ sliderHelp.join("\n\n")
                    ++ "\n\nSWITCHES / ENABLED\n\n" ++ switchHelp.join("\n\n")
                    ++ "\n\nF1: this receipt. Space: start/stop. Escape: panic.\n"
                    ++ "Aa changes label glyphs to ASCII for fonts that lack the decorative letters.\n"
                    ++ "Hover any control to reveal its function. The central trace follows state, not audio level.\n"
                    ++ "SAVE/LOAD store controls and seed; RESEED preserves controls. WAV exports 90 seconds.\n"
                    ++ "Spoken messages: enable ZHUN, then raise AEZRI for more frequent arrivals and stronger spectral movement. SHOR darkens them; NOZA narrows them to telephone bandwidth.\n"
                    ++ "See docs/CONTROL_MAP.md for parameter bounds and implementation details.";
                TextView(legend, Rect(12, 12, legendBounds.width - 24, legendBounds.height - 24)).string_(notes)
                    .font_(Font("DejaVu Sans Mono", 12)).stringColor_(colours[\pearl])
                    .background_(colours[\ink]).editable_(false).resize_(5);
                legend.onClose = { ~ism[\legendWindow] = nil };
                legend.front;
            };
        };
        ~ism[\showLegend] = showLegend;
        momentary.value("F1 / RECEIPT", Rect(828, 692, 175, 30), showLegend, colours[\pink]);
        updateNames = {
            var sliders, switches;
            sliders = if(~ism[\guiAscii]) { sliderASCII } { sliderNames };
            switches = if(~ism[\guiAscii]) { switchASCII } { switchNames };
            10.do { |i|
                sliderLabels[i].string = sliders[i];
                switchLabels[i].states = [
                    [switches[i], colours[\pearl], Color.clear], [switches[i], colours[\cyan], Color.clear]
                ];
            };
        };
        momentary.value("Aa / GLYPH", Rect(1012, 692, 158, 30), {
            ~ism[\guiAscii] = ~ism[\guiAscii].not;
            updateNames.value;
        }, colours[\chrome]);
        makeText.value("a synthetic town / the line is still open / 2000 forever", Rect(346, 743, 711, 13),
            Font("DejaVu Sans Mono", 8), colours[\ash]);

        refresh = {
            {
                if(w.isClosed.not) {
                    10.do { |i|
                        ~ism[\sliderViews][i].value = (~ism[\sliders] ? Array.fill(10, 0.5))[i];
                        sliderNumbers[i].string = ((~ism[\sliders] ? Array.fill(10, 0.5))[i] * 100).round.asInteger.asString.padLeft(3, "0");
                        ~ism[\switchViews][i].value = (~ism[\switches] ? Array.fill(10, 0))[i];
                    };
                    vocalCaption.string = if((~ism[\vocalUntil] ? 0) > Main.elapsedTime) { ~ism[\vocalText] ? "" } { "" };
                    seedText.string = "SEED " ++ (~ism[\seed] ? 0).asString;
                    sceneText.string = (~ism[\scene] ? \vacant).asString.toUpper;
                    status.string = (~ism[\status] ? "READY").asString;
                    status.stringColor = if(~ism[\running] ? false) { colours[\cyan] } { colours[\pearl] };
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
            ~ism[\vocalCaption] = nil;
            if(~ism[\close].notNil) { ~ism[\close].value };
        };
        // Scale once after constructing the logical 1200x760 design. Pen uses the same
        // factor above, so every native hit area stays aligned with its capsule.
        w.view.children.do { |child|
            var rect, font;
            rect = child.bounds;
            child.bounds = Rect(rect.left * fitScale, rect.top * fitScale,
                rect.width * fitScale, rect.height * fitScale);
            font = child.font;
            if(font.notNil and: { font.size.notNil }) {
                child.font = font.copy.size_(font.size * fitScale);
            };
            if(child.isKindOf(Slider)) { child.thumbSize = 14 * fitScale };
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
