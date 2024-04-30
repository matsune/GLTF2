#import "GLTFAnimationSampler.h"

@implementation GLTFAnimationSampler

- (instancetype)init {
  self = [super init];
  if (self) {
    _interpolation = GLTFAnimationSamplerInterpolationLinear;
  }
  return self;
}

@end
