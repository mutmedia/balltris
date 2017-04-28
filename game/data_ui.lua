require 'data_constants'
require 'events'

local UI = require 'ui'
local Rectangle = UI.rectangle
local Text = UI.text
local Button = UI.button
local Game = require 'game'

--local DEBUG_UI = true

local MAIN_UI_FONT = 'content/Neon.ttf'
UI.DEFAULT_FONT_COLOR = {255, 255, 255}

function inGameState(...)
  local gameStates = {...}
  return function()
    for _, state in pairs(gameStates) do
      if Game.state == state then
        return true
      end
    end
    
    return false
  end
end

function conditionAnd(...)
  local conditions = {...}
  return function()
    for _, cond in pairs(conditions) do
      if not cond() then
        return false
      end
    end

    return true
  end
end

Rectangle{
  name='previewbox',
  layer=LAYER_GAME,
  condition=inGameState(STATE_GAME_RUNNING),
  x=BASE_SCREEN_WIDTH/2,
  y=BASE_SCREEN_HEIGHT/2,
  width=(BASE_SCREEN_WIDTH - 2*BORDER_THICKNESS)*1.2,
  height=BASE_SCREEN_HEIGHT,
  lineWidth=3,
  lineColor={0, 0, 0, DEBUG_UI and 255 or 0},
  onMove = function(self, x, y, dx, dy)
    if DEBUG_UI then self.lineColor = {0, 255, 0, 255} end
    Game.events.fire(EVENT_MOVED_PREVIEW, x, y, dx, dy)
  end,
  onEnter = function(self, x, y)
    Game.events.fire(EVENT_MOVED_PREVIEW, x, y, dx, dy)
  end,
  onExit = function(self, x, y)

    if DEBUG_UI then self.lineColor = {0, 0, 255, 255} end
    Game.events.fire(EVENT_RELEASED_PREVIEW, x, y)
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

-- Score stuff
Text{
  name='highscore',
  layer=LAYER_HUD,
  x=BORDER_THICKNESS/2,
  y=120,
  font=love.graphics.newFont(MAIN_UI_FONT, 40),
  width=100,
  getText = function()
    return string.format('High: %04d', Game.highScore)
  end,
}

Text{
  name='score',
  layer=LAYER_HUD,
  x=BORDER_THICKNESS/2,
  y=240,
  font=love.graphics.newFont(MAIN_UI_FONT, 40),
  width=180,
  getText = function()
    return string.format('Score: %04d', Game.score)
  end,
}

Text{
  name='combo',
  layer=LAYER_HUD,
  condition = function() return Game.combo > 0 end,
  x=BORDER_THICKNESS/2,
  y=320,
  font=love.graphics.newFont(MAIN_UI_FONT, 30),
  width=180,
  getText = function()
    return 'Combo: x'..Game.combo
  end,
}

-- Game Menus
Button{
  name='openmenu',
  layer=LAYER_HUD,
  x=BORDER_THICKNESS/2,
  y=40,
  font=love.graphics.newFont(MAIN_UI_FONT, 40),
  width=100,
  height=50,
  color={0, 0, 0},
  lineWidth = 5,
  lineColor={255, 255, 255},
  font=love.graphics.newFont(MAIN_UI_FONT, 35),
  getText = function()
    return 'Menu'
  end,
  onPress = function() 
    Game.state = STATE_GAME_PAUSED
  end,
}

Button{
  name='gamemenuunpouse',
  condition=inGameState(STATE_GAME_PAUSED),
  layer=LAYER_MENUS,
  x=BASE_SCREEN_WIDTH/2,
  y=BASE_SCREEN_HEIGHT/2 - 100,
  height=80,
  width=HOLE_WIDTH * 0.8,
  color={0, 0, 0},
  lineWidth = 5,
  lineColor={255, 255, 255},
  font=love.graphics.newFont(MAIN_UI_FONT, 35),
  getText = function()
    return 'Unpause'
  end,
  onPress = function() 
    Game.state = STATE_GAME_RUNNING
  end,
}

Button{
  name='replaybutton',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_PAUSED),
  x=BASE_SCREEN_WIDTH/2,
  y=BASE_SCREEN_HEIGHT/2 + 50,
  width=HOLE_WIDTH * 0.8,
  height=80,
  color={0, 0, 0},
  --textColor={0, 0, 0},
  lineColor={255, 255, 255},
  lineWidth=3,
  font=love.graphics.newFont(MAIN_UI_FONT, 35),
  getText = function() 
    return 'Restart'
  end,
  onPress = function(self, x, y)
    Game.start()
  end,
}
-- Game Over Menu
Text{
  name='gameover',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_OVER),
  x=BASE_SCREEN_WIDTH/2,
  y=BASE_SCREEN_HEIGHT/2 - 200 - 100,
  font=love.graphics.newFont(MAIN_UI_FONT, 80),
  color={194, 59, 34},
  width=250,
  getText = function()
    return 'Game Over'
  end,
}

Text{
  name='newHighScore',
  layer=LAYER_MENUS,
  condition=conditionAnd(inGameState(STATE_GAME_OVER), function() return Game.newHighScore end),
  x=BASE_SCREEN_WIDTH/2,
  y=BASE_SCREEN_HEIGHT/2 -130,
  font=love.graphics.newFont(MAIN_UI_FONT, 20),
  width=200,
  getText = function()
    return 'New High Score!'
  end,
}


Text{
  name='finalscore',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_OVER),
  x=BASE_SCREEN_WIDTH/2,
  y=BASE_SCREEN_HEIGHT/2 - 000 - 100,
  font=love.graphics.newFont(MAIN_UI_FONT, 30),
  width=400,
  getText = function()
    return string.format('Final Score: %04d', Game.score)
  end,
}

Text{
  name='maxcombo',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_OVER),
  x=BASE_SCREEN_WIDTH/2,
  y=BASE_SCREEN_HEIGHT/2 + 50 - 100,
  font=love.graphics.newFont(MAIN_UI_FONT, 30),
  width=400,
  getText = function()
    return string.format('Max combo: %d', Game.maxCombo)
  end,
}

Button{
  name='replaybutton',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_OVER),
  x=BASE_SCREEN_WIDTH/2,
  y=BASE_SCREEN_HEIGHT/2 + 50,
  width=HOLE_WIDTH * 0.8,
  height=80,
  color={0, 0, 0, 0},
  --textColor={0, 0, 0},
  lineColor={255, 255, 255},
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
    game.events.fire(EVENT_PRESSED_SWITCH)
    self.color = {255, 0, 0, 255}
  end,
}]]--

--Circle{
--  x=BASE_SCREEN_WIDTH - 100,
--  y = 20 + 20 + 1.1*MAX_RADIUS,
--  color={255, 0, 255, 255},
--}
