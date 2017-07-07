require 'ui/base'
local LocalSave = require 'localsave'
local Backend = require 'backend'

-- Game Over Menu
Text{
  name='game over',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_OVER),
  x=BASE_SCREEN_WIDTH/2,
  y=06*UI_HEIGHT_UNIT,
  font=FONT_LG,
  color=7,
  width=HOLE_WIDTH,
  getText = function()
    return 'game\nover'
  end,
}

Text{
  name='finalscore',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_OVER),
  x=BASE_SCREEN_WIDTH/2,
  y=11*UI_HEIGHT_UNIT,
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
  y=14.5*UI_HEIGHT_UNIT,
  font=FONT_SM,
  color=4,
  width=HOLE_WIDTH,
  getText = function()
    return 'new high score!'
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
  y=17*UI_HEIGHT_UNIT,
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
  y=28*UI_HEIGHT_UNIT,
  width=HOLE_WIDTH * 0.8,
  height=2*UI_HEIGHT_UNIT,
  lineColor=1,
  lineWidth=3,
  font=FONT_MD,
  textColor=1,
  color=COLOR_BLACK,
  getText = function() 
    return 'replay'
  end,
  onPress = function(self, x, y)
    Backend.SendStats(Game.stats, Game.number)
    LocalSave.Save(Game)
    Game.start()
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
  lineColor=1,
  lineWidth=3,
  font=FONT_MD,
  textColor=1,
  color=COLOR_BLACK,
  getText = function() 
    return 'quit'
  end,
  onPress = function(self, x, y)
    Backend.SendStats(Game.stats, Game.number)
    LocalSave.Save(Game)
    Game.state:push(STATE_GAME_MAINMENU)
  end,
}




