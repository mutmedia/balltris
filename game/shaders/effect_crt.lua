local CRTEffect = {}
function CRTEffect.New(params)
  local crt = {}
  crt._scanlineShader = love.graphics.newShader('shaders/scanlines.fs')
  crt._distortShader = love.graphics.newShader('shaders/barreldistort.fs')

  crt._baseWidth = params.width
  crt._baseHeight = params.height

  crt._distortShader:send('distortion', EFFECT_CRT_DISTORTION)
  crt._scanlineShader:send('pixel_size', EFFECT_CRT_PIXEL)
  crt._scanlineShader:send('opacity', EFFECT_CRT_OPACITY)
  crt._scanlineShader:send('center_fade', EFFECT_CRT_FADE)
  crt._scanlineShader:send('scanline_height', EFFECT_CRT_SCAN_HEIGHT)

  crt._canvas = love.graphics.newCanvas(crt._baseWidth, crt._baseHeight)
  setmetatable(crt, {__index=CRTEffect})
  return crt
end

function CRTEffect:apply(sourceCanvas, targetCanvas)
  local originalCanvas = love.graphics.getCanvas()
  local originalShader = love.graphics.getShader()
  local originalColor = {love.graphics.getColor()}


  love.graphics.setShader(self._scanlineShader)
-- TODO: remove
  self._scanlineShader:send('pixel_size', EFFECT_CRT_PIXEL)
  self._scanlineShader:send('opacity', EFFECT_CRT_OPACITY)
  self._scanlineShader:send('center_fade', EFFECT_CRT_FADE)
  self._scanlineShader:send('scanline_height', EFFECT_CRT_SCAN_HEIGHT)


  love.graphics.setCanvas(self._canvas)
  love.graphics.clear()
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(sourceCanvas)

  love.graphics.setShader(self._distortShader)
-- TODO: remove
  self._distortShader:send('distortion', EFFECT_CRT_DISTORTION)
  love.graphics.setCanvas(targetCanvas)
  love.graphics.clear()
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(self._canvas)

  love.graphics.setCanvas(originalCanvas)
  love.graphics.setShader(originalShader)
  love.graphics.setColor(originalColor)

end

return CRTEffect
