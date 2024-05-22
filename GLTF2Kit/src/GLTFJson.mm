#import "GLTFJson.h"

@implementation GLTFObject

- (nullable NSDictionary *)valueForExtensionKey:(NSString *)key {
  if (self.extensions) {
    id value = [self.extensions valueForKey:key];
    if ([value isKindOfClass:[NSDictionary class]]) {
      return value;
    }
  }
  return nil;
}

@end

#pragma mark - Accessor

@implementation GLTFAccessorSparseIndices

- (NSInteger)byteOffsetValue {
  return _byteOffset.integerValue;
}

@end

@implementation GLTFAccessorSparseValues

- (NSInteger)byteOffsetValue {
  return _byteOffset.integerValue;
}

@end

@implementation GLTFAccessorSparse
@end

NSInteger sizeOfComponentType(GLTFAccessorComponentType componentType) {
  switch (componentType) {
  case GLTFAccessorComponentTypeByte:
    return sizeof(int8_t);
  case GLTFAccessorComponentTypeUnsignedByte:
    return sizeof(uint8_t);
  case GLTFAccessorComponentTypeShort:
    return sizeof(int16_t);
  case GLTFAccessorComponentTypeUnsignedShort:
    return sizeof(uint16_t);
  case GLTFAccessorComponentTypeUnsignedInt:
    return sizeof(uint32_t);
  case GLTFAccessorComponentTypeFloat:
    return sizeof(float);
  default:
    return 0;
  }
}

NSString *const GLTFAccessorTypeScalar = @"SCALAR";
NSString *const GLTFAccessorTypeVec2 = @"VEC2";
NSString *const GLTFAccessorTypeVec3 = @"VEC3";
NSString *const GLTFAccessorTypeVec4 = @"VEC4";
NSString *const GLTFAccessorTypeMat2 = @"MAT2";
NSString *const GLTFAccessorTypeMat3 = @"MAT3";
NSString *const GLTFAccessorTypeMat4 = @"MAT4";

NSInteger componentsCountOfAccessorType(NSString *accessorType) {
  if ([accessorType isEqualToString:GLTFAccessorTypeScalar])
    return 1;
  if ([accessorType isEqualToString:GLTFAccessorTypeVec2])
    return 2;
  if ([accessorType isEqualToString:GLTFAccessorTypeVec3])
    return 3;
  if ([accessorType isEqualToString:GLTFAccessorTypeVec4])
    return 4;
  if ([accessorType isEqualToString:GLTFAccessorTypeMat2])
    return 4;
  if ([accessorType isEqualToString:GLTFAccessorTypeMat3])
    return 9;
  if ([accessorType isEqualToString:GLTFAccessorTypeMat4])
    return 16;
  return 0;
}

@implementation GLTFAccessor

- (NSInteger)byteOffsetValue {
  return _byteOffset.integerValue;
}

- (BOOL)isNormalized {
  return _normalized.boolValue;
}

@end

#pragma mark - Animation

NSString *const GLTFAnimationChannelTargetPathTranslation = @"translation";
NSString *const GLTFAnimationChannelTargetPathRotation = @"rotation";
NSString *const GLTFAnimationChannelTargetPathScale = @"scale";
NSString *const GLTFAnimationChannelTargetPathWeights = @"weights";

@implementation GLTFAnimationChannelTarget

- (BOOL)isPathTranslation {
  return [self.path isEqualToString:GLTFAnimationChannelTargetPathTranslation];
}

- (BOOL)isPathRotation {
  return [self.path isEqualToString:GLTFAnimationChannelTargetPathRotation];
}

- (BOOL)isPathScale {
  return [self.path isEqualToString:GLTFAnimationChannelTargetPathScale];
}

- (BOOL)isPathWeights {
  return [self.path isEqualToString:GLTFAnimationChannelTargetPathWeights];
}

@end

NSString *const GLTFAnimationSamplerInterpolationLinear = @"LINEAR";
NSString *const GLTFAnimationSamplerInterpolationStep = @"STEP";
NSString *const GLTFAnimationSamplerInterpolationCubicSpline = @"CUBICSPLINE";

