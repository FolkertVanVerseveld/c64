#include <stdio.h>
#include <string.h>
#include <strings.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>

#include "6510.h"

#define COL 40

#define D_ROW 8

#define T_UNK 0
#define T_PRG 1
#define T_T64 2
#define T_D64 3
#define T_G64 4

struct bfile {
	int fd;
	char name[COL];
	unsigned type;
	unsigned char *data;
	struct stat st;
};

static void bfile_init(struct bfile *f)
{
	f->fd = -1;
	f->name[0] = '\0';
	f->data = NULL;
	f->type = T_UNK;
	f->st.st_size = 0;
}

static void bfile_free(struct bfile *f)
{
	if (f->data)
		munmap(f->data, f->st.st_size);
	if (f->fd)
		close(f->fd);
	bfile_init(f);
}

static char *_strncpy(char *dest, const char *src, size_t n)
{
	char *ptr = strncpy(dest, src, n);
	if (n)
		dest[n - 1] = '\0';
	return ptr;
}

static int bfile_open(struct bfile *f, const char *name)
{
	int ret = 1, fd = -1;
	void *map = NULL;
	struct stat st;

	/* try to open and map file data */
	fd = open(name, O_RDONLY);
	if (fd == -1 || fstat(fd, &st) == -1) {
		perror(name);
		goto fail;
	}

	map = mmap(NULL, st.st_size, PROT_READ, MAP_SHARED, fd, 0);
	if (map == MAP_FAILED)
		goto fail;

	ret = 0;
	f->fd = fd;
	f->data = map;
	f->st = st;

	/* copy filename and determine file type */
	if (strrchr(name, '/'))
		_strncpy(f->name, strrchr(name, '/') + 1, COL);
	else
		_strncpy(f->name, name, COL);
	if (strrchr(name, '.')) {
		const char *ext = strrchr(name, '.') + 1;
		f->type = T_UNK;
		if (!strcasecmp(ext, "prg"))
			f->type = T_PRG;
		else if (!strcasecmp(ext, "t64"))
			f->type = T_T64;
		else if (!strcasecmp(ext, "d64"))
			f->type = T_D64;
		else if (!strcasecmp(ext, "g64"))
			f->type = T_G64;
	}
fail:
	if (ret) {
		if (map)
			munmap(map, st.st_size);
		if (fd != -1)
			close(fd);
	}
	return ret;
}

static void dump(const void *ptr, size_t n, unsigned row)
{
	const unsigned char *data = ptr;
	for (size_t i = 0; i < n;) {
		printf(".byte $%02X", data[i]);
		for (size_t j = ++i + (row - 1); i < j && i < n; ++i)
			printf(", $%02X", data[i]);
		putchar('\n');
	}
}

#define chkn(x) \
	if (i + x > n) {\
		printf(".byte $%02X\n", data[i++]);\
		continue;\
	}

static int dump_prg(const void *ptr, size_t n)
{
	const unsigned char *data;
	unsigned load;

	data = ptr;
	if (n < 2) {
		fputs("missing header\n", stderr);
		return 1;
	}

	load = data[1] << 8 | data[0];
	printf("* = $%X \"start\"\n", load);

	for (size_t i = 2; i < n;) {
		const struct op *o = &optbl[data[i]];
		unsigned l = opl[o->type];
		chkn(l);

		unsigned tp1 = aw16(i, 1), tp2 = aw16(i, 2);

		switch(o->type) {
		case O_IMP: puts(o->name); break;
		case O_IMM: printf("%s $%02X\n", o->name, data[tp1]); break;
		case O_ZP : printf("%s $%02X\n", o->name, data[tp1]); break;
		case O_ZPX: printf("%s $%02X,X\n", o->name, data[tp1]); break;
		case O_ZPY: printf("%s $%02X,Y\n", o->name, data[tp1]); break;
		case O_IZX: printf("%s ($%02X, X)\n", o->name, data[tp1]); break;
		case O_IZY: printf("%s ($%02X), Y\n", o->name, data[tp1]); break;
		case O_ABS: printf("%s $%04X\n", o->name, data[tp2] << 8 | data[tp1]); break;
		case O_ABX: printf("%s $%04X,X\n", o->name, data[tp2] << 8 | data[tp1]); break;
		case O_ABY: printf("%s $%04X,Y\n", o->name, data[tp2] << 8 | data[tp1]); break;
		case O_REL: printf("%s $%04X\n", o->name, aw16(load + tp2, (int8_t)data[tp1])); break;
		default: printf(".byte $%02X\n", data[i]); break;
		}
		i += l;
	}

	return 0;
}

static int diss(const struct bfile *f)
{
	int ret = 1;
	printf(
		"// name: %s (type: %u)\n"
		"// size: $%zX (%zu)\n",
		f->name, f->type,
		f->st.st_size, f->st.st_size
	);
	switch (f->type) {
	case T_PRG:
		ret = dump_prg(f->data, f->st.st_size);
		break;
	default:
		dump(f->data, f->st.st_size, D_ROW);
		ret = 0;
		break;
	}
	if (ret)
		fputs("Dissassembly failed\n", stderr);
	return ret;
}

int main(int argc, char **argv)
{
	int ret = 1;
	struct bfile f;
	bfile_init(&f);

	if (argc != 2) {
		fprintf(stderr, "usage: %s file\n", argc > 0 ? argv[0] : "diss");
		goto fail;
	}

	if (bfile_open(&f, argv[1]))
		goto fail;

	ret = diss(&f);
fail:
	bfile_free(&f);
	return ret;
}
