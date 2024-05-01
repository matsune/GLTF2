#import "GLTFJSONAnimationSampler.h"

NSString *const GLTFJSONAnimationSamplerInterpolationLinear = @"LINEAR";
NSString *const GLTFJSONAnimationSamplerInterpolationStep = @"STEP";
NSString *const GLTFJSONAnimationSamplerInterpolationCubicSpline =
    @"CUBICSPLINE";

@implementation GLTFJSONAnimationSampler

- (instancetype)init {
  self = [super init];
  if (self) {
    _interpolation = GLTFJSONAnimationSamplerInterpolationLinear;
  }
  return self;
}

@end
