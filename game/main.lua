require 'Game_debug'

-- Libraries
require 'math_utils'
local List = require 'doubly_linked_list'
local Queue = require 'queue'
local Vector = require 'vector2d'

-- Game Files
local Game = require 'game'
require 'data_constants'

-- Helper functions
function GetRandomRadius()
  return BASE_RADIUS * RADIUS_MULTIPLIERS[math.random(#RADIUS_MULTIPLIERS)]
end

function GetBallNumber() 
  return math.random(#BALL_COLORS)
end


function NewBallPreview(initialData)
  initialData = initialData or {
    indestructible = false,
  }
  local number = GetBallNumber()
  --local indestructible = math.random() > 0.9
  local radius = GetRandomRadius()
  local getColor = function() return initialData.indestructible and {255, 255, 255} or BALL_COLORS[number] end
  local position = Vector.new{x=BASE_SCREEN_WIDTH/2, y=radius + PREVIEW_PADDING}
  return {
    number = number,
    position = position,
    radius = radius,
    getColor = getColor,
    drawStyle = 'line',
    indestructible = initialData.indestructible,
    destroyed = false,
  }
end

function IsInsideScreen(x, y)
  return utils.isInsideRect(x, y, 0, 0, BASE_SCREEN_WIDTH, BASE_SCREEN_HEIGHT)
end

-- Variables
local lastDroppedBall

local hit = false
local lastHit = false

local ballsRemoved = 0
local totalSpeed2 = 0
local lastTotalSpeed2 = -1
local time = 0

local PostEffectsShader
local BallShader
local lightDirection = {1, 1, 3}
local gameCanvas

local startTime = love.timer.getTime()

-- Behaviour definitions
function love.load()
  math.randomseed( os.time() )
  love.window.setTitle(TITLE)
  love.window.setMode(BASE_SCREEN_WIDTH, BASE_SCREEN_HEIGHT, {resizable=true})

  -- Physics
  love.physics.setMeter(METER)

  -- UI
  local screenWidth, screenHeight = love.window.getMode()
  local aspectRatio = screenWidth/screenHeight
  local drawWidth, drawHeight
  if aspectRatio > ASPECT_RATIO then
    drawHeight = screenHeight
    drawWidth = drawHeight * ASPECT_RATIO
  else
    drawWidth = screenWidth
    drawHeight = drawWidth / ASPECT_RATIO
  end


  Game.UI.adjust((screenWidth-drawWidth)/2, (screenHeight-drawHeight), drawWidth/BASE_SCREEN_WIDTH, drawHeight/BASE_SCREEN_HEIGHT)
  Game.UI.initialize()

  -- Shaders
  BallShader = love.graphics.newShader('ballShader.fs')
  PostEffectsShader = love.graphics.newShader('postfx.fs')

  -- Game Canvas
  gameCanvas = love.graphics.newCanvas(screenWidth, screenHeight)

  Game.start()
end

function love.draw() 
  love.graphics.translate(Game.UI.deltaX, Game.UI.deltaY)
  love.graphics.scale(Game.UI.scaleX, Game.UI.scaleY)
  love.graphics.setNewFont(12)

  -- Move to new canvas
  love.graphics.setCanvas(gameCanvas)
  love.graphics.translate(Game.UI.deltaX, Game.UI.deltaY)
  love.graphics.scale(Game.UI.scaleX, Game.UI.scaleY)
  love.graphics.setColor(255, 255, 255)
  love.graphics.polygon('fill', Game.objects.ground.body:getWorldPoints(Game.objects.ground.shape:getPoints())) 
  love.graphics.polygon('fill', Game.objects.wallL.body:getWorldPoints(Game.objects.wallL.shape:getPoints()))
  love.graphics.polygon('fill', Game.objects.wallR.body:getWorldPoints(Game.objects.wallR.shape:getPoints()))

  -- Stage BG
  love.graphics.setLineWidth(1)
  --love.graphics.setColor(0, 0, 0)
  love.graphics.setColor(255, 255, 255)
  love.graphics.rectangle('fill', BORDER_THICKNESS, -10, HOLE_WIDTH, HOLE_DEPTH + 10)
  love.graphics.setColor(0, 0, 0)
  love.graphics.rectangle('line', BORDER_THICKNESS, -10, HOLE_WIDTH, HOLE_DEPTH + 10)

  -- Balls

  -- Ball Preview
  local time = love.timer.getTime() - startTime
  love.graphics.setShader(BallShader)
  --BallShader:send('light_dir', lightDirection)
  if Game.objects.ballPreview and Game.objects.ballPreview.drawStyle ~= 'none' then
    local center = {Game.objects.ballPreview.position.x, Game.objects.ballPreview.position.y}
    local radius = Game.objects.ballPreview.radius
    BallShader:send('center', center)
    BallShader:send('radius', radius)
    BallShader:send('time', time)
    BallShader:send('time_destroyed', -1)


    love.graphics.setColor(Game.objects.ballPreview.getColor())
    love.graphics.circle('fill', center[1], center[2], radius)

  end

  local ballCount = 0
  local BALL_SPEED_STRETCH = 0.2
  Game.objects.balls:forEach(function(ball) 
    local center = {ball.body:getX(), ball.body:getY()}
    local radius = ball.radius
    BallShader:send('center', center)
    BallShader:send('radius', radius)
    BallShader:send('time', time)
    BallShader:send('time_destroyed', ball.timeDestroyed or -1)
    ballCount = ballCount + 1
    local vx, vy = ball.body:getLinearVelocity()
    local s = BALL_SPEED_STRETCH * math.sqrt(vx * vx + vy * vy)
    local rot = math.atan2(vy, vx)
    love.graphics.push()
    local color = ball.getColor()
    --color[4] = ball.transparency 
    love.graphics.setColor(color)
    --love.graphics.rotate(rot)
    --love.graphics.scale(1+s, 1-s)
    love.graphics.circle('fill', center[1], center[2], radius)
    love.graphics.pop()
    --love.graphics.reset()
    --DEBUGGER.line('ball: x='..ball.body:getX()..' y='..ball.body:getY()..'\n')
  end)

  -- Next balls
  local ballPreviewNum = 1
  local ballPreviewHeight = 40
  local ballPreviewX = BASE_SCREEN_WIDTH - (BORDER_THICKNESS)/2
  love.graphics.setLineWidth(1)
  Game.objects.nextBallPreviews:forEach(function(nextBallPreview)
    ballPreviewHeight = ballPreviewHeight + nextBallPreview.radius

    local center = {ballPreviewX, ballPreviewHeight}
    local radius = nextBallPreview.radius
    BallShader:send('center', center)
    BallShader:send('radius', radius)
    BallShader:send('time', time)
    BallShader:send('time_destroyed', -1)

    love.graphics.setColor(nextBallPreview.getColor())

    love.graphics.circle('fill', center[1], center[2], radius)

    ballPreviewNum = ballPreviewNum + 1

    ballPreviewHeight = ballPreviewHeight + nextBallPreview.radius + 5
  end)
  love.graphics.setShader()


  -- switch canvas and draw with new shader
  love.graphics.setCanvas()
  love.graphics.setColor(255, 255, 255)
  love.graphics.setShader(PostEffectsShader)
  love.graphics.draw(gameCanvas)
  love.graphics.setShader()

  -- UI
  love.graphics.setColor(0, 0, 0)
  love.graphics.print(string.format('Score: %04d\n'..
      'Last Combo: x%02d (%04d)\n'..
      'Max Combo: x%02d (%04d)\n',
      tostring(Game.score),
      tostring(Game.combo),
      tostring(ComboMultiplier(Game.combo)),
      tostring(Game.maxCombo),
      tostring(ComboMultiplier(Game.maxCombo))),
    5, 15)

  love.graphics.print('Next Balls:', BASE_SCREEN_WIDTH - 150, 20)

  Game.UI.draw()

  if Game.state == STATE_GAME_OVER then
    love.graphics.setNewFont(25)
    love.graphics.setColor(200, 50, 0)
    love.graphics.print(string.format('Game OVER\n'..
        'Final Score: %04d\n'..
        'Max Combo: %02d\n\n'..
        'Restart',
      Game.score, Game.maxCombo), BASE_SCREEN_WIDTH/2 - 100, BASE_SCREEN_HEIGHT/2 - 115)
  end

  -- debug
  DEBUGGER.draw()
end

local staticFrameCount = 0

function OnBallsStatic()
  DEBUGGER.line('static')
  local ballsTooHigh = false
  Game.objects.balls:forEach(function(ball)
    if not ball.inGame then return end
    if ball.body:getY() < MIN_DISTANCE_TO_TOP + ball.radius then
      ballsTooHigh = true
    end
  end)
  if ballsTooHigh then
    GameOver()
  end
  lastHit = hit
  hit = false
  if Game.combo > Game.maxCombo then Game.maxCombo = Game.combo return end
  Game.combo = 0

end


function love.update(dt)
  Game.world:update(dt)

  totalSpeed2 = 0
  Game.objects.balls:forEach(function(ball)
    local px, py = ball.body:getPosition() 
    if not IsInsideScreen(px, py) then
      Game.objects.balls:SetToDelete(ball)
      ballsRemoved = ballsRemoved + 1
    end

    if ball.inGame then
      local x, y = ball.body:getLinearVelocity()
      totalSpeed2 = totalSpeed2 + x*x + y*y
    end
    -- TODO: create max radius variable
  end)

  -- TODO: Make this more robust
  if totalSpeed2 < MIN_SPEED2 then
    staticFrameCount = staticFrameCount + 1
    if staticFrameCount == FRAMES_TO_STATIC then
      Game.events:fire(EVENT_ON_BALLS_STATIC)
    end
  else
    staticFrameCount = 0
  end


  if lastDroppedBall then
    if lastDroppedBall.body:getY() > MIN_DISTANCE_TO_TOP + lastDroppedBall.radius then
      Game.events:fire(EVENT_SAFE_TO_DROP)
      lastDroppedBall = nil
    end
  end

  if Game.state == STATE_GAME_OVER then
    return
  end

  --[[if Game.objects.ballPreview then
    if love.keyboard.isDown('right') then --press the right arrow key to push the ball to the right
      Game.objects.ballPreview.position.x = Game.objects.ballPreview.position.x + PREVIEW_SPEED * dt
    elseif love.keyboard.isDown('left') then
      Game.objects.ballPreview.position.x = Game.objects.ballPreview.position.x - PREVIEW_SPEED * dt
    end
    Game.objects.ballPreview.position.x = utils.clamp(Game.objects.ballPreview.position.x, BORDER_THICKNESS + Game.objects.ballPreview.radius + 1, BASE_SCREEN_WIDTH - (BORDER_THICKNESS + Game.objects.ballPreview.radius) - 1)
  end]]--

  lastTotalSpeed2 = totalSpeed2

  Game.objects.balls:Clean()
  Game.UI:Clean()
end

function ComboMultiplier(combo)
  if combo == 0 then return 0 end
  return math.pow(2, combo)
end

function GameOver()
  Game.objects.balls:forEach(function(ball)
    if not ball.indestructible then return end
    DestroyBall(ball)
  end)
  Game.state = STATE_GAME_OVER
end

function beginContact(a, b, coll)
  local aref = a:getUserData() and a:getUserData().ref
  local bref = b:getUserData() and b:getUserData().ref
  if aref then aref.inGame = true end
  if bref then bref.inGame = true end
  if not aref or not bref then return end
  aref.color = aref.getColor()
  bref.color = bref.getColor()

  if aref.indestructible or bref.indestructible then return end
  if aref.number == bref.number then
    Game.combo = Game.combo + 1
    Game.score = Game.score + ComboMultiplier(Game.combo)
    DestroyBall(aref)
    DestroyBall(bref)
    hit = true
  end
end

function endContact(a, b, coll)
end
function preSolve(a, b, coll)
end
function postSolve(a, b, coll, normalimpulse, tangentimpulse)
end

function ReleaseBall()
  if not Game.objects.ballPreview then return end
  local newBall = Game.objects.ballPreview

  newBall.inGame = false
  newBall.body = love.physics.newBody(Game.world, Game.objects.ballPreview.position.x, Game.objects.ballPreview.position.y, 'dynamic')
  --newBall.body:setFixedRotation(false)
  newBall.shape = love.physics.newCircleShape(Game.objects.ballPreview.radius)
  newBall.fixture = love.physics.newFixture(newBall.body, newBall.shape)
  newBall.fixture:setCategory(COL_MAIN_CATEGORY)
  --newBall.fixture:setRestitution(0)
  newBall.fixture:setUserData({
      ref = newBall,
    })
  Game.objects.balls:add(newBall)

  Game.objects.ballPreview = nil
  --Game.objects.ballPreview = NewBallPreview(Game.objects.ballPreview.position.x)
  lastDroppedBall = newBall

end

function DestroyBall(ball)
  ball.inGame = true
  ball.destroyed = true
  ball.timeDestroyed = love.timer.getTime() - startTime
  ball.fixture:setMask(COL_MAIN_CATEGORY)
end

function GetNextBall() 
  if not Game.objects.ballPreview then
    Game.objects.ballPreview = Game.objects.nextBallPreviews:dequeue()
    local hasWhiteBalls = false
    Game.objects.nextBallPreviews:forEach(function(ball)
      if ball.indestructible then
        hasWhiteBalls = true
        DEBUGGER.line('White balls')
      end
    end)
    if hasWhiteBalls then 
      Game.objects.nextBallPreviews:enqueue(NewBallPreview())
    else
      Game.objects.nextBallPreviews:enqueue(NewBallPreview({indestructible = true}))
    end
  end
end
-- INPUT
function love.keypressed(key)
  if Game.state == STATE_GAME_RUNNING then
    if key == INPUT_RELEASE_BALL then
      ReleaseBall() 
    end 

    if key == INPUT_SWITCH_BALL then
      SwitchBall()
    end
  end

  -- DEBUG input
  if key == 'u' then
    DEBUGGER.line('Reloaded UI and constants')
    Game.UI:Clear()
    Game.UI:initialize()
    dofile('Game/data_ui.lua')
    dofile('Game/data_constants.lua')
  end

  if key == 'o' then
    GameOver()
  end

  if key == 'r' then
    Game.objects.balls:Clear()
    Game.state = STATE_GAME_RUNNING
    Game.objects.ballPreview = NewBallPreview()
    Game.objects.nextBallPreviews:Clear()
    Game.objects.nextBallPreviews:enqueue(NewBallPreview())
  end
  if key == 'e' then
    DEBUGGER.clear()
  end
end

function love.mousepressed(x, y)
  Game.UI.pressed(x, y)
end

function love.mousemoved(x, y, dx, dy)
  -- TODO: move this
  if Game.objects.ballPreview then
    Game.objects.ballPreview.drawStyle = 'none'
  end
  Game.UI.moved(x, y, dx, dy)
end

function love.mousereleased(x, y, button)
  Game.UI.released(x, y)
end

--[[function love.touchpressed(id, x, y)
  Game.touch.pressed(x, y)
end

function love.touchmoved(id, x, y, dx, dy)
  Game.touch.moved(x, y, dx, dy)
end

function love.touchreleased(id, x, y)
  Game.touch.released(x, y)
end]]--
