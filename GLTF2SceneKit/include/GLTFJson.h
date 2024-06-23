#import <Foundation/Foundation.h>
#import <SceneKit/SceneKit.h>

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

extern NSString *const VRM1MetaAvatarPermissionOnlyAuthor;
extern NSString *const VRM1MetaAvatarPermissionOnlySeparatelyLicensedPerson;
extern NSString *const VRM1MetaAvatarPermissionEveryone;

extern NSString *const VRM1MetaCommercialUsagePersonalNonProfit;
extern NSString *const VRM1MetaCommercialUsagePersonalProfit;
extern NSString *const VRM1MetaCommercialUsageCorporation;

extern NSString *const VRM1MetaCreditNotationRequired;
extern NSString *const VRM1MetaCreditNotationUnnecessary;

extern NSString *const VRM1MetaModificationProhibited;
extern NSString *const VRM1MetaModificationAllowModification;
extern NSString *const VRM1MetaModificationAllowModificationRedistribution;

@interface VRM1Meta : NSObject

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

@interface VRM1HumanBone : NSObject

@property(nonatomic, strong) NSNumber *node;

@end

@interface VRM1HumanBones : NSObject

@property(nonatomic, strong) VRM1HumanBone *hips;
@property(nonatomic, strong) VRM1HumanBone *spine;
@property(nonatomic, strong, nullable) VRM1HumanBone *chest;
@property(nonatomic, strong, nullable) VRM1HumanBone *upperChest;
@property(nonatomic, strong, nullable) VRM1HumanBone *neck;
@property(nonatomic, strong) VRM1HumanBone *head;
@property(nonatomic, strong, nullable) VRM1HumanBone *leftEye;
@property(nonatomic, strong, nullable) VRM1HumanBone *rightEye;
@property(nonatomic, strong, nullable) VRM1HumanBone *jaw;
@property(nonatomic, strong) VRM1HumanBone *leftUpperLeg;
@property(nonatomic, strong) VRM1HumanBone *leftLowerLeg;
@property(nonatomic, strong) VRM1HumanBone *leftFoot;
@property(nonatomic, strong, nullable) VRM1HumanBone *leftToes;
@property(nonatomic, strong) VRM1HumanBone *rightUpperLeg;
@property(nonatomic, strong) VRM1HumanBone *rightLowerLeg;
@property(nonatomic, strong) VRM1HumanBone *rightFoot;
@property(nonatomic, strong, nullable) VRM1HumanBone *rightToes;
@property(nonatomic, strong, nullable) VRM1HumanBone *leftShoulder;
@property(nonatomic, strong) VRM1HumanBone *leftUpperArm;
@property(nonatomic, strong) VRM1HumanBone *leftLowerArm;
@property(nonatomic, strong) VRM1HumanBone *leftHand;
@property(nonatomic, strong, nullable) VRM1HumanBone *rightShoulder;
@property(nonatomic, strong) VRM1HumanBone *rightUpperArm;
@property(nonatomic, strong) VRM1HumanBone *rightLowerArm;
@property(nonatomic, strong) VRM1HumanBone *rightHand;
@property(nonatomic, strong, nullable) VRM1HumanBone *leftThumbMetacarpal;
@property(nonatomic, strong, nullable) VRM1HumanBone *leftThumbProximal;
@property(nonatomic, strong, nullable) VRM1HumanBone *leftThumbDistal;
@property(nonatomic, strong, nullable) VRM1HumanBone *leftIndexProximal;
@property(nonatomic, strong, nullable) VRM1HumanBone *leftIndexIntermediate;
@property(nonatomic, strong, nullable) VRM1HumanBone *leftIndexDistal;
@property(nonatomic, strong, nullable) VRM1HumanBone *leftMiddleProximal;
@property(nonatomic, strong, nullable) VRM1HumanBone *leftMiddleIntermediate;
@property(nonatomic, strong, nullable) VRM1HumanBone *leftMiddleDistal;
@property(nonatomic, strong, nullable) VRM1HumanBone *leftRingProximal;
@property(nonatomic, strong, nullable) VRM1HumanBone *leftRingIntermediate;
@property(nonatomic, strong, nullable) VRM1HumanBone *leftRingDistal;
@property(nonatomic, strong, nullable) VRM1HumanBone *leftLittleProximal;
@property(nonatomic, strong, nullable) VRM1HumanBone *leftLittleIntermediate;
@property(nonatomic, strong, nullable) VRM1HumanBone *leftLittleDistal;
@property(nonatomic, strong, nullable) VRM1HumanBone *rightThumbMetacarpal;
@property(nonatomic, strong, nullable) VRM1HumanBone *rightThumbProximal;
@property(nonatomic, strong, nullable) VRM1HumanBone *rightThumbDistal;
@property(nonatomic, strong, nullable) VRM1HumanBone *rightIndexProximal;
@property(nonatomic, strong, nullable) VRM1HumanBone *rightIndexIntermediate;
@property(nonatomic, strong, nullable) VRM1HumanBone *rightIndexDistal;
@property(nonatomic, strong, nullable) VRM1HumanBone *rightMiddleProximal;
@property(nonatomic, strong, nullable) VRM1HumanBone *rightMiddleIntermediate;
@property(nonatomic, strong, nullable) VRM1HumanBone *rightMiddleDistal;
@property(nonatomic, strong, nullable) VRM1HumanBone *rightRingProximal;
@property(nonatomic, strong, nullable) VRM1HumanBone *rightRingIntermediate;
@property(nonatomic, strong, nullable) VRM1HumanBone *rightRingDistal;
@property(nonatomic, strong, nullable) VRM1HumanBone *rightLittleProximal;
@property(nonatomic, strong, nullable) VRM1HumanBone *rightLittleIntermediate;
@property(nonatomic, strong, nullable) VRM1HumanBone *rightLittleDistal;

