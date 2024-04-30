#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const GLTFJSONAnimationSamplerInterpolationLinear;
extern NSString *const GLTFJSONAnimationSamplerInterpolationStep;
extern NSString *const GLTFJSONAnimationSamplerInterpolationCubicSpline;

@interface GLTFJSONAnimationSampler : NSObject

@property(nonatomic, assign) NSInteger input;
@property(nonatomic, copy) NSString *interpolation;
@property(nonatomic, assign) NSInteger output;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

NS_ASSUME_NONNULL_END
