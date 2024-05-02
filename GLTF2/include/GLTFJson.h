#import <Foundation/Foundation.h>
#import <simd/simd.h>
#import "GLTF2Availability.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Accessor

typedef NS_ENUM(NSInteger, GLTFJSONAccessorSparseIndicesComponentType) {
  GLTFJSONAccessorSparseIndicesComponentTypeUnsignedByte = 5121,
  GLTFJSONAccessorSparseIndicesComponentTypeUnsignedShort = 5123,
  GLTFJSONAccessorSparseIndicesComponentTypeUnsignedInt = 5125
};

GLTF_EXPORT @interface GLTFJSONAccessorSparseIndices : NSObject

@property(nonatomic, assign) NSInteger bufferView;
@property(nonatomic, assign) NSInteger byteOffset;
@property(nonatomic, assign) NSInteger componentType;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

GLTF_EXPORT @interface GLTFJSONAccessorSparseValues : NSObject

@property(nonatomic, assign) NSInteger bufferView;
@property(nonatomic, assign) NSInteger byteOffset;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

GLTF_EXPORT @interface GLTFJSONAccessorSparse : NSObject

@property(nonatomic, assign) NSInteger count;
@property(nonatomic, strong) GLTFJSONAccessorSparseIndices *indices;
@property(nonatomic, strong) GLTFJSONAccessorSparseValues *values;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

typedef NS_ENUM(NSInteger, GLTFJSONAccessorComponentType) {
  GLTFJSONAccessorComponentTypeByte = 5120,
  GLTFJSONAccessorComponentTypeUnsignedByte = 5121,
  GLTFJSONAccessorComponentTypeShort = 5122,
  GLTFJSONAccessorComponentTypeUnsignedShort = 5123,
  GLTFJSONAccessorComponentTypeUnsignedInt = 5125,
  GLTFJSONAccessorComponentTypeFloat = 5126
};

GLTF_EXPORT NSString *const GLTFJSONAccessorTypeScalar;
GLTF_EXPORT NSString *const GLTFJSONAccessorTypeVec2;
GLTF_EXPORT NSString *const GLTFJSONAccessorTypeVec3;
GLTF_EXPORT NSString *const GLTFJSONAccessorTypeVec4;
GLTF_EXPORT NSString *const GLTFJSONAccessorTypeMat2;
GLTF_EXPORT NSString *const GLTFJSONAccessorTypeMat3;
GLTF_EXPORT NSString *const GLTFJSONAccessorTypeMat4;

GLTF_EXPORT @interface GLTFJSONAccessor : NSObject

@property(nonatomic, strong, nullable) NSNumber *bufferView;
@property(nonatomic, assign) NSInteger byteOffset;
@property(nonatomic, assign) NSInteger componentType;
@property(nonatomic, assign) BOOL normalized;
@property(nonatomic, assign) NSInteger count;
@property(nonatomic, assign) NSString *type;
@property(nonatomic, strong, nullable) NSArray<NSNumber *> *max;
@property(nonatomic, strong, nullable) NSArray<NSNumber *> *min;
@property(nonatomic, strong, nullable) GLTFJSONAccessorSparse *sparse;
@property(nonatomic, copy, nullable) NSString *name;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

#pragma mark - Animation

GLTF_EXPORT NSString *const GLTFJSONAnimationChannelTargetPathTranslation;
GLTF_EXPORT NSString *const GLTFJSONAnimationChannelTargetPathRotation;
GLTF_EXPORT NSString *const GLTFJSONAnimationChannelTargetPathScale;
GLTF_EXPORT NSString *const GLTFJSONAnimationChannelTargetPathWeights;

GLTF_EXPORT @interface GLTFJSONAnimationChannelTarget : NSObject

@property(nonatomic, strong, nullable) NSNumber *node;
@property(nonatomic, copy) NSString *path;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

GLTF_EXPORT NSString *const GLTFJSONAnimationSamplerInterpolationLinear;
GLTF_EXPORT NSString *const GLTFJSONAnimationSamplerInterpolationStep;
GLTF_EXPORT NSString *const GLTFJSONAnimationSamplerInterpolationCubicSpline;