@end

@interface VRM1Humanoid : NSObject

@property(nonatomic, strong) VRM1HumanBones *humanBones;

@end

extern NSString *const VRM1FirstPersonMeshAnnotationTypeAuto;
extern NSString *const VRM1FirstPersonMeshAnnotationTypeBoth;
extern NSString *const VRM1FirstPersonMeshAnnotationTypeThirdPersonOnly;
extern NSString *const VRM1FirstPersonMeshAnnotationTypeFirstPersonOnly;

@interface VRM1FirstPersonMeshAnnotation : NSObject

@property(nonatomic, assign) uint32_t node;
@property(nonatomic, copy) NSString *type;

@end

@interface VRM1FirstPerson : NSObject

@property(nonatomic, strong, nullable)
    NSArray<VRM1FirstPersonMeshAnnotation *> *meshAnnotations;

@end

@interface VRM1LookAtRangeMap : NSObject

@property(nonatomic, strong, nullable) NSNumber *inputMaxValue;
@property(nonatomic, strong, nullable) NSNumber *outputScale;

@end

@interface Vec3 : NSObject

@property(nonatomic, assign) float x;
@property(nonatomic, assign) float y;
@property(nonatomic, assign) float z;

- (instancetype)initWithX:(float)x Y:(float)y Z:(float)z;

- (SCNVector3)scnVector3;

@end

extern NSString *const VRM1LookAtTypeBone;
extern NSString *const VRM1LookAtTypeExpression;

@interface VRM1LookAt : NSObject

@property(nonatomic, strong, nullable) Vec3 *offsetFromHeadBone;
@property(nonatomic, copy, nullable) NSString *type;
@property(nonatomic, strong, nullable)
    VRM1LookAtRangeMap *rangeMapHorizontalInner;
@property(nonatomic, strong, nullable)
    VRM1LookAtRangeMap *rangeMapHorizontalOuter;
@property(nonatomic, strong, nullable) VRM1LookAtRangeMap *rangeMapVerticalDown;
@property(nonatomic, strong, nullable) VRM1LookAtRangeMap *rangeMapVerticalUp;

- (BOOL)isTypeBone;
- (BOOL)isTypeExpression;

@end

