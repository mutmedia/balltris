varying vec2 coordinate6b;
varying vec2 coordinate5b;
varying vec2 coordinate4b;
varying vec2 coordinate3b;
varying vec2 coordinate2b;
varying vec2 coordinate1b;
varying vec2 coordinate0f;
varying vec2 coordinate1f;
varying vec2 coordinate2f;
varying vec2 coordinate3f;
varying vec2 coordinate4f;
varying vec2 coordinate5f;
varying vec2 coordinate6f;
uniform vec2 offset_direction;

vec4 position(mat4 transform_projection, vec4 vertex_position)
{
  coordinate6b = VertexTexCoord.xy + -6.000000 * offset_direction;
  coordinate5b = VertexTexCoord.xy + -5.000000 * offset_direction;
  coordinate4b = VertexTexCoord.xy + -4.000000 * offset_direction;
  coordinate3b = VertexTexCoord.xy + -3.000000 * offset_direction;
  coordinate2b = VertexTexCoord.xy + -2.000000 * offset_direction;
  coordinate1b = VertexTexCoord.xy + -1.000000 * offset_direction;
  coordinate0f = VertexTexCoord.xy + 0.000000 * offset_direction;
  coordinate1f = VertexTexCoord.xy + 1.000000 * offset_direction;
  coordinate2f = VertexTexCoord.xy + 2.000000 * offset_direction;
  coordinate3f = VertexTexCoord.xy + 3.000000 * offset_direction;
  coordinate4f = VertexTexCoord.xy + 4.000000 * offset_direction;
  coordinate5f = VertexTexCoord.xy + 5.000000 * offset_direction;
  coordinate6f = VertexTexCoord.xy + 6.000000 * offset_direction;
  return transform_projection * vertex_position;
}
/*
#ifdef GL_ES 
#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif
#endif

uniform vec2 offset_direction;

varying vec2 coordinate0;
varying vec2 coordinate1f;
varying vec2 coordinate2f;
varying vec2 coordinate1b;
varying vec2 coordinate2b;
varying vec2 coordinate3f;
varying vec2 coordinate3b;
varying vec2 coordinate4f;
varying vec2 coordinate4b;

const float offsets[4] = float[](1.411764705882353, 3.2941176470588234, 5.176470588235294, 7.0588235294117645);

vec4 position(mat4 transform_projection, vec4 vertex_position)
{
vec2 offset1 = offsets[0] * offset_direction;
vec2 offset2 = offsets[1] * offset_direction;
vec2 offset3 = offsets[2] * offset_direction;
vec2 offset4 = offsets[3] * offset_direction;

coordinate0 = VertexTexCoord.xy;
coordinate1f = VertexTexCoord.xy + offset1;
coordinate1b = VertexTexCoord.xy - offset1;
coordinate2f = VertexTexCoord.xy + offset2;
coordinate2b = VertexTexCoord.xy - offset2;
coordinate3f = VertexTexCoord.xy + offset3;
coordinate3b = VertexTexCoord.xy - offset3;
coordinate4f = VertexTexCoord.xy + offset4;
coordinate4b = VertexTexCoord.xy - offset4;

return transform_projection * vertex_position;
}
 */
