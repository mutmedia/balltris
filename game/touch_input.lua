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
  game.UI:forEach(function(elem) elem:draw() end)
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

function game.touch.pressed(x, y)
  local tx = (x - game.UI.deltaX) / game.UI.scaleX
  local ty = (y - game.UI.deltaY) / game.UI.scaleY
  game.UI:forEach(function(elem)
    if elem:contains(tx, ty) and elem.pressed then
      elem:pressed(tx, ty)
    end
  end)
end

function game.touch.moved(x, y, dx, dy)
  local tx = (x - game.UI.deltaX) / game.UI.scaleX
  local ty = (y - game.UI.deltaY) / game.UI.scaleY
  game.UI:forEach(function(elem)
    if elem:contains(tx, ty) and elem.moved then
      elem:moved(tx, ty, dx, dy)
    end
  end)
end

function game.touch.released(x, y)
  local tx = (x - game.UI.deltaX) / game.UI.scaleX
  local ty = (y - game.UI.deltaY) / game.UI.scaleY
  game.UI:forEach(function(elem)
    if elem:contains(tx, ty) and elem.released then
      elem:released(tx, ty, dx, dy)
    end
  end)
end

