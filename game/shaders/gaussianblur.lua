local print = function() end

PTLookup = {}

function Factorial(n)
  return n == 0 and 1 or n * Factorial(n-1)
end

function PT(n, k)
  local v = Factorial(n)/(Factorial(k)*Factorial(n-k))
  return v
end

function PTLine(n)
  local line = {}
  for k=0,n do
    line[k] = PT(n, k)
  end
  return line
end

-- TODO: make this use the more efficient pascal triangle thing
function GaussianBlurShader(taps)
  local offsetsd = {}
  local weightsd = {}
  local taps = taps * 2 + 1
  local n = taps + 4 - 1
  local offsets = math.floor(taps/2)
  local lineSum = math.pow(2, n) - 2 - 2*PT(n, 1)

  for k=0,offsets do
    local x = math.floor(n/2) - k
    offsetsd[k+1] = k
    weightsd[k+1] = PT(n, x)/lineSum
    print(offsetsd[k+1], weightsd[k+1])
  end

  local offsetsl = {offsetsd[1]}
  local weightsl = {weightsd[1]}

  print(offsetsl[1], weightsl[1])
  for k=1,offsets/2 do
    weightsl[k+1] = weightsd[2*k] + weightsd[2*k+1]
    offsetsl[k+1] = (offsetsd[2*k] * weightsd[2*k] + offsetsd[2*k+1] * weightsd[2*k+1])/weightsl[k+1]
    print(offsetsl[k+1], weightsl[k+1])
  end

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
  vertshader[2 + offsets + 1] = vertshaderfunc
  fragshader[2 + offsets + 1] = fragshaderfunc

  local varyings = {}
  for i = -offsets/2, offsets/2 do
    local ai = math.abs(i)
    local si = i < 0 and -1 or 1
    vertshader[2 + i + offsets/2] = string.format('varying vec2 coordinate%d%s;\n', math.abs(i), i < 0 and 'b' or 'f')
    fragshader[2 + i + offsets/2] = string.format('varying vec2 coordinate%d%s;\n', math.abs(i), i < 0 and 'b' or 'f')
    vertshader[2 + i + offsets/2 + offsets + 2] = string.format('coordinate%d%s = VertexTexCoord.xy + %f * offset_direction;\n', ai, i < 0 and 'b' or 'f', si * offsetsl[ai + 1])
    fragshader[2 + i + offsets/2 + offsets + 2] = string.format('c += vec4(%f) * Texel(texture, coordinate%d%s);\n', weightsl[ai+1], ai, i < 0 and 'b' or 'f')
  end

  table.insert(fragshader, string.format('return c * color;\n}'))
  table.insert(vertshader, 'return transform_projection * vertex_position;\n}')


  print('Vertex Shader Generated:\n'..table.concat(vertshader))
  print('Pixel Shader Generated:\n'..table.concat(fragshader))

  return love.graphics.newShader(table.concat(vertshader), table.concat(fragshader))
end

return GaussianBlurShader
