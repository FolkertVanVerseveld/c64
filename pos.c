#include <stdio.h>
#include <stdint.h>

#define MAX 32
#define ROWS 25
#define COLS 40

int main(void)
{
	uint16_t start_state = 751;  /* Any nonzero start state will work. */
	uint16_t lfsr = start_state;
	uint16_t bit;                    /* Must be 16bit to allow bit<<15 later in the code */
	unsigned period = 0;

	unsigned pos[MAX];
	unsigned x[MAX], y[MAX];

	do {
		//printf("%5u %4X (%2u,%2u)\n", lfsr, lfsr, lfsr / COLS, lfsr % COLS);
		/* taps: 10 8 7; feedback polynomial: x^10 + x^8 + x^7 + 1 */
		bit  = ((lfsr >> 0) ^ (lfsr >> 1) ^ (lfsr >> 4) ^ (lfsr >> 5) ) & 1;
		lfsr =  (lfsr >> 1) | (bit << 9);
		pos[period] = lfsr + 1024;
		y[period] = (lfsr / COLS) % ROWS;
		x[period] = lfsr % COLS;
		++period;
	} while (lfsr != start_state && period < MAX);

	// dump pos
	printf(".byte");
	for (unsigned i = 0; i < period; ++i)
		printf(" $%02X,", pos[i] & 0xff);
	printf("\n.byte");
	for (unsigned i = 0; i < period; ++i)
		printf(" $%02X,", pos[i] >> 8);
	// dump y
	printf("\n.byte");
	for (unsigned i = 0; i < period; ++i)
		printf(" $%02X,", y[i]);
	// dump x
	printf("\n.byte");
	for (unsigned i = 0; i < period; ++i)
		printf(" $%02X,", x[i]);
	putchar('\n');

	//printf("period: %u\n", period);
	printf("// bytes used: %u\n", 4 * MAX);

	return 0;
}

