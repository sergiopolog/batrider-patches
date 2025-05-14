#!/bin/sh

interleave --width 1 --output original_combined_batriderj.bin ../mame/roms/batriderj/prg0b.u22.bak ../mame/roms/batrider/prg1b.u23.bak
asl patch.s -i . -n -U -o batrider.o
p2bin batrider.o batrider.bin
rm original_combined_batriderj.bin
rm batrider.o
#split -b 1M batrider.bin batrider
deinterleave batrider.bin prg
rm batrider.bin
#rm batrideraa
#rm batriderab
mv prg.even ../mame/roms/batriderj/prg0b.u22
mv prg.odd ../mame/roms/batrider/prg1b.u23
