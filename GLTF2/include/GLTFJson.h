#import "GLTF2Availability.h"
#import <Foundation/Foundation.h>
#import <simd/simd.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Accessor

typedef NS_ENUM(NSInteger, GLTFAccessorSparseIndicesComponentType) {
  GLTFAccessorSparseIndicesComponentTypeUnsignedByte = 5121,
  GLTFAccessorSparseIndicesComponentTypeUnsignedShort = 5123,
  GLTFAccessorSparseIndicesComponentTypeUnsignedInt = 5125
};

GLTF_EXPORT @interface GLTFAccessorSparseIndices : NSObject

@property(nonatomic, assign) NSInteger bufferView;
@property(nonatomic, assign) NSInteger byteOffset;
@property(nonatomic, assign) NSInteger componentType;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

GLTF_EXPORT @interface GLTFAccessorSparseValues : NSObject

@property(nonatomic, assign) NSInteger bufferView;
@property(nonatomic, assign) NSInteger byteOffset;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

GLTF_EXPORT @interface GLTFAccessorSparse : NSObject

@property(nonatomic, assign) NSInteger count;
@property(nonatomic, strong) GLTFAccessorSparseIndices *indices;
@property(nonatomic, strong) GLTFAccessorSparseValues *values;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

typedef NS_ENUM(NSInteger, GLTFAccessorComponentType) {
  GLTFAccessorComponentTypeByte = 5120,
  GLTFAccessorComponentTypeUnsignedByte = 5121,
  GLTFAccessorComponentTypeShort = 5122,
  GLTFAccessorComponentTypeUnsignedShort = 5123,
  GLTFAccessorComponentTypeUnsignedInt = 5125,
  GLTFAccessorComponentTypeFloat = 5126
};

GLTF_EXPORT NSString *const GLTFAccessorTypeScalar;
GLTF_EXPORT NSString *const GLTFAccessorTypeVec2;
GLTF_EXPORT NSString *const GLTFAccessorTypeVec3;
GLTF_EXPORT NSString *const GLTFAccessorTypeVec4;
GLTF_EXPORT NSString *const GLTFAccessorTypeMat2;
GLTF_EXPORT NSString *const GLTFAccessorTypeMat3;
GLTF_EXPORT NSString *const GLTFAccessorTypeMat4;

GLTF_EXPORT NSInteger componentsCountOfAccessorType(NSString *accessorType);

GLTF_EXPORT NSInteger
sizeOfComponentType(GLTFAccessorComponentType componentType);

GLTF_EXPORT @interface GLTFAccessor : NSObject

@property(nonatomic, strong, nullable) NSNumber *bufferView;
@property(nonatomic, assign) NSInteger byteOffset;
@property(nonatomic, assign) NSInteger componentType;
@property(nonatomic, assign) BOOL normalized;
@property(nonatomic, assign) NSInteger count;
@property(nonatomic, assign) NSString *type;
@property(nonatomic, strong, nullable) NSArray<NSNumber *> *max;
@property(nonatomic, strong, nullable) NSArray<NSNumber *> *min;
@property(nonatomic, strong, nullable) GLTFAccessorSparse *sparse;
@property(nonatomic, copy, nullable) NSString *name;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

#pragma mark - Animation

GLTF_EXPORT NSString *const GLTFAnimationChannelTargetPathTranslation;
GLTF_EXPORT NSString *const GLTFAnimationChannelTargetPathRotation;
GLTF_EXPORT NSString *const GLTFAnimationChannelTargetPathScale;
GLTF_EXPORT NSString *const GLTFAnimationChannelTargetPathWeights;

GLTF_EXPORT @interface GLTFAnimationChannelTarget : NSObject

@property(nonatomic, strong, nullable) NSNumber *node;
@property(nonatomic, copy) NSString *path;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

GLTF_EXPORT NSString *const GLTFAnimationSamplerInterpolationLinear;
GLTF_EXPORT NSString *const GLTFAnimationSamplerInterpolationStep;
GLTF_EXPORT NSString *const GLTFAnimationSamplerInterpolationCubicSpline;

GLTF_EXPORT @interface GLTFAnimationSampler : NSObject

@property(nonatomic, assign) NSInteger input;
@property(nonatomic, copy) NSString *interpolation;
@property(nonatomic, assign) NSInteger output;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

GLTF_EXPORT @interface GLTFAnimationChannel : NSObject

@property(nonatomic, assign) NSInteger sampler;
@property(nonatomic, strong) GLTFAnimationChannelTarget *target;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

GLTF_EXPORT @interface GLTFAnimation : NSObject

