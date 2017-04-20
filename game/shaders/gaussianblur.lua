function GaussianBlurShader(sigma)
  support = math.max(1, math.floor(3*sigma + .5))
  local invSigma2 = sigma > 0 and 1/(sigma*sigma) or 1
  local norm  = 0

  local shader = [[
    uniform vec2 direction;

    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
    {
      vec4 c = vec4(0.0);
      ]]

  for i = -support, support do
    local coef = math.exp(-0.5 * i * i * invSigma2)
    norm = norm + coef
    shader = shader..string.format('c += vec4(%f) * Texel(texture, texture_coords + vec2(%f) * direction);\n', coef, i)
  end

  shader = shader..string.format('return c * vec4(%f) * color;\n}', norm > 0 and 1/norm or 1)

  return love.graphics.newShader(shader)
end

return GaussianBlurShader
