//Image texture2

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
  
  vec4 src = pow(Texel(texture, texture_coords), vec4(1.0/2.2));
  //vec4 dst = pow(Texel(texture2, duv), vec4(2.2))
  //return pow(vec4(dst.rgb + src.a*src.rgb, dst.a), vec4(1/2.2))
  return src;
}
