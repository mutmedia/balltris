GaussianBlurEffect = {
}

function GaussianBlurEffect.new(params)
  local gbe = {}
  gbe._shaderloader = require('shaders/gaussianblur')
  gbe._baseWidth = params.width
  gbe._baseHeight = params.height
  setmetatable(gbe, {__index=GaussianBlurEffect})
  gbe:setSigma(params.sigma)
  gbe:setScale(params.scale)
  return gbe
end

function GaussianBlurEffect:setSigma(newSigma)
  self._sigma = newSigma
  self._shader = self._shaderloader(newSigma)
end

function GaussianBlurEffect:setScale(newScale)
  self._scale = newScale
  self._canvasH = love.graphics.newCanvas(self._baseWidth/newScale, self._baseHeight/newScale)
  self._canvasV = love.graphics.newCanvas(self._baseWidth/newScale, self._baseHeight/newScale)
end

function GaussianBlurEffect:apply(sourceCanvas, targetCanvas)
  --print(''..self._scale..' '..self._sigma)
  
  local originalCanvas = love.graphics.getCanvas()
	local originalShader = love.graphics.getShader()
	local originalColor = {love.graphics.getColor()}

  love.graphics.setShader(self._shader)

  love.graphics.setBlendMode('alpha', 'premultiplied')

  love.graphics.setCanvas(self._canvasH)
  love.graphics.clear()
  love.graphics.setColor(255, 255, 255)
  self._shader:send('offset_direction', {1 / love.graphics.getWidth(), 0})
  love.graphics.draw(sourceCanvas, 0, 0, 0, 1 / self._scale)

  love.graphics.setCanvas(self._canvasV)
  love.graphics.clear()
  love.graphics.setColor(255, 255, 255)
  self._shader:send('offset_direction', {0, 1 / love.graphics.getHeight()})
  love.graphics.draw(self._canvasH)

  love.graphics.setCanvas(targetCanvas)
  love.graphics.clear()
  love.graphics.setColor(255, 255, 255)
  love.graphics.draw(self._canvasV, 0, 0, 0, self._scale)

  love.graphics.setCanvas(originalCanvas)
	love.graphics.setShader(originalShader)
	love.graphics.setColor(originalColor)
  
end

return GaussianBlurEffect
