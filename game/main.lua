require 'game_debug'

-- Libraries
require 'math_utils'
local List = require 'doubly_linked_list'
local Queue = require 'queue'
local Vector = require 'vector2d'

-- Game Files
require 'ui'
require 'events'
require 'data_constants'

-- Helper functions
function GetRandomRadius()
  return BASE_RADIUS * RADIUS_MULTIPLIERS[math.random(#RADIUS_MULTIPLIERS)]
end

function GetColor(number)
  local h = (number * math.floor(360/NUM_COLORS) + BALL_HUE_OFFSET) % 360
  local s = BALL_SATURATION
  local v = BALL_VALUE

  local c = v * s
  local x = c * (1-math.abs((h/60)%2 -1))
  local m = v - c
  local hdiv = math.floor(h/60)

  local HSVtoRGBt = {
    {c, x, 0},
    {x, c, 0},
    {0, c, x},
    {0, x, c},
    {x, 0, c},
    {c, 0, x}
  }

  local rr, gg, bb = unpack(HSVtoRGBt[hdiv + 1])

  local r = (rr + m) * 255
  local g = (gg + m) * 255
  local b = (bb + m) * 255
  return {r, g, b, 255}
end

function NewBallPreview(initialData)
  initialData = initialData or {
    indestructible = false,
  }
  local number = math.random(NUM_COLORS)
  --local indestructible = math.random() > 0.9
  local radius = GetRandomRadius()
  local getColor = function() return initialData.indestructible and {255, 255, 255} or GetColor((number % NUM_COLORS)) end
  local position = Vector.new{x=BASE_SCREEN_WIDTH/2, y=radius + PREVIEW_PADDING}
  return {
    position = position,
    radius = radius,
    getColor = getColor,
    drawStyle = 'line',
    indestructible = initialData.indestructible,
    transparency = 255,
  }
end

function IsInsideScreen(x, y)
  return utils.isInsideRect(x, y, 0, 0, BASE_SCREEN_WIDTH, BASE_SCREEN_HEIGHT)
end

-- Variables
local ballPreview
local nextBallPreviews = Queue.new()
local lastDroppedBall
local world = nil
local scoreCombo = 0
local combo = 0
local maxCombo = 0

local hit = false
local lastHit = false

local ballsRemoved = 0
local totalSpeed2 = 0
local lastTotalSpeed2 = -1
local time = 0

game = game or {}
game.objects = {}
game.state = STATE_GAME_RUNNING

-- Behaviour definitions
function love.load()
  game.state = STATE_GAME_RUNNING

  math.randomseed( os.time() )
  ballPreview = NewBallPreview()

  -- Initialize Previews
  for _=1,NUM_BALL_PREVIEWS do
    nextBallPreviews:enqueue(NewBallPreview())
  end

  love.window.setTitle(TITLE)
  love.window.setMode(BASE_SCREEN_WIDTH, BASE_SCREEN_HEIGHT, {resizable=true})

  -- Physics
  love.physics.setMeter(METER)
  world = love.physics.newWorld(0, GRAVITY, true)
  world:setCallbacks(beginContact, endContact, preSolve, postSolve)

  -- Initial objects
  game.objects.ground = {}
  game.objects.ground.body = love.physics.newBody(world, BASE_SCREEN_WIDTH/2, BASE_SCREEN_HEIGHT-BOTTOM_THICKNESS/2)
  game.objects.ground.shape = love.physics.newRectangleShape(BASE_SCREEN_WIDTH, BOTTOM_THICKNESS)
  game.objects.ground.fixture = love.physics.newFixture(game.objects.ground.body, game.objects.ground.shape)
  game.objects.ground.fixture:setCategory(COL_MAIN_CATEGORY)

  game.objects.wallL = {}
  game.objects.wallL.body = love.physics.newBody(world, BASE_SCREEN_WIDTH-BORDER_THICKNESS/2, BASE_SCREEN_HEIGHT/2)
  game.objects.wallL.shape = love.physics.newRectangleShape(BORDER_THICKNESS, BASE_SCREEN_HEIGHT)
  game.objects.wallL.fixture = love.physics.newFixture(game.objects.wallL.body, game.objects.wallL.shape)
  game.objects.wallL.fixture:setCategory(COL_MAIN_CATEGORY)

  game.objects.wallR = {}
  game.objects.wallR.body = love.physics.newBody(world, BORDER_THICKNESS/2, BASE_SCREEN_HEIGHT/2)
  game.objects.wallR.shape = love.physics.newRectangleShape(BORDER_THICKNESS, BASE_SCREEN_HEIGHT)
  game.objects.wallR.fixture = love.physics.newFixture(game.objects.wallR.body, game.objects.wallR.shape)
  game.objects.wallR.fixture:setCategory(COL_MAIN_CATEGORY)

  game.objects.balls = List.new(function(ball)
    if ball.fixture and not ball.fixture:isDestroyed() then ball.fixture:destroy() end
    if ball.body and not ball.body:isDestroyed() then ball.body:destroy() end
    ball = nil
  end)

  -- UI
  game.UI.initialize()

  -- Events
  game.events:add(EVENT_MOVED_PREVIEW, function(x, y, dx, dy)
    if ballPreview then
      ballPreview.drawStyle = 'line'
      ballPreview.position.x = utils.clamp(x, BORDER_THICKNESS + ballPreview.radius + 1, BASE_SCREEN_WIDTH - (BORDER_THICKNESS + ballPreview.radius) - 1)
    end
  end)

  game.events:add(EVENT_RELEASED_PREVIEW, ReleaseBall)
  game.events:add(EVENT_PRESSED_SWITCH, SwitchBall)
  game.events:add(EVENT_ON_BALLS_STATIC, OnBallsStatic)
  game.events:add(EVENT_SAFE_TO_DROP, GetNextBall)
end

function love.draw() 
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

  love.graphics.setNewFont(12)

  game.UI.adjust((screenWidth-drawWidth)/2, (screenHeight-drawHeight), drawWidth/BASE_SCREEN_WIDTH, drawHeight/BASE_SCREEN_HEIGHT)
  love.graphics.translate(game.UI.deltaX, game.UI.deltaY)
  love.graphics.scale(game.UI.scaleX, game.UI.scaleY)


  love.graphics.setColor(255, 255, 255)
  love.graphics.polygon('fill', game.objects.ground.body:getWorldPoints(game.objects.ground.shape:getPoints())) 
  love.graphics.polygon('fill', game.objects.wallL.body:getWorldPoints(game.objects.wallL.shape:getPoints()))
  love.graphics.polygon('fill', game.objects.wallR.body:getWorldPoints(game.objects.wallR.shape:getPoints()))

  -- Stage BG
  love.graphics.setLineWidth(1)
  love.graphics.setColor(255, 255, 255)
  love.graphics.rectangle('fill', BORDER_THICKNESS, -10, HOLE_WIDTH, HOLE_DEPTH + 10)
  love.graphics.setColor(0, 0, 0)
  love.graphics.rectangle('line', BORDER_THICKNESS, -10, HOLE_WIDTH, HOLE_DEPTH + 10)

  -- Ball Preview
  if ballPreview and ballPreview.drawStyle ~= 'none' then
    love.graphics.setColor(ballPreview.getColor())
    love.graphics.circle('fill', ballPreview.position.x, ballPreview.position.y, ballPreview.radius)
    love.graphics.setLineWidth(1)
    love.graphics.setColor(0, 0, 0)
    love.graphics.circle('line', ballPreview.position.x, ballPreview.position.y, ballPreview.radius)
  end

  -- Balls
  local ballCount = 0
  local BALL_SPEED_STRETCH = 0.2
  love.graphics.setLineWidth(1)
  game.objects.balls:forEach(function(ball) 
    ballCount = ballCount + 1
    local vx, vy = ball.body:getLinearVelocity()
    local s = BALL_SPEED_STRETCH * math.sqrt(vx * vx + vy * vy)
    local rot = math.atan2(vy, vx)
    love.graphics.push()
    local color = ball.getColor()
    color[4] = ball.transparency 
    love.graphics.setColor(color)
    --love.graphics.rotate(rot)
    --love.graphics.scale(1+s, 1-s)
    love.graphics.circle('fill', ball.body:getX(), ball.body:getY(), ball.shape:getRadius())
    love.graphics.setColor(0, 0, 0)
    love.graphics.circle('line', ball.body:getX(), ball.body:getY(), ball.shape:getRadius())
    love.graphics.pop()
    --love.graphics.reset()
    --DEBUGGER.line('ball: x='..ball.body:getX()..' y='..ball.body:getY()..'\n')
  end)

  --[[
  -- Preview box
  love.graphics.setColor(0, 0, 0)
  love.graphics.rectangle('fill', BASE_SCREEN_WIDTH
    - 100 - MAX_RADIUS*1.1, 20 + 20, 2*MAX_RADIUS*1.1, 2*MAX_RADIUS*1.1) 
  ]]--

  -- Next balls
  local ballPreviewNum = 1
  local ballPreviewHeight = 40
  local ballPreviewX = BASE_SCREEN_WIDTH - (BORDER_THICKNESS)/2
  love.graphics.setLineWidth(1)
  nextBallPreviews:forEach(function(nextBallPreview)
    ballPreviewHeight = ballPreviewHeight + nextBallPreview.radius
    love.graphics.setColor(nextBallPreview.getColor())
    love.graphics.circle('fill', ballPreviewX, ballPreviewHeight, nextBallPreview.radius)
    love.graphics.setColor(0, 0, 0)
    love.graphics.circle('line', ballPreviewX, ballPreviewHeight, nextBallPreview.radius)
    ballPreviewNum = ballPreviewNum + 1

    ballPreviewHeight = ballPreviewHeight + nextBallPreview.radius + 5
  end)

  -- UI
  love.graphics.setColor({0, 0, 0, 255})
  love.graphics.print(string.format('Score: %04d\n'..
      --'%04d(balls)+%04d(combo)\n'..
      'Last Combo: x%02d (%04d)\n'..
      'Max Combo: x%02d (%04d)\n',
      --tostring(scoreCombo + scoreBalls),
      --tostring(scoreBalls),
      tostring(scoreCombo),
      tostring(combo),
      tostring(ComboMultiplier(combo)),
      tostring(maxCombo),
      tostring(ComboMultiplier(maxCombo))),
    5, 15)

  love.graphics.print('Next Balls:', BASE_SCREEN_WIDTH - 150, 20)

  game.UI.draw()

  if game.state == STATE_GAME_OVER then
    love.graphics.setNewFont(25)
    love.graphics.setColor({200, 50, 0, 255})
    love.graphics.print(string.format('GAME OVER\n'..
        'Final Score: %04d\n'..
        'Max Combo: %02d\n\n'..
        'Restart',
      scoreCombo, maxCombo), BASE_SCREEN_WIDTH/2 - 100, BASE_SCREEN_HEIGHT/2 - 115)
  end

  -- debug
  DEBUGGER.draw()
end

local staticFrameCount = 0

function OnBallsStatic()
  DEBUGGER.line('static')
  local ballsTooHigh = false
  game.objects.balls:forEach(function(ball)
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
  if combo > maxCombo then maxCombo = combo return end
  combo = 0

end

function love.update(dt)
  world:update(dt)

  totalSpeed2 = 0
  game.objects.balls:forEach(function(ball)
    local px, py = ball.body:getPosition() 
    if not IsInsideScreen(px, py) then
      game.objects.balls:SetToDelete(ball)
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
      game.events:fire(EVENT_ON_BALLS_STATIC)
    end
  else
    staticFrameCount = 0
  end


  if lastDroppedBall then
    if lastDroppedBall.body:getY() > MIN_DISTANCE_TO_TOP + lastDroppedBall.radius then
      game.events:fire(EVENT_SAFE_TO_DROP)
      lastDroppedBall = nil
    end
  end

  if game.state == STATE_GAME_OVER then
    return
  end

  --[[if ballPreview then
    if love.keyboard.isDown('right') then --press the right arrow key to push the ball to the right
      ballPreview.position.x = ballPreview.position.x + PREVIEW_SPEED * dt
    elseif love.keyboard.isDown('left') then
      ballPreview.position.x = ballPreview.position.x - PREVIEW_SPEED * dt
    end
    ballPreview.position.x = utils.clamp(ballPreview.position.x, BORDER_THICKNESS + ballPreview.radius + 1, BASE_SCREEN_WIDTH - (BORDER_THICKNESS + ballPreview.radius) - 1)
  end]]--

  lastTotalSpeed2 = totalSpeed2

  game.objects.balls:Clean()
  game.UI:Clean()
end

function ComboMultiplier(combo)
  if combo == 0 then return 0 end
  return math.pow(2, combo)
end

function GameOver()
  game.objects.balls:forEach(function(ball)
    if not ball.indestructible then return end
    DestroyBall(ball)
  end)
  game.state = STATE_GAME_OVER
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
  if aref.color[1] == bref.color[1] and aref.color[2] == bref.color[2] and aref.color[3] == bref.color[3] then
    combo = combo + 1
    scoreCombo = scoreCombo + ComboMultiplier(combo)
    DestroyBall(aref)
    DestroyBall(bref)
    hit = true
    aref.color[4] = 120
    bref.color[4] = 120
  end
end

function endContact(a, b, coll)
end
function preSolve(a, b, coll)
end
function postSolve(a, b, coll, normalimpulse, tangentimpulse)
end

function ReleaseBall()
  if not ballPreview then return end
  local newBall = ballPreview

  newBall.inGame = false
  newBall.body = love.physics.newBody(world, ballPreview.position.x, ballPreview.position.y, 'dynamic')
  --newBall.body:setFixedRotation(false)
  newBall.shape = love.physics.newCircleShape(ballPreview.radius)
  newBall.fixture = love.physics.newFixture(newBall.body, newBall.shape)
  newBall.fixture:setCategory(COL_MAIN_CATEGORY)
  --newBall.fixture:setRestitution(0)
  newBall.fixture:setUserData({
      ref = newBall,
    })
  game.objects.balls:add(newBall)

  ballPreview = nil
  --ballPreview = NewBallPreview(ballPreview.position.x)
  lastDroppedBall = newBall

end

function DestroyBall(ball)
  ball.inGame = true
  ball.transparency = BALL_DESTROY_TRANSPARENCY
  ball.fixture:setMask(COL_MAIN_CATEGORY)
end

function GetNextBall() 
  if not ballPreview then
    ballPreview = nextBallPreviews:dequeue()
    local hasWhiteBalls = false
    nextBallPreviews:forEach(function(ball)
      if ball.indestructible then
        hasWhiteBalls = true
        DEBUGGER.line('White balls')
      end
    end)
    if hasWhiteBalls then 
      nextBallPreviews:enqueue(NewBallPreview())
    else
      nextBallPreviews:enqueue(NewBallPreview({indestructible = true}))
    end
  end
end
-- INPUT
function love.keypressed(key)
  if game.state == STATE_GAME_RUNNING then
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
    game.UI:Clear()
    game.UI:initialize()
    dofile('game/data_ui.lua')
    dofile('game/data_constants.lua')
  end

  if key == 'o' then
    GameOver()
  end

  if key == 'r' then
    game.objects.balls:Clear()
    game.state = STATE_GAME_RUNNING
    ballPreview = NewBallPreview()
    nextBallPreviews:Clear()
    nextBallPreviews:enqueue(NewBallPreview())
  end
  if key == 'e' then
    DEBUGGER.clear()
  end
end

function love.mousepressed(x, y)
  game.touch.pressed(x, y)
end

function love.mousemoved(x, y, dx, dy)
  --if not love.mouse.isDown(1) then return end
  if ballPreview then
    ballPreview.drawStyle = 'none'
  end
  game.touch.moved(x, y, dx, dy)
end

function love.mousereleased(x, y, button)
  game.touch.released(x, y)
end

--[[function love.touchpressed(id, x, y)
  game.touch.pressed(x, y)
end

function love.touchmoved(id, x, y, dx, dy)
  game.touch.moved(x, y, dx, dy)
end

function love.touchreleased(id, x, y)
  game.touch.released(x, y)
end]]--
