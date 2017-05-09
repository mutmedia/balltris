require 'data_constants'
require 'events'
require 'math_utils'

UI = require 'ui'
Rectangle = UI.rectangle
Text = UI.text
function buttonFadeInTween(k)
  k = math.clamp(k, 0, 1)
  return k*k
end

function buttonFadeOutTween(k)
  k = math.clamp(k, 0, 1)
  k = 1 - k
  return k * k
end
Button = function (obj)
  obj.transitionInTime= obj.transitionInTime or 0.4
  obj.transitionIn = obj.transitionIn or function(self, dt)
    local fadeTime = (self.transitionInTime/2)
    local maxDelay = (self.transitionInTime/2) 
    local k = ((-self.y/BASE_SCREEN_HEIGHT)*maxDelay + dt)/fadeTime
    return {
      visibility = buttonFadeInTween(k)
    }
  end

  obj.transitionOutTime= obj.transitionOutTime or 0.4
  obj.transitionOut = obj.transitionOut or  function(self, dt)
    local fadeTime = (self.transitionOutTime/2)
    local maxDelay = (self.transitionOutTime/2) 
    local k = ((-self.y/BASE_SCREEN_HEIGHT)*maxDelay + dt)/fadeTime
    return {
      visibility = buttonFadeOutTween(k)
    }
  end

  return UI.button(obj)
end

Custom = UI.object
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


