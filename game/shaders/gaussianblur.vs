uniform vec2 offset_direction;

varying mediump vec2 coordinate0;
varying mediump vec2 coordinate1f;
varying mediump vec2 coordinate2f;
varying mediump vec2 coordinate1b;
varying mediump vec2 coordinate2b;

vec4 position(mat4 transform_projection, vec4 vertex_position)
{
  vec2 offset1 = 1.3846153846 * offset_direction;
  vec2 offset2 = 3.2307692308 * offset_direction;

  coordinate0 = VertexTexCoord.xy;
  coordinate1f = VertexTexCoord.xy + offset1;
  coordinate1b = VertexTexCoord.xy - offset1;
  coordinate2f = VertexTexCoord.xy + offset2;
  coordinate2b = VertexTexCoord.xy - offset2;

  return transform_projection * vertex_position;
}
