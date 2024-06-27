#import "GLTFJson.h"
#import "SceneKitUtil.h"

@implementation GLTFAccessorSparseIndices

@end

@implementation GLTFAccessorSparseValues

@end

@implementation GLTFAccessorSparse

@end

NSString *const GLTFAccessorTypeScalar = @"SCALAR";
NSString *const GLTFAccessorTypeVec2 = @"VEC2";
NSString *const GLTFAccessorTypeVec3 = @"VEC3";
NSString *const GLTFAccessorTypeVec4 = @"VEC4";
NSString *const GLTFAccessorTypeMat2 = @"MAT2";
NSString *const GLTFAccessorTypeMat3 = @"MAT3";
NSString *const GLTFAccessorTypeMat4 = @"MAT4";

@implementation GLTFAccessor

@end

NSString *const GLTFAnimationChannelTargetPathTranslation = @"translation";
NSString *const GLTFAnimationChannelTargetPathRotation = @"rotation";
NSString *const GLTFAnimationChannelTargetPathScale = @"scale";
NSString *const GLTFAnimationChannelTargetPathWeights = @"weights";

@implementation GLTFAnimationChannelTarget

@end

@implementation GLTFAnimationChannel

@end

NSString *const GLTFAnimationSamplerInterpolationLinear = @"LINEAR";
NSString *const GLTFAnimationSamplerInterpolationStep = @"STEP";
NSString *const GLTFAnimationSamplerInterpolationCubicSpline = @"CUBICSPLINE";

@implementation GLTFAnimationSampler

@end

@implementation GLTFAnimation

@end

@implementation GLTFAsset

@end

@implementation GLTFBuffer

@end

@implementation GLTFBufferView

@end

@implementation GLTFCameraOrthographic

@end

@implementation GLTFCameraPerspective

@end

NSString *const GLTFCameraTypePerspective = @"perspective";
NSString *const GLTFCameraTypeOrthographic = @"orthographic";

@implementation GLTFCamera

@end

NSString *const GLTFImageMimeTypeJPEG = @"image/jpeg";
NSString *const GLTFImageMimeTypePNG = @"image/png";

@implementation GLTFImage

@end

@implementation GLTFTexture

@end

@implementation KHRTextureTransform

@end

@implementation GLTFTextureInfo

@end

@implementation GLTFMaterialPBRMetallicRoughness

@end

@implementation GLTFMaterialNormalTextureInfo

@end

@implementation GLTFMaterialOcclusionTextureInfo

@end

@implementation KHRMaterialAnisotropy

@end

@implementation KHRMaterialSheen

@end

@implementation KHRMaterialSpecular

@end

@implementation KHRMaterialIor

@end

@implementation KHRMaterialClearcoat

@end

@implementation KHRMaterialDispersion

@end

@implementation KHRMaterialEmissiveStrength

@end

@implementation KHRMaterialIridescence

@end

@implementation KHRMaterialVolume

@end

@implementation KHRMaterialTransmission

@end

NSString *const GLTFMaterialAlphaModeOpaque = @"OPAQUE";
NSString *const GLTFMaterialAlphaModeMask = @"MASK";
NSString *const GLTFMaterialAlphaModeBlend = @"BLEND";

@implementation GLTFMaterial

@end

@implementation GLTFMeshPrimitiveTarget

@end

@implementation GLTFMeshPrimitiveAttributes

@end

@implementation GLTFMeshPrimitiveDracoExtension

@end

@implementation GLTFMeshPrimitive

@end

@implementation GLTFMesh

@end

@implementation GLTFNode

@end

@implementation GLTFSampler

@end

@implementation GLTFScene

@end

@implementation GLTFSkin

@end

@implementation KHRLightSpot

@end

NSString *const KHRLightTypePoint = @"point";
NSString *const KHRLightTypeSpot = @"spot";
NSString *const KHRLightTypeDirectional = @"directional";

@implementation KHRLight

@end

