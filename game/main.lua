-- Libraries
require 'math_utils'
local List = require 'doubly_linked_list'
local Queue = require 'queue'
local Vector = require 'vector2d'
local Scheduler = require 'scheduler'
--local BackEnd = require 'playfab'

-- Game Files
local Game = require 'game'
require 'data_constants'

-- Helper functions
function NewBallPreview(initialData)
  initialData = initialData or {
    indestructible = false,
  }
  local number = Game.GetBallNumber()
  --local indestructible = math.random() > 0.9
  local radius = initialData.indestructible and WHITE_BALL_SIZE or Game.GetBallRadius()
  local getColor = function() return initialData.indestructible and WHITE_BALL_COLOR or BALL_COLORS[number] end
  local position = Vector.new{x=BASE_SCREEN_WIDTH/2, y=radius + PREVIEW_PADDING}
  return {
    number = number,
    position = position,
    radius = radius,
    getColor = getColor,
    drawStyle = 'line',
    indestructible = initialData.indestructible,
    destroyed = false,
  }
end

function IsInsideScreen(x, y)
  return utils.isInsideRect(x, y, 0, 0, BASE_SCREEN_WIDTH, BASE_SCREEN_HEIGHT)
end

-- Variables
local DEBUG_SHOW_FPS = true

local lastDroppedBall

local hit = false
local lastHit = false

local ballsRemoved = 0
local totalSpeed2 = 0
local lastTotalSpeed2 = -1
local time = 0

local Shaders = {
  GaussianBlur,
  Edge,
  TurnOff,
  BlackWhite,
  BarrelDistort,
  Scanlines,
}

local lightDirection = {1, 1, 3}
local gameCanvas
local loadingCanvas
local auxCanvas1
local auxCanvas2

local startTime = love.timer.getTime()

local loader
local dataToLoadChannel
local dataLoadedChannel
local threadPrintChannel


local loaded = false

-- Behaviour definitions
function love.load()
  -- Initializing logic
  math.randomseed( os.time() )
  love.window.setTitle(TITLE)
  love.window.setMode(BASE_SCREEN_WIDTH, BASE_SCREEN_HEIGHT, {resizable=true})

  -- Physics
  love.physics.setMeter(METER)

  -- Loading actual stuff
  --[[
  loader = love.thread.newThread('loader.lua')
  dataToLoadChannel = love.thread.getChannel('data_to_load')
  dataLoadedChannel = love.thread.getChannel('data_loaded')
  threadPrintChannel = love.thread.getChannel('thread_print')
  loader:start()
  Scheduler.add(function() 
    dataToLoadChannel:push({
        type='shader', value={'shaders/edgeshader.fs', 'shaders/edgeshader.vs'},
      })
  end, 1)
  ]]--

  -- Game Canvas
  gameCanvas = love.graphics.newCanvas(BASE_SCREEN_WIDTH, BASE_SCREEN_HEIGHT, 'normal', 0)
  auxCanvas1 = love.graphics.newCanvas(BASE_SCREEN_WIDTH, BASE_SCREEN_HEIGHT, 'normal', 0)
  auxCanvas2 = love.graphics.newCanvas(BASE_SCREEN_WIDTH, BASE_SCREEN_HEIGHT, 'normal', 0)
  loadingCanvas = love.graphics.newCanvas(BASE_SCREEN_WIDTH, BASE_SCREEN_HEIGHT, 'normal', 0)

  -- UI
  Game.UI.setFiles('ui/hud.lua')
  Game.UI.initialize()
  love.graphics.setCanvas(loadingCanvas)
  love.graphics.clear()
  Game.UI.draw()
  drawScaled(loadingCanvas)
  love.graphics.present()

  -- Shaders
  Shaders.TurnOff = love.graphics.newShader('shaders/turnOffShader.fs')

  --Shaders.GaussianBlur = love.graphics.newShader('shaders/gaussianblur.vs', 'shaders/gaussianblur.fs')
  Shaders.GaussianBlur = require('shaders/gaussianblur2')(4) -- Making this too big crashes
  Shaders.Edge = love.graphics.newShader('shaders/edgeshader.fs', 'shaders/edgeshader.vs')
  Shaders.BlackWhite = love.graphics.newShader('shaders/blackandwhite.fs')
  Shaders.BarrelDistort = love.graphics.newShader('shaders/barreldistort.fs')
  Shaders.Scanlines = love.graphics.newShader('shaders/scanlines.fs')


  Game.load()

  -- TODO: move to place where game actually starts
  Scheduler.add(function() 
    loaded = true
    Game.start()
  end, 1)
