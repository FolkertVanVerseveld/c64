#include <SDL2/SDL.h>
#include <SDL2/SDL_image.h>
#include <GL/gl.h>

#define ARRAY_SIZE(a) (sizeof(a)/sizeof(a[0]))

#define SCR_X0 32
#define SCR_Y0 34

#define FRGB(r, g, b) {(r) / 255.0f, (g) / 255.0f, (b) / 255.0f}

const float coltbl[16][3] = {
	FRGB(0, 0, 0), // black
	FRGB(255, 255, 255), // white
	FRGB(187, 106, 81), // red
	FRGB(169, 243, 255), // cyan
	FRGB(191, 110, 251), // purple
	FRGB(152, 229, 81), // green
	FRGB(105, 83, 245), // blue
	FRGB(255, 255, 123), // yellow
	FRGB(198, 146, 50), // brown
	FRGB(141, 121, 0), // dark drown
	FRGB(245, 171, 150), // light red
	FRGB(129, 129, 129), // dark grey
	FRGB(182, 182, 182), // grey
	FRGB(219, 255, 128), // light green
	FRGB(177, 158, 255), // light blue
	FRGB(224, 224, 224), // light grey
};

const unsigned char boot_top[] = {
	// **** COMMODORE 64 BASIC V2 ****
	0x20, 0x20, 0x20, 0x20, 0x2a, 0x2a, 0x2a, 0x2a,
	0x20, 0x03, 0x0f, 0x0d, 0x0d, 0x0f, 0x04, 0x0f,
	0x12, 0x05, 0x20, 0x36, 0x34, 0x20, 0x02, 0x01,
	0x13, 0x09, 0x03, 0x20, 0x16, 0x32, 0x20, 0x2a,
	0x2a, 0x2a, 0x2a, 0x20, 0x20, 0x20
};

const unsigned char boot_ram[] = {
	// 64K RAM SYSTEM  38911 BASIC BYTES FREE
	0x20, 0x36, 0x34, 0x0b, 0x20, 0x12, 0x01, 0x0d,
	0x20, 0x13, 0x19, 0x13, 0x14, 0x05, 0x0d, 0x20,
	0x20, 0x33, 0x38, 0x39, 0x31, 0x31, 0x20, 0x02,
	0x01, 0x13, 0x09, 0x03, 0x20, 0x02, 0x19, 0x14,
	0x05, 0x13, 0x20, 0x06, 0x12, 0x05, 0x05
};

const unsigned char boot_prompt[] = {
	// READY.
	0x12, 0x05, 0x01, 0x04, 0x19, 0x2e
};

/*
READY.
LOAD"*",8,1:

SEARCHING FOR *
LOADING
READY.
RUN
*/

#define TITLE "Prole Art Debut Concept"

#define WIDTH 384
#define HEIGHT 272

static SDL_Window *win;
static SDL_GLContext gl;

#define TEXTURES 2

#define TEX_UPPER 0
#define TEX_LOWER 1

static GLuint tex[TEXTURES];
static unsigned tex_w[TEXTURES], tex_h[TEXTURES];

static Uint32 timer;

static void gfx_load(unsigned i, const char *name)
{
	SDL_Surface *surf;
	int mode = GL_RGB;
	GLuint texture = tex[i];

	surf = IMG_Load(name);
	if (!surf) {
		fprintf(stderr, "Could not load \"%s\": %s\n", name, IMG_GetError());
		exit(1);
	}
	if (surf->w <= 0 || surf->h <= 0) {
		fprintf(stderr, "Bogus dimensions: %d, %d\n", surf->w, surf->h);
		exit(1);
	}

	glBindTexture(GL_TEXTURE_2D, texture);

	//printf("%s: bpp = %d\n", name, surf->format->BytesPerPixel);
	// Not completely correct, but good enough
	if (surf->format->BytesPerPixel == 4)
		mode = GL_RGBA;

	glTexImage2D(GL_TEXTURE_2D, 0, mode, surf->w, surf->h, 0, mode, GL_UNSIGNED_BYTE, surf->pixels);

	tex_w[i] = (unsigned)surf->w;
	tex_h[i] = (unsigned)surf->h;

	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

	SDL_FreeSurface(surf);
}

static void gfx_init(void)
{
	glGenTextures(TEXTURES, tex);

	gfx_load(TEX_UPPER, "upper.png");
	gfx_load(TEX_LOWER, "lower.png");
}

static void gfx_free(void)
{
	glDeleteTextures(TEXTURES, tex);
}

static int kbd(unsigned key)
{
	switch (key) {
	case 'q':
		return 0;
	}
	return 1;
}

