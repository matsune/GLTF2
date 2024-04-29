#import "GLTFAccessorSparseValues.h"

@implementation GLTFAccessorSparseValues

- (instancetype)init {
  self = [super init];
  if (self) {
    _bufferView = NSNotFound;
    _byteOffset = 0;
    _extensions = nil;
    _extras = nil;
  }
  return self;
}

@end
