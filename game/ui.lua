require 'game_debug'

local bit32 = require("bit") 

require 'data_constants'

require 'math_utils'
local List = require 'doubly_linked_list'


UI = {
  _layers = {},
}

function UI.object(params)
  local obj = params

  obj.x = (obj.x + BASE_SCREEN_WIDTH) % BASE_SCREEN_WIDTH
  obj.y = (obj.y + BASE_SCREEN_HEIGHT) % BASE_SCREEN_HEIGHT

  table.insert(UI._layers[obj.layer], obj)
  obj._state = {
    pressed = false,
    inside = false,
  }
  obj._lastState = {}

  return obj
end


function UI.rectangle(params)
  local rect = UI.object(params)

  rect.contains = function(self, x, y)
    return utils.isInsideRect(x, y, self.x - self.width/2, self.y - self.height/2, self.x + self.width/2, self.y + self.height/2)
  end

  rect.draw = function(self)
    love.graphics.setColor(self.color or {0, 0, 0, 0})
    love.graphics.rectangle(
      'fill',
      self.x - self.width/2,
      self.y - self.height/2,
      self.width,
      self.height) 
    if self.lineWidth then
      love.graphics.setColor(self.lineColor or {0, 0, 0})
      love.graphics.setLineWidth(self.lineWidth)
      love.graphics.rectangle(
        'line',
        self.x - self.width/2,
        self.y - self.height/2,
        self.width,
        self.height) 
    end
  end

  return rect
end

function UI.text(params)
  local text = UI.object(params)

  text.contains = function(self, x, y)
    return false
  end

  text.draw = function(self)
    love.graphics.setColor(self.color or {0, 0, 0})
    love.graphics.setFont(self.font)
    love.graphics.printf(
      self.getText(),
      self.x - self.width/2,
      self.y,
      self.width,
      'center',
      self.orientation,
      self.scale,
      self.scale,
      self.offsetX,
      self.offsetY)
  end

  return rect
end

function UI.button(params)
  local btn = UI.object(params)

  btn.contains = function(self, x, y)
    return utils.isInsideRect(x, y, self.x - self.width/2, self.y - self.height/2, self.x + self.width/2, self.y + self.height/2)
  end

  btn.draw = function(self)
    love.graphics.setColor(self.color or {0, 0, 0, 0})
    love.graphics.rectangle(
      'fill',
      self.x - self.width/2,
      self.y - self.height/2,
      self.width,
      self.height) 
    if self.lineWidth then
      love.graphics.setColor(self.lineColor or {0, 0, 0})
      love.graphics.setLineWidth(self.lineWidth)
      love.graphics.rectangle(
        'line',
        self.x - self.width/2,
        self.y - self.height/2,
        self.width,
        self.height) 
    end

    love.graphics.setColor(self.textColor or {0, 0, 0})
    love.graphics.setFont(self.font)
    love.graphics.printf(
      self.getText(),
      self.x - self.width/2,
      self.y - self.height/4, -- TODO: make this shift based on font height
      self.width,
      'center',
      self.orientation,
      1,
      1,
      self.offsetX,
      self.offsetY)
  end
end


function UI.initialize()
  UI._layers = {}
  for i=1,#GAME_LAYERS do
    UI._layers[GAME_LAYERS[i]] = {}
  end
  require('data_ui')
end

function UI.draw()
  for i=#GAME_LAYERS,1,-1 do
    for _, elem in ipairs(UI._layers[GAME_LAYERS[i]]) do
      if not elem.condition or elem.condition() then
        elem:draw() 
      end
    end
  end
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

  if actionName == 'pressed' then
    UI._pressed = true
  elseif actionName == 'released' then
    UI._pressed = false
  end

  for i=#GAME_LAYERS,1,-1 do
    for _, elem in ipairs(UI._layers[GAME_LAYERS[i]]) do
      elem._lastState.pressed = elem._state.pressed
      elem._lastState.inside = elem._state.inside
      if not elem.condition or elem.condition() then
        if elem:contains(tx, ty) then
          if actionName == 'pressed' then
            elem._state.pressed = true
            elem._state.inside = true
          elseif actionName == 'moved' and UI._pressed then
            elem._state.inside = true
          elseif actionName == 'released' then
            elem._state.pressed = false
            elem._state.inside = false
          end
        else 
          elem._state.inside = false
        end

        if elem._state.inside and not elem._lastState.inside then
          if elem.onEnter then elem:onEnter(tx, ty) end
        elseif elem._lastState.inside and not elem._state.inside then
          if elem.onExit then elem:onExit(tx, ty) end
        elseif elem._lastState.inside and elem._state.inside then
          if elem.onMove then elem:onMove(tx, ty) end
        end

        if not elem._state.pressed and elem._lastState.pressed then
          if elem.onPress then elem:onPress(tx, ty) end
        end
      end
    end
  end
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

