#import "GLTFAccessorSparseIndices.h"
#import "GLTFAccessorSparseValues.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

NSString *const GLTF2ErrorDomain = @"GLTF2.Error";

typedef NS_ENUM(NSInteger, GLTF2ErrorCode) {
  GLTF2ErrorMissingData = 1,
  GLTF2ErrorInvalidFormat = 2,
};

@interface GLTFDecoder : NSObject

+ (nullable GLTFAccessorSparseIndices *)
    decodeAccessorSparseIndicesFromJson:(NSDictionary *)jsonDict
                                  error:(NSError **)error;
+ (nullable GLTFAccessorSparseValues *)
    decodeAccessorSparseValuesFromJson:(NSDictionary *)jsonDict
                                 error:(NSError **)error;
@end

NS_ASSUME_NONNULL_END
