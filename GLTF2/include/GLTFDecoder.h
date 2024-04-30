#import "GLTFAccessor.h"
#import "GLTFAccessorSparse.h"
#import "GLTFAccessorSparseIndices.h"
#import "GLTFAccessorSparseValues.h"
#import "GLTFMaterialNormalTextureInfo.h"
#import "GLTFMaterialOcclusionTextureInfo.h"
#import "GLTFMaterialPBRMetallicRoughness.h"
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

NSString *const GLTF2DecodeErrorDomain = @"GLTF2.DecodeError";

typedef NS_ENUM(NSInteger, GLTF2ErrorCode) {
  GLTF2ErrorMissingData = 1001,
  GLTF2ErrorInvalidFormat = 1002,
};

@interface GLTFDecoder : NSObject

//+ (nullable GLTFAccessor *)decodeAccessorFromJson:(NSDictionary *)jsonDict
//                                            error:(NSError **)error;
//
//+ (nullable GLTFAccessorSparse *)decodeAccessorSparseFromJson:
//                                     (NSDictionary *)jsonDict
//                                                        error:(NSError **)error;
//
//+ (nullable GLTFAccessorSparseIndices *)
//    decodeAccessorSparseIndicesFromJson:(NSDictionary *)jsonDict
//                                  error:(NSError **)error;
//
//+ (nullable GLTFAccessorSparseValues *)
//    decodeAccessorSparseValuesFromJson:(NSDictionary *)jsonDict
//                                 error:(NSError **)error;
//
//+ (nullable GLTFMaterialNormalTextureInfo *)
//    decodeMaterialNormalTextureInfoFromJson:(NSDictionary *)jsonDict
//                                      error:(NSError **)error;
//
//+ (nullable GLTFMaterialOcclusionTextureInfo *)
//    decodeMaterialOcclusionTextureInfoFromJson:(NSDictionary *)jsonDict
//                                         error:(NSError **)error;
//
//+ (nullable GLTFMaterialPBRMetallicRoughness *)
//    decodeMaterialPBRMetallicRoughnessFromJson:(NSDictionary *)jsonDict
//                                         error:(NSError **)error;
//
//+ (nullable GLTFMesh *)decodeMeshFromJson:(NSDictionary *)jsonDict
//                                    error:(NSError **)error;
//
//+ (nullable GLTFMeshPrimitive *)decodeMeshPrimitiveFromJson:
//                                    (NSDictionary *)jsonDict
//                                                      error:(NSError **)error;
//
//+ (nullable GLTFNode *)decodeNodeFromJson:(NSDictionary *)jsonDict
//                                    error:(NSError **)error;
//
//+ (nullable GLTFSampler *)decodeSamplerFromJson:(NSDictionary *)jsonDict
//                                          error:(NSError **)error;
//
//+ (nullable GLTFScene *)decodeSceneFromJson:(NSDictionary *)jsonDict
//                                      error:(NSError **)error;
//
//+ (nullable GLTFSkin *)decodeSkinFromJson:(NSDictionary *)jsonDict
//                                    error:(NSError **)error;
//
//+ (nullable GLTFTexture *)decodeTextureFromJson:(NSDictionary *)jsonDict
//                                          error:(NSError **)error;
//
//+ (nullable GLTFTextureInfo *)decodeTextureInfoFromJson:(NSDictionary *)jsonDict
//                                                  error:(NSError **)error;
@end

NS_ASSUME_NONNULL_END