static void init(void)
{
	glViewport(0, 0, WIDTH, HEIGHT);
	glClearColor(0, 0, 0, 0);

	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

	//glClearColor(184 / 255.0f, 163 / 255.0f, 255 / 255.0f, 0);
	glClearColor(coltbl[14][0], coltbl[14][1], coltbl[14][2], 0);
}

static void scrputc(unsigned y, unsigned x, int ch)
{
	if (ch < 0) ch = -ch;
	ch &= 0xff;

	GLfloat s0, t0, s1, t1;
	s0 = (ch % 16) / 16.0f;
	s1 = s0 + 1 / 16.0f;
	t0 = (ch / 16) / 16.0f;
	t1 = t0 + 1 / 16.0f;

	GLfloat x0, y0, x1, y1;
	x0 = SCR_X0 + x * 8;
	x1 = x0 + 8;
	y0 = SCR_Y0 + y * 8;
	y1 = y0 + 8;

	glBegin(GL_QUADS);
		glTexCoord2f(s0, t0); glVertex2f(x0, y0);
		glTexCoord2f(s1, t0); glVertex2f(x1, y0);
		glTexCoord2f(s1, t1); glVertex2f(x1, y1);
		glTexCoord2f(s0, t1); glVertex2f(x0, y1);
	glEnd();
}

static void display(Uint32 ticks)
{
	glClear(GL_COLOR_BUFFER_BIT);

	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrtho(0, WIDTH, HEIGHT, 0, -1, 1);

	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();

	glColor3f(coltbl[6][0], coltbl[6][1], coltbl[6][2]);
	glBegin(GL_QUADS);
		glVertex2f(SCR_X0, SCR_Y0);
		glVertex2f(SCR_X0 + 40 * 8, SCR_Y0);
		glVertex2f(SCR_X0 + 40 * 8, SCR_Y0 + 25 * 8);
		glVertex2f(SCR_X0, SCR_Y0 + 25 * 8);
	glEnd();

	glBindTexture(GL_TEXTURE_2D, tex[0]);
	glEnable(GL_TEXTURE_2D);
	glColor3f(coltbl[14][0], coltbl[14][1], coltbl[14][2]);

#if 0
	for (int i = 0; i < 255; ++i)
		scrputc(i / 16, i % 16, i);
#else
	for (unsigned i = 0; i < ARRAY_SIZE(boot_top); ++i)
		scrputc(1, i, boot_top[i]);

	for (unsigned i = 0; i < ARRAY_SIZE(boot_ram); ++i)
		scrputc(3, i, boot_ram[i]);

	for (unsigned i = 0; i < ARRAY_SIZE(boot_prompt); ++i)
		scrputc(5, i, boot_prompt[i]);
#endif

	glDisable(GL_TEXTURE_2D);
}

static int mainloop(void)
{
	init();

	timer = SDL_GetTicks();

	while (1) {
		SDL_Event ev;

		while (SDL_PollEvent(&ev)) {
			switch (ev.type) {
			case SDL_QUIT:
				return 0;
			case SDL_KEYDOWN:
				if (kbd(ev.key.keysym.sym) == 0)
					return 0;
				break;
			}
		}

		Uint32 next = SDL_GetTicks();
		display(next - timer);
		timer = next;

		SDL_GL_SwapWindow(win);
	}
}

int main(void)
{
	int ret = 1;
	unsigned img_mask = IMG_INIT_JPG | IMG_INIT_PNG;

	if (SDL_Init(SDL_INIT_VIDEO) != 0) {
		fprintf(stderr, "Could not init SDL: %s\n", SDL_GetError());
		goto fail;
	}

	if (SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1))
		fputs("No double buffering\n", stderr);

	win = SDL_CreateWindow(
		TITLE,
		SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
		WIDTH, HEIGHT,
		SDL_WINDOW_OPENGL | SDL_WINDOW_SHOWN
	);
	if (!win) {
		fprintf(stderr, "Could not create window: %s\n", SDL_GetError());
		goto err_win;
	}

	if (!(gl = SDL_GL_CreateContext(win))) {
		fprintf(stderr, "Could not create OpenGL context: %s\n", SDL_GetError());
		goto err_gl;
	}

	if ((IMG_Init(img_mask) & img_mask) != img_mask) {
		fprintf(stderr, "Could not init image library: %s\n", IMG_GetError());
		goto err_img;
	}
	gfx_init();

	ret = mainloop();

	// Cleanup
	gfx_free();
	IMG_Quit();
err_img:
	SDL_GL_DeleteContext(gl);
err_gl:
	SDL_DestroyWindow(win);
err_win:
	SDL_Quit();
fail:
	return ret;
}
