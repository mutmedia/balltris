require 'ui/base'

Rectangle{
  name='background',
  layer=LAYER_BACKGROUND,
  condition=True(),
  x=BASE_SCREEN_WIDTH/2,
  y=BASE_SCREEN_HEIGHT/2,
  width=BASE_SCREEN_WIDTH,
  height=BASE_SCREEN_HEIGHT,
  color=2,
}

Custom{
  name='scanline',
  layer=LAYER_GAME,
  condition=inGameState(STATE_GAME_RUNNING),
  -- //height=60,
  count=2,
  width=BASE_SCREEN_WIDTH,
  lineWidth=2,
  speed=200,
  visibility=0.25,
  draw=function(self)
    local y = Game.totalTime * self.speed 
    UI.setColor(8, self.visibility) 
    love.graphics.setLineWidth(self.lineWidth or 1)
    local height = 400
      local pos = y  % (BASE_SCREEN_HEIGHT)
      love.graphics.rectangle(
        'fill',
        0,
        pos,
        self.width,
        height,
        RECTANGLE_BORDER_RADIUS)
      local overflow = pos + height - BASE_SCREEN_HEIGHT
      if overflow > 0 then
        love.graphics.rectangle(
          'fill',
          0,
          0,
          self.width,
          overflow,
          RECTANGLE_BORDER_RADIUS)
      end
  end
}

Rectangle{
  name='gamebox',
  layer=LAYER_GAME,
  condition=inGameState(STATE_GAME_RUNNING),
  x=BASE_SCREEN_WIDTH/2,
  y=BASE_SCREEN_HEIGHT/2,
  width=(BASE_SCREEN_WIDTH - 2*BORDER_THICKNESS)*1.2,
  height=BASE_SCREEN_HEIGHT,
  onMove = function(self, x, y, dx, dy)
    Game.events.fire(EVENT_MOVED_PREVIEW, x, y, dx, dy)
  end,
  onEnter = function(self, x, y)
    Game.events.fire(EVENT_MOVED_PREVIEW, x, y, dx, dy)
  end,
  onExit = function(self, x, y)
    Game.events.fire(EVENT_RELEASED_PREVIEW, x, y)
  end,
}

Custom{
  name='combo pit color fill',
  layer=LAYER_BACKGROUND,
  --condition=True(),
  condition=inGameState(STATE_GAME_RUNNING),
  draw = function(self)
    local lineSize = HOLE_DEPTH + HOLE_WIDTH/2
    local position = 0
    local value = math.clamp((Game.comboTimeLeft - COMBO_TIMEOUT_BUFFER) / (COMBO_MAX_TIMEOUT - COMBO_TIMEOUT_BUFFER), 0, 1)
    local color = COLOR_GREEN
    if value < 1/3 then
      color = COLOR_RED
    elseif value < 2/3 then
      color = COLOR_YELLOW
    end
    value = value * lineSize

    UI.setColor(color)
    local hstep = math.min(value, HOLE_WIDTH/2)
    love.graphics.setLineWidth(BALL_LINES_DISTANCE*2)
    -- Draw horizontal lines
    love.graphics.line(
      BASE_SCREEN_WIDTH/2,
      HOLE_DEPTH + BALL_LINES_DISTANCE/2,
      BASE_SCREEN_WIDTH/2 + hstep,
      HOLE_DEPTH + BALL_LINES_DISTANCE/2
      )
    love.graphics.line(
      BASE_SCREEN_WIDTH/2 - position,
      HOLE_DEPTH + BALL_LINES_DISTANCE/2,
      BASE_SCREEN_WIDTH/2 - hstep,
      HOLE_DEPTH + BALL_LINES_DISTANCE/2
      )
    position = position + hstep

    if value >= HOLE_WIDTH/2 then
      -- Draw arc
      love.graphics.arc(
        'line', 
        'open', 
        BASE_SCREEN_WIDTH/2 + (HOLE_WIDTH/2 + BALL_LINES_DISTANCE/2 - RECTANGLE_BORDER_RADIUS),
        HOLE_DEPTH + BALL_LINES_DISTANCE/2 - RECTANGLE_BORDER_RADIUS,
        RECTANGLE_BORDER_RADIUS,
        0,
        math.pi/2,
        10)
      love.graphics.arc(
        'line', 
        'open', 
        BASE_SCREEN_WIDTH/2 - (HOLE_WIDTH/2 + BALL_LINES_DISTANCE/2 - RECTANGLE_BORDER_RADIUS),
        HOLE_DEPTH + BALL_LINES_DISTANCE/2 - RECTANGLE_BORDER_RADIUS,
        RECTANGLE_BORDER_RADIUS,
        0 + math.pi/2,
        math.pi/2 + math.pi/2,
        10)
    end

    --Vertical

    local vstep = math.max(value-HOLE_WIDTH/2, 0)
    love.graphics.line(
      BASE_SCREEN_WIDTH/2 + (HOLE_WIDTH/2 + BALL_LINES_DISTANCE/2),
      HOLE_DEPTH - (position - HOLE_WIDTH/2),
      BASE_SCREEN_WIDTH/2 + (HOLE_WIDTH/2 + BALL_LINES_DISTANCE/2),
      HOLE_DEPTH - (position - HOLE_WIDTH/2 + vstep)
      )
    love.graphics.line(
      BASE_SCREEN_WIDTH/2 - (HOLE_WIDTH/2 + BALL_LINES_DISTANCE/2),
      HOLE_DEPTH - (position - HOLE_WIDTH/2),
      BASE_SCREEN_WIDTH/2 - (HOLE_WIDTH/2 + BALL_LINES_DISTANCE/2),
      HOLE_DEPTH - (position - HOLE_WIDTH/2 + vstep)
      )

    --UI.setColor(3)
    --love.graphics.setLineWidth(BALL_LINES_DISTANCE)
  end,
  x=0, y=0, widht=0, height=0
}

