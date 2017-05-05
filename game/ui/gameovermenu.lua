require 'ui/base'

-- Game Over Menu
Text{
  name='game over',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_OVER),
  x=BASE_SCREEN_WIDTH/2,
  y=BASE_SCREEN_HEIGHT/2 - 200 - 100,
  font=love.graphics.newFont(MAIN_UI_FONT, 80),
  color=7,
  width=250,
  getText = function()
    return 'Game Over'
  end,
}

Text{
  name='newHighScore',
  layer=LAYER_MENUS,
  condition=And(inGameState(STATE_GAME_OVER), function() return Game.newHighScore end),
  x=BASE_SCREEN_WIDTH/2,
  y=BASE_SCREEN_HEIGHT/2 -130,
  font=love.graphics.newFont(MAIN_UI_FONT, 20),
  color=1,
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
  color=1,
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
  color=1,
  width=400,
  getText = function()
    return string.format('Max combo: %d', Game.maxCombo)
  end,
}

Button{
  name='replay button',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_OVER),
  x=BASE_SCREEN_WIDTH/2,
  y=BASE_SCREEN_HEIGHT/2 + 60,
  width=HOLE_WIDTH * 0.8,
  height=80,
  lineColor=1,
  lineWidth=3,
  font=love.graphics.newFont(MAIN_UI_FONT, 35),
  textColor=1,
  getText = function() 
    return 'Play Again?'
  end,
  onPress = function(self, x, y)
    Game.start()
  end,
}

Button{
  name='game over back to mainmenu',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_OVER),
  x=BASE_SCREEN_WIDTH/2,
  y=BASE_SCREEN_HEIGHT/2 + 210 - 10 - 15,
  width=HOLE_WIDTH * 0.8,
  height=80,
  lineColor=1,
  lineWidth=3,
  font=love.graphics.newFont(MAIN_UI_FONT, 35),
  textColor=1,
  getText = function() 
    return 'EXIT'
  end,
  onPress = function(self, x, y)
    Game.state = STATE_GAME_MAINMENU
  end,
}


