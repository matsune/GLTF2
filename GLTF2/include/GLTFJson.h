#import "GLTF2Availability.h"
#import <Foundation/Foundation.h>
#import <simd/simd.h>

NS_ASSUME_NONNULL_BEGIN

GLTF_EXPORT @interface GLTFObject : NSObject

@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

#pragma mark - Accessor

typedef NS_ENUM(NSInteger, GLTFAccessorSparseIndicesComponentType) {
  GLTFAccessorSparseIndicesComponentTypeUnsignedByte = 5121,
  GLTFAccessorSparseIndicesComponentTypeUnsignedShort = 5123,
  GLTFAccessorSparseIndicesComponentTypeUnsignedInt = 5125
};

GLTF_EXPORT @interface GLTFAccessorSparseIndices : GLTFObject

@property(nonatomic, assign) NSInteger bufferView;
@property(nonatomic, strong, nullable) NSNumber *byteOffset;
@property(nonatomic, assign) NSInteger componentType;

@property(nonatomic, readonly) NSInteger byteOffsetValue;

@end

GLTF_EXPORT @interface GLTFAccessorSparseValues : GLTFObject

@property(nonatomic, assign) NSInteger bufferView;
@property(nonatomic, strong, nullable) NSNumber *byteOffset;

@property(nonatomic, readonly) NSInteger byteOffsetValue;

@end

GLTF_EXPORT @interface GLTFAccessorSparse : GLTFObject

@property(nonatomic, assign) NSInteger count;
@property(nonatomic, strong) GLTFAccessorSparseIndices *indices;
@property(nonatomic, strong) GLTFAccessorSparseValues *values;

@end

typedef NS_ENUM(NSInteger, GLTFAccessorComponentType) {
  GLTFAccessorComponentTypeByte = 5120,
  GLTFAccessorComponentTypeUnsignedByte = 5121,
  GLTFAccessorComponentTypeShort = 5122,
  GLTFAccessorComponentTypeUnsignedShort = 5123,
  GLTFAccessorComponentTypeUnsignedInt = 5125,
  GLTFAccessorComponentTypeFloat = 5126
};

GLTF_EXPORT NSInteger
sizeOfComponentType(GLTFAccessorComponentType componentType);

GLTF_EXPORT NSString *const GLTFAccessorTypeScalar;
GLTF_EXPORT NSString *const GLTFAccessorTypeVec2;
GLTF_EXPORT NSString *const GLTFAccessorTypeVec3;
GLTF_EXPORT NSString *const GLTFAccessorTypeVec4;
GLTF_EXPORT NSString *const GLTFAccessorTypeMat2;
GLTF_EXPORT NSString *const GLTFAccessorTypeMat3;
GLTF_EXPORT NSString *const GLTFAccessorTypeMat4;

GLTF_EXPORT NSInteger componentsCountOfAccessorType(NSString *accessorType);

GLTF_EXPORT @interface GLTFAccessor : GLTFObject

@property(nonatomic, strong, nullable) NSNumber *bufferView;
@property(nonatomic, strong, nullable) NSNumber *byteOffset;
@property(nonatomic, assign) NSInteger componentType;
@property(nonatomic, strong, nullable) NSNumber *normalized;
@property(nonatomic, assign) NSInteger count;
@property(nonatomic, assign) NSString *type;
@property(nonatomic, strong, nullable) NSArray<NSNumber *> *max;
@property(nonatomic, strong, nullable) NSArray<NSNumber *> *min;
@property(nonatomic, strong, nullable) GLTFAccessorSparse *sparse;
@property(nonatomic, copy, nullable) NSString *name;

@property(nonatomic, readonly) NSInteger byteOffsetValue;
@property(nonatomic, readonly) BOOL isNormalized;

@end

#pragma mark - Animation

GLTF_EXPORT NSString *const GLTFAnimationChannelTargetPathTranslation;
GLTF_EXPORT NSString *const GLTFAnimationChannelTargetPathRotation;
GLTF_EXPORT NSString *const GLTFAnimationChannelTargetPathScale;
GLTF_EXPORT NSString *const GLTFAnimationChannelTargetPathWeights;

GLTF_EXPORT @interface GLTFAnimationChannelTarget : GLTFObject

