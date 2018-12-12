#include <SDL2/SDL.h>
#include <SDL2/SDL_image.h>
#include <GL/gl.h>

static SDL_Window *win;
static SDL_GLContext gl;

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

	ret = 0;

err_win:
	SDL_Quit();
fail:
	return ret;
}