NSString *const VRM1MetaAvatarPermissionOnlyAuthor = @"onlyAuthor";
NSString *const VRM1MetaAvatarPermissionOnlySeparatelyLicensedPerson =
    @"onlySeparatelyLicensedPerson";
NSString *const VRM1MetaAvatarPermissionEveryone = @"everyone";

NSString *const VRM1MetaCommercialUsagePersonalNonProfit = @"personalNonProfit";
NSString *const VRM1MetaCommercialUsagePersonalProfit = @"personalProfit";
NSString *const VRM1MetaCommercialUsageCorporation = @"corporation";

NSString *const VRM1MetaCreditNotationRequired = @"required";
NSString *const VRM1MetaCreditNotationUnnecessary = @"unnecessary";

NSString *const VRM1MetaModificationProhibited = @"prohibited";
NSString *const VRM1MetaModificationAllowModification = @"allowModification";
NSString *const VRM1MetaModificationAllowModificationRedistribution =
    @"allowModificationRedistribution";

@implementation VRM1Meta

@end

@implementation VRM1HumanBone

@end

@implementation VRM1HumanBones

@end

@implementation VRM1Humanoid

@end

NSString *const VRM1FirstPersonMeshAnnotationTypeAuto = @"auto";
NSString *const VRM1FirstPersonMeshAnnotationTypeBoth = @"both";
NSString *const VRM1FirstPersonMeshAnnotationTypeThirdPersonOnly =
    @"thirdPersonOnly";
NSString *const VRM1FirstPersonMeshAnnotationTypeFirstPersonOnly =
    @"firstPersonOnly";

@implementation VRM1FirstPersonMeshAnnotation

@end

@implementation VRM1FirstPerson

@end

@implementation VRM1LookAtRangeMap

@end

NSString *const VRM1LookAtTypeBone = @"bone";
NSString *const VRM1LookAtTypeExpression = @"expression";

@implementation VRM1LookAt

- (BOOL)isTypeBone {
  if (self.type)
    return [self.type isEqualToString:VRM1LookAtTypeBone];
  return NO;
}

- (BOOL)isTypeExpression {
  if (self.type)
    return [self.type isEqualToString:VRM1LookAtTypeExpression];
  return NO;
}

@end

NSString *const VRM1ExpressionMaterialColorBindTypeColor = @"color";
NSString *const VRM1ExpressionMaterialColorBindTypeEmissionColor =
    @"emissionColor";
NSString *const VRM1ExpressionMaterialColorBindTypeShadeColor = @"shadeColor";
NSString *const VRM1ExpressionMaterialColorBindTypeMatcapColor = @"matcapColor";
NSString *const VRM1ExpressionMaterialColorBindTypeRimColor = @"rimColor";
NSString *const VRM1ExpressionMaterialColorBindTypeOutlineColor =
    @"outlineColor";

@implementation VRM1ExpressionMaterialColorBind

@end

@implementation VRM1ExpressionMorphTargetBind

@end

@implementation VRM1ExpressionTextureTransformBind

@end

NSString *const VRM1ExpressionOverrideNone = @"none";
NSString *const VRM1ExpressionOverrideBlock = @"block";
NSString *const VRM1ExpressionOverrideBlend = @"blend";

@implementation VRM1Expression

@end

@implementation VRM1ExpressionsPreset

