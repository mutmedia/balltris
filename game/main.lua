IS_EXTRAPOLATING = true
love.graphics.clear(0, 1, 0)
love.graphics.present()

local piefiller = require 'lib/piefiller'

-- Libraries
require 'lib/math_utils'
local List = require 'lib/doubly_linked_list'
local Queue = require 'lib/queue'
local Vector = require 'lib/vector2d'
local Scheduler = require 'lib/scheduler'

local NewPalette = require 'palette'

local Backend = require 'backend'

-- Game Files
local Game = require 'game'
local TempSave = require 'tempsave'
local LocalSave = require 'localsave'
local Balls = require 'balls'
require 'tutorial'
require 'achievements'
require 'stats'
require 'data_constants'

-- Helper functions
function IsInsideScreen(x, y)
  return math.isInsideRect(x, y, 0, 0, BASE_SCREEN_WIDTH, BASE_SCREEN_HEIGHT)
end

-- Variables
local DEBUG_SHOW_FPS = true

local lastDroppedBall

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

local Palette

local loadtime = love.timer.getTime()
local PROFILE = false
local Pie = {}

local canvasSettings = {
  format = 'normal',
}

-- Behaviour definitions
function love.load()
  Pie = piefiller:new()
  love.graphics.clear(1, 0, 1)
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

  --Game options
  Game.options = DEFAULT_OPTIONS
  LocalSave.Load()

  -- Game Canvas
  loadtime = love.timer.getTime()

  loadingCanvas = love.graphics.newCanvas(BASE_SCREEN_WIDTH, BASE_SCREEN_HEIGHT, canvasSettings)

  love.graphics.clear(1, 0, 1)
  love.graphics.present()
  --print('Time to loading canvas: \t\t'..love.timer.getTime() - loadtime)

  -- Loading UI
  loadtime = love.timer.getTime()
  Game.UI.setFiles('ui/base.lua', 'ui/hud.lua', 'ui/mainmenu.lua', 'ui/game.lua', 'ui/pausemenu.lua', 'ui/gameovermenu.lua', 'ui/leaderboard.lua', 'ui/username.lua', 'ui/options.lua', 'ui/tutorial.lua', 'ui/connection.lua', 'ui/achievements.lua', 'ui/credits.lua')
  Game.UI.initialize(NewPalette(Game.options.colorblind and PALETTE_COLORBLIND_PATH or PALETTE_DEFAULT_PATH))
  love.graphics.setCanvas(loadingCanvas)
  love.graphics.clear()
  --Game.UI.draw()
  drawScaled(loadingCanvas)
  love.graphics.present()
  --print('Time to present load: \t\t\t'..love.timer.getTime() - loadtime)

  love.graphics.clear(0, 1, 1)

  loadtime = love.timer.getTime()
  gameCanvas = love.graphics.newCanvas(BASE_SCREEN_WIDTH, BASE_SCREEN_HEIGHT, canvasSettings)
  auxCanvas1 = love.graphics.newCanvas(BASE_SCREEN_WIDTH, BASE_SCREEN_HEIGHT, canvasSettings)
  auxCanvas2 = love.graphics.newCanvas(BASE_SCREEN_WIDTH, BASE_SCREEN_HEIGHT, canvasSettings)
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
  --print('Time to shader Scanlines: \t\t'..love.timer.getTime() - loadtime)
  Shaders.GammaCorrect = love.graphics.newShader('shaders/addalpha.fs')

  GaussianBlurEffect = (require 'shaders/effect_gaussianblur').New{
    sigma=4,
    scale=2,
    width=BASE_SCREEN_WIDTH,
    height=BASE_SCREEN_HEIGHT,
  }

  CRTEffect = (require 'shaders/effect_crt').New{
    width=BASE_SCREEN_WIDTH,
    height=BASE_SCREEN_HEIGHT,
  }

  -- TODO: move to place where game actually starts
  loaded = true
  love.keyboard.setTextInput(false)
  Game.state:push(STATE_GAME_MAINMENU)
  Game.InitializeTutorial()

  Game.InitializeAchievements()
  Backend.Init()
end

function love.draw() 
  love.graphics.setCanvas()
  -- TODO: Make this a proper state so there is a loading scene
  love.graphics.setNewFont(12)
  local blendMode = love.graphics.getBlendMode()

  -- Move to new canvas
  love.graphics.setCanvas(gameCanvas)
  love.graphics.clear(0, 0, 0, 1)
  --love.graphics.translate(Game.UI.deltaX, Game.UI.deltaY)
  --love.graphics.scale(Game.UI.scaleX, Game.UI.scaleY)


  -- Move this to load when final value set

  -- Next balls

  love.graphics.setBlendMode(blendMode)

  love.graphics.setShader()

  -- UI
  Game.UI.draw()

  -- Switch to game post fx

  GaussianBlurEffect:apply(gameCanvas, auxCanvas1)

  love.graphics.setBlendMode(blendMode)

  love.graphics.setCanvas(auxCanvas2)
  love.graphics.clear()
  love.graphics.setColor(1, 1, 1)
  love.graphics.setShader(Shaders.Glow)

  love.graphics.draw(gameCanvas)
  love.graphics.setBlendMode('add')
  love.graphics.draw(auxCanvas1)
  love.graphics.setBlendMode(blendMode)

  love.graphics.setShader()

  CRTEffect:apply(auxCanvas2, gameCanvas)

  -- Final draw
  love.graphics.setShader(Shaders.GammaCorrect)
  drawScaled(gameCanvas)
  love.graphics.setShader()

  love.graphics.setColor(0, 1, 0)
  love.graphics.setNewFont(10*2)
  if DEBUG_SHOW_FPS then
    love.graphics.print(tostring(love.timer.getFPS( )), 5, 5)
  end
  if PROFILE then
    Pie:draw()
  end
