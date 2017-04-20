vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
  vec4 textureColor = Texel(texture, texture_coords);

  textureColor = vec4(dot(vec4(1.0/4.0), textureColor));
  textureColor = vec4(textureColor.x < 0.99 ? 0.0 : 1.0);
  textureColor.a = 1.0;

  return textureColor;
}