end

local bv = 0
function love.draw() 
  love.graphics.setCanvas()
  -- TODO: Make this a proper state so there is a loading scene
  if not loaded then 
    love.graphics.setCanvas(gameCanvas)
    love.graphics.clear()
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(loadingCanvas)
  else
    love.graphics.setNewFont(12)
    local b = love.graphics.getBlendMode()

    -- Move to new canvas
    love.graphics.setCanvas(gameCanvas)
    love.graphics.clear(0, 0, 0, 255)
    --love.graphics.translate(Game.UI.deltaX, Game.UI.deltaY)
    --love.graphics.scale(Game.UI.scaleX, Game.UI.scaleY)

    -- Stage BG
    --[[
  love.graphics.setColor(0, 0, 0)
  --love.graphics.setColor(255, 255, 255)
  love.graphics.polygon('fill', Game.objects.ground.body:getWorldPoints(Game.objects.ground.shape:getPoints())) 
  love.graphics.polygon('fill', Game.objects.wallL.body:getWorldPoints(Game.objects.wallL.shape:getPoints()))
  love.graphics.polygon('fill', Game.objects.wallR.body:getWorldPoints(Game.objects.wallR.shape:getPoints()))
  ]]--

    love.graphics.setLineWidth(BALL_LINE_WIDTH_IN)
    love.graphics.setColor(WHITE_BALL_COLOR)
    love.graphics.rectangle('line', BORDER_THICKNESS, -10, HOLE_WIDTH, HOLE_DEPTH + 10)
    love.graphics.setLineWidth(BALL_LINE_WIDTH_OUT)
    love.graphics.rectangle('line', BORDER_THICKNESS - BALL_LINES_DISTANCE, -10 - BALL_LINES_DISTANCE, HOLE_WIDTH + 2 * BALL_LINES_DISTANCE, HOLE_DEPTH + 10 + 2 * BALL_LINES_DISTANCE)
    love.graphics.setLineWidth(1)
    -- Balls
    love.graphics.setBlendMode('add', 'premultiplied')

    -- Move this to load when final value set
    Shaders.TurnOff:send('time_to_destroy', BALL_TIME_TO_DESTROY)

    -- Ball Preview
    local time = love.timer.getTime() - startTime
    if Game.objects.ballPreview and Game.objects.ballPreview.drawStyle ~= 'none' then
      local center = {Game.objects.ballPreview.position.x, Game.objects.ballPreview.position.y}
      local radius = Game.objects.ballPreview.radius
      local color = Game.objects.ballPreview.getColor()

      love.graphics.push()
      love.graphics.setColor(color)
      love.graphics.translate(center[1], center[2])
      love.graphics.setLineWidth(BALL_LINE_WIDTH_OUT)
      love.graphics.circle('line', 0, 0, radius * BALL_DRAW_SCALE)
      love.graphics.setLineWidth(BALL_LINE_WIDTH_IN)
      love.graphics.circle('line', 0, 0, radius * BALL_DRAW_SCALE - BALL_LINES_DISTANCE)
      love.graphics.pop()

    end

    Game.objects.balls:forEach(function(ball) 
      local center = {ball.body:getX(), ball.body:getY()}
      local radius = ball.radius
      local color = ball.getColor()
      if ball.timeDestroyed then
        love.graphics.setShader(Shaders.TurnOff)
        Shaders.TurnOff:send('delta_time', time - ball.timeDestroyed)
      else
        love.graphics.setShader()
      end
      local vx, vy = ball.body:getLinearVelocity()
      local s = BALL_SPEED_STRETCH * math.sqrt(vx * vx + vy * vy)
      local rot = math.atan2(vy, vx)
      love.graphics.push()
      love.graphics.setColor(color)
      love.graphics.translate(center[1], center[2])
      love.graphics.rotate(rot)
      love.graphics.scale(1+s, 1-s)
      love.graphics.setLineWidth(BALL_LINE_WIDTH_OUT)
      love.graphics.circle('line', 0, 0, radius * BALL_DRAW_SCALE)
      love.graphics.setLineWidth(BALL_LINE_WIDTH_IN)
      love.graphics.circle('line', 0, 0, radius * BALL_DRAW_SCALE - BALL_LINES_DISTANCE)
      love.graphics.pop()
      --love.graphics.reset()
    end)


    -- Next balls
    local ballPreviewNum = 1
    local ballPreviewHeight = 80
    local ballPreviewX = BASE_SCREEN_WIDTH - (BORDER_THICKNESS)/2
    love.graphics.setLineWidth(1)
    Game.objects.nextBallPreviews:forEach(function(nextBallPreview)
      ballPreviewHeight = ballPreviewHeight + nextBallPreview.radius

      local center = {ballPreviewX, ballPreviewHeight}
      local radius = nextBallPreview.radius
      local color = nextBallPreview.getColor()

      love.graphics.push()
      love.graphics.translate(center[1], center[2])
      love.graphics.setColor(color)

      love.graphics.setLineWidth(BALL_LINE_WIDTH_OUT)
      love.graphics.circle('line', 0, 0, radius * BALL_DRAW_SCALE)
      love.graphics.setLineWidth(BALL_LINE_WIDTH_IN)
      love.graphics.circle('line', 0, 0, radius * BALL_DRAW_SCALE - BALL_LINES_DISTANCE)
      love.graphics.pop()

      ballPreviewNum = ballPreviewNum + 1

      ballPreviewHeight = ballPreviewHeight + nextBallPreview.radius + 5
    end)
    love.graphics.setBlendMode(b)


    love.graphics.setShader()

    -- UI
    Game.UI.draw()

    -- Switch to game post fx

    love.graphics.setCanvas(auxCanvas1)
    love.graphics.clear()
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(gameCanvas)

    love.graphics.setBlendMode('alpha', 'premultiplied')

    love.graphics.setCanvas(auxCanvas2)
    love.graphics.clear()
    love.graphics.setColor(255, 255, 255)
    Shaders.GaussianBlur:send('offset_direction', {1.3 / auxCanvas2:getWidth(), 0})
    love.graphics.setShader(Shaders.GaussianBlur)
    love.graphics.draw(auxCanvas1, 0, 0)

    love.graphics.setCanvas(auxCanvas1)
    love.graphics.clear()
    love.graphics.setColor(255, 255, 255)
    Shaders.GaussianBlur:send('offset_direction', {0, 1.3 / auxCanvas1:getHeight()})
    love.graphics.draw(auxCanvas2, 0, 0)

    love.graphics.setShader()
    love.graphics.setBlendMode(b)

    love.graphics.setCanvas(auxCanvas2)
    love.graphics.clear()
    love.graphics.setColor(255, 255, 255)
    --love.graphics.setColor(255, 255, 255)


    love.graphics.draw(gameCanvas)
    love.graphics.setBlendMode('add')
    love.graphics.draw(auxCanvas1)
    --love.graphics.setBlendMode('add')
    --love.graphics.setColor(200, 0, 0, 120)
    --love.graphics.circle('fill', 300, 400, 200)
    --love.graphics.setColor(0, 200, 0, 120)
    --love.graphics.circle('fill', 300, 600, 200)
    love.graphics.setBlendMode(b)

    love.graphics.setCanvas(auxCanvas1)
    love.graphics.setShader(Shaders.Scanlines)
    love.graphics.draw(auxCanvas2)
    love.graphics.setShader()

    love.graphics.setCanvas(auxCanvas2)
    love.graphics.setShader(Shaders.BarrelDistort)
    Shaders.BarrelDistort:send('distortion', EFFECT_CRT_DISTORTION)
    love.graphics.draw(auxCanvas1)
    love.graphics.setShader()

    love.graphics.setCanvas(gameCanvas)
    love.graphics.clear()
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(auxCanvas2)
  end

  -- Final draw
  drawScaled(gameCanvas)

  love.graphics.setColor(0, 255, 0)
  love.graphics.setNewFont(10)
  if DEBUG_SHOW_FPS then
    love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)
  end
