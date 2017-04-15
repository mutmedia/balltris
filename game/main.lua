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

function NewBallPreview(initialX)
  local number = math.random(NUM_COLORS)
  local indestructible = math.random() > 0.9
  local radius = GetRandomRadius()
  local getColor = function() return indestructible and {255, 255, 255} or GetColor((number % NUM_COLORS)) end
  local position = Vector.new{x=initialX or BASE_SCREEN_WIDTH/2, y=radius + PREVIEW_PADDING}
  return {
    position = position,
    radius = radius,
    getColor = getColor,
    drawStyle = 'line',
    indestructible = indestructible,
    transparency = 255,
  }
end

function IsInsideScreen(x, y)
  return utils.isInsideRect(x, y, 0, 0, BASE_SCREEN_WIDTH, BASE_SCREEN_HEIGHT)
end

-- Variables
local objects = {}
local ballPreview
local nextBallPreview
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

local gameOver = false

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

  game.UI.adjust((screenWidth-drawWidth)/2, (screenHeight-drawHeight), drawWidth/BASE_SCREEN_WIDTH, drawHeight/BASE_SCREEN_HEIGHT)
  love.graphics.translate(game.UI.deltaX, game.UI.deltaY)
  love.graphics.scale(game.UI.scaleX, game.UI.scaleY)

  if ballPreview and ballPreview.drawStyle ~= 'none'then
    love.graphics.setColor(ballPreview.getColor())
    love.graphics.circle(ballPreview.drawStyle, ballPreview.position.x, ballPreview.position.y, ballPreview.radius)
    if ballPreview.indestructible then
      --love.graphics.setColor(WHITE_BALL_BORDER_COLOR)
      --love.graphics.setLineWidth(WHITE_BALL_BORDER_WIDTH)
      --love.graphics.circle('line', ballPreview.position.x, ballPreview.position.y, ballPreview.radius - 0.99*WHITE_BALL_BORDER_WIDTH/2)
    end
    --love.graphics.reset()
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
    love.graphics.push()
    local color = ball.getColor()
    color[4] = ball.transparency 
    love.graphics.setColor(color)
    --love.graphics.rotate(rot)
    --love.graphics.scale(1+s, 1-s)
    love.graphics.circle(ball.inGame and 'fill' or 'line', ball.body:getX(), ball.body:getY(), ball.shape:getRadius())
    if ball.indestructible then
      --love.graphics.setColor(WHITE_BALL_BORDER_COLOR)
      --love.graphics.setLineWidth(WHITE_BALL_BORDER_WIDTH)
      --love.graphics.circle('line', ball.body:getX(), ball.body:getY(), ball.shape:getRadius() - 0.99*WHITE_BALL_BORDER_WIDTH/2)
    end
    love.graphics.pop()
    --love.graphics.reset()
    --DEBUGGER.line('ball: x='..ball.body:getX()..' y='..ball.body:getY()..'\n')
  end)

  -- UI
  love.graphics.setColor({0, 0, 0, 255})
  love.graphics.print(string.format('Score: %04d\n'..
      --'%04d(balls)+%04d(combo)\n'..
      'Last Combo: x%02d (%04d)\n',
      --tostring(scoreCombo + scoreBalls),
      --tostring(scoreBalls),
      tostring(scoreCombo),
      tostring(combo),
      tostring(ComboMultiplier(combo))),
    0, 10)

  love.graphics.print('Next Ball (Click to swap)', BASE_SCREEN_WIDTH - 180, 20)

  love.graphics.setColor(0, 0, 0)
  love.graphics.rectangle('fill', BASE_SCREEN_WIDTH
    - 100 - MAX_RADIUS*1.1, 20 + 20, 2*MAX_RADIUS*1.1, 2*MAX_RADIUS*1.1) 
  love.graphics.setColor(nextBallPreview.getColor())
  love.graphics.circle('fill', BASE_SCREEN_WIDTH
    - 100, 20 + 20 + MAX_RADIUS*1.1, nextBallPreview.radius)
  if nextBallPreview.indestructible then
    --love.graphics.setColor(WHITE_BALL_BORDER_COLOR)
    --love.graphics.setLineWidth(WHITE_BALL_BORDER_WIDTH)
    --love.graphics.circle('line', BASE_SCREEN_WIDTH
      --- 100, 20 + 20 + MAX_RADIUS*1.1, nextBallPreview.radius - 0.99*WHITE_BALL_BORDER_WIDTH/2)
  end
  --love.graphics.reset()

  game.UI.draw()

  if gameOver then
    love.graphics.setNewFont(22)
    love.graphics.setColor({200, 50, 0, 255})
    love.graphics.print(string.format('GAME OVER\n'..
      'Final Score: %04d\n',
      scoreCombo), BASE_SCREEN_WIDTH/2 - 100, BASE_SCREEN_HEIGHT/2 - 50)
  end

  -- debug
  DEBUGGER.draw()
end

local staticFrameCount = 0

function OnBallsStatic()
  local ballsTooHigh = false
  objects.balls:forEach(function(ball)
    if not ball.Ingame then return end
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
  local ballsCount = 0
  objects.balls:forEach(function(ball)
    local px, py = ball.body:getPosition() 
    if not IsInsideScreen(px, py) then
      objects.balls:SetToDelete(ball)
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

  if gameOver then
    return
  end

  if ballPreview then
    if love.keyboard.isDown('right') then --press the right arrow key to push the ball to the right
      ballPreview.position.x = ballPreview.position.x + PREVIEW_SPEED * dt
    elseif love.keyboard.isDown('left') then
      ballPreview.position.x = ballPreview.position.x - PREVIEW_SPEED * dt
    end
    ballPreview.position.x = utils.clamp(ballPreview.position.x, BORDER_THICKNESS + ballPreview.radius + 1, BASE_SCREEN_WIDTH - (BORDER_THICKNESS + ballPreview.radius) - 1)
  end

  lastTotalSpeed2 = totalSpeed2

  objects.balls:Clean()
  game.UI:Clean()
end

function ComboMultiplier(combo)
  if combo == 0 then return 0 end
  return math.pow(2, combo)
end

function GameOver()
  objects.balls:forEach(function(ball)
    if not ball.indestructible then return end
    DestroyBall(ball)
  end)
  gameOver = true
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
  objects.balls:add(newBall)

  ballPreview = nil
  --ballPreview = NewBallPreview(ballPreview.position.x)
  lastDroppedBall = newBall

  end

function SwitchBall()
  if not ballPreview then return end
  local aux = ballPreview
  ballPreview = nextBallPreview
  nextBallPreview = aux
end

function DestroyBall(ball)
  ball.inGame = true
  ball.transparency = BALL_DESTROY_TRANSPARENCY
  ball.fixture:setMask(COL_MAIN_CATEGORY)
end

function GetNextBall() 
  if not ballPreview then
    ballPreview = nextBallPreview 
    nextBallPreview = NewBallPreview() 
  end
end
-- INPUT
function love.keypressed(key)
  if not gameOver then
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
    objects.balls:Clear()
    gameOver = false
    ballPreview = NewBallPreview()
    nextBallPreview = NewBallPreview()
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
