#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, GLTFAccessorSparseIndicesComponentType) {
  GLTFAccessorSparseIndicesComponentTypeUnsignedByte = 5121,
  GLTFAccessorSparseIndicesComponentTypeUnsignedShort = 5123,
  GLTFAccessorSparseIndicesComponentTypeUnsignedInt = 5125
};

@interface GLTFAccessorSparseIndices : NSObject

@property(nonatomic, assign) NSUInteger bufferView;
@property(nonatomic, strong, nullable) NSNumber *byteOffset;
@property(nonatomic, assign)
    GLTFAccessorSparseIndicesComponentType componentType;

@end

@interface GLTFAccessorSparseValues : NSObject

@property(nonatomic, assign) NSUInteger bufferView;
@property(nonatomic, strong, nullable) NSNumber *byteOffset;

@end

@interface GLTFAccessorSparse : NSObject

@property(nonatomic, assign) NSUInteger count;
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

extern NSString *const GLTFAccessorTypeScalar;
extern NSString *const GLTFAccessorTypeVec2;
extern NSString *const GLTFAccessorTypeVec3;
extern NSString *const GLTFAccessorTypeVec4;
extern NSString *const GLTFAccessorTypeMat2;
extern NSString *const GLTFAccessorTypeMat3;
extern NSString *const GLTFAccessorTypeMat4;

@interface GLTFAccessor : NSObject

@property(nonatomic, strong, nullable) NSNumber *bufferView;
@property(nonatomic, strong, nullable) NSNumber *byteOffset;
@property(nonatomic, assign) GLTFAccessorComponentType componentType;
@property(nonatomic, assign) BOOL normalized;
@property(nonatomic, assign) NSUInteger count;
@property(nonatomic, copy) NSString *type;
@property(nonatomic, strong, nullable) NSArray<NSNumber *> *max;
@property(nonatomic, strong, nullable) NSArray<NSNumber *> *min;
@property(nonatomic, strong, nullable) GLTFAccessorSparse *sparse;
@property(nonatomic, copy, nullable) NSString *name;

@end

extern NSString *const GLTFAnimationChannelTargetPathTranslation;
extern NSString *const GLTFAnimationChannelTargetPathRotation;
extern NSString *const GLTFAnimationChannelTargetPathScale;
extern NSString *const GLTFAnimationChannelTargetPathWeights;

@interface GLTFAnimationChannelTarget : NSObject

@property(nonatomic, strong, nullable) NSNumber *node;
@property(nonatomic, copy) NSString *path;

@end

@interface GLTFAnimationChannel : NSObject

@property(nonatomic, assign) uint32_t sampler;
@property(nonatomic, strong) GLTFAnimationChannelTarget *target;

@end

extern NSString *const GLTFAnimationSamplerInterpolationLinear;
extern NSString *const GLTFAnimationSamplerInterpolationStep;
extern NSString *const GLTFAnimationSamplerInterpolationCubicSpline;

@interface GLTFAnimationSampler : NSObject

@property(nonatomic, assign) uint32_t input;
@property(nonatomic, copy) NSString *interpolation;
@property(nonatomic, assign) uint32_t output;

@end

@interface GLTFAnimation : NSObject

@property(nonatomic, strong) NSArray<GLTFAnimationChannel *> *channels;
@property(nonatomic, strong) NSArray<GLTFAnimationSampler *> *samplers;
@property(nonatomic, copy, nullable) NSString *name;

@end

@interface GLTFAsset : NSObject

@property(nonatomic, copy, nullable) NSString *copyright;
@property(nonatomic, copy, nullable) NSString *generator;
@property(nonatomic, copy) NSString *version;
@property(nonatomic, copy, nullable) NSString *minVersion;

@end

@interface GLTFBuffer : NSObject

@property(nonatomic, copy, nullable) NSString *uri;
@property(nonatomic, assign) uint32_t byteLength;
@property(nonatomic, copy, nullable) NSString *name;

@end

@interface GLTFBufferView : NSObject

@property(nonatomic, assign) uint32_t buffer;
@property(nonatomic, strong, nullable) NSNumber *byteOffset;
@property(nonatomic, assign) uint32_t byteLength;
@property(nonatomic, strong, nullable) NSNumber *byteStride;
@property(nonatomic, strong, nullable) NSNumber *target;
@property(nonatomic, copy, nullable) NSString *name;

@end

@interface GLTFCameraOrthographic : NSObject

@property(nonatomic, assign) float xmag;
@property(nonatomic, assign) float ymag;
@property(nonatomic, assign) float zfar;
@property(nonatomic, assign) float znear;

@end

@interface GLTFCameraPerspective : NSObject

@property(nonatomic, strong, nullable) NSNumber *aspectRatio;
@property(nonatomic, assign) float yfov;
@property(nonatomic, strong, nullable) NSNumber *zfar;
@property(nonatomic, assign) float znear;

@end

extern NSString *const GLTFCameraTypePerspective;
extern NSString *const GLTFCameraTypeOrthographic;

@interface GLTFCamera : NSObject

@property(nonatomic, strong, nullable) GLTFCameraOrthographic *orthographic;
@property(nonatomic, strong, nullable) GLTFCameraPerspective *perspective;
@property(nonatomic, copy) NSString *type;
@property(nonatomic, copy, nullable) NSString *name;

@end

extern NSString *const GLTFImageMimeTypeJPEG;
extern NSString *const GLTFImageMimeTypePNG;

@interface GLTFImage : NSObject

@property(nonatomic, copy, nullable) NSString *uri;
@property(nonatomic, copy) NSString *mimeType;
@property(nonatomic, strong, nullable) NSNumber *bufferView;
@property(nonatomic, copy, nullable) NSString *name;

@end

@interface GLTFTexture : NSObject

@property(nonatomic, strong, nullable) NSNumber *sampler;
@property(nonatomic, strong, nullable) NSNumber *source;
@property(nonatomic, copy, nullable) NSString *name;

@end

@interface KHRTextureTransform : NSObject