end

function drawScaled(canvas)
  love.graphics.setCanvas()
  love.graphics.translate(Game.UI.deltaX, Game.UI.deltaY)
  love.graphics.scale(Game.UI.scaleX, Game.UI.scaleY)
  love.graphics.draw(canvas)
end


local watchedFiles = {
  ['ui'] = {
    lastUpdated = 0,
  },
  ['data_constants'] = {
    lastUpdated = 0,
  },
  ['content'] = {
    lastUpdated = 0,
  }
}

function love.update(dt)
  if PROFILE then 
    Pie:attach()
  end
  Game.update(dt)
  if PROFILE then 
    Pie:detach()
  end

  if love.mouse.isDown(1) then
    local x, y = love.mouse.getPosition()
    Game.UI.moved(x, y, 0, 0)

  end
  -- Watch Modifiable Files

  --[[
  for k, v in pairs(watchedFiles) do
    if love.filesystem.isFile(k) then
      if v.lastUpdated < love.filesystem.getLastModified(k) then
        print('watched file updated')
        Palette = NewPalette('content/palette.png')
        Game.UI.initialize(NewPalette('content/palette.png'))
        dofile('game/data_constants.lua')
        v.lastUpdated = love.filesystem.getLastModified(k)
      end
    else if love.filesystem.isDirectory(k) then
        for _, f in pairs(love.filesystem.getDirectoryItems(k)) do
          if v.lastUpdated < (love.filesystem.getLastModified(f) or 0) then
            print('watched file updated')
            Palette = NewPalette('content/palette.png')
            Game.UI.initialize(NewPalette('content/palette.png'))
            dofile('game/data_constants.lua')
            v.lastUpdated = love.filesystem.getLastModified(f)
          end
        end
      end
    end
  end
  ]]--
end

function love.textinput(t)
  if Game.inState(STATE_GAME_USERNAME, STATE_GAME_OVER) then
    if string.len(Game.usernameText) < 10 then
      Game.usernameText = Game.usernameText..t
    end
  end
end

function ComboMultiplier(combo)
  return combo + 1
end


function beginContact(a, b, coll)
  local aref = a:getUserData() and a:getUserData().ref
  local bref = b:getUserData() and b:getUserData().ref
  if aref then 
    if aref.isWall then return end
    aref:enterGame()
  end
  if bref then 
    if bref.isWall then return end
    bref:enterGame()
  end
  if not aref or not bref then return end

  Game.BallCollision(aref, bref)
end

function endContact(a, b, coll)
end
function preSolve(a, b, coll)
end
function postSolve(a, b, coll, normalimpulse, tangentimpulse)
end

-- INPUT
function love.keypressed(key)
  if PROFILE then
    Pie:keypressed(key)
  end
  if Game.inState(STATE_GAME_USERNAME, STATE_GAME_OVER) then 
    if key == 'backspace' then
      Game.usernameText = Game.usernameText:sub(1, -2)
    end
  end

  if love.keyboard.hasTextInput() then return end

  if Game.inState(STATE_GAME_RUNNING) then
    if key == INPUT_RELEASE_BALL then
      ReleaseBall() 
    end 

    if key == INPUT_SWITCH_BALL then
      SwitchBall()
    end
  end

  if key == 'q' then
    PROFILE = not PROFILE
  end

  -- DEBUG input
  if key == 'u' then
    dofile('game/data_constants.lua')
    local palette = NewPalette(Game.options.colorblind and PALETTE_COLORBLIND_PATH or PALETTE_DEFAULT_PATH)
    Game.UI.initialize(palette)
  end

  if key == 'l' then
    Game.lose()
  end

  if key == 's' then
    --TempSave.Save(Game)
  end

  if key == 'escape' then
    if Game.inState(STATE_GAME_RUNNING) then
      Game.state:push(STATE_GAME_PAUSED)
    elseif Game.inState(STATE_GAME_PAUSED) then
      Game.state:push(STATE_GAME_RUNNING)
    elseif Game.inState(STATE_GAME_OPTIONS) then
      Game.state:pop()
    end
  end

  if key == 'f' then
    DEBUG_SHOW_FPS = not DEBUG_SHOW_FPS
  end

  --[[
  if key == 't' then
    print(Game.tutorial.state:peek())
  end
  ]]--

  if key == 'r' then
    --[[
    Game.state:push(STATE_GAME_RUNNING)
    if Game.objects then 
      Game.objects.ballPreview = Balls.NewBallPreview()
      if Game.objects.nextBallPreviews then
        Game.objects.nextBallPreviews:Clear()
        Game.objects.nextBallPreviews:enqueue(Balls.NewBallPreview())
      end
      if Game.objects.balls then
        Game.objects.balls:Clear()
      end
    end
    --]]
  end

  if key == 'b' then
    Backend.SendStats(Game.stats, Game.number)
  end

  if key == 'e' then 
    IS_EXTRAPOLATING = not IS_EXTRAPOLATING
  end
end

function love.mousepressed(x, y)
  if PROFILE then
    Pie:mousepressed(x, y)
  end
  Game.UI.pressed(x, y)
end

function love.mousemoved(x, y, dx, dy)
    Game.UI.moved(x, y, dx, dy)
end

function love.mousereleased(x, y, button)
  Game.UI.released(x, y)
end

function love.focus(f)
  if Game.inState(STATE_GAME_RUNNING) and f then
    Game.state:push(STATE_GAME_PAUSED)
  end
end
