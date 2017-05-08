-- Libraries
require 'math_utils'
local List = require 'doubly_linked_list'
local Queue = require 'queue'
local Vector = require 'vector2d'
local Scheduler = require 'scheduler'

local NewPalette = require 'palette'

--local BackEnd = require 'playfab'

-- Game Files
local Game = require 'game'
local SaveSystem = require 'savesystem'
require 'data_constants'
local Balls = require 'balls'

-- Helper functions
function IsInsideScreen(x, y)
  return utils.isInsideRect(x, y, 0, 0, BASE_SCREEN_WIDTH, BASE_SCREEN_HEIGHT)
end

-- Variables
local DEBUG_SHOW_FPS = true

local lastDroppedBall

local hit = false
local lastHit = false

local totalSpeed2 = 0
local lastTotalSpeed2 = -1
local time = 0

local Shaders = {
  Edge,
  TurnOff,
  BlackWhite,
  BarrelDistort,
  Scanlines,
}

local GaussianBlurEffect

local gameCanvas
local loadingCanvas
local auxCanvas1
local auxCanvas2


local loader
local dataToLoadChannel
local dataLoadedChannel
local threadPrintChannel

local Palette

local loadtime = love.timer.getTime()

-- Behaviour definitions
function love.load()
  love.graphics.clear(255, 0, 255)
  love.graphics.present()
  --print('Time to start loading: '..love.timer.getTime() - loadtime)
  -- Initializing logic
  loadtime = love.timer.getTime()
  math.randomseed( os.time() )
  --print('Time to do random logic: \t\t'..love.timer.getTime() - loadtime)
  loadtime = love.timer.getTime()
  love.window.setTitle(TITLE)
  --print('Time to do title logic: \t\t'..love.timer.getTime() - loadtime)

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

  -- Load Game Palette

  -- Game Canvas
  loadtime = love.timer.getTime()
  loadingCanvas = love.graphics.newCanvas(BASE_SCREEN_WIDTH, BASE_SCREEN_HEIGHT, 'normal', 0)

  love.graphics.clear(255, 0, 255)
  love.graphics.present()
  --print('Time to loading canvas: \t\t'..love.timer.getTime() - loadtime)

  -- Loading UI
  loadtime = love.timer.getTime()
  Game.UI.setFiles('ui/base.lua', 'ui/hud.lua', 'ui/mainmenu.lua', 'ui/game.lua', 'ui/pausemenu.lua', 'ui/gameovermenu.lua')
  Game.UI.initialize(NewPalette('content/palette.png'))
  love.graphics.setCanvas(loadingCanvas)
  love.graphics.clear()
  --Game.UI.draw()
  drawScaled(loadingCanvas)
  love.graphics.present()
  --print('Time to present load: \t\t\t'..love.timer.getTime() - loadtime)

  love.graphics.clear(0, 255, 255)

  loadtime = love.timer.getTime()
  gameCanvas = love.graphics.newCanvas(BASE_SCREEN_WIDTH, BASE_SCREEN_HEIGHT, 'normal', 0)
  auxCanvas1 = love.graphics.newCanvas(BASE_SCREEN_WIDTH, BASE_SCREEN_HEIGHT, 'normal', 0)
  auxCanvas2 = love.graphics.newCanvas(BASE_SCREEN_WIDTH, BASE_SCREEN_HEIGHT, 'normal', 0)
  --print('Time to load other canvases: \t\t'..love.timer.getTime() - loadtime)


  -- Shaders
  loadtime = love.timer.getTime()
  Shaders.Edge = love.graphics.newShader('shaders/edgeshader.fs', 'shaders/edgeshader.vs')
  --print('Time to shader Edge: \t\t\t'..love.timer.getTime() - loadtime)
  loadtime = love.timer.getTime()
  Shaders.BlackWhite = love.graphics.newShader('shaders/blackandwhite.fs')
  --print('Time to shader BlackWhite: \t\t'..love.timer.getTime() - loadtime)
  loadtime = love.timer.getTime()
  Shaders.BarrelDistort = love.graphics.newShader('shaders/barreldistort.fs')
  --print('Time to shader BarrelDistort: \t\t'..love.timer.getTime() - loadtime)
  loadtime = love.timer.getTime()
  Shaders.Scanlines = love.graphics.newShader('shaders/scanlines.fs')
  Shaders.Scanlines:send('pixel_size', EFFECT_CRT_PIXEL)
  --print('Time to shader Scanlines: \t\t'..love.timer.getTime() - loadtime)
  Shaders.GammaCorrect = love.graphics.newShader('shaders/addalpha.fs')

  GaussianBlurEffect = (require 'shaders/effect_gaussianblur').new{
    sigma=4,
    scale=2,
    width=BASE_SCREEN_WIDTH,
    height=BASE_SCREEN_HEIGHT,
  }

  Game.load()

  -- TODO: move to place where game actually starts
  loaded = true
  Game.state = STATE_GAME_MAINMENU