end

function drawScaled(canvas)
  love.graphics.setCanvas()
  love.graphics.translate(Game.UI.deltaX, Game.UI.deltaY)
  love.graphics.scale(Game.UI.scaleX, Game.UI.scaleY)
  love.graphics.draw(canvas)
end

function love.update(dt)
  Scheduler.update(dt)
  if loaded then
    Game.update(dt)
  end
end

function ComboMultiplier(combo)
  return combo
end


function beginContact(a, b, coll)
  local aref = a:getUserData() and a:getUserData().ref
  local bref = b:getUserData() and b:getUserData().ref
  if aref then aref.inGame = true end
  if bref then bref.inGame = true end
  if not aref or not bref then return end

  if aref.indestructible or bref.indestructible then return end
  if aref.number == bref.number then
    -- Combo stuff
    Game.combo = Game.combo + 1
    if not aref.willDestroy then
      Game.score = Game.score + ComboMultiplier(Game.combo)
    end
    if not bref.willDestroy then
      Game.score = Game.score + ComboMultiplier(Game.combo)
    end
    hit = true

    -- Ball destruction
    if not aref.willDestroy then
      Scheduler.add(function() DestroyBall(aref) end, BALL_TIME_TO_DESTROY)
    end
    aref.willDestroy = true

    if not bref.willDestroy then
      Scheduler.add(function() DestroyBall(bref) end, BALL_TIME_TO_DESTROY)
    end
    bref.willDestroy = true

  end
