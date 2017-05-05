function NewPalette(path)
  local imgdata = love.image.newImageData(path)
  local palette = {}
  for j=0,imgdata:getHeight()-1 do
    for i=0,imgdata:getWidth()-1 do
      palette[j*imgdata:getHeight() + i] = {imgdata:getPixel(i, j)}
    end
  end
  return palette
end

return NewPalette
