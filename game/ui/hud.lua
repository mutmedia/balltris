require 'ui/base'
local Backend = require 'backend'

Text{
  name='loading',
  layer=LAYER_HUD,
  condition=inGameState(STATE_GAME_LOADING),
  x=BASE_SCREEN_WIDTH/2,
  y=BASE_SCREEN_HEIGHT/2,
  font=FONT_MD,
  color=1,
  width=1000,
  getText = function()
    return 'Loading...'
  end,
}

Text{
  name='offline',
  layer=LAYER_HUD,
  condition=function() return Backend.isOffline end,
  x=BORDER_THICKNESS/2,
  y=-UI_HEIGHT_UNIT,
  font=FONT_SM,
  color=COLOR_RED,
  width=1000,
  getText = function()
    return 'offline'
  end,
}

Text{
  name='nextballs',
  layer=LAYER_HUD,
  condition=inGameState(STATE_GAME_RUNNING),
  x=-BORDER_THICKNESS/2,
  y=2*UI_HEIGHT_UNIT,
  font=FONT_SM,
  color=1,
  width=BORDER_THICKNESS,
  getText = function()
    return 'next balls'
  end,
}

-- Game Menus
Button{
  name='open menu',
  layer=LAYER_HUD,
  condition=inGameState(STATE_GAME_RUNNING, STATE_GAME_PAUSED),
  x=BORDER_THICKNESS/2,
  y=2*UI_HEIGHT_UNIT,
  width=0.8*BORDER_THICKNESS,
  height=2*UI_HEIGHT_UNIT,
  lineWidth = 5,
  lineColor=1,
  font=FONT_MD,
  textColor=1,
  getText = function()
    return 'menu'
  end,
  onPress = function() 
    if Game.state ~= STATE_GAME_PAUSED then
      Game.state = STATE_GAME_PAUSED
    else
      Game.state = STATE_GAME_RUNNING
    end
  end,
}

-- Score stuff

Text{
  name='score',
  layer=LAYER_HUD,
  condition=inGameState(STATE_GAME_RUNNING, STATE_GAME_PAUSED, STATE_GAME_LOST),
  x=BORDER_THICKNESS/2,
  y=6*UI_HEIGHT_UNIT,
  font=FONT_MD,
  color=1,
  width=BORDER_THICKNESS,
  getText = function()
    return string.format('score: %04d', Game.score)
  end,
}
Text{
  name='highscore',
  layer=LAYER_HUD,
  condition=inGameState(STATE_GAME_RUNNING, STATE_GAME_PAUSED, STATE_GAME_LOST),
  x=BORDER_THICKNESS/2,
  y=09.5*UI_HEIGHT_UNIT,
  font=FONT_SM,
  color=1,
  width=BORDER_THICKNESS,
  getText = function()
    return string.format('best: %04d', Game.highScore)
  end,
}

Text{
  name='combo',
  layer=LAYER_HUD,
  condition = And(inGameState(STATE_GAME_RUNNING, STATE_GAME_PAUSED, STATE_GAME_LOST)),
  x=BORDER_THICKNESS/2,
  y=12*UI_HEIGHT_UNIT,
  font=FONT_SM,
  color=1,
  width=BORDER_THICKNESS,
  getText = function()
    local comboText = Game.combo > 0 and string.format('%2d', Game.combo) or '--'
    local objectiveText = string.format('%2d', Game.comboObjective)
    return 'combo '..comboText
  end,
}

Text{
  name='combo objective',
  layer=LAYER_HUD,
  condition = inGameState(STATE_GAME_RUNNING, STATE_GAME_PAUSED),
  --condition = And(function() return Game.combo > 0 end, inGameState(STATE_GAME_RUNNING, STATE_GAME_PAUSED, STATE_GAME_LOST)),
  x=BORDER_THICKNESS/2,
  y=13.15*UI_HEIGHT_UNIT,
  font=FONT_XS,
  getColor=function()
    return Game.comboObjectiveCleared and COLOR_GREEN or COLOR_YELLOW
  end,
  width=BORDER_THICKNESS,
  getText = function()
  return Game.comboObjectiveCleared and 'cleared' or string.format('clears at %2d', Game.comboObjective)
  end,
}

Custom{
  name='combo thermometer',
  layer=LAYER_HUD,
  condition = inGameState(STATE_GAME_RUNNING, STATE_GAME_PAUSED, STATE_GAME_LOST),
  --condition = And(function() return Game.combo > 0 end, inGameState(STATE_GAME_RUNNING, STATE_GAME_PAUSED, STATE_GAME_LOST)),
  x=BORDER_THICKNESS/2,
  y=15*UI_HEIGHT_UNIT,
  radius=UI_HEIGHT_UNIT,
  width=1*UI_HEIGHT_UNIT,
  height=9*UI_HEIGHT_UNIT,
  draw=function(self)
    local value = Game.comboTimeLeft / MAX_COMBO_TIMEOUT
      local color = COLOR_GREEN
    if value < 1/3 then
        color = COLOR_RED
      elseif value < 2/3 then
        color = COLOR_YELLOW
      end

    local NUM_SEGMENTS = 9
    local maxFill = 1/NUM_SEGMENTS
    for i=1,NUM_SEGMENTS do
      local fill = math.clamp(value - (i-1) * maxFill, 0, maxFill)
            UI.setColor(color)

      local h = self.height * fill
      love.graphics.rectangle('fill',
        self.x - self.width/2,
        self.y + ((NUM_SEGMENTS-i) * (maxFill)) * self.height + (maxFill-fill) * self.height,
        self.width,
        h
        )

      UI.setColor(COLOR_BLACK)
      love.graphics.rectangle('fill',
        self.x - self.width/2,
        self.y + ((NUM_SEGMENTS-i) * (maxFill)) * self.height + maxFill * self.height,
        self.width,
        UI_HEIGHT_UNIT * 0.2
        )
    end

    UI.setColor(COLOR_WHITE)
    love.graphics.setLineWidth(BALL_LINE_WIDTH_IN)
    love.graphics.rectangle('line', self.x - self.width/2, self.y, self.width, self.height)


    UI.setColor(COLOR_WHITE)
    love.graphics.setLineWidth(BALL_LINE_WIDTH_OUT)
    local w = self.width + 2*BALL_LINES_DISTANCE
    local h = self.height + 2 * BALL_LINES_DISTANCE
    love.graphics.rectangle('line', self.x - w/2, self.y - BALL_LINES_DISTANCE, w, h)
    --[[ Circular
    local angle = math.pi * value
    love.graphics.arc('fill', self.x, self.y, self.radius, 0, -angle)
    UI.setColor(COLOR_WHITE)
    love.graphics.arc('line', self.x, self.y + self.lineWidth/2, self.radius + self.lineWidth/2, 0, -math.pi)
    ]]--


  end,
}

--[[
Text{
  name='speed',
  layer=LAYER_HUD,
  condition=False(),
  --condition = And(function() return Game.combo > 0 end, inGameState(STATE_GAME_RUNNING, STATE_GAME_PAUSED, STATE_GAME_LOST)),
  x=BORDER_THICKNESS/2,
  y=18*UI_HEIGHT_UNIT,
  font=FONT_XS,
  color=3,
  width=BORDER_THICKNESS,
  getText = function()
    return 'Speed: '..Game.meanSpeed
  end,
}
]]--

-- Container
--[[Rectangle{
  x=BASE_SCREEN_WIDTH - 100 - 1.1*MAX_RADIUS,
  y=20 + 20,
  width=2*1.1*MAX_RADIUS,
  height=2*1.1*MAX_RADIUS,
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
--}