extern NSString *const VRM1ExpressionMaterialColorBindTypeColor;
extern NSString *const VRM1ExpressionMaterialColorBindTypeEmissionColor;
extern NSString *const VRM1ExpressionMaterialColorBindTypeShadeColor;
extern NSString *const VRM1ExpressionMaterialColorBindTypeMatcapColor;
extern NSString *const VRM1ExpressionMaterialColorBindTypeRimColor;
extern NSString *const VRM1ExpressionMaterialColorBindTypeOutlineColor;

@interface VRM1ExpressionMaterialColorBind : NSObject

@property(nonatomic, assign) uint32_t material;
@property(nonatomic, copy) NSString *type;
@property(nonatomic, strong) NSArray<NSNumber *> *targetValue;

@end

@interface VRM1ExpressionMorphTargetBind : NSObject

@property(nonatomic, assign) uint32_t node;
@property(nonatomic, assign) uint32_t index;
@property(nonatomic, assign) float weight;

@end

@interface VRM1ExpressionTextureTransformBind : NSObject

@property(nonatomic, assign) uint32_t material;
@property(nonatomic, strong, nullable) NSArray<NSNumber *> *scale;
@property(nonatomic, strong, nullable) NSArray<NSNumber *> *offset;

@end

extern NSString *const VRM1ExpressionOverrideNone;
extern NSString *const VRM1ExpressionOverrideBlock;
extern NSString *const VRM1ExpressionOverrideBlend;

@interface VRM1Expression : NSObject

@property(nonatomic, strong, nullable)
    NSArray<VRM1ExpressionMorphTargetBind *> *morphTargetBinds;
@property(nonatomic, strong, nullable)
    NSArray<VRM1ExpressionMaterialColorBind *> *materialColorBinds;
@property(nonatomic, strong, nullable)
    NSArray<VRM1ExpressionTextureTransformBind *> *textureTransformBinds;
@property(nonatomic, assign) BOOL isBinary;
@property(nonatomic, copy, nullable) NSString *overrideBlink;
@property(nonatomic, copy, nullable) NSString *overrideLookAt;
@property(nonatomic, copy, nullable) NSString *overrideMouth;

@end

@interface VRM1ExpressionsPreset : NSObject

@property(nonatomic, strong, nullable) VRM1Expression *happy;
@property(nonatomic, strong, nullable) VRM1Expression *angry;
@property(nonatomic, strong, nullable) VRM1Expression *sad;
@property(nonatomic, strong, nullable) VRM1Expression *relaxed;
@property(nonatomic, strong, nullable) VRM1Expression *surprised;
@property(nonatomic, strong, nullable) VRM1Expression *aa;
@property(nonatomic, strong, nullable) VRM1Expression *ih;
@property(nonatomic, strong, nullable) VRM1Expression *ou;
@property(nonatomic, strong, nullable) VRM1Expression *ee;
@property(nonatomic, strong, nullable) VRM1Expression *oh;
@property(nonatomic, strong, nullable) VRM1Expression *blink;
@property(nonatomic, strong, nullable) VRM1Expression *blinkLeft;
@property(nonatomic, strong, nullable) VRM1Expression *blinkRight;
@property(nonatomic, strong, nullable) VRM1Expression *lookUp;
@property(nonatomic, strong, nullable) VRM1Expression *lookDown;
@property(nonatomic, strong, nullable) VRM1Expression *lookLeft;
@property(nonatomic, strong, nullable) VRM1Expression *lookRight;
@property(nonatomic, strong, nullable) VRM1Expression *neutral;

- (NSArray<NSString *> *)expressionNames;

@end

@interface VRM1Expressions : NSObject

@property(nonatomic, strong, nullable) VRM1ExpressionsPreset *preset;
@property(nonatomic, strong, nullable)
    NSDictionary<NSString *, VRM1Expression *> *custom;

- (nullable VRM1Expression *)expressionByName:(NSString *)name;
- (NSArray<NSString *> *)expressionNames;

@end

@interface VRM1VRM : NSObject

@property(nonatomic, copy) NSString *specVersion;
@property(nonatomic, strong) VRM1Meta *meta;
@property(nonatomic, strong) VRM1Humanoid *humanoid;
@property(nonatomic, strong, nullable) VRM1FirstPerson *firstPerson;
@property(nonatomic, strong, nullable) VRM1LookAt *lookAt;
@property(nonatomic, strong, nullable) VRM1Expressions *expressions;