Custom{
  name='combo pit color fill',
  layer=LAYER_BACKGROUND,
  --condition=True(),
  condition=False(), --inGameState(STATE_GAME_RUNNING),
  initialPosition=0,
  frenzyTime=-1,
  draw = function(self)
    local lineSize = HOLE_DEPTH + HOLE_WIDTH/2
    local stepSize = lineSize/Game.comboObjective
    local maxSize = math.min(Game.combo, Game.comboObjective) * stepSize

    if self.frenzyTime < 0 and Game.combo >= Game.comboObjective then
      self.frenzyTime = Game.totalTime
    end

    if self.frenzyTime > 0 then
      self.initialPosition = (FRENZY_SPEED * (Game.totalTime-self.frenzyTime)) % maxSize
    end

    if self.frenzyTime > 0 and Game.combo < Game.comboObjective then
      self.initialPosition = 0
      self.frenzyTime = -1
    end

    local currentSize = 0
    local currentBall = 1
    love.graphics.setLineWidth(BALL_LINES_DISTANCE*2)
    Game.comboNumbers:forEach(function(q)
      if currentBall > Game.comboObjective then return end
      UI.setColor(q.num + 2)
      local position = (self.initialPosition + currentSize) % maxSize

      local step = stepSize
      while step > 0 do
        if position < HOLE_WIDTH/2 then 
          local hstep = math.min(step, HOLE_WIDTH/2 - position)
          -- Draw horizontal lines
          love.graphics.line(
            BASE_SCREEN_WIDTH/2 + position,
            HOLE_DEPTH + BALL_LINES_DISTANCE/2,
            BASE_SCREEN_WIDTH/2 + (position + hstep),
            HOLE_DEPTH + BALL_LINES_DISTANCE/2
            )
          love.graphics.line(
            BASE_SCREEN_WIDTH/2 - position,
            HOLE_DEPTH + BALL_LINES_DISTANCE/2,
            BASE_SCREEN_WIDTH/2 - (position + hstep),
            HOLE_DEPTH + BALL_LINES_DISTANCE/2
            )
          position = (position + hstep) % maxSize
          step = step - hstep
        else
          if position == HOLE_WIDTH/2 then
            -- Draw arc
            love.graphics.arc(
              'line', 
              'open', 
              BASE_SCREEN_WIDTH/2 + (HOLE_WIDTH/2 + BALL_LINES_DISTANCE/2 - RECTANGLE_BORDER_RADIUS),
              HOLE_DEPTH + BALL_LINES_DISTANCE/2 - RECTANGLE_BORDER_RADIUS,
              RECTANGLE_BORDER_RADIUS,
              0,
              math.pi/2,
              10)
            love.graphics.arc(
              'line', 
              'open', 
              BASE_SCREEN_WIDTH/2 - (HOLE_WIDTH/2 + BALL_LINES_DISTANCE/2 - RECTANGLE_BORDER_RADIUS),
              HOLE_DEPTH + BALL_LINES_DISTANCE/2 - RECTANGLE_BORDER_RADIUS,
              RECTANGLE_BORDER_RADIUS,
              0 + math.pi/2,
              math.pi/2 + math.pi/2,
              10)
          end

          local vstep = math.min(step, maxSize - position)
          love.graphics.line(
            BASE_SCREEN_WIDTH/2 + (HOLE_WIDTH/2 + BALL_LINES_DISTANCE/2),
            HOLE_DEPTH - (position - HOLE_WIDTH/2),
            BASE_SCREEN_WIDTH/2 + (HOLE_WIDTH/2 + BALL_LINES_DISTANCE/2),
            HOLE_DEPTH - (position - HOLE_WIDTH/2 + vstep)
            )
          love.graphics.line(
            BASE_SCREEN_WIDTH/2 - (HOLE_WIDTH/2 + BALL_LINES_DISTANCE/2),
            HOLE_DEPTH - (position - HOLE_WIDTH/2),
            BASE_SCREEN_WIDTH/2 - (HOLE_WIDTH/2 + BALL_LINES_DISTANCE/2),
            HOLE_DEPTH - (position - HOLE_WIDTH/2 + vstep)
            )
          step = step - vstep
          position = (position + vstep) % maxSize
        end
      end
      currentBall = currentBall + 1
      currentSize = currentSize + stepSize
    end)
    UI.setColor(3)
    love.graphics.setLineWidth(BALL_LINES_DISTANCE)
  end,
  x=0, y=0, widht=0, height=0
}
Rectangle{
  name='inner visible pit',
  layer=LAYER_BACKGROUND,
  condition=Not(inGameState(STATE_GAME_USERNAME, STATE_GAME_OFFLINE_CONFIRMATION, STATE_GAME_USERNAME_LOADING, STATE_GAME_FIRST_CONNECTION)),
  lineColor=COLOR_WHITE,
  lineWidth=BALL_LINE_WIDTH_IN,
  x=BASE_SCREEN_WIDTH/2,
  y=0,
  width=HOLE_WIDTH,
  height=HOLE_DEPTH * 2,
}

