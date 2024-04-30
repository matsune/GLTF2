#import "GLTFJSONAnimationChannel.h"
#import "GLTFJSONAnimationSampler.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GLTFJSONAnimation : NSObject

@property(nonatomic, strong) NSArray<GLTFJSONAnimationChannel *> *channels;
@property(nonatomic, strong) NSArray<GLTFJSONAnimationSampler *> *samplers;
@property(nonatomic, copy, nullable) NSString *name;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

NS_ASSUME_NONNULL_END
