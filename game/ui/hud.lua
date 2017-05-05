require 'ui/base'

Text{
  name='loading',
  layer=LAYER_HUD,
  condition=inGameState(STATE_GAME_LOADING),
  x=BASE_SCREEN_WIDTH/2,
  y=BASE_SCREEN_HEIGHT/2,
  font=love.graphics.newFont(MAIN_UI_FONT, 28),
  color=1,
  width=1000,
  getText = function()
    return 'Loading...'
  end,
}


Rectangle{
  name='limitline',
  layer=LAYER_HUD,
  condition=Not(inGameState(STATE_GAME_LOADING)),
  x=BASE_SCREEN_WIDTH/2,
  y=MIN_DISTANCE_TO_TOP,
  width=HOLE_WIDTH,
  height=1,
  lineWidth=2,
  lineColor=1,
}

Text{
  name='nextballs',
  layer=LAYER_HUD,
  condition=inGameState(STATE_GAME_RUNNING),
  x=-BORDER_THICKNESS/2,
  y=30,
  font=love.graphics.newFont(MAIN_UI_FONT, 28),
  color=1,
  width=1000,
  getText = function()
    return 'Next Balls'
  end,
}

-- Score stuff
Text{
  name='highscore',
  layer=LAYER_HUD,
  condition=inGameState(STATE_GAME_RUNNING, STATE_GAME_PAUSED),
  x=BORDER_THICKNESS/2,
  y=120,
  font=love.graphics.newFont(MAIN_UI_FONT, 40),
  color=1,
  width=100,
  getText = function()
    return string.format('High: %04d', Game.highScore)
  end,
}

Text{
  name='score',
  layer=LAYER_HUD,
  condition=inGameState(STATE_GAME_RUNNING, STATE_GAME_PAUSED),
  x=BORDER_THICKNESS/2,
  y=240,
  font=love.graphics.newFont(MAIN_UI_FONT, 40),
  color=1,
  width=180,
  getText = function()
    return string.format('Score: %04d', Game.score)
  end,
}

Text{
  name='combo',
  layer=LAYER_HUD,
  condition = And(function() return Game.combo > 0 end, inGameState(STATE_GAME_RUNNING, STATE_GAME_PAUSED)),
  x=BORDER_THICKNESS/2,
  y=320,
  font=love.graphics.newFont(MAIN_UI_FONT, 30),
  color=1,
  width=180,
  getText = function()
    return 'Combo: x'..Game.combo
  end,
}

-- Game Menus
Button{
  name='open menu',
  layer=LAYER_HUD,
  condition=inGameState(STATE_GAME_RUNNING, STATE_GAME_PAUSED),
  x=BORDER_THICKNESS/2,
  y=40,
  width=100,
  height=50,
  lineWidth = 5,
  lineColor=1,
  font=love.graphics.newFont(MAIN_UI_FONT, 35),
  textColor=1,
  getText = function()
    return 'Menu'
  end,
  onPress = function() 
    Game.state = STATE_GAME_PAUSED
  end,
}
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
