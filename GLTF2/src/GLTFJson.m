#import "GLTFJson.h"

NSString *const GLTFJSONAccessorTypeScalar = @"SCALAR";
NSString *const GLTFJSONAccessorTypeVec2 = @"VEC2";
NSString *const GLTFJSONAccessorTypeVec3 = @"VEC3";
NSString *const GLTFJSONAccessorTypeVec4 = @"VEC4";
NSString *const GLTFJSONAccessorTypeMat2 = @"MAT2";
NSString *const GLTFJSONAccessorTypeMat3 = @"MAT3";
NSString *const GLTFJSONAccessorTypeMat4 = @"MAT4";

NSString *const GLTFJSONAnimationChannelTargetPathTranslation = @"translation";
NSString *const GLTFJSONAnimationChannelTargetPathRotation = @"rotation";
NSString *const GLTFJSONAnimationChannelTargetPathScale = @"scale";
NSString *const GLTFJSONAnimationChannelTargetPathWeights = @"weights";

NSString *const GLTFJSONAnimationSamplerInterpolationLinear = @"LINEAR";
NSString *const GLTFJSONAnimationSamplerInterpolationStep = @"STEP";
NSString *const GLTFJSONAnimationSamplerInterpolationCubicSpline =
    @"CUBICSPLINE";

@implementation GLTFJSONAnimationSampler

- (instancetype)init {
  self = [super init];
  if (self) {
    _interpolation = GLTFJSONAnimationSamplerInterpolationLinear;
  }
  return self;
}

@end

NSString *const GLTFJSONMaterialAlphaModeOpaque = @"OPAQUE";
NSString *const GLTFJSONMaterialAlphaModeMask = @"MASK";
NSString *const GLTFJSONMaterialAlphaModeBlend = @"BLEND";

@implementation GLTFJSONMaterial

- (instancetype)init {
  self = [super init];
  if (self) {
    _emissiveFactor = @[ @0, @0, @0 ];
    _alphaMode = GLTFJSONMaterialAlphaModeOpaque;
    _alphaCutoff = 0.5;
  }
  return self;
}

@end

@implementation GLTFJSONMaterialNormalTextureInfo

- (instancetype)init {
  self = [super init];
  if (self) {
    _scale = 1.0;
  }
  return self;
}

@end

@implementation GLTFJSONMaterialOcclusionTextureInfo

- (instancetype)init {
  self = [super init];
  if (self) {
    _strength = 1.0;
  }
  return self;
}

@end

@implementation GLTFJSONMaterialPBRMetallicRoughness

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

@implementation GLTFJSONMeshPrimitive

- (instancetype)init {
  self = [super init];
  if (self) {
    _mode = GLTFJSONMeshPrimitiveModeTriangles;
  }
  return self;
}

@end

@implementation GLTFJSONNode

- (instancetype)init {
  self = [super init];
  if (self) {
    _matrix =
        (simd_float4x4){(simd_float4){1, 0, 0, 0}, (simd_float4){0, 1, 0, 0},
                        (simd_float4){0, 0, 1, 0}, (simd_float4){0, 0, 0, 1}};
    _rotation = @[ @0, @0, @0, @1 ];
    _scale = @[ @1, @1, @1 ];
    _translation = @[ @0, @0, @0 ];
  }
  return self;
}

@end

@implementation GLTFJSONSampler

- (instancetype)init {
  self = [super init];
  if (self) {
    _wrapS = GLTFJSONSamplerWrapModeRepeat;
    _wrapT = GLTFJSONSamplerWrapModeRepeat;
  }
  return self;
}

@end

@implementation GLTFJSONAccessorSparseIndices
@end

@implementation GLTFJSONAccessorSparseValues
@end

@implementation GLTFJSONAccessorSparse
@end

@implementation GLTFJSONAccessor
@end

@implementation GLTFJSONAnimationChannelTarget
@end

@implementation GLTFJSONAnimationChannel
@end

@implementation GLTFJSONAnimation
@end

@implementation GLTFJSONAsset
@end

@implementation GLTFJSONBuffer
@end

@implementation GLTFJSONBufferView
@end

@implementation GLTFJSONCameraOrthographic
@end

@implementation GLTFJSONCameraPerspective
@end

@implementation GLTFJSONCamera
@end

@implementation GLTFJSONImage
@end

@implementation GLTFJSONTexture
@end

@implementation GLTFJSONTextureInfo
@end

@implementation GLTFJSONMesh
@end

@implementation GLTFJSONScene
@end

@implementation GLTFJSONSkin
@end

@implementation GLTFJson
@end
