#import "GLTFTexture.h"

@implementation GLTFTexture

- (instancetype)init {
  self = [super init];
  if (self) {
    _sampler = NSNotFound;
    _source = NSNotFound;
    _name = nil;
    _extensions = nil;
    _extras = nil;
  }
  return self;
}

@end
