#import "GLTFNode.h"

@implementation GLTFNode

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
