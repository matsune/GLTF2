#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const GLTFAnimationChannelTargetPathTranslation;
extern NSString *const GLTFAnimationChannelTargetPathRotation;
extern NSString *const GLTFAnimationChannelTargetPathScale;
extern NSString *const GLTFAnimationChannelTargetPathWeights;

@interface GLTFAnimationChannelTarget : NSObject

@property(nonatomic, strong, nullable) NSNumber *node;
@property(nonatomic, copy) NSString *path;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

NS_ASSUME_NONNULL_END
