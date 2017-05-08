require 'ui/base'

Text{
  name='subtitle',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_MAINMENU),
  x=BASE_SCREEN_WIDTH/2,
  y=11*UI_HEIGHT_UNIT,
  font=FONT_MD,
  color=7,
  width=HOLE_WIDTH,
  getText = function()
    return 'Definetely not'
  end,
}

Text{
  name='title',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_MAINMENU),
  x=BASE_SCREEN_WIDTH/2,
  y=14*UI_HEIGHT_UNIT,
  font=FONT_XL,
  color=6,
  width=HOLE_WIDTH,
  getText = function()
    return 'Balltris'
  end,
}

Button{
  name='play button',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_MAINMENU),
  x=BASE_SCREEN_WIDTH/2,
  y=22*UI_HEIGHT_UNIT,
  width=HOLE_WIDTH * 0.8,
  height=2*UI_HEIGHT_UNIT,
  color=0,
  lineColor=1,
  lineWidth=3,
  font=FONT_MD,
  textColor=1,
  getText = function() 
    return 'New'
  end,
  onPress = function(self, x, y)
    Game.start()
  end,
}

