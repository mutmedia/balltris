//Image texture2
uniform float k; // From 0 to 1 representing how much of the animation is complete
const float height = 0.300;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
  color = pow(Texel(texture, texture_coords) * color, vec4(1.0/2.2));
  float gray = (color.r + color.g + color.b)/3.0;
  float p = (1.0-height) * screen_coords.y/love_ScreenSize.y;
  vec4 ret = vec4(0.0);
  if (k >= 0.0)
  {
    float k2 = k;
    if (p < k2-height)
    {
      ret = vec4(color);
    }
    else if (p < k2)
    {
      ret = vec4(vec3(gray)*0.5, color.a);
    }
  }
  else if (k < 0.0)
  {
    float k2 = -k;
    if (p > k2)
    {
      ret = vec4(color);
    }
    else if (p > k2 - height)
    {
      ret = vec4(vec3(gray)*0.5, color.a);
    }
  }
  return pow(ret, vec4(2.2));
}

