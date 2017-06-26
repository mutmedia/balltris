local Vector = require 'lib/vector2d'
local List = require 'lib/doubly_linked_list'
local Balls = {}

function Balls.NewBallPreview(initialData)
  initialData = initialData or {}

  local radius = initialData.indestructible and WHITE_BALL_SIZE or Game.GetBallRadius()
  return {
    number = initialData.number or Game.GetBallNumber(), --TODO: make white ball have a number
    position = initialData.position or  Vector.new{x=BASE_SCREEN_WIDTH/2, y=radius + PREVIEW_PADDING},
    radius = initialData.radius or radius,
    indestructible = initialData.indestructible or false,
  }
end

function Balls.NewList()
  return List.new(function(ball)
    if ball.fixture and not ball.fixture:isDestroyed() then ball.fixture:destroy() end
    if ball.body and not ball.body:isDestroyed() then ball.body:destroy() end
    ball = nil
  end)
end

local Ball = {}

function Ball.new(ballData, world)
  local newBall = ballData

  newBall._inGame = false
  -- Change toggle to enter exit?
  newBall._toggleInGameCoroutine = coroutine.create(function()
    if not newBall._inGame then
      newBall._inGame = true
      newBall:enterGameCallback()
      coroutine.yield()
    end

    if newBall._inGame then
      newBall._inGame = false
      coroutine.yield()
    end
  end)

  newBall.toggleInGame = function(self)
    coroutine.resume(self._toggleInGameCoroutine)
  end

  newBall.isInGame = function(self)
    return self._inGame
  end

  newBall.body = love.physics.newBody(world, ballData.position.x, ballData.position.y, 'dynamic')
  newBall.body:setFixedRotation(false)
  newBall.shape = love.physics.newCircleShape(ballData.radius)
  newBall.fixture = love.physics.newFixture(newBall.body, newBall.shape)
  newBall.fixture:setCategory(COL_MAIN_CATEGORY)
  --newBall.fixture:setFriction(0.0)
  newBall.fixture:setRestitution(0.0)
  newBall.fixture:setUserData({
      ref = newBall,
    })

  setmetatable(newBall, {__index = Ball})
  return newBall
end
Balls.newBall = Ball.new

return Balls
