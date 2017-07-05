require 'ui/base'
local Backend = require 'backend'
local LocalSave = require 'localsave'

Button{
  name='Set user',
  layer=LAYER_MENUS,
  condition=And(function() return Backend.isOffline end,  inGameState(STATE_GAME_OPTIONS)),
  x=BASE_SCREEN_WIDTH/2,
  y=16*UI_HEIGHT_UNIT,
  width=HOLE_WIDTH * 0.8,
  height=2*UI_HEIGHT_UNIT,
  color=0,
  lineColor=1,
  lineWidth=3,
  font=FONT_SM,
  textColor=1,
  getText = function() 
    return 'set username'
  end,
  onPress = function(self, x, y)
    Game.state:push(STATE_GAME_USERNAME)
  end,
}

Button{
  name='slomo type',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_OPTIONS),
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
    return 'slo-mo: '..Game.options.slomoType
  end,
  onPress = function(self, x, y)
    if Game.options.slomoType == OPTIONS_SLOMO_DEFAULT then
      Game.options.slomoType = OPTIONS_SLOMO_REVERSE
    elseif Game.options.slomoType == OPTIONS_SLOMO_REVERSE then
      Game.options.slomoType = OPTIONS_SLOMO_ALWAYSON
    elseif Game.options.slomoType == OPTIONS_SLOMO_ALWAYSON then
      Game.options.slomoType = OPTIONS_SLOMO_DEFAULT
    end
    LocalSave.Save(Game)
  end,
}

Button{
  name='reset tutorial',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_OPTIONS),
  x=BASE_SCREEN_WIDTH/2,
  y=24*UI_HEIGHT_UNIT,
  width=HOLE_WIDTH * 0.8,
  height=2*UI_HEIGHT_UNIT,
  color=COLOR_BLACK,
  getLineColor=function()
    return not Game.IsTutorialReset() and COLOR_WHITE or COLOR_GRAY
  end,
  lineWidth=3,
  font=FONT_SM,
  getText = function() 
    return 'reset tutorial'
  end,
  onPress = function(self, x, y)
    Game.ResetTutorial()
  end,
}

Button{
  name='skip tutorial',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_OPTIONS),
  x=BASE_SCREEN_WIDTH/2,
  y=28*UI_HEIGHT_UNIT,
  width=HOLE_WIDTH * 0.8,
  height=2*UI_HEIGHT_UNIT,
  color=0,
  getLineColor=function()
    return not Game.IsTutorialOver() and COLOR_WHITE or COLOR_GRAY
  end,
  lineWidth=3,
  font=FONT_SM,
  getText = function() 
    return 'skip tutorial'
  end,
  onPress = function(self, x, y)
    Game.SkipTutorial()
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
    return 'back'
  end,
  onPress = function(self, x, y)
    Game.state:pop()
  end,
}