GLTF_EXPORT @interface GLTFJSONAnimationSampler : NSObject

@property(nonatomic, assign) NSInteger input;
@property(nonatomic, copy) NSString *interpolation;
@property(nonatomic, assign) NSInteger output;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

GLTF_EXPORT @interface GLTFJSONAnimationChannel : NSObject

@property(nonatomic, assign) NSInteger sampler;
@property(nonatomic, strong) GLTFJSONAnimationChannelTarget *target;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

GLTF_EXPORT @interface GLTFJSONAnimation : NSObject

@property(nonatomic, strong) NSArray<GLTFJSONAnimationChannel *> *channels;
@property(nonatomic, strong) NSArray<GLTFJSONAnimationSampler *> *samplers;
@property(nonatomic, copy, nullable) NSString *name;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

#pragma mark - Asset

GLTF_EXPORT @interface GLTFJSONAsset : NSObject

@property(nonatomic, copy, nullable) NSString *copyright;
@property(nonatomic, copy, nullable) NSString *generator;
@property(nonatomic, copy) NSString *version;
@property(nonatomic, copy, nullable) NSString *minVersion;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

#pragma mark - Buffer

GLTF_EXPORT @interface GLTFJSONBuffer : NSObject

@property(nonatomic, copy, nullable) NSString *uri;
@property(nonatomic, assign) NSInteger byteLength;
@property(nonatomic, copy, nullable) NSString *name;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

GLTF_EXPORT @interface GLTFJSONBufferView : NSObject

@property(nonatomic, assign) NSInteger buffer;
@property(nonatomic, assign) NSInteger byteOffset;
@property(nonatomic, assign) NSInteger byteLength;
@property(nonatomic, strong, nullable) NSNumber *byteStride;
@property(nonatomic, strong, nullable) NSNumber *target;
@property(nonatomic, copy, nullable) NSString *name;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

#pragma mark - Camera

GLTF_EXPORT @interface GLTFJSONCameraOrthographic : NSObject

@property(nonatomic, assign) float xmag;
@property(nonatomic, assign) float ymag;
@property(nonatomic, assign) float zfar;
@property(nonatomic, assign) float znear;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

GLTF_EXPORT @interface GLTFJSONCameraPerspective : NSObject

@property(nonatomic, strong, nullable) NSNumber *aspectRatio;
@property(nonatomic, assign) float yfov;
@property(nonatomic, strong, nullable) NSNumber *zfar;
@property(nonatomic, assign) float znear;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

GLTF_EXPORT @interface GLTFJSONCamera : NSObject

@property(nonatomic, strong, nullable) GLTFJSONCameraOrthographic *orthographic;
@property(nonatomic, strong, nullable) GLTFJSONCameraPerspective *perspective;
@property(nonatomic, copy) NSString *type;
@property(nonatomic, copy, nullable) NSString *name;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

#pragma mark - Image

GLTF_EXPORT @interface GLTFJSONImage : NSObject

@property(nonatomic, copy, nullable) NSString *uri;
@property(nonatomic, copy, nullable) NSString *mimeType;
@property(nonatomic, strong, nullable) NSNumber *bufferView;
@property(nonatomic, copy, nullable) NSString *name;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

#pragma mark - Texture

GLTF_EXPORT @interface GLTFJSONTexture : NSObject

@property(nonatomic, strong, nullable) NSNumber *sampler;
@property(nonatomic, strong, nullable) NSNumber *source;
@property(nonatomic, copy, nullable) NSString *name;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

GLTF_EXPORT @interface GLTFJSONTextureInfo : NSObject

@property(nonatomic, assign) NSInteger index;
@property(nonatomic, assign) NSInteger texCoord;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

#pragma mark - Material

GLTF_EXPORT @interface GLTFJSONMaterialNormalTextureInfo : NSObject

@property(nonatomic, assign) NSInteger index;
@property(nonatomic, assign) NSInteger texCoord;
@property(nonatomic, assign) float scale;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

