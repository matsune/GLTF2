#import "GLTFJSONAccessorSparseIndices.h"
#import "GLTFJSONAccessorSparseValues.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GLTFJSONAccessorSparse : NSObject

@property(nonatomic, assign) NSInteger count;
@property(nonatomic, strong) GLTFJSONAccessorSparseIndices *indices;
@property(nonatomic, strong) GLTFJSONAccessorSparseValues *values;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

NS_ASSUME_NONNULL_END