@property(nonatomic, strong) NSArray<GLTFAnimationChannel *> *channels;
@property(nonatomic, strong) NSArray<GLTFAnimationSampler *> *samplers;
@property(nonatomic, copy, nullable) NSString *name;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

#pragma mark - Asset

GLTF_EXPORT @interface GLTFAsset : NSObject

@property(nonatomic, copy, nullable) NSString *copyright;
@property(nonatomic, copy, nullable) NSString *generator;
@property(nonatomic, copy) NSString *version;
@property(nonatomic, copy, nullable) NSString *minVersion;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

#pragma mark - Buffer

GLTF_EXPORT @interface GLTFBuffer : NSObject

@property(nonatomic, copy, nullable) NSString *uri;
@property(nonatomic, assign) NSInteger byteLength;
@property(nonatomic, copy, nullable) NSString *name;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

GLTF_EXPORT @interface GLTFBufferView : NSObject

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

GLTF_EXPORT @interface GLTFCameraOrthographic : NSObject

@property(nonatomic, assign) float xmag;
@property(nonatomic, assign) float ymag;
@property(nonatomic, assign) float zfar;
@property(nonatomic, assign) float znear;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

GLTF_EXPORT @interface GLTFCameraPerspective : NSObject

@property(nonatomic, strong, nullable) NSNumber *aspectRatio;
@property(nonatomic, assign) float yfov;
@property(nonatomic, strong, nullable) NSNumber *zfar;
@property(nonatomic, assign) float znear;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

GLTF_EXPORT @interface GLTFCamera : NSObject

@property(nonatomic, strong, nullable) GLTFCameraOrthographic *orthographic;
@property(nonatomic, strong, nullable) GLTFCameraPerspective *perspective;
@property(nonatomic, copy) NSString *type;
@property(nonatomic, copy, nullable) NSString *name;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

#pragma mark - Image

GLTF_EXPORT @interface GLTFImage : NSObject

@property(nonatomic, copy, nullable) NSString *uri;
@property(nonatomic, copy, nullable) NSString *mimeType;
@property(nonatomic, strong, nullable) NSNumber *bufferView;
@property(nonatomic, copy, nullable) NSString *name;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

#pragma mark - Texture

GLTF_EXPORT @interface GLTFTexture : NSObject

@property(nonatomic, strong, nullable) NSNumber *sampler;
@property(nonatomic, strong, nullable) NSNumber *source;
@property(nonatomic, copy, nullable) NSString *name;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

GLTF_EXPORT @interface GLTFTextureInfo : NSObject

@property(nonatomic, assign) NSInteger index;
@property(nonatomic, assign) NSInteger texCoord;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

#pragma mark - Material

GLTF_EXPORT @interface GLTFMaterialNormalTextureInfo : NSObject

@property(nonatomic, assign) NSInteger index;
@property(nonatomic, assign) NSInteger texCoord;
@property(nonatomic, assign) float scale;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

GLTF_EXPORT @interface GLTFMaterialOcclusionTextureInfo : NSObject

@property(nonatomic, assign) NSInteger index;
@property(nonatomic, assign) NSInteger texCoord;
@property(nonatomic, assign) float strength;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

GLTF_EXPORT @interface GLTFMaterialPBRMetallicRoughness : NSObject

@property(nonatomic, strong) NSArray<NSNumber *> *baseColorFactor;
@property(nonatomic, strong, nullable) GLTFTextureInfo *baseColorTexture;
@property(nonatomic, assign) float metallicFactor;
@property(nonatomic, assign) float roughnessFactor;
@property(nonatomic, strong, nullable)
    GLTFTextureInfo *metallicRoughnessTexture;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

GLTF_EXPORT NSString *const GLTFMaterialAlphaModeOpaque;
GLTF_EXPORT NSString *const GLTFMaterialAlphaModeMask;
GLTF_EXPORT NSString *const GLTFMaterialAlphaModeBlend;

GLTF_EXPORT @interface GLTFMaterial : NSObject

@property(nonatomic, copy, nullable) NSString *name;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;
@property(nonatomic, strong, nullable)
    GLTFMaterialPBRMetallicRoughness *pbrMetallicRoughness;
@property(nonatomic, strong, nullable)
    GLTFMaterialNormalTextureInfo *normalTexture;
@property(nonatomic, strong, nullable)
    GLTFMaterialOcclusionTextureInfo *occlusionTexture;
@property(nonatomic, strong, nullable) GLTFTextureInfo *emissiveTexture;
@property(nonatomic, strong) NSArray<NSNumber *> *emissiveFactor;
@property(nonatomic, copy) NSString *alphaMode;
@property(nonatomic, assign) float alphaCutoff;
@property(nonatomic, assign) BOOL doubleSided;

