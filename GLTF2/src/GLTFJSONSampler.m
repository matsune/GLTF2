#import "GLTFJSONSampler.h"

@implementation GLTFJSONSampler

- (instancetype)init {
  self = [super init];
  if (self) {
    _wrapS = GLTFJSONSamplerWrapModeRepeat;
    _wrapT = GLTFJSONSamplerWrapModeRepeat;
  }
  return self;
}

@end