Rectangle{
  name='outer visible pit',
  layer=LAYER_BACKGROUND,
  condition=Not(inGameState(STATE_GAME_USERNAME, STATE_GAME_OFFLINE_CONFIRMATION, STATE_GAME_USERNAME_LOADING, STATE_GAME_FIRST_CONNECTION)),
  lineColor=COLOR_WHITE,
  lineWidth=BALL_LINE_WIDTH_OUT,
  x=BASE_SCREEN_WIDTH/2,
  y=0,
  width=HOLE_WIDTH + 2*BALL_LINES_DISTANCE,
  height=HOLE_DEPTH * 2 + 2*BALL_LINES_DISTANCE,
}

Rectangle{
  name='limitline',
  layer=LAYER_HUD,
  condition=Not(inGameState(STATE_GAME_LOADING, STATE_GAME_USERNAME, STATE_GAME_OFFLINE_CONFIRMATION, STATE_GAME_USERNAME_LOADING, STATE_GAME_FIRST_CONNECTION)),
  x=BASE_SCREEN_WIDTH/2,
  y=MIN_DISTANCE_TO_TOP,
  width=HOLE_WIDTH,
  height=1,
  lineWidth=2,
  lineColor=COLOR_WHITE,
}



function DrawBall(color, center, radius, rotation, scale, visibility)
  love.graphics.push()
  love.graphics.translate(center[1], center[2])
  love.graphics.rotate(rotation or 0)
  scale = scale or {1, 1}
  love.graphics.scale(scale[1] or 1, scale[2] or 1)
  UI.setColor(color, visibility or 1)
  love.graphics.setLineWidth(BALL_LINE_WIDTH_OUT)
  radius = radius * BALL_DRAW_SCALE
  arcEnd = 2 * math.pi - BALL_NEON_GAP * math.pi / radius
  love.graphics.arc('line', 'open', 0, 0, radius, 0, arcEnd,  30)
  radius = radius * BALL_DRAW_SCALE-BALL_LINES_DISTANCE
  arcEnd = 2 * math.pi - BALL_NEON_GAP * math.pi / radius
  love.graphics.setLineWidth(BALL_LINE_WIDTH_IN)
  love.graphics.arc('line', 'open', 0, 0, radius, 0 + math.pi, arcEnd + math.pi, 30)
  love.graphics.pop()
