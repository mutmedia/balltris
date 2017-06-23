require 'ui/base'
local Backend = require 'backend'

Text{
  name='leaderboard title',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_LEADERBOARD),
  x=BASE_SCREEN_WIDTH/2,
  y=2*UI_HEIGHT_UNIT,
  font=FONT_MD,
  color=4,
  width=HOLE_WIDTH*1.4,
  getText= function()
    return 'TOP PLAYERS'
  end,
}


for i=1,10 do
  Text{
    name='leader'..i,
    layer=LAYER_MENUS,
    condition=inGameState(STATE_GAME_LEADERBOARD),
    x=BASE_SCREEN_WIDTH/2,
    y=2*(i + 2)*UI_HEIGHT_UNIT,
    font=FONT_SM,
    getColor=function(self)
      return Backend.top10Data[i].username == Backend.userData.username and
        6 or 5
    end,
    color=5,
    width=HOLE_WIDTH,
    getText= function()
      local user = Backend.top10Data[i]
      return user.username..': '..user.score
    end,
  }
end

Button{
  name='back',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_LEADERBOARD),
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
    return 'Back'
  end,
  onPress = function(self, x, y)
    Game.state = STATE_GAME_MAINMENU
  end,
}

