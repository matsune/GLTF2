#import "GLTFAccessorSparseIndices.h"

@implementation GLTFAccessorSparseIndices

- (instancetype)init {
  self = [super init];
  if (self) {
    _bufferView = NSNotFound;
    _byteOffset = NSNotFound;
    _componentType = NSNotFound;
    _extensions = nil;
    _extras = nil;
  }
  return self;
}

@end
