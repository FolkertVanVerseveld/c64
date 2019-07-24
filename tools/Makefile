.PHONY: default clean

CC=gcc
CFLAGS=-Wall -Wextra -pedantic -std=gnu99 -g -DDEBUG $(shell pkg-config --cflags ncurses)
LDLIBS=$(shell pkg-config --libs ncurses)

default: diss prgview
diss: diss.o 6510.o
diss.o: diss.c 6510.c 6510.h
prgview: prgview.o 6510.o
prgview.o: prgview.c 6510.c 6510.h
6510.o: 6510.c 6510.h

clean:
	rm -f diss prgview *.o
