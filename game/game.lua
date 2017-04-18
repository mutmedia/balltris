local List = require 'doubly_linked_list'
local Queue = require 'queue'

Game = {}
Game.UI = require 'ui'
Game.events = require 'events'

Game.objects = {}
Game.state = STATE_GAME_RUNNING
Game.world = nil

Game.score = 0
Game.combo = 0
Game.maxCombo = 0

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
  Game.events:clear()
  Game.events:add(EVENT_MOVED_PREVIEW, function(x, y, dx, dy)
    if Game.objects.ballPreview then
      Game.objects.ballPreview.drawStyle = 'line'
      Game.objects.ballPreview.position.x = utils.clamp(x, BORDER_THICKNESS + Game.objects.ballPreview.radius + 1, BASE_SCREEN_WIDTH - (BORDER_THICKNESS + Game.objects.ballPreview.radius) - 1)
    end
  end)

  Game.events:add(EVENT_RELEASED_PREVIEW, ReleaseBall)
  Game.events:add(EVENT_PRESSED_SWITCH, SwitchBall)
  Game.events:add(EVENT_ON_BALLS_STATIC, OnBallsStatic)
  Game.events:add(EVENT_SAFE_TO_DROP, GetNextBall)


  -- Score
  Game.score = 0
  Game.combo = 0
  Game.maxCombo = 0

end

return Game

