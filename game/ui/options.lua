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
  name='palette',
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
    return 'palette: '..(Game.options.calango and 'gafa' or 'calango')
  end,
  onPress = function()
    if not Game.options.calango then
      local palette = NewPalette(PALETTE_CALANGO_PATH)
      Game.UI.initialize(palette)
    else
      local palette = NewPalette(PALETTE_DEFAULT_PATH)
      Game.UI.initialize(palette)
    end
    Game.options.calango = not Game.options.calango
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
  getText = function() 
    local slomoName = 'default'
    if Game.options.slomoType == OPTIONS_SLOMO_HOLD then
      slomoName = 'hold'
    elseif Game.options.slomoType == OPTIONS_SLOMO_RELEASE then
      slomoName = 'release'
    elseif Game.options.slomoType == OPTIONS_SLOMO_ALWAYSON then
      slomoName = 'always'
    end
    return 'slo-mo: '..slomoName
  end,
  onPress = function(self, x, y)
    if Game.options.slomoType == OPTIONS_SLOMO_HOLD then
      Game.options.slomoType = OPTIONS_SLOMO_RELEASE
    elseif Game.options.slomoType == OPTIONS_SLOMO_RELEASE then
      Game.options.slomoType = OPTIONS_SLOMO_ALWAYSON
    elseif Game.options.slomoType == OPTIONS_SLOMO_ALWAYSON then
      Game.options.slomoType = OPTIONS_SLOMO_HOLD
    end
    LocalSave.Save(Game)
  end,
}

Button{
  name='toggle audio',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_OPTIONS),
  x=BASE_SCREEN_WIDTH/2,
  y=24*UI_HEIGHT_UNIT,
  width=HOLE_WIDTH * 0.8,
  height=2*UI_HEIGHT_UNIT,
  color=COLOR_BLACK,
  lineColor=COLOR_WHITE,
  lineWidth=3,
  font=FONT_SM,
  getText = function(self) 
    return 'audio: '..(Game.options.audio and 'on' or 'off')
  end,
  onPress = function(self, x, y)
    Game.options.audio = not Game.options.audio
  end,
}

Button{
  name='reset/skip tutorial',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_OPTIONS),
  x=BASE_SCREEN_WIDTH/2,
  y=28*UI_HEIGHT_UNIT,
  width=HOLE_WIDTH * 0.8,
  height=2*UI_HEIGHT_UNIT,
  color=COLOR_BLACK,
  skipTutorial=function() 
    return not Game.IsTutorialOver()
  end,
  lineColor=COLOR_WHITE,
  lineWidth=3,
  font=FONT_SM,
  getText = function(self) 
    return self.skipTutorial() and 'skip tutorial' or 'reset tutorial'
  end,
  onPress = function(self, x, y)
    if self.skipTutorial() then 
      Game.SkipTutorial()
    else
      Game.ResetTutorial()
    end
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