- (NSArray<NSString *> *)expressionNames {
  NSMutableArray<NSString *> *names = [NSMutableArray array];
  if (self.happy) {
    [names addObject:@"happy"];
  }
  if (self.angry) {
    [names addObject:@"angry"];
  }
  if (self.sad) {
    [names addObject:@"sad"];
  }
  if (self.relaxed) {
    [names addObject:@"relaxed"];
  }
  if (self.surprised) {
    [names addObject:@"surprised"];
  }
  if (self.aa) {
    [names addObject:@"aa"];
  }
  if (self.ih) {
    [names addObject:@"ih"];
  }
  if (self.ou) {
    [names addObject:@"ou"];
  }
  if (self.ee) {
    [names addObject:@"ee"];
  }
  if (self.oh) {
    [names addObject:@"oh"];
  }
  if (self.blink) {
    [names addObject:@"blink"];
  }
  if (self.blinkLeft) {
    [names addObject:@"blinkLeft"];
  }
  if (self.blinkRight) {
    [names addObject:@"blinkRight"];
  }
  if (self.lookUp) {
    [names addObject:@"lookUp"];
  }
  if (self.lookDown) {
    [names addObject:@"lookDown"];
  }
  if (self.lookLeft) {
    [names addObject:@"lookLeft"];
  }
  if (self.lookRight) {
    [names addObject:@"lookRight"];
  }
  if (self.neutral) {
    [names addObject:@"neutral"];
  }
  return [names copy];
}
@end

@implementation VRM1Expressions

- (nullable VRM1Expression *)expressionByName:(NSString *)name {
  NSString *lower = name.lowercaseString;
  if (self.preset) {
    if ([lower isEqualToString:@"happy"]) {
      return self.preset.happy;
    } else if ([lower isEqualToString:@"angry"]) {
      return self.preset.angry;
    } else if ([lower isEqualToString:@"sad"]) {
      return self.preset.sad;
    } else if ([lower isEqualToString:@"relaxed"]) {
      return self.preset.relaxed;
    } else if ([lower isEqualToString:@"surprised"]) {
      return self.preset.surprised;
    } else if ([lower isEqualToString:@"aa"]) {
      return self.preset.aa;
    } else if ([lower isEqualToString:@"ih"]) {
      return self.preset.ih;
    } else if ([lower isEqualToString:@"ou"]) {
      return self.preset.ou;
    } else if ([lower isEqualToString:@"ee"]) {
      return self.preset.ee;
    } else if ([lower isEqualToString:@"oh"]) {
      return self.preset.oh;
    } else if ([lower isEqualToString:@"blink"]) {
      return self.preset.blink;
    } else if ([lower isEqualToString:@"blinkLeft"]) {
      return self.preset.blinkLeft;
    } else if ([lower isEqualToString:@"blinkRight"]) {
      return self.preset.blinkRight;
    } else if ([lower isEqualToString:@"lookUp"]) {
      return self.preset.lookUp;
    } else if ([lower isEqualToString:@"lookDown"]) {
      return self.preset.lookDown;
    } else if ([lower isEqualToString:@"lookLeft"]) {
      return self.preset.lookLeft;
    } else if ([lower isEqualToString:@"lookRight"]) {
      return self.preset.lookRight;
    } else if ([lower isEqualToString:@"neutral"]) {
      return self.preset.neutral;
    }
  }
  if (self.custom) {
    for (NSString *key in self.custom) {
      if ([key.lowercaseString isEqualToString:lower]) {
        return self.custom[key];
      }
    }
  }
  return nil;
}

- (NSArray<NSString *> *)expressionNames {
  NSMutableArray<NSString *> *names = [NSMutableArray array];
  if (self.preset) {
    names = [NSMutableArray arrayWithArray:self.preset.expressionNames];
  }
  if (self.custom) {
    [names addObjectsFromArray:self.custom.allKeys];
  }
  return [names copy];
}

@end

@implementation VRM1VRM

- (nullable VRM1Expression *)expressionByName:(NSString *)name {
  if (!self.expressions)
    return nil;
  return [self.expressions expressionByName:name];
}

@end

@implementation Vec3

- (instancetype)initWithX:(float)x Y:(float)y Z:(float)z {
  self = [super init];
  if (self) {
    self.x = x;
    self.y = y;
    self.z = z;
  }
  return self;
}

- (SCNVector3)scnVector3;
{ return SCNVector3Make(self.x, self.y, self.z); }

@end

