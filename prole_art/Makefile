.PHONY: default clean

default: concept sid

concept: concept.c
	gcc -std=gnu99 -Wall -Wextra -pedantic $(shell pkg-config --cflags gl sdl2) -o concept concept.c $(shell pkg-config --libs gl sdl2) -lSDL2_image -lm
sid: sid.c

clean:
	rm -f concept sid *.o
