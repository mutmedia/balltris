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