@end

#pragma mark - Mesh

GLTF_EXPORT @interface GLTFMesh : NSObject

@property(nonatomic, strong) NSArray<NSNumber *> *primitives;
@property(nonatomic, strong, nullable) NSArray<NSNumber *> *weights;
@property(nonatomic, copy, nullable) NSString *name;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

typedef NS_ENUM(NSInteger, GLTFMeshPrimitiveMode) {
  GLTFMeshPrimitiveModePoints = 0,
  GLTFMeshPrimitiveModeLines = 1,
  GLTFMeshPrimitiveModeLineLoop = 2,
  GLTFMeshPrimitiveModeLineStrip = 3,
  GLTFMeshPrimitiveModeTriangles = 4,
  GLTFMeshPrimitiveModeTriangleStrip = 5,
  GLTFMeshPrimitiveModeTriangleFan = 6
};

GLTF_EXPORT @interface GLTFMeshPrimitive : NSObject

@property(nonatomic, strong) NSDictionary<NSString *, NSNumber *> *attributes;
@property(nonatomic, strong, nullable) NSNumber *indices;
@property(nonatomic, strong, nullable) NSNumber *material;
@property(nonatomic, assign) NSInteger mode;
@property(nonatomic, strong, nullable) NSArray<NSNumber *> *targets;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

- (nullable NSNumber *)valueOfSemantic:(NSString *)semantic;
- (NSArray<NSNumber *> *)valuesOfSemantic:(NSString *)semantic;

@end

#pragma mark - Node

GLTF_EXPORT @interface GLTFNode : NSObject

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

typedef NS_ENUM(NSInteger, GLTFSamplerMagFilter) {
  GLTFSamplerMagFilterNearest = 9728,
  GLTFSamplerMagFilterLinear = 9729
};

typedef NS_ENUM(NSInteger, GLTFSamplerMinFilter) {
  GLTFSamplerMinFilterNearest = 9728,
  GLTFSamplerMinFilterLinear = 9729,
  GLTFSamplerMinFilterNearestMipmapNearest = 9984,
  GLTFSamplerMinFilterLinearMipmapNearest = 9985,
  GLTFSamplerMinFilterNearestMipmapLinear = 9986,
  GLTFSamplerMinFilterLinearMipmapLinear = 9987
};

typedef NS_ENUM(NSInteger, GLTFSamplerWrapMode) {
  GLTFSamplerWrapModeClampToEdge = 33071,
  GLTFSamplerWrapModeMirroredRepeat = 33648,
  GLTFSamplerWrapModeRepeat = 10497
};

GLTF_EXPORT @interface GLTFSampler : NSObject

@property(nonatomic, strong, nullable) NSNumber *magFilter;
@property(nonatomic, strong, nullable) NSNumber *minFilter;
@property(nonatomic, assign) NSInteger wrapS;
@property(nonatomic, assign) NSInteger wrapT;
@property(nonatomic, copy, nullable) NSString *name;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

#pragma mark - Scene

GLTF_EXPORT @interface GLTFScene : NSObject

@property(nonatomic, strong, nullable) NSArray<NSNumber *> *nodes;
@property(nonatomic, copy, nullable) NSString *name;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

#pragma mark - Skin

GLTF_EXPORT @interface GLTFSkin : NSObject

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
@property(nonatomic, strong, nullable) NSArray<GLTFAccessor *> *accessors;
@property(nonatomic, strong) GLTFAsset *asset;
@property(nonatomic, strong, nullable) NSArray<GLTFAnimation *> *animations;
@property(nonatomic, strong, nullable) NSArray<GLTFBuffer *> *buffers;
@property(nonatomic, strong, nullable) NSArray<GLTFBufferView *> *bufferViews;
@property(nonatomic, strong, nullable) NSArray<GLTFCamera *> *cameras;
@property(nonatomic, strong, nullable) NSArray<GLTFImage *> *images;
@property(nonatomic, strong, nullable) NSArray<GLTFMaterial *> *materials;
@property(nonatomic, strong, nullable) NSArray<GLTFMesh *> *meshes;
@property(nonatomic, strong, nullable) NSArray<GLTFNode *> *nodes;
@property(nonatomic, strong, nullable) NSArray<GLTFSampler *> *samplers;
@property(nonatomic, strong, nullable) NSNumber *scene;
@property(nonatomic, strong, nullable) NSArray<GLTFScene *> *scenes;
@property(nonatomic, strong, nullable) NSArray<GLTFSkin *> *skins;
@property(nonatomic, strong, nullable) NSArray<GLTFTexture *> *textures;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

NS_ASSUME_NONNULL_END
