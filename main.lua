local DEBUG = false

-- Library functions

local List = {}

function List.new()
  local l = {list=nil}
  setmetatable(l, {__index=List})
  return l
end

function List:add(elem)
  local new = {next=self.list, prev=nil, val=elem}
  new.val.ref = new
  if self.list then
    self.list.prev = new
  end
  self.list = new
end

function List:forEach(func) 
  local l = self.list
  while l do
    func(l.val)
    l = l.next
  end
end

function List:SetToDelete(elem)
  if not self.toDelete then
    self.toDelete = List.new()
  end
  self.toDelete:add(elem.ref)
end

function List:Clean(free)
  if not self.toDelete then
    return
  end
  local free = free or function () end
  self.toDelete:forEach(function(del)
    if del == self.list then
      self.list = del.next
    end
    if del.next then
      del.next.prev = del.prev
    end
    if del.prev then
      del.prev.next = del.next
    end

    free(del.val)
    del = nil
  end)
  self.toDelete = nil
end


Vector = {}
Vector.mt = {}

function Vector.new(params)
  local v = {}
  v.x = params.x
  v.y = params.y
  setmetatable(v, Vector.mt)
  return v
end

function Vector.add(a, b)
  return Vector.new{x=(a.x + b.x), y=(a.y + b.y)}
end

function Vector.subtract(a, b)
  return Vector.new{x=(a.x - b.x), y=(a.y - b.y)}
end

function Vector.negate(a)
  return Vector.new{x=-a.x, y=-a.y}
end

function Vector.multiply(v, c)
  return Vector.new{x=v.x*c, y=v.y*c}
end

Vector.mt.__add = Vector.add
Vector.mt.__sub = Vector.subtract
Vector.mt.__unm = Vector.negate
Vector.mt.__mul = Vector.multiply

-- Constants
local METER = 64
local SCREEN_WIDTH = 640
local SCREEN_HEIGHT = 960
local BORDER_THICKNESS = 200
local BOTTOM_THICKNESS = 50
local PREVIEW_SPEED = 200
local PREVIEW_PADDING = 5
local MIN_SPEED2 = 50
local COL_MAIN_CATEGORY = 1
local BASE_RADIUS = 25
local RADIUS_MULTIPLIERS = {1, 1.69, 2.23}

