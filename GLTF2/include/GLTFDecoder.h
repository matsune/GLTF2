#import "GLTFAccessor.h"
#import "GLTFAccessorSparse.h"
#import "GLTFAccessorSparseIndices.h"
#import "GLTFAccessorSparseValues.h"
#import "GLTFTexture.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

NSString *const GLTF2ErrorDomain = @"GLTF2.Error";

typedef NS_ENUM(NSInteger, GLTF2ErrorCode) {
  GLTF2ErrorMissingData = 1,
  GLTF2ErrorInvalidFormat = 2,
};

@interface GLTFDecoder : NSObject

+ (nullable GLTFAccessor *)decodeAccessorFromJson:(NSDictionary *)jsonDict
                                            error:(NSError **)error;
+ (nullable GLTFAccessorSparse *)decodeAccessorSparseFromJson:
                                     (NSDictionary *)jsonDict
                                                        error:(NSError **)error;
+ (nullable GLTFAccessorSparseIndices *)
    decodeAccessorSparseIndicesFromJson:(NSDictionary *)jsonDict
                                  error:(NSError **)error;
+ (nullable GLTFAccessorSparseValues *)
    decodeAccessorSparseValuesFromJson:(NSDictionary *)jsonDict
                                 error:(NSError **)error;
+ (nullable GLTFTexture *)decodeTextureFromJson:(NSDictionary *)jsonDict
                                          error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
