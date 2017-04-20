uniform vec2 center;
uniform float radius;
uniform vec3 light_dir;
uniform float time;
uniform float time_destroyed;

float material_kd = 1.5;

const float TIME_TO_DESTROY = 0.4;
vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
  vec3 ambient_color = vec3(color * 0.2);
  vec3 diffuse_color = vec3(color * 0.5);
  vec3 specular_color = vec3(1.0, 1.0, 1.0);

  vec2 point = vec2(screen_coords.x, screen_coords.y); 

  vec3 colorDestroyed = vec3(1.0);
  float alpha = 1.0;
  float visibleRadius = radius;
  if (time_destroyed > 0.0 && time > time_destroyed) {
    float deltaTime = (time - time_destroyed) / TIME_TO_DESTROY;
    float timeInfluence = pow(deltaTime, 5.0);
    visibleRadius = radius * (1.0 - timeInfluence);
    alpha = step(length(point-center), visibleRadius);
    colorDestroyed = vec3(alpha);
  }

  vec3 color3 = vec3(color);
  //float color_mult = (visibleRadius - length(point-center)) < 3.0 ? 0.3 : 1.0;
  
  //color3 *= color_mult;
  //vec3 color3hsv = rgb2hsv(color3);
  //color3 = hsv2rgb(color3hsv);

  

  //color3 *= colorDestroyed;
  return vec4(color3, color.a * alpha);
}
