#include <stdio.h>
#include <stdint.h>

#define MAX 1048576
#define COLS 40

int main(void)
{
	uint16_t start_state = 0x269u;  /* Any nonzero start state will work. */
	uint16_t lfsr = start_state;
	uint16_t bit;                    /* Must be 16bit to allow bit<<15 later in the code */
	unsigned period = 0;

	do {
		printf("%5u %4X (%2u,%2u)\n", lfsr, lfsr, lfsr / COLS, lfsr % COLS);
		/* taps: 10 8 7; feedback polynomial: x^10 + x^8 + x^7 + 1 */
		bit  = ((lfsr >> 0) ^ (lfsr >> 2) ^ (lfsr >> 3) ^ (lfsr >> 5) ) & 1;
		lfsr =  (lfsr >> 1) | (bit << 9);
		++period;
	} while (lfsr != start_state && period < MAX);

	printf("period: %u\n", period);

	return 0;
}