@implementation GLTFAnimationSampler

- (NSString *)interpolationValue {
  return _interpolation ?: GLTFAnimationSamplerInterpolationLinear;
}

@end

@implementation GLTFAnimationChannel
@end

@implementation GLTFAnimation
@end

#pragma mark - Asset

@implementation GLTFAsset
@end

#pragma mark - Buffer

@implementation GLTFBuffer
@end

@implementation GLTFBufferView

- (NSInteger)byteOffsetValue {
  return _byteOffset.integerValue;
}

@end

#pragma mark - Camera

@implementation GLTFCameraOrthographic
@end

@implementation GLTFCameraPerspective
@end

NSString *const GLTFCameraTypePerspective = @"perspective";
NSString *const GLTFCameraTypeOrthographic = @"orthographic";

@implementation GLTFCamera
@end

#pragma mark - Image

@implementation GLTFImage
@end

#pragma mark - Texture

@implementation GLTFTexture
@end

@implementation GLTFTextureInfo

- (NSInteger)texCoordValue {
  return _texCoord.integerValue;
}

@end

#pragma mark - Material

@implementation GLTFMaterialNormalTextureInfo

- (float)scaleValue {
  if (_scale)
    return _scale.floatValue;
  return 1.0;
}

@end

@implementation GLTFMaterialOcclusionTextureInfo

- (float)strengthValue {
  if (_strength)
    return _strength.floatValue;
  return 1.0;
}

@end

@implementation GLTFMaterialPBRMetallicRoughness

- (simd_float4)baseColorFactorValue {
  if (_baseColorFactor && _baseColorFactor.count == 4) {
    return simd_make_float4(
        _baseColorFactor[0].floatValue, _baseColorFactor[1].floatValue,
        _baseColorFactor[2].floatValue, _baseColorFactor[3].floatValue);
  }
  return simd_make_float4(1, 1, 1, 1);
}

- (float)metallicFactorValue {
  return _metallicFactor != nil ? _metallicFactor.floatValue : 1.0;
}

- (float)roughnessFactorValue {
  return _roughnessFactor != nil ? _roughnessFactor.floatValue : 1.0;
}

@end

NSString *const GLTFMaterialAlphaModeOpaque = @"OPAQUE";
NSString *const GLTFMaterialAlphaModeMask = @"MASK";
NSString *const GLTFMaterialAlphaModeBlend = @"BLEND";

@implementation GLTFMaterial

- (simd_float3)emissiveFactorValue {
  if (_emissiveFactor && _emissiveFactor.count == 3) {
    return simd_make_float3(_emissiveFactor[0].floatValue,
                            _emissiveFactor[1].floatValue,
                            _emissiveFactor[2].floatValue);
  }
  return simd_make_float3(0, 0, 0);
}

- (NSString *)alphaModeValue {
  return _alphaMode ?: GLTFMaterialAlphaModeOpaque;
}

- (BOOL)isAlphaModeOpaque {
  return [self.alphaModeValue isEqualToString:GLTFMaterialAlphaModeOpaque];
}

- (BOOL)isAlphaModeMask {
  return [self.alphaModeValue isEqualToString:GLTFMaterialAlphaModeMask];
}

- (BOOL)isAlphaModeBlend {
  return [self.alphaModeValue isEqualToString:GLTFMaterialAlphaModeBlend];
}

- (float)alphaCutoffValue {
  if (_alphaCutoff)
    return _alphaCutoff.floatValue;
  return 0.5;
}

- (BOOL)isDoubleSided {
  return _doubleSided.boolValue;
}

@end

#pragma mark - Mesh

@implementation GLTFMesh
@end

