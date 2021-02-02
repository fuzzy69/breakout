module scene;

import std.conv : to;
import std.stdio : writeln;

import bindbc.sdl;

import brick : Brick;
import bounce_direction : BounceDirection;

import color : Color;
import config : KEY_MOVE_STEP, SCREEN_HEIGHT, SCREEN_WIDTH, PAD_HEIGHT, PAD_WIDTH, BALL_RADIUS, BRICK_ROWS, BRICK_COLS, BRICK_WIDTH, BRICK_HEIGHT, NUM_BRICKS;

class Scene
{
public:
    this(SDL_Renderer *renderer)
    {
        _renderer = renderer;
        _pad.x = (SCREEN_WIDTH - PAD_WIDTH) / 2;
        _pad.y = SCREEN_HEIGHT - PAD_HEIGHT;
        _pad.w = PAD_WIDTH;
        _pad.h = PAD_HEIGHT;

        _ball.x = SCREEN_WIDTH/2 - BALL_RADIUS;
        _ball.y = SCREEN_HEIGHT/2 - BALL_RADIUS;
        _ball.w = BALL_RADIUS * 2;
        _ball.h = BALL_RADIUS * 2;
        _ballMoving = true;
        _ballVelX = 0;
        _ballVelY = 0;
        launchBall();

        for (int i = 0; i < BRICK_ROWS; i++)
        {
            for (int j = 0; j < BRICK_COLS; j++)
            {
                _bricks ~= new Brick(_renderer, j * BRICK_WIDTH + j, i * BRICK_HEIGHT + i, to!Color(i));
            }
        }
    }
    // ~this();

    void render()
    {
        // Draw background
        SDL_SetRenderDrawColor(_renderer, 0, 0, 0, 255);
        SDL_RenderClear(_renderer);

        // Draw pad
        SDL_SetRenderDrawColor(_renderer, 255, 255, 255, 255);
        SDL_RenderFillRect(_renderer, &_pad);

        // Draw bricks
        for (int i = 0; i < NUM_BRICKS; i++) {
            _bricks[i].render();
        }

        // Draw ball
        moveBall();
        SDL_SetRenderDrawColor(_renderer, 255, 255, 255, 255);
        SDL_RenderFillRect(_renderer, &_ball);

        SDL_RenderPresent(_renderer);
    }
    void movePad(int x)
    {
        _pad.x = x;
        if (_pad.x < 0)
            _pad.x = 0;
        else if (_pad.x > SCREEN_WIDTH - PAD_WIDTH)
            _pad.x = SCREEN_WIDTH - PAD_WIDTH;

    }
    void movePadRelative(int delta)
    {
        movePad(_pad.x + delta);
    }
    void launchBall()
    {
        _ball.x = SCREEN_WIDTH / 2 - BALL_RADIUS;
        _ball.y = SCREEN_HEIGHT / 2 - BALL_RADIUS;
        _ballMoving = true;

        _ballVelX = 3;
        _ballVelY = 5;

        // if (rand() > RAND_MAX / 2) {
        //     ball_velx = -ball_velx;
        // }
    }

private:
    void moveBall()
    {
        if (!_ballMoving)
            return;

        _ball.x += _ballVelX;
        _ball.y += _ballVelY;

        // Collisions

        // Left
        if (_ball.x <= 0) {
            _ballVelX = -_ballVelX;
        }
        // Right
        if (_ball.x >= SCREEN_WIDTH - 2*BALL_RADIUS) {
            _ballVelX = -_ballVelX;
        }
        // Top
        if (_ball.y <= 0) {
            _ballVelY = -_ballVelY;
        }
        // Bottom
        if (_ball.y >= SCREEN_HEIGHT) {
            launchBall();
            // launch_ball();
        }
        // Pad
        if (_ball.x >= _pad.x && _ball.x <= _pad.x + PAD_WIDTH && _ball.y + 2*BALL_RADIUS >= _pad.y) {
            _ballVelY = -_ballVelY;
        }
        // Bricks
        for (int i = NUM_BRICKS - 1; i >= 0; --i) {
            immutable int x1 = _ball.x;
            immutable int y1 = _ball.y;
            immutable int x2 = _ball.x + 2 * BALL_RADIUS;
            immutable int y2 = _ball.y + 2 * BALL_RADIUS;
            // writeln(i, " ", _bricks.length);

            immutable BounceDirection bounceDirection = _bricks[i].collide(x1, y1, x2, y2);
            switch (bounceDirection) {
                case BounceDirection.None:
                    continue;
                case BounceDirection.Top:
                case BounceDirection.Bottom:
                    _ballVelY = -_ballVelY;
                    break;
                case BounceDirection.Left:
                case BounceDirection.Right:
                    _ballVelX = -_ballVelX;
                    break;
                default:
                    continue;
            }

            _bricks[i].destroy();
        }
    }

    SDL_Renderer *_renderer;
    bool _ballMoving;
    int _ballVelX;
    int _ballVelY;
    SDL_Rect _ball;
    SDL_Rect _pad;
    Brick[] _bricks;
}