@property(nonatomic, strong, nullable) NSArray<NSNumber *> *offset;
@property(nonatomic, strong, nullable) NSNumber *rotation;
@property(nonatomic, strong, nullable) NSArray<NSNumber *> *scale;
@property(nonatomic, strong, nullable) NSNumber *texCoord;

@end

@interface GLTFTextureInfo : NSObject

@property(nonatomic, assign) uint32_t index;
@property(nonatomic, strong, nullable) NSNumber *texCoord;
@property(nonatomic, strong, nullable) KHRTextureTransform *khrTextureTransform;

@end

@interface GLTFMaterialPBRMetallicRoughness : NSObject

@property(nonatomic, strong, nullable) NSArray<NSNumber *> *baseColorFactor;
@property(nonatomic, strong, nullable) GLTFTextureInfo *baseColorTexture;
@property(nonatomic, strong, nullable) NSNumber *metallicFactor;
@property(nonatomic, strong, nullable) NSNumber *roughnessFactor;
@property(nonatomic, strong, nullable)
    GLTFTextureInfo *metallicRoughnessTexture;

@end

@interface GLTFMaterialNormalTextureInfo : GLTFTextureInfo

@property(nonatomic, strong, nullable) NSNumber *scale;

@end

@interface GLTFMaterialOcclusionTextureInfo : GLTFTextureInfo

@property(nonatomic, strong, nullable) NSNumber *strength;

@end

@interface KHRMaterialAnisotropy : NSObject

@property(nonatomic, strong, nullable) NSNumber *anisotropyStrength;
@property(nonatomic, strong, nullable) NSNumber *anisotropyRotation;
@property(nonatomic, strong, nullable) GLTFTextureInfo *anisotropyTexture;

@end

@interface KHRMaterialSheen : NSObject

@property(nonatomic, strong, nullable) NSArray<NSNumber *> *sheenColorFactor;
@property(nonatomic, strong, nullable) GLTFTextureInfo *sheenColorTexture;
@property(nonatomic, strong, nullable) NSNumber *sheenRoughnessFactor;
@property(nonatomic, strong, nullable) GLTFTextureInfo *sheenRoughnessTexture;

@end

@interface KHRMaterialSpecular : NSObject

@property(nonatomic, strong, nullable) NSNumber *specularFactor;
@property(nonatomic, strong, nullable) GLTFTextureInfo *specularTexture;
@property(nonatomic, strong, nullable) NSArray<NSNumber *> *specularColorFactor;
@property(nonatomic, strong, nullable) GLTFTextureInfo *specularColorTexture;

@end

@interface KHRMaterialIor : NSObject

@property(nonatomic, strong, nullable) NSNumber *ior;

@end

@interface KHRMaterialClearcoat : NSObject

@property(nonatomic, strong, nullable) NSNumber *clearcoatFactor;
@property(nonatomic, strong, nullable) GLTFTextureInfo *clearcoatTexture;
@property(nonatomic, strong, nullable) NSNumber *clearcoatRoughnessFactor;
@property(nonatomic, strong, nullable)
    GLTFTextureInfo *clearcoatRoughnessTexture;
@property(nonatomic, strong, nullable)
    GLTFMaterialNormalTextureInfo *clearcoatNormalTexture;

@end

@interface KHRMaterialDispersion : NSObject

@property(nonatomic, strong, nullable) NSNumber *dispersion;

@end

@interface KHRMaterialEmissiveStrength : NSObject

@property(nonatomic, strong, nullable) NSNumber *emissiveStrength;

@end

@interface KHRMaterialIridescence : NSObject

@property(nonatomic, strong, nullable) NSNumber *iridescenceFactor;
@property(nonatomic, strong, nullable) GLTFTextureInfo *iridescenceTexture;
@property(nonatomic, strong, nullable) NSNumber *iridescenceIor;
@property(nonatomic, strong, nullable) NSNumber *iridescenceThicknessMinimum;
@property(nonatomic, strong, nullable) NSNumber *iridescenceThicknessMaximum;
@property(nonatomic, strong, nullable)
    GLTFTextureInfo *iridescenceThicknessTexture;

@end

@interface KHRMaterialVolume : NSObject

@property(nonatomic, strong, nullable) NSNumber *thicknessFactor;
@property(nonatomic, strong, nullable) GLTFTextureInfo *thicknessTexture;
@property(nonatomic, strong, nullable) NSNumber *attenuationDistance;
@property(nonatomic, strong, nullable) NSArray<NSNumber *> *attenuationColor;

@end

@interface KHRMaterialTransmission : NSObject

@property(nonatomic, strong, nullable) NSNumber *transmissionFactor;
@property(nonatomic, strong, nullable) GLTFTextureInfo *transmissionTexture;

@end

extern NSString *const GLTFMaterialAlphaModeOpaque;
extern NSString *const GLTFMaterialAlphaModeMask;
extern NSString *const GLTFMaterialAlphaModeBlend;

@interface GLTFMaterial : NSObject

@property(nonatomic, copy, nullable) NSString *name;
@property(nonatomic, strong, nullable)
    GLTFMaterialPBRMetallicRoughness *pbrMetallicRoughness;
@property(nonatomic, strong, nullable)
    GLTFMaterialNormalTextureInfo *normalTexture;
@property(nonatomic, strong, nullable)
    GLTFMaterialOcclusionTextureInfo *occlusionTexture;
@property(nonatomic, strong, nullable) GLTFTextureInfo *emissiveTexture;
@property(nonatomic, strong, nullable) NSArray<NSNumber *> *emissiveFactor;
@property(nonatomic, copy) NSString *alphaMode;
@property(nonatomic, strong, nullable) NSNumber *alphaCutoff;
@property(nonatomic, strong, nullable) NSNumber *doubleSided;
@property(nonatomic, strong, nullable) KHRMaterialAnisotropy *anisotropy;
@property(nonatomic, strong, nullable) KHRMaterialClearcoat *clearcoat;
@property(nonatomic, strong, nullable) KHRMaterialDispersion *dispersion;
@property(nonatomic, strong, nullable)
    KHRMaterialEmissiveStrength *emissiveStrength;
