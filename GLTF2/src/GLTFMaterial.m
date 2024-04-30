#import "GLTFMaterial.h"

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
