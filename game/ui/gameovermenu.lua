require 'ui/base'

-- Game Over Menu
Text{
  name='game over',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_OVER),
  x=BASE_SCREEN_WIDTH/2,
  y=10*UI_HEIGHT_UNIT,
  font=FONT_LG,
  color=7,
  width=HOLE_WIDTH,
  getText = function()
    return 'Game Over'
  end,
}

Text{
  name='finalscore',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_OVER),
  x=BASE_SCREEN_WIDTH/2,
  y=15*UI_HEIGHT_UNIT,
  font=FONT_MD,
  color=1,
  width=HOLE_WIDTH,
  getText = function()
    return string.format('Final Score:\n%04d', Game.score)
  end,
}

Text{
  name='newHighScore',
  layer=LAYER_MENUS,
  condition=And(inGameState(STATE_GAME_OVER), function() return Game.newHighScore end),
  x=BASE_SCREEN_WIDTH/2,
  y=19*UI_HEIGHT_UNIT,
  font=FONT_SM,
  color=4,
  width=HOLE_WIDTH,
  getText = function()
    return 'New High Score!'
  end,
}

Text{
  name='maxcombo',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_OVER),
  x=BASE_SCREEN_WIDTH/2,
  y=21*UI_HEIGHT_UNIT,
  font=FONT_MD,
  color=1,
  width=HOLE_WIDTH,
  getText = function()
    return string.format('Best combo:\n%d', Game.maxCombo)
  end,
}

Button{
  name='replay button',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_OVER),
  x=BASE_SCREEN_WIDTH/2,
  y=26*UI_HEIGHT_UNIT,
  width=HOLE_WIDTH * 0.8,
  height=2*UI_HEIGHT_UNIT,
  lineColor=1,
  lineWidth=3,
  font=FONT_MD,
  textColor=1,
  getText = function() 
    return 'Replay'
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
  y=30*UI_HEIGHT_UNIT,
  width=HOLE_WIDTH * 0.8,
  height=2*UI_HEIGHT_UNIT,
  lineColor=1,
  lineWidth=3,
  font=FONT_MD,
  textColor=1,
  getText = function() 
    return 'Quit'
  end,
  onPress = function(self, x, y)
    Game.state = STATE_GAME_MAINMENU
  end,
}


