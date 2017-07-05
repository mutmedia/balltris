require 'ui/base'
local Scheduler = require 'lib/scheduler'
local Backend = require 'backend'

Rectangle{
  name='leave enter username',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_USERNAME),
  x=BASE_SCREEN_WIDTH/2,
  y=BASE_SCREEN_HEIGHT/2,
  color=COLOR_TRANSPARENT,
  height=BASE_SCREEN_HEIGHT, 
  width=BASE_SCREEN_WIDTH, 
  onPress = function(self, x, y)
    love.keyboard.setTextInput(false)
  end
}

Text{
  name='enter username title',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_USERNAME, STATE_GAME_USERNAME_LOADING),
  x=BASE_SCREEN_WIDTH/2,
  y=10*UI_HEIGHT_UNIT,
  font=FONT_MD,
  color=4,
  width=HOLE_WIDTH*1.4,
  getText= function()
    return 'enter username'
  end,
}


Button{
  name='enter username',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_USERNAME, STATE_GAME_USERNAME_LOADING),
  x=BASE_SCREEN_WIDTH/2,
  y=16*UI_HEIGHT_UNIT,
  font=FONT_MD,
  height=2*UI_HEIGHT_UNIT,
  color=1,
  textColor=6,
  width=HOLE_WIDTH*1.4,
  cursorF=0.5,
  lastCursorSwap = 0,
  showCursor = true,
  getText= function(self)
    if self.lastCursorSwap + self.cursorF < Game.totalTime then
      self.showCursor = not self.showCursor
      self.lastCursorSwap = Game.totalTime
    end

    if Game.state == STATE_GAME_USERNAME_LOADING then self.showCursor = false end
    return Game.usernameText..(self.showCursor and '_' or '') 
  end,
  onPress = function(self, x, y)
    if Game.state == STATE_GAME_USERNAME_LOADING then return end
    if not love.keyboard.hasTextInput() then
      Game.usernameText = ''
    end
    love.keyboard.setTextInput(true)
  end
}



Text{
  name='invalid username',
  layer=LAYER_MENUS,
  condition=And(inGameState(STATE_GAME_USERNAME), function() return Game.usernameErrorMsg and true or false end),
  x=BASE_SCREEN_WIDTH/2,
  y=18*UI_HEIGHT_UNIT,
  font=FONT_SM,
  color=COLOR_RED,
  width=HOLE_WIDTH*1.4,
  cursorF=0.5,
  transitionTime = 0,
  lastCursorSwap = 0,
  showCursor = true,
  getText= function(self)
    return 'error: '..(Game.usernameErrorMsg or '')
  end,
}

Button{
  name='Submit username',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_USERNAME, STATE_GAME_USERNAME_LOADING),
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
    if Game.state == STATE_GAME_USERNAME_LOADING then return 'loading...' end
    return 'enter'
  end,
  onPress = function(self, x, y)
    if Game.state == STATE_GAME_USERNAME_LOADING then return end
    Game.state = STATE_GAME_USERNAME_LOADING
    love.keyboard.setTextInput(false)
    Backend.tryCreateUser(Game.usernameText)
  end,
}

Button{
  name='Offline',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_USERNAME),
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
    return 'offline'
  end,
  onPress = function(self, x, y)
    Game.state = STATE_GAME_OFFLINE_CONFIRMATION
    Scheduler.add(function() 
      if Game.state == STATE_GAME_OFFLINE_CONFIRMATION then
        Game.state = STATE_GAME_MAINMENU
      end
    end, 7) -- Offline confirmation will exit after 7 seconds
end,
}

-- Offline confirmation stuff

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
    return 'You can add a username to compete in the leaderboards at any time by changing the settings in the options menu'
  end,
}

Button{
  name='Enter',
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
    Game.state = STATE_GAME_MAINMENU
  end,
}

