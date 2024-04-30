#import "GLTFAnimationChannelTarget.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GLTFAnimationChannel : NSObject

@property(nonatomic, assign) NSInteger sampler;
@property(nonatomic, strong) GLTFAnimationChannelTarget *target;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

NS_ASSUME_NONNULL_END
