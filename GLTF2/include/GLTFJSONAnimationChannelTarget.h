#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const GLTFJSONAnimationChannelTargetPathTranslation;
extern NSString *const GLTFJSONAnimationChannelTargetPathRotation;
extern NSString *const GLTFJSONAnimationChannelTargetPathScale;
extern NSString *const GLTFJSONAnimationChannelTargetPathWeights;

@interface GLTFJSONAnimationChannelTarget : NSObject

@property(nonatomic, strong, nullable) NSNumber *node;
@property(nonatomic, copy) NSString *path;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

NS_ASSUME_NONNULL_END