- (nullable VRM1Expression *)expressionByName:(NSString *)name;

@end

extern NSString *const VRM0HumanoidBoneNameHips;
extern NSString *const VRM0HumanoidBoneNameLeftUpperLeg;
extern NSString *const VRM0HumanoidBoneNameRightUpperLeg;
extern NSString *const VRM0HumanoidBoneNameLeftLowerLeg;
extern NSString *const VRM0HumanoidBoneNameRightLowerLeg;
extern NSString *const VRM0HumanoidBoneNameLeftFoot;
extern NSString *const VRM0HumanoidBoneNameRightFoot;
extern NSString *const VRM0HumanoidBoneNameSpine;
extern NSString *const VRM0HumanoidBoneNameChest;
extern NSString *const VRM0HumanoidBoneNameNeck;
extern NSString *const VRM0HumanoidBoneNameHead;
extern NSString *const VRM0HumanoidBoneNameLeftShoulder;
extern NSString *const VRM0HumanoidBoneNameRightShoulder;
extern NSString *const VRM0HumanoidBoneNameLeftUpperArm;
extern NSString *const VRM0HumanoidBoneNameRightUpperArm;
extern NSString *const VRM0HumanoidBoneNameLeftLowerArm;
extern NSString *const VRM0HumanoidBoneNameRightLowerArm;
extern NSString *const VRM0HumanoidBoneNameLeftHand;
extern NSString *const VRM0HumanoidBoneNameRightHand;
extern NSString *const VRM0HumanoidBoneNameLeftToes;
extern NSString *const VRM0HumanoidBoneNameRightToes;
extern NSString *const VRM0HumanoidBoneNameLeftEye;
extern NSString *const VRM0HumanoidBoneNameRightEye;
extern NSString *const VRM0HumanoidBoneNameJaw;
extern NSString *const VRM0HumanoidBoneNameLeftThumbProximal;
extern NSString *const VRM0HumanoidBoneNameLeftThumbIntermediate;
extern NSString *const VRM0HumanoidBoneNameLeftThumbDistal;
extern NSString *const VRM0HumanoidBoneNameLeftIndexProximal;
extern NSString *const VRM0HumanoidBoneNameLeftIndexIntermediate;
extern NSString *const VRM0HumanoidBoneNameLeftIndexDistal;
extern NSString *const VRM0HumanoidBoneNameLeftMiddleProximal;
extern NSString *const VRM0HumanoidBoneNameLeftMiddleIntermediate;
extern NSString *const VRM0HumanoidBoneNameLeftMiddleDistal;
extern NSString *const VRM0HumanoidBoneNameLeftRingProximal;
extern NSString *const VRM0HumanoidBoneNameLeftRingIntermediate;
extern NSString *const VRM0HumanoidBoneNameLeftRingDistal;
extern NSString *const VRM0HumanoidBoneNameLeftLittleProximal;
extern NSString *const VRM0HumanoidBoneNameLeftLittleIntermediate;
extern NSString *const VRM0HumanoidBoneNameLeftLittleDistal;
extern NSString *const VRM0HumanoidBoneNameRightThumbProximal;
extern NSString *const VRM0HumanoidBoneNameRightThumbIntermediate;
extern NSString *const VRM0HumanoidBoneNameRightThumbDistal;
extern NSString *const VRM0HumanoidBoneNameRightIndexProximal;
extern NSString *const VRM0HumanoidBoneNameRightIndexIntermediate;
extern NSString *const VRM0HumanoidBoneNameRightIndexDistal;
extern NSString *const VRM0HumanoidBoneNameRightMiddleProximal;
extern NSString *const VRM0HumanoidBoneNameRightMiddleIntermediate;
extern NSString *const VRM0HumanoidBoneNameRightMiddleDistal;
extern NSString *const VRM0HumanoidBoneNameRightRingProximal;
extern NSString *const VRM0HumanoidBoneNameRightRingIntermediate;
extern NSString *const VRM0HumanoidBoneNameRightRingDistal;
extern NSString *const VRM0HumanoidBoneNameRightLittleProximal;
extern NSString *const VRM0HumanoidBoneNameRightLittleIntermediate;
extern NSString *const VRM0HumanoidBoneNameRightLittleDistal;
extern NSString *const VRM0HumanoidBoneNameUpperChest;

