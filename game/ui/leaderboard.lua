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

local selected = nil

local leaderBoardThing = function(func)
  return function(num)
    return function(obj)
      obj.layer=obj.layer or LAYER_MENUS
      obj.number = num
      obj.width = obj.width or HOLE_WIDTH
      obj.x = obj.x or BASE_SCREEN_WIDTH/2
      obj.y = 2*(num + 2) * UI_HEIGHT_UNIT
      if not obj.color then
        obj.getColor= obj.getColor or function(self)
          return Backend.top10Data[self.number].userid == Backend.userData.id and COLOR_GREEN 
          or selected == self.number and COLOR_RED 
          or COLOR_BLUE
        end
      end
      local basecondition = And(
        function() return Backend.top10Error == nil end ,
        inGameState(STATE_GAME_LEADERBOARD),
        function(self)
          return (Backend.top10Data[self.number] and true or false) 
        end,
        function() return not Backend.isOffline end
        )
      if obj.condition then
        obj.condition = And(obj.condition, basecondition)
      else
        obj.condition = basecondition
      end


      return func(obj)
    end
  end
end

for i=1,10 do
  leaderBoardThing(Rectangle)(i){
    name='leader button '..i,
    color=COLOR_TRANSPARENT,
    height=UI_HEIGHT_UNIT * 1.3,
    onEnter=function(self)
      selected = self.number
    end
  }
  leaderBoardThing(Text)(i){
    name='leader name '..i,
    x=BASE_SCREEN_WIDTH/2 - HOLE_WIDTH/6,
    font=FONT_SM,
    width=HOLE_WIDTH,
    getText= function(self)
      local gameData = Backend.top10Data[self.number]
      return string.format('%-10s', gameData.username)
    end,
  }
  leaderBoardThing(Text)(i){
    name='leader score '..i,
    layer=LAYER_MENUS,
    x=BASE_SCREEN_WIDTH/2 + HOLE_WIDTH/3.5,
    font=FONT_SM,
    getText= function(self)
      local gameData = Backend.top10Data[self.number]
      return string.format('%5d', gameData.stats.score)
    end,
  }
  --[[
  Text{
    name='stats leader '..i,
    layer=LAYER_HUD,
    condition=And(
      function() return Backend.top10Data[i] ~= nil end,
      function() return Backend.top10Error == nil end,
      function() return selected == i end,
      inGameState(STATE_GAME_LEADERBOARD)),
    x=-BORDER_THICKNESS/2,
    y=12*UI_HEIGHT_UNIT + 2.0,
    font=FONT_XS,
    color=COLOR_WHITE,
    width=BORDER_THICKNESS,
    getText = function()
      local str = ''
      local stats = Backend.top10Data[i].stats
      for k, v in pairs(stats) do
        str = str..string.format('%s\n%4.2f\n', k, stats[k])
      end
      return str
    end,
  }
  ]]--
  i = i + 1
end

Text{
  name='stat title',
  layer=LAYER_HUD,
  condition=And(
    function() return selected and true or false end,
    inGameState(STATE_GAME_LEADERBOARD)
    ),
  x=-BORDER_THICKNESS/2,
  y=10*UI_HEIGHT_UNIT, 
  font=FONT_MD,
  color=COLOR_RED,
  width=BORDER_THICKNESS,
  getText = function()
    return 'stats'
  end,
}


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
  getLineColor=function()
    return inGameState(STATE_GAME_LEADERBOARD_LOADING)() and COLOR_GRAY or COLOR_WHITE
  end,
  lineWidth=3,
  font=FONT_MD,
  getText = function() 
    return Backend.top10Error and 'retry' or 'refresh'
  end,
  onPress = function(self, x, y)
    Backend.top10Error = nil
    Game.state:pop()
    Backend.GetTopPlayers()
    --if Game.highscore.stats then
    --Backend.SendStats(Game.highscore.stats, Game.highscore.number)
    --end
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

