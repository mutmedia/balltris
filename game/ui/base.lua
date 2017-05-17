require 'lib/events'
require 'lib/math_utils'

require 'data_constants'
UI = require 'ui'
Game = require 'game'

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

Rectangle = WithFade(UI.rectangle)
Text = WithFade(UI.text)
Button = WithFade(UI.button)
Custom = WithFade(UI.object)

--local DEBUG_UI = true

MAIN_UI_FONT = 'content/Neon.ttf'
UI.DEFAULT_FONT_COLOR = {255, 255, 255}

FONT_XS = love.graphics.newFont(MAIN_UI_FONT, 40*BASE_SCREEN_WIDTH/1080)
FONT_SM = love.graphics.newFont(MAIN_UI_FONT, 50*BASE_SCREEN_WIDTH/1080)
FONT_MD = love.graphics.newFont(MAIN_UI_FONT, 80*BASE_SCREEN_WIDTH/1080)
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

function And(...)
  local conditions = {...}
  return function()
    for _, cond in pairs(conditions) do
      if not cond() then
        return false
      end
    end

    return true
  end
end

function Not(cond)
  return function()
    return not cond()
  end
end

function True()
  return function()
    return true
  end
end

function False()
  return Not(True())
end


