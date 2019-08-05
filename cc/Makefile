.PHONY: default run clean

default: petscii.prg snake.prg
petscii.prg: petscii.c
	cc65 -t c64 petscii.c
	ca65 petscii.s
	ld65 -o petscii.prg -t c64 petscii.o c64.lib

snake.prg: snake.c
	cc65 -t c64 snake.c
	ca65 snake.s
	ld65 -o snake.prg -t c64 snake.o c64.lib

run: petscii.prg
	../sock.py p petscii.prg 172.28.1.102

clean:
	rm -f *.prg *.o *.s
