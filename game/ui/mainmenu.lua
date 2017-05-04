require 'ui/base'

Text{
  name='title',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_MAINMENU),
  x=BASE_SCREEN_WIDTH/2,
  y=BASE_SCREEN_HEIGHT/2 - 200 - 100,
  font=love.graphics.newFont(MAIN_UI_FONT, 80),
  color=BALL_COLORS[1],
  width=250,
  getText = function()
    return 'Balltris'
  end,
}

Button{
  name='play button',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_MAINMENU),
  x=BASE_SCREEN_WIDTH/2,
  y=BASE_SCREEN_HEIGHT/2 + 50,
  width=HOLE_WIDTH * 0.8,
  height=80,
  color={0, 0, 0},
  --textColor={0, 0, 0},
  lineColor={255, 255, 255},
  lineWidth=3,
  font=love.graphics.newFont(MAIN_UI_FONT, 35),
  getText = function() 
    return 'New Game'
  end,
  onPress = function(self, x, y)
    Game.start()
  end,
}

