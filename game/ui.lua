local bit32 = require("bit") 

require 'lib/math_utils'
local List = require 'lib/doubly_linked_list'
local Load = require 'lib/load'

require 'data_constants'

UI = {
  _layers = {},
  DEFAULT_FONT_COLOR = 2,
}

function DrawCoroutine(elem)
  return function()
    while true do
      -- If element does not satisfy condition to show up, yield
      while not elem:condition() do
        coroutine.yield()
      end

      -- Do transition in animation
      local initialTime = Game.totalTime
      if elem.transitionInTime then
        while Game.totalTime - initialTime < elem.transitionInTime do
          if elem.transitionIn then
            elem.draw(elem:_transitionIn((Game.totalTime - initialTime)/elem.transitionInTime)) -- draws the transitionIn element
          end
          coroutine.yield()
        end
      end

      elem._isInteractable = true
      while elem:condition() do
        elem:draw()
        coroutine.yield()
      end

      elem._isInteractable = false
      -- Do transition out animation
      local initialTime = Game.totalTime
      if elem.transitionOutTime then
        while Game.totalTime - initialTime < elem.transitionOutTime do
          if elem.transitionOut then
            elem.draw(elem:_transitionOut((Game.totalTime - initialTime)/elem.transitionOutTime)) -- draws the transitionIn element
          else
            elem:draw()
          end
          coroutine.yield()
        end
      end
    end
  end
end

function UI.object(params)
  local obj = params

  obj._isInteractable = false

  obj.visibility = obj.visibility or 1
  obj.x = (obj.x and (obj.x + BASE_SCREEN_WIDTH) % BASE_SCREEN_WIDTH) or 0
  obj.y = (obj.y and (obj.y + BASE_SCREEN_HEIGHT) % BASE_SCREEN_HEIGHT) or 0

  obj.contains = params.contains or function(self, x, y)
    return false
  end

  obj.anchor = obj.anchor or {x=0, y=0}

  obj.transitionInTime = obj.transitionInTime or obj.transitionTime or nil
  obj.transitionOutTime = obj.transitionOutTime or obj.transitionTime or nil

  if obj.shader then
    obj.uniforms = obj.uniforms or {}
  end

  obj._drawCoroutine = coroutine.create(DrawCoroutine(obj))
  if obj.transitionIn then
    obj._transitionIn = function(self, p)
      local diff = self:transitionIn(p) or {}
      local clone = {}
      for k, v in pairs(self) do
        if diff[k] then
          clone[k] = diff[k]
        else
          clone[k] = v
        end
      end
      return clone
    end
  end
  if obj.transitionOut then
    obj._transitionOut = function(self, p)
      local diff = self:transitionOut(p) or {}
      local clone = {}
      for k, v in pairs(self) do
        if diff[k] then
          clone[k] = diff[k]
        else
          clone[k] = v
        end
      end
      return clone
    end
  end


  if not obj.draw then
    print(string.format('UI ERROR: Drawable %s has no draw function', obj.name or 'unnamed'))
  else
    obj._draw = obj.draw
    obj.draw = function(self)
      if self.shader then
        love.graphics.setShader(self.shader)
        for name, value in pairs(self.uniforms) do
          self.shader:send(name, value)
        end
      end
      obj._draw(self)
      if self.shader then
        love.graphics.setShader()
      end
    end
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

  --print('UI: Loaded '..obj.name)

end


function UI.rectangle(params)
  local rect = params

  if not rect.width then
    print(string.format('UI ERROR: Rectangle %s has no width.', rect.name))
    rect.width = 0
  end
  if not rect.height then
    print(string.format('UI ERROR: Rectangle %s has no height.', rect.name))
    rect.height = 0
  end

  rect.contains = function(self, x, y)
    return math.isInsideRect(x, y, self.x - self.width/2, self.y - self.height/2, self.x + self.width/2, self.y + self.height/2)
  end

  rect.draw = function(self)
    self.color = (self.getColor and self:getColor()) or self.color
    if self.color then
      UI.setColor(self.color, self.visibility)
      love.graphics.rectangle(
        'fill',
        self.x - (self.width/2) * (1 - self.anchor.x),
        self.y - (self.height/2) * (1 - self.anchor.y),
        self.width,
        self.height,
        RECTANGLE_BORDER_RADIUS) 
    end
    if self.lineWidth or self.lineColor then
      UI.setColor(self.lineColor, self.visibility)
      love.graphics.setLineWidth(self.lineWidth or 1)
      love.graphics.rectangle(
        'line',
        self.x - (self.width/2) * (1 - self.anchor.x),
        self.y - (self.height/2) * (1 - self.anchor.y),
        self.width,
        self.height,
        RECTANGLE_BORDER_RADIUS)
    end
  end

  UI.object(rect)
