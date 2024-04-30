#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

static NSString *const GLTFAnimationChannelTargetPathTranslation =
    @"translation";
static NSString *const GLTFAnimationChannelTargetPathRotation = @"rotation";
static NSString *const GLTFAnimationChannelTargetPathScale = @"scale";
static NSString *const GLTFAnimationChannelTargetPathWeights = @"weights";

@interface GLTFAnimationChannelTarget : NSObject

@property(nonatomic, strong, nullable) NSNumber *node;
@property(nonatomic, copy) NSString *path;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

NS_ASSUME_NONNULL_END