end

local bv = 0
function love.draw() 
  love.graphics.setCanvas()
  -- TODO: Make this a proper state so there is a loading scene
  love.graphics.setNewFont(12)
  local b = love.graphics.getBlendMode()

  -- Move to new canvas
  love.graphics.setCanvas(gameCanvas)
  love.graphics.clear(0, 0, 0, 255)
  --love.graphics.translate(Game.UI.deltaX, Game.UI.deltaY)
  --love.graphics.scale(Game.UI.scaleX, Game.UI.scaleY)


  -- Move this to load when final value set

  -- Next balls

  love.graphics.setBlendMode(b)

  love.graphics.setShader()

  -- UI
  Game.UI.draw()

  -- Switch to game post fx

  GaussianBlurEffect:apply(gameCanvas, auxCanvas1)

  love.graphics.setBlendMode(b)

  love.graphics.setCanvas(auxCanvas2)
  love.graphics.clear()
  love.graphics.setColor(255, 255, 255)

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


  -- Final draw
  love.graphics.setShader(Shaders.GammaCorrect)
  drawScaled(gameCanvas)
  love.graphics.setShader()

  love.graphics.setColor(0, 255, 0)
  love.graphics.setNewFont(10*3)
  if DEBUG_SHOW_FPS then
    love.graphics.print(tostring(love.timer.getFPS( )), 5, 5)
  end
end

function drawScaled(canvas)
  love.graphics.setCanvas()
  love.graphics.translate(Game.UI.deltaX, Game.UI.deltaY)
  love.graphics.scale(Game.UI.scaleX, Game.UI.scaleY)
  love.graphics.draw(canvas)
end

function love.update(dt)
  Game.update(dt)
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
    Game.events.fire(EVENT_SCORED)

    -- Combo stuff
    if Game.combo == 0 then
      Game.events.fire(EVENT_COMBO_START)
    end
    if not aref.willDestroy or not bref.willDestroy then
      Game.combo = Game.combo + 1
    end
    if not aref.willDestroy then
      Game.score = Game.score + ComboMultiplier(Game.combo)
    end
    if not bref.willDestroy then
      Game.score = Game.score + ComboMultiplier(Game.combo)
    end
    hit = true

    -- Ball destruction
    if not aref.willDestroy then
      Game.ScheduleBallDestruction(aref)
      aref.willDestroy = true
    end

    if not bref.willDestroy then
      Game.ScheduleBallDestruction(bref)
      bref.willDestroy = true
    end

  end
end

function endContact(a, b, coll)
end
function preSolve(a, b, coll)
end
function postSolve(a, b, coll, normalimpulse, tangentimpulse)
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
    Palette = NewPalette('content/palette.png')
    Game.UI.initialize(NewPalette('content/palette.png'))
    dofile('Game/data_constants.lua')
  end

  if key == 'l' then
    Game.lose()
  end

  if key == 's' then
    SaveSystem.save(Game)
  end

  if key == 'escape' then
    if Game.state ~= STATE_GAME_PAUSED then
      Game.state = STATE_GAME_PAUSED
    else
      -- TODO: this might be buggy if there is more than a running state
      Game.state = STATE_GAME_RUNNING
    end
  end

  if key == 'f' then
    DEBUG_SHOW_FPS = not DEBUG_SHOW_FPS
  end

  if key == 'r' then
    Game.objects.balls:Clear()
    Game.state = STATE_GAME_RUNNING
    Game.objects.ballPreview = Balls.NewBallPreview()
    Game.objects.nextBallPreviews:Clear()
    Game.objects.nextBallPreviews:enqueue(Balls.NewBallPreview())
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

