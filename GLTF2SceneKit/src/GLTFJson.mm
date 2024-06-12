#import "GLTFJson.h"

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

NSString *const VRMCMetaAvatarPermissionOnlyAuthor = @"onlyAuthor";
NSString *const VRMCMetaAvatarPermissionOnlySeparatelyLicensedPerson =
    @"onlySeparatelyLicensedPerson";
NSString *const VRMCMetaAvatarPermissionEveryone = @"everyone";

NSString *const VRMCMetaCommercialUsagePersonalNonProfit = @"personalNonProfit";
NSString *const VRMCMetaCommercialUsagePersonalProfit = @"personalProfit";
NSString *const VRMCMetaCommercialUsageCorporation = @"corporation";

NSString *const VRMCMetaCreditNotationRequired = @"required";
NSString *const VRMCMetaCreditNotationUnnecessary = @"unnecessary";

NSString *const VRMCMetaModificationProhibited = @"prohibited";
NSString *const VRMCMetaModificationAllowModification = @"allowModification";
NSString *const VRMCMetaModificationAllowModificationRedistribution =
    @"allowModificationRedistribution";

@implementation VRMCMeta

@end

@implementation VRMCHumanBone

@end

@implementation VRMCHumanBones

@end

@implementation VRMCHumanoid

@end

NSString *const VRMCFirstPersonMeshAnnotationTypeAuto = @"auto";
NSString *const VRMCFirstPersonMeshAnnotationTypeBoth = @"both";
NSString *const VRMCFirstPersonMeshAnnotationTypeThirdPersonOnly =
    @"thirdPersonOnly";
NSString *const VRMCFirstPersonMeshAnnotationTypeFirstPersonOnly =
    @"firstPersonOnly";

@implementation VRMCFirstPersonMeshAnnotation

@end

@implementation VRMCFirstPerson

@end

@implementation VRMCLookAtRangeMap

@end

NSString *const VRMCLookAtTypeBone = @"bone";
NSString *const VRMCLookAtTypeExpression = @"expression";

@implementation VRMCLookAt

@end

NSString *const VRMCExpressionMaterialColorBindTypeColor = @"color";
NSString *const VRMCExpressionMaterialColorBindTypeEmissionColor =
    @"emissionColor";
NSString *const VRMCExpressionMaterialColorBindTypeShadeColor = @"shadeColor";
NSString *const VRMCExpressionMaterialColorBindTypeMatcapColor = @"matcapColor";
NSString *const VRMCExpressionMaterialColorBindTypeRimColor = @"rimColor";
NSString *const VRMCExpressionMaterialColorBindTypeOutlineColor =
    @"outlineColor";

@implementation VRMCExpressionMaterialColorBind

@end

@implementation VRMCExpressionMorphTargetBind

@end

@implementation VRMCExpressionTextureTransformBind

@end

NSString *const VRMCExpressionOverrideNone = @"none";
NSString *const VRMCExpressionOverrideBlock = @"block";
NSString *const VRMCExpressionOverrideBlend = @"blend";

@implementation VRMCExpression

@end

@implementation VRMCExpressionsPreset

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

@implementation VRMCExpressions

