require 'ui/base'
local LocalSave = require 'localsave'
local Backend = require 'backend'

-- Game Over Menu
Text{
  name='game over',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_OVER),
  x=BASE_SCREEN_WIDTH/2,
  y=02*UI_HEIGHT_UNIT,
  font=FONT_MD,
  color=7,
  width=HOLE_WIDTH,
  getText = function()
    return 'game over'
  end,
}

Text{
  name='finalscore',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_OVER),
  x=BASE_SCREEN_WIDTH/2,
  y=06*UI_HEIGHT_UNIT,
  font=FONT_MD,
  color=1,
  width=HOLE_WIDTH,
  getText = function()
    return string.format('final score:\n%04d', Game.score)
  end,
}

Text{
  name='newHighScore',
  layer=LAYER_MENUS,
  condition=And(inGameState(STATE_GAME_OVER), function() return Game.newHighScore end),
  x=BASE_SCREEN_WIDTH/2,
  y=09.5*UI_HEIGHT_UNIT,
  font=FONT_SM,
  color=4,
  width=HOLE_WIDTH,
  getText = function()
    return 'new personal best!'
  end,
}

-- High score username stuff
Rectangle{
  name='leave enter username',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_OVER),
  x=BASE_SCREEN_WIDTH/2,
  y=BASE_SCREEN_HEIGHT/2,
  color=COLOR_TRANSPARENT,
  height=BASE_SCREEN_HEIGHT, 
  width=BASE_SCREEN_WIDTH, 
  onPress = function(self, x, y)
    love.keyboard.setTextInput(false)
  end
}


Button{
  name='enter username',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_OVER),
  x=BASE_SCREEN_WIDTH/2,
  y=12*UI_HEIGHT_UNIT,
  font=FONT_SM,
  height=1.5*UI_HEIGHT_UNIT,
  color=COLOR_BLACK,
  lineColor=COLOR_WHITE,
  lineWidth=2,
  --textColor=COLOR_YELLOW,
  width=HOLE_WIDTH * 0.9,
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
  onPress = function(self, x, y)
    --if Game.inState(STATE_GAME_USERNAME_LOADING) then return end
    if not love.keyboard.hasTextInput() then
      Game.usernameText = ''
    end
    love.keyboard.setTextInput(true)
    --Game.usernameErrorMsg = nil
  end
}

Text{
  name='invalid username',
  layer=LAYER_MENUS,
  condition=And(
    inGameState(STATE_GAME_OVER), 
    function() 
      return not Backend.CheckUsername(Game.usernameText)
    end),
  x=BASE_SCREEN_WIDTH/2,
  y=14*UI_HEIGHT_UNIT,
  font=FONT_SM,
  color=COLOR_RED,
  width=HOLE_WIDTH*1.4,
  cursorF=0.5,
  transitionTime = 0,
  lastCursorSwap = 0,
  showCursor = true,
  getText= function(self)
    return 'a-z 0-9 only\n3 to 10 characters'
  end,
}

--[[
Text{
  name='maxcombo',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_OVER),
  x=BASE_SCREEN_WIDTH/2,
  y=21*UI_HEIGHT_UNIT,
  font=FONT_MD,
  color=1,
  width=HOLE_WIDTH,
  getText = function()
    return string.format('Best combo:\n%d', Game.maxCombo)
  end,
}
]]--


Button{
  name='replay button',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_OVER),
  x=BASE_SCREEN_WIDTH/2,
  y=20*UI_HEIGHT_UNIT,
  width=HOLE_WIDTH * 0.8,
  height=2*UI_HEIGHT_UNIT,
  getLineColor=function()
      return Backend.CheckUsername(Game.usernameText) and COLOR_WHITE or COLOR_GRAY
  end,
  lineWidth=3,
  font=FONT_SM,
  color=COLOR_BLACK,
  getText = function() 
    return 'play again'
  end,
  onPress = function(self, x, y)
    if not Backend.CheckUsername(Game.usernameText) then return end
    if not Game.sentStats then
      Backend.SendStats(Game.stats, Game.number)
      Game.sentStats = true
    end
    LocalSave.Save(Game)
    Game.start()
  end,
}

Button{
  name='achievements button',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_OVER),
  x=BASE_SCREEN_WIDTH/2,
  y=24*UI_HEIGHT_UNIT,
  width=HOLE_WIDTH * 0.8,
  height=2*UI_HEIGHT_UNIT,
  lineColor=COLOR_WHITE,
  getTextColor=function()
    return Game.achievements.achievedThisGameNums:count() > 0 and COLOR_GREEN or COLOR_WHITE
  end,
  lineWidth=3,
  font=FONT_SM,
  color=COLOR_BLACK,
  getText = function() 
    return 'achievements'
  end,
  onPress = function(self, x, y)
    LocalSave.Save(Game)
    Game.state:push(STATE_GAME_ACHIEVEMENTS)
  end,
}

Button{
  name='leaderboard button',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_OVER),
  x=BASE_SCREEN_WIDTH/2,
  y=28*UI_HEIGHT_UNIT,
  width=HOLE_WIDTH * 0.8,
  height=2*UI_HEIGHT_UNIT,
  color=COLOR_BLACK,
  getLineColor=function()
      return Backend.CheckUsername(Game.usernameText) and COLOR_WHITE or COLOR_GRAY
  end,
  lineWidth=3,
  font=FONT_SM,
  getText = function() 
    return 'leaderboard'
  end,
  onPress = function(self, x, y)
    if not Backend.CheckUsername(Game.usernameText) then return end
    if not Game.sentStats then
      Backend.SendStats(Game.stats, Game.number)
      Game.sentStats = true
    end
    LocalSave.Save(Game)
    Backend.GetTopPlayers()
  end,
}



Button{
  name='game over back to mainmenu',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_OVER),
  x=BASE_SCREEN_WIDTH/2,
  y=32*UI_HEIGHT_UNIT,
  width=HOLE_WIDTH * 0.8,
  height=2*UI_HEIGHT_UNIT,
  getLineColor=function()
      return Backend.CheckUsername(Game.usernameText) and COLOR_WHITE or COLOR_GRAY
  end,
  lineWidth=3,
  font=FONT_SM,
  color=COLOR_BLACK,
  getText = function() 
    return 'main menu'
  end,
  onPress = function(self, x, y)
    if not Backend.CheckUsername(Game.usernameText) then return end
    if not Game.sentStats then
      Backend.SendStats(Game.stats, Game.number)
      Game.sentStats = true
    end
    LocalSave.Save(Game)
    Game.state:push(STATE_GAME_MAINMENU)
  end,
}