@interface VRM0HumanoidBone : NSObject

@property(nonatomic, copy, nullable) NSString *bone;
@property(nonatomic, strong, nullable) NSNumber *node;
@property(nonatomic, strong, nullable) NSNumber *useDefaultValues;
@property(nonatomic, strong, nullable) Vec3 *min;
@property(nonatomic, strong, nullable) Vec3 *max;
@property(nonatomic, strong, nullable) Vec3 *center;
@property(nonatomic, strong, nullable) NSNumber *axisLength;

@end

@interface VRM0Humanoid : NSObject

@property(nonatomic, strong, nullable) NSArray<VRM0HumanoidBone *> *humanBones;
@property(nonatomic, strong, nullable) NSNumber *armStretch;
@property(nonatomic, strong, nullable) NSNumber *legStretch;
@property(nonatomic, strong, nullable) NSNumber *upperArmTwist;
@property(nonatomic, strong, nullable) NSNumber *lowerArmTwist;
@property(nonatomic, strong, nullable) NSNumber *upperLegTwist;
@property(nonatomic, strong, nullable) NSNumber *lowerLegTwist;
@property(nonatomic, strong, nullable) NSNumber *feetSpacing;
@property(nonatomic, strong, nullable) NSNumber *hasTranslationDoF;

- (nullable VRM0HumanoidBone *)humanBoneByName:(NSString *)name;

@end

extern NSString *const VRM0MetaAllowedUserNameOnlyAuthor;
extern NSString *const VRM0MetaAllowedUserNameExplicitlyLicensedPerson;
extern NSString *const VRM0MetaAllowedUserNameEveryone;

extern NSString *const VRM0MetaUsagePermissionDisallow;
extern NSString *const VRM0MetaUsagePermissionAllow;

extern NSString *const VRM0MetaLicenseNameRedistributionProhibited;
extern NSString *const VRM0MetaLicenseNameCC0;
extern NSString *const VRM0MetaLicenseNameCCBY;
extern NSString *const VRM0MetaLicenseNameCCBYNC;
extern NSString *const VRM0MetaLicenseNameCCBYSA;
extern NSString *const VRM0MetaLicenseNameCCBYNCSA;
extern NSString *const VRM0MetaLicenseNameCCBYND;
extern NSString *const VRM0MetaLicenseNameCCBYNCND;
extern NSString *const VRM0MetaLicenseNameOther;

@interface VRM0Meta : NSObject

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

@interface VRM0FirstPersonMeshAnnotation : NSObject

@property(nonatomic, strong, nullable) NSNumber *mesh;
@property(nonatomic, copy, nullable) NSString *firstPersonFlag;

@end

@interface VRM0FirstPersonDegreeMapCurve : NSObject

@property(nonatomic, assign) float time;
@property(nonatomic, assign) float value;
@property(nonatomic, assign) float inTangent;
@property(nonatomic, assign) float outTangent;

@end

@interface VRM0FirstPersonDegreeMap : NSObject

@property(nonatomic, strong, nullable)
    NSArray<VRM0FirstPersonDegreeMapCurve *> *curve;
@property(nonatomic, strong, nullable) NSNumber *xRange;
@property(nonatomic, strong, nullable) NSNumber *yRange;

@end

extern NSString *const VRM0FirstPersonLookAtTypeBone;
extern NSString *const VRM0FirstPersonLookAtTypeBlendShape;

@interface VRM0FirstPerson : NSObject

@property(nonatomic, strong, nullable) NSNumber *firstPersonBone;
@property(nonatomic, strong, nullable) Vec3 *firstPersonBoneOffset;
@property(nonatomic, strong, nullable)
    NSArray<VRM0FirstPersonMeshAnnotation *> *meshAnnotations;