NSString *const VRM0HumanoidBoneNameHips = @"hips";
NSString *const VRM0HumanoidBoneNameLeftUpperLeg = @"leftUpperLeg";
NSString *const VRM0HumanoidBoneNameRightUpperLeg = @"rightUpperLeg";
NSString *const VRM0HumanoidBoneNameLeftLowerLeg = @"leftLowerLeg";
NSString *const VRM0HumanoidBoneNameRightLowerLeg = @"rightLowerLeg";
NSString *const VRM0HumanoidBoneNameLeftFoot = @"leftFoot";
NSString *const VRM0HumanoidBoneNameRightFoot = @"rightFoot";
NSString *const VRM0HumanoidBoneNameSpine = @"spine";
NSString *const VRM0HumanoidBoneNameChest = @"chest";
NSString *const VRM0HumanoidBoneNameNeck = @"neck";
NSString *const VRM0HumanoidBoneNameHead = @"head";
NSString *const VRM0HumanoidBoneNameLeftShoulder = @"leftShoulder";
NSString *const VRM0HumanoidBoneNameRightShoulder = @"rightShoulder";
NSString *const VRM0HumanoidBoneNameLeftUpperArm = @"leftUpperArm";
NSString *const VRM0HumanoidBoneNameRightUpperArm = @"rightUpperArm";
NSString *const VRM0HumanoidBoneNameLeftLowerArm = @"leftLowerArm";
NSString *const VRM0HumanoidBoneNameRightLowerArm = @"rightLowerArm";
NSString *const VRM0HumanoidBoneNameLeftHand = @"leftHand";
NSString *const VRM0HumanoidBoneNameRightHand = @"rightHand";
NSString *const VRM0HumanoidBoneNameLeftToes = @"leftToes";
NSString *const VRM0HumanoidBoneNameRightToes = @"rightToes";
NSString *const VRM0HumanoidBoneNameLeftEye = @"leftEye";
NSString *const VRM0HumanoidBoneNameRightEye = @"rightEye";
NSString *const VRM0HumanoidBoneNameJaw = @"jaw";
NSString *const VRM0HumanoidBoneNameLeftThumbProximal = @"leftThumbProximal";
NSString *const VRM0HumanoidBoneNameLeftThumbIntermediate =
    @"leftThumbIntermediate";
NSString *const VRM0HumanoidBoneNameLeftThumbDistal = @"leftThumbDistal";
NSString *const VRM0HumanoidBoneNameLeftIndexProximal = @"leftIndexProximal";
NSString *const VRM0HumanoidBoneNameLeftIndexIntermediate =
    @"leftIndexIntermediate";
NSString *const VRM0HumanoidBoneNameLeftIndexDistal = @"leftIndexDistal";
NSString *const VRM0HumanoidBoneNameLeftMiddleProximal = @"leftMiddleProximal";
NSString *const VRM0HumanoidBoneNameLeftMiddleIntermediate =
    @"leftMiddleIntermediate";
NSString *const VRM0HumanoidBoneNameLeftMiddleDistal = @"leftMiddleDistal";
NSString *const VRM0HumanoidBoneNameLeftRingProximal = @"leftRingProximal";
NSString *const VRM0HumanoidBoneNameLeftRingIntermediate =
    @"leftRingIntermediate";
NSString *const VRM0HumanoidBoneNameLeftRingDistal = @"leftRingDistal";
NSString *const VRM0HumanoidBoneNameLeftLittleProximal = @"leftLittleProximal";
NSString *const VRM0HumanoidBoneNameLeftLittleIntermediate =
    @"leftLittleIntermediate";
NSString *const VRM0HumanoidBoneNameLeftLittleDistal = @"leftLittleDistal";
NSString *const VRM0HumanoidBoneNameRightThumbProximal = @"rightThumbProximal";
NSString *const VRM0HumanoidBoneNameRightThumbIntermediate =
    @"rightThumbIntermediate";
NSString *const VRM0HumanoidBoneNameRightThumbDistal = @"rightThumbDistal";
NSString *const VRM0HumanoidBoneNameRightIndexProximal = @"rightIndexProximal";
NSString *const VRM0HumanoidBoneNameRightIndexIntermediate =
    @"rightIndexIntermediate";
