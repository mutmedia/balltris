require 'ui/base'

Text{
  name='credits title',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_CREDITS),
  x=BASE_SCREEN_WIDTH/2,
  y=2*UI_HEIGHT_UNIT,
  font=FONT_MD,
  color=COLOR_YELLOW,
  width=HOLE_WIDTH*1.4,
  getText= function()
    return 'credits'
  end,
}

Text{
  name='Developer',
  layer=LAYER_HUD,
  condition=inGameState(STATE_GAME_CREDITS),
  x=BASE_SCREEN_WIDTH/2,
  y=6*UI_HEIGHT_UNIT,
  font=FONT_XS,
  color=COLOR_PINK,
  width=BASE_SCREEN_WIDTH,
  getText = function()
    return ("developed by \n%s"):format(CREDITS_DEVELOPER)
  end,
}

Text{
  name='Music',
  layer=LAYER_HUD,
  condition=inGameState(STATE_GAME_CREDITS),
  x=BASE_SCREEN_WIDTH/2,
  y=9*UI_HEIGHT_UNIT,
  font=FONT_XS,
  color=COLOR_BLUE,
  width=BASE_SCREEN_WIDTH,
  getText = function()
    return ("music by \n%s"):format(CREDITS_MUSIC)
  end,
}

Text{
    name='thanks',
    layer=LAYER_HUD,
    condition=inGameState(STATE_GAME_CREDITS),
    x=BASE_SCREEN_WIDTH/2,
    y=(12)*UI_HEIGHT_UNIT,
    font=FONT_XS,
    color=COLOR_GREEN,
    width=BASE_SCREEN_WIDTH,
    getText = function()
      return "playtesters"
    end,
  }

for k, v in pairs(CREDITS_SPECIAL_THANKS) do
  Text{
    name='thanks_'..v,
    layer=LAYER_HUD,
    condition=inGameState(STATE_GAME_CREDITS),
    x=BASE_SCREEN_WIDTH/2,
    y=(12 + 1 * k)*UI_HEIGHT_UNIT,
    font=FONT_XS,
    color=COLOR_GREEN,
    width=BASE_SCREEN_WIDTH,
    getText = function()
      return ("%s"):format(v)
    end,
  }
end

Button{
  name='twitter',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_CREDITS),
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
    return 'twitter'
  end,
  onPress = function()
    love.system.openURL('https://twitter.com/ghust1995')
  end
}
Button{
  name='Back',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_CREDITS),
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
    return 'back'
  end,
  onPress = function(self, x, y)
    Game.state:pop()
  end,
}
