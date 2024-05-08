#import "GLTFJson.h"

@implementation GLTFObject
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

- (NSInteger)texCoordValue {
  return _texCoord.integerValue;
}

- (float)scaleValue {
  if (_scale)
    return _scale.floatValue;
  return 1.0;
}

@end

@implementation GLTFMaterialOcclusionTextureInfo

- (NSInteger)texCoordValue {
  return _texCoord.integerValue;
}

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
  return _metallicFactor.floatValue ?: 1.0;
}

- (float)roughnessFactorValue {
  return _roughnessFactor.floatValue ?: 1.0;
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

@implementation GLTFMeshPrimitive

- (NSInteger)modeValue {
  if (_mode != nil)
    return _mode.integerValue;
  return GLTFMeshPrimitiveModeTriangles;
}

- (nullable NSNumber *)valueOfSemantic:(NSString *)semantic {
  return [self.attributes valueForKey:semantic];
}

- (nullable NSNumber *)indexOfPrefixedKey:(NSString *)prefixedKey
                                   prefix:(NSString *)prefix {
  NSString *pattern = [NSString stringWithFormat:@"%@_(\\d+)", prefix];
  NSRegularExpression *regex =
      [NSRegularExpression regularExpressionWithPattern:pattern
                                                options:0
                                                  error:nil];
  if (regex) {
    NSTextCheckingResult *match =
        [regex firstMatchInString:prefixedKey
                          options:0
                            range:NSMakeRange(0, prefixedKey.length)];
    if (match) {
      NSRange numberRange = [match rangeAtIndex:1];
      if (numberRange.location != NSNotFound) {
        NSString *numberString = [prefixedKey substringWithRange:numberRange];
        NSInteger number = [numberString integerValue];
        return @(number);
      }
    }
  }
  return nil;
}

- (NSArray<NSNumber *> *)valuesOfSemantic:(NSString *)semantic {
  NSMutableArray<NSNumber *> *values = [NSMutableArray array];
  NSArray<NSString *> *keys =
      [self.attributes.allKeys sortedArrayUsingSelector:@selector(compare:)];
  for (NSString *prefixedKey in keys) {
    NSNumber *index = [self indexOfPrefixedKey:prefixedKey prefix:semantic];
    if (index && values.count == [index integerValue]) {
      [values addObject:self.attributes[prefixedKey]];
    }
  }
  return [values copy];
}

@end

#pragma mark - Node

@implementation GLTFNode

- (simd_float4x4)matrixValue {
  if (_matrix && _matrix.count == 16) {
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

- (simd_float4)rotationValue {
  if (_rotation && _rotation.count == 4) {
    return simd_make_float4(_rotation[0].floatValue, _rotation[1].floatValue,
                            _rotation[2].floatValue, _rotation[3].floatValue);
  }
  return simd_make_float4(0, 0, 0, 1);
}

- (simd_float3)scaleValue {
  if (_scale && _scale.count == 3) {
    return simd_make_float3(_scale[0].floatValue, _scale[1].floatValue,
                            _scale[2].floatValue);
  }
  return simd_make_float3(1, 1, 1);
}

- (simd_float3)translationValue {
  if (_translation && _translation.count == 3) {
    return simd_make_float3(_translation[0].floatValue,
                            _translation[1].floatValue,
                            _translation[2].floatValue);
  }
  return simd_make_float3(0, 0, 0);
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
