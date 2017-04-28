#ifdef GL_ES
#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif
#endif

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

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
  vec4 c = vec4(0.0);
  c += vec4(11.108997) * Texel(texture, coordinate6b);
  c += vec4(43.936934) * Texel(texture, coordinate5b);
  c += vec4(135.335283) * Texel(texture, coordinate4b);
  c += vec4(324.652467) * Texel(texture, coordinate3b);
  c += vec4(606.530660) * Texel(texture, coordinate2b);
  c += vec4(882.496903) * Texel(texture, coordinate1b);
  c += vec4(1000.000000) * Texel(texture, coordinate0f);
  c += vec4(882.496903) * Texel(texture, coordinate1f);
  c += vec4(606.530660) * Texel(texture, coordinate2f);
  c += vec4(324.652467) * Texel(texture, coordinate3f);
  c += vec4(135.335283) * Texel(texture, coordinate4f);
  c += vec4(43.936934) * Texel(texture, coordinate5f);
  c += vec4(11.108997) * Texel(texture, coordinate6f);
  return c * vec4(0.199676) * color / 1000.0;
}
/*`
#ifdef GL_ES 
#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif
#endif

varying vec2 coordinate0;
varying vec2 coordinate1f;
varying vec2 coordinate1b;
varying vec2 coordinate2f;
varying vec2 coordinate2b;
varying vec2 coordinate3f;
varying vec2 coordinate3b;
varying vec2 coordinate4f;
varying vec2 coordinate4b;

const float weights[5] = float[](0.196380615234375, 0.2967529296875, 0.09442138671875, 0.0103759765625, 0.0002593994140625);

vec4 effect(vec4 color, Image texture, vec2 tc, vec2 _)
{
vec4 fragmentColor = Texel(texture, coordinate0) * weights[0];
fragmentColor += Texel(texture, coordinate1f) * weights[1];
fragmentColor += Texel(texture, coordinate1b) * weights[1];
fragmentColor += Texel(texture, coordinate2f) * weights[2];
fragmentColor += Texel(texture, coordinate2b) * weights[2];
fragmentColor += Texel(texture, coordinate3f) * weights[3];
fragmentColor += Texel(texture, coordinate3b) * weights[3];
fragmentColor += Texel(texture, coordinate4f) * weights[3];
fragmentColor += Texel(texture, coordinate4b) * weights[3];

return vec4(fragmentColor.rgb, 1.0);
}
 */