NSString *const GLTFMeshPrimitiveAttributeSemanticPosition = @"POSITION";
NSString *const GLTFMeshPrimitiveAttributeSemanticNormal = @"NORMAL";
NSString *const GLTFMeshPrimitiveAttributeSemanticTangent = @"TANGENT";
NSString *const GLTFMeshPrimitiveAttributeSemanticTexcoord = @"TEXCOORD";
NSString *const GLTFMeshPrimitiveAttributeSemanticColor = @"COLOR";
NSString *const GLTFMeshPrimitiveAttributeSemanticJoints = @"JOINTS";
NSString *const GLTFMeshPrimitiveAttributeSemanticWeights = @"WEIGHTS";

@implementation GLTFMeshPrimitiveTarget
@end

@implementation GLTFMeshPrimitiveAttributes
@end

@implementation GLTFMeshPrimitiveDracoExtension
@end

@implementation GLTFMeshPrimitive

- (NSInteger)modeValue {
  if (_mode != nil)
    return _mode.integerValue;
  return GLTFMeshPrimitiveModeTriangles;
}

@end

#pragma mark - Node

@implementation GLTFNode
- (simd_float4x4)matrixValue {
  if (_matrix) {
    return simd_matrix(
        (vector_float4){_matrix[0].floatValue, _matrix[1].floatValue,
                        _matrix[2].floatValue, _matrix[3].floatValue},
        (vector_float4){_matrix[4].floatValue, _matrix[5].floatValue,
                        _matrix[6].floatValue, _matrix[7].floatValue},
        (vector_float4){_matrix[8].floatValue, _matrix[9].floatValue,
                        _matrix[10].floatValue, _matrix[11].floatValue},
        (vector_float4){_matrix[12].floatValue, _matrix[13].floatValue,
                        _matrix[14].floatValue, _matrix[15].floatValue});
  }
  return matrix_identity_float4x4;
}

- (simd_quatf)rotationValue {
  if (_rotation && _rotation.count == 4) {
    return simd_quaternion(_rotation[0].floatValue, _rotation[1].floatValue,
                           _rotation[2].floatValue, _rotation[3].floatValue);
  }
  return simd_quaternion(0.0f, 0.0f, 0.0f, 1.0f);
}

- (simd_float3)scaleValue {
  if (_scale && _scale.count == 3) {
    return simd_make_float3(_scale[0].floatValue, _scale[1].floatValue,
                            _scale[2].floatValue);
  }
  return simd_make_float3(1.0f, 1.0f, 1.0f);
}

- (simd_float3)translationValue {
  if (_translation && _translation.count == 3) {
    return simd_make_float3(_translation[0].floatValue,
                            _translation[1].floatValue,
                            _translation[2].floatValue);
  }
  return simd_make_float3(0.0f, 0.0f, 0.0f);
}

- (simd_float4x4)simdTransform {
  if (_matrix) {
    return self.matrixValue;
  } else {
    simd_quatf q = self.rotationValue;
    simd_float3 t = self.translationValue;
    simd_float3 s = self.scaleValue;

    simd_float4x4 rMat = simd_matrix4x4(q);
    simd_float4x4 tMat = matrix_identity_float4x4;
    tMat.columns[3].x = t[0];
    tMat.columns[3].y = t[1];
    tMat.columns[3].z = t[2];
    simd_float4x4 sMat = matrix_identity_float4x4;
    sMat.columns[0].x = s[0];
    sMat.columns[1].y = s[1];
    sMat.columns[2].z = s[2];

    return simd_mul(tMat, simd_mul(rMat, sMat));
  }
  return matrix_identity_float4x4;
}

@end

#pragma mark - Sampler

@implementation GLTFSampler

- (NSInteger)wrapSValue {
  if (_wrapS)
    return _wrapS.integerValue;
  return GLTFSamplerWrapModeRepeat;
}

- (NSInteger)wrapTValue {
  if (_wrapT)
    return _wrapT.integerValue;
  return GLTFSamplerWrapModeRepeat;
}

@end

#pragma mark - Scene

@implementation GLTFScene
@end

#pragma mark - Skin

@implementation GLTFSkin
@end

#pragma mark - Json

@implementation GLTFJson
@end