GLTF_EXPORT @interface GLTFJSONMaterialOcclusionTextureInfo : NSObject

@property(nonatomic, assign) NSInteger index;
@property(nonatomic, assign) NSInteger texCoord;
@property(nonatomic, assign) float strength;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

GLTF_EXPORT @interface GLTFJSONMaterialPBRMetallicRoughness : NSObject

@property(nonatomic, strong) NSArray<NSNumber *> *baseColorFactor;
@property(nonatomic, strong, nullable) GLTFJSONTextureInfo *baseColorTexture;
@property(nonatomic, assign) float metallicFactor;
@property(nonatomic, assign) float roughnessFactor;
@property(nonatomic, strong, nullable)
    GLTFJSONTextureInfo *metallicRoughnessTexture;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

GLTF_EXPORT NSString *const GLTFJSONMaterialAlphaModeOpaque;
GLTF_EXPORT NSString *const GLTFJSONMaterialAlphaModeMask;
GLTF_EXPORT NSString *const GLTFJSONMaterialAlphaModeBlend;

GLTF_EXPORT @interface GLTFJSONMaterial : NSObject

@property(nonatomic, copy, nullable) NSString *name;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;
@property(nonatomic, strong, nullable)
    GLTFJSONMaterialPBRMetallicRoughness *pbrMetallicRoughness;
@property(nonatomic, strong, nullable)
    GLTFJSONMaterialNormalTextureInfo *normalTexture;
@property(nonatomic, strong, nullable)
    GLTFJSONMaterialOcclusionTextureInfo *occlusionTexture;
@property(nonatomic, strong, nullable) GLTFJSONTextureInfo *emissiveTexture;
@property(nonatomic, strong) NSArray<NSNumber *> *emissiveFactor;
@property(nonatomic, copy) NSString *alphaMode;
@property(nonatomic, assign) float alphaCutoff;
@property(nonatomic, assign) BOOL doubleSided;

@end

#pragma mark - Mesh

GLTF_EXPORT @interface GLTFJSONMesh : NSObject

@property(nonatomic, strong) NSArray<NSNumber *> *primitives;
@property(nonatomic, strong, nullable) NSArray<NSNumber *> *weights;
@property(nonatomic, copy, nullable) NSString *name;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

typedef NS_ENUM(NSInteger, GLTFJSONMeshPrimitiveMode) {
  GLTFJSONMeshPrimitiveModePoints = 0,
  GLTFJSONMeshPrimitiveModeLines = 1,
  GLTFJSONMeshPrimitiveModeLineLoop = 2,
  GLTFJSONMeshPrimitiveModeLineStrip = 3,
  GLTFJSONMeshPrimitiveModeTriangles = 4,
  GLTFJSONMeshPrimitiveModeTriangleStrip = 5,
  GLTFJSONMeshPrimitiveModeTriangleFan = 6
};

GLTF_EXPORT @interface GLTFJSONMeshPrimitive : NSObject

@property(nonatomic, strong) NSDictionary<NSString *, NSNumber *> *attributes;
@property(nonatomic, strong, nullable) NSNumber *indices;
@property(nonatomic, strong, nullable) NSNumber *material;
@property(nonatomic, assign) NSInteger mode;
@property(nonatomic, strong, nullable) NSArray<NSNumber *> *targets;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

#pragma mark - Node

GLTF_EXPORT @interface GLTFJSONNode : NSObject

@property(nonatomic, strong, nullable) NSNumber *camera;
@property(nonatomic, strong, nullable) NSArray<NSNumber *> *children;
@property(nonatomic, strong, nullable) NSNumber *skin;
@property(nonatomic, assign) simd_float4x4 matrix;
@property(nonatomic, strong, nullable) NSNumber *mesh;
@property(nonatomic, strong) NSArray<NSNumber *> *rotation;    // number[4]
@property(nonatomic, strong) NSArray<NSNumber *> *scale;       // number[3]
@property(nonatomic, strong) NSArray<NSNumber *> *translation; // number[3]
@property(nonatomic, strong, nullable) NSArray<NSNumber *> *weights;
@property(nonatomic, copy, nullable) NSString *name;
@property(nonatomic, copy, nullable) NSDictionary *extensions;
@property(nonatomic, copy, nullable) NSDictionary *extras;

