#define MAX_CIRCLES 100
#define SEGMENTS_MULT 4
#define PI 3.141592

uniform int num_circles;
uniform float[MAX_CIRCLES] radii;
uniform vec2[MAX_CIRCLES] centers;
uniform vec3[MAX_CIRCLES] colors;
uniform float[MAX_CIRCLES] time_destroyed;
uniform float time;

uniform float intensity;
//const float intensity = 0.01;

uniform float a;
uniform float b;

vec4 effect(vec4 color2, Image texture, vec2 texture_coords, vec2 screen_coords)
{
  vec3 final_color = vec3(0.0);
  for (int n = 0; n < num_circles; n++) {
    vec2 center = centers[n];
    float radius_mult = radii[n];
    int num_segments = SEGMENTS_MULT * int(radius_mult);
    float radius = radius_mult;
    vec3 color = colors[n];
    float field = 0.0;
    for (int i = 0; i < num_segments; i++) {
      float angle = float(i) * 2.0 * PI / float(num_segments);
      vec2 point = center + radius * vec2(cos(angle),sin(angle));
      vec2 point2 = center + (radius - 5.0) * vec2(cos(angle),sin(angle));
      float dis = distance(screen_coords, point);
      float dis2 = distance(screen_coords, point2);

      //field += (intensity)/(dis*dis*sqrt(dis));
      field += (intensity)/(1.0 + a * dis + b*dis*dis);
      field += (intensity)/(1.0 + a * dis2 + b*dis2*dis2);
    }

    color = color * field;
    final_color += color;
  }

  return vec4(final_color, 1.0);
}
