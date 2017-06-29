local Vector = require 'lib/vector2d'
local List = require 'lib/doubly_linked_list'
local ParticleSystem = require 'lib/particle_system'
local ParticleSystemUtils = require 'lib/particle_system_utils'
local UI = require 'ui'
require 'data_constants'

local Balls = {}
local Ball = {}

function Balls.NewBallPreview(initialData)
  initialData = initialData or {}

  local radius = initialData.indestructible and WHITE_BALL_SIZE or Game.GetBallRadius()
  return {
    number = initialData.number or Game.GetBallNumber(), --TODO: make white ball have a number
    position = initialData.position or  Vector.New(BASE_SCREEN_WIDTH/2, radius + PREVIEW_PADDING),
    radius = initialData.radius or radius,
    indestructible = initialData.indestructible or false,
    getColor = Ball.getColor
  }
end

function Balls.NewList()
  return List.New(function(ball)
    if ball.fixture and not ball.fixture:isDestroyed() then ball.fixture:destroy() end
    if ball.body and not ball.body:isDestroyed() then ball.body:destroy() end
    ball = nil
  end)
end


function Ball.New(ballData, world)
  local newBall = ballData
  setmetatable(newBall, {__index = Ball})

  newBall._inGame = false
  -- Change toggle to enter exit?
  newBall._enterGameCoroutine = coroutine.create(function() 
    if not newBall._inGame then
      newBall._inGame = true
      newBall:enterGameCallback()
      coroutine.yield()
    end
  end)
  newBall._exitGameCoroutine = coroutine.create(function()
    if newBall._inGame then
      newBall._inGame = false
      coroutine.yield()
    end
  end)

  newBall.enterGame = function(self)
    coroutine.resume(self._enterGameCoroutine)
  end

  newBall.exitGame = function(self)
    coroutine.resume(self._exitGameCoroutine)
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

  newBall.startDeathParticleSystem = function()
    local ballPos = newBall:getPosition()
    ParticleSystem.New{
      duration = BALL_TIME_TO_DESTROY,
      particleLifeTime = BALL_TIME_TO_DESTROY/4,
      getInitialPosition = function(time) 
        local p0 = ballPos
        return p0 + ParticleSystemUtils.RandomRadialUnitVector() * newBall.radius
      end,
      getInitialVelocity = function(position, time)
        --return ParticleSystemUtils.RandomRadialUnitVector() * 180
        return (position - ballPos):normalized() * 150
      end,
      colorOverLifeTime = ParticleSystemUtils.RGBGradient(UI.GetColor(newBall:getColor()), {0, 0, 0, 0}),
      scaleOverLifeTime = function(k) 
        return 4 * (1-k) * (k)
      end,
      particleDraw = ParticleSystemUtils.SquareParticlesDraw(15 * newBall.radius/BALL_MAX_RADIUS),
      rateOverTime = 50
    }
  end

  return newBall
end

function Ball:getPosition()
  return Vector.New(self.body:getX(), self.body:getY())
end

function Ball:getColor()
  return (self.indestructible and 1 or self.number + 2)
end

Balls.NewBall = Ball.New

return Balls
