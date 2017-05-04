//Vertex Shader Generated:
#ifdef GL_ES
#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif
#endif
varying vec2 coordinate3b;
varying vec2 coordinate2b;
varying vec2 coordinate1b;
varying vec2 coordinate0f;
varying vec2 coordinate1f;
varying vec2 coordinate2f;
varying vec2 coordinate3f;
uniform vec2 offset_direction;

vec4 position(mat4 transform_projection, vec4 vertex_position)
{
  coordinate3b = VertexTexCoord.xy + -3.000000 * offset_direction;
  coordinate2b = VertexTexCoord.xy + -2.000000 * offset_direction;
  coordinate1b = VertexTexCoord.xy + -1.000000 * offset_direction;
  coordinate0f = VertexTexCoord.xy + 0.000000 * offset_direction;
  coordinate1f = VertexTexCoord.xy + 1.000000 * offset_direction;
  coordinate2f = VertexTexCoord.xy + 2.000000 * offset_direction;
  coordinate3f = VertexTexCoord.xy + 3.000000 * offset_direction;
  return transform_projection * vertex_position;
}

//Fragment Shader Generated:
#ifdef GL_ES
#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif
#endif
varying vec2 coordinate3b;
varying vec2 coordinate2b;
varying vec2 coordinate1b;
varying vec2 coordinate0f;
varying vec2 coordinate1f;
varying vec2 coordinate2f;
varying vec2 coordinate3f;
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
  vec4 c = vec4(0.0);
  c += vec4(11.108997) * Texel(texture, coordinate3b);
  c += vec4(135.335283) * Texel(texture, coordinate2b);
  c += vec4(606.530660) * Texel(texture, coordinate1b);
  c += vec4(1000.000000) * Texel(texture, coordinate0f);
  c += vec4(606.530660) * Texel(texture, coordinate1f);
  c += vec4(135.335283) * Texel(texture, coordinate2f);
  c += vec4(11.108997) * Texel(texture, coordinate3f);
  return c * vec4(0.399050) * color / 1000.0;
}
