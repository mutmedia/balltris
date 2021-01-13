uniform vec2 distortion;

vec2 To11Coord(vec2 point)
{
  point.x = (point.x) * 2.0 - 1.0;
  point.y = (point.y) * -2.0 + 1.0;

  return point;
}

vec2 distort_coords(vec2 point) {

  point = To11Coord(point);

  point.x = point.x + (point.y * point.y) * point.x * distortion.x;
  point.y = point.y + (point.x * point.x) * point.y * distortion.y;

  point.x = (point.x + 1.0)/2.0;
  point.y = (point.y - 1.0)/-2.0;

  return point;
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
  vec2 duv = distort_coords(texture_coords);
  vec4 c = pow(Texel(texture, duv), vec4(2.2));
  if (duv.x < 0.0 || duv.x >= 1.0 || duv.y < 0.0 || duv.y > 1.0) {
    c = vec4(0.0, 0.0, 0.0, 1.0);
  }
  return pow(c, vec4(1.0/2.2));
}
