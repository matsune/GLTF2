#import "GLTFJson.h"

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
    return 4; // 2x2 matrix
  if ([accessorType isEqualToString:GLTFAccessorTypeMat3])
    return 9; // 3x3 matrix
  if ([accessorType isEqualToString:GLTFAccessorTypeMat4])
    return 16; // 4x4 matrix
  return 0;
}

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

NSString *const GLTFAnimationChannelTargetPathTranslation = @"translation";
NSString *const GLTFAnimationChannelTargetPathRotation = @"rotation";
NSString *const GLTFAnimationChannelTargetPathScale = @"scale";
NSString *const GLTFAnimationChannelTargetPathWeights = @"weights";

NSString *const GLTFAnimationSamplerInterpolationLinear = @"LINEAR";
NSString *const GLTFAnimationSamplerInterpolationStep = @"STEP";
NSString *const GLTFAnimationSamplerInterpolationCubicSpline = @"CUBICSPLINE";

@implementation GLTFAnimationSampler

- (instancetype)init {
  self = [super init];
  if (self) {
    _interpolation = GLTFAnimationSamplerInterpolationLinear;
  }
  return self;
}

@end

NSString *const GLTFMaterialAlphaModeOpaque = @"OPAQUE";
NSString *const GLTFMaterialAlphaModeMask = @"MASK";
NSString *const GLTFMaterialAlphaModeBlend = @"BLEND";

@implementation GLTFMaterial

- (instancetype)init {
  self = [super init];
  if (self) {
    _emissiveFactor = @[ @0, @0, @0 ];
    _alphaMode = GLTFMaterialAlphaModeOpaque;
    _alphaCutoff = 0.5;
  }
  return self;
}

@end

@implementation GLTFMaterialNormalTextureInfo

- (instancetype)init {
  self = [super init];
  if (self) {
    _scale = 1.0;
  }
  return self;
}

@end

@implementation GLTFMaterialOcclusionTextureInfo

- (instancetype)init {
  self = [super init];
  if (self) {
    _strength = 1.0;
  }
  return self;
}

@end

@implementation GLTFMaterialPBRMetallicRoughness

- (instancetype)init {
  self = [super init];
  if (self) {
    _baseColorFactor = @[ @1, @1, @1, @1 ];
    _metallicFactor = 1.0;
    _roughnessFactor = 1.0;
  }
  return self;
}

@end

NSString *const GLTFMeshPrimitiveAttributeSemanticPosition = @"POSITION";
NSString *const GLTFMeshPrimitiveAttributeSemanticNormal = @"NORMAL";
NSString *const GLTFMeshPrimitiveAttributeSemanticTangent = @"TANGENT";
NSString *const GLTFMeshPrimitiveAttributeSemanticTexcoord = @"TEXCOORD";
NSString *const GLTFMeshPrimitiveAttributeSemanticColor = @"COLOR";
NSString *const GLTFMeshPrimitiveAttributeSemanticJoints = @"JOINTS";
NSString *const GLTFMeshPrimitiveAttributeSemanticWeights = @"WEIGHTS";

@implementation GLTFMeshPrimitive

- (instancetype)init {
  self = [super init];
  if (self) {
    _mode = GLTFMeshPrimitiveModeTriangles;
  }
  return self;
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

@implementation GLTFNode

- (instancetype)init {
  self = [super init];
  if (self) {
    _matrix = matrix_identity_float4x4;
    _rotation = @[ @0, @0, @0, @1 ];
    _scale = @[ @1, @1, @1 ];
    _translation = @[ @0, @0, @0 ];
  }
  return self;
}

@end

@implementation GLTFSampler

- (instancetype)init {
  self = [super init];
  if (self) {
    _wrapS = GLTFSamplerWrapModeRepeat;
    _wrapT = GLTFSamplerWrapModeRepeat;
  }
  return self;
}

@end

@implementation GLTFAccessorSparseIndices
@end

@implementation GLTFAccessorSparseValues
@end

@implementation GLTFAccessorSparse
@end

@implementation GLTFAccessor
@end

@implementation GLTFAnimationChannelTarget
@end

@implementation GLTFAnimationChannel
@end

@implementation GLTFAnimation
@end

@implementation GLTFAsset
@end

@implementation GLTFBuffer
@end

@implementation GLTFBufferView
@end

@implementation GLTFCameraOrthographic
@end

@implementation GLTFCameraPerspective
@end

@implementation GLTFCamera
@end

@implementation GLTFImage
@end

@implementation GLTFTexture
@end

@implementation GLTFTextureInfo
@end

@implementation GLTFMesh
@end

@implementation GLTFScene
@end

@implementation GLTFSkin
@end

@implementation GLTFJson
@end
