require 'ui/base'

local BALL_COLORS_PALETTE = 2

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
love.graphics.setLineWidth(BALL_LINE_WIDTH_IN)
  love.graphics.setColor({255, 0, 255})
  love.graphics.rectangle('line', BORDER_THICKNESS, -10, HOLE_WIDTH, HOLE_DEPTH + 10)
  love.graphics.setLineWidth(BALL_LINE_WIDTH_OUT)
  love.graphics.rectangle('line', BORDER_THICKNESS - BALL_LINES_DISTANCE, -10 - BALL_LINES_DISTANCE, HOLE_WIDTH + 2 * BALL_LINES_DISTANCE, HOLE_DEPTH + 10 + 2 * BALL_LINES_DISTANCE)
  love.graphics.setLineWidth(1)

Rectangle{
  name='inner visible pit',
  layer=LAYER_BACKGROUND,
  condition=True(),
  lineColor=1,
  lineWidth=BALL_LINE_WIDTH_IN,
  x=BASE_SCREEN_WIDTH/2,
  y=HOLE_DEPTH/2,
  width=HOLE_WIDTH,
  height=HOLE_DEPTH,
}

Rectangle{
  name='limitline',
  layer=LAYER_HUD,
  condition=Not(inGameState(STATE_GAME_LOADING)),
  x=BASE_SCREEN_WIDTH/2,
  y=MIN_DISTANCE_TO_TOP,
  width=HOLE_WIDTH,
  height=1,
  lineWidth=2,
  lineColor=1,
}


Rectangle{
  name='outer visible pit',
  layer=LAYER_BACKGROUND,
  condition=True(),
  lineColor=1,
  lineWidth=BALL_LINE_WIDTH_OUT,
  x=BASE_SCREEN_WIDTH/2,
  y=HOLE_DEPTH/2,
  width=HOLE_WIDTH + 2*BALL_LINES_DISTANCE,
  height=HOLE_DEPTH + 2*BALL_LINES_DISTANCE,
}

function GetBallColor(ball)
  return ball.indestructible and 1 or ball.number + BALL_COLORS_PALETTE

end


Custom{
  name='ball preview',
  layer=LAYER_GAME,
  condition = inGameState(STATE_GAME_RUNNING),
  draw=function()
    if Game.objects.ballPreview and Game.objects.ballPreview.drawStyle ~= 'none' then
      local center = {Game.objects.ballPreview.position.x, Game.objects.ballPreview.position.y}
      local radius = Game.objects.ballPreview.radius
      local color = GetBallColor(Game.objects.ballPreview)

      love.graphics.push()
      UI.setColor(color)
      love.graphics.translate(center[1], center[2])
      love.graphics.setLineWidth(BALL_LINE_WIDTH_OUT)
      love.graphics.circle('line', 0, 0, radius * BALL_DRAW_SCALE)
      love.graphics.setLineWidth(BALL_LINE_WIDTH_IN)
      love.graphics.circle('line', 0, 0, radius * BALL_DRAW_SCALE - BALL_LINES_DISTANCE)
      love.graphics.pop()
    end
  end,
}

Custom{
  name='ball preview laser raycast',
  layer=LAYER_GAME,
  condition = inGameState(STATE_GAME_RUNNING),
  draw=function()
    if Game.raycastHit and Game.objects.ballPreview and Game.objects.ballPreview.drawStyle ~= 'none' then
      UI.setColor(GetBallColor(Game.objects.ballPreview))
      love.graphics.circle('fill', Game.raycastHit.x, Game.raycastHit.y, 7)
    end
  end,
}
Custom{
  name='balls in game',
  layer=LAYER_GAME,
  condition =  Not(inGameState(STATE_GAME_MAINMENU, STATE_GAME_MAINMENU, STATE_GAME_OVER)),
  turnOffShader= love.graphics.newShader('shaders/turnOffShader.fs'),
  draw=function(self)
    self.turnOffShader:send('time_to_destroy', BALL_TIME_TO_DESTROY)
    Game.objects.balls:forEach(function(ball) 
      local center = {ball.body:getX(), ball.body:getY()}
      local radius = ball.radius
      local color = GetBallColor(ball)

      if ball.timeDestroyed then
        love.graphics.setShader(self.turnOffShader)
        self.turnOffShader:send('delta_time', Game.totalTime - ball.timeDestroyed)
      else
        love.graphics.setShader()
      end
      local vx, vy = ball.body:getLinearVelocity()
      local s = BALL_SPEED_STRETCH * math.sqrt(vx * vx + vy * vy)
      local rot = math.atan2(vy, vx)
      love.graphics.push()
      UI.setColor(color)
      love.graphics.translate(center[1], center[2])
      love.graphics.rotate(rot)
      love.graphics.scale(1+s, 1-s)
      love.graphics.setLineWidth(BALL_LINE_WIDTH_OUT)
      love.graphics.circle('line', 0, 0, radius * BALL_DRAW_SCALE)
      love.graphics.setLineWidth(BALL_LINE_WIDTH_IN)
      love.graphics.circle('line', 0, 0, radius * BALL_DRAW_SCALE - BALL_LINES_DISTANCE)
      love.graphics.pop()
      --love.graphics.reset()
    end)
    love.graphics.setShader()
  end,
}

Custom{
  name='next balls',
  layer=LAYER_GAME,
  condition = inGameState(STATE_GAME_RUNNING),
  draw=function()
    local ballPreviewNum = 1
    local ballPreviewHeight = 5*UI_HEIGHT_UNIT
    local ballPreviewX = BASE_SCREEN_WIDTH - (BORDER_THICKNESS)/2
    love.graphics.setLineWidth(1)
    Game.objects.nextBallPreviews:forEach(function(nextBallPreview)
      --ballPreviewHeight = ballPreviewHeight + nextBallPreview.radius

      local center = {ballPreviewX, ballPreviewHeight}
      local radius = nextBallPreview.radius
      local color = GetBallColor(nextBallPreview)

      love.graphics.push()
      love.graphics.translate(center[1], center[2])
      UI.setColor(color)

      love.graphics.setLineWidth(BALL_LINE_WIDTH_OUT)
      love.graphics.circle('line', 0, 0, radius * BALL_DRAW_SCALE)
      love.graphics.setLineWidth(BALL_LINE_WIDTH_IN)
      love.graphics.circle('line', 0, 0, radius * BALL_DRAW_SCALE - BALL_LINES_DISTANCE)
      --UI.setColor(1)
      --love.graphics.circle('fill', 0, 0, 3)
      love.graphics.pop()

      ballPreviewNum = ballPreviewNum + 1

      ballPreviewHeight = ballPreviewHeight + 5*UI_HEIGHT_UNIT
    end)
  end
}
