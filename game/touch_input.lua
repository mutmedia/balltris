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

function game.touch.pressed(x, y)
  game.UI:forEach(function(elem)
    if elem:contains(x, y) and elem.pressed then
      elem:pressed(x, y)
    end
  end)
end

function game.touch.moved(x, y, dx, dy)
  game.UI:forEach(function(elem)
    if elem:contains(x, y) and elem.moved then
      elem:moved(x, y, dx, dy)
    end
  end)
end

function game.touch.released(x, y)
  game.UI:forEach(function(elem)
    if elem:contains(x, y) and elem.released then
      elem:released(x, y, dx, dy)
    end
  end)
end

