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
    local particleColor = UI.GetColor(newBall:getColor())
    -- TODO:
    -- could make this with HSL
    particleColor[1] = particleColor[1] * 2.0
    particleColor[2] = particleColor[2] * 2.0
    particleColor[3] = particleColor[3] * 2.0
    particleColor[4] = particleColor[4] * 2.0
    local getBallPosition = function()
      if newBall and newBall.body and not newBall.body:isDestroyed() then
        ballPos = newBall:getPosition()
      end
      return ballPos
    end
    ParticleSystem.New{
      duration = BALL_TIME_TO_DESTROY,
      particleLifeTime = BALL_TIME_TO_DESTROY/4,
      getInitialPosition = function(time) 
        local p0 = getBallPosition()
        return p0 + ParticleSystemUtils.RandomRadialUnitVector() * newBall.radius * 0.95
      end,
      getInitialVelocity = function(position, time)
        --return ParticleSystemUtils.RandomRadialUnitVector() * 180
        return (position - getBallPosition()):normalized() * 100
      end,
      colorOverLifeTime = ParticleSystemUtils.MultiRGBGradient(
        3,
        {
          --{1, 0, 0, 1},
          --{0, 1, 0, 1},
          {0, 0, 0, 0},
          particleColor,
          {0, 0, 0, 0},
        }),
      scaleOverLifeTime = function(k) 
        return 4 * (1-k) * (k)
      end,
      particleDraw = ParticleSystemUtils.SquareParticlesDraw(20 * newBall.radius/BALL_MAX_RADIUS),
      rateOverTime = 40,
      drawCondition=function()
        return Game.inState(STATE_GAME_RUNNING, STATE_GAME_LOST, STATE_GAME_OVER)
      end
    }
  end

newBall.startSpawnParticleSystem = function()

        -- TODO:
    -- could make this with HSL
    local particleColor = UI.GetColor(newBall:getColor())
    particleColor[1] = particleColor[1] * 2.0
    particleColor[2] = particleColor[2] * 2.0
    particleColor[3] = particleColor[3] * 2.0
    particleColor[4] = particleColor[4] * 2.0

    local ballPos = newBall:getPosition()
    local getBallPosition = function()
      if newBall and newBall.body and not newBall.body:isDestroyed() then
        ballPos = newBall:getPosition()
      end
      return ballPos
    end

    --[[
    local ballVel = Vector.New()
    ballVel.x, ballVel.y = newBall.body:getLinearVelocity()
    local getBallVelocity = function()
      if newBall and newBall.body and not newBall.body:isDestroyed() then
        ballVel.x, ballVel.y = newBall.body:getLinearVelocity()
      end
      return ballVel
    end
    ]]--

    ParticleSystem.New{
      duration = BALL_TIME_TO_DESTROY/2,
      particleLifeTime = BALL_TIME_TO_DESTROY/4,
      getInitialPosition = function(time) 
        local p0 = getBallPosition()
        return p0 + ParticleSystemUtils.RandomRadialUnitVector() * newBall.radius * 0.95
      end,
      getInitialVelocity = function(position, time)
        local v =  (position - getBallPosition()):normalized() * 100
        return v --+ getBallVelocity()
      end,
      colorOverLifeTime = ParticleSystemUtils.MultiRGBGradient(
        3,
        {
          --{1, 0, 0, 1},
          --{0, 1, 0, 1},
          {0, 0, 0, 0},
          particleColor,
          {0, 0, 0, 0},
        }),
      scaleOverLifeTime = function(k) 
        return 4 * (1-k) * (k)
      end,
      particleDraw = ParticleSystemUtils.SquareParticlesDraw(20 * newBall.radius/BALL_MAX_RADIUS),
      rateOverTime = 240,
      particleAcceleration = Vector.New(0, GRAVITY),
      drawCondition=function()
        return Game.inState(STATE_GAME_RUNNING, STATE_GAME_LOST, STATE_GAME_OVER)
      end
    }
  end


  newBall.startSpawnParticleSystem2 = function()
    local ballRadius = newBall.radius
    local particleLife = BALL_TIME_TO_DESTROY/4
    ParticleSystem.New{
      duration = BALL_TIME_TO_DESTROY/3,
      particleLifeTime = particleLife,
      getInitialPosition = function(time) 
        local p0 = newBall:getPosition()
        local v = ParticleSystemUtils.RandomRadialUnitVector() * ballRadius 

        return Vector.New(BASE_SCREEN_WIDTH/2 + math.sign(v.x) * HOLE_WIDTH/2, p0.y + v.y)
      end,
      getInitialVelocity = function(position, time)
        --return particlesystemutils.randomradialunitvector() * 180
        local v = vector.new()
        _, v.y = newball.body:getlinearvelocity()
        local dist = position.x - newball:getposition().x

        v.x = -math.sign(dist) * (math.abs(dist) - ballradius)/particlelife
        return v
      end,
      colorOverLifeTime = ParticleSystemUtils.RGBGradient({0, 0, 0, 0}, UI.GetColor(newBall:getColor())),
      scaleOverLifeTime = function(k) 
        return k
      end,
      particleDraw = ParticleSystemUtils.SquareParticlesDraw(25 * newBall.radius/BALL_MAX_RADIUS),
      rateOverTime = 700,
      particleAcceleration = Vector.New(0, GRAVITY)
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
