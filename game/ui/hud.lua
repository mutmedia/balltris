require 'ui/base'
local Backend = require 'backend'

Text{
  name='loading',
  layer=LAYER_HUD,
  condition=inGameState(STATE_GAME_LOADING),
  x=BASE_SCREEN_WIDTH/2,
  y=BASE_SCREEN_HEIGHT/2,
  font=FONT_MD,
  color=1,
  width=1000,
  getText = function()
    return 'Loading...'
  end,
}

Text{
  name='offline',
  layer=LAYER_HUD,
  condition=function() return Backend.isOffline end,
  x=BORDER_THICKNESS/2,
  y=-UI_HEIGHT_UNIT,
  font=FONT_SM,
  color=COLOR_RED,
  width=1000,
  getText = function()
    return 'offline'
  end,
}

Text{
  name='achievement',
  layer=LAYER_HUD,
  condition=function() return Game.achievements.displaying ~= nil end,
  x=BASE_SCREEN_WIDTH/2,
  y=-UI_HEIGHT_UNIT,
  font=FONT_SM,
  color=COLOR_GREEN,
  width=BASE_SCREEN_WIDTH,
  getText = function()
    return (Game.achievements.displaying or 'achievement')..'!'
  end,
}

Text{
  name='nextballs',
  layer=LAYER_HUD,
  condition=inGameState(STATE_GAME_RUNNING),
  x=-BORDER_THICKNESS/2,
  y=2*UI_HEIGHT_UNIT,
  font=FONT_MD,
  color=1,
  width=BORDER_THICKNESS,
  getText = function()
    return 'next'
  end,
}

-- Game Menus
Button{
  name='open menu',
  layer=LAYER_HUD,
  condition=inGameState(STATE_GAME_RUNNING, STATE_GAME_PAUSED),
  x=BORDER_THICKNESS/2 - 3,
  y=2*UI_HEIGHT_UNIT,
  width=0.8*BORDER_THICKNESS,
  height=2*UI_HEIGHT_UNIT,
  lineWidth = 3,
  lineColor=1,
  font=FONT_MD,
  textColor=1,
  getText = function()
    return 'menu'
  end,
  onPress = function() 
    if not Game.inState(STATE_GAME_PAUSED) then
      Game.state:push(STATE_GAME_PAUSED)
    else
      Game.state:push(STATE_GAME_RUNNING)
    end
  end,
}

-- Score stuff

Text{
  name='score',
  layer=LAYER_HUD,
  condition=inGameState(STATE_GAME_RUNNING, STATE_GAME_PAUSED, STATE_GAME_LOST),
  x=BORDER_THICKNESS/2,
  y=6*UI_HEIGHT_UNIT,
  font=FONT_MD,
  color=1,
  width=BORDER_THICKNESS,
  getText = function()
    return string.format('score: %04d', Game.score)
  end,
}

Text{
  name='highscore',
  layer=LAYER_HUD,
  condition=inGameState(STATE_GAME_RUNNING, STATE_GAME_PAUSED, STATE_GAME_LOST),
  x=BORDER_THICKNESS/2,
  y=09.5*UI_HEIGHT_UNIT,
  font=FONT_SM,
  color=1,
  width=BORDER_THICKNESS,
  getText = function()
    return string.format('best: %04d', Game.highscore.stats.score)
  end,
}

Text{
  name='combo',
  layer=LAYER_HUD,
  condition = And(inGameState(STATE_GAME_RUNNING, STATE_GAME_PAUSED, STATE_GAME_LOST)),
  x=BORDER_THICKNESS/2,
  y=12*UI_HEIGHT_UNIT,
  font=FONT_SM,
  color=1,
  width=BORDER_THICKNESS,
  getText = function()
    local comboText = Game.combo > 0 and string.format('%2d', Game.combo) or '--'
    local objectiveText = string.format('%2d', Game.comboObjective)
    return 'combo '..comboText
  end,
}

