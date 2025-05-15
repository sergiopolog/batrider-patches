# **Armed Police Batrider quality of life patches.**

Program ROM patches for Armed Police Batrider (B version only) which add some convenience and functionality.

This is pretty much an adaptation of some of the @zakk4223 's [Quality-of-life patches for Battle Garegga](https://github.com/zakk4223/battle-garegga-patches), but modified to work with Batrider. Thanks a lot for your research and previous work on it! 🍻

Includes:

 - Rank display. Real time display of current game rank.
 - Rank change display: Per-frame display of rank change during the frame. This excludes per-frame rank adjustments and any rank changes due to shooting (normal and option). (*STILL NOT WORKING*)
 - Rank percentage display. It considers 0% the 'lowest' possible Rank value, i.e.: when Difficulty switch is set to 'Easy' and Course selected is 'Normal' or 'Training'.
 - Per frame rank display.
 - Quick Reset: By pressing A + B + C + Start buttons on any of the player control, and you can go directly to the Warning screen at any time. Rank value is reset, too.
 - Fixed the TEXT Test: now palette code could be modified by pressing C button + Joystick directions (same behavior on Battle Bakraid).

Rank and rank change are shown in hexadecimal. Per frame is shown in decimal.

NOTE: Stage Edit DIP switch behavior is modified and now it controls if Rank info should be shown at screen or not. It must be ON for Rank display to appear. Stage EDIT can be selected anyway by pressing A+B buttons while selecting the Course mode.


To-Do:

 - Rank change display: Allow per-frame display of rank change during the frame. This should exclude per-frame rank adjustments and any rank changes due to shooting (normal and option). (*NOT IMPLEMENTED YET*)
 - Reset rank value on a new credit. (*NOT IMPLEMENTED YET. Currently, the Rank is kept between credits, but you can reset it using the Quick-Reset short-cut and start a new credit quickly*)
 - Hide Rank info on the Credits/Ending screens
 

## How to use

Extract any B version rom set (i.e. `batrider`, `batrideru`, `batriderc`, `batriderj` or `batriderk`). Use your favorite IPS patch applier to patch `prg0b.u22` and `prg1b.u23` using the respective IPS files in this repo. `prg0.u22` ROM file is different between existings sets in B version, but only the first byte differs on them, therefore the same `prg0b.u22.ips` should work for any version of `prg0___.u22` ROM file.

MAME will complain about incorrect rom checksums. You can ignore this and/or may need to launch the game directly as an argument, e.g. `./mame batriderj`

Expected hashes after applying patch (for Japan version):

| File          | SHA1                                       |
| :-----------: | :----------------------------------------: |
| **prg0b.u22** | `20ee02ce4bc41c9647bbab145ecf8244824840ba` |
| **prg1b.u23** | `7141586d5ca712ddf4f6aaf00b67a18888b99a54` |


## Source

patch.s contains the assembly source code to recreate this patch.  Use http://john.ccac.rwth-aachen.de:8000/as/ and https://www.mankier.com/1/p2bin to assemble it. You must combine `prg0_____.u22` and `prg1b.u23` into a single interleaved binary. See build.sh for exact command line arguments using various tools.