@property(nonatomic, strong, nullable) NSNumber *node;
@property(nonatomic, copy) NSString *path;

@property(nonatomic, readonly) BOOL isPathTranslation;
@property(nonatomic, readonly) BOOL isPathRotation;
@property(nonatomic, readonly) BOOL isPathScale;
@property(nonatomic, readonly) BOOL isPathWeights;

@end

GLTF_EXPORT NSString *const GLTFAnimationSamplerInterpolationLinear;
GLTF_EXPORT NSString *const GLTFAnimationSamplerInterpolationStep;
GLTF_EXPORT NSString *const GLTFAnimationSamplerInterpolationCubicSpline;

GLTF_EXPORT @interface GLTFAnimationSampler : GLTFObject

@property(nonatomic, assign) NSInteger input;
@property(nonatomic, copy, nullable) NSString *interpolation;
@property(nonatomic, assign) NSInteger output;

@property(nonatomic, readonly) NSString *interpolationValue;

@end

GLTF_EXPORT @interface GLTFAnimationChannel : GLTFObject

@property(nonatomic, assign) NSInteger sampler;
@property(nonatomic, strong) GLTFAnimationChannelTarget *target;

@end

GLTF_EXPORT @interface GLTFAnimation : GLTFObject

@property(nonatomic, strong) NSArray<GLTFAnimationChannel *> *channels;
@property(nonatomic, strong) NSArray<GLTFAnimationSampler *> *samplers;
@property(nonatomic, copy, nullable) NSString *name;

@end

#pragma mark - Asset

GLTF_EXPORT @interface GLTFAsset : GLTFObject

@property(nonatomic, copy, nullable) NSString *copyright;
@property(nonatomic, copy, nullable) NSString *generator;
@property(nonatomic, copy) NSString *version;
@property(nonatomic, copy, nullable) NSString *minVersion;

@end

#pragma mark - Buffer

GLTF_EXPORT @interface GLTFBuffer : GLTFObject

@property(nonatomic, copy, nullable) NSString *uri;
@property(nonatomic, assign) NSInteger byteLength;
@property(nonatomic, copy, nullable) NSString *name;

@end

GLTF_EXPORT @interface GLTFBufferView : GLTFObject

@property(nonatomic, assign) NSInteger buffer;
@property(nonatomic, strong, nullable) NSNumber *byteOffset;
@property(nonatomic, assign) NSInteger byteLength;
@property(nonatomic, strong, nullable) NSNumber *byteStride;
@property(nonatomic, strong, nullable) NSNumber *target;
@property(nonatomic, copy, nullable) NSString *name;

@property(nonatomic, readonly) NSInteger byteOffsetValue;

@end

#pragma mark - Camera

GLTF_EXPORT @interface GLTFCameraOrthographic : GLTFObject

@property(nonatomic, assign) float xmag;
@property(nonatomic, assign) float ymag;
@property(nonatomic, assign) float zfar;
@property(nonatomic, assign) float znear;

@end

GLTF_EXPORT @interface GLTFCameraPerspective : GLTFObject

@property(nonatomic, strong, nullable) NSNumber *aspectRatio;
@property(nonatomic, assign) float yfov;
@property(nonatomic, strong, nullable) NSNumber *zfar;
@property(nonatomic, assign) float znear;

@end

GLTF_EXPORT NSString *const GLTFCameraTypePerspective;
GLTF_EXPORT NSString *const GLTFCameraTypeOrthographic;

GLTF_EXPORT @interface GLTFCamera : GLTFObject

@property(nonatomic, strong, nullable) GLTFCameraOrthographic *orthographic;
@property(nonatomic, strong, nullable) GLTFCameraPerspective *perspective;
@property(nonatomic, copy) NSString *type;
@property(nonatomic, copy, nullable) NSString *name;

@end

#pragma mark - Image

GLTF_EXPORT @interface GLTFImage : GLTFObject

@property(nonatomic, copy, nullable) NSString *uri;
@property(nonatomic, copy, nullable) NSString *mimeType;
@property(nonatomic, strong, nullable) NSNumber *bufferView;
@property(nonatomic, copy, nullable) NSString *name;

@end

#pragma mark - Texture

GLTF_EXPORT @interface GLTFTexture : GLTFObject

