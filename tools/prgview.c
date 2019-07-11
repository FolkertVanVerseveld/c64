/* Copyright 2019 Folkert van Verseveld. All rights reserved */

// https://www.c64-wiki.com/wiki/BASIC_token

/*
 * Simple .prg viewer
 */
#include <stdio.h>
#include <string.h>
#include <stdbool.h>
#include <stdint.h>
#include <ctype.h>
#include <ncurses.h>

// max 202 blocks with default memconfig
#define PRG_MAX_SIZE 51712

#define COL_MIN 80
#define ROW_MIN 24

#define CBM64_MEMMAX 65536

unsigned char file[CBM64_MEMMAX], type[CBM64_MEMMAX];
int rows, cols;
uint16_t offset, pos, offset_end;
unsigned filesize;
bool is_prg = false;

const char *HEX = "0123456789ABCDEF", *hex = "0123456789abcdef";
char top[] = "     00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F 0123456789ABCDEF";

void Hw2str(char *str, unsigned v)
{
	str[0] = HEX[(v >> 12) & 0xf];
	str[1] = HEX[(v >> 8) & 0xf];
	str[2] = HEX[(v >> 4) & 0xf];
	str[3] = HEX[v & 0xf];
}

void Hb2str(char *str, int ch)
{
	str[0] = HEX[(ch >> 4) & 0xf];
	str[1] = HEX[ch & 0xf];
}

long b2acs[256] = {
	' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
	' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
	' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
	' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', // 18-1f
	' ', '!', '"', '#', '$', '%', '&', '`',
	'(', ')', '*', '+', ',', '-', '.', '/',
	'0', '1', '2', '3', '4', '5', '6', '7',
	'8', '9', ':', ';', '<', '=', '>', '?', // 38-3f
	'@', 'A', 'B', 'C', 'D', 'E', 'F', 'G',
	'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O',
	'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W',
	'X', 'Y', 'Z', '[', ' ', ']', ' ', ' ', // 58-5f
	' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
	' ', ' ', ' ', ' ', ' ', '\\', '/', ' ',
	' ', ' ', ' ', ' ', '|', ' ', 'X', ' ',
	' ', '|', ' ', '+', ' ', '|', ' ', '\\', // 78-7f
	' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
	' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
	' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
	' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', // 98-9f
	' ', '|', ' ', ' ', ' ', '|', ' ', '|',
	' ', '/', '|', ' ', '.', ' ', ' ', ' ',
	' ', ' ', ' ', ' ', '|', '|', '|', ' ',
	' ', ' ', ' ', '.', '.', ' ', '.', ' ', // b8-bf
	' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
	' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
	' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
	' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', // d8-df
	' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
	' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
	' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
	' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', // f8-ff
};

void b2acs_init(void)
{
	b2acs[0x03] = ACS_LANTERN;
	b2acs[0x05] = ACS_DEGREE;
	b2acs[0x08] = ACS_LANTERN;
	b2acs[0x09] = ACS_LANTERN;
	b2acs[0x0E] = ACS_LANTERN;
	b2acs[0x12] = ACS_LANTERN;
	b2acs[0x1C] = ACS_DEGREE;
	b2acs[0x1E] = ACS_DEGREE;
	b2acs[0x1F] = ACS_DEGREE;
	b2acs[0x5c] = ACS_STERLING;
	b2acs[0x5e] = ACS_UARROW;
	b2acs[0x5f] = ACS_LARROW;
	b2acs[0x60] = ACS_HLINE;
	b2acs[0x61] = ACS_DIAMOND;
	b2acs[0x62] = ACS_VLINE;
	b2acs[0x63] = ACS_HLINE;
	b2acs[0x64] = ACS_S3;
	b2acs[0x65] = ACS_S1;
	b2acs[0x66] = ACS_S7;
	b2acs[0x67] = ACS_VLINE;
	b2acs[0x68] = ACS_VLINE;
	b2acs[0x69] = ACS_URCORNER;
	b2acs[0x6a] = ACS_LLCORNER;
	b2acs[0x6b] = ACS_LRCORNER;
	b2acs[0x6c] = ACS_LLCORNER;
	b2acs[0x6f] = ACS_ULCORNER;
	b2acs[0x70] = ACS_URCORNER;
	b2acs[0x71] = ACS_BULLET;
	b2acs[0x72] = ACS_S7;
	b2acs[0x73] = ACS_DIAMOND;
	b2acs[0x75] = ACS_ULCORNER;
	b2acs[0x77] = ACS_BULLET;
	b2acs[0x78] = ACS_PLMINUS;
	b2acs[0x7a] = ACS_DIAMOND;
	b2acs[0x7c] = ACS_CKBOARD;
	b2acs[0x7E] = ACS_PI;
	b2acs[0x81] = ACS_DEGREE;
	b2acs[0x83] = ACS_LANTERN;
	b2acs[0x8E] = ACS_LANTERN;
	b2acs[0x90] = ACS_DEGREE;
	b2acs[0x92] = ACS_LANTERN;
	b2acs[0x95] = ACS_DEGREE;
	b2acs[0x96] = ACS_DEGREE;
	b2acs[0x97] = ACS_DEGREE;
	b2acs[0x98] = ACS_DEGREE;
	b2acs[0x99] = ACS_DEGREE;
	b2acs[0x9a] = ACS_DEGREE;
	b2acs[0x9b] = ACS_DEGREE;
	b2acs[0x9c] = ACS_DEGREE;
	b2acs[0x9e] = ACS_DEGREE;
	b2acs[0x9f] = ACS_DEGREE;
	b2acs[0xa2] = ACS_HLINE;
	b2acs[0xa3] = ACS_S1;
	b2acs[0xa4] = ACS_S9;
	b2acs[0xa6] = ACS_CKBOARD;
	b2acs[0xa8] = ACS_HLINE;
	b2acs[0xab] = ACS_LTEE;
	b2acs[0xad] = ACS_LLCORNER;
	b2acs[0xae] = ACS_URCORNER;
	b2acs[0xaf] = ACS_S9;
	b2acs[0xb0] = ACS_ULCORNER;
	b2acs[0xb1] = ACS_BTEE;
	b2acs[0xb2] = ACS_TTEE;
	b2acs[0xb3] = ACS_RTEE;
	b2acs[0xb4] = ACS_VLINE;
	b2acs[0xb5] = ACS_VLINE;
	b2acs[0xb6] = ACS_VLINE;
	b2acs[0xb7] = ACS_S1;
	b2acs[0xb8] = ACS_S3;
	b2acs[0xb9] = ACS_S7;
	b2acs[0xba] = ACS_LRCORNER;
	b2acs[0xbd] = ACS_LRCORNER;
	b2acs[0xbf] = ACS_CKBOARD;

	for (int i = 0xc0; i < 0xff; ++i)
		b2acs[i] = b2acs[i - 64];
}

