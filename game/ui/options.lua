require 'ui/base'
local Backend = require 'backend'
local LocalSave = require 'localsave'
local NewPalette = require 'palette'

Text{
  name='options title',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_OPTIONS),
  x=BASE_SCREEN_WIDTH/2,
  y=2*UI_HEIGHT_UNIT,
  font=FONT_MD,
  color=COLOR_YELLOW,
  width=HOLE_WIDTH*1.4,
  getText= function()
    return 'options'
  end,
}

Button{
  name='go online',
  layer=LAYER_MENUS,
  condition=And(function() return Backend.isOffline end,  inGameState(STATE_GAME_OPTIONS)),
  x=BASE_SCREEN_WIDTH/2,
  y=12*UI_HEIGHT_UNIT,
  width=HOLE_WIDTH * 0.8,
  height=2*UI_HEIGHT_UNIT,
  color=0,
  lineColor=1,
  lineWidth=3,
  font=FONT_SM,
  textColor=1,
  getText = function() 
    return 'go online'
  end,
  onPress = function(self, x, y)
    Backend.ConnectFirstTime()
  end,
}

Button{
  name='go online',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_OPTIONS),
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
    return 'colorblind '..(Game.options.colorblind and 'on' or 'off')
  end,
  onPress = function()
    if not Game.options.colorblind then
      local palette = NewPalette(PALETTE_COLORBLIND_PATH)
      Game.UI.initialize(palette)
    else
      local palette = NewPalette(PALETTE_DEFAULT_PATH)
      Game.UI.initialize(palette)
    end
    Game.options.colorblind = not Game.options.colorblind
    LocalSave.Save(Game)
  end
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