- (nullable VRMCExpression *)expressionByName:(NSString *)name {
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

@implementation VRMCVrm

- (nullable VRMCExpression *)expressionByName:(NSString *)name {
  if (!self.expressions)
    return nil;
  return [self.expressions expressionByName:name];
}

@end

@implementation VRMVec3

@end

NSString *const VRMHumanoidBoneTypeHips = @"hips";
NSString *const VRMHumanoidBoneTypeLeftUpperLeg = @"leftUpperLeg";
NSString *const VRMHumanoidBoneTypeRightUpperLeg = @"rightUpperLeg";
NSString *const VRMHumanoidBoneTypeLeftLowerLeg = @"leftLowerLeg";
NSString *const VRMHumanoidBoneTypeRightLowerLeg = @"rightLowerLeg";
NSString *const VRMHumanoidBoneTypeLeftFoot = @"leftFoot";
NSString *const VRMHumanoidBoneTypeRightFoot = @"rightFoot";
NSString *const VRMHumanoidBoneTypeSpine = @"spine";
NSString *const VRMHumanoidBoneTypeChest = @"chest";
NSString *const VRMHumanoidBoneTypeNeck = @"neck";
NSString *const VRMHumanoidBoneTypeHead = @"head";
NSString *const VRMHumanoidBoneTypeLeftShoulder = @"leftShoulder";
NSString *const VRMHumanoidBoneTypeRightShoulder = @"rightShoulder";
NSString *const VRMHumanoidBoneTypeLeftUpperArm = @"leftUpperArm";
NSString *const VRMHumanoidBoneTypeRightUpperArm = @"rightUpperArm";
NSString *const VRMHumanoidBoneTypeLeftLowerArm = @"leftLowerArm";
NSString *const VRMHumanoidBoneTypeRightLowerArm = @"rightLowerArm";
NSString *const VRMHumanoidBoneTypeLeftHand = @"leftHand";
NSString *const VRMHumanoidBoneTypeRightHand = @"rightHand";
NSString *const VRMHumanoidBoneTypeLeftToes = @"leftToes";
NSString *const VRMHumanoidBoneTypeRightToes = @"rightToes";
NSString *const VRMHumanoidBoneTypeLeftEye = @"leftEye";
NSString *const VRMHumanoidBoneTypeRightEye = @"rightEye";
NSString *const VRMHumanoidBoneTypeJaw = @"jaw";
NSString *const VRMHumanoidBoneTypeLeftThumbProximal = @"leftThumbProximal";
NSString *const VRMHumanoidBoneTypeLeftThumbIntermediate =
    @"leftThumbIntermediate";
NSString *const VRMHumanoidBoneTypeLeftThumbDistal = @"leftThumbDistal";
NSString *const VRMHumanoidBoneTypeLeftIndexProximal = @"leftIndexProximal";
NSString *const VRMHumanoidBoneTypeLeftIndexIntermediate =
    @"leftIndexIntermediate";
NSString *const VRMHumanoidBoneTypeLeftIndexDistal = @"leftIndexDistal";
NSString *const VRMHumanoidBoneTypeLeftMiddleProximal = @"leftMiddleProximal";
NSString *const VRMHumanoidBoneTypeLeftMiddleIntermediate =
    @"leftMiddleIntermediate";
NSString *const VRMHumanoidBoneTypeLeftMiddleDistal = @"leftMiddleDistal";
NSString *const VRMHumanoidBoneTypeLeftRingProximal = @"leftRingProximal";
NSString *const VRMHumanoidBoneTypeLeftRingIntermediate =
    @"leftRingIntermediate";
NSString *const VRMHumanoidBoneTypeLeftRingDistal = @"leftRingDistal";
NSString *const VRMHumanoidBoneTypeLeftLittleProximal = @"leftLittleProximal";
NSString *const VRMHumanoidBoneTypeLeftLittleIntermediate =
    @"leftLittleIntermediate";
NSString *const VRMHumanoidBoneTypeLeftLittleDistal = @"leftLittleDistal";
NSString *const VRMHumanoidBoneTypeRightThumbProximal = @"rightThumbProximal";
NSString *const VRMHumanoidBoneTypeRightThumbIntermediate =
    @"rightThumbIntermediate";
NSString *const VRMHumanoidBoneTypeRightThumbDistal = @"rightThumbDistal";
NSString *const VRMHumanoidBoneTypeRightIndexProximal = @"rightIndexProximal";
NSString *const VRMHumanoidBoneTypeRightIndexIntermediate =
    @"rightIndexIntermediate";
NSString *const VRMHumanoidBoneTypeRightIndexDistal = @"rightIndexDistal";
NSString *const VRMHumanoidBoneTypeRightMiddleProximal = @"rightMiddleProximal";
NSString *const VRMHumanoidBoneTypeRightMiddleIntermediate =
    @"rightMiddleIntermediate";
NSString *const VRMHumanoidBoneTypeRightMiddleDistal = @"rightMiddleDistal";
NSString *const VRMHumanoidBoneTypeRightRingProximal = @"rightRingProximal";
NSString *const VRMHumanoidBoneTypeRightRingIntermediate =
    @"rightRingIntermediate";
NSString *const VRMHumanoidBoneTypeRightRingDistal = @"rightRingDistal";
NSString *const VRMHumanoidBoneTypeRightLittleProximal = @"rightLittleProximal";
NSString *const VRMHumanoidBoneTypeRightLittleIntermediate =
    @"rightLittleIntermediate";
NSString *const VRMHumanoidBoneTypeRightLittleDistal = @"rightLittleDistal";
NSString *const VRMHumanoidBoneTypeUpperChest = @"upperChest";

@implementation VRMHumanoidBone

@end

@implementation VRMHumanoid

@end

NSString *const VRMMetaAllowedUserNameOnlyAuthor = @"OnlyAuthor";
NSString *const VRMMetaAllowedUserNameExplicitlyLicensedPerson =
    @"ExplicitlyLicensedPerson";
NSString *const VRMMetaAllowedUserNameEveryone = @"Everyone";

NSString *const VRMMetaUsagePermissionDisallow = @"Disallow";
NSString *const VRMMetaUsagePermissionAllow = @"Allow";

NSString *const VRMMetaLicenseNameRedistributionProhibited =
    @"Redistribution_Prohibited";
NSString *const VRMMetaLicenseNameCC0 = @"CC0";
NSString *const VRMMetaLicenseNameCCBY = @"CC_BY";
NSString *const VRMMetaLicenseNameCCBYNC = @"CC_BY_NC";
NSString *const VRMMetaLicenseNameCCBYSA = @"CC_BY_SA";
NSString *const VRMMetaLicenseNameCCBYNCSA = @"CC_BY_NC_SA";
NSString *const VRMMetaLicenseNameCCBYND = @"CC_BY_ND";
NSString *const VRMMetaLicenseNameCCBYNCND = @"CC_BY_NC_ND";
NSString *const VRMMetaLicenseNameOther = @"Other";

@implementation VRMMeta

@end

@implementation VRMMeshAnnotation

@end

@implementation VRMDegreeMap

@end

@implementation VRMFirstPerson

@end

@implementation VRMBlendShapeBind

@end

@implementation VRMBlendShapeMaterialBind

@end

NSString *const VRMBlendShapeGroupPresetNameUnknown = @"unknown";
NSString *const VRMBlendShapeGroupPresetNameNeutral = @"neutral";
NSString *const VRMBlendShapeGroupPresetNameA = @"a";
NSString *const VRMBlendShapeGroupPresetNameI = @"i";
NSString *const VRMBlendShapeGroupPresetNameU = @"u";
NSString *const VRMBlendShapeGroupPresetNameE = @"e";
NSString *const VRMBlendShapeGroupPresetNameO = @"o";
NSString *const VRMBlendShapeGroupPresetNameBlink = @"blink";
NSString *const VRMBlendShapeGroupPresetNameJoy = @"joy";
NSString *const VRMBlendShapeGroupPresetNameAngry = @"angry";
NSString *const VRMBlendShapeGroupPresetNameSorrow = @"sorrow";
NSString *const VRMBlendShapeGroupPresetNameFun = @"fun";
NSString *const VRMBlendShapeGroupPresetNameLookUp = @"lookup";
NSString *const VRMBlendShapeGroupPresetNameLookDown = @"lookdown";
NSString *const VRMBlendShapeGroupPresetNameLookLeft = @"lookleft";
NSString *const VRMBlendShapeGroupPresetNameLookRight = @"lookright";
NSString *const VRMBlendShapeGroupPresetNameBlinkL = @"blink_l";
NSString *const VRMBlendShapeGroupPresetNameBlinkR = @"blink_r";

@implementation VRMBlendShapeGroup

- (nullable NSString *)groupName {
  return self.presetName ?: self.name;
}

@end

@implementation VRMBlendShape

- (nullable VRMBlendShapeGroup *)blendShapeGroupByPreset:
    (NSString *)presetName {
  if (!self.blendShapeGroups)
    return nil;
  for (VRMBlendShapeGroup *group in self.blendShapeGroups) {
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
    for (VRMBlendShapeGroup *group in self.blendShapeGroups) {
      [names addObject:group.groupName];
    }
  }
  return [names copy];
}

@end

@implementation VRMSecondaryAnimationCollider

@end

@implementation VRMSecondaryAnimationColliderGroup

@end

@implementation VRMSecondaryAnimationSpring

@end

@implementation VRMSecondaryAnimation

@end

@implementation VRMMaterial

@end

@implementation VRMVrm

- (nullable VRMBlendShapeGroup *)blendShapeGroupByPreset:
    (NSString *)presetName {
  if (!self.blendShapeMaster)
    return nil;
  return [self.blendShapeMaster blendShapeGroupByPreset:presetName];
}

@end

@implementation GLTFJson

@end
