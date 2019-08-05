#include <cbm.h>
#include <stdlib.h>
#include <time.h>
#include <conio.h>

#if !defined(__C64__)
#error Only C64 is supported
#endif

#define ROWS 25
#define COLS 40

// Controller Interface Adapter registers
// Zie: http://sta.c64.org/cbm64mem.html
#define CIA1_PORT1 0xDC00
#define CIA1_DDR1 0xDC02

#define SCR_CTRL1 0xD011

#define POKE(addr, val) (*((unsigned char*)addr) = (val))
#define PEEK(addr) (*((unsigned char*)addr))

// Wacht totdat de rasterbeam onderaan is
void wait_rb(void)
{
	while ((PEEK(SCR_CTRL1) & 0x80))
		;
	while (!(PEEK(SCR_CTRL1) & 0x80))
		;
}

unsigned score = 0;

unsigned char joy2, richting, richting_nieuw;
unsigned char kop_x = 10, kop_y = 10, lengte = 5;
unsigned char staart_x, staart_y;
unsigned char food_x, food_y;
unsigned char timer = 0, stappen = 8;

#define MAX_LENGTE 100

unsigned slang_x[MAX_LENGTE + 1], slang_y[MAX_LENGTE + 1];

void next_food(void)
{
	while (1) {
		food_x = rand() % COLS;
		food_y = 2 + (rand() % (ROWS - 2));

		if (PEEK(0x0400 + food_y * 40 + food_x) == ' ')
			break;
	}
}

int main(void)
{
	unsigned char i, j;

	srand(time(NULL));

init:
	kop_x = kop_y = 10;
	stappen = 8;
	score = richting = timer = 0;
	lengte = 5;

	cursor(0);
	clrscr();

	// Plaats objecten
	for (i = 0; i < MAX_LENGTE; ++i) {
		slang_x[i] = kop_x;
		slang_y[i] = kop_y;
		cputcxy(kop_x, kop_y, '@');
	}
	next_food();

	// Maak balk tussen scorebord en speelveld
	gotoxy(0, 1); chline(COLS);

	// Dump joy2 status in hexadecimaal.
	while (1) {
		staart_x = slang_x[0];
		staart_y = slang_y[0];

		joy2 = PEEK(CIA1_PORT1);

		// Bepaal de richting waarin joy2 wijst
		// 0 = midden, 1 = rechts, 2 = omhoog, 3 = links, 4 = beneden
		if (!(joy2 & 0x01))
			richting_nieuw = 2;
		else if (!(joy2 & 0x02))
			richting_nieuw = 4;
		else if (!(joy2 & 0x04))
			richting_nieuw = 3;
		else if (!(joy2 & 0x08))
			richting_nieuw = 1;

		// Beweeg de kop als de timer verstreken is
		if (!timer) {
			// De slang kan niet 180 graden draaien!
			switch (richting_nieuw) {
			case 1: if (richting != 3) richting = richting_nieuw; break;
			case 2: if (richting != 4) richting = richting_nieuw; break;
			case 3: if (richting != 1) richting = richting_nieuw; break;
			case 4: if (richting != 2) richting = richting_nieuw; break;
			}

			switch (richting) {
			case 1: if (kop_x == COLS - 1) kop_x = 0; else ++kop_x; break;
			case 2: if (kop_y == 2) kop_y = ROWS - 1; else --kop_y; break;
			case 3: if (kop_x == 0) kop_x = COLS - 1; else --kop_x; break;
			case 4: if (kop_y == ROWS - 1) kop_y = 2; else ++kop_y; break;
			}

			for (i = 0; i < MAX_LENGTE; ++i) {
				slang_x[i] = slang_x[i + 1];
				slang_y[i] = slang_y[i + 1];
			}

			slang_x[lengte] = kop_x;
			slang_y[lengte] = kop_y;

			timer = stappen;
		} else {
			--timer;
		}

		// Kijk of we een stuk voedsel gegeten hebben
		if (kop_x == food_x && kop_y == food_y) {
			score += 50;

			// Bepaal hoeveel stappen er gaan komen
			if (score >= 1000)
				stappen = 1;
			else if (score >= 800)
				stappen = 2;
			else if (score >= 500)
				stappen = 4;
			else if (score >= 200)
				stappen = 6;

			if (lengte != MAX_LENGTE)
				++lengte;

			next_food();
		}

		// Kijk of we in onszelf gebeten hebben
		if (richting)
			for (i = 0; i < lengte - 1; ++i)
				if (kop_x == slang_x[i] && kop_y == slang_y[i])
					goto game_over;

		// Deze barrière zorgt ervoor dat we pas het scherm gaan tekenen
		// Als het vorige frame getekend is, om zo `strepen', ofwel
		// screen-tearing, te voorkomen...
		wait_rb();

		gotoxy(0, 0); cprintf("Score %d", score);
		if (richting)
			cputcxy(staart_x, staart_y, ' ');
		cputcxy(kop_x, kop_y, '@');
		cputcxy(food_x, food_y, '#');
	}

game_over:
	cputsxy(COLS / 2 - 10 / 2, 0, "game over");

	for (j = 2; j < ROWS; ++j) {
		if (j & 1) {
			for (i = 0; i < COLS; ++i) {
				cputcxy(i, j, '#');
				if (i & 1)
					wait_rb();
			}
		} else {
			for (i = COLS; i > 0; --i) {
				cputcxy(i - 1, j, '#');
				if (i & 1)
					wait_rb();
			}
		}
	}

	cputsxy(6, ROWS / 2 + 1, " Press FIRE for another RUN ");

	for (i = 10; i; --i) {
		gotoxy(10, ROWS / 2); cprintf("    Continue?   %d  ", i);

		for (j = 0; j < 50; ++j) {
			joy2 = PEEK(CIA1_PORT1);
			if (!(joy2 & 0x10))
				goto init;

			wait_rb();
		}
	}

	return 0;
}
