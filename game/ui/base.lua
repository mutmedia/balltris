require 'data_constants'
require 'events'

UI = require 'ui'
Rectangle = UI.rectangle
Text = UI.text
Button = UI.button
Custom = UI.object
Game = require 'game'

--local DEBUG_UI = true

MAIN_UI_FONT = 'content/Neon.ttf'
UI.DEFAULT_FONT_COLOR = {255, 255, 255}

FONT_XS = love.graphics.newFont(MAIN_UI_FONT, 40)
FONT_SM = love.graphics.newFont(MAIN_UI_FONT, 50)
FONT_MD = love.graphics.newFont(MAIN_UI_FONT, 80)
FONT_LG = love.graphics.newFont(MAIN_UI_FONT, 120)
FONT_XL = love.graphics.newFont(MAIN_UI_FONT, 160)

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


