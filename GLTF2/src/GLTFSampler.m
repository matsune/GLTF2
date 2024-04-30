#import "GLTFSampler.h"

@implementation GLTFSampler

- (instancetype)init {
  self = [super init];
  if (self) {
    _wrapS = GLTFSamplerWrapModeRepeat;
    _wrapT = GLTFSamplerWrapModeRepeat;
  }
  return self;
}

@end