@property(nonatomic, strong, nullable) NSNumber *sampler;
@property(nonatomic, strong, nullable) NSNumber *source;
@property(nonatomic, copy, nullable) NSString *name;

@end

GLTF_EXPORT @interface GLTFTextureInfo : GLTFObject

@property(nonatomic, assign) NSInteger index;
@property(nonatomic, strong, nullable) NSNumber *texCoord;

@property(nonatomic, readonly) NSInteger texCoordValue;

@end

#pragma mark - Material

GLTF_EXPORT @interface GLTFMaterialNormalTextureInfo : GLTFTextureInfo

@property(nonatomic, strong, nullable) NSNumber *scale;

@property(nonatomic, readonly) float scaleValue;

@end

GLTF_EXPORT @interface GLTFMaterialOcclusionTextureInfo : GLTFTextureInfo

@property(nonatomic, strong, nullable) NSNumber *strength;

@property(nonatomic, readonly) float strengthValue;

@end

GLTF_EXPORT @interface GLTFMaterialPBRMetallicRoughness : GLTFObject

@property(nonatomic, strong, nullable) NSArray<NSNumber *> *baseColorFactor;
@property(nonatomic, strong, nullable) GLTFTextureInfo *baseColorTexture;
@property(nonatomic, strong, nullable) NSNumber *metallicFactor;
@property(nonatomic, strong, nullable) NSNumber *roughnessFactor;
@property(nonatomic, strong, nullable)
    GLTFTextureInfo *metallicRoughnessTexture;

@property(nonatomic, readonly) simd_float4 baseColorFactorValue;
@property(nonatomic, readonly) float metallicFactorValue;
@property(nonatomic, readonly) float roughnessFactorValue;

@end

GLTF_EXPORT NSString *const GLTFMaterialAlphaModeOpaque;
GLTF_EXPORT NSString *const GLTFMaterialAlphaModeMask;
GLTF_EXPORT NSString *const GLTFMaterialAlphaModeBlend;

GLTF_EXPORT @interface GLTFMaterial : GLTFObject

@property(nonatomic, copy, nullable) NSString *name;
@property(nonatomic, strong, nullable)
    GLTFMaterialPBRMetallicRoughness *pbrMetallicRoughness;
@property(nonatomic, strong, nullable)
    GLTFMaterialNormalTextureInfo *normalTexture;
@property(nonatomic, strong, nullable)
    GLTFMaterialOcclusionTextureInfo *occlusionTexture;
@property(nonatomic, strong, nullable) GLTFTextureInfo *emissiveTexture;
@property(nonatomic, strong, nullable) NSArray<NSNumber *> *emissiveFactor;
@property(nonatomic, copy, nullable) NSString *alphaMode;
@property(nonatomic, strong, nullable) NSNumber *alphaCutoff;
@property(nonatomic, strong, nullable) NSNumber *doubleSided;

@property(nonatomic, readonly) simd_float3 emissiveFactorValue;
@property(nonatomic, readonly) NSString *alphaModeValue;
@property(nonatomic, readonly) float alphaCutoffValue;
@property(nonatomic, readonly) BOOL isDoubleSided;
@property(nonatomic, readonly) BOOL isAlphaModeOpaque;
@property(nonatomic, readonly) BOOL isAlphaModeMask;
@property(nonatomic, readonly) BOOL isAlphaModeBlend;

@end

#pragma mark - Mesh

typedef NS_ENUM(NSInteger, GLTFMeshPrimitiveMode) {
  GLTFMeshPrimitiveModePoints = 0,
  GLTFMeshPrimitiveModeLines = 1,
  GLTFMeshPrimitiveModeLineLoop = 2,
  GLTFMeshPrimitiveModeLineStrip = 3,
  GLTFMeshPrimitiveModeTriangles = 4,
  GLTFMeshPrimitiveModeTriangleStrip = 5,
  GLTFMeshPrimitiveModeTriangleFan = 6
};

