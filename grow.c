#include <stdio.h>

#define SIZE 32
#define START 1024

unsigned head, tail, grow, count, pos;

unsigned table[SIZE];

void dump(void)
{
	printf("%2u %2u", head, tail);
	for (unsigned i = 0; i < SIZE; ++i)
		printf(" %4u", table[i]);

	putchar('\n');
}

void step(void)
{
	// setup snake movement code
	int dp = 1;
	pos += dp; // compute new head screen location

	// grow code
	if (grow)
		--grow;
	else {
		// erase old tail
		table[tail] = 0;
		tail = (tail + 1) % SIZE;
	}

	table[head] = pos; // update head and store head in table
	head = (head + 1) % SIZE; // head = (head + 1) % 32

	dump();
}

int main(void)
{
	head = tail = count = 0;
	pos = START;
	grow = 4;

	for (unsigned i = 0; i < 12; ++i) {
		if (!(i % 7))
			++grow;

		step();
	}

	return 0;
}
