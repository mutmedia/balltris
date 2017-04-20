varying vec2 textureCoordinate;
varying vec2 leftTextureCoordinate;
varying vec2 rightTextureCoordinate;

varying vec2 topTextureCoordinate;
varying vec2 topLeftTextureCoordinate;
varying vec2 topRightTextureCoordinate;

varying vec2 bottomTextureCoordinate;
varying vec2 bottomLeftTextureCoordinate;
varying vec2 bottomRightTextureCoordinate;


vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
  vec4 fSumX = vec4(0.0);
  vec4 fSumY = vec4(0.0);


  float i00   = Texel(texture, textureCoordinate).r;
  float im1m1 = Texel(texture, bottomLeftTextureCoordinate).r;
  float ip1p1 = Texel(texture, topRightTextureCoordinate).r;
  float im1p1 = Texel(texture, topLeftTextureCoordinate).r;
  float ip1m1 = Texel(texture, bottomRightTextureCoordinate).r;
  float im10 = Texel(texture, leftTextureCoordinate).r;
  float ip10 = Texel(texture, rightTextureCoordinate).r;
  float i0m1 = Texel(texture, bottomTextureCoordinate).r;
  float i0p1 = Texel(texture, topTextureCoordinate).r;
  float h = -im1p1 - 2.0 * i0p1 - ip1p1 + im1m1 + 2.0 * i0m1 + ip1m1;
  float v = -im1m1 - 2.0 * im10 - im1p1 + ip1m1 + 2.0 * ip10 + ip1p1;

  float mag = floor(1.0 - length(vec2(h, v)));

  return vec4(vec3(mag), 1.0-mag);
  //return vec4(0.0);
  //return textureColor;
  //return fTotalSum;
  //  return mix(fTotalSum, textureColor, 0.5);
}