@property(nonatomic, strong, nullable) KHRMaterialIor *ior;
@property(nonatomic, strong, nullable) KHRMaterialIridescence *iridescence;
@property(nonatomic, strong, nullable) KHRMaterialSheen *sheen;
@property(nonatomic, strong, nullable) KHRMaterialSpecular *specular;
@property(nonatomic, strong, nullable) KHRMaterialTransmission *transmission;
@property(nonatomic, strong, nullable) NSNumber *unlit;
@property(nonatomic, strong, nullable) KHRMaterialVolume *volume;

@end

@interface GLTFMeshPrimitiveTarget : NSObject

@property(nonatomic, strong, nullable) NSNumber *position;
@property(nonatomic, strong, nullable) NSNumber *normal;
@property(nonatomic, strong, nullable) NSNumber *tangent;

@end

@interface GLTFMeshPrimitiveAttributes : GLTFMeshPrimitiveTarget

@property(nonatomic, strong, nullable) NSArray<NSNumber *> *texcoords;
@property(nonatomic, strong, nullable) NSArray<NSNumber *> *colors;
@property(nonatomic, strong, nullable) NSArray<NSNumber *> *joints;
@property(nonatomic, strong, nullable) NSArray<NSNumber *> *weights;

@end

@interface GLTFMeshPrimitiveDracoExtension : NSObject

@property(nonatomic, assign) uint32_t bufferView;
@property(nonatomic, strong) GLTFMeshPrimitiveAttributes *attributes;

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

@interface GLTFMeshPrimitive : NSObject

@property(nonatomic, strong) GLTFMeshPrimitiveAttributes *attributes;
@property(nonatomic, strong, nullable) NSNumber *indices;
@property(nonatomic, strong, nullable) NSNumber *material;
@property(nonatomic, assign) GLTFMeshPrimitiveMode mode;
@property(nonatomic, strong, nullable)
    NSArray<GLTFMeshPrimitiveTarget *> *targets;
@property(nonatomic, strong, nullable)
    GLTFMeshPrimitiveDracoExtension *dracoExtension;

@end

@interface GLTFMesh : NSObject

@property(nonatomic, strong) NSArray<GLTFMeshPrimitive *> *primitives;
@property(nonatomic, strong, nullable) NSArray<NSNumber *> *weights;
@property(nonatomic, copy, nullable) NSString *name;

@end

@interface GLTFNode : NSObject

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

@end

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

@interface GLTFSampler : NSObject

@property(nonatomic, strong, nullable) NSNumber *magFilter;
@property(nonatomic, strong, nullable) NSNumber *minFilter;
@property(nonatomic, assign) GLTFSamplerWrapMode wrapS;
@property(nonatomic, assign) GLTFSamplerWrapMode wrapT;
@property(nonatomic, copy, nullable) NSString *name;

@end

@interface GLTFScene : NSObject

@property(nonatomic, strong, nullable) NSArray<NSNumber *> *nodes;
@property(nonatomic, copy, nullable) NSString *name;

@end

@interface GLTFSkin : NSObject

@property(nonatomic, strong, nullable) NSNumber *inverseBindMatrices;
@property(nonatomic, strong, nullable) NSNumber *skeleton;
@property(nonatomic, strong) NSArray<NSNumber *> *joints;
@property(nonatomic, copy, nullable) NSString *name;

@end

@interface KHRLightSpot : NSObject

@property(nonatomic, strong, nullable) NSNumber *innerConeAngle;
@property(nonatomic, strong, nullable) NSNumber *outerConeAngle;

@end

extern NSString *const KHRLightTypePoint;
extern NSString *const KHRLightTypeSpot;
extern NSString *const KHRLightTypeDirectional;

@interface KHRLight : NSObject

@property(nonatomic, copy, nullable) NSString *name;
@property(nonatomic, strong, nullable) NSArray<NSNumber *> *color;
@property(nonatomic, strong, nullable) NSNumber *intensity;
@property(nonatomic, copy) NSString *type;
@property(nonatomic, strong, nullable) KHRLightSpot *spot;

@end

extern NSString *const VRMCMetaAvatarPermissionOnlyAuthor;
extern NSString *const VRMCMetaAvatarPermissionOnlySeparatelyLicensedPerson;
extern NSString *const VRMCMetaAvatarPermissionEveryone;

extern NSString *const VRMCMetaCommercialUsagePersonalNonProfit;
extern NSString *const VRMCMetaCommercialUsagePersonalProfit;
extern NSString *const VRMCMetaCommercialUsageCorporation;

extern NSString *const VRMCMetaCreditNotationRequired;
extern NSString *const VRMCMetaCreditNotationUnnecessary;

extern NSString *const VRMCMetaModificationProhibited;
extern NSString *const VRMCMetaModificationAllowModification;
extern NSString *const VRMCMetaModificationAllowModificationRedistribution;

@interface VRMCMeta : NSObject

@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy, nullable) NSString *version;
@property(nonatomic, strong) NSArray<NSString *> *authors;
@property(nonatomic, copy, nullable) NSString *copyrightInformation;
@property(nonatomic, copy, nullable) NSString *contactInformation;
@property(nonatomic, strong, nullable) NSArray<NSString *> *references;
@property(nonatomic, copy, nullable) NSString *thirdPartyLicenses;
@property(nonatomic, strong, nullable) NSNumber *thumbnailImage;
@property(nonatomic, copy) NSString *licenseUrl;
@property(nonatomic, copy, nullable) NSString *avatarPermission;
@property(nonatomic, strong, nullable) NSNumber *allowExcessivelyViolentUsage;
@property(nonatomic, strong, nullable) NSNumber *allowExcessivelySexualUsage;
@property(nonatomic, copy, nullable) NSString *commercialUsage;
@property(nonatomic, strong, nullable) NSNumber *allowPoliticalOrReligiousUsage;
@property(nonatomic, strong, nullable) NSNumber *allowAntisocialOrHateUsage;
@property(nonatomic, copy, nullable) NSString *creditNotation;
@property(nonatomic, strong, nullable) NSNumber *allowRedistribution;
@property(nonatomic, copy, nullable) NSString *modification;
@property(nonatomic, copy, nullable) NSString *otherLicenseUrl;

