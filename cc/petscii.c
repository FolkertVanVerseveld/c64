#include <conio.h>

int main(void)
{
	unsigned x, y;

	clrscr();
	cputsxy(2, 0, "0123456789abcdef");
	cputcxy(1, 1, 0xb0);
	for (x = 0; x < 16; ++x)
		cputc(0xc0);

	for (y = 0; y < 16; ++y) {
		cputcxy(0, y + 2, "0123456789abcdef"[y]);
		cputc(0x9d);
		for (x = 0; x < 16; ++x)
			cputcxy(x + 2, y + 2, 16 * y + x);
	}

	return 0;
}
