#import "GLTFJson.h"
#import "GLTFMeshPrimitive.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

NSString *const GLTF2DecodeErrorDomain = @"GLTF2.DecodeError";

typedef NS_ENUM(NSInteger, GLTF2ErrorCode) {
  GLTF2ErrorMissingData = 1001,
};

@interface GLTFDecoder : NSObject

- (nullable GLTFJson *)decodeJson:(NSDictionary *)jsonDict
                            error:(NSError **)error;

- (nullable GLTFAccessor *)decodeAccessor:(NSDictionary *)jsonDict
                                    error:(NSError **)error;

- (nullable GLTFAccessorSparse *)decodeAccessorSparse:(NSDictionary *)jsonDict
                                                error:(NSError **)error;

- (nullable GLTFAccessorSparseIndices *)
    decodeAccessorSparseIndices:(NSDictionary *)jsonDict
                          error:(NSError **)error;

- (nullable GLTFAccessorSparseValues *)
    decodeAccessorSparseValues:(NSDictionary *)jsonDict
                         error:(NSError **)error;

- (nullable GLTFAnimation *)decodeAnimation:(NSDictionary *)jsonDict
                                      error:(NSError **)error;

- (nullable GLTFAnimationChannel *)decodeAnimationChannel:
                                       (NSDictionary *)jsonDict
                                                    error:(NSError **)error;

- (nullable GLTFAnimationChannelTarget *)
    decodeAnimationChannelTarget:(NSDictionary *)jsonDict
                           error:(NSError **)error;

- (nullable GLTFAnimationSampler *)decodeAnimationSampler:
                                       (NSDictionary *)jsonDict
                                                    error:(NSError **)error;

- (nullable GLTFAsset *)decodeAsset:(NSDictionary *)jsonDict
                              error:(NSError **)error;

- (nullable GLTFBuffer *)decodeBuffer:(NSDictionary *)jsonDict
                                error:(NSError **)error;

- (nullable GLTFBufferView *)decodeBufferView:(NSDictionary *)jsonDict
                                        error:(NSError **)error;

- (nullable GLTFCamera *)decodeCamera:(NSDictionary *)jsonDict
                                error:(NSError **)error;

- (nullable GLTFCameraOrthographic *)decodeCameraOrthographic:
                                         (NSDictionary *)jsonDict
                                                        error:(NSError **)error;
- (nullable GLTFCameraPerspective *)decodeCameraPerspective:
                                        (NSDictionary *)jsonDict
                                                      error:(NSError **)error;

- (GLTFImage *)decodeImage:(NSDictionary *)jsonDict;

- (nullable GLTFMaterial *)decodeMaterial:(NSDictionary *)jsonDict
                                    error:(NSError **)error;

- (nullable GLTFMaterialNormalTextureInfo *)
    decodeMaterialNormalTextureInfo:(NSDictionary *)jsonDict
                              error:(NSError **)error;

- (nullable GLTFMaterialOcclusionTextureInfo *)
    decodeMaterialOcclusionTextureInfo:(NSDictionary *)jsonDict
                                 error:(NSError **)error;

- (nullable GLTFMaterialPBRMetallicRoughness *)
    decodeMaterialPBRMetallicRoughness:(NSDictionary *)jsonDict
                                 error:(NSError **)error;

- (nullable GLTFMesh *)decodeMesh:(NSDictionary *)jsonDict
                            error:(NSError **)error;
- (nullable GLTFMeshPrimitive *)decodeMeshPrimitive:(NSDictionary *)jsonDict
                                              error:(NSError **)error;

- (GLTFNode *)decodeNode:(NSDictionary *)jsonDict;

- (GLTFSampler *)decodeSampler:(NSDictionary *)jsonDict;

- (GLTFScene *)decodeScene:(NSDictionary *)jsonDict;

- (nullable GLTFSkin *)decodeSkin:(NSDictionary *)jsonDict
                            error:(NSError **)error;

- (GLTFTexture *)decodeTexture:(NSDictionary *)jsonDict;

- (nullable GLTFTextureInfo *)decodeTextureInfo:(NSDictionary *)jsonDict
                                          error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