@end

@interface VRMCHumanBone : NSObject

@property(nonatomic, strong) NSNumber *node;

@end

@interface VRMCHumanBones : NSObject

@property(nonatomic, strong) VRMCHumanBone *hips;
@property(nonatomic, strong) VRMCHumanBone *spine;
@property(nonatomic, strong, nullable) VRMCHumanBone *chest;
@property(nonatomic, strong, nullable) VRMCHumanBone *upperChest;
@property(nonatomic, strong, nullable) VRMCHumanBone *neck;
@property(nonatomic, strong) VRMCHumanBone *head;
@property(nonatomic, strong, nullable) VRMCHumanBone *leftEye;
@property(nonatomic, strong, nullable) VRMCHumanBone *rightEye;
@property(nonatomic, strong, nullable) VRMCHumanBone *jaw;
@property(nonatomic, strong) VRMCHumanBone *leftUpperLeg;
@property(nonatomic, strong) VRMCHumanBone *leftLowerLeg;
@property(nonatomic, strong) VRMCHumanBone *leftFoot;
@property(nonatomic, strong, nullable) VRMCHumanBone *leftToes;
@property(nonatomic, strong) VRMCHumanBone *rightUpperLeg;
@property(nonatomic, strong) VRMCHumanBone *rightLowerLeg;
@property(nonatomic, strong) VRMCHumanBone *rightFoot;
@property(nonatomic, strong, nullable) VRMCHumanBone *rightToes;
@property(nonatomic, strong, nullable) VRMCHumanBone *leftShoulder;
@property(nonatomic, strong) VRMCHumanBone *leftUpperArm;
@property(nonatomic, strong) VRMCHumanBone *leftLowerArm;
@property(nonatomic, strong) VRMCHumanBone *leftHand;
@property(nonatomic, strong, nullable) VRMCHumanBone *rightShoulder;
@property(nonatomic, strong) VRMCHumanBone *rightUpperArm;
@property(nonatomic, strong) VRMCHumanBone *rightLowerArm;
@property(nonatomic, strong) VRMCHumanBone *rightHand;
@property(nonatomic, strong, nullable) VRMCHumanBone *leftThumbMetacarpal;
@property(nonatomic, strong, nullable) VRMCHumanBone *leftThumbProximal;
@property(nonatomic, strong, nullable) VRMCHumanBone *leftThumbDistal;
@property(nonatomic, strong, nullable) VRMCHumanBone *leftIndexProximal;
@property(nonatomic, strong, nullable) VRMCHumanBone *leftIndexIntermediate;
@property(nonatomic, strong, nullable) VRMCHumanBone *leftIndexDistal;
@property(nonatomic, strong, nullable) VRMCHumanBone *leftMiddleProximal;
@property(nonatomic, strong, nullable) VRMCHumanBone *leftMiddleIntermediate;
@property(nonatomic, strong, nullable) VRMCHumanBone *leftMiddleDistal;
@property(nonatomic, strong, nullable) VRMCHumanBone *leftRingProximal;
@property(nonatomic, strong, nullable) VRMCHumanBone *leftRingIntermediate;
@property(nonatomic, strong, nullable) VRMCHumanBone *leftRingDistal;
@property(nonatomic, strong, nullable) VRMCHumanBone *leftLittleProximal;
@property(nonatomic, strong, nullable) VRMCHumanBone *leftLittleIntermediate;
@property(nonatomic, strong, nullable) VRMCHumanBone *leftLittleDistal;
@property(nonatomic, strong, nullable) VRMCHumanBone *rightThumbMetacarpal;
@property(nonatomic, strong, nullable) VRMCHumanBone *rightThumbProximal;
@property(nonatomic, strong, nullable) VRMCHumanBone *rightThumbDistal;
@property(nonatomic, strong, nullable) VRMCHumanBone *rightIndexProximal;
@property(nonatomic, strong, nullable) VRMCHumanBone *rightIndexIntermediate;
@property(nonatomic, strong, nullable) VRMCHumanBone *rightIndexDistal;
@property(nonatomic, strong, nullable) VRMCHumanBone *rightMiddleProximal;
@property(nonatomic, strong, nullable) VRMCHumanBone *rightMiddleIntermediate;
@property(nonatomic, strong, nullable) VRMCHumanBone *rightMiddleDistal;
@property(nonatomic, strong, nullable) VRMCHumanBone *rightRingProximal;
@property(nonatomic, strong, nullable) VRMCHumanBone *rightRingIntermediate;
@property(nonatomic, strong, nullable) VRMCHumanBone *rightRingDistal;
@property(nonatomic, strong, nullable) VRMCHumanBone *rightLittleProximal;
@property(nonatomic, strong, nullable) VRMCHumanBone *rightLittleIntermediate;
@property(nonatomic, strong, nullable) VRMCHumanBone *rightLittleDistal;

@end

@interface VRMCHumanoid : NSObject

@property(nonatomic, strong) VRMCHumanBones *humanBones;

@end

extern NSString *const VRMCFirstPersonMeshAnnotationTypeAuto;
extern NSString *const VRMCFirstPersonMeshAnnotationTypeBoth;
extern NSString *const VRMCFirstPersonMeshAnnotationTypeThirdPersonOnly;
extern NSString *const VRMCFirstPersonMeshAnnotationTypeFirstPersonOnly;

@interface VRMCFirstPersonMeshAnnotation : NSObject

@property(nonatomic, assign) uint32_t node;
@property(nonatomic, copy) NSString *type;

@end

@interface VRMCFirstPerson : NSObject

@property(nonatomic, strong, nullable)
    NSArray<VRMCFirstPersonMeshAnnotation *> *meshAnnotations;

