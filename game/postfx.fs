float rand(float n){return fract(sin(n) * 43758.5453123);}

vec3 hsv2rgb(vec3 c)
{
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
  vec4 screen_size = love_ScreenSize;

  vec4 textureColor = Texel(texture, texture_coords);
  vec2 point = screen_coords/screen_size.xy;

  vec3 color3 = vec3(textureColor);
  float h = fract(mix(-0.1, 0.5, point.y) + 1.0);
  vec3 color_mult = hsv2rgb(vec3(h, 0.3, 0.5));

  vec3 checkered = vec3(1.0);
  if (mod(floor(screen_coords.x/2.0 + 1000.0*point.y + 50.0 * rand(10.0*point.x + point.y)), 2.0) == 0.0) {
    checkered = vec3(0.90 + 0.08 * rand(10.0*point.x + point.y) * sin(3.0*rand(10.0*point.x + point.y) + 150.0 * point.x));
  }
  if (mod(floor(screen_coords.y/2.0 + 1000.0*point.x + 50.0 * rand(10.0*point.y + point.x)), 2.0) == 0.0) {
    checkered = vec3(0.90 + 0.08 * rand(10.0*point.y + point.x) * cos(3.0*rand(10.0*point.y + point.x) + 225.0 * point.y));
  } 

  return vec4(checkered * color_mult * color3, color.a);
}
