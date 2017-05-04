require 'ui/base'

Rectangle{
  name='gamebox',
  layer=LAYER_GAME,
  condition=inGameState(STATE_GAME_RUNNING),
  x=BASE_SCREEN_WIDTH/2,
  y=BASE_SCREEN_HEIGHT/2,
  width=(BASE_SCREEN_WIDTH - 2*BORDER_THICKNESS)*1.2,
  height=BASE_SCREEN_HEIGHT,
  lineWidth=3,
  lineColor={0, 0, 0, DEBUG_UI and 255 or 0},
  onMove = function(self, x, y, dx, dy)
    if DEBUG_UI then self.lineColor = {0, 255, 0, 255} end
    Game.events.fire(EVENT_MOVED_PREVIEW, x, y, dx, dy)
  end,
  onEnter = function(self, x, y)
    Game.timeScale = 0.3
    Game.events.fire(EVENT_MOVED_PREVIEW, x, y, dx, dy)
  end,
  onExit = function(self, x, y)
    Game.timeScale = 2
    if DEBUG_UI then self.lineColor = {0, 0, 255, 255} end
    Game.events.fire(EVENT_RELEASED_PREVIEW, x, y)
  end,
}

Custom{
  name='ball preview',
  layer=LAYER_GAME,
  condition = inGameState(STATE_GAME_RUNNING),
  draw=function()
    if Game.objects.ballPreview and Game.objects.ballPreview.drawStyle ~= 'none' then
      local center = {Game.objects.ballPreview.position.x, Game.objects.ballPreview.position.y}
      local radius = Game.objects.ballPreview.radius
      local color = Game.objects.ballPreview.getColor()

      love.graphics.push()
      love.graphics.setColor(color)
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
  name='balls in game',
  layer=LAYER_GAME,
  condition =  Not(inGameState(STATE_GAME_MAINMENU, STATE_GAME_MAINMENU, STATE_GAME_OVER)),
  turnOffShader= love.graphics.newShader('shaders/turnOffShader.fs'),
  draw=function(self)
    self.turnOffShader:send('time_to_destroy', BALL_TIME_TO_DESTROY)
    Game.objects.balls:forEach(function(ball) 
      local center = {ball.body:getX(), ball.body:getY()}
      local radius = ball.radius
      local color = ball.getColor()
      if ball.timeDestroyed then
        love.graphics.setShader(self.turnOffShader)
        self.turnOffShader:send('delta_time', Game.totalTime - ball.timeDestroyed)
        print('Total Time:'..(Game.totalTime))
        print('Destroyed Time:'..(ball.timeDestroyed))
      else
        love.graphics.setShader()
      end
      local vx, vy = ball.body:getLinearVelocity()
      local s = BALL_SPEED_STRETCH * math.sqrt(vx * vx + vy * vy)
      local rot = math.atan2(vy, vx)
      love.graphics.push()
      love.graphics.setColor(color)
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
    local ballPreviewHeight = 80
    local ballPreviewX = BASE_SCREEN_WIDTH - (BORDER_THICKNESS)/2
    love.graphics.setLineWidth(1)
    Game.objects.nextBallPreviews:forEach(function(nextBallPreview)
      ballPreviewHeight = ballPreviewHeight + nextBallPreview.radius

      local center = {ballPreviewX, ballPreviewHeight}
      local radius = nextBallPreview.radius
      local color = nextBallPreview.getColor()

      love.graphics.push()
      love.graphics.translate(center[1], center[2])
      love.graphics.setColor(color)

      love.graphics.setLineWidth(BALL_LINE_WIDTH_OUT)
      love.graphics.circle('line', 0, 0, radius * BALL_DRAW_SCALE)
      love.graphics.setLineWidth(BALL_LINE_WIDTH_IN)
      love.graphics.circle('line', 0, 0, radius * BALL_DRAW_SCALE - BALL_LINES_DISTANCE)
      love.graphics.pop()

      ballPreviewNum = ballPreviewNum + 1

      ballPreviewHeight = ballPreviewHeight + nextBallPreview.radius + 5
    end)
  end
}