@end

@interface VRMCLookAtRangeMap : NSObject

@property(nonatomic, strong, nullable) NSNumber *inputMaxValue;
@property(nonatomic, strong, nullable) NSNumber *outputScale;

@end

@interface Vec3 : NSObject

@property(nonatomic, assign) float x;
@property(nonatomic, assign) float y;
@property(nonatomic, assign) float z;

- (instancetype)initWithX:(float)x Y:(float)y Z:(float)z;

@end

extern NSString *const VRMCLookAtTypeBone;
extern NSString *const VRMCLookAtTypeExpression;

@interface VRMCLookAt : NSObject

@property(nonatomic, strong, nullable) Vec3 *offsetFromHeadBone;
@property(nonatomic, copy, nullable) NSString *type;
@property(nonatomic, strong, nullable)
    VRMCLookAtRangeMap *rangeMapHorizontalInner;
@property(nonatomic, strong, nullable)
    VRMCLookAtRangeMap *rangeMapHorizontalOuter;
@property(nonatomic, strong, nullable) VRMCLookAtRangeMap *rangeMapVerticalDown;
@property(nonatomic, strong, nullable) VRMCLookAtRangeMap *rangeMapVerticalUp;

- (BOOL)isTypeBone;
- (BOOL)isTypeExpression;

@end

extern NSString *const VRMCExpressionMaterialColorBindTypeColor;
extern NSString *const VRMCExpressionMaterialColorBindTypeEmissionColor;
extern NSString *const VRMCExpressionMaterialColorBindTypeShadeColor;
extern NSString *const VRMCExpressionMaterialColorBindTypeMatcapColor;
extern NSString *const VRMCExpressionMaterialColorBindTypeRimColor;
extern NSString *const VRMCExpressionMaterialColorBindTypeOutlineColor;

@interface VRMCExpressionMaterialColorBind : NSObject

@property(nonatomic, assign) uint32_t material;
@property(nonatomic, copy) NSString *type;
@property(nonatomic, strong) NSArray<NSNumber *> *targetValue;

@end

@interface VRMCExpressionMorphTargetBind : NSObject

@property(nonatomic, assign) uint32_t node;
@property(nonatomic, assign) uint32_t index;
@property(nonatomic, assign) float weight;

@end

@interface VRMCExpressionTextureTransformBind : NSObject

@property(nonatomic, assign) uint32_t material;
@property(nonatomic, strong, nullable) NSArray<NSNumber *> *scale;
@property(nonatomic, strong, nullable) NSArray<NSNumber *> *offset;

@end

extern NSString *const VRMCExpressionOverrideNone;
extern NSString *const VRMCExpressionOverrideBlock;
extern NSString *const VRMCExpressionOverrideBlend;

@interface VRMCExpression : NSObject

@property(nonatomic, strong, nullable)
    NSArray<VRMCExpressionMorphTargetBind *> *morphTargetBinds;
@property(nonatomic, strong, nullable)
    NSArray<VRMCExpressionMaterialColorBind *> *materialColorBinds;
@property(nonatomic, strong, nullable)
    NSArray<VRMCExpressionTextureTransformBind *> *textureTransformBinds;
@property(nonatomic, assign) BOOL isBinary;
@property(nonatomic, copy, nullable) NSString *overrideBlink;
@property(nonatomic, copy, nullable) NSString *overrideLookAt;
@property(nonatomic, copy, nullable) NSString *overrideMouth;

@end

@interface VRMCExpressionsPreset : NSObject

@property(nonatomic, strong, nullable) VRMCExpression *happy;
@property(nonatomic, strong, nullable) VRMCExpression *angry;
@property(nonatomic, strong, nullable) VRMCExpression *sad;
@property(nonatomic, strong, nullable) VRMCExpression *relaxed;
@property(nonatomic, strong, nullable) VRMCExpression *surprised;
@property(nonatomic, strong, nullable) VRMCExpression *aa;
@property(nonatomic, strong, nullable) VRMCExpression *ih;
@property(nonatomic, strong, nullable) VRMCExpression *ou;
@property(nonatomic, strong, nullable) VRMCExpression *ee;
@property(nonatomic, strong, nullable) VRMCExpression *oh;
@property(nonatomic, strong, nullable) VRMCExpression *blink;
@property(nonatomic, strong, nullable) VRMCExpression *blinkLeft;
@property(nonatomic, strong, nullable) VRMCExpression *blinkRight;
@property(nonatomic, strong, nullable) VRMCExpression *lookUp;
@property(nonatomic, strong, nullable) VRMCExpression *lookDown;
@property(nonatomic, strong, nullable) VRMCExpression *lookLeft;
@property(nonatomic, strong, nullable) VRMCExpression *lookRight;
@property(nonatomic, strong, nullable) VRMCExpression *neutral;

- (NSArray<NSString *> *)expressionNames;

@end

@interface VRMCExpressions : NSObject

@property(nonatomic, strong, nullable) VRMCExpressionsPreset *preset;
@property(nonatomic, strong, nullable)
    NSDictionary<NSString *, VRMCExpression *> *custom;

- (nullable VRMCExpression *)expressionByName:(NSString *)name;
- (NSArray<NSString *> *)expressionNames;

@end

@interface VRMCVrm : NSObject

@property(nonatomic, copy) NSString *specVersion;
@property(nonatomic, strong) VRMCMeta *meta;
@property(nonatomic, strong) VRMCHumanoid *humanoid;
@property(nonatomic, strong, nullable) VRMCFirstPerson *firstPerson;
@property(nonatomic, strong, nullable) VRMCLookAt *lookAt;
@property(nonatomic, strong, nullable) VRMCExpressions *expressions;

- (nullable VRMCExpression *)expressionByName:(NSString *)name;

@end