@property(nonatomic, copy, nullable) NSString *lookAtTypeName;
@property(nonatomic, strong, nullable)
    VRM0FirstPersonDegreeMap *lookAtHorizontalInner;
@property(nonatomic, strong, nullable)
    VRM0FirstPersonDegreeMap *lookAtHorizontalOuter;
@property(nonatomic, strong, nullable)
    VRM0FirstPersonDegreeMap *lookAtVerticalDown;
@property(nonatomic, strong, nullable)
    VRM0FirstPersonDegreeMap *lookAtVerticalUp;

- (BOOL)isLookAtTypeBone;
- (BOOL)isLookAtTypeBlendShape;

@end

@interface VRM0BlendShapeBind : NSObject

@property(nonatomic, strong, nullable) NSNumber *mesh;
@property(nonatomic, strong, nullable) NSNumber *index;
@property(nonatomic, strong, nullable) NSNumber *weight;

@end

@interface VRM0BlendShapeMaterialBind : NSObject

@property(nonatomic, copy, nullable) NSString *materialName;
@property(nonatomic, copy, nullable) NSString *propertyName;
@property(nonatomic, strong, nullable) NSArray<NSNumber *> *targetValue;

@end

extern NSString *const VRM0BlendShapeGroupPresetNameUnknown;
extern NSString *const VRM0BlendShapeGroupPresetNameNeutral;
extern NSString *const VRM0BlendShapeGroupPresetNameA;
extern NSString *const VRM0BlendShapeGroupPresetNameI;
extern NSString *const VRM0BlendShapeGroupPresetNameU;
extern NSString *const VRM0BlendShapeGroupPresetNameE;
extern NSString *const VRM0BlendShapeGroupPresetNameO;
extern NSString *const VRM0BlendShapeGroupPresetNameBlink;
extern NSString *const VRM0BlendShapeGroupPresetNameJoy;
extern NSString *const VRM0BlendShapeGroupPresetNameAngry;
extern NSString *const VRM0BlendShapeGroupPresetNameSorrow;
extern NSString *const VRM0BlendShapeGroupPresetNameFun;
extern NSString *const VRM0BlendShapeGroupPresetNameLookUp;
extern NSString *const VRM0BlendShapeGroupPresetNameLookDown;
extern NSString *const VRM0BlendShapeGroupPresetNameLookLeft;
extern NSString *const VRM0BlendShapeGroupPresetNameLookRight;
extern NSString *const VRM0BlendShapeGroupPresetNameBlinkL;
extern NSString *const VRM0BlendShapeGroupPresetNameBlinkR;

@interface VRM0BlendShapeGroup : NSObject

@property(nonatomic, copy, nullable) NSString *name;
@property(nonatomic, copy, nullable) NSString *presetName;
@property(nonatomic, strong, nullable) NSArray<VRM0BlendShapeBind *> *binds;
@property(nonatomic, strong, nullable)
    NSArray<VRM0BlendShapeMaterialBind *> *materialValues;
@property(nonatomic, assign) BOOL isBinary;

- (nullable NSString *)groupName;

@end

@interface VRM0BlendShape : NSObject

@property(nonatomic, strong, nullable)
    NSArray<VRM0BlendShapeGroup *> *blendShapeGroups;

- (nullable VRM0BlendShapeGroup *)blendShapeGroupByPreset:
    (NSString *)presetName;
- (NSArray<NSString *> *)groupNames;

@end

@interface VRM0SecondaryAnimationCollider : NSObject

@property(nonatomic, strong, nullable) Vec3 *offset;
@property(nonatomic, strong, nullable) NSNumber *radius;

- (SCNVector3)offsetValue;
- (float)radiusValue;

@end

@interface VRM0SecondaryAnimationColliderGroup : NSObject

@property(nonatomic, strong, nullable) NSNumber *node;
@property(nonatomic, strong, nullable)
    NSArray<VRM0SecondaryAnimationCollider *> *colliders;

@end

@interface VRM0SecondaryAnimationSpring : NSObject

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

@interface VRM0SecondaryAnimation : NSObject

