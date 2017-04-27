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
