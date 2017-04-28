-- TODO: make this use the more efficient pascal triangle thing
function GaussianBlurShader(sigma)
  support = math.max(1, math.floor(3*sigma + .5))
  local invSigma2 = sigma > 0 and 1/(sigma*sigma) or 1
  local norm  = 0

  local defines = [[
    #ifdef GL_ES 
    #ifdef GL_FRAGMENT_PRECISION_HIGH
    precision highp float;
    #else
    precision mediump float;
    #endif
    #endif
  ]]
  local varyings = ''

  local vertshader = [[
    uniform vec2 offset_direction;

    vec4 position(mat4 transform_projection, vec4 vertex_position)
    {
  ]]



  local fragshader = [[
    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
    {
      vec4 c = vec4(0.0);
      ]]

  for i = -support, support do
    local coef = math.exp(-0.5 * i * i * invSigma2)
    norm = norm + coef
    fragshader = fragshader..string.format('c += vec4(%f) * Texel(texture, coordinate%d%s);\n', 1000 * coef, math.abs(i), i < 0 and 'b' or 'f')
    vertshader = vertshader..string.format('coordinate%d%s = VertexTexCoord.xy + %f * offset_direction;\n', math.abs(i), i < 0 and 'b' or 'f', i)
    varyings = varyings..string.format('varying vec2 coordinate%d%s;\n', math.abs(i), i < 0 and 'b' or 'f')
  end

  fragshader = fragshader..string.format('return c * vec4(%f) * color / 1000.0;\n}', norm > 0 and 1/norm or 1)
  vertshader = vertshader..'return transform_projection * vertex_position;\n}'


  fragshader = defines..varyings..fragshader
  vertshader = defines..varyings..vertshader

  print('Vertex Shader Generated:\n'..vertshader)
  print('Pixel Shader Generated:\n'..fragshader)

  return love.graphics.newShader(vertshader, fragshader)
end

return GaussianBlurShader
