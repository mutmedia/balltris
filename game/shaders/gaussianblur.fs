varying mediump vec2 coordinate0;
varying mediump vec2 coordinate1f;
varying mediump vec2 coordinate2f;
varying mediump vec2 coordinate1b;
varying mediump vec2 coordinate2b;

// const float weight[3] = float[]( 0.2270270270, 0.3162162162, 0.0702702703 );

vec4 effect(vec4 color, Image texture, vec2 tc, vec2 _)
{
  vec4 fragmentColor = Texel(texture, coordinate0) * 0.2270270270;
  fragmentColor += Texel(texture, coordinate1f) * 0.3162162162;
  fragmentColor += Texel(texture, coordinate1b) * 0.3162162162;
  fragmentColor += Texel(texture, coordinate2f) * 0.0702702703;
  fragmentColor += Texel(texture, coordinate2b) * 0.0702702703;

  return vec4(fragmentColor.rgb, 1.0);
}
