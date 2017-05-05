local Scheduler = require 'scheduler'
local List = require 'doubly_linked_list'
local Queue = require 'queue'
local RandomBag = require 'randombag'

Game = {}
Game.UI = require 'ui'
Game.events = require 'events'

Game.objects = {}
Game.state = 0
Game.world = nil

Game.score = 0
Game.highScore = 0
Game.newHighScore = false
Game.combo = 0
Game.maxCombo = 0

Game.timeScale = 0.5
Game.startTime = love.timer.getTime()

-- Initialize game

-- TODO: move to ballpreview.lua
local ballChances = RandomBag.new(BALL_COLORS, BALL_CHANCE_MODIFIER)

local radiusChances = RandomBag.new(#BALL_RADIUS_MULTIPLIERS, BALL_CHANCE_MODIFIER)

function Game.load()
  Game.savePath = 'save.lua'
  if love.filesystem.exists(Game.savePath) then
    local loadChunk = love.filesystem.load(Game.savePath)
    loadChunk()
  end
end

function Game.save()
  local file, errorstr = love.filesystem.newFile(Game.savePath, 'w') 
  if errorstr then 
    return 
  end
  local savestring = [[
      Game.highScore = %d
      ]]
  savestring = savestring:format(Game.highScore)
  local s, err = file:write(savestring)

end

function Game.start()
  Game.state = STATE_GAME_LOADING

  -- Physics
  Game.world = love.physics.newWorld(0, GRAVITY, true)
  Game.world:setCallbacks(beginContact, endContact, preSolve, postSolve)

  -- Ball Previews
  Game.objects.ballPreview = NewBallPreview()

  Game.objects.nextBallPreviews = Queue.new()
  for _=1,NUM_BALL_PREVIEWS do
    Game.objects.nextBallPreviews:enqueue(NewBallPreview())
  end

  -- Game objects
  Game.objects.ground = {}
  Game.objects.ground.body = love.physics.newBody(Game.world, BASE_SCREEN_WIDTH/2, BASE_SCREEN_HEIGHT-BOTTOM_THICKNESS/2)
  Game.objects.ground.shape = love.physics.newRectangleShape(BASE_SCREEN_WIDTH, BOTTOM_THICKNESS)
  Game.objects.ground.fixture = love.physics.newFixture(Game.objects.ground.body, Game.objects.ground.shape)
  Game.objects.ground.fixture:setCategory(COL_MAIN_CATEGORY)

  Game.objects.wallL = {}
  Game.objects.wallL.body = love.physics.newBody(Game.world, BASE_SCREEN_WIDTH-BORDER_THICKNESS/2, BASE_SCREEN_HEIGHT/2)
  Game.objects.wallL.shape = love.physics.newRectangleShape(BORDER_THICKNESS, BASE_SCREEN_HEIGHT)
  Game.objects.wallL.fixture = love.physics.newFixture(Game.objects.wallL.body, Game.objects.wallL.shape)
  Game.objects.wallL.fixture:setCategory(COL_MAIN_CATEGORY)

  Game.objects.wallR = {}
  Game.objects.wallR.body = love.physics.newBody(Game.world, BORDER_THICKNESS/2, BASE_SCREEN_HEIGHT/2)
  Game.objects.wallR.shape = love.physics.newRectangleShape(BORDER_THICKNESS, BASE_SCREEN_HEIGHT)
  Game.objects.wallR.fixture = love.physics.newFixture(Game.objects.wallR.body, Game.objects.wallR.shape)
  Game.objects.wallR.fixture:setCategory(COL_MAIN_CATEGORY)

  Game.objects.balls = List.new(function(ball)
    if ball.fixture and not ball.fixture:isDestroyed() then ball.fixture:destroy() end
    if ball.body and not ball.body:isDestroyed() then ball.body:destroy() end
    ball = nil
  end)

  -- Events
  Game.events.clear()
  Game.events.add(EVENT_MOVED_PREVIEW, function(x, y, dx, dy)
    if Game.objects.ballPreview then
      Game.objects.ballPreview.drawStyle = 'line'
      Game.objects.ballPreview.position.x = utils.clamp(x, BORDER_THICKNESS + Game.objects.ballPreview.radius + 1, BASE_SCREEN_WIDTH - (BORDER_THICKNESS + Game.objects.ballPreview.radius) - 1)
    end
  end)

  Game.events.add(EVENT_RELEASED_PREVIEW, Game.ReleaseBall)
  Game.events.add(EVENT_ON_BALLS_STATIC, Game.onBallsStatic)
  Game.events.add(EVENT_SAFE_TO_DROP, Game.GetNextBall)
  Game.events.add(EVENT_BALLS_TOO_HIGH, Game.lose)

  -- Score
  Game.score = 0
  Game.combo = 0
  Game.maxCombo = 0
  Game.newHighScore = false

  -- Random bags
  ballChances = RandomBag.new(BALL_COLORS, BALL_CHANCE_MODIFIER)
  radiusChances = RandomBag.new(#BALL_RADIUS_MULTIPLIERS, BALL_CHANCE_MODIFIER)

  Game.state = STATE_GAME_RUNNING
end

Game.staticFrameCount = 0
Game.totalTime = 0
local accumulator = 0
function Game.update(dt)
  dt = dt * Game.timeScale
  Scheduler.update(dt)
  --print(' Game State: '.. Game.state)
  --print('STATE_GAME_RUNNING ='..STATE_GAME_RUNNING)
  --print('STATE_GAME_LOST ='..STATE_GAME_LOST)
  --print('STATE_GAME_OVER  = '..STATE_GAME_OVER)
  --print('STATE_GAME_PAUSED  = '..STATE_GAME_PAUSED)
  --print('STATE_GAME_LOADING = '..STATE_GAME_LOADING)
  --print('STATE_GAME_MAINMENU = '..STATE_GAME_MAINMENU)


  if not Game.inState(STATE_GAME_LOADING, STATE_GAME_MAINMENU, STATE_GAME_OVER) then
    --print('game is running')
    accumulator = accumulator + dt
    -- NOTE: this might break
    Game.totalTime = Game.totalTime + dt

    -- To prevent spiral of death
    if accumulator > MAX_DT_ACC then
      accumulator = 0
      return
    end

    while accumulator >= FIXED_DT do
      Game.world:update(FIXED_DT)
      totalSpeed2 = 0
      Game.objects.balls:forEach(function(ball)
        local px, py = ball.body:getPosition() 
        if not IsInsideScreen(px, py) then
          Game.objects.balls:SetToDelete(ball)
        end

        if ball.inGame then
          local x, y = ball.body:getLinearVelocity()
          totalSpeed2 = totalSpeed2 + x*x + y*y
        end
        -- TODO: create max radius variable
      end)

      -- TODO: Make this more robust
      if totalSpeed2 < MIN_SPEED2 then
        Game.staticFrameCount = Game.staticFrameCount + 1
        if Game.staticFrameCount == FRAMES_TO_STATIC then
          Game.events.fire(EVENT_ON_BALLS_STATIC)
        end
      else
        Game.staticFrameCount = 0
      end


      if Game.lastDroppedBall then
        if Game.lastDroppedBall.body:getY() > MIN_DISTANCE_TO_TOP + Game.lastDroppedBall.radius or Game.lastDroppedBall.destroyed then
          Game.events.fire(EVENT_SAFE_TO_DROP)
          Game.lastDroppedBall = nil
        end
      end

      lastTotalSpeed2 = totalSpeed2

      Game.objects.balls:Clean()

      accumulator = accumulator - FIXED_DT
    end
  end
end

function Game.inState(...)
  local gameStates = {...}
  for _, gameState in pairs(gameStates) do
    if gameState ~= 1 and gameState % 2 ~= 0 then
      print('STATE ERROR: comparing against invalid state')
    end

    if Game.state == gameState then
      return true
    end
  end
  return false
end

function Game.onBallsStatic()
  local ballsTooHigh = false
  Game.objects.balls:forEach(function(ball)
    if not ball.inGame then return end
    if ball.body:getY() < MIN_DISTANCE_TO_TOP + ball.radius then
      ballsTooHigh = true
    end
  end)
  if ballsTooHigh then
    Game.events.fire(EVENT_BALLS_TOO_HIGH)
  end
  lastHit = hit
  hit = false
  if Game.combo > Game.maxCombo then Game.maxCombo = Game.combo end
  Game.combo = 0

end

function Game.lose()
  Game.timeScale = 2
  Game.objects.balls:forEach(function(ball)
  if not ball.indestructible then return end
    Game.ScheduleBallDestruction(ball)
  end)
  Game.state = STATE_GAME_LOST
  Game.events.add(EVENT_ON_BALLS_STATIC, Game.gameOver)
end


function Game.gameOver()
  Game.setHighScore(Game.score)
  Game.objects.balls:forEach(Game.DestroyBall)
  Game.state = STATE_GAME_OVER
end

function Game.setHighScore(score)
  if score > Game.highScore then
    Game.highScore = score
    Game.save()
    Game.newHighScore = true
  end
end

local lastBallNumber
-- TODO: remove from game
-- move to ballpreview file
function Game.GetBallNumber() 
  while true do
    local ballNumber = ballChances:get()
    if ballNumber ~= lastBallNumber then
      --lastBallNumber = ballNumber
      ballChances:update(ballNumber)
      return ballNumber
    end
  end
end

function Game.GetBallRadius()
  local radiusNumber = radiusChances:get()
  radiusChances:update(radiusNumber)
  return BALL_BASE_RADIUS * BALL_RADIUS_MULTIPLIERS[radiusNumber]
end

function Game.ReleaseBall()
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
  Game.lastDroppedBall = newBall
end

function Game.GetNextBall() 
  if not Game.objects.ballPreview then
    Game.objects.ballPreview = Game.objects.nextBallPreviews:dequeue()
    local hasWhiteBalls = false
    Game.objects.nextBallPreviews:forEach(function(ball)
      if ball.indestructible then
        hasWhiteBalls = true
      end
    end)
    if hasWhiteBalls then 
      Game.objects.nextBallPreviews:enqueue(NewBallPreview())
    else
      Game.objects.nextBallPreviews:enqueue(NewBallPreview({indestructible = true}))
    end
  end
end

function Game.ScheduleBallDestruction(ball)
  ball.inGame = false
  ball.timeDestroyed = Game.totalTime
  print('Schedule Time:'..(ball.timeDestroyed))
  Scheduler.add(function()
    Game.DestroyBall(ball)
    print('Ball destroyed at: '..Game.totalTime)
  end, BALL_TIME_TO_DESTROY)
end

function Game.DestroyBall(ball)
  if not ball then return end
  Game.objects.balls:SetToDelete(ball)
  if ball.fixture and not ball.fixture:isDestroyed() then
    ball.fixture:setMask(COL_MAIN_CATEGORY)
  end
  if ball.body and not ball.body:isDestroyed() then
    ball.body:setActive(false)
  end
  ball.destroyed = true
end
return Game

