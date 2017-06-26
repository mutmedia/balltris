require 'ui/base'

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
  name='nextballs',
  layer=LAYER_HUD,
  condition=inGameState(STATE_GAME_RUNNING),
  x=-BORDER_THICKNESS/2,
  y=2*UI_HEIGHT_UNIT,
  font=FONT_SM,
  color=1,
  width=BORDER_THICKNESS,
  getText = function()
    return 'Next Balls'
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
    return 'Menu'
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
  name='highscore',
  layer=LAYER_HUD,
  condition=inGameState(STATE_GAME_RUNNING, STATE_GAME_PAUSED, STATE_GAME_LOST),
  x=BORDER_THICKNESS/2,
  y=5*UI_HEIGHT_UNIT,
  font=FONT_MD,
  color=1,
  width=BORDER_THICKNESS,
  getText = function()
    return string.format('High: %04d', Game.highScore)
  end,
}

Text{
  name='score',
  layer=LAYER_HUD,
  condition=inGameState(STATE_GAME_RUNNING, STATE_GAME_PAUSED, STATE_GAME_LOST),
  x=BORDER_THICKNESS/2,
  y=9*UI_HEIGHT_UNIT,
  font=FONT_MD,
  color=1,
  width=BORDER_THICKNESS,
  getText = function()
    return string.format('Score: %04d', Game.score)
  end,
}

Text{
  name='combo',
  layer=LAYER_HUD,
  condition = And(function() return Game.combo > 0 end, inGameState(STATE_GAME_RUNNING, STATE_GAME_PAUSED, STATE_GAME_LOST)),
  x=BORDER_THICKNESS/2,
  y=13*UI_HEIGHT_UNIT,
  font=FONT_XS,
  color=1,
  width=BORDER_THICKNESS,
  getText = function()
    return 'Combo: x'..Game.combo
  end,
}

Text{
  name='combo objective',
  layer=LAYER_HUD,
  condition = True(),
  --condition = And(function() return Game.combo > 0 end, inGameState(STATE_GAME_RUNNING, STATE_GAME_PAUSED, STATE_GAME_LOST)),
  x=BORDER_THICKNESS/2,
  y=15*UI_HEIGHT_UNIT,
  font=FONT_XS,
  color=1,
  width=BORDER_THICKNESS,
  getText = function()
    return 'Objective: ' ..(Game.comboObjectiveCleared and ' CLEARED' or '\nx'..Game.comboObjective)
  end,
}

Custom{
  name='combo thermometer',
  layer=LAYER_HUD,
  condition = inGameState(STATE_GAME_RUNNING, STATE_GAME_PAUSED, STATE_GAME_LOST),
  --condition = And(function() return Game.combo > 0 end, inGameState(STATE_GAME_RUNNING, STATE_GAME_PAUSED, STATE_GAME_LOST)),
  x=BORDER_THICKNESS/2,
  y=18*UI_HEIGHT_UNIT,
  radius=UI_HEIGHT_UNIT,
  lineWidth=5,
  draw=function(self)
    local angle = math.pi * Game.comboTimeLeft / MAX_COMBO_TIMEOUT
    local color = COLOR_RED
    if angle > 2*math.pi/3 then
      color = COLOR_GREEN
    elseif angle > math.pi/3 then
      color = COLOR_YELLOW
    end
    UI.setColor(color)
    love.graphics.arc('fill', self.x, self.y, self.radius, 0, -angle)
    love.graphics.setLineWidth(self.lineWidth)
    UI.setColor(COLOR_WHITE)
    love.graphics.arc('line', self.x, self.y + self.lineWidth/2, self.radius + self.lineWidth/2, 0, -math.pi)
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
