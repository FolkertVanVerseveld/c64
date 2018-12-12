.PHONY: default clean

default: concept

concept: concept.c
	gcc -std=gnu99 -Wall -Wextra -pedantic $(shell pkg-config --cflags gl sdl2) -o concept concept.c $(shell pkg-config --libs gl sdl2) -lSDL2_image -lm

clean:
	rm -f concept *.o
