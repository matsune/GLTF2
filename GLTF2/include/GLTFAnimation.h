#import "GLTFAnimationChannel.h"
#import "GLTFAnimationSampler.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GLTFAnimation : NSObject

@property(nonatomic, strong) NSArray<GLTFAnimationChannel *> *channels;
@property(nonatomic, strong) NSArray<GLTFAnimationSampler *> *samplers;
@property(nonatomic, copy, nullable) NSString *name;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

NS_ASSUME_NONNULL_END
