require 'data_constants'
require 'events'
local Rectangle = game.UI.rectangle

Rectangle{
  x=BORDER_THICKNESS,
  y=0,
  width=SCREEN_WIDTH - 2*BORDER_THICKNESS,
  height=SCREEN_HEIGHT,
  color={255, 0, 0, 255},
  drawMode='line',
  pressed = function(self, x, y)
    self.color = {0, 255, 0, 255}
  end,
  moved = function(self, x, y, dx, dy)
    game.events:fire(EVENT_MOVED_PREVIEW, x, y, dx, dy)
  end,
  released = function(self, x, y)
    self.color = {255, 0, 0, 255}
    game.events:fire(EVENT_RELEASED_PREVIEW, x, y)
  end,
}

-- Container
Rectangle{
  x=SCREEN_WIDTH - 100 - 1.1*MAX_RADIUS,
  y=20 + 20,
  width=2*1.1*MAX_RADIUS,
  height=2*1.1*MAX_RADIUS,
  color={255, 0, 0, 255},
  drawMode='line',
  pressed = function(self, x, y)
    self.color = {0, 255, 0, 255}
    game.events:fire(EVENT_PRESSED_SWITCH)
  end,
  released = function(self, x, y)
    self.color = {255, 0, 0, 255}
  end,
}

--Circle{
--  x=SCREEN_WIDTH - 100,
--  y = 20 + 20 + 1.1*MAX_RADIUS,
--  color={255, 0, 255, 255},
--}