@end

#pragma mark - Sampler

typedef NS_ENUM(NSInteger, GLTFJSONSamplerMagFilter) {
  GLTFJSONSamplerMagFilterNearest = 9728,
  GLTFJSONSamplerMagFilterLinear = 9729
};

typedef NS_ENUM(NSInteger, GLTFJSONSamplerMinFilter) {
  GLTFJSONSamplerMinFilterNearest = 9728,
  GLTFJSONSamplerMinFilterLinear = 9729,
  GLTFJSONSamplerMinFilterNearestMipmapNearest = 9984,
  GLTFJSONSamplerMinFilterLinearMipmapNearest = 9985,
  GLTFJSONSamplerMinFilterNearestMipmapLinear = 9986,
  GLTFJSONSamplerMinFilterLinearMipmapLinear = 9987
};

typedef NS_ENUM(NSInteger, GLTFJSONSamplerWrapMode) {
  GLTFJSONSamplerWrapModeClampToEdge = 33071,
  GLTFJSONSamplerWrapModeMirroredRepeat = 33648,
  GLTFJSONSamplerWrapModeRepeat = 10497
};

GLTF_EXPORT @interface GLTFJSONSampler : NSObject

@property(nonatomic, strong, nullable) NSNumber *magFilter;
@property(nonatomic, strong, nullable) NSNumber *minFilter;
@property(nonatomic, assign) NSInteger wrapS;
@property(nonatomic, assign) NSInteger wrapT;
@property(nonatomic, copy, nullable) NSString *name;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

#pragma mark - Scene

GLTF_EXPORT @interface GLTFJSONScene : NSObject

@property(nonatomic, strong, nullable) NSArray<NSNumber *> *nodes;
@property(nonatomic, copy, nullable) NSString *name;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

#pragma mark - Skin

GLTF_EXPORT @interface GLTFJSONSkin : NSObject

@property(nonatomic, strong, nullable) NSNumber *inverseBindMatrices;
@property(nonatomic, strong, nullable) NSNumber *skeleton;
@property(nonatomic, strong) NSArray<NSNumber *> *joints;
@property(nonatomic, copy, nullable) NSString *name;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

#pragma mark - Json

GLTF_EXPORT @interface GLTFJson : NSObject

@property(nonatomic, copy, nullable) NSArray<NSString *> *extensionsUsed;
@property(nonatomic, copy, nullable) NSArray<NSString *> *extensionsRequired;
@property(nonatomic, strong, nullable) NSArray<GLTFJSONAccessor *> *accessors;
@property(nonatomic, strong) GLTFJSONAsset *asset;
@property(nonatomic, strong, nullable) NSArray<GLTFJSONAnimation *> *animations;
@property(nonatomic, strong, nullable) NSArray<GLTFJSONBuffer *> *buffers;
@property(nonatomic, strong, nullable)
    NSArray<GLTFJSONBufferView *> *bufferViews;
@property(nonatomic, strong, nullable) NSArray<GLTFJSONCamera *> *cameras;
@property(nonatomic, strong, nullable) NSArray<GLTFJSONImage *> *images;
@property(nonatomic, strong, nullable) NSArray<GLTFJSONMaterial *> *materials;
@property(nonatomic, strong, nullable) NSArray<GLTFJSONMesh *> *meshes;
@property(nonatomic, strong, nullable) NSArray<GLTFJSONNode *> *nodes;
@property(nonatomic, strong, nullable) NSArray<GLTFJSONSampler *> *samplers;
@property(nonatomic, strong, nullable) NSNumber *scene;
@property(nonatomic, strong, nullable) NSArray<GLTFJSONScene *> *scenes;
@property(nonatomic, strong, nullable) NSArray<GLTFJSONSkin *> *skins;
@property(nonatomic, strong, nullable) NSArray<GLTFJSONTexture *> *textures;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

NS_ASSUME_NONNULL_END
