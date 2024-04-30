#import "GLTFAnimationSampler.h"

NSString *const GLTFAnimationSamplerInterpolationLinear = @"LINEAR";
NSString *const GLTFAnimationSamplerInterpolationStep = @"STEP";
NSString *const GLTFAnimationSamplerInterpolationCubicSpline = @"CUBICSPLINE";

@implementation GLTFAnimationSampler

- (instancetype)init {
  self = [super init];
  if (self) {
    _interpolation = GLTFAnimationSamplerInterpolationLinear;
  }
  return self;
}

@end
