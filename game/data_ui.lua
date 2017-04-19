require 'game_debug' 
require 'data_constants'
require 'events'
local UI = require 'ui'
local Rectangle = UI.rectangle
local Game = require 'game'

local DEBUG_UI = true

Rectangle{
  name='Preview box',
  layer=LAYER_GAME,
  x=BORDER_THICKNESS - 0.2*(BASE_SCREEN_WIDTH - 2*BORDER_THICKNESS)/2,
  y=0,
  width=(BASE_SCREEN_WIDTH - 2*BORDER_THICKNESS)*1.2,
  height=BASE_SCREEN_HEIGHT,
  color={0, 0, 0, DEBUG_UI and 255 or 0},
  drawMode='line',
  stateMask=STATE_GAME_RUNNING,
  onMove = function(self, x, y, dx, dy)
    if DEBUG_UI then self.color = {0, 255, 0, 255} end
    Game.events:fire(EVENT_MOVED_PREVIEW, x, y, dx, dy)
  end,
  onEnter = function(self, x, y)
    Game.events:fire(EVENT_MOVED_PREVIEW, x, y, dx, dy)
  end,
  onExit = function(self, x, y)

    if DEBUG_UI then self.color = {0, 0, 255, 255} end
    Game.events:fire(EVENT_RELEASED_PREVIEW, x, y)
  end,
}

-- Replay button
Rectangle{
  name='Replay button',
  layer=LAYER_MENUS,
  x=BORDER_THICKNESS + HOLE_WIDTH * 0.1,
  y=BASE_SCREEN_HEIGHT/2,
  width=HOLE_WIDTH * 0.8,
  height=30,
  color={255, 0, 255, 255},
  drawMode='fill',
  stateMask= STATE_GAME_OVER,
  onPress = function(self, x, y)
    Game.start()
  end,
}

-- Line
Rectangle{
  layer=LAYER_HUD,
  x=BORDER_THICKNESS,
  y=MIN_DISTANCE_TO_TOP,
  width=HOLE_WIDTH,
  height=1,
  color={100, 100, 100, 255},
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