@property(nonatomic, strong, nullable)
    NSArray<VRM0SecondaryAnimationSpring *> *boneGroups;
@property(nonatomic, strong, nullable)
    NSArray<VRM0SecondaryAnimationColliderGroup *> *colliderGroups;

@end

@interface VRM0Material : NSObject

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

@interface VRM0VRM : NSObject

@property(nonatomic, copy, nullable) NSString *exporterVersion;
@property(nonatomic, copy, nullable) NSString *specVersion;
@property(nonatomic, strong, nullable) VRM0Meta *meta;
@property(nonatomic, strong, nullable) VRM0Humanoid *humanoid;
@property(nonatomic, strong, nullable) VRM0FirstPerson *firstPerson;
@property(nonatomic, strong, nullable) VRM0BlendShape *blendShapeMaster;
@property(nonatomic, strong, nullable)
    VRM0SecondaryAnimation *secondaryAnimation;
@property(nonatomic, strong, nullable)
    NSArray<VRM0Material *> *materialProperties;

- (nullable VRM0BlendShapeGroup *)blendShapeGroupByPreset:
    (NSString *)presetName;

@end

@interface VRMSpringBoneShapeSphere : NSObject

@property(nonatomic, strong, nullable) Vec3 *offset;
@property(nonatomic, strong, nullable) NSNumber *radius;

- (SCNVector3)offsetValue;
- (float)radiusValue;

@end

@interface VRMSpringBoneShapeCapsule : NSObject

@property(nonatomic, strong, nullable) Vec3 *offset;
@property(nonatomic, strong, nullable) NSNumber *radius;
@property(nonatomic, strong, nullable) Vec3 *tail;

- (SCNVector3)offsetValue;
- (float)radiusValue;
- (SCNVector3)tailValue;

@end

@interface VRMSpringBoneShape : NSObject

@property(nonatomic, strong, nullable) VRMSpringBoneShapeSphere *sphere;
@property(nonatomic, strong, nullable) VRMSpringBoneShapeCapsule *capsule;

@end

@interface VRMSpringBoneCollider : NSObject

@property(nonatomic, assign) NSUInteger node;
@property(nonatomic, strong) VRMSpringBoneShape *shape;

@end

@interface VRMSpringBoneJoint : NSObject

@property(nonatomic, assign) NSUInteger node;
@property(nonatomic, strong, nullable) NSNumber *hitRadius;
@property(nonatomic, strong, nullable) NSNumber *stiffness;
@property(nonatomic, strong, nullable) NSNumber *gravityPower;
@property(nonatomic, strong, nullable) Vec3 *gravityDir;
@property(nonatomic, strong, nullable) NSNumber *dragForce;

- (float)hitRadiusValue;
- (float)stiffnessValue;
- (float)gravityPowerValue;
- (SCNVector3)gravityDirValue;
- (float)dragForceValue;

@end

@interface VRMSpringBoneColliderGroup : NSObject

@property(nonatomic, copy, nullable) NSString *name;
@property(nonatomic, strong) NSArray<NSNumber *> *colliders;

@end

@interface VRMSpringBoneSpring : NSObject

@property(nonatomic, copy, nullable) NSString *name;
@property(nonatomic, strong) NSArray<VRMSpringBoneJoint *> *joints;
@property(nonatomic, strong, nullable) NSArray<NSNumber *> *colliderGroups;
@property(nonatomic, strong, nullable) NSNumber *center;

@end

@interface VRMSpringBone : NSObject

@property(nonatomic, copy) NSString *specVersion;
@property(nonatomic, strong, nullable)
    NSArray<VRMSpringBoneCollider *> *colliders;
@property(nonatomic, strong, nullable)
    NSArray<VRMSpringBoneColliderGroup *> *colliderGroups;
@property(nonatomic, strong, nullable) NSArray<VRMSpringBoneSpring *> *springs;

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
@property(nonatomic, strong, nullable) VRM0VRM *vrm0;
@property(nonatomic, strong, nullable) VRM1VRM *vrm1;
@property(nonatomic, strong, nullable) VRMSpringBone *springBone;

@end

NS_ASSUME_NONNULL_END
