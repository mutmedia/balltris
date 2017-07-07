require 'ui/base'
local Backend = require 'backend'
local Scheduler = require 'lib/scheduler'

Text{
  name='connecting to backend title',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_FIRST_CONNECTION),
  x=BASE_SCREEN_WIDTH/2,
  y=10*UI_HEIGHT_UNIT,
  font=FONT_MD,
  color=COLOR_GREEN,
  width=HOLE_WIDTH*1.4,
  getText= function(self)
    return 'Connecting to backend\n'
  end,
}

Text{
  name='first connection attention',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_FIRST_CONNECTION),
  x=BASE_SCREEN_WIDTH/2,
  y=17*UI_HEIGHT_UNIT,
  font=FONT_SM,
  color=COLOR_YELLOW,
  width=HOLE_WIDTH*1.4,
  getText= function()
    return 'This will only happen once'
  end,
}

Text{
  name='connection loading',
  layer=LAYER_MENUS,
  condition=And(inGameState(STATE_GAME_FIRST_CONNECTION), function() return Game.backendConnectionError == nil end),
  x=BASE_SCREEN_WIDTH/2,
  y=19*UI_HEIGHT_UNIT,
  font=FONT_SM,
  color=COLOR_GREEN,
  width=HOLE_WIDTH*1.4,
  cursorF=0.5,
  transitionTime = 0,
  lastCursorSwap = 0,
  showCursor = true,
  count=0,
  getText= function(self)
    self.count = self.count + 1
    str = ''
    if self.count > 60  then str = str..'.' else str = str..' ' end
    if self.count > 120  then str = str..'.' else str = str..' ' end
    if self.count > 180  then str = str..'.' else str = str..' ' end
    self.count = self.count % 240
    return str
  end,
}


Text{
  name='connection error',
  layer=LAYER_MENUS,
  condition=And(inGameState(STATE_GAME_FIRST_CONNECTION), function() return Game.backendConnectionError ~= nil end),
  x=BASE_SCREEN_WIDTH/2,
  y=19*UI_HEIGHT_UNIT,
  font=FONT_SM,
  color=COLOR_RED,
  width=HOLE_WIDTH*1.4,
  cursorF=0.5,
  transitionTime = 0,
  lastCursorSwap = 0,
  showCursor = true,
  getText= function(self)
    return 'error: '..(Game.backendConnectionError or '')
  end,
}
-- Offline confirmation stuff
Button{
  name='Offline',
  layer=LAYER_MENUS,
  condition=And(inGameState(STATE_GAME_FIRST_CONNECTION), function() return Game.backendConnectionError ~= nil end),
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
    return 'retry'
  end,
  onPress = function(self, x, y)
    Backend.ConnectFirstTime()
  end,
}


-- Offline confirmation stuff
Button{
  name='Offline',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_FIRST_CONNECTION),
  x=BASE_SCREEN_WIDTH/2,
  y=32*UI_HEIGHT_UNIT,
  width=HOLE_WIDTH * 0.8,
  height=2*UI_HEIGHT_UNIT,
  color=0,
  lineColor=1,
  lineWidth=3,
  font=FONT_XS,
  textColor=1,
  getText = function() 
    return 'play offline'
  end,
  onPress = function(self, x, y)
    Game.state:push(STATE_GAME_OFFLINE_CONFIRMATION)
    Scheduler.add(function() 
      if Game.inState(STATE_GAME_OFFLINE_CONFIRMATION) then
        Game.state:push(STATE_GAME_MAINMENU)
      end
    end, 7) -- Offline confirmation will exit after 7 seconds
end,
}


Text{
  name='offline confirmation message',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_OFFLINE_CONFIRMATION),
  x=BASE_SCREEN_WIDTH/2,
  y=16*UI_HEIGHT_UNIT,
  font=FONT_SM,
  color=COLOR_YELLOW,
  width=HOLE_WIDTH*1.4,
  cursorF=0.5,
  transitionTime = 0,
  lastCursorSwap = 0,
  showCursor = true,
  getText= function(self)
    return 'You can go online to compete in the leaderboards at any time by changing the settings in the options menu'
  end,
}

Button{
  name='offline confirmation ok',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_OFFLINE_CONFIRMATION),
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
    return 'ok'
  end,
  onPress = function(self, x, y)
    Game.state:push(STATE_GAME_MAINMENU)
  end,
}