NSString *const VRM0HumanoidBoneNameRightIndexDistal = @"rightIndexDistal";
NSString *const VRM0HumanoidBoneNameRightMiddleProximal =
    @"rightMiddleProximal";
NSString *const VRM0HumanoidBoneNameRightMiddleIntermediate =
    @"rightMiddleIntermediate";
NSString *const VRM0HumanoidBoneNameRightMiddleDistal = @"rightMiddleDistal";
NSString *const VRM0HumanoidBoneNameRightRingProximal = @"rightRingProximal";
NSString *const VRM0HumanoidBoneNameRightRingIntermediate =
    @"rightRingIntermediate";
NSString *const VRM0HumanoidBoneNameRightRingDistal = @"rightRingDistal";
NSString *const VRM0HumanoidBoneNameRightLittleProximal =
    @"rightLittleProximal";
NSString *const VRM0HumanoidBoneNameRightLittleIntermediate =
    @"rightLittleIntermediate";
NSString *const VRM0HumanoidBoneNameRightLittleDistal = @"rightLittleDistal";
NSString *const VRM0HumanoidBoneNameUpperChest = @"upperChest";

@implementation VRM0HumanoidBone

@end

@implementation VRM0Humanoid

- (nullable VRM0HumanoidBone *)humanBoneByName:(NSString *)name {
  if (self.humanBones) {
    for (VRM0HumanoidBone *bone in self.humanBones) {
      if (bone.bone && [bone.bone isEqualToString:name]) {
        return bone;
      }
    }
  }
  return nil;
}

@end

NSString *const VRM0MetaAllowedUserNameOnlyAuthor = @"OnlyAuthor";
NSString *const VRM0MetaAllowedUserNameExplicitlyLicensedPerson =
    @"ExplicitlyLicensedPerson";
NSString *const VRM0MetaAllowedUserNameEveryone = @"Everyone";

NSString *const VRM0MetaUsagePermissionDisallow = @"Disallow";
NSString *const VRM0MetaUsagePermissionAllow = @"Allow";

NSString *const VRM0MetaLicenseNameRedistributionProhibited =
    @"Redistribution_Prohibited";
NSString *const VRM0MetaLicenseNameCC0 = @"CC0";
NSString *const VRM0MetaLicenseNameCCBY = @"CC_BY";
NSString *const VRM0MetaLicenseNameCCBYNC = @"CC_BY_NC";
NSString *const VRM0MetaLicenseNameCCBYSA = @"CC_BY_SA";
NSString *const VRM0MetaLicenseNameCCBYNCSA = @"CC_BY_NC_SA";
NSString *const VRM0MetaLicenseNameCCBYND = @"CC_BY_ND";
NSString *const VRM0MetaLicenseNameCCBYNCND = @"CC_BY_NC_ND";
NSString *const VRM0MetaLicenseNameOther = @"Other";

@implementation VRM0Meta

@end

@implementation VRM0FirstPersonMeshAnnotation

@end

@implementation VRM0FirstPersonDegreeMapCurve

@end

@implementation VRM0FirstPersonDegreeMap

@end

NSString *const VRM0FirstPersonLookAtTypeBone = @"Bone";
NSString *const VRM0FirstPersonLookAtTypeBlendShape = @"BlendShape";

@implementation VRM0FirstPerson

- (BOOL)isLookAtTypeBone {
  if (self.lookAtTypeName)
    return [self.lookAtTypeName isEqualToString:VRM0FirstPersonLookAtTypeBone];
  if (self.firstPersonBone != nil && self.firstPersonBoneOffset != nil)
    return YES;
  return NO;
}

- (BOOL)isLookAtTypeBlendShape {
  if (self.lookAtTypeName)
    return [self.lookAtTypeName
        isEqualToString:VRM0FirstPersonLookAtTypeBlendShape];
  return NO;
}

@end

@implementation VRM0BlendShapeBind

@end

@implementation VRM0BlendShapeMaterialBind

@end