int hex_start_row, hex_last_row;

void display(void)
{
	char buf[80];
	Hw2str(top, pos);
	mvaddstr(0, 0, top);

	hex_start_row = 1;
	hex_last_row = rows / 2;
	offset_end = offset + 0x10 * (hex_last_row - hex_start_row);

	for (uint16_t y = hex_start_row, addr = offset; y < hex_last_row; ++y, addr += 0x10) {
		Hw2str(buf, addr);
		buf[4] = ' ';
		char *ptr = buf + 5;
		for (unsigned x = 0; x < 0x10; ++x, ptr += 3) {
			if (file[addr + x]) {
				Hb2str(ptr, file[addr + x]);
			} else {
				ptr[0] = ' ';
				ptr[1] = ' ';
			}
			ptr[2] = ' ';
		}
		*ptr = '\0';
		mvaddstr(y, 0, buf);

		move(y, 5 + 0x10 * 3);
		for (unsigned x = 0; x < 0x10; ++x)
			addch(b2acs[file[addr + x]]);
	}

	int cpos = pos - offset;
	if (cpos >= 0 && cpos < 0x10 * (hex_last_row - hex_start_row)) {
		int crow = cpos / 0x10;
		int ccol = cpos % 0x10;

		move(1 + crow, 5 + 3 * ccol);
		curs_set(2);
	} else {
		curs_set(0);
	}
}

int mainloop(void)
{
	pos = offset;

	curs_set(0);
	clear();
	display();
	refresh();

	for (int key = getch(); key != ERR && key != 'q'; key = getch()) {
		switch (key) {
		case KEY_DOWN:
			pos += 0x10;
			if (pos >= offset_end)
				offset += 0x10;
			break;
		case KEY_UP:
			pos -= 0x10;
			if (pos < offset)
				offset -= 0x10;
			break;
		case KEY_LEFT:
			if (--pos < offset)
				offset -= 0x10;
			break;
		case KEY_RIGHT:
			if (++pos >= offset_end)
				offset += 0x10;
			break;
		}
		display();
		refresh();
	}

	return 0;
}

int main(int argc, char **argv)
{
	if (argc != 2) {
		fprintf(stderr, "usage: %s file\n", argc > 0 ? argv[0] : "prgview");
		return 1;
	}

	long end;
	FILE *f = fopen(argv[1], "rb");
	if (!f) {
		perror(argv[1]);
		return 1;
	}

	if (fseek(f, 0, SEEK_SET) || fseek(f, 0, SEEK_END) || (end = ftell(f)) < 0)
		goto f_err;

	if (end < 0 || end > PRG_MAX_SIZE) {
		fputs("Not a prg file\n", stderr);
		fclose(f);
		return 1;
	}

	if (fseek(f, 0, SEEK_SET) || fread(file, sizeof(char), UINT16_MAX, f) != (size_t)end) {
f_err:
		perror(argv[1]);
		fclose(f);
		return 1;
	}
	fclose(f);

	// detect file type
	filesize = (unsigned)end;
	const char *ext = strrchr(argv[1], '.');
	if (ext && !strcmp(ext + 1, "prg")) {
		char copy[UINT16_MAX];
		memcpy(copy, file + 2, filesize - 2);

		is_prg = true;
		// move data
		offset = *((uint16_t*)file);
		for (uint16_t i = offset, j = 0; j < filesize; ++i, ++j)
			file[i] = copy[j];
		offset &= 0xfff0;
		filesize -= 2;
	}

	WINDOW *win = initscr();
	cbreak();
	noecho();
	nonl();
	intrflush(win, FALSE);
	keypad(win, TRUE);
	getmaxyx(win, rows, cols);

	if (rows < ROW_MIN || cols < COL_MIN) {
		delwin(win);
		endwin();
		fprintf(stderr, "tty too small: (%d,%d), expected at least: (%d,%d)\n", cols, rows, COL_MIN, ROW_MIN);
		return 1;
	}
	b2acs_init();

	int ret = mainloop();

	delwin(win);
	endwin();
	return ret;
}
