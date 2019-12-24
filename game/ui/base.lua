require 'lib/events'
require 'lib/math_utils'
require 'lib/condition_utils'

require 'data_constants'
UI = require 'ui'
Game = require 'game'
ParticleSystem = require 'lib/particle_system'

function FadeInTween(k)
  k = math.clamp(k, 0, 1)
  return k
end

function FadeOutTween(k)
  k = math.clamp(k, 0, 1)
  k = 1 - k
  return k * k
end

local fadeTime = 0.6
local fadeShader = love.graphics.newShader('shaders/printer.fs')
function WithFade(uielem)
  return function(obj)
    obj.shader = obj.shader or fadeShader
    obj.transitionInTime = obj.transitionInTime or obj.transitionTime or fadeTime
    obj.transitionIn = obj.transitionIn or function(self, p)
      local k = FadeInTween(p)
      self.uniforms={
        k = k
      }
      return {
        --visibility = k,
      }
    end

    obj.transitionOutTime = obj.transitionOutTime or obj.transitionTime or fadeTime
    obj.transitionOut = obj.transitionOut or  function(self, p)
      k = FadeInTween(p)
      self.uniforms={
        k = -k
      }
      return {
        --visibility = k,
      }

    end

    return uielem(obj)
  end
end

Rectangle = (UI.rectangle)
Text = (UI.text)
Button = (UI.button)
Custom = (UI.object)

--local DEBUG_UI = true

MAIN_UI_FONT = 'content/Neon.ttf'
UI.DEFAULT_FONT_COLOR = {1, 1, 1}

COLOR_BLACK = 0
COLOR_WHITE = 1
COLOR_TRANSPARENT = 2
COLOR_PINK = 3
COLOR_YELLOW = 4
COLOR_BLUE = 5
COLOR_GREEN = 6
COLOR_RED = 7
COLOR_GRAY = 8

FONT_XS = love.graphics.newFont(MAIN_UI_FONT, 40*BASE_SCREEN_WIDTH/1080)
FONT_SM = love.graphics.newFont(MAIN_UI_FONT, 50*BASE_SCREEN_WIDTH/1080)
FONT_MD = love.graphics.newFont(MAIN_UI_FONT, 75*BASE_SCREEN_WIDTH/1080)
FONT_LG = love.graphics.newFont(MAIN_UI_FONT, 120*BASE_SCREEN_WIDTH/1080)
FONT_XL = love.graphics.newFont(MAIN_UI_FONT, 160*BASE_SCREEN_WIDTH/1080)

UI_HEIGHT_UNIT = BASE_SCREEN_HEIGHT/40

--love.graphics.newFont = function() end

function inGameState(...) 
  local vars = {...}
  return function()
    return Game.inState(unpack(vars))
  end
end

Custom{
  name='Particle Systems',
  layer=LAYER_GAME,
  condition = True(),
  draw=ParticleSystem.Draw,
}