extern NSString *const VRMHumanoidBoneTypeHips;
extern NSString *const VRMHumanoidBoneTypeLeftUpperLeg;
extern NSString *const VRMHumanoidBoneTypeRightUpperLeg;
extern NSString *const VRMHumanoidBoneTypeLeftLowerLeg;
extern NSString *const VRMHumanoidBoneTypeRightLowerLeg;
extern NSString *const VRMHumanoidBoneTypeLeftFoot;
extern NSString *const VRMHumanoidBoneTypeRightFoot;
extern NSString *const VRMHumanoidBoneTypeSpine;
extern NSString *const VRMHumanoidBoneTypeChest;
extern NSString *const VRMHumanoidBoneTypeNeck;
extern NSString *const VRMHumanoidBoneTypeHead;
extern NSString *const VRMHumanoidBoneTypeLeftShoulder;
extern NSString *const VRMHumanoidBoneTypeRightShoulder;
extern NSString *const VRMHumanoidBoneTypeLeftUpperArm;
extern NSString *const VRMHumanoidBoneTypeRightUpperArm;
extern NSString *const VRMHumanoidBoneTypeLeftLowerArm;
extern NSString *const VRMHumanoidBoneTypeRightLowerArm;
extern NSString *const VRMHumanoidBoneTypeLeftHand;
extern NSString *const VRMHumanoidBoneTypeRightHand;
extern NSString *const VRMHumanoidBoneTypeLeftToes;
extern NSString *const VRMHumanoidBoneTypeRightToes;
extern NSString *const VRMHumanoidBoneTypeLeftEye;
extern NSString *const VRMHumanoidBoneTypeRightEye;
extern NSString *const VRMHumanoidBoneTypeJaw;
extern NSString *const VRMHumanoidBoneTypeLeftThumbProximal;
extern NSString *const VRMHumanoidBoneTypeLeftThumbIntermediate;
extern NSString *const VRMHumanoidBoneTypeLeftThumbDistal;
extern NSString *const VRMHumanoidBoneTypeLeftIndexProximal;
extern NSString *const VRMHumanoidBoneTypeLeftIndexIntermediate;
extern NSString *const VRMHumanoidBoneTypeLeftIndexDistal;
extern NSString *const VRMHumanoidBoneTypeLeftMiddleProximal;
extern NSString *const VRMHumanoidBoneTypeLeftMiddleIntermediate;
extern NSString *const VRMHumanoidBoneTypeLeftMiddleDistal;
extern NSString *const VRMHumanoidBoneTypeLeftRingProximal;
extern NSString *const VRMHumanoidBoneTypeLeftRingIntermediate;
extern NSString *const VRMHumanoidBoneTypeLeftRingDistal;
extern NSString *const VRMHumanoidBoneTypeLeftLittleProximal;
extern NSString *const VRMHumanoidBoneTypeLeftLittleIntermediate;
extern NSString *const VRMHumanoidBoneTypeLeftLittleDistal;
extern NSString *const VRMHumanoidBoneTypeRightThumbProximal;
extern NSString *const VRMHumanoidBoneTypeRightThumbIntermediate;
extern NSString *const VRMHumanoidBoneTypeRightThumbDistal;
extern NSString *const VRMHumanoidBoneTypeRightIndexProximal;
extern NSString *const VRMHumanoidBoneTypeRightIndexIntermediate;
extern NSString *const VRMHumanoidBoneTypeRightIndexDistal;
extern NSString *const VRMHumanoidBoneTypeRightMiddleProximal;
extern NSString *const VRMHumanoidBoneTypeRightMiddleIntermediate;
extern NSString *const VRMHumanoidBoneTypeRightMiddleDistal;
extern NSString *const VRMHumanoidBoneTypeRightRingProximal;
extern NSString *const VRMHumanoidBoneTypeRightRingIntermediate;
extern NSString *const VRMHumanoidBoneTypeRightRingDistal;
extern NSString *const VRMHumanoidBoneTypeRightLittleProximal;
extern NSString *const VRMHumanoidBoneTypeRightLittleIntermediate;
extern NSString *const VRMHumanoidBoneTypeRightLittleDistal;
extern NSString *const VRMHumanoidBoneTypeUpperChest;

@interface VRMHumanoidBone : NSObject

@property(nonatomic, copy, nullable) NSString *bone;
@property(nonatomic, strong, nullable) NSNumber *node;
@property(nonatomic, strong, nullable) NSNumber *useDefaultValues;
@property(nonatomic, strong, nullable) Vec3 *min;
@property(nonatomic, strong, nullable) Vec3 *max;
@property(nonatomic, strong, nullable) Vec3 *center;
@property(nonatomic, strong, nullable) NSNumber *axisLength;

@end

@interface VRMHumanoid : NSObject

@property(nonatomic, strong, nullable) NSArray<VRMHumanoidBone *> *humanBones;
@property(nonatomic, strong, nullable) NSNumber *armStretch;
@property(nonatomic, strong, nullable) NSNumber *legStretch;
@property(nonatomic, strong, nullable) NSNumber *upperArmTwist;
@property(nonatomic, strong, nullable) NSNumber *lowerArmTwist;
@property(nonatomic, strong, nullable) NSNumber *upperLegTwist;
@property(nonatomic, strong, nullable) NSNumber *lowerLegTwist;
@property(nonatomic, strong, nullable) NSNumber *feetSpacing;
@property(nonatomic, strong, nullable) NSNumber *hasTranslationDoF;

- (nullable VRMHumanoidBone *)humanBoneByName:(NSString *)name;

@end

extern NSString *const VRMMetaAllowedUserNameOnlyAuthor;
extern NSString *const VRMMetaAllowedUserNameExplicitlyLicensedPerson;
extern NSString *const VRMMetaAllowedUserNameEveryone;

extern NSString *const VRMMetaUsagePermissionDisallow;
extern NSString *const VRMMetaUsagePermissionAllow;

