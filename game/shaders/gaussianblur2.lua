-- TODO: make this use the more efficient pascal triangle thing
function GaussianBlurShader(sigma)
  support = math.max(1, math.floor(3*sigma + .5))
  local invSigma2 = sigma > 0 and 1/(sigma*sigma) or 1
  local norm  = 0

  local fragshader = {}

  local defines = [[
    #ifdef GL_ES 
    #ifdef GL_FRAGMENT_PRECISION_HIGH
    precision highp float;
    #else
    precision mediump float;
    #endif
    #endif
  ]]

  table.insert(fragshader, defines)

  
  table.insert(fragshader, [[
    uniform vec2 offset_direction;

    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
    {
      vec4 c = vec4(0.0);
      ]])

  for i = -support, support do
    local coef = math.exp(-0.5 * i * i * invSigma2)
    norm = norm + coef
    local newColor = string.format('c += vec4(%f) * Texel(texture, texture_coords + vec2(%f) * offset_direction);\n', coef * 1000, i)
    table.insert(fragshader, newColor)
  end

  table.insert(fragshader, string.format('return c * vec4(%f) * color;\n}', norm > 0 and 1/(norm*1000) or 1))

  --print('Pixel Shader Generated:\n'..fragshader)

  return love.graphics.newShader(table.concat(fragshader))
end

return GaussianBlurShader
