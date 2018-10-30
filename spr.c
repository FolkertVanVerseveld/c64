#include <stdio.h>
#include <string.h>

#define BUFSZ 256

char *itoa(char *buf, int val, int base)
{
	int i = 30;

	for (; val && i; val /= base)
		buf[i--] = "0123456789abcdef"[val % base];

	return &buf[i + 1];
}

unsigned hatod(char *ptr)
{
	const char *hex = "0123456789abcdef";

	return (strchr(hex, ptr[0]) - hex) << 4 | (strchr(hex, ptr[1]) - hex);
}

int main(void)
{
	char buf[BUFSZ];
	char bin[8 + 1];
	int n = 0;

	//printf("0xfa == %d, %d\n", 0xfa, hatod("fa"));

	while (fgets(buf, BUFSZ, stdin)) {
		char *s = strstr(buf, ".byte");
		if (!s)
			continue;

		for (unsigned char *ptr = s; *ptr; ++ptr) {
			if (*ptr == '$') {
				unsigned v = hatod(ptr + 1);
				for (int i = 7; i >= 0; --i)
					putchar(((v >> i) & 1) ? '1' : '0');

				if (++n == 3) {
					n = 0;
					putchar('\n');
				}
			}
		}
	}
	putchar('\n');
	return 0;
}
