.PHONY: default clean

default: rev18.d64

rev18.d64: rev18.prg multifx.prg
	c1541 -format "rev18,+a" d64 rev18.d64
	c1541 -attach rev18.d64 \
		-write rev18.prg "rev18" \
		-write multifx.prg "multifx"

rev18.prg: rev18.asm
	ka rev18.asm
multifx.prg: multifx.asm
	ka multifx.asm

clean:
	rm -f *.prg
