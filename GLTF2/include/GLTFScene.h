#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GLTFScene : NSObject

@property(nonatomic, strong) NSArray<NSNumber *> *nodes;
@property(nonatomic, copy, nullable) NSString *name;
@property(nonatomic, copy, nullable) NSDictionary *extensions;
@property(nonatomic, copy, nullable) NSDictionary *extras;

@end

NS_ASSUME_NONNULL_END