extern NSString *const VRMMetaLicenseNameRedistributionProhibited;
extern NSString *const VRMMetaLicenseNameCC0;
extern NSString *const VRMMetaLicenseNameCCBY;
extern NSString *const VRMMetaLicenseNameCCBYNC;
extern NSString *const VRMMetaLicenseNameCCBYSA;
extern NSString *const VRMMetaLicenseNameCCBYNCSA;
extern NSString *const VRMMetaLicenseNameCCBYND;
extern NSString *const VRMMetaLicenseNameCCBYNCND;
extern NSString *const VRMMetaLicenseNameOther;

@interface VRMMeta : NSObject

@property(nonatomic, copy, nullable) NSString *title;
@property(nonatomic, copy, nullable) NSString *version;
@property(nonatomic, copy, nullable) NSString *author;
@property(nonatomic, copy, nullable) NSString *contactInformation;
@property(nonatomic, copy, nullable) NSString *reference;
@property(nonatomic, strong, nullable) NSNumber *texture;
@property(nonatomic, copy, nullable) NSString *allowedUserName;
@property(nonatomic, copy, nullable) NSString *violentUsage;
@property(nonatomic, copy, nullable) NSString *sexualUsage;
@property(nonatomic, copy, nullable) NSString *commercialUsage;
@property(nonatomic, copy, nullable) NSString *otherPermissionUrl;
@property(nonatomic, copy, nullable) NSString *licenseName;
@property(nonatomic, copy, nullable) NSString *otherLicenseUrl;

@end

@interface VRMMeshAnnotation : NSObject

@property(nonatomic, strong, nullable) NSNumber *mesh;
@property(nonatomic, copy, nullable) NSString *firstPersonFlag;

@end

@interface VRMDegreeMapCurveMapping : NSObject

@property(nonatomic, assign) float time;
@property(nonatomic, assign) float value;
@property(nonatomic, assign) float inTangent;
@property(nonatomic, assign) float outTangent;

@end

@interface VRMDegreeMap : NSObject

@property(nonatomic, strong, nullable)
    NSArray<VRMDegreeMapCurveMapping *> *curve;
@property(nonatomic, strong, nullable) NSNumber *xRange;
@property(nonatomic, strong, nullable) NSNumber *yRange;

@end

extern NSString *const VRMFirstPersonLookAtTypeBone;
extern NSString *const VRMFirstPersonLookAtTypeBlendShape;

@interface VRMFirstPerson : NSObject

@property(nonatomic, strong, nullable) NSNumber *firstPersonBone;
@property(nonatomic, strong, nullable) Vec3 *firstPersonBoneOffset;
@property(nonatomic, strong, nullable)
    NSArray<VRMMeshAnnotation *> *meshAnnotations;
@property(nonatomic, copy, nullable) NSString *lookAtTypeName;
@property(nonatomic, strong, nullable) VRMDegreeMap *lookAtHorizontalInner;
@property(nonatomic, strong, nullable) VRMDegreeMap *lookAtHorizontalOuter;
@property(nonatomic, strong, nullable) VRMDegreeMap *lookAtVerticalDown;
@property(nonatomic, strong, nullable) VRMDegreeMap *lookAtVerticalUp;

- (BOOL)isLookAtTypeBone;
- (BOOL)isLookAtTypeBlendShape;

@end

@interface VRMBlendShapeBind : NSObject

@property(nonatomic, strong, nullable) NSNumber *mesh;
@property(nonatomic, strong, nullable) NSNumber *index;
@property(nonatomic, strong, nullable) NSNumber *weight;

@end

@interface VRMBlendShapeMaterialBind : NSObject

@property(nonatomic, copy, nullable) NSString *materialName;
@property(nonatomic, copy, nullable) NSString *propertyName;
@property(nonatomic, strong, nullable) NSArray<NSNumber *> *targetValue;

@end

extern NSString *const VRMBlendShapeGroupPresetNameUnknown;
extern NSString *const VRMBlendShapeGroupPresetNameNeutral;
extern NSString *const VRMBlendShapeGroupPresetNameA;
extern NSString *const VRMBlendShapeGroupPresetNameI;
extern NSString *const VRMBlendShapeGroupPresetNameU;
extern NSString *const VRMBlendShapeGroupPresetNameE;
extern NSString *const VRMBlendShapeGroupPresetNameO;
extern NSString *const VRMBlendShapeGroupPresetNameBlink;
extern NSString *const VRMBlendShapeGroupPresetNameJoy;
extern NSString *const VRMBlendShapeGroupPresetNameAngry;
extern NSString *const VRMBlendShapeGroupPresetNameSorrow;
extern NSString *const VRMBlendShapeGroupPresetNameFun;
extern NSString *const VRMBlendShapeGroupPresetNameLookUp;
extern NSString *const VRMBlendShapeGroupPresetNameLookDown;
extern NSString *const VRMBlendShapeGroupPresetNameLookLeft;
extern NSString *const VRMBlendShapeGroupPresetNameLookRight;
extern NSString *const VRMBlendShapeGroupPresetNameBlinkL;
extern NSString *const VRMBlendShapeGroupPresetNameBlinkR;

@interface VRMBlendShapeGroup : NSObject

@property(nonatomic, copy, nullable) NSString *name;
@property(nonatomic, copy, nullable) NSString *presetName;
@property(nonatomic, strong, nullable) NSArray<VRMBlendShapeBind *> *binds;
@property(nonatomic, strong, nullable)
    NSArray<VRMBlendShapeMaterialBind *> *materialValues;
@property(nonatomic, assign) BOOL isBinary;

- (nullable NSString *)groupName;

@end

@interface VRMBlendShape : NSObject

@property(nonatomic, strong, nullable)
    NSArray<VRMBlendShapeGroup *> *blendShapeGroups;

- (nullable VRMBlendShapeGroup *)blendShapeGroupByPreset:(NSString *)presetName;
- (NSArray<NSString *> *)groupNames;

@end

@interface VRMSecondaryAnimationCollider : NSObject

@property(nonatomic, strong, nullable) Vec3 *offset;
@property(nonatomic, strong, nullable) NSNumber *radius;

@end

@interface VRMSecondaryAnimationColliderGroup : NSObject