Text{
  name='combo objective',
  layer=LAYER_HUD,
  condition = And(inGameState(STATE_GAME_RUNNING, STATE_GAME_PAUSED), function() return not Game.comboObjectiveCleared end),
  --condition = And(function() return Game.combo > 0 end, inGameState(STATE_GAME_RUNNING, STATE_GAME_PAUSED, STATE_GAME_LOST)),
  x=BORDER_THICKNESS/2,
  y=13.55*UI_HEIGHT_UNIT,
  font=FONT_XS,
  getColor=function()
    return Game.comboObjectiveCleared and COLOR_GREEN or COLOR_YELLOW
  end,
  width=BORDER_THICKNESS,
  getText = function()
    return Game.comboObjectiveCleared and 'cleared' or string.format('clears at %2d', Game.comboObjective)
  end,
}

Text{
  name='next combo objective',
  layer=LAYER_HUD,
  condition = And(inGameState(STATE_GAME_RUNNING, STATE_GAME_PAUSED), function() return Game.comboObjectiveCleared end),
  --condition = And(function() return Game.combo > 0 end, inGameState(STATE_GAME_RUNNING, STATE_GAME_PAUSED, STATE_GAME_LOST)),
  x=BORDER_THICKNESS/2,
  y=13.15*UI_HEIGHT_UNIT,
  font=FONT_XS,
  color=COLOR_RED,
  width=BORDER_THICKNESS,
  getText = function()
    return string.format('next combo \nclears at %2d', Game.GetComboObjectiveValue(Game.currentObjectiveNumber + 1))
  end,
}

Custom{
  name='combo fill',
  layer=LAYER_HUD,
  condition = inGameState(STATE_GAME_RUNNING, STATE_GAME_PAUSED, STATE_GAME_LOST),
  --condition = And(function() return Game.combo > 0 end, inGameState(STATE_GAME_RUNNING, STATE_GAME_PAUSED, STATE_GAME_LOST)),
  x=BORDER_THICKNESS/2,
  y=15.15*UI_HEIGHT_UNIT,
  radius=UI_HEIGHT_UNIT,
  width=1*UI_HEIGHT_UNIT,
  height=9*UI_HEIGHT_UNIT,
  initialPosition=0,
  frenzyTime=-1,
  draw=function(self)

    local NUM_SEGMENTS = Game.comboObjective
    local maxSize = 1/NUM_SEGMENTS
    local currentBall = 1

    if self.frenzyTime < 0 and Game.combo >= Game.comboObjective then
      self.frenzyTime = Game.totalTime
    end

    if self.frenzyTime > 0 then
      self.initialPosition = (FRENZY_SPEED * (Game.totalTime-self.frenzyTime)) % NUM_SEGMENTS
    end

    if self.frenzyTime > 0 and Game.combo < Game.comboObjective then
      self.initialPosition = 0
      self.frenzyTime = -1
    end


    Game.comboNumbers:forEach(function(q) 
      if currentBall > NUM_SEGMENTS then return end
      color = Game.comboObjectiveCleared and COLOR_GRAY or (q.num + 2)
      UI.setColor(color)

      local h = self.height * maxSize
      local py = h * (currentBall )--+ self.initialPosition)
      py = (py) % self.height
      local py1 = py
      local h1 = h
      local h2 = 0
      local py2 = 0
      if py1 + h > self.height then 
        h1 = self.height - py
        h2 = py1 + h - self.height
        py1 = py1 + h1 -h
        py2 = h2
      end
      -- SUPER DUMB BUT SUPER LAZY
      if self.frenzyTime > 0 then
        py1 = py1 + h
      end

      love.graphics.rectangle('fill',
        self.x - self.width/2,
        self.y + self.height - py1,
        self.width,
        h1
        )
      if h2 > 0 then
        love.graphics.rectangle('fill',
          self.x - self.width/2,
          self.y + self.height - py2,
          self.width,
          h2
          )
      end
      currentBall = currentBall + 1
    end)

    for i=1,NUM_SEGMENTS-1 do
      UI.setColor(COLOR_BLACK)
      love.graphics.setLineWidth(3)
      love.graphics.line(
        self.x - self.width/2,
        self.y + self.height * i/NUM_SEGMENTS,
        self.x + self.width/2,
        self.y + self.height * i/NUM_SEGMENTS
        )
    end

    UI.setColor(COLOR_WHITE)
    love.graphics.setLineWidth(BALL_LINE_WIDTH_IN)
    love.graphics.rectangle('line', self.x - self.width/2, self.y, self.width, self.height, RECTANGLE_BORDER_RADIUS)

    UI.setColor(COLOR_WHITE)
    love.graphics.setLineWidth(BALL_LINE_WIDTH_OUT)
    local w = self.width + 2*BALL_LINES_DISTANCE
    local h = self.height + 2 * BALL_LINES_DISTANCE
    love.graphics.rectangle('line', self.x - w/2, self.y - BALL_LINES_DISTANCE, w, h, RECTANGLE_BORDER_RADIUS)
  end,
}

