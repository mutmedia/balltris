require 'ui/base'
local Backend = require 'backend'

Text{
  name='leaderboard title',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_LEADERBOARD, STATE_GAME_LEADERBOARD_LOADING, STATE_GAME_LEADERBOARD_STATS),
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
  name='leaderboard title',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_LEADERBOARD, STATE_GAME_LEADERBOARD_LOADING),
  x=BASE_SCREEN_WIDTH/2,
  y=3.5*UI_HEIGHT_UNIT,
  font=FONT_XS,
  color=4,
  width=HOLE_WIDTH*1.4,
  getText= function()
    return 'click on entry for stats'
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
      Game.selectedLeaderboardGame = self.number
      Game.state:push(STATE_GAME_LEADERBOARD_STATS)
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
  i = i + 1
end


Text{
  name='stat name',
  layer=LAYER_HUD,
  condition=And(
    function() return Game.selectedLeaderboardGame ~= nil end,
    inGameState(STATE_GAME_LEADERBOARD_STATS)),
  x=BASE_SCREEN_WIDTH/2 - HOLE_WIDTH/6,
  y=6*UI_HEIGHT_UNIT, 
  font=FONT_SM,
  getColor = function(self)
    return Backend.top10Data[Game.selectedLeaderboardGame].userid == Backend.userData.id and COLOR_GREEN 
    or COLOR_BLUE
  end,
  width=BORDER_THICKNESS,
  getText = function()
    local gameData = Backend.top10Data[Game.selectedLeaderboardGame]
    return string.format('%-10s', gameData.username)
  end,
}

Text{
  name='stat score',
  layer=LAYER_HUD,
  condition=And(
    function() return Game.selectedLeaderboardGame ~= nil end,
    inGameState(STATE_GAME_LEADERBOARD_STATS)),
  x=BASE_SCREEN_WIDTH/2 + HOLE_WIDTH/3.5,
  y=6*UI_HEIGHT_UNIT, 
  font=FONT_SM,
  getColor = function(self)
    return Backend.top10Data[Game.selectedLeaderboardGame].userid == Backend.userData.id and COLOR_GREEN 
    or COLOR_BLUE
  end,
  width=BORDER_THICKNESS,
  getText = function()
    local gameData = Backend.top10Data[Game.selectedLeaderboardGame]
    return string.format('%5d', gameData.stats.score)
  end,
}

Text{
  name='stat title',
  layer=LAYER_HUD,
  condition=And(
    function() return Game.selectedLeaderboardGame ~= nil end,
    inGameState(STATE_GAME_LEADERBOARD_STATS)),
  x=BASE_SCREEN_WIDTH/2,
  y=9*UI_HEIGHT_UNIT, 
  font=FONT_MD,
  color=COLOR_WHITE,
  width=BORDER_THICKNESS,
  getText = function()
    return 'Stats'
  end,
}

Text{
  name='stats leader text',
  layer=LAYER_HUD,
  condition=And(
    function() return Game.selectedLeaderboardGame ~= nil end,
    inGameState(STATE_GAME_LEADERBOARD_STATS)),
  x=BASE_SCREEN_WIDTH/2 - HOLE_WIDTH/6,
  y=11*UI_HEIGHT_UNIT ,
  font=FONT_SM,
  color=COLOR_WHITE,
  width=HOLE_WIDTH,
  getText = function()
    local str = ''
    for _, v in pairs(LEADERBOARD_STATS) do
      local statStr = ''
      statStr = statStr..v.name
      statStr = statStr..'\n'
      str = str..statStr
    end
    return str
  end,
}

Text{
  name='stats leader values',
  layer=LAYER_HUD,
  condition=And(
    function() return Game.selectedLeaderboardGame ~= nil end,
    inGameState(STATE_GAME_LEADERBOARD_STATS)),
  x=BASE_SCREEN_WIDTH/2 + HOLE_WIDTH/3.5,
  y=11*UI_HEIGHT_UNIT ,
  font=FONT_SM,
  color=COLOR_WHITE,
  width=HOLE_WIDTH,
  getText = function()
    local str = ''
    local stats = Backend.top10Data[Game.selectedLeaderboardGame].stats
    for _, v in pairs(LEADERBOARD_STATS) do
      local stat = stats[v.key]
      if stat then
        local statStr = ''
        statStr = statStr..string.format(v.text, stat)
        statStr = statStr..'\n'
        str = str..statStr
      else
        str = str..'nil\n'
      end
    end
    return str
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
  condition=inGameState(STATE_GAME_LEADERBOARD, STATE_GAME_LEADERBOARD_LOADING, STATE_GAME_LEADERBOARD_STATS),
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
    Game.selectedLeaderboardGame = nil
    Game.state:pop()
  end,
}