@property(nonatomic, strong, nullable) NSNumber *node;
@property(nonatomic, strong, nullable)
    NSArray<VRMSecondaryAnimationCollider *> *colliders;

@end

@interface VRMSecondaryAnimationSpring : NSObject

@property(nonatomic, copy, nullable) NSString *comment;
@property(nonatomic, strong, nullable) NSNumber *stiffiness;
@property(nonatomic, strong, nullable) NSNumber *gravityPower;
@property(nonatomic, strong, nullable) Vec3 *gravityDir;
@property(nonatomic, strong, nullable) NSNumber *dragForce;
@property(nonatomic, strong, nullable) NSNumber *center;
@property(nonatomic, strong, nullable) NSNumber *hitRadius;
@property(nonatomic, strong, nullable) NSArray<NSNumber *> *bones;
@property(nonatomic, strong, nullable) NSArray<NSNumber *> *colliderGroups;

@end

@interface VRMSecondaryAnimation : NSObject

@property(nonatomic, strong, nullable)
    NSArray<VRMSecondaryAnimationSpring *> *boneGroups;
@property(nonatomic, strong, nullable)
    NSArray<VRMSecondaryAnimationColliderGroup *> *colliderGroups;

@end

@interface VRMMaterial : NSObject

@property(nonatomic, copy, nullable) NSString *name;
@property(nonatomic, copy, nullable) NSString *shader;
@property(nonatomic, strong, nullable) NSNumber *renderQueue;
@property(nonatomic, strong, nullable)
    NSDictionary<NSString *, NSNumber *> *floatProperties;
@property(nonatomic, strong, nullable)
    NSDictionary<NSString *, NSArray<NSNumber *> *> *vectorProperties;
@property(nonatomic, strong, nullable)
    NSDictionary<NSString *, NSNumber *> *textureProperties;
@property(nonatomic, strong, nullable)
    NSDictionary<NSString *, NSNumber *> *keywordMap;
@property(nonatomic, strong, nullable)
    NSDictionary<NSString *, NSString *> *tagMap;

@end

@interface VRMVrm : NSObject

@property(nonatomic, copy, nullable) NSString *exporterVersion;
@property(nonatomic, copy, nullable) NSString *specVersion;
@property(nonatomic, strong, nullable) VRMMeta *meta;
@property(nonatomic, strong, nullable) VRMHumanoid *humanoid;
@property(nonatomic, strong, nullable) VRMFirstPerson *firstPerson;
@property(nonatomic, strong, nullable) VRMBlendShape *blendShapeMaster;
@property(nonatomic, strong, nullable)
    VRMSecondaryAnimation *secondaryAnimation;
@property(nonatomic, strong, nullable)
    NSArray<VRMMaterial *> *materialProperties;

- (nullable VRMBlendShapeGroup *)blendShapeGroupByPreset:(NSString *)presetName;

@end

@interface VRMCSpringBoneShapeSphere : NSObject

@property(nonatomic, strong, nullable) Vec3 *offset;
@property(nonatomic, strong, nullable) NSNumber *radius;

@end

@interface VRMCSpringBoneShapeCapsule : NSObject

@property(nonatomic, strong, nullable) Vec3 *offset;
@property(nonatomic, strong, nullable) NSNumber *radius;
@property(nonatomic, strong, nullable) Vec3 *tail;

@end

@interface VRMCSpringBoneShape : NSObject

@property(nonatomic, strong, nullable) VRMCSpringBoneShapeSphere *sphere;
@property(nonatomic, strong, nullable) VRMCSpringBoneShapeCapsule *capsule;

@end

@interface VRMCSpringBoneCollider : NSObject

@property(nonatomic, assign) NSUInteger node;
@property(nonatomic, strong) VRMCSpringBoneShape *shape;

@end

@interface VRMCSpringBoneJoint : NSObject

@property(nonatomic, assign) NSUInteger node;
@property(nonatomic, strong, nullable) NSNumber *hitRadius;
@property(nonatomic, strong, nullable) NSNumber *stiffness;
@property(nonatomic, strong, nullable) NSNumber *gravityPower;
@property(nonatomic, strong, nullable) Vec3 *gravityDir;
@property(nonatomic, strong, nullable) NSNumber *dragForce;

@end

@interface VRMCSpringBoneColliderGroup : NSObject

@property(nonatomic, copy, nullable) NSString *name;
@property(nonatomic, strong) NSArray<NSNumber *> *colliders;

@end

@interface VRMCSpringBoneSpring : NSObject

@property(nonatomic, copy, nullable) NSString *name;
@property(nonatomic, strong) NSArray<VRMCSpringBoneJoint *> *joints;
@property(nonatomic, strong, nullable) NSArray<NSNumber *> *colliderGroups;
@property(nonatomic, strong, nullable) NSNumber *center;

@end

@interface VRMCSpringBone : NSObject

@property(nonatomic, copy) NSString *specVersion;
@property(nonatomic, strong, nullable)
    NSArray<VRMCSpringBoneCollider *> *colliders;
@property(nonatomic, strong, nullable)
    NSArray<VRMCSpringBoneColliderGroup *> *colliderGroups;
@property(nonatomic, strong, nullable) NSArray<VRMCSpringBoneSpring *> *springs;

@end

@interface GLTFJson : NSObject

@property(nonatomic, strong, nullable) NSArray<NSString *> *extensionsUsed;
@property(nonatomic, strong, nullable) NSArray<NSString *> *extensionsRequired;
@property(nonatomic, strong, nullable) NSArray<GLTFAccessor *> *accessors;
@property(nonatomic, strong, nullable) NSArray<GLTFAnimation *> *animations;
@property(nonatomic, strong) GLTFAsset *asset;
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
@property(nonatomic, strong, nullable) NSArray<KHRLight *> *lights;
@property(nonatomic, strong, nullable) VRMVrm *vrm0;
@property(nonatomic, strong, nullable) VRMCVrm *vrm1;
@property(nonatomic, strong, nullable) VRMCSpringBone *springBone;

@end

NS_ASSUME_NONNULL_END
