#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GLTFAccessorSparseValues : NSObject

@property(nonatomic, assign) NSUInteger bufferView;
@property(nonatomic, assign) NSUInteger byteOffset;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

NS_ASSUME_NONNULL_END
