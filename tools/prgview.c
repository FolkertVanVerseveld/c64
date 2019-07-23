/* Copyright 2019 Folkert van Verseveld. All rights reserved */

// https://www.c64-wiki.com/wiki/BASIC_token

/*
 * Simple .prg viewer
 */
#include <stddef.h>
#include <assert.h>
#include <stdio.h>
#include <string.h>
#include <stdbool.h>
#include <stdint.h>
#include <ctype.h>
#include <ncurses.h>

#include "6510.h"

// max 202 blocks with default memconfig
#define PRG_MAX_SIZE 51712

#define COL_MIN 80
#define ROW_MIN 24

#define CBM64_MEMMAX 65536

#define CMD_BUFSZ COL_MIN
#define STATUS_BUFSZ COL_MIN

char cmd_buf[CMD_BUFSZ], status[STATUS_BUFSZ];
unsigned cmd_buf_pos = 0;

#define TYPE_DATA 0
#define TYPE_WORD 1
#define TYPE_OPCODE 2
#define TYPE_BASIC_OPCODE 3
#define TYPE_CHAR 4

// sizeof largest type
#define TYPE_LENGTH 3

unsigned char file[CBM64_MEMMAX], type[CBM64_MEMMAX];
int rows, cols;
uint16_t offset, pos, offset_end;
unsigned filesize;
bool is_prg = false;

const char *HEX = "0123456789ABCDEF", *hex = "0123456789abcdef";
char top[] = "     00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F 0123456789ABCDEF";

const char *basic_tokens[256] = {
	[0x80]="END"   ,[0x81]="FOR"   ,[0x82]="NEXT",[0x83]="DATA",[0x84]="INPUT#" ,[0x85]="INPUT" ,[0x86]="DIM"   ,[0x87]="READ",
	[0x88]="LET"   ,[0x89]="GOTO"  ,[0x8A]="RUN" ,[0x8B]="IF"  ,[0x8C]="RESTORE",[0x8D]="GOSUB" ,[0x8E]="RETURN",[0x8F]="REM" ,
	[0x90]="STOP"  ,[0x91]="ON"    ,[0x92]="WAIT",[0x93]="LOAD",[0x94]="SAVE"   ,[0x95]="VERIFY",[0x96]="DEF"   ,[0x97]="POKE",
	[0x98]="PRINT#",[0x99]="PRINT" ,[0x9A]="CONT",[0x9B]="LIST",[0x9C]="CLR"    ,[0x9D]="CMD"   ,[0x9E]="SYS"   ,[0x9F]="OPEN",
	[0xA0]="CLOSE" ,[0xA1]="GET"   ,[0xA2]="NEW" ,[0xA3]="TAB(",[0xA4]="TO"     ,[0xA5]="FN"    ,[0xA6]="SPC("  ,[0xA7]="THEN",
	[0xA8]="NOT"   ,[0xA9]="STEP"  ,[0xAA]="+"   ,[0xAB]="-"   ,[0xAC]="*"      ,[0xAD]="/"     ,[0xAE]="^"     ,[0xAF]="AND",
	[0xB0]="OR"    ,[0xB1]=">"     ,[0xB2]="="   ,[0xB3]="<"   ,[0xB4]="SGN"    ,[0xB5]="INT"   ,[0xB6]="ABS"   ,[0xB7]="USR",
	[0xB8]="FRE"   ,[0xB9]="POS"   ,[0xBA]="SQR" ,[0xBB]="RND" ,[0xBC]="LOG"    ,[0xBD]="EXP"   ,[0xBE]="COS"   ,[0xBF]="SIN",
	[0xC0]="TAN"   ,[0xC1]="ATN"   ,[0xC2]="PEEK",[0xC3]="LEN" ,[0xC4]="STR$"   ,[0xC5]="VAL"   ,[0xC6]="ASC"   ,[0xC7]="CHR$",
	[0xC8]="LEFT$" ,[0xC9]="RIGHT$",[0xCA]="MID$",[0xCB]="GO"
};

#include "6510.c"

static inline uint16_t aw16(unsigned base, unsigned v)
{
	return (base + v) & 0xffff;
}