-- Helper functions
function GetRandomRadius()
  return BASE_RADIUS * RADIUS_MULTIPLIERS[math.random(#RADIUS_MULTIPLIERS)]
end

function GetRandomColor()
  local r = 255 / math.floor(math.random() * 2 + 1)
  local g = 255 / math.floor(math.random() * 2 + 1)
  local b = 255 / math.floor(math.random() * 2 + 1)
  return {r, g, b, 255}
end

function NewBallPreview(initialX)
  local radius = GetRandomRadius()
  local color = GetRandomColor()
  local position = Vector.new{x=initialX or SCREEN_WIDTH/2, y=radius/2 + PREVIEW_PADDING}
  return {
    position = position,
    radius = radius,
    color = color,
  }
end

function Clamp(val, min, max)
  if val > max then 
    return max
  elseif val < min then
    return min
  else
    return val
  end
end

function IsInsideRect(x, y, x0, y0, x1, y1)
  return x >= x0 and x <= x1 and y >= y0 and y <= y1
end

function IsInsideScreen(x, y)
  return IsInsideRect(x, y, 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
end

-- Variables
local objects = {}
local world = nil
local ballPreview = NewBallPreview()
local nextBallPreview = NewBallPreview()
local scoreCombo = 0
local scoreBalls = 0
local combo = 1

local hit = false
local lastHit = false

local ballsRemoved = 0
local text = ""
local totalSpeed2 = 0
local lastTotalSpeed2 = -1
local time = 0

-- DEBUG STUFF

-- Behaviour definitions
function love.load()
  love.physics.setMeter(METER)
  world = love.physics.newWorld(0, 9.81*METER, true)
  world:setCallbacks(beginContact, endContact, preSolve, postSolve)

  objects.ground = {}
  objects.ground.body = love.physics.newBody(world, SCREEN_WIDTH/2, SCREEN_HEIGHT-BOTTOM_THICKNESS/2)
  objects.ground.shape = love.physics.newRectangleShape(SCREEN_WIDTH, BOTTOM_THICKNESS)
  objects.ground.fixture = love.physics.newFixture(objects.ground.body, objects.ground.shape)
  objects.ground.fixture:setFriction(1)
  objects.ground.fixture:setCategory(COL_MAIN_CATEGORY)

  objects.wallL = {}
  objects.wallL.body = love.physics.newBody(world, SCREEN_WIDTH-BORDER_THICKNESS/2, SCREEN_HEIGHT/2)
  objects.wallL.shape = love.physics.newRectangleShape(BORDER_THICKNESS, SCREEN_HEIGHT)
  objects.wallL.fixture = love.physics.newFixture(objects.wallL.body, objects.wallL.shape)
  objects.wallL.fixture:setCategory(COL_MAIN_CATEGORY)

  objects.wallR = {}
  objects.wallR.body = love.physics.newBody(world, BORDER_THICKNESS/2, SCREEN_HEIGHT/2)
  objects.wallR.shape = love.physics.newRectangleShape(BORDER_THICKNESS, SCREEN_HEIGHT)
  objects.wallR.fixture = love.physics.newFixture(objects.wallR.body, objects.wallR.shape)
  objects.wallR.fixture:setCategory(COL_MAIN_CATEGORY)


  objects.balls = List.new()
  love.window.setMode(SCREEN_WIDTH, SCREEN_HEIGHT)
end

function love.draw() 
  if ballPreview then
    love.graphics.setColor(ballPreview.color)
    love.graphics.circle("line", ballPreview.position.x, ballPreview.position.y, ballPreview.radius)
  end

  love.graphics.setColor(255, 255, 255)
  love.graphics.polygon("fill", objects.ground.body:getWorldPoints(objects.ground.shape:getPoints())) 
  love.graphics.polygon("fill", objects.wallL.body:getWorldPoints(objects.wallL.shape:getPoints()))
  love.graphics.polygon("fill", objects.wallR.body:getWorldPoints(objects.wallR.shape:getPoints()))

  local ballCount = 0
  local BALL_SPEED_STRETCH = 0.2
  objects.balls:forEach(function(ball) 
    ballCount = ballCount + 1
    local vx, vy = ball.body:getLinearVelocity()
    local s = BALL_SPEED_STRETCH * math.sqrt(vx * vx + vy * vy)
    local rot = math.atan2(vy, vx)
    love.graphics.setColor(ball.color)
    love.graphics.push()

    --love.graphics.rotate(rot)
    --love.graphics.scale(1+s, 1-s)
    love.graphics.circle("fill", ball.body:getX(), ball.body:getY(), ball.shape:getRadius())
    love.graphics.pop()
    text = text.."ball: x="..ball.body:getX().." y="..ball.body:getY().."\n"
  end)

  -- UI
  love.graphics.setColor({0, 0, 0, 255})
  love.graphics.print(string.format([[
      Score: %04d
      %04d(balls)+%04d(combo)
      Combo: x%02d]],
      tostring(scoreCombo + scoreBalls),
      tostring(scoreBalls),
      tostring(scoreCombo),
      tostring(combo)),
      0, 10)
  
  love.graphics.print("Next Ball", SCREEN_WIDTH - 150, 20)

  local containerSize = BASE_RADIUS * RADIUS_MULTIPLIERS[#RADIUS_MULTIPLIERS] * 1.1
  love.graphics.setColor(0, 0, 0)
  love.graphics.rectangle("fill", SCREEN_WIDTH - 100 - containerSize, 20 + 20, 2*containerSize, 2*containerSize) 
  love.graphics.setColor(nextBallPreview.color)
  love.graphics.circle("fill", SCREEN_WIDTH - 100, 20 + 20 + containerSize, nextBallPreview.radius)

  -- debug
  if DEBUG then
    love.graphics.setColor({255, 0, 255, 255})
    love.graphics.print(string.format("Balls: %06d", tostring(ballCount)), 10, 50)
    love.graphics.print(string.format("ballsRemoved: %06d", tostring(ballsRemoved)), 10, 60)
    love.graphics.print(text, 10, 50)
  end
end

function love.update(dt)
  world:update(dt)
  text = ""

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
    if love.keyboard.isDown("right") then --press the right arrow key to push the ball to the right
      ballPreview.position.x = ballPreview.position.x + PREVIEW_SPEED * dt
    elseif love.keyboard.isDown("left") then
      ballPreview.position.x = ballPreview.position.x - PREVIEW_SPEED * dt
    end
    ballPreview.position.x = Clamp(ballPreview.position.x, BORDER_THICKNESS + ballPreview.radius, SCREEN_WIDTH - (BORDER_THICKNESS + ballPreview.radius))
  end

  lastTotalSpeed2 = totalSpeed2

  objects.balls:Clean(function(ball)
    --ball.body:destroy()
    --ball = nil
  end)
end

function beginContact(a, b, coll)
  local aref = a:getUserData() and a:getUserData().ref
  local bref = b:getUserData() and b:getUserData().ref
  if not aref or not bref then return end
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

-- INPUT
local INPUT_SAVE_BALL = "c"
function love.keypressed(key)
  if key == "space" and ballPreview then
    local newBall = {}
    newBall.radius = ballPreview.radius
    newBall.color = ballPreview.color
    newBall.body = love.physics.newBody(world, ballPreview.position.x, ballPreview.position.y, "dynamic")
    --newBall.body:setFixedRotation(false)
    newBall.shape = love.physics.newCircleShape(ballPreview.radius)
    newBall.fixture = love.physics.newFixture(newBall.body, newBall.shape)
    newBall.fixture:setCategory(COL_MAIN_CATEGORY)
    newBall.fixture:setRestitution(0)
    newBall.fixture:setUserData({
        ref = newBall,
      })
    objects.balls:add(newBall)
    
    --ballPreview = NewBallPreview(ballPreview.position.x)
    ballPreview = nil

  end 

  if key == INPUT_SAVE_BALL then
    local aux = ballPreview
    ballPreview = nextBallPreview
    nextBallPreview = aux
  end

  if key == "r" then
    objects.balls:forEach(function(ball)
      ball.fixture:destroy()
      ball.body:destroy()
    end)
    objects.balls = List.new()
    ballPreview = NewBallPreview()
  end

end