GLTF_EXPORT NSString *const GLTFMeshPrimitiveAttributeSemanticPosition;
GLTF_EXPORT NSString *const GLTFMeshPrimitiveAttributeSemanticNormal;
GLTF_EXPORT NSString *const GLTFMeshPrimitiveAttributeSemanticTangent;
GLTF_EXPORT NSString *const GLTFMeshPrimitiveAttributeSemanticTexcoord;
GLTF_EXPORT NSString *const GLTFMeshPrimitiveAttributeSemanticColor;
GLTF_EXPORT NSString *const GLTFMeshPrimitiveAttributeSemanticJoints;
GLTF_EXPORT NSString *const GLTFMeshPrimitiveAttributeSemanticWeights;

GLTF_EXPORT @interface GLTFMeshPrimitiveTarget : GLTFObject

@property(nonatomic, strong, nullable) NSNumber *position;
@property(nonatomic, strong, nullable) NSNumber *normal;
@property(nonatomic, strong, nullable) NSNumber *tangent;

@end

GLTF_EXPORT @interface GLTFMeshPrimitive : GLTFObject

@property(nonatomic, strong) NSDictionary<NSString *, NSNumber *> *attributes;
@property(nonatomic, strong, nullable) NSNumber *indices;
@property(nonatomic, strong, nullable) NSNumber *material;
@property(nonatomic, strong, nullable) NSNumber *mode;
@property(nonatomic, strong, nullable)
    NSArray<GLTFMeshPrimitiveTarget *> *targets;

@property(nonatomic, readonly) NSInteger modeValue;

- (nullable NSNumber *)valueOfAttributeSemantic:(NSString *)semantic;
- (NSArray<NSNumber *> *)valuesOfAttributeSemantic:(NSString *)semantic;

@end

GLTF_EXPORT @interface GLTFMesh : GLTFObject

@property(nonatomic, strong) NSArray<GLTFMeshPrimitive *> *primitives;
@property(nonatomic, strong, nullable) NSArray<NSNumber *> *weights;
@property(nonatomic, copy, nullable) NSString *name;

@end

#pragma mark - Node

GLTF_EXPORT @interface GLTFNode : GLTFObject

@property(nonatomic, strong, nullable) NSNumber *camera;
@property(nonatomic, strong, nullable) NSArray<NSNumber *> *children;
@property(nonatomic, strong, nullable) NSNumber *skin;
@property(nonatomic, strong, nullable) NSArray<NSNumber *> *matrix;
@property(nonatomic, strong, nullable) NSNumber *mesh;
@property(nonatomic, strong, nullable) NSArray<NSNumber *> *rotation;
@property(nonatomic, strong, nullable) NSArray<NSNumber *> *scale;
@property(nonatomic, strong, nullable) NSArray<NSNumber *> *translation;
@property(nonatomic, strong, nullable) NSArray<NSNumber *> *weights;
@property(nonatomic, copy, nullable) NSString *name;

@property(nonatomic, readonly) simd_float4x4 matrixValue;
@property(nonatomic, readonly) simd_quatf rotationValue;
@property(nonatomic, readonly) simd_float3 scaleValue;
@property(nonatomic, readonly) simd_float3 translationValue;

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

GLTF_EXPORT @interface GLTFSampler : GLTFObject

@property(nonatomic, strong, nullable) NSNumber *magFilter;
@property(nonatomic, strong, nullable) NSNumber *minFilter;
@property(nonatomic, strong, nullable) NSNumber *wrapS;
@property(nonatomic, strong, nullable) NSNumber *wrapT;
@property(nonatomic, copy, nullable) NSString *name;

@property(nonatomic, readonly) NSInteger wrapSValue;
@property(nonatomic, readonly) NSInteger wrapTValue;

@end

#pragma mark - Scene

GLTF_EXPORT @interface GLTFScene : GLTFObject

@property(nonatomic, strong, nullable) NSArray<NSNumber *> *nodes;
@property(nonatomic, copy, nullable) NSString *name;

@end

#pragma mark - Skin

GLTF_EXPORT @interface GLTFSkin : GLTFObject

@property(nonatomic, strong, nullable) NSNumber *inverseBindMatrices;
@property(nonatomic, strong, nullable) NSNumber *skeleton;
@property(nonatomic, strong) NSArray<NSNumber *> *joints;
@property(nonatomic, copy, nullable) NSString *name;

@end

#pragma mark - Json

GLTF_EXPORT @interface GLTFJson : GLTFObject

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

@end

NS_ASSUME_NONNULL_END