NSString *const VRM0BlendShapeGroupPresetNameUnknown = @"unknown";
NSString *const VRM0BlendShapeGroupPresetNameNeutral = @"neutral";
NSString *const VRM0BlendShapeGroupPresetNameA = @"a";
NSString *const VRM0BlendShapeGroupPresetNameI = @"i";
NSString *const VRM0BlendShapeGroupPresetNameU = @"u";
NSString *const VRM0BlendShapeGroupPresetNameE = @"e";
NSString *const VRM0BlendShapeGroupPresetNameO = @"o";
NSString *const VRM0BlendShapeGroupPresetNameBlink = @"blink";
NSString *const VRM0BlendShapeGroupPresetNameJoy = @"joy";
NSString *const VRM0BlendShapeGroupPresetNameAngry = @"angry";
NSString *const VRM0BlendShapeGroupPresetNameSorrow = @"sorrow";
NSString *const VRM0BlendShapeGroupPresetNameFun = @"fun";
NSString *const VRM0BlendShapeGroupPresetNameLookUp = @"lookup";
NSString *const VRM0BlendShapeGroupPresetNameLookDown = @"lookdown";
NSString *const VRM0BlendShapeGroupPresetNameLookLeft = @"lookleft";
NSString *const VRM0BlendShapeGroupPresetNameLookRight = @"lookright";
NSString *const VRM0BlendShapeGroupPresetNameBlinkL = @"blink_l";
NSString *const VRM0BlendShapeGroupPresetNameBlinkR = @"blink_r";

@implementation VRM0BlendShapeGroup

- (nullable NSString *)groupName {
  return self.presetName ?: self.name;
}

@end

@implementation VRM0BlendShape

- (nullable VRM0BlendShapeGroup *)blendShapeGroupByPreset:
    (NSString *)presetName {
  if (!self.blendShapeGroups)
    return nil;
  for (VRM0BlendShapeGroup *group in self.blendShapeGroups) {
    if ([group.groupName.lowercaseString
            isEqualToString:presetName.lowercaseString]) {
      return group;
    }
  }
  return nil;
}

- (NSArray<NSString *> *)groupNames {
  NSMutableArray<NSString *> *names = [NSMutableArray array];
  if (self.blendShapeGroups) {
    for (VRM0BlendShapeGroup *group in self.blendShapeGroups) {
      [names addObject:group.groupName];
    }
  }
  return [names copy];
}

@end

@implementation VRM0SecondaryAnimationCollider

- (SCNVector3)offsetValue {
  if (self.offset)
    return self.offset.scnVector3;
  return SCNVector3Make(0, 0, 0);
}

- (float)radiusValue {
  if (self.radius)
    return self.radius.floatValue;
  return 0;
}

- (SCNNode *)toSCNNode {
  SCNNode *colliderNode = [SCNNode node];
  colliderNode.geometry = [SCNSphere sphereWithRadius:self.radiusValue];
  SCNVector3 offset = self.offsetValue;
  colliderNode.position = offset;
  colliderNode.geometry.firstMaterial.transparency = 0.0;
  colliderNode.physicsBody = [SCNPhysicsBody
      bodyWithType:SCNPhysicsBodyTypeKinematic
             shape:[SCNPhysicsShape shapeWithNode:colliderNode options:nil]];
  return colliderNode;
}

@end

@implementation VRM0SecondaryAnimationColliderGroup

@end

@implementation VRM0SecondaryAnimationSpring

- (float)hitRadiusValue {
  if (self.hitRadius)
    return self.hitRadius.floatValue;
  return 0;
}

- (float)stiffinessValue {
  if (self.stiffiness)
    return self.stiffiness.floatValue;
  return 1.0f;
}

- (float)gravityPowerValue {
  if (self.gravityPower)
    return self.gravityPower.floatValue;
  return 0;
}

- (SCNVector3)gravityDirValue {
  if (self.gravityDir)
    return self.gravityDir.scnVector3;
  return SCNVector3Make(0, -1.0f, 0);
}

