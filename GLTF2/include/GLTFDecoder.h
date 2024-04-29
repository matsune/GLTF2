#import "GLTFAccessor.h"
#import "GLTFAccessorSparse.h"
#import "GLTFAccessorSparseIndices.h"
#import "GLTFAccessorSparseValues.h"
#import "GLTFMesh.h"
#import "GLTFMeshPrimitive.h"
#import "GLTFNode.h"
#import "GLTFSampler.h"
#import "GLTFScene.h"
#import "GLTFSkin.h"
#import "GLTFTexture.h"
#import "GLTFTextureInfo.h"
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

+ (nullable GLTFMesh *)decodeMeshFromJson:(NSDictionary *)jsonDict
                                    error:(NSError **)error;

+ (nullable GLTFMeshPrimitive *)decodeMeshPrimitiveFromJson:
                                    (NSDictionary *)jsonDict
                                                      error:(NSError **)error;

+ (nullable GLTFNode *)decodeNodeFromJson:(NSDictionary *)jsonDict
                                    error:(NSError **)error;

+ (nullable GLTFSampler *)decodeSamplerFromJson:(NSDictionary *)jsonDict
                                          error:(NSError **)error;

+ (nullable GLTFScene *)decodeSceneFromJson:(NSDictionary *)jsonDict
                                      error:(NSError **)error;

+ (nullable GLTFSkin *)decodeSkinFromJson:(NSDictionary *)jsonDict
                                    error:(NSError **)error;

+ (nullable GLTFTexture *)decodeTextureFromJson:(NSDictionary *)jsonDict
                                          error:(NSError **)error;

+ (nullable GLTFTextureInfo *)decodeTextureInfoFromJson:(NSDictionary *)jsonDict
                                                  error:(NSError **)error;
@end

NS_ASSUME_NONNULL_END
