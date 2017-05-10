require 'data_constants'
require 'events'
require 'math_utils'

function FadeInTween(k)
  k = math.clamp(k, 0, 1)
  return k*k
end

function FadeOutTween(k)
  k = math.clamp(k, 0, 1)
  k = 1 - k
  return k * k
end

function WithFade(uielem)
  return function(obj)
    obj.transitionInTime= obj.transitionInTime or 1.0
    obj.transitionIn = obj.transitionIn or function(self, dt)
      local fadeTime = (self.transitionInTime/2)
      local maxDelay = (self.transitionInTime/2) 
      local k = ((-self.y/BASE_SCREEN_HEIGHT)*maxDelay + dt)/fadeTime
      return {
        visibility = FadeInTween(k),
      }
    end

    obj.transitionOutTime= obj.transitionOutTime or 1.0
    obj.transitionOut = obj.transitionOut or  function(self, dt)
      local fadeTime = (self.transitionOutTime/2)
      local maxDelay = (self.transitionOutTime/2) 
      local k = ((-self.y/BASE_SCREEN_HEIGHT)*maxDelay + dt)/fadeTime
      return {
        visibility = FadeOutTween(k),
      }
    end

    return uielem(obj)
  end
end

UI = require 'ui'
Rectangle = WithFade(UI.rectangle)
Text = WithFade(UI.text)
Button = (UI.button)

Custom = WithFade(UI.object)
Game = require 'game'

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