end

function UI.text(params)
  local text = params

  if not text.color and not text.getColor then
    print(string.format('UI ERROR: Object %s has no text color', text.name or 'unnamed'))
  end

  text.draw = function(self)
    self.color = (self.getColor and self:getColor()) or self.color
    UI.setColor(self.color, self.visibility)
    love.graphics.setFont(self.font)
    love.graphics.printf(
      self:getText(),
      self.x - (self.width/2) * (1 - self.anchor.x),
      self.y - (self.font:getHeight()/2) * (1 - self.anchor.y),
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

  if (btn.text or btn.getText) and not btn.textColor and not btn.getTextColor and not btn.lineColor and not btn.getLineColor then
    print(string.format('UI ERROR: Object %s has no text color', btn.name or 'unnamed'))
  end

  btn.contains = function(self, x, y)
    return math.isInsideRect(x, y, self.x - self.width/2, self.y - self.height/2, self.x + self.width/2, self.y + self.height/2)
  end

  btn.draw = function(self)
    --TODO: make getXXX for everything
    self.color = (self.getColor and self:getColor()) or self.color
    if self.color then
      UI.setColor(self.color, self.visibility)
      love.graphics.rectangle(
        'fill',
        self.x - (self.width/2) * (1 - self.anchor.x),
        self.y - (self.height/2) * (1 - self.anchor.y),
        self.width,
        self.height,
        RECTANGLE_BORDER_RADIUS) 
    end
    local lineColor = (self.getLineColor and self:getLineColor()) or self.lineColor
    if self.lineWidth and lineColor then
      UI.setColor(lineColor, self.visibility)
      love.graphics.setLineWidth(self.lineWidth)
      love.graphics.rectangle(
        'line',
        self.x - (self.width/2) * (1 - self.anchor.x),
        self.y - (self.height/2) * (1 - self.anchor.y),
        self.width,
        self.height,
        RECTANGLE_BORDER_RADIUS)
    end

    local textColor = (self.getTextColor and self:getTextColor()) or self.textColor or lineColor
    UI.setColor(textColor, self.visibility)
    love.graphics.setFont(self.font)
    local text = self:getText()
    local _, lineCount = text:gsub('\n', '\n')
    lineCount = (lineCount or 0)
    --print(text)
    --print(string.byte(text:sub(-1, -1)))
    if text:sub(-1, -1) ~= "\n" then
      lineCount = lineCount + 1
    end
    love.graphics.printf(
      text,
      self.x - (self.width/2) * (1 - self.anchor.x),
      self.y - ((self.font:getHeight() * lineCount)/2) * (1 - self.anchor.y),
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

function UI.GetColor(number)
  return {
    UI._palette[number][1],
    UI._palette[number][2],
    UI._palette[number][3],
    UI._palette[number][4],
  }
end

function UI.setColor(index, visibility)
  --print('Using UI print')
  if index then
    visibility = visibility or 1
    local r, g, b, a = unpack(UI._palette[index])
    love.graphics.setColor(r, g, b, math.pow(math.pow(a, 1/2.2)*visibility, 2.2))
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

  --print('drawWidth'..drawWidth)
  --print('drawHeight'..drawHeight)

  UI.deltaX = (screenWidth-drawWidth)/2
  UI.deltaY = (screenHeight-drawHeight)
  UI.scaleX = drawWidth/BASE_SCREEN_WIDTH
  UI.scaleY = drawHeight/BASE_SCREEN_HEIGHT 

  --print('UI.deltaX'..UI.deltaX)
  --print('UI.deltaY'..UI.deltaY)
  --print('UI.scaleX'..UI.scaleX)
  --print('UI.scaleY'..UI.scaleY)

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
    UI._loveSetColor(0, 0, 0, 1)
  end
  ]]--
end

function UI.draw()
  for i=1,#GAME_LAYERS do
    for _, elem in ipairs(UI._layers[GAME_LAYERS[i]]) do
      coroutine.resume(elem._drawCoroutine)
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
      if elem._isInteractable then
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

