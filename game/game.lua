local List = require 'doubly_linked_list'
local Queue = require 'queue'
local RandomBag = require 'randombag'

Game = {}
Game.UI = require 'ui'
Game.events = require 'events'

Game.objects = {}
Game.state = STATE_GAME_RUNNING
Game.world = nil

Game.score = 0
Game.highScore = 0
Game.newHighScore = false
Game.combo = 0
Game.maxCombo = 0

-- Initialize game

-- TODO: move to ballpreview.lua
local ballChances = RandomBag.new(#BALL_COLORS, BALL_CHANCE_MODIFIER)

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
  Game.state = STATE_GAME_RUNNING

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

  Game.events.add(EVENT_RELEASED_PREVIEW, ReleaseBall)
  Game.events.add(EVENT_ON_BALLS_STATIC, Game.onBallsStatic)
  Game.events.add(EVENT_SAFE_TO_DROP, GetNextBall)
  Game.events.add(EVENT_BALLS_TOO_HIGH, function()
    Game.objects.balls:forEach(function(ball)
      if not ball.indestructible then return end
      DestroyBall(ball)
    end)
    Game.state = STATE_GAME_LOST
    Game.events.add(EVENT_ON_BALLS_STATIC, Game.gameOver)
  end)

  -- Score
  Game.score = 0
  Game.combo = 0
  Game.maxCombo = 0
  Game.newHighScore = false

  -- Ball chances
  ballChances = RandomBag.new(#BALL_COLORS, BALL_CHANCE_MODIFIER)
end

local static = 0
function Game.onBallsStatic()
  static = static + 1
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
  if Game.combo > Game.maxCombo then Game.maxCombo = Game.combo return end
  Game.combo = 0

end

function Game.gameOver()
  Game.setHighScore(Game.score)
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

return Game

