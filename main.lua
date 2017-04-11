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
local PREVIEW_SPEED = 200
local PREVIEW_PADDING = 5
local MIN_SPEED2 = 50
local COL_MAIN_CATEGORY = 1

-- Helper functions
function GetRandomRadius()
  return math.floor(math.random() * 5 + 1) * 10
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
local score = 0
local combo = 0

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
  objects.ground.body = love.physics.newBody(world, SCREEN_WIDTH/2, SCREEN_HEIGHT-BORDER_THICKNESS/2)
  objects.ground.shape = love.physics.newRectangleShape(SCREEN_WIDTH, BORDER_THICKNESS)
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

  love.graphics.setColor(72, 160, 14)
  love.graphics.polygon("fill", objects.ground.body:getWorldPoints(objects.ground.shape:getPoints())) 
  love.graphics.polygon("fill", objects.wallL.body:getWorldPoints(objects.wallL.shape:getPoints()))
  love.graphics.polygon("fill", objects.wallR.body:getWorldPoints(objects.wallR.shape:getPoints()))

  local ballCount = 0
  objects.balls:forEach(function(ball) 
    ballCount = ballCount + 1
    love.graphics.setColor(ball.color)
    love.graphics.circle("fill", ball.body:getX(), ball.body:getY(), ball.shape:getRadius())
    text = text.."ball: x="..ball.body:getX().." y="..ball.body:getY().."\n"
  end)

  -- UI
  love.graphics.setColor({255, 255, 255, 255})
  love.graphics.print(string.format("Score: %06d", tostring(score)), 10, 10)
  if DEBUG then
    love.graphics.print(string.format("Balls: %06d", tostring(ballCount)), 10, 30)
    love.graphics.print(string.format("ballsRemoved: %06d", tostring(ballsRemoved)), 10, 40)
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
      ballPreview = NewBallPreview() 
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
  local ad = a:getUserData()
  local bd = b:getUserData()
  if not ad or not bd then return end
  if ad.color[1] == bd.color[1] and ad.color[2] == bd.color[2] and ad.color[3] == bd.color[3] then
    score = score + ad.radius + bd.radius
    a:setMask(COL_MAIN_CATEGORY)
    b:setMask(COL_MAIN_CATEGORY)
  end
end

function endContact(a, b, coll)
end
function preSolve(a, b, coll)
end
function postSolve(a, b, coll, normalimpulse, tangentimpulse)
end

function love.keypressed(key)
  if key == "space" and ballPreview then
    local newBall = {}
    newBall.color = ballPreview.color
    newBall.body = love.physics.newBody(world, ballPreview.position.x, ballPreview.position.y, "dynamic")
    --newBall.body:setFixedRotation(false)
    newBall.shape = love.physics.newCircleShape(ballPreview.radius)
    newBall.fixture = love.physics.newFixture(newBall.body, newBall.shape)
    newBall.fixture:setCategory(COL_MAIN_CATEGORY)
    newBall.fixture:setRestitution(0)
    newBall.fixture:setUserData({
        color = ballPreview.color,
        radius = ballPreview.radius,
      })
    objects.balls:add(newBall)
    
    ballPreview = NewBallPreview(ballPreview.position.x)
    --ballPreview = nil
  end 

  if key == "r" then
    objects.balls:forEach(function(ball)
      ball.fixture:destroy()
      ball.body:destroy()
    end)
    objects.balls = List.new()
    ballPreview = NewBallPreview(ballPreview.position.x)
  end

end