char *strncpy0(char *dest, const char *src, size_t n)
{
	char *ptr = strncpy(dest, src, n);
	if (n) dest[n - 1] = '\0';
	return ptr;
}

unsigned type_len(uint16_t pos)
{
	switch (type[pos]) {
	case TYPE_OPCODE: return opl[optbl[file[pos]].type];
	case TYPE_WORD: return 2;
	default: return 1;
	}
}

#define SCROLL 0x10

// TODO improve scrolling

void add_pos(int v)
{
	if (!v)
		return;

	pos += v;

	if (v > 0) {
		if (pos >= offset_end)
			offset += SCROLL;
	} else {
		if (pos < offset)
			offset -= SCROLL;
	}
}

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
	/* draw hex view */
	char buf[80];
	Hw2str(top, pos);
	mvaddstr(0, 0, top);

	hex_start_row = 1;
	hex_last_row = rows / 2 - 1;
	offset_end = offset + 0x10 * (hex_last_row - hex_start_row);

	for (uint16_t y = hex_start_row, addr = offset; y <= hex_last_row; ++y, addr += 0x10) {
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

	/* draw data as type (e.g. assembly instruction, basic token, data) */
	for (uint16_t y = hex_last_row + 1, n = rows - 2 - hex_last_row, i = 0, tpos = (pos + 0x10000 - n / 2) & 0xffff; i < n; ++i, ++y, ++tpos) {
		//mvprintw(y, 0, "row %u, tpos %04X", i, tpos);
		int special_char = 0;
		sprintf(buf, "%04X %02X       ", tpos, file[tpos]);

		if (tpos == pos)
			attron(A_UNDERLINE);
		else
			attroff(A_UNDERLINE);

#define put(s) strncpy0(buf + 14, s, sizeof buf - 14)
#define format(f, ...) snprintf(buf + 14, sizeof buf - 14, f, ## __VA_ARGS__)

		switch (type[tpos]) {
		case TYPE_BASIC_OPCODE: {
			if (!basic_tokens[file[tpos]])
				goto unknown_byte;
			else
				put(basic_tokens[file[tpos]]);
			break;
		}
		case TYPE_OPCODE: {
			const struct op *o = &optbl[file[tpos]];
			unsigned l = opl[o->type];

			unsigned tp1 = aw16(tpos, 1), tp2 = aw16(tpos, 2);

			switch (o->type) {
			case O_IMP: put(o->name); break;
			case O_IMM: format("%s $%02X\n", o->name, file[tp1]); break;
			case O_ZP : format("%s $%02X\n", o->name, file[tp1]); break;
			case O_ZPX: format("%s $%02X,X\n", o->name, file[tp1]); break;
			case O_ZPY: format("%s $%02X,Y\n", o->name, file[tp1]); break;
			case O_IZX: format("%s ($%02X, X)\n", o->name, file[tp1]); break;
			case O_IZY: format("%s ($%02X), Y\n", o->name, file[tp1]); break;
			case O_ABS: format("%s $%04X\n", o->name, file[tp2] << 8 | file[tp1]); break;
			case O_ABX: format("%s $%04X,X\n", o->name, file[tp2] << 8 | file[tp1]); break;
			case O_ABY: format("%s $%04X,Y\n", o->name, file[tp2] << 8 | file[tp1]); break;
			case O_REL: format("%s $%02X\n", o->name, file[tp1]); break;
			default: goto unknown_byte;
			}

			if (l >= 3) {
				buf[11] = HEX[file[tpos + 2] >> 4];
				buf[12] = HEX[file[tpos + 2] & 0xf];
			}
			if (l >= 2) {
				buf[8] = HEX[file[tpos + 1] >> 4];
				buf[9] = HEX[file[tpos + 1] & 0xf];
			}

			tpos += l - 1;
			break;
		}
		case TYPE_WORD:
			format(".word %04X", file[tpos + 1] << 8 | file[tpos]);
			buf[8] = HEX[file[tpos + 1] >> 4];
			buf[9] = HEX[file[tpos + 1] & 0xf];
			++tpos;
			break;
		case TYPE_CHAR:
			put(".byte ' '");
			special_char = 14 + strlen(".byte '");
			break;
		default:
unknown_byte:
			format(".byte %02X", file[tpos]);
			break;
		}

#undef format
#undef put

		mvaddstr(y, 0, buf);
		if (special_char) {
			int y, x;
			getyx(stdscr, y, x);
			mvaddch(y, special_char, b2acs[file[tpos]]);
			move(y, x);
		}
		clrtoeol();
	}

	/* draw command interface */
	if (cmd_buf_pos)
		mvaddstr(rows - 1, 0, cmd_buf);
	else
		mvaddstr(rows - 1, 0, status);
	clrtoeol();

	/* show cursor at cmd buf if in command mode */
	if (cmd_buf_pos) {
		curs_set(2);
		return;
	}

	/* show cursor in hexview */
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
		if (cmd_buf_pos) {
			switch (key) {
			case KEY_BACKSPACE:
			case 127:
			case '\b':
				cmd_buf[--cmd_buf_pos] = '\0';
				break;
			case '\r':
			case '\n':
				// process buffer
				*status = '\0';
				if (cmd_buf_pos >= 2 && cmd_buf[1] == 't') {
					switch (cmd_buf[2]) {
					case 'b':
						switch (cmd_buf[3]) {
						case 'i': type[pos] = TYPE_BASIC_OPCODE; break;
						case ' ':
						case '\0': type[pos] = TYPE_DATA; break;
						default: strcpy(status, "Bad type"); break;
						}
						break;
					case 'w': type[pos] = TYPE_WORD; break;
					case 'i': type[pos] = TYPE_OPCODE; break;
					case 'I': {
						// keep parsing till opcode jams cpu
						for (uint16_t ipos = pos, i = 0; i < UINT16_MAX; ++i) {
							const struct op *o = &optbl[file[ipos]];
							unsigned l = opl[o->type];

							if (o->name[0] == 'K')
								break;

							for (unsigned j = 0; j < l; ++j)
								if (type[aw16(ipos, j)] != TYPE_DATA) {
									i = UINT16_MAX;
									goto stop;
								}

							type[ipos] = TYPE_OPCODE;
							ipos += l;
						}
stop:
						break;
					}
					case 'c': type[pos] = TYPE_CHAR; break;
					case '\0': type[pos] = TYPE_DATA; break;
					default: strcpy(status, "Bad type"); break;
					}
				} else {
					strcpy(status, "Unknown command");
				}
				cmd_buf_pos = 0;
				break;
			default:
				// append to buffer
				if (key <= 0xff && isprint(key & 0xff) && cmd_buf_pos < CMD_BUFSZ + 1) {
					cmd_buf[cmd_buf_pos++] = key & 0xff;
					cmd_buf[cmd_buf_pos] = '\0';
				}
				break;
			}
		} else {
			switch (key) {
				case KEY_DOWN: add_pos(SCROLL); break;
				case KEY_UP: add_pos(-SCROLL); break;
				case KEY_LEFT: add_pos(-1); break;
				case KEY_RIGHT: add_pos(1); break;
				case 'k': {
					assert(TYPE_LENGTH == 3);
					int l = -1;

					// guess how many bytes we have to go back
					if (type_len(pos - 3) == 3)
						l = -3;
					else if (type_len(pos - 1) == 1 && type_len(pos - 2) > 1 && type_len(pos - 2) < 3)
						l = -2;

					add_pos(l);
					break;
				}
				case 'j':
					add_pos(type_len(pos));
					break;
				case ':':
					cmd_buf[0] = ':';
					cmd_buf[1] = '\0';
					cmd_buf_pos = 1;
					break;
				default:
					snprintf(status, STATUS_BUFSZ, "Unknown key: %d\n", key);
					break;
			}
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
		memset(file, 0, filesize);

		for (uint16_t i = offset, j = 0; j < filesize; ++i, ++j)
			file[i] = copy[j];

		offset &= 0xfff0;
		filesize -= 2;
	}

	if (!is_prg) {
		fputs("Warning: limited non-prg support\n", stderr);
		while (getchar() != '\n') {}
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
