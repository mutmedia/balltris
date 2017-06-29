require 'ui/base'
local SaveSystem = require 'savesystem'
local Backend = require 'backend'
local Scheduler = require 'lib/scheduler'


local BlinkingText = function(textObj)
  textObj.colorF = 0.75
  textObj.lastColorSwap = 0
  textObj.lastColor = math.floor(3 + math.random() * 5)
  textObj.getColor = function(self)
    if self.lastColorSwap + self.colorF < Game.totalTime then
      self.lastColor = math.floor(3 + math.random() * 5)
      self.lastColorSwap = Game.totalTime
    end
    return self.lastColor
  end
  return Text(textObj)
end

BlinkingText{
  name='subtitle',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_MAINMENU),
  x=BASE_SCREEN_WIDTH/2,
  y=11*UI_HEIGHT_UNIT,
  font=FONT_MD,
  width=HOLE_WIDTH,
  getText = function()
    return 'Synth'
  end,
}

BlinkingText{
  name='title',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_MAINMENU),
  x=BASE_SCREEN_WIDTH/2,
  y=14*UI_HEIGHT_UNIT,
  font=FONT_XL,
  width=HOLE_WIDTH,
  getText = function()
    return 'Balls'
  end,
}

Button{
  name='new game button',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_MAINMENU),
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
    return 'New'
  end,
  onPress = function(self, x, y)
    SaveSystem.clearSave()
    Game.start()
  end,
}

Button{
  name='continue button',
  layer=LAYER_MENUS,
  condition=And(
    inGameState(STATE_GAME_MAINMENU),
    function() return SaveSystem.CreateLoadFunc or false end),
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
    return 'Continue'
  end,
  onPress = function(self, x, y)
    Game.start(SaveSystem.CreateLoadFunc())
  end,
}
 
Button{
  name='top10 button',
  layer=LAYER_MENUS,
  condition=And(
    inGameState(STATE_GAME_MAINMENU),
    function() return SaveSystem.CreateLoadFunc or false end),
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
    return 'Top 10'
  end,
  onPress = function(self, x, y)
    Game.state = STATE_GAME_LEADERBOARD_LOADING
    Scheduler.add(function() 
      Backend.getTopPlayers()
      Game.state = STATE_GAME_LEADERBOARD
    end, 0.1)
  end,
}

Button{
  name='options button',
  layer=LAYER_MENUS,
  condition=And(
    inGameState(STATE_GAME_MAINMENU),
    function() return SaveSystem.CreateLoadFunc or false end),
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
    return 'Options'
  end,
  onPress = function(self, x, y)
    Game.state = STATE_GAME_OPTIONS
  end,
}

  
