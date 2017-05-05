require 'ui/base'

Button{
  name='gamemenu unpouse',
  condition=inGameState(STATE_GAME_PAUSED),
  layer=LAYER_MENUS,
  x=BASE_SCREEN_WIDTH/2,
  y=BASE_SCREEN_HEIGHT/2 - 120 - 10 - 15,
  height=80,
  width=HOLE_WIDTH * 0.8,
  color=0,
  lineColor=1,
  lineWidth = 5,
  font=love.graphics.newFont(MAIN_UI_FONT, 35),
  textColor=1,
  getText = function()
    return 'Unpause'
  end,
  onPress = function() 
    Game.state = STATE_GAME_RUNNING
  end,
}

Button{
  name='restart button',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_PAUSED),
  x=BASE_SCREEN_WIDTH/2,
  y=BASE_SCREEN_HEIGHT/2 + 30 - 10 - 15,
  width=HOLE_WIDTH * 0.8,
  height=80,
  color=0,
  lineColor=1,
  lineWidth=3,
  font=love.graphics.newFont(MAIN_UI_FONT, 35),
  textColor=1,
  getText = function() 
    return 'Restart'
  end,
  onPress = function(self, x, y)
    Game.start()
  end,
}

Button{
  name='pause back to mainmenu',
  layer=LAYER_MENUS,
  condition=inGameState(STATE_GAME_PAUSED),
  x=BASE_SCREEN_WIDTH/2,
  y=BASE_SCREEN_HEIGHT/2 + 180 - 10 - 15,
  width=HOLE_WIDTH * 0.8,
  height=80,
  color=0,
  lineColor=1,
  lineWidth=3,
  font=love.graphics.newFont(MAIN_UI_FONT, 35),
  textColor=1,
  getText = function() 
    return 'EXIT'
  end,
  onPress = function(self, x, y)
    Game.state = STATE_GAME_MAINMENU
  end,
}
