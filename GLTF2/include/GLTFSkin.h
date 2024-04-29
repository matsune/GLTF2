#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GLTFSkin : NSObject

@property(nonatomic, assign) NSUInteger inverseBindMatrices;
@property(nonatomic, assign) NSUInteger skeleton;
@property(nonatomic, strong, nonnull) NSArray<NSNumber *> *joints;
@property(nonatomic, copy, nullable) NSString *name;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

NS_ASSUME_NONNULL_END
