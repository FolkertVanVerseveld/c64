.PHONY: default clean

CC=gcc
CFLAGS=-Wall -Wextra -pedantic -std=gnu99 -g -DDEBUG $(shell pkg-config --cflags ncurses)
LDLIBS=$(shell pkg-config --libs ncurses)

default: diss prgview
diss: diss.c
prgview: prgview.c

clean:
	rm -f diss prgview *.o
