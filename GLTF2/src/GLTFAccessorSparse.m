#import "GLTFAccessorSparse.h"

@implementation GLTFAccessorSparse

- (instancetype)init {
  self = [super init];
  if (self) {
    _count = NSNotFound;
    _indices = nil;
    _values = nil;
    _extensions = nil;
    _extras = nil;
  }
  return self;
}

@end
