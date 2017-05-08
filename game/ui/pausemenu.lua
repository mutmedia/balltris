require 'ui/base'

Button{
  name='gamemenu unpouse',
  condition=inGameState(STATE_GAME_PAUSED),
  layer=LAYER_MENUS,
  x=BASE_SCREEN_WIDTH/2,
  y=16*UI_HEIGHT_UNIT,
  height=2*UI_HEIGHT_UNIT,
  width=HOLE_WIDTH * 0.8,
  color=0,
  lineColor=1,
  lineWidth = 5,
  font=FONT_MD,
  textColor=1,
  getText = function()
    return 'Unpause'
  end,
  onPress = function() 
    Game.state = STATE_GAME_RUNNING
  end,
}

Button{
  name='restart button',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_PAUSED),
  x=BASE_SCREEN_WIDTH/2,
  y=20*UI_HEIGHT_UNIT,
  width=HOLE_WIDTH * 0.8,
  height=2*UI_HEIGHT_UNIT,
  color=0,
  lineColor=1,
  lineWidth=3,
  font=FONT_MD,
  textColor=1,
  getText = function() 
    return 'Restart'
  end,
  onPress = function(self, x, y)
    Game.start()
  end,
}

Button{
  name='pause back to mainmenu',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_PAUSED),
  x=BASE_SCREEN_WIDTH/2,
  y=24*UI_HEIGHT_UNIT,
  width=HOLE_WIDTH * 0.8,
  height=2*UI_HEIGHT_UNIT,
  color=0,
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
