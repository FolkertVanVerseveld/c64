#ifndef MOS_6510_H
#define MOS_6510_H

#include <stdint.h>

#define O_UNK 0
#define O_IMP 1
#define O_IMM 2
#define O_ZP  3
#define O_ZPX 4
#define O_ZPY 5
#define O_IZX 6
#define O_IZY 7
#define O_ABS 8
#define O_ABX 9
#define O_ABY 10
#define O_IND 11
#define O_REL 12

struct op {
	unsigned type;
	const char *name;
};

extern const struct op optbl[256];
extern const unsigned opl[O_REL + 1];

static inline uint16_t aw16(unsigned base, unsigned v)
{
	return (base + v) & 0xffff;
}

#endif
