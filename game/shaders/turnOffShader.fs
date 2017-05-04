#ifdef GL_ES 
#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif
#endif

//uniform vec2 center;
//uniform float radius;
uniform float delta_time;
uniform float time_to_destroy;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
  vec2 point = vec2(screen_coords.x, screen_coords.y); 

  vec3 color3 = vec3(color);
  color3 *= (1.0 - 0.5 * smoothstep(0.0, 2.0*time_to_destroy/5.0, delta_time)
      /*+ 0.25 * smoothstep(2.0*time_to_destroy/5.0, 3.0*time_to_destroy/5.0, delta_time)*/
      - 0.5 * smoothstep(3.0*time_to_destroy/5.0, 5.0*time_to_destroy/5.0, delta_time)
      //- 0.25 * smoothstep(time_destroyed[n] + 0.30, time_destroyed[n] + 0.35, delta_time)
      );

  //color3 *= colorDestroyed;
  return vec4(color3.rgb, color.a);
}
