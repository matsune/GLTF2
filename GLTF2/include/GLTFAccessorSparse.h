#import "GLTFAccessorSparseIndices.h"
#import "GLTFAccessorSparseValues.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GLTFAccessorSparse : NSObject

@property(nonatomic, assign) NSUInteger count;
@property(nonatomic, strong) GLTFAccessorSparseIndices *indices;
@property(nonatomic, strong) GLTFAccessorSparseValues *values;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

NS_ASSUME_NONNULL_END
