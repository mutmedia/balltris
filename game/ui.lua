local bit32 = require("bit") 

require 'math_utils'
local List = require 'doubly_linked_list'
local Load = require 'load'

require 'data_constants'


UI = {
  _layers = {},
  DEFAULT_FONT_COLOR = 2,
}

function UI.object(params)
  local obj = params

  obj.x = (obj.x and (obj.x + BASE_SCREEN_WIDTH) % BASE_SCREEN_WIDTH) or 0
  obj.y = (obj.y and (obj.y + BASE_SCREEN_HEIGHT) % BASE_SCREEN_HEIGHT) or 0

  obj.contains = params.contains or function(self, x, y)
    return false
  end

  if not params.draw then
    print(string.format('UI ERROR: Drawable %s has no draw function', obj.name or 'unnamed'))
  end

  if not obj.layer then
    print(string.format('UI ERROR: Object %s has no layer.', obj.name or 'unnamed'))
  end

  if not obj.condition then
    print(string.format('UI ERROR: Object %s has no display condition.', obj.name or 'unnamed'))
  end

  table.insert(UI._layers[obj.layer], obj)
  obj._state = {
    pressed = false,
    inside = false,
  }
  obj._lastState = {}

  print('UI: Loaded '..obj.name)

end


function UI.rectangle(params)
  local rect = params

  rect.contains = function(self, x, y)
    return utils.isInsideRect(x, y, self.x - self.width/2, self.y - self.height/2, self.x + self.width/2, self.y + self.height/2)
  end

  rect.draw = function(self)
    if self.color then
      UI.setColor(self.color)
      love.graphics.rectangle(
        'fill',
        self.x - self.width/2,
        self.y - self.height/2,
        self.width,
        self.height) 
    end
    if self.lineWidth or self.lineColor then
      UI.setColor(self.lineColor)
      love.graphics.setLineWidth(self.lineWidth or 1)
      love.graphics.rectangle(
        'line',
        self.x - self.width/2,
        self.y - self.height/2,
        self.width,
        self.height) 
    end
  end

  UI.object(rect)
end

function UI.text(params)
  local text = params

  if not text.color then
    print(string.format('UI ERROR: Object %s has no text color', text.name or 'unnamed'))
  end

  text.draw = function(self)
    UI.setColor(self.color)
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

  UI.object(text)
end

function UI.button(params)
  local btn = params

  if not btn.textColor then
    print(string.format('UI ERROR: Object %s has no text color', btn.name or 'unnamed'))
  end

  btn.contains = function(self, x, y)
    return utils.isInsideRect(x, y, self.x - self.width/2, self.y - self.height/2, self.x + self.width/2, self.y + self.height/2)
  end

  btn.draw = function(self)
    if self.color then
      UI.setColor(self.color)
      love.graphics.rectangle(
        'fill',
        self.x - self.width/2,
        self.y - self.height/2,
        self.width,
        self.height) 
    end
    if self.lineWidth and self.lineColor then
      UI.setColor(self.lineColor)
      love.graphics.setLineWidth(self.lineWidth)
      love.graphics.rectangle(
        'line',
        self.x - self.width/2,
        self.y - self.height/2,
        self.width,
        self.height) 
    end

    UI.setColor(self.textColor)
    love.graphics.setFont(self.font)
    love.graphics.printf(
      self.getText(),
      self.x - self.width/2,
      self.y - self.font:getHeight()/2, -- TODO: make this shift based on font height
      self.width,
      'center',
      self.orientation,
      1,
      1,
      self.offsetX,
      self.offsetY)
  end

  UI.object(btn)
end

function UI.setColor(index)
  --print('Using UI print')
  if index then
    love.graphics.setColor(UI._palette[index])
  else
    print('Index: ', index)
    error('cant set to a color not in the palette')
  end
end


function UI.setFiles(...)
  -- TODO: Make some error checking here
  UI.files = {...}
end

UI._loveSetColor = love.graphics.setColor
function UI.initialize(palette)
  print('UI: Initializing')
  -- Adjust to current screen size
  local screenWidth, screenHeight = love.window.getMode()
  local aspectRatio = screenWidth/screenHeight
  local drawWidth, drawHeight
  if aspectRatio > ASPECT_RATIO then
    drawHeight = screenHeight
    drawWidth = drawHeight * ASPECT_RATIO
  else
    drawWidth = screenWidth
    drawHeight = drawWidth / ASPECT_RATIO
  end

  UI.deltaX = (screenWidth-drawWidth)/2
  UI.deltaY = (screenHeight-drawHeight)
  UI.scaleX = drawWidth/BASE_SCREEN_WIDTH
  UI.scaleY = drawHeight/BASE_SCREEN_HEIGHT 

  UI._palette = palette

  UI._layers = {}
  for i=1,#GAME_LAYERS do
    UI._layers[GAME_LAYERS[i]] = {}
  end
  Load.luafiles(unpack(UI.files))


  -- Overloading setColor with params to make sure its not being used
  --[[ Uncomment to test if love.setColor is being used
  love.graphics.setColor = function(r, g, b, a)
    if r or g or b or a then
      print('UI WARN: Should not be using default setColor')
      UI._loveSetColor(r, g, b, a)
      return
    end
    UI._loveSetColor(0, 0, 0, 255)
  end
  ]]--
end

function UI.draw()
  for i=1,#GAME_LAYERS do
    for _, elem in ipairs(UI._layers[GAME_LAYERS[i]]) do
      if elem:condition() then
        --print('drawing UI element: '..elem.name)
        elem:draw() 
      end
    end
  end
end


function Action(x, y, actionName)
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
  Action(x, y, 'pressed')
end

function UI.moved(x, y, dx, dy)
  Action(x, y, 'moved')
end

function UI.released(x, y)
  Action(x, y, 'released')
end

return UI