Custom{
  name='combometer',
  layer=LAYER_HUD,
  condition = False(),--inGameState(STATE_GAME_RUNNING, STATE_GAME_PAUSED, STATE_GAME_LOST),
  --condition = And(function() return Game.combo > 0 end, inGameState(STATE_GAME_RUNNING, STATE_GAME_PAUSED, STATE_GAME_LOST)),
  x=BORDER_THICKNESS/2,
  y=15.15*UI_HEIGHT_UNIT,
  radius=UI_HEIGHT_UNIT,
  width=1*UI_HEIGHT_UNIT,
  height=9*UI_HEIGHT_UNIT,
  draw=function(self)
    local value = (Game.comboTimeLeft - COMBO_TIMEOUT_BUFFER) / (COMBO_MAX_TIMEOUT - COMBO_TIMEOUT_BUFFER)
    local color = COLOR_GREEN
    if value < 1/3 then
      color = COLOR_RED
    elseif value < 2/3 then
      color = COLOR_YELLOW
    end

    local NUM_SEGMENTS = 9
    local maxFill = 1/NUM_SEGMENTS
    for i=1,NUM_SEGMENTS do
      local fill = math.clamp(value - (i-1) * maxFill, 0, maxFill)
      UI.setColor(color)

      local h = self.height * fill
      if h > 0 then
        love.graphics.rectangle('fill',
          self.x - self.width/2,
          self.y + ((NUM_SEGMENTS-i) * (maxFill)) * self.height + (maxFill-fill) * self.height,
          self.width,
          h, RECTANGLE_BORDER_RADIUS
          )

        UI.setColor(COLOR_BLACK)
        love.graphics.rectangle('fill',
          self.x - self.width/2,
          self.y + ((NUM_SEGMENTS-i) * (maxFill)) * self.height + maxFill * self.height,
          self.width,
          UI_HEIGHT_UNIT * 0.2
          )
      end
    end

    UI.setColor(COLOR_WHITE)
    love.graphics.setLineWidth(BALL_LINE_WIDTH_IN)
    love.graphics.rectangle('line', self.x - self.width/2, self.y, self.width, self.height, RECTANGLE_BORDER_RADIUS)


    UI.setColor(COLOR_WHITE)
    love.graphics.setLineWidth(BALL_LINE_WIDTH_OUT)
    local w = self.width + 2*BALL_LINES_DISTANCE
    local h = self.height + 2 * BALL_LINES_DISTANCE
    love.graphics.rectangle('line', self.x - w/2, self.y - BALL_LINES_DISTANCE, w, h, RECTANGLE_BORDER_RADIUS)
  end,
}

--[[
Text{
  name='speed',
  layer=LAYER_HUD,
  condition=False(),
  --condition = And(function() return Game.combo > 0 end, inGameState(STATE_GAME_RUNNING, STATE_GAME_PAUSED, STATE_GAME_LOST)),
  x=BORDER_THICKNESS/2,
  y=18*UI_HEIGHT_UNIT,
  font=FONT_XS,
  color=3,
  width=BORDER_THICKNESS,
  getText = function()
    return 'Speed: '..Game.meanSpeed
  end,
}
]]--

-- Container
--[[Rectangle{
  x=BASE_SCREEN_WIDTH - 100 - 1.1*MAX_RADIUS,
  y=20 + 20,
  width=2*1.1*MAX_RADIUS,
  height=2*1.1*MAX_RADIUS,
  drawMode='line',
  pressed = function(self, x, y)
    self.color = {0, 1, 0, 1}
  end,
  released = function(self, x, y)
    game.events.fire(EVENT_PRESSED_SWITCH)
    self.color = {1, 0, 0, 1}
  end,
}]]--

--Circle{
--  x=BASE_SCREEN_WIDTH - 100,
--  y = 20 + 20 + 1.1*MAX_RADIUS,
--}
