bit32 = require("bit") 

require 'math_utils'
local List = require 'doubly_linked_list'


UI = {}
UI = List.new()

function UI.initialize()
  UI:Clear()
  require('data_ui')
end

function UI.rectangle(params)
  DEBUGGER.line('added new rectangle')
  local rect = {}
  rect = params
  UI:add(rect)

  rect.contains = function(self, x, y)
    return utils.isInsideRect(x, y, self.x, self.y, self.x + self.width, self.y + self.height)
  end

  rect.draw = function(self)
    love.graphics.setColor(self.color)
    love.graphics.rectangle(self.drawMode, self.x, self.y, self.width, self.height) 
  end

  return rect
end

function UI.draw()
  UI:forEach(function(elem) 
    if not elem.stateMask or bit32.band(elem.stateMask, Game.state) ~= 0 then
      elem:draw() 
    end
  end)
end

UI.deltaX = 0
UI.deltaY = 0
UI.scaleX = 1
UI.scaleY = 1
function UI.adjust(deltaX, deltaY, scaleX, scaleY)
  UI.deltaX = deltaX
  UI.deltaY = deltaY
  UI.scaleX = scaleX
  UI.scaleY = scaleY
end

function UI.Action(x, y, actionName)
  local tx = (x - UI.deltaX) / UI.scaleX
  local ty = (y - UI.deltaY) / UI.scaleY
  UI:forEach(function(elem)
    if elem.stateMask and bit32.band(elem.stateMask, Game.state) == 0 then return end
    if elem:contains(tx, ty) and elem[actionName] then
      elem[actionName](elem, tx, ty)
    end
  end)
end

function UI.pressed(x, y)
  UI.Action(x, y, 'pressed')
end

function UI.moved(x, y, dx, dy)
  UI.Action(x, y, 'moved')
end

function UI.released(x, y)
  UI.Action(x, y, 'released')
end

return UI

