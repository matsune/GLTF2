#import "GLTF2Availability.h"
#import "GLTFJson.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

GLTF_EXPORT @interface GLTFDecoder : NSObject

+ (nullable GLTFJson *)decodeJsonData:(NSData *)data
                                error:(NSError *_Nullable *_Nullable)error;

+ (nullable GLTFJson *)decodeJsonDict:(NSDictionary *)jsonDict
                                error:(NSError *_Nullable *)error;

- (nullable GLTFJson *)decodeJson:(NSDictionary *)jsonDict
                            error:(NSError *_Nullable *)error;

- (nullable GLTFAccessor *)decodeAccessor:(NSDictionary *)jsonDict
                                    error:(NSError *_Nullable *)error;

- (nullable GLTFAccessorSparse *)decodeAccessorSparse:(NSDictionary *)jsonDict
                                                error:
                                                    (NSError *_Nullable *)error;

- (nullable GLTFAccessorSparseIndices *)
    decodeAccessorSparseIndices:(NSDictionary *)jsonDict
                          error:(NSError *_Nullable *)error;

- (nullable GLTFAccessorSparseValues *)
    decodeAccessorSparseValues:(NSDictionary *)jsonDict
                         error:(NSError *_Nullable *)error;

- (nullable GLTFAnimation *)decodeAnimation:(NSDictionary *)jsonDict
                                      error:(NSError *_Nullable *)error;

- (nullable GLTFAnimationChannel *)
    decodeAnimationChannel:(NSDictionary *)jsonDict
                     error:(NSError *_Nullable *)error;

- (nullable GLTFAnimationChannelTarget *)
    decodeAnimationChannelTarget:(NSDictionary *)jsonDict
                           error:(NSError *_Nullable *)error;

- (nullable GLTFAnimationSampler *)
    decodeAnimationSampler:(NSDictionary *)jsonDict
                     error:(NSError *_Nullable *)error;

- (nullable GLTFAsset *)decodeAsset:(NSDictionary *)jsonDict
                              error:(NSError *_Nullable *)error;

- (nullable GLTFBuffer *)decodeBuffer:(NSDictionary *)jsonDict
                                error:(NSError *_Nullable *)error;

- (nullable GLTFBufferView *)decodeBufferView:(NSDictionary *)jsonDict
                                        error:(NSError *_Nullable *)error;

- (nullable GLTFCamera *)decodeCamera:(NSDictionary *)jsonDict
                                error:(NSError *_Nullable *)error;

- (nullable GLTFCameraOrthographic *)
    decodeCameraOrthographic:(NSDictionary *)jsonDict
                       error:(NSError *_Nullable *)error;
- (nullable GLTFCameraPerspective *)
    decodeCameraPerspective:(NSDictionary *)jsonDict
                      error:(NSError *_Nullable *)error;

- (GLTFImage *)decodeImage:(NSDictionary *)jsonDict;

- (nullable GLTFMaterial *)decodeMaterial:(NSDictionary *)jsonDict
                                    error:(NSError *_Nullable *)error;

- (nullable GLTFMaterialNormalTextureInfo *)
    decodeMaterialNormalTextureInfo:(NSDictionary *)jsonDict
                              error:(NSError *_Nullable *)error;

- (nullable GLTFMaterialOcclusionTextureInfo *)
    decodeMaterialOcclusionTextureInfo:(NSDictionary *)jsonDict
                                 error:(NSError *_Nullable *)error;

- (nullable GLTFMaterialPBRMetallicRoughness *)
    decodeMaterialPBRMetallicRoughness:(NSDictionary *)jsonDict
                                 error:(NSError *_Nullable *)error;

- (nullable GLTFMesh *)decodeMesh:(NSDictionary *)jsonDict
                            error:(NSError *_Nullable *)error;
- (nullable GLTFMeshPrimitive *)decodeMeshPrimitive:(NSDictionary *)jsonDict
                                              error:(NSError *_Nullable *)error;

- (GLTFNode *)decodeNode:(NSDictionary *)jsonDict;

- (GLTFSampler *)decodeSampler:(NSDictionary *)jsonDict;

- (GLTFScene *)decodeScene:(NSDictionary *)jsonDict;

- (nullable GLTFSkin *)decodeSkin:(NSDictionary *)jsonDict
                            error:(NSError *_Nullable *)error;

- (GLTFTexture *)decodeTexture:(NSDictionary *)jsonDict;

- (nullable GLTFTextureInfo *)decodeTextureInfo:(NSDictionary *)jsonDict
                                          error:(NSError *_Nullable *)error;

@end

NS_ASSUME_NONNULL_END
