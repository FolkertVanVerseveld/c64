#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <stddef.h>

static const int base[] ={
	34334, 36376, 38539, 40830,
	43258, 45830, 48556, 51443,
	54502, 57743, 61176, 64814,
}, voice0[] = {
	594, 594, 594, 596, 596,
	1618, 587, 592, 587, 585, 331, 336,
	1097, 583, 585, 585, 585, 587, 587,
	1609, 585, 331, 337, 594, 594, 593,
	1618, 594, 596, 594, 592, 587,
	1616, 587, 585, 331, 336, 841, 327,
	1607,
	0
}, voice1[] = {
	583, 585, 583, 583, 327, 329,
	1611, 583, 585, 578, 578, 578,
	196, 198, 583, 326, 578,
	326, 327, 329, 327, 329, 326, 578, 583,
	1606, 582, 322, 324, 582, 587,
	329, 327, 1606, 583,
	327, 329, 587, 331, 329,
	329, 328, 1609, 578, 834,
	324, 322, 327, 585, 1602,
	0
}, voice2[] = {
	567, 566, 567, 304, 306, 308, 310,
	1591, 567, 311, 310, 567,
	306, 304, 299, 308,
	304, 171, 176, 306, 291, 551, 306, 308,
	310, 308, 310, 306, 295, 297, 299, 304,
	1586, 562, 567, 310, 315, 311,
	308, 313, 297,
	1586, 567, 560, 311, 309,
	308, 309, 306, 308,
	1577, 299, 295, 306, 310, 311, 304,
	562, 546, 1575,
	0
};

static void process(const int *data, int v)
{
	int i = 0;
	for (int nm; nm = *data; ++data) {
		int wa = v;
		int wb = wa - 1;
		if (nm < 0) {
			nm = -nm;
			wa = 0;
			wb = 0;
		}
		int dr = nm / 128;
		int oc = (nm - 128 * dr) / 16;
		int nt = nm - 128 * dr - 16 * oc;
		if (nt >= 12) {
			fprintf(stderr, "nt: %3d\n", nt);
			exit(1);
		}
		int fr = base[nt];
		if (oc != 7) {
			for (int j = 6; j >= oc; --j)
				fr /= 2;
		}
		int hf = fr / 256;
		int lf = fr - 256 * hf;
		if (dr == 1) {
			printf("lf,hf,wa=%3d,%3d,%3d\n", lf, hf, wa);
			++i;
			continue;
		}
		for (int j = 1; j <= dr - 1; ++j) {
			printf("lf,hf,wa=%3d,%3d,%3d\n", lf, hf, wa);
			++i;
		}
		printf("lf,hf,wb=%3d,%3d,%3d\n", lf, hf, wb);
		++i;
	}
	printf("i=%3d\n", i);
}

int main(void)
{
	printf("baselen  : %zu\n", sizeof base   / 4);
	printf("voice0len: %zu\n", sizeof voice0 / 4);
	printf("voice1len: %zu\n", sizeof voice1 / 4);
	printf("voice2len: %zu\n", sizeof voice2 / 4);
	puts("----");
	process(voice0, 17);
	puts("----");
	process(voice1, 65);
	puts("----");
	process(voice2, 33);
	return 0;
}
