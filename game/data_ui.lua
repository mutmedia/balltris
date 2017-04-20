require 'game_debug' 
require 'data_constants'
require 'events'

local UI = require 'ui'
local Rectangle = UI.rectangle
local Text = UI.text
local Button = UI.button
local Game = require 'game'

--local DEBUG_UI = true

local MAIN_UI_FONT = 'content/bubblegum.ttf'

Rectangle{
  name='previewbox',
  layer=LAYER_GAME,
  stateMask=STATE_GAME_RUNNING,
  x=BASE_SCREEN_WIDTH/2,
  y=BASE_SCREEN_HEIGHT/2,
  width=(BASE_SCREEN_WIDTH - 2*BORDER_THICKNESS)*1.2,
  height=BASE_SCREEN_HEIGHT,
  lineWidth=3,
  lineColor={0, 0, 0, DEBUG_UI and 255 or 0},
  onMove = function(self, x, y, dx, dy)
    if DEBUG_UI then self.lineColor = {0, 255, 0, 255} end
    Game.events:fire(EVENT_MOVED_PREVIEW, x, y, dx, dy)
  end,
  onEnter = function(self, x, y)
    Game.events:fire(EVENT_MOVED_PREVIEW, x, y, dx, dy)
  end,
  onExit = function(self, x, y)

    if DEBUG_UI then self.lineColor = {0, 0, 255, 255} end
    Game.events:fire(EVENT_RELEASED_PREVIEW, x, y)
  end,
}

Rectangle{
  name='limitline',
  layer=LAYER_HUD,
  x=BASE_SCREEN_WIDTH/2,
  y=MIN_DISTANCE_TO_TOP,
  width=HOLE_WIDTH,
  height=1,
  color={100, 100, 100, 255},
  drawMode='line',
}

Text{
  name='score',
  layer=LAYER_HUD,
  x=80,
  y=50,
  font=love.graphics.newFont(MAIN_UI_FONT, 40),
  width=100,
  getText = function()
    return string.format('%04d', Game.score)
  end,
}

Text{
  name='combo',
  layer=LAYER_HUD,
  x=80,
  y=100,
  font=love.graphics.newFont(MAIN_UI_FONT, 30),
  width=100,
  getText = function()
    return 'Combo: x'..Game.combo
  end,
}

Text{
  name='nextballs',
  layer=LAYER_HUD,
  x=-BORDER_THICKNESS/2,
  y=30,
  font=love.graphics.newFont(MAIN_UI_FONT, 28),
  width=1000,
  getText = function()
    return 'Next Balls'
  end,
}

Text{
  name='gameover',
  layer=LAYER_MENUS,
  stateMask=STATE_GAME_OVER,
  x=BASE_SCREEN_WIDTH/2,
  y=BASE_SCREEN_HEIGHT/2 - 200 - 100,
  font=love.graphics.newFont(MAIN_UI_FONT, 80),
  color={194, 59, 34},
  width=200,
  getText = function()
    return 'Game Over'
  end,
}

Text{
  name='finalscore',
  layer=LAYER_MENUS,
  stateMask=STATE_GAME_OVER,
  x=BASE_SCREEN_WIDTH/2,
  y=BASE_SCREEN_HEIGHT/2 - 000 - 100,
  font=love.graphics.newFont(MAIN_UI_FONT, 30),
  color={0, 0, 0},
  width=400,
  getText = function()
    return string.format('Final Score: %04d', Game.score)
  end,
}

Text{
  name='maxcombo',
  layer=LAYER_MENUS,
  stateMask=STATE_GAME_OVER,
  x=BASE_SCREEN_WIDTH/2,
  y=BASE_SCREEN_HEIGHT/2 + 50 - 100,
  font=love.graphics.newFont(MAIN_UI_FONT, 30),
  color={0, 0, 0},
  width=400,
  getText = function()
    return string.format('Max combo: %d', Game.maxCombo)
  end,
}

Button{
  name='replaybutton',
  layer=LAYER_MENUS,
  stateMask= STATE_GAME_OVER,
  x=BASE_SCREEN_WIDTH/2,
  y=BASE_SCREEN_HEIGHT/2 + 50,
  width=HOLE_WIDTH * 0.8,
  height=80,
  color={255, 255, 255},
  --textColor={0, 0, 0},
  --lineColor={0, 0, 0},
  lineWidth=3,
  font=love.graphics.newFont(MAIN_UI_FONT, 35),
  getText = function() 
    return 'Play Again?'
  end,
  onPress = function(self, x, y)
    Game.start()
  end,
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
