require 'game_debug'

-- Libraries
require 'math_utils'
local List = require 'doubly_linked_list'
local Vector = require 'vector2d'

-- Game Files
require 'touch_input'
require 'events'
require 'data_constants'

-- Helper functions
function GetRandomRadius()
  return BASE_RADIUS * RADIUS_MULTIPLIERS[math.random(#RADIUS_MULTIPLIERS)]
end

function GetColor(number)
  local h = number * math.floor(360/NUM_COLORS)
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

function NewBallPreview(initialX)
  local number = math.random(NUM_COLORS)
  local radius = GetRandomRadius()
  local getColor = function() return GetColor((number % NUM_COLORS)) end
  local position = Vector.new{x=initialX or BASE_SCREEN_WIDTH/2, y=radius + PREVIEW_PADDING}
  return {
    position = position,
    radius = radius,
    getColor = getColor,
    drawStyle = 'line'
  }
end

function IsInsideScreen(x, y)
  return utils.isInsideRect(x, y, 0, 0, BASE_SCREEN_WIDTH, BASE_SCREEN_HEIGHT)
end

-- Variables
local objects = {}
local ballPreview
local nextBallPreview
local world = nil
local scoreCombo = 0
local scoreBalls = 0
local combo = 1

local hit = false
local lastHit = false

local ballsRemoved = 0
local totalSpeed2 = 0
local lastTotalSpeed2 = -1
local time = 0

-- Behaviour definitions
function love.load()
  math.randomseed( os.time() )
  ballPreview = NewBallPreview()
  nextBallPreview = NewBallPreview()

  love.window.setTitle(TITLE)
  love.window.setMode(BASE_SCREEN_WIDTH, BASE_SCREEN_HEIGHT, {resizable=true})

  -- Physics
  love.physics.setMeter(METER)
  world = love.physics.newWorld(0, GRAVITY, true)
  world:setCallbacks(beginContact, endContact, preSolve, postSolve)

  -- Initial objects
  objects.ground = {}
  objects.ground.body = love.physics.newBody(world, BASE_SCREEN_WIDTH/2, BASE_SCREEN_HEIGHT-BOTTOM_THICKNESS/2)
  objects.ground.shape = love.physics.newRectangleShape(BASE_SCREEN_WIDTH, BOTTOM_THICKNESS)
  objects.ground.fixture = love.physics.newFixture(objects.ground.body, objects.ground.shape)
  --objects.ground.fixture:setFriction(1)
  objects.ground.fixture:setCategory(COL_MAIN_CATEGORY)

  objects.wallL = {}
  objects.wallL.body = love.physics.newBody(world, BASE_SCREEN_WIDTH-BORDER_THICKNESS/2, BASE_SCREEN_HEIGHT/2)
  objects.wallL.shape = love.physics.newRectangleShape(BORDER_THICKNESS, BASE_SCREEN_HEIGHT)
  objects.wallL.fixture = love.physics.newFixture(objects.wallL.body, objects.wallL.shape)
  objects.wallL.fixture:setCategory(COL_MAIN_CATEGORY)

  objects.wallR = {}
  objects.wallR.body = love.physics.newBody(world, BORDER_THICKNESS/2, BASE_SCREEN_HEIGHT/2)
  objects.wallR.shape = love.physics.newRectangleShape(BORDER_THICKNESS, BASE_SCREEN_HEIGHT)
  objects.wallR.fixture = love.physics.newFixture(objects.wallR.body, objects.wallR.shape)
  objects.wallR.fixture:setCategory(COL_MAIN_CATEGORY)

  objects.balls = List.new(function(ball)
    ball.fixture:destroy()
    ball.body:destroy()
    ball = nil
  end)

  -- UI
  game.UI.initialize()

  -- Events
  game.events:add(EVENT_MOVED_PREVIEW, function(x, y, dx, dy)
    if ballPreview then
      ballPreview.drawStyle = 'fill'
      ballPreview.position.x = utils.clamp(x, BORDER_THICKNESS + ballPreview.radius, BASE_SCREEN_WIDTH - (BORDER_THICKNESS + ballPreview.radius))
    end
  end)

  game.events:add(EVENT_RELEASED_PREVIEW, ReleaseBall)
  game.events:add(EVENT_PRESSED_SWITCH, SwitchBall)
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

  game.UI.adjust((screenWidth-drawWidth)/2, (screenHeight-drawHeight), drawWidth/BASE_SCREEN_WIDTH, drawHeight/BASE_SCREEN_HEIGHT)
  love.graphics.translate(game.UI.deltaX, game.UI.deltaY)
  love.graphics.scale(game.UI.scaleX, game.UI.scaleY)

  if ballPreview then
    love.graphics.setColor(ballPreview.getColor())
    love.graphics.circle(ballPreview.drawStyle, ballPreview.position.x, ballPreview.position.y, ballPreview.radius)
  end

  love.graphics.setColor(255, 255, 255)
  love.graphics.polygon('fill', objects.ground.body:getWorldPoints(objects.ground.shape:getPoints())) 
  love.graphics.polygon('fill', objects.wallL.body:getWorldPoints(objects.wallL.shape:getPoints()))
  love.graphics.polygon('fill', objects.wallR.body:getWorldPoints(objects.wallR.shape:getPoints()))

  local ballCount = 0
  local BALL_SPEED_STRETCH = 0.2
  objects.balls:forEach(function(ball) 
    ballCount = ballCount + 1
    local vx, vy = ball.body:getLinearVelocity()
    local s = BALL_SPEED_STRETCH * math.sqrt(vx * vx + vy * vy)
    local rot = math.atan2(vy, vx)
    love.graphics.setColor(ball.getColor())
    love.graphics.push()

    --love.graphics.rotate(rot)
    --love.graphics.scale(1+s, 1-s)
    love.graphics.circle('fill', ball.body:getX(), ball.body:getY(), ball.shape:getRadius())
    love.graphics.pop()
    --DEBUGGER.line('ball: x='..ball.body:getX()..' y='..ball.body:getY()..'\n')
  end)

  -- UI
  love.graphics.setColor({0, 0, 0, 255})
  --[[love.graphics.print(string.format('Score: %04d\n'..
      '%04d(balls)+%04d(combo)\n'..
      'Combo: x%02d\n',
      tostring(scoreCombo + scoreBalls),
      tostring(scoreBalls),
      tostring(scoreCombo),
      tostring(combo)),
    0, 10)]]--

  love.graphics.print('Next Ball (Click to swap)', BASE_SCREEN_WIDTH - 180, 20)

  love.graphics.setColor(0, 0, 0)
  love.graphics.rectangle('fill', BASE_SCREEN_WIDTH
    - 100 - MAX_RADIUS*1.1, 20 + 20, 2*MAX_RADIUS*1.1, 2*MAX_RADIUS*1.1) 
  love.graphics.setColor(nextBallPreview.getColor())
  love.graphics.circle('fill', BASE_SCREEN_WIDTH
    - 100, 20 + 20 + MAX_RADIUS*1.1, nextBallPreview.radius)

  game.UI.draw()

  -- debug
  DEBUGGER.draw()
end

function love.update(dt)
  world:update(dt)

  totalSpeed2 = 0
  objects.balls:forEach(function(ball)
    local x, y = ball.body:getLinearVelocity()
    totalSpeed2 = totalSpeed2 + x*x + y*y
    local px, py = ball.body:getPosition() 
    -- TODO: create max radius variable
    if not IsInsideScreen(px, py) then
      objects.balls:SetToDelete(ball)
      ballsRemoved = ballsRemoved + 1
    end
  end)

  -- TODO: Make this more robust
  if totalSpeed2 < MIN_SPEED2 then
    if lastTotalSpeed2 >= MIN_SPEED2 then
      if not ballPreview then
        ballPreview = nextBallPreview 
        nextBallPreview = NewBallPreview() 
      end
      if not hit then
        combo = 1
      end
      lastHit = hit
      hit = false
    end
  end

  if ballPreview then
    if love.keyboard.isDown('right') then --press the right arrow key to push the ball to the right
      ballPreview.position.x = ballPreview.position.x + PREVIEW_SPEED * dt
    elseif love.keyboard.isDown('left') then
      ballPreview.position.x = ballPreview.position.x - PREVIEW_SPEED * dt
    end
    ballPreview.position.x = utils.clamp(ballPreview.position.x, BORDER_THICKNESS + ballPreview.radius, BASE_SCREEN_WIDTH - (BORDER_THICKNESS + ballPreview.radius))
  end

  lastTotalSpeed2 = totalSpeed2

  objects.balls:Clean()
  game.UI:Clean()
end

function beginContact(a, b, coll)
  local aref = a:getUserData() and a:getUserData().ref
  local bref = b:getUserData() and b:getUserData().ref
  if not aref or not bref then return end
  aref.color = aref.getColor()
  bref.color = bref.getColor()
  if aref.color[1] == bref.color[1] and aref.color[2] == bref.color[2] and aref.color[3] == bref.color[3] then
    scoreBalls = scoreBalls + 2
    scoreCombo = scoreCombo + 2 * combo
    a:setMask(COL_MAIN_CATEGORY)
    b:setMask(COL_MAIN_CATEGORY)
    hit = true
    combo = combo + 1
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
  local newBall = {}
  newBall.radius = ballPreview.radius
  newBall.getColor = ballPreview.getColor
  newBall.body = love.physics.newBody(world, ballPreview.position.x, ballPreview.position.y, 'dynamic')
  --newBall.body:setFixedRotation(false)
  newBall.shape = love.physics.newCircleShape(ballPreview.radius)
  newBall.fixture = love.physics.newFixture(newBall.body, newBall.shape)
  newBall.fixture:setCategory(COL_MAIN_CATEGORY)
  --newBall.fixture:setRestitution(0)
  newBall.fixture:setUserData({
      ref = newBall,
    })
  objects.balls:add(newBall)

  --ballPreview = NewBallPreview(ballPreview.position.x)
  ballPreview = nil
end

function SwitchBall()
  if not ballPreview then return end
  local aux = ballPreview
  ballPreview = nextBallPreview
  nextBallPreview = aux
end

-- INPUT
function love.keypressed(key)
  if key == INPUT_RELEASE_BALL then
    ReleaseBall() 
  end 

  if key == INPUT_SWITCH_BALL then
    SwitchBall()
  end

  if key == 'r' then
    DEBUGGER.line('Reloaded UI and constants')
    game.UI:Clear()
    game.UI:initialize()
    dofile('data/constants.lua')
  end

  if key == 't' then
    objects.balls:Clear()
  end
  if key == 'e' then
    DEBUGGER.clear()
  end
end

function love.mousepressed(x, y)
  -- TODO: remove
  game.touch.pressed(x, y)
end

function love.mousemoved(x, y, dx, dy)
  -- TODO: remove
  if ballPreview then
    ballPreview.drawStyle = 'line'
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
