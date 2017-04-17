require 'data_constants'
require 'events'
local Rectangle = game.UI.rectangle

Rectangle{
  x=BORDER_THICKNESS - 0.05*(BASE_SCREEN_WIDTH - 2*BORDER_THICKNESS)/2,
  y=0,
  width=(BASE_SCREEN_WIDTH - 2*BORDER_THICKNESS)*1.05,
  height=BASE_SCREEN_HEIGHT,
  color={255, 0, 0, 0},
  drawMode='line',
  stateMask=STATE_GAME_RUNNING,
  pressed = function(self, x, y)
    --self.color = {0, 255, 0, 255}
  end,
  moved = function(self, x, y, dx, dy)
    game.events:fire(EVENT_MOVED_PREVIEW, x, y, dx, dy)
  end,
  released = function(self, x, y)
    --self.color = {255, 0, 0, 255}
    game.events:fire(EVENT_RELEASED_PREVIEW, x, y)
  end,
}

-- Replay button
Rectangle{
  x=BORDER_THICKNESS + HOLE_WIDTH * 0.1,
  y=BASE_SCREEN_HEIGHT/2,
  width=HOLE_WIDTH * 0.8,
  height=30,
  color={255, 0, 255, 255},
  drawMode='fill',
  stateMask= STATE_GAME_OVER,
  released = function(self, x, y)
    game.objects.balls:Clear()
    game.state = STATE_GAME_RUNNING
    ballPreview = NewBallPreview()
    nextBallPreview = NewBallPreview()
  end,
}

-- Line
Rectangle{
  x=BORDER_THICKNESS,
  y=MIN_DISTANCE_TO_TOP,
  width=HOLE_WIDTH,
  height=1,
  color={255, 0, 0, 255},
  drawMode='line',
}

-- Container
--[[Rectangle{
  x=BASE_SCREEN_WIDTH - 100 - 1.1*MAX_RADIUS,
  y=20 + 20,
  width=2*1.1*MAX_RADIUS,
  height=2*1.1*MAX_RADIUS,
  color={255, 0, 0, 255},
  drawMode='line',
  pressed = function(self, x, y)
    self.color = {0, 255, 0, 255}
  end,
  released = function(self, x, y)
    game.events:fire(EVENT_PRESSED_SWITCH)
    self.color = {255, 0, 0, 255}
  end,
}]]--

--Circle{
--  x=BASE_SCREEN_WIDTH - 100,
--  y = 20 + 20 + 1.1*MAX_RADIUS,
--  color={255, 0, 255, 255},
--}
