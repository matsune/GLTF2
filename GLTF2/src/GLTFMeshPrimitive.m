#import "GLTFMeshPrimitive.h"

@implementation GLTFMeshPrimitive

- (instancetype)init {
  self = [super init];
  if (self) {
    _mode = GLTFMeshPrimitiveModeTriangles;
  }
  return self;
}

@end
