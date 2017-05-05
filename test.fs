//Vertex Shader:
#ifdef GL_ES
#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif
#endif

varying vec2 coordinate2b;
varying vec2 coordinate1b;
varying vec2 coordinate0f;
varying vec2 coordinate1f;
varying vec2 coordinate2f;

uniform vec2 offset_direction;

vec4 position(mat4 transform_projection, vec4 vertex_position)
{
  coordinate2b = VertexTexCoord.xy + -3.230769 * offset_direction;
  coordinate1b = VertexTexCoord.xy + -1.384615 * offset_direction;
  coordinate0f = VertexTexCoord.xy + 0.000000 * offset_direction;
  coordinate1f = VertexTexCoord.xy + 1.384615 * offset_direction;
  coordinate2f = VertexTexCoord.xy + 3.230769 * offset_direction;
  return transform_projection * vertex_position;
}

//Pixel Shader:
#ifdef GL_ES
#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif
#endif

varying vec2 coordinate2b;
varying vec2 coordinate1b;
varying vec2 coordinate0f;
varying vec2 coordinate1f;
varying vec2 coordinate2f;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
  vec4 c = vec4(0.0);
  c += vec4(0.070270) * Texel(texture, coordinate2b);
  c += vec4(0.316216) * Texel(texture, coordinate1b);
  c += vec4(0.227027) * Texel(texture, coordinate0f);
  c += vec4(0.316216) * Texel(texture, coordinate1f);
  c += vec4(0.070270) * Texel(texture, coordinate2f);
  return c * color;
}
