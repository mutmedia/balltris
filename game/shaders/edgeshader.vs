uniform float imageWidthFactor;
uniform float imageHeightFactor;

varying vec2 textureCoordinate;
varying vec2 leftTextureCoordinate;
varying vec2 rightTextureCoordinate;

varying vec2 topTextureCoordinate;
varying vec2 topLeftTextureCoordinate;
varying vec2 topRightTextureCoordinate;

varying vec2 bottomTextureCoordinate;
varying vec2 bottomLeftTextureCoordinate;
varying vec2 bottomRightTextureCoordinate;

vec4 position(mat4 transform_projection, vec4 vertex_position)
{

  vec2 widthStep = vec2(imageWidthFactor, 0.0);
  vec2 heightStep = vec2(0.0, imageHeightFactor);
  vec2 widthHeightStep = vec2(imageWidthFactor, imageHeightFactor);
  vec2 widthNegativeHeightStep = vec2(imageWidthFactor, -imageHeightFactor);

  textureCoordinate = VertexTexCoord.xy;
  leftTextureCoordinate = VertexTexCoord.xy - widthStep;
  rightTextureCoordinate = VertexTexCoord.xy + widthStep;

  topTextureCoordinate = VertexTexCoord.xy + heightStep;
  topLeftTextureCoordinate = VertexTexCoord.xy - widthNegativeHeightStep;
  topRightTextureCoordinate = VertexTexCoord.xy + widthHeightStep;

  bottomTextureCoordinate = VertexTexCoord.xy - heightStep;
  bottomLeftTextureCoordinate = VertexTexCoord.xy - widthHeightStep;
  bottomRightTextureCoordinate = VertexTexCoord.xy + widthNegativeHeightStep;

  return transform_projection * vertex_position;
}
