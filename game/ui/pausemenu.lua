require 'ui/base'
local LocalSave = require 'localsave'

Text{
  name='pause title',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_PAUSED),
  x=BASE_SCREEN_WIDTH/2,
  y=10*UI_HEIGHT_UNIT,
  font=FONT_MD,
  color=COLOR_PINK,
  width=HOLE_WIDTH*1.4,
  getText= function()
    return 'PAUSED'
  end,
}

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
  lineWidth = 3,
  font=FONT_MD,
  textColor=1,
  getText = function()
    return 'unpause'
  end,
  onPress = function() 
    Game.state:push(STATE_GAME_RUNNING)
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
    return 'restart'
  end,
  onPress = function(self, x, y)
    Game.start()
  end,
}

Button{
  name='options button pause',
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
    return 'options'
  end,
  onPress = function(self, x, y)
    Game.state:push(STATE_GAME_OPTIONS)
  end,
}

Button{
  name='pause back to mainmenu',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_PAUSED),
  x=BASE_SCREEN_WIDTH/2,
  y=28*UI_HEIGHT_UNIT,
  width=HOLE_WIDTH * 0.8,
  height=2*UI_HEIGHT_UNIT,
  color=0,
  lineColor=1,
  lineWidth=3,
  font=FONT_MD,
  textColor=1,
  getText = function() 
    return 'quit'
  end,
  onPress = function(self, x, y)
    Game.state:push(STATE_GAME_MAINMENU)
  end,
}
--[[
Rectangle{
  name="animation cover",
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_PAUSED),
  x=BASE_SCREEN_WIDTH/2, 
  y=14*UI_HEIGHT_UNIT,
  width=HOLE_WIDTH * 0.9,
  height=14*0,
  color=0,
  transitionTime=0.5,
  transitionIn=function(self, dt)
    return {
      anchor = {x=0, y=-1},
      y=26*UI_HEIGHT_UNIT,
      height = 14*UI_HEIGHT_UNIT - 14*UI_HEIGHT_UNIT*dt/self.transitionTime,
    }
  end,
  transitionOut=function(self, dt)
    return {
      anchor = {x=0, y=1},
      y=14*UI_HEIGHT_UNIT,
      height = 14*UI_HEIGHT_UNIT*dt/self.transitionTime,
    }
  end

}
]]--

