require 'ui/base'
local Backend = require 'backend'

Text{
  name='leaderboard title',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_LEADERBOARD, STATE_GAME_LEADERBOARD_LOADING),
  x=BASE_SCREEN_WIDTH/2,
  y=2*UI_HEIGHT_UNIT,
  font=FONT_MD,
  color=4,
  width=HOLE_WIDTH*1.4,
  getText= function()
    return 'top players'
  end,
}

Text{
  name='Loading Leaderboard',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_LEADERBOARD_LOADING),
  x=BASE_SCREEN_WIDTH/2,
  y=6*UI_HEIGHT_UNIT,
  font=FONT_SM,
  color=COLOR_PINK,
  width=HOLE_WIDTH,
  getText= function()
    return 'loading...'
  end,
}

for i=1,10 do
  Text{
    name='leader'..i,
    layer=LAYER_MENUS,
    condition=And(function() return Backend.top10Error == nil end ,inGameState(STATE_GAME_LEADERBOARD)),
    x=BASE_SCREEN_WIDTH/2 - HOLE_WIDTH/6,
    y=2*(i + 2)*UI_HEIGHT_UNIT,
    font=FONT_SM,
    getColor=function(self)
      return (not Backend.isOffline) and Backend.top10Data[i].username == Backend.userData.username and COLOR_GREEN or COLOR_BLUE
    end,
    width=HOLE_WIDTH,
    getText= function()
      local user = Backend.top10Data[i]
      return string.format('%-10s', user.username)
    end,
  }
  Text{
    name='leader'..i,
    layer=LAYER_MENUS,
    condition=And(function() return Backend.top10Error == nil end ,inGameState(STATE_GAME_LEADERBOARD)),
    x=BASE_SCREEN_WIDTH/2 + HOLE_WIDTH/3.5,
    y=2*(i + 2)*UI_HEIGHT_UNIT,
    font=FONT_SM,
    getColor=function(self)
      return (not Backend.isOffline) and Backend.top10Data[i].username == Backend.userData.username and COLOR_GREEN or COLOR_BLUE
    end,
    width=HOLE_WIDTH,
    getText= function()
      local user = Backend.top10Data[i]
      return string.format('%5d', user.score)
    end,
  }

end

Text{
  name='top10 error',
  layer=LAYER_MENUS,
  condition=And(function() return Backend.top10Error ~= nil end ,inGameState(STATE_GAME_LEADERBOARD)),
  x = BASE_SCREEN_WIDTH/2,
  y=8*UI_HEIGHT_UNIT,
  font = FONT_SM,
  color= COLOR_RED,
  width=HOLE_WIDTH,
  getText=function()
    return 'Error: \n'..Backend.top10Error
  end,
}

Button{
  name='retry',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_LEADERBOARD, STATE_GAME_LEADERBOARD_LOADING),
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
    return Backend.top10Error and 'retry' or 'refresh'
  end,
  onPress = function(self, x, y)
    Backend.top10Error = nil
    Backend.GetTopPlayers()
    if Game.highscoreStats then
      Backend.SendStats(Game.highscoreStats)
    end
  end,
}

Button{
  name='back',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_LEADERBOARD, STATE_GAME_LEADERBOARD_LOADING),
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
    return 'back'
  end,
  onPress = function(self, x, y)
    Game.state:pop()
  end,
}

