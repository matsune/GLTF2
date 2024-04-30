#import "GLTFJSONMaterial.h"

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
