local Scheduler = require 'lib/scheduler'
local List = require 'lib/doubly_linked_list'
local Queue = require 'lib/queue'
local Stack = require 'lib/stack'
local RandomBag = require 'lib/randombag'
local Vector = require 'lib/vector2d'
local TempSave = require 'tempsave'
local LocalSave = require 'localsave'

local Balls = require 'balls'

local Backend = require 'backend'

Game = {}
Game.UI = require 'ui'
Game.events = require 'lib/events'
Game.tutorial = {}

Game.objects = {}
Game.isOffline = true
Game.state = 0
Game.world = nil

Game.score = 0
Game.highScore = 0
Game.newHighScore = false
Game.combo = 0
Game.maxCombo = 0
Game.comboObjective = 5
Game.comboObjectiveCleared = false
Game.comboNumbers = nil

Game.timeScale = TIME_SCALE_SLOMO
Game.startTime = love.timer.getTime()

Game.usernameText = 'name'

-- Initialize game

-- TODO: move to ballpreview.lua
Game.ballChances = RandomBag.New(BALL_COLORS, BALL_CHANCE_MODIFIER)
Game.radiusChances = RandomBag.New(#BALL_RADIUS_MULTIPLIERS, BALL_CHANCE_MODIFIER)
Game.tutorial = {}

function Game.start(loadGame)
  Game.totalTime = 0
  Game.state = STATE_GAME_LOADING

  -- Physics
  Game.world = love.physics.newWorld(0, GRAVITY, true)
  Game.world:setCallbacks(beginContact, endContact, preSolve, postSolve)

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
  Game.objects.wallL.fixture:setUserData({
      ref = {
        isWall = true
      }
    })

  Game.objects.wallR = {}
  Game.objects.wallR.body = love.physics.newBody(Game.world, BORDER_THICKNESS/2, BASE_SCREEN_HEIGHT/2)
  Game.objects.wallR.shape = love.physics.newRectangleShape(BORDER_THICKNESS, BASE_SCREEN_HEIGHT)
  Game.objects.wallR.fixture = love.physics.newFixture(Game.objects.wallR.body, Game.objects.wallR.shape)
  Game.objects.wallR.fixture:setCategory(COL_MAIN_CATEGORY)
  Game.objects.wallR.fixture:setUserData({
      ref = {
        isWall = true
      }
    })

  -- TODO: save this later
  Game.comboObjective = 5
  -- Information that can be saved
  if loadGame then
    Game = loadGame(Game)
  else
    Game.objects.ballPreview = Balls.NewBallPreview()

    Game.objects.nextBallPreviews = Queue.New()
    for _=1,NUM_BALL_PREVIEWS do
      Game.objects.nextBallPreviews:enqueue(Balls.NewBallPreview())
    end

    --Loaded Balls
    Game.objects.balls = Balls.NewList()

    -- Random bags
    Game.ballChances = RandomBag.New(BALL_COLORS, BALL_CHANCE_MODIFIER)
    Game.radiusChances = RandomBag.New(#BALL_RADIUS_MULTIPLIERS, BALL_CHANCE_MODIFIER)

    -- Score
    Game.score = 0
    Game.maxCombo = 0

    -- These two are not saved, since the second is calculated real time, and the first I will assume the game only saves when not in a combo
    Game.combo = 0
    Game.newHighScore = false

  end
  Game.totalSpeedQueue = Queue.New()
  Game.meanSpeed = 0
  Game.lastMeanSpeed = 0
  Game.timeSinceLastCombo = 0
  Game.comboTimeLeft = 0
  Game.comboNumbers = Queue.New()
  --
  -- End of information that can be saved

  -- Events
  Game.events.clear()
  Game.events.add(EVENT_MOVED_PREVIEW, function(x, y, dx, dy)
    if Game.objects.ballPreview then
      Game.objects.ballPreview.drawStyle = 'line'
      Game.objects.ballPreview.position.x = math.clamp(x, BORDER_THICKNESS + Game.objects.ballPreview.radius + 1, BASE_SCREEN_WIDTH - (BORDER_THICKNESS + Game.objects.ballPreview.radius) - 1)
      Game.timeScale = Game.options.slomoType == OPTIONS_SLOMO_REVERSE and TIME_SCALE_REGULAR or TIME_SCALE_SLOMO
    elseif Game.options.slomoType == OPTIONS_SLOMO_DEFAULT then
      Game.events.schedule(EVENT_SAFE_TO_DROP, function()
        -- HACK: didnt want to implement proper UI hold just for this
        -- TODO: implement ui.hold
        if Game.state == STATE_GAME_RUNNING and love.mouse.isDown(1) then
          Game.timeScale = TIME_SCALE_SLOMO
        end
      end)
    end
  end)

  Game.events.add(EVENT_RELEASED_PREVIEW, function()
    Game.ReleaseBall()
    Game.timeScale = TIME_SCALE_REGULAR
    if Game.options.slomoType == OPTIONS_SLOMO_REVERSE then
      Game.events.schedule(EVENT_SAFE_TO_DROP, function()
        if Game.state == STATE_GAME_RUNNING and not love.mouse.isDown(1) then
          Game.timeScale = TIME_SCALE_SLOMO
        end
      end)
    end
    if Game.options.slomoType == OPTIONS_SLOMO_ALWAYSON then
      Game.events.schedule(EVENT_SAFE_TO_DROP, function()
        if Game.state == STATE_GAME_RUNNING then
          Game.timeScale = TIME_SCALE_SLOMO
        end
      end)
    end

  end)
  Game.events.add(EVENT_ON_BALLS_STATIC,  function()
    Game.events.schedule(EVENT_NEW_BALL, function()
      TempSave.Save(Game)
    end)
    Game.validateHeight()
    if Game.combo > 0 then
      --Game.events.fire(EVENT_COMBO_END)
    end
  end)
  Game.events.add(EVENT_COMBO_TIMEOUT, function()
    Game.events.schedule(EVENT_NEW_BALL, function()
      TempSave.Save(Game)
    end)
    if Game.combo > 0 then
      Game.events.fire(EVENT_COMBO_END)
    end
    --Game.validateHeight()
  end)
  Game.events.add(EVENT_SAFE_TO_DROP, function()
    Game.IncrementComboTimeout(COMBO_INCREMENT_DROP)
    Game.GetNextBall()
  end)
  Game.events.add(EVENT_NEW_BALL_INGAME, function()
    --Game.IncrementComboTimeout()
  end)
  Game.events.add(EVENT_BALLS_TOO_HIGH, Game.lose)
  Game.events.add(EVENT_SCORED, function() 
    Game.timeSinceLastCombo = 0
    if Game.combo >= Game.comboObjective and not Game.comboObjectiveCleared and not Game.inState(STATE_GAME_LOST, STATE_GAME_OVER) then
      Game.events.fire(EVENT_COMBO_CLEARED)
    end
  end)
  Game.events.add(EVENT_COMBO_CLEARED, function()
    Game.clearWhiteBalls()
    Game.comboObjectiveCleared = true
  end)
  Game.events.add(EVENT_COMBO_END, function()
    if Game.combo <= 0 then print('CALLING COMBO END EVENT IN A WEIRD CIRUCUNSTANCE') end
    if Game.combo > Game.maxCombo then Game.maxCombo = Game.combo end
    if Game.combo >= Game.comboObjective then
      Game.comboObjectiveCleared = false
      Game.comboObjective = Game.comboObjective + 5
      Game.events.fire(EVENT_COMBO_NEW_CLEARSAT)
    end
    Game.comboNumbers = Queue.New()
    -- Reset on next frame
    Scheduler.add(function() Game.combo = 0 end, 0)
  end)

  Game.state = STATE_GAME_RUNNING
  if not Game.options.ignoreTutorial then
    Game.InitializeTutorial()
  end
end

Game.staticFrameCount = 0
Game.timeSinceLastCombo = 0
Game.comboTimeLeft = 0
Game.totalTime = 0
Game.totalTimeUnscaled = 0

Game.raycastHit = nil

local accumulator = 0
gf = 0
pf = 0
function Game.update(dt)

  Game.totalTimeUnscaled = Game.totalTimeUnscaled + dt
  dt = dt * Game.timeScale
  Scheduler.update(dt)
  --print(' Game State: '.. Game.state)
  --print('STATE_GAME_RUNNING ='..STATE_GAME_RUNNING)
  --print('STATE_GAME_LOST ='..STATE_GAME_LOST)
  --print('STATE_GAME_OVER  = '..STATE_GAME_OVER)
  --print('STATE_GAME_PAUSED  = '..STATE_GAME_PAUSED)
  --print('STATE_GAME_LOADING = '..STATE_GAME_LOADING)
  --print('STATE_GAME_MAINMENU = '..STATE_GAME_MAINMENU)

  Game.raycastHit = nil
  --Raycast to get preview
  if Game.objects.ballPreview then
    function previewRaycastCallback(fixture, x, y, xn, yn, fraction)
      --ballref = fixture:getUserData() and fixture:getUserData().ref
      --if not ballref then return end
      --print('Ray cast hit something')
      if not Game.raycastHit or y < Game.raycastHit.y then
        Game.raycastHit = Vector.New(x, y)
      end
      return 1
    end

    Game.world:rayCast(Game.objects.ballPreview.position.x,
      Game.objects.ballPreview.position.y,
      Game.objects.ballPreview.position.x,
      Game.objects.ballPreview.position.y + BASE_SCREEN_HEIGHT,
      previewRaycastCallback)
  end


  -- NOTE: this might break
  Game.totalTime = Game.totalTime + dt
  --print('game.state = '..Game.state..' tutorial.state = '..Game.tutorial.state)
  if Game.inState(STATE_GAME_RUNNING, STATE_GAME_LOST, STATE_GAME_PAUSED) and not Game.tutorial.state:peek() then
    -- To prevent spiral of death
    accumulator = accumulator + dt
    if accumulator > MAX_DT_ACC then
      accumulator = 0
      return
    end



    while accumulator >= FIXED_DT do
      Game.world:update(FIXED_DT)
      ParticleSystem.Update(FIXED_DT)
      totalSpeed = 0
      Game.objects.balls:forEach(function(ball)
        local px, py = ball.body:getPosition() 
        if not IsInsideScreen(px, py) then
          Game.objects.balls:SetToDelete(ball)
        end

        if ball:isInGame() then
          local x, y = ball.body:getLinearVelocity()
          totalSpeed = totalSpeed + math.sqrt(x*x + y*y)
        end
      end)
      Game.totalSpeedQueue:enqueue({speed = totalSpeed})
      if Game.totalSpeedQueue.size > FRAMES_TO_STATIC then
        Game.totalSpeedQueue:dequeue()
      end

      Game.meanSpeed = 0
      Game.totalSpeedQueue:forEach(function(q)
        Game.meanSpeed = Game.meanSpeed + q.speed
      end)

      --print('meanspeed' , Game.meanSpeed)
      Game.meanSpeed = Game.meanSpeed/FRAMES_TO_STATIC
      -- TODO: Make this more robust
      if Game.meanSpeed < MIN_SPEED and Game.lastMeanSpeed >= MIN_SPEED then
        Game.events.fire(EVENT_ON_BALLS_STATIC)
      end

      Game.lastMeanSpeed = Game.meanSpeed

      if Game.lastDroppedBall then
        if Game.lastDroppedBall.body:getY() > MIN_DISTANCE_TO_TOP + Game.lastDroppedBall.radius or Game.lastDroppedBall.destroyed then
          Game.events.fire(EVENT_SAFE_TO_DROP)
          Game.lastDroppedBall = nil
        end
      end

      Game.objects.balls:Clean()


      -- Make sure this will trigger only once
      if Game.comboTimeLeft <= FIXED_DT and Game.comboTimeLeft > 0 then
        Game.events.fire(EVENT_COMBO_TIMEOUT)
      end

      if Game.objects.ballPreview then
        Game.comboTimeLeft = math.max(Game.comboTimeLeft - FIXED_DT, 0)
      end
      Game.timeSinceLastCombo = math.max(Game.timeSinceLastCombo + FIXED_DT, 0)

      pf = pf + 1
      accumulator = accumulator - FIXED_DT
    end
  end
  gf = gf + 1
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

t = 0
function Game.validateHeight()
  local ballsTooHigh = false
  Game.objects.balls:forEach(function(ball)
    if not ball:isInGame() then 
      t = t + 1
      --print('checking height with not all balls', gf, pf)
      return
    end
    if ball.body:getY() < MIN_DISTANCE_TO_TOP + ball.radius then
      ballsTooHigh = true
    end
  end)
  if ballsTooHigh then
    Game.events.fire(EVENT_BALLS_TOO_HIGH)
  end
end

function Game.clearWhiteBalls()
  Game.objects.balls:forEach(function(ball)
    if not ball.indestructible then return end
    Game.ScheduleBallDestruction(ball)
  end)
end

function Game.lose()
  Game.clearWhiteBalls()
  Game.state = STATE_GAME_LOST
  Game.events.add(EVENT_COMBO_TIMEOUT, Game.gameOver)
end


function Game.gameOver()
  Game.setHighScore(Game.score)
  Backend.sendScore(Game.highScore)
  Game.state = STATE_GAME_OVER
  TempSave.Clear()
  LocalSave.Save(Game)
end

function Game.setHighScore(score)
  if score > Game.highScore then
    Game.highScore = score
    Game.newHighScore = true
  end
end

local lastBallNumber
-- TODO: remove from game
-- move to ballpreview file
function Game.GetBallNumber() 
  while true do
    local ballNumber = Game.ballChances:get()
    if ballNumber ~= lastBallNumber then
      --lastBallNumber = ballNumber
      Game.ballChances:update(ballNumber)
      return ballNumber
    end
  end
end

function Game.GetBallRadius()
  local radiusNumber = Game.radiusChances:get()
  Game.radiusChances:update(radiusNumber)
  return BALL_BASE_RADIUS * BALL_RADIUS_MULTIPLIERS[radiusNumber]
end

function Game.ReleaseBall()
  if not Game.objects.ballPreview then return end
  Game.objects.ballPreview.enterGameCallback = function()
    Game.events.fire(EVENT_NEW_BALL_INGAME)
  end
  local newBall = Balls.NewBall(Game.objects.ballPreview, Game.world)
  Game.objects.balls:add(newBall)

  Game.objects.ballPreview = nil
  --Game.objects.ballPreview = Balls.NewBallPreview(Game.objects.ballPreview.position.x)
  Game.lastDroppedBall = newBall
  newBall.startSpawnParticleSystem()
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
      Game.objects.nextBallPreviews:enqueue(Balls.NewBallPreview())
    else
      Game.objects.nextBallPreviews:enqueue(Balls.NewBallPreview({indestructible = true}))
    end

    Game.events.fire(EVENT_NEW_BALL)
  end
end

function Game.IncrementComboTimeout(inc)
  Game.comboTimeLeft = math.min(Game.comboTimeLeft + inc, COMBO_MAX_TIMEOUT)
end

function Game.ScheduleBallDestruction(ball)
  ball:exitGame()
  ball.timeDestroyed = Game.totalTime
  ball.startDeathParticleSystem()
  Game.IncrementComboTimeout(COMBO_INCREMENT_SCORE)
  Scheduler.add(function()
    Game.DestroyBall(ball)
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

function Game.BallCollision(ball1, ball2)
  --Game.IncrementComboTimeout()

  if ball1.indestructible and ball2.indestructible then
    Game.events.fire(EVENT_WHITE_BALLS_HIT)
  end
  if ball1.indestructible or ball2.indestructible then return end
  if ball1.number == ball2.number then
    Game.sameColorBallCollision(ball1, ball2)
  end
end

function Game.sameColorBallCollision(ball1, ball2)
  -- Combo stuff
  if Game.combo == 0 then
    Game.events.fire(EVENT_COMBO_START)
  end
  if not ball1.willDestroy or not ball2.willDestroy then
    Game.combo = Game.combo + 1
    Game.comboNumbers:enqueue({num = ball1.number})
  end

  if not ball1.willDestroy then
    Game.score = Game.score + ComboMultiplier(Game.combo)
    Game.ScheduleBallDestruction(ball1)
    ball1.willDestroy = true
  end
  if not ball2.willDestroy then
  end

  if not ball2.willDestroy then
    Game.score = Game.score + ComboMultiplier(Game.combo)
    Game.ScheduleBallDestruction(ball2)
    ball2.willDestroy = true
  end

  Game.events.fire(EVENT_SCORED)
end

return Game

