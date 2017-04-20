uniform float direction;

const float SIGMA = 10.0;

vec4 effect(vec4 color, Image texture, vec2 tc, vec2 _)
{ 
  float support = max(1.0, floor(3.0*SIGMA + .5));
  float invSigma2 = 1.0 / SIGMA * SIGMA;
  float norm = 0.0;

  vec4 c = vec4(0.0f);
  for (float i = -support; i <=support; i++)
  {
    float coeff = exp(-0.5 * i * i * invSigma2);
    norm += coeff;
    c += vec4(coeff) * Texel(texture, tc + vec2(norm) * (direction > 0.0 ? vec2(1.0/love_ScreenSize.x, 0.0) : vec2(0.0, 1.0/love_ScreenSize.y)));
  }

  return c * vec4(norm > 0.0 ? 1.0/norm : 1.0) * color;
}

