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
FRENZY_SPEED = 1000
Custom{
  name='combo pit color fill',
  layer=LAYER_BACKGROUND,
  --condition=True(),
  condition=inGameState(STATE_GAME_RUNNING),
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
      if currentBall == Game.comboNumbers.size then
        --step = step * math.max( 1 - Game.timeSinceLastCombo / COMBO_TIMEOUT, 0)
      end
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
  condition=Not(inGameState(STATE_GAME_USERNAME, STATE_GAME_OFFLINE_CONFIRMATION, STATE_GAME_USERNAME_LOADING)),
  lineColor=COLOR_TRANSPARENT,
  lineWidth=BALL_LINE_WIDTH_IN,
  x=BASE_SCREEN_WIDTH/2,
  y=0,
  width=HOLE_WIDTH,
  height=HOLE_DEPTH * 2,
}

Rectangle{
  name='outer visible pit',
  layer=LAYER_BACKGROUND,
  condition=Not(inGameState(STATE_GAME_USERNAME, STATE_GAME_OFFLINE_CONFIRMATION, STATE_GAME_USERNAME_LOADING)),
  lineColor=COLOR_TRANSPARENT,
  lineWidth=BALL_LINE_WIDTH_OUT,
  x=BASE_SCREEN_WIDTH/2,
  y=0,
  width=HOLE_WIDTH + 2*BALL_LINES_DISTANCE,
  height=HOLE_DEPTH * 2 + 2*BALL_LINES_DISTANCE,
}

Rectangle{
  name='limitline',
  layer=LAYER_HUD,
  condition=Not(inGameState(STATE_GAME_LOADING, STATE_GAME_USERNAME, STATE_GAME_OFFLINE_CONFIRMATION, STATE_GAME_USERNAME_LOADING)),
  x=BASE_SCREEN_WIDTH/2,
  y=MIN_DISTANCE_TO_TOP,
  width=HOLE_WIDTH,
  height=1,
  lineWidth=2,
  lineColor=COLOR_WHITE,
}



function DrawBall(color, center, radius, rotation)
  love.graphics.push()
  love.graphics.translate(center[1], center[2])
  love.graphics.rotate(rotation or 0)
  --love.graphics.scale(1+s, 1-s)
  if color ~= COLOR_BLUE and color ~= COLOR_GREEN then 
    color = COLOR_TRANSPARENT
  end
  if color == COLOR_BLUE then
    color = COLOR_PINK
  end
  if color == COLOR_GREEN then
    color = COLOR_BLUE
  end
  if color == COLOR_BLUE and radius == BALL_MAX_RADIUS then
    color = COLOR_TRANSPARENT
  end
  UI.setColor(color)
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
  condition = inGameState(STATE_GAME_RUNNING),
  draw=function()
    if Game.objects.ballPreview then
      local center = {Game.objects.ballPreview.position.x, Game.objects.ballPreview.position.y}
      local radius = Game.objects.ballPreview.radius
      local color = Game.objects.ballPreview:getColor()

      DrawBall(color, center, radius)
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
      local center = {ball.body:getX(), ball.body:getY()}
      local radius = ball.radius
      local color = ball:getColor()

      local lastShader
      if ball.timeDestroyed then
        lastShader = love.graphics.getShader()
        love.graphics.setShader(self.turnOffShader)
        self.turnOffShader:send('delta_time', Game.totalTime - ball.timeDestroyed)
      end
      local vx, vy = ball.body:getLinearVelocity()
      local s = BALL_SPEED_STRETCH * math.sqrt(vx * vx + vy * vy)
      local rot = ball.body:getAngle() --math.atan2(vy, vx)
      --love.graphics.push()
      --love.graphics.rotate(rot)
      --love.graphics.scale(1+s, 1-s)
      DrawBall(color, center, radius, rot)
      --love.graphics.pop()
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
