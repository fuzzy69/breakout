import std.stdio;
import std.string : fromStringz, toStringz;
import std.conv;

import bindbc.sdl;
import bindbc.sdl.image;

import config : KEY_MOVE_STEP, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_X, SCREEN_Y;
import scene : Scene;

void main()
{
    const SDLSupport ret = loadSDL();
    if(ret != sdlSupport) {
      writeln("Error loading SDL dll");
      return;
    }
    if(loadSDLImage() != sdlImageSupport) {
      writeln("Error loading SDL Image dll");
      return;
    }

    if (SDL_Init(SDL_INIT_EVERYTHING) != 0) { 
        printf("error initializing SDL: %s\n", SDL_GetError()); 
    } 

    SDL_Window *window = SDL_CreateWindow(
        cast(char*)("Breakout".toStringz), SCREEN_X, SCREEN_Y, SCREEN_WIDTH, SCREEN_HEIGHT, SDL_WINDOW_SHOWN
    );
    scope(exit)
    {
        SDL_DestroyWindow(window);
        SDL_Quit();
    }
    if (window == null)
    {
        writeln("SDL_CreateWindow Error: ", SDL_GetError());
        return;
    }
    SDL_Renderer *renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
    if (renderer == null)
    {
        writeln("SDL_CreateRenderer Error: ", SDL_GetError());
        return;
    }

    auto scene = new Scene(renderer);

    SDL_Event event;
    bool running = true;
    while (running)
    {
        while (SDL_PollEvent(&event))
        {
            if (event.type == SDL_QUIT)
                running = false;
            if (event.type == SDL_KEYDOWN)
            {
                switch (event.key.keysym.sym)
                {
                    case SDLK_q:
                        running = false;
                        break;
                    case SDLK_LEFT:
                        scene.movePadRelative(-KEY_MOVE_STEP);
                        break;
                    case SDLK_RIGHT:
                        scene.movePadRelative(KEY_MOVE_STEP);
                        break;
                    default:
                        break;
                }
            }
            if (event.type == SDL_MOUSEMOTION)
            {
                //
            }
        }
        scene.render();
        SDL_Delay(10);
    }
}
