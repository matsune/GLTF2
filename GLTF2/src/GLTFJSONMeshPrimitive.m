#import "GLTFJSONMeshPrimitive.h"

@implementation GLTFJSONMeshPrimitive

- (instancetype)init {
  self = [super init];
  if (self) {
    _mode = GLTFJSONMeshPrimitiveModeTriangles;
  }
  return self;
}

@end
