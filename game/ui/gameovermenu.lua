require 'ui/base'

-- Game Over Menu
Text{
  name='game over',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_OVER),
  x=BASE_SCREEN_WIDTH/2,
  y=09*UI_HEIGHT_UNIT,
  font=FONT_LG,
  color=7,
  width=HOLE_WIDTH,
  getText = function()
    return 'game over'
  end,
}

Text{
  name='finalscore',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_OVER),
  x=BASE_SCREEN_WIDTH/2,
  y=14*UI_HEIGHT_UNIT,
  font=FONT_MD,
  color=1,
  width=HOLE_WIDTH,
  getText = function()
    return string.format('final score:\n%04d', Game.score)
  end,
}

Text{
  name='newHighScore',
  layer=LAYER_MENUS,
  condition=And(inGameState(STATE_GAME_OVER), function() return Game.newHighScore end),
  x=BASE_SCREEN_WIDTH/2,
  y=17.5*UI_HEIGHT_UNIT,
  font=FONT_SM,
  color=4,
  width=HOLE_WIDTH,
  getText = function()
    return 'new high score!'
  end,
}

--[[
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
]]--

Button{
  name='replay button',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_OVER),
  x=BASE_SCREEN_WIDTH/2,
  y=20*UI_HEIGHT_UNIT,
  width=HOLE_WIDTH * 0.8,
  height=2*UI_HEIGHT_UNIT,
  lineColor=1,
  lineWidth=3,
  font=FONT_MD,
  textColor=1,
  color=COLOR_BLACK,
  getText = function() 
    return 'replay'
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
  y=24*UI_HEIGHT_UNIT,
  width=HOLE_WIDTH * 0.8,
  height=2*UI_HEIGHT_UNIT,
  lineColor=1,
  lineWidth=3,
  font=FONT_MD,
  textColor=1,
  color=COLOR_BLACK,
  getText = function() 
    return 'quit'
  end,
  onPress = function(self, x, y)
    Game.state:push(STATE_GAME_MAINMENU)
  end,
}


