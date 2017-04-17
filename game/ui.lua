bit32 = require("bit") 
require 'game_debug'

require 'math_utils'
local List = require 'doubly_linked_list'


game = game or {}
game.touch = {}

game.UI = List.new()
function game.UI.initialize()
  game.UI:Clear()
  require('data_ui')
end

function game.UI.rectangle(params)
  DEBUGGER.line('added new rectangle')
  local rect = {}
  rect = params
  game.UI:add(rect)

  rect.contains = function(self, x, y)
    return utils.isInsideRect(x, y, self.x, self.y, self.x + self.width, self.y + self.height)
  end

  rect.draw = function(self)
    love.graphics.setColor(self.color)
    love.graphics.rectangle(self.drawMode, self.x, self.y, self.width, self.height) 
  end

  return rect
end

function game.UI.draw()
  game.UI:forEach(function(elem) 
    if not elem.stateMask or bit32.band(elem.stateMask, game.state) ~= 0 then
      elem:draw() 
    end
  end)
end

game.UI.deltaX = 0
game.UI.deltaY = 0
game.UI.scaleX = 1
game.UI.scaleY = 1
function game.UI.adjust(deltaX, deltaY, scaleX, scaleY)
  game.UI.deltaX = deltaX
  game.UI.deltaY = deltaY
  game.UI.scaleX = scaleX
  game.UI.scaleY = scaleY
end

function touchAction(x, y, actionName)
  local tx = (x - game.UI.deltaX) / game.UI.scaleX
  local ty = (y - game.UI.deltaY) / game.UI.scaleY
  game.UI:forEach(function(elem)
    if elem.stateMask and bit32.band(elem.stateMask, game.state) == 0 then return end
    if elem:contains(tx, ty) and elem[actionName] then
      elem[actionName](elem, tx, ty)
    end
  end)
end


function game.touch.pressed(x, y)
  touchAction(x, y, 'pressed')
end

function game.touch.moved(x, y, dx, dy)
  touchAction(x, y, 'moved')
end

function game.touch.released(x, y)
  touchAction(x, y, 'released')
end

