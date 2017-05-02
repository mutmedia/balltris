-- TODO: make this use the more efficient pascal triangle thing
function GaussianBlurShader(sigma)
  support = math.max(1, math.floor(3*sigma + .5))
  local invSigma2 = sigma > 0 and 1/(sigma*sigma) or 1
  local norm  = 0

  local vertshader = {}
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

  local vertshaderfunc = [[
    uniform vec2 offset_direction;

    vec4 position(mat4 transform_projection, vec4 vertex_position)
    {
  ]]

  local fragshaderfunc = [[
    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
    {
      vec4 c = vec4(0.0);
      ]]

  table.insert(vertshader, defines)
  table.insert(fragshader, defines)
  vertshader[2 + 2*support + 1] = vertshaderfunc
  fragshader[2 + 2*support + 1] = fragshaderfunc

  local varyings = {}
  for i = -support, support do
    local coef = math.exp(-0.5 * i * i * invSigma2)
    norm = norm + coef
    vertshader[2 + i + support] = string.format('varying vec2 coordinate%d%s;\n', math.abs(i), i < 0 and 'b' or 'f')
    fragshader[2 + i + support] = string.format('varying vec2 coordinate%d%s;\n', math.abs(i), i < 0 and 'b' or 'f')
    vertshader[2 + i + support + 2*support + 2] = string.format('coordinate%d%s = VertexTexCoord.xy + %f * offset_direction;\n', math.abs(i), i < 0 and 'b' or 'f', i)
    fragshader[2 + i + support + 2*support + 2] = string.format('c += vec4(%f) * Texel(texture, coordinate%d%s);\n', 1000 * coef, math.abs(i), i < 0 and 'b' or 'f')
  end

  table.insert(fragshader, string.format('return c * vec4(%f) * color / 1000.0;\n}', norm > 0 and 1/norm or 1))
  table.insert(vertshader, 'return transform_projection * vertex_position;\n}')


  --print('Vertex Shader Generated:\n'..table.concat(vertshader))
  --print('Pixel Shader Generated:\n'..table.concat(fragshader))

  return love.graphics.newShader(table.concat(vertshader), table.concat(fragshader))
end

return GaussianBlurShader
