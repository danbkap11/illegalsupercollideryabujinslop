# Sonic references and optional sample provenance

Research and acquisition date: 2026-10-11. This instrument creates original music.
The named songs are references, and are not included as samples or transcribed
into its motif bank.

## What was verified

The user's `idontwant2go` most likely refers to **。✰302？ionwan2go✰。**.
The unofficial [Gates to Azeroy archive](https://yabujinarchive1.bandcamp.com/album/gates-to-azeroy)
lists that title alongside **Baroque** and **Hardstyle Drill 2009 Nokia Angelz**.
The archive explicitly says it is unofficial and unaffiliated. Its track lengths
(2:27, 2:10, and 2:53 respectively) are archive metadata, not a production analysis.
The [Dismiss Yourself Archive listing](https://dismissyourselfarchive.bandcamp.com/track/yabujin-hardstyle-drill-2009-nokia-angelz-16)
also confirms the longer Nokia Angelz title. Both archives specify all rights
reserved; they provide no redistribution permission for a sample bank.

[Kieran Press-Reynolds' Pitchfork feature](https://pitchfork.com/thepitch/chasing-yabujin-the-artist-who-secretly-shaped-the-underground-sound-of-the-2020s/)
(2025-02-19) describes unstable bright synthetic melody, damaged ocarina-like
timbres, muffled voices, forgotten game landscapes, and the contrast between
sweetness and digital grotesquerie. It also distinguishes the artist's wider
musical world from interchangeable jumpstyle imitations. Those descriptions
motivate the design choices below. They do not establish the exact production
techniques of the three requested songs.

**Evidence limit:** public pages and metadata were inspected, but this cloud pass
did not perform actual listening to the named recordings. No BPM, key, drum-kit
identification, timestamped listening observation, or exact sound patch is
claimed. The supplied WAV demonstrations allow a listener to judge the original
instrument; successful audio analysis is not a substitute for that judgment.

## Translation into an original instrument

| Reference direction | Implementation target |
| --- | --- |
| Naive, damaged synthetic melody | A small recurring minor motif pool; bell/flute voices with instability and occasional harmonic friction |
| Cloud-rap weight beside violent dance energy | Sparse locally convincing rhythms interrupted by brief hardstyle accelerations |
| Mangled voices and distant machinery | Synthesized formants, telephone coloration, small digital/interface accents |
| Deserted virtual landscapes | Long-lived harmonic identity, silence pockets, narrow near-field details against wide tails |
| Corruption as musical structure | Reversals, interruption, irregular phrase lengths, return of remembered material |
| Damaged medium with surviving clarity | Separate digital resolution and spectral/tape wear controls; restrained source levels before limiting |

The slider and switch labels are original invented Azeroy-inspired labels. They
are not authenticated words or translations of the artist's invented language.
The GUI's architecture and glyphs are procedural original artwork. It does not
use album art, artist photos, regional scripts as decoration, or unlicensed
landscape imagery.

## Downloaded sound bank: Concrete Phone Debris

The complete instrument works with stock SuperCollider synthesis. It also ships
**28 selected external sound effects** as short musical accents: metallic and
glass impacts, concrete/wood hits, interface clicks and errors, digital debris,
descending electronic sweeps, and three-tone telephone/game motifs. These add
texture without tying the instrument to a copyrighted drum kit or an API key.

They come from three official, explicitly CC0 Kenney packs:

- [Impact Sounds](https://kenney.nl/assets/impact-sounds): 12 selected impacts.
- [Interface Sounds](https://kenney.nl/assets/interface-sounds): 8 selected interface artifacts.
- [Digital Audio](https://kenney.nl/assets/digital-audio): 8 selected synthetic accents.

Every official page states Creative Commons CC0, and each downloaded ZIP includes
a matching `License.txt`. These original notices are bundled beside the WAVs.
Kenney credit is appreciated but not required by the license.

The selection favors concise source roles suited to this instrument rather than
the largest possible library. No subjective claim that these are the best
available samples is made. Selection used the source categories and objective
format/decoding checks; an available human has not auditioned the source pack in
this session.

The shipped subset totals **1,304,236 bytes**. All WAVs are mono, 44,100 Hz,
16-bit PCM, with durations from 7 ms to 1.48 s. Ogg Vorbis sources were decoded
with FFmpeg into uncompressed WAV and stripped of metadata. The sounds were not
normalized, denoised, equalized, or subjected to additional lossy compression.

[assets/LICENSES.json](../assets/LICENSES.json) records each source page, creator,
license, source archive URL and SHA-256, archive member and SHA-256, transformed
WAV SHA-256, date, format, and intended musical role. This is the authoritative
manifest if bank details change.

The default application never downloads files. To check the included bank:

```sh
python3 tools/fetch_assets.py --verify-only
```

To restore a missing file from the verified source archives:

```sh
python3 tools/fetch_assets.py
```

Restoration requires Python 3.9+ and FFmpeg. Existing modified files are preserved
and reported, not overwritten. HTTPS/TLS verification and pinned archive/member
checksums stay enabled. If the publisher changes an archive or the decoder
produces different WAV bytes, restoration stops for review. Included WAVs remain
the reproducible bank distributed with the instrument.
