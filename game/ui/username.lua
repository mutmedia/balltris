require 'ui/base'
local Scheduler = require 'lib/scheduler'
local Backend = require 'backend'

Text{
  name='enter username title',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_USERNAME),
  x=BASE_SCREEN_WIDTH/2,
  y=10*UI_HEIGHT_UNIT,
  font=FONT_MD,
  color=4,
  width=HOLE_WIDTH*1.4,
  getText= function()
    return 'Enter Username'
  end,
}

Text{
  name='enter username',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_USERNAME),
  x=BASE_SCREEN_WIDTH/2,
  y=16*UI_HEIGHT_UNIT,
  font=FONT_MD,
  color=6,
  width=HOLE_WIDTH*1.4,
  cursorF=0.5,
  lastCursorSwap = 0,
  showCursor = true,
  getText= function(self)
    if self.lastCursorSwap + self.cursorF < Game.totalTime then
      self.showCursor = not self.showCursor
      self.lastCursorSwap = Game.totalTime
    end
    return Game.usernameText..(self.showCursor and '_' or '') 
  end,
}

Text{
  name='invalid username',
  layer=LAYER_MENUS,
  condition=And(inGameState(STATE_GAME_USERNAME), function() return Game.invalidUsername == true end),
  x=BASE_SCREEN_WIDTH/2,
  y=18*UI_HEIGHT_UNIT,
  font=FONT_SM,
  color=7,
  width=HOLE_WIDTH*1.4,
  cursorF=0.5,
  transitionTime = 0,
  lastCursorSwap = 0,
  showCursor = true,
  getText= function(self)
    return 'invalid username'
  end,
}

Button{
  name='Enter',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_USERNAME),
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
    return 'Enter'
  end,
  onPress = function(self, x, y)
    local validUser = Backend.tryCreateUser(Game.usernameText)
    if validUser then
      Game.state = STATE_GAME_MAINMENU
    else
      Game.invalidUsername = true
      Scheduler.add(function() Game.invalidUsername = false end, 4)
    end
  end,
}