end

function endContact(a, b, coll)
end
function preSolve(a, b, coll)
end
function postSolve(a, b, coll, normalimpulse, tangentimpulse)
end



function DestroyBall(ball)
  ball.inGame = false
  ball.destroyed = true
  ball.timeDestroyed = love.timer.getTime() - startTime
  ball.fixture:setMask(COL_MAIN_CATEGORY)
  ball.body:setActive(false)
  Scheduler.add(function()
    Game.objects.balls:SetToDelete(ball)
    ballsRemoved = ballsRemoved + 1
  end, 0.25)
end


-- INPUT
function love.keypressed(key)
  if Game.state == STATE_GAME_RUNNING then
    if key == INPUT_RELEASE_BALL then
      ReleaseBall() 
    end 

    if key == INPUT_SWITCH_BALL then
      SwitchBall()
    end
  end

  -- DEBUG input
  if key == 'u' then
    Game.UI:initialize()
    dofile('Game/data_constants.lua')
  end

  if key == 'o' then
    Game.gameOver()
  end

  if key == 'f' then
    DEBUG_SHOW_FPS = not DEBUG_SHOW_FPS
  end

  if key == 'r' then
    Game.objects.balls:Clear()
    Game.state = STATE_GAME_RUNNING
    Game.objects.ballPreview = NewBallPreview()
    Game.objects.nextBallPreviews:Clear()
    Game.objects.nextBallPreviews:enqueue(NewBallPreview())
  end
end

function love.mousepressed(x, y)
  Game.UI.pressed(x, y)
end

function love.mousemoved(x, y, dx, dy)
  -- TODO: move this
  if Game.objects.ballPreview then
    Game.objects.ballPreview.drawStyle = 'none'
  end
  Game.UI.moved(x, y, dx, dy)
end

function love.mousereleased(x, y, button)
  Game.UI.released(x, y)
end