end


Custom{
  name='ball preview',
  layer=LAYER_GAME,
  condition = function() return Game.objects.ballPreview end,
  transitionInTime=0.8,
  transitionIn=function(self, dt) 
    return {
      visibility=dt
    }
  end,
  visibility=1,
  draw=function(self)
    if Game.objects.ballPreview then
      local center = {Game.objects.ballPreview.position.x, Game.objects.ballPreview.position.y}
      local radius = Game.objects.ballPreview.radius
      local color = Game.objects.ballPreview:getColor()

      local hold = Game.objects.ballPreview.holdTime / PREVIEW_HOLD_TIME
      local b = 0.25
      local k = b + hold * (0.7-b)
      if hold > 1 then k = 1 end
      
      DrawBall(color, center, radius, 0, {1, 1}, k * k)
    end
  end,
}


Custom{
  name='ball preview laser raycast',
  layer=LAYER_GAME,
  condition = inGameState(STATE_GAME_RUNNING),
  draw=function()
    if Game.raycastHit and Game.objects.ballPreview then
      UI.setColor(Game.objects.ballPreview:getColor())
      love.graphics.circle('fill', Game.raycastHit.x, Game.raycastHit.y, 7)
    end
  end,
}
Custom{
  name='balls in game',
  layer=LAYER_GAME,
  condition = inGameState(STATE_GAME_RUNNING, STATE_GAME_LOST, STATE_GAME_OVER, STATE_GAME_PAUSED),
  turnOffShader= love.graphics.newShader('shaders/turnOffShader.fs'),
  draw=function(self)
    self.turnOffShader:send('time_to_destroy', BALL_TIME_TO_DESTROY)
    if not Game.objects or not Game.objects.balls then return end
    Game.objects.balls:forEach(function(ball) 
      --print('lots of balls')
      local vx, vy = ball.body:getLinearVelocity()
      local center = {ball.body:getX() - vx * (FIXED_DT - Game.extrapolationTime), ball.body:getY() - vy * (FIXED_DT - Game.extrapolationTime)}


      local radius = ball.radius
      local color = ball:getColor()

      local lastShader
      if ball.timeDestroyed then
        lastShader = love.graphics.getShader()
        love.graphics.setShader(self.turnOffShader)
        self.turnOffShader:send('delta_time', Game.totalTime - ball.timeDestroyed)
      end
      local s = BALL_STRETCH_NORMALIZER * math.sqrt(vx * vx + vy * vy) -- ~0 - 3000
      sx = math.pow(BALL_STRETCH_FACTOR, 1+s)/BALL_STRETCH_FACTOR
      sy = math.pow(BALL_STRETCH_FACTOR, 1-s)/BALL_STRETCH_FACTOR
      --local rot = ball.body:getAngle() 
      local rot = math.atan2(vy, vx)
      DrawBall(color, center, radius, rot, {sx, sy})
      if ball.timeDestroyed then
        love.graphics.setShader(lastShader)
      end
    end)
  end,
}

Custom{
  name='next balls',
  layer=LAYER_GAME,
  condition = inGameState(STATE_GAME_RUNNING),
  draw=function(self)
    local ballPreviewNum = 1
    local ballPreviewHeight = 5*UI_HEIGHT_UNIT
    local ballPreviewX = BASE_SCREEN_WIDTH - (BORDER_THICKNESS)/2
    love.graphics.setLineWidth(1)
    Game.objects.nextBallPreviews:forEach(function(nextBallPreview)
      --ballPreviewHeight = ballPreviewHeight + nextBallPreview.radius

      local center = {ballPreviewX, ballPreviewHeight}
      local radius = nextBallPreview.radius
      local color = nextBallPreview:getColor()

      DrawBall(color, center, radius)


      ballPreviewNum = ballPreviewNum + 1

      ballPreviewHeight = ballPreviewHeight + 5*UI_HEIGHT_UNIT
    end)
  end
}