- (float)dragForceValue {
  if (self.dragForce)
    return self.dragForce.floatValue;
  return 0.5f;
}

@end

@implementation VRM0SecondaryAnimation

@end

@implementation VRM0Material

@end

@implementation VRM0VRM

- (nullable VRM0BlendShapeGroup *)blendShapeGroupByPreset:
    (NSString *)presetName {
  if (!self.blendShapeMaster)
    return nil;
  return [self.blendShapeMaster blendShapeGroupByPreset:presetName];
}

@end

@implementation VRMSpringBoneShapeSphere

- (SCNVector3)offsetValue {
  if (self.offset)
    return self.offset.scnVector3;
  return SCNVector3Make(0, 0, 0);
}

- (float)radiusValue {
  if (self.radius)
    return self.radius.floatValue;
  return 0;
}

@end

@implementation VRMSpringBoneShapeCapsule

- (SCNVector3)offsetValue {
  if (self.offset)
    return self.offset.scnVector3;
  return SCNVector3Make(0, 0, 0);
}

- (float)radiusValue {
  if (self.radius)
    return self.radius.floatValue;
  return 0;
}

- (SCNVector3)tailValue {
  if (self.tail)
    return self.tail.scnVector3;
  return SCNVector3Make(0, 0, 0);
}

@end

@implementation VRMSpringBoneShape
@end

@implementation VRMSpringBoneCollider

- (SCNNode *)toSCNNode {
  SCNNode *colliderNode = [SCNNode node];
  if (self.shape.sphere) {
    colliderNode.geometry =
        [SCNSphere sphereWithRadius:self.shape.sphere.radiusValue];
    SCNVector3 offset = self.shape.sphere.offsetValue;
    colliderNode.position = offset;
  } else if (self.shape.capsule) {
    SCNVector3 offset = self.shape.capsule.offsetValue;
    SCNVector3 tail = self.shape.capsule.tailValue;
    float height = sqrt(pow(tail.x - offset.x, 2) + pow(tail.y - offset.y, 2) +
                        pow(tail.z - offset.z, 2));
    colliderNode.geometry =
        [SCNCapsule capsuleWithCapRadius:self.shape.capsule.radiusValue
                                  height:height];

    colliderNode.position = offset;

    SCNVector3 direction =
        SCNVector3Make(tail.x - offset.x, tail.y - offset.y, tail.z - offset.z);
    SCNVector3 up = SCNVector3Make(0, 1, 0);
    SCNVector3 cross = SCNVector3Cross(up, direction);
    SCNVector3 axis = SCNVector3Cross(up, direction);
    CGFloat angle = SCNVector3AngleBetween(up, direction);
    colliderNode.rotation = SCNVector4Make(axis.x, axis.y, axis.z, angle);
  }
  colliderNode.geometry.firstMaterial.transparency = 0.0;
  colliderNode.physicsBody = [SCNPhysicsBody
      bodyWithType:SCNPhysicsBodyTypeKinematic
             shape:[SCNPhysicsShape shapeWithNode:colliderNode options:nil]];
  return colliderNode;
}

@end

@implementation VRMSpringBoneJoint

- (float)hitRadiusValue {
  if (self.hitRadius)
    return self.hitRadius.floatValue;
  return 0;
}

- (float)stiffnessValue {
  if (self.stiffness)
    return self.stiffness.floatValue;
  return 1.0f;
}

- (float)gravityPowerValue {
  if (self.gravityPower)
    return self.gravityPower.floatValue;
  return 0;
}

- (SCNVector3)gravityDirValue {
  if (self.gravityDir)
    return self.gravityDir.scnVector3;
  return SCNVector3Make(0, -1.0f, 0);
}

- (float)dragForceValue {
  if (self.dragForce)
    return self.dragForce.floatValue;
  return 0.5f;
}

@end

@implementation VRMSpringBoneColliderGroup
@end

@implementation VRMSpringBoneSpring
@end

@implementation VRMSpringBone
@end

@implementation GLTFJson

@end
