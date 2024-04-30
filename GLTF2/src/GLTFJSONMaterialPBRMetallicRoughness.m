#import "GLTFJSONMaterialPBRMetallicRoughness.h"

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
