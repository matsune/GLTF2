#import "GLTFJson.h"
#import "GLTFJSONMeshPrimitive.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GLTFJSONDecoder : NSObject

+ (nullable GLTFJson *)decodeJsonData:(NSData *)data
                                error:(NSError *_Nullable *_Nullable)error;

+ (nullable GLTFJson *)decodeJsonDict:(NSDictionary *)jsonDict
                                error:(NSError *_Nullable *)error;

- (nullable GLTFJson *)decodeJson:(NSDictionary *)jsonDict
                            error:(NSError *_Nullable *)error;

- (nullable GLTFJSONAccessor *)decodeAccessor:(NSDictionary *)jsonDict
                                    error:(NSError *_Nullable *)error;

- (nullable GLTFJSONAccessorSparse *)decodeAccessorSparse:(NSDictionary *)jsonDict
                                                error:
                                                    (NSError *_Nullable *)error;

- (nullable GLTFJSONAccessorSparseIndices *)
    decodeAccessorSparseIndices:(NSDictionary *)jsonDict
                          error:(NSError *_Nullable *)error;

- (nullable GLTFJSONAccessorSparseValues *)
    decodeAccessorSparseValues:(NSDictionary *)jsonDict
                         error:(NSError *_Nullable *)error;

- (nullable GLTFJSONAnimation *)decodeAnimation:(NSDictionary *)jsonDict
                                      error:(NSError *_Nullable *)error;

- (nullable GLTFJSONAnimationChannel *)
    decodeAnimationChannel:(NSDictionary *)jsonDict
                     error:(NSError *_Nullable *)error;

- (nullable GLTFJSONAnimationChannelTarget *)
    decodeAnimationChannelTarget:(NSDictionary *)jsonDict
                           error:(NSError *_Nullable *)error;

- (nullable GLTFJSONAnimationSampler *)
    decodeAnimationSampler:(NSDictionary *)jsonDict
                     error:(NSError *_Nullable *)error;

- (nullable GLTFJSONAsset *)decodeAsset:(NSDictionary *)jsonDict
                              error:(NSError *_Nullable *)error;

- (nullable GLTFJSONBuffer *)decodeBuffer:(NSDictionary *)jsonDict
                                error:(NSError *_Nullable *)error;

- (nullable GLTFJSONBufferView *)decodeBufferView:(NSDictionary *)jsonDict
                                        error:(NSError *_Nullable *)error;

- (nullable GLTFJSONCamera *)decodeCamera:(NSDictionary *)jsonDict
                                error:(NSError *_Nullable *)error;

- (nullable GLTFJSONCameraOrthographic *)
    decodeCameraOrthographic:(NSDictionary *)jsonDict
                       error:(NSError *_Nullable *)error;
- (nullable GLTFJSONCameraPerspective *)
    decodeCameraPerspective:(NSDictionary *)jsonDict
                      error:(NSError *_Nullable *)error;

- (GLTFJSONImage *)decodeImage:(NSDictionary *)jsonDict;

- (nullable GLTFJSONMaterial *)decodeMaterial:(NSDictionary *)jsonDict
                                    error:(NSError *_Nullable *)error;

- (nullable GLTFJSONMaterialNormalTextureInfo *)
    decodeMaterialNormalTextureInfo:(NSDictionary *)jsonDict
                              error:(NSError *_Nullable *)error;

- (nullable GLTFJSONMaterialOcclusionTextureInfo *)
    decodeMaterialOcclusionTextureInfo:(NSDictionary *)jsonDict
                                 error:(NSError *_Nullable *)error;

- (nullable GLTFJSONMaterialPBRMetallicRoughness *)
    decodeMaterialPBRMetallicRoughness:(NSDictionary *)jsonDict
                                 error:(NSError *_Nullable *)error;

- (nullable GLTFJSONMesh *)decodeMesh:(NSDictionary *)jsonDict
                            error:(NSError *_Nullable *)error;
- (nullable GLTFJSONMeshPrimitive *)decodeMeshPrimitive:(NSDictionary *)jsonDict
                                              error:(NSError *_Nullable *)error;

- (GLTFJSONNode *)decodeNode:(NSDictionary *)jsonDict;

- (GLTFJSONSampler *)decodeSampler:(NSDictionary *)jsonDict;

- (GLTFJSONScene *)decodeScene:(NSDictionary *)jsonDict;

- (nullable GLTFJSONSkin *)decodeSkin:(NSDictionary *)jsonDict
                            error:(NSError *_Nullable *)error;

- (GLTFJSONTexture *)decodeTexture:(NSDictionary *)jsonDict;

- (nullable GLTFJSONTextureInfo *)decodeTextureInfo:(NSDictionary *)jsonDict
                                          error:(NSError *_Nullable *)error;

@end

NS_ASSUME_NONNULL_END
