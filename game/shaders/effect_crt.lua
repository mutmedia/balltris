local CRTEffect = {}
function CRTEffect.new(params)
  local crt = {}
  crt._shader = love.graphics.newShader('shaders/scanlines.fs')

  crt._baseWidth = params.width
  crt._baseHeight = params.height

  crt._shader:send('pixel_size', EFFECT_CRT_PIXEL)
  crt._shader:send('opacity', EFFECT_CRT_OPACITY)
  crt._shader:send('center_fade', EFFECT_CRT_FADE)
  crt._shader:send('scanline_height', EFFECT_CRT_SCAN_HEIGHT)

  crt._canvas = love.graphics.newCanvas(self._baseWidth, self._baseHeight)
  setmetatable(crt, {__index=CRTEffect})
  return crt
end

function CRTEffect:apply(sourceCanvas, targetCanvas)
  local originalCanvas = love.graphics.getCanvas()
  local originalShader = love.graphics.getShader()
  local originalColor = {love.graphics.getColor()}


  love.graphics.setShader(self._shader)

  love.graphics.setCanvas(self._canvas)
  love.graphics.clear()
  love.graphics.setColor(255, 255, 255)
  love.graphics.draw(sourceCanvas)


  love.graphics.setCanvas(targetCanvas)
  love.graphics.clear()
  love.graphics.setColor(255, 255, 255)
  love.graphics.draw(self._canvas)

  love.graphics.setCanvas(originalCanvas)
  love.graphics.setShader(originalShader)
  love.graphics.setColor(originalColor)

end

return CRTEffect
