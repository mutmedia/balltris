require 'ui/base'
local Backend = require 'backend'

Button{
  name='Set user',
  layer=LAYER_MENUS,
  condition=And(function() return Backend.isOffline end,  inGameState(STATE_GAME_OPTIONS)),
  x=BASE_SCREEN_WIDTH/2,
  y=20*UI_HEIGHT_UNIT,
  width=HOLE_WIDTH * 0.8,
  height=2*UI_HEIGHT_UNIT,
  color=0,
  lineColor=1,
  lineWidth=3,
  font=FONT_SM,
  textColor=1,
  getText = function() 
    return 'Set username'
  end,
  onPress = function(self, x, y)
    Game.state = STATE_GAME_USERNAME
  end,
}

Button{
  name='Back',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_OPTIONS),
  x=BASE_SCREEN_WIDTH/2,
  y=32*UI_HEIGHT_UNIT,
  width=HOLE_WIDTH * 0.8,
  height=2*UI_HEIGHT_UNIT,
  color=0,
  lineColor=1,
  lineWidth=3,
  font=FONT_MD,
  textColor=1,
  getText = function() 
    return 'Back'
  end,
  onPress = function(self, x, y)
    Game.state = STATE_GAME_MAINMENU
  end,
}
