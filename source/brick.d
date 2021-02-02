module brick;

import bindbc.sdl;

import bounce_direction : BounceDirection;
import config : BRICK_WIDTH, BRICK_HEIGHT;
import color : Color;

class Brick
{
public:
    this(SDL_Renderer *r, int x, int y, Color c)
    {
        _renderer = r;
        _brick.x = x;
        _brick.y = y;
        _brick.w = BRICK_WIDTH;
        _brick.h = BRICK_HEIGHT;
        _color = c;
        _visible = true;
    }

    BounceDirection collide(int x1, int y1, int x2, int y2)
    {
        if (!(
            _visible && _brick.x <= x2 && 
            _brick.x + BRICK_WIDTH >= x1 &&
            _brick.y <= y2 &&
            _brick.y + BRICK_HEIGHT >= y1
        ))
            return BounceDirection.None;
        if (y1 <= _brick.y - BRICK_HEIGHT / 2)
            return BounceDirection.Bottom;
        else if (y1 >= _brick.y + BRICK_HEIGHT / 2)
            return BounceDirection.Top;
        else if (x1 < _brick.x)
            return BounceDirection.Left;
        else if (x1 > _brick.x)
            return BounceDirection.Right;
        else
            return BounceDirection.None;
    }
    void destroy()
    {
        _visible = false;
    }
    void render()
    {
        if (!_visible)
            return;

        switch (_color) {
            case Color.RED:
                SDL_SetRenderDrawColor(_renderer, 255, 51, 51, 255);
                break;
            case Color.ORANGE:
                SDL_SetRenderDrawColor(_renderer, 255, 153, 51, 255);
                break;
            case Color.YELLOW:
                SDL_SetRenderDrawColor(_renderer, 255, 255, 51, 255);
                break;
            case Color.GREEN:
                SDL_SetRenderDrawColor(_renderer, 153, 255, 51, 255);
                break;
            case Color.LIGHTBLUE:
                SDL_SetRenderDrawColor(_renderer, 51, 255, 255, 255);
                break;
            case Color.BLUE:
                SDL_SetRenderDrawColor(_renderer, 51, 153, 255, 255);
                break;
            case Color.PURPLE:
                SDL_SetRenderDrawColor(_renderer, 153, 51, 255, 255);
                break;
            default:
                assert(0);
        }

        SDL_RenderFillRect(_renderer, &_brick);
    }

private:
    SDL_Renderer *_renderer;
    SDL_Rect _brick;
    Color _color;
    bool _visible;
}