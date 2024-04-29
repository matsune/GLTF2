#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, GLTFAnimationSamplerInterpolation) {
  GLTFAnimationSamplerInterpolationLinear,
  GLTFAnimationSamplerInterpolationStep,
  GLTFAnimationSamplerInterpolationCubicSpline
};

GLTFAnimationSamplerInterpolation
GLTFAnimationSamplerInterpolationFromNSString(NSString *string) {
  if ([string isEqualToString:@"LINEAR"]) {
    return GLTFAnimationSamplerInterpolationLinear;
  } else if ([string isEqualToString:@"STEP"]) {
    return GLTFAnimationSamplerInterpolationStep;
  } else if ([string isEqualToString:@"CUBICSPLINE"]) {
    return GLTFAnimationSamplerInterpolationCubicSpline;
  } else {
    return NSNotFound;
  }
}

@interface GLTFAnimationSampler : NSObject

@end

NS_ASSUME_NONNULL_END
