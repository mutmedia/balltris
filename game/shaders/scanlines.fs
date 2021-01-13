#define PI (3.14159265)

uniform float pixel_size;
uniform float opacity;
uniform float center_fade;
uniform float scanline_height;

vec2 To11Coord(vec2 point)
{
  point.x = (point.x) * 2.0 - 1.0;
  point.y = (point.y) * -2.0 + 1.0;

  return point;
}

vec4 desaturate(vec4 color, float amount)
{
    vec4 gray = vec4(dot(vec4(0.2126,0.7152,0.0722,0.2), color));
    return vec4(mix(color, gray, amount));
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
  vec2 uv = (texture_coords);
  vec4 c = pow(Texel(texture, uv), vec4(2.2));

  float current_pixel_v = screen_coords.y / pixel_size;
  float scanline_is_active = cos(current_pixel_v * 2.0 * PI) - 1.0 + scanline_height * 3.0;

  if (scanline_is_active > 1.0) {
    scanline_is_active = 1.0;
  }

  vec2 fade_coords;
  fade_coords.x = 0.0;
  fade_coords.y = (uv.y) * -2.0 + 1.0;
  float fade_value = ((1.0 - abs(fade_coords.x)) + (1.0 - abs(fade_coords.y))) / 2.0;
  scanline_is_active -= fade_value * center_fade;

  if (scanline_is_active < 0.0) {
    scanline_is_active = 0.0;
  }
  // eh, just implement as lowering alpha for now
  // see if we should be modifying rgb values instead
  // possibly by making it darker and less saturated in the scanlines?
  c = desaturate(c, scanline_is_active * 0.07);
  c.r = c.r - (scanline_is_active * opacity);
  c.g = c.g - (scanline_is_active * opacity);
  c.b = c.b - (scanline_is_active * opacity);

  return pow(c, vec4(1.0/2.2));
}
