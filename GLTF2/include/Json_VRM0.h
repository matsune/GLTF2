#ifndef Json_VRM0_h
#define Json_VRM0_h

#include <map>
#include <optional>
#include <string>
#include <vector>

namespace gltf2 {
namespace json {
namespace vrm0 {

class Vec3 {
public:
  std::optional<float> x;
  std::optional<float> y;
  std::optional<float> z;

  static Vec3 zero() {
    Vec3 v;
    v.x = 0;
    v.y = 0;
    v.z = 0;
    return v;
  }
};

// Meta

class Meta {
public:
  enum class AllowedUserName {
    ONLY_AUTHOR,
    EXPLICITLY_LICENSED_PERSON,
    EVERYONE
  };

  enum class UsagePermission { DISALLOW, ALLOW };

  enum class LicenseName {
    REDISTRIBUTION_PROHIBITED,
    CC0,
    CC_BY,
    CC_BY_NC,
    CC_BY_SA,
    CC_BY_NC_SA,
    CC_BY_ND,
    CC_BY_NC_ND,
    OTHER
  };

  static std::optional<AllowedUserName>
  AllowedUserNameFromString(const std::string &value) {
    if (value == "OnlyAuthor")
      return AllowedUserName::ONLY_AUTHOR;
    if (value == "ExplicitlyLicensedPerson")
      return AllowedUserName::EXPLICITLY_LICENSED_PERSON;
    if (value == "Everyone")
      return AllowedUserName::EVERYONE;
    return std::nullopt;
  }

  static std::optional<UsagePermission>
  UsagePermissionFromString(const std::string &value) {
    if (value == "Disallow")
      return UsagePermission::DISALLOW;
    if (value == "Allow")
      return UsagePermission::ALLOW;
    return std::nullopt;
  }

  static std::optional<LicenseName>
  LicenseNameFromString(const std::string &value) {
    if (value == "Redistribution_Prohibited")
      return LicenseName::REDISTRIBUTION_PROHIBITED;
    if (value == "CC0")
      return LicenseName::CC0;
    if (value == "CC_BY")
      return LicenseName::CC_BY;
    if (value == "CC_BY_NC")
      return LicenseName::CC_BY_NC;
    if (value == "CC_BY_SA")
      return LicenseName::CC_BY_SA;
    if (value == "CC_BY_NC_SA")
      return LicenseName::CC_BY_NC_SA;
    if (value == "CC_BY_ND")
      return LicenseName::CC_BY_ND;
    if (value == "CC_BY_NC_ND")
      return LicenseName::CC_BY_NC_ND;
    if (value == "Other")
      return LicenseName::OTHER;
    return std::nullopt;
  }

  std::optional<std::string> title;
  std::optional<std::string> version;
  std::optional<std::string> author;
  std::optional<std::string> contactInformation;
  std::optional<std::string> reference;
  std::optional<uint32_t> texture;
  std::optional<AllowedUserName> allowedUserName;
  std::optional<UsagePermission> violentUsage;
  std::optional<UsagePermission> sexualUsage;
  std::optional<UsagePermission> commercialUsage;
  std::optional<std::string> otherPermissionUrl;
  std::optional<LicenseName> licenseName;
  std::optional<std::string> otherLicenseUrl;

  AllowedUserName allowedUserNameValue() const {
    return allowedUserName.value_or(AllowedUserName::ONLY_AUTHOR);
  }

  UsagePermission violentUsageValue() const {
    return violentUsage.value_or(UsagePermission::DISALLOW);
  }

  UsagePermission sexualUsageValue() const {
    return sexualUsage.value_or(UsagePermission::DISALLOW);
  }

  UsagePermission commercialUsageValue() const {
    return commercialUsage.value_or(UsagePermission::DISALLOW);
  }

  LicenseName licenseNameValue() const {
    return licenseName.value_or(LicenseName::REDISTRIBUTION_PROHIBITED);
  }
};

// Humanoid

class HumanoidBone {
public:
  enum class BoneName {
    HIPS,
    LEFT_UPPER_LEG,
    RIGHT_UPPER_LEG,
    LEFT_LOWER_LEG,
    RIGHT_LOWER_LEG,
    LEFT_FOOT,
    RIGHT_FOOT,
    SPINE,
    CHEST,
    NECK,
    HEAD,
    LEFT_SHOULDER,
    RIGHT_SHOULDER,
    LEFT_UPPER_ARM,
    RIGHT_UPPER_ARM,
    LEFT_LOWER_ARM,
    RIGHT_LOWER_ARM,
    LEFT_HAND,
    RIGHT_HAND,
    LEFT_TOES,
    RIGHT_TOES,
    LEFT_EYE,
    RIGHT_EYE,
    JAW,
    LEFT_THUMB_PROXIMAL,
    LEFT_THUMB_INTERMEDIATE,
    LEFT_THUMB_DISTAL,
    LEFT_INDEX_PROXIMAL,
    LEFT_INDEX_INTERMEDIATE,
    LEFT_INDEX_DISTAL,
    LEFT_MIDDLE_PROXIMAL,
    LEFT_MIDDLE_INTERMEDIATE,
    LEFT_MIDDLE_DISTAL,
    LEFT_RING_PROXIMAL,
    LEFT_RING_INTERMEDIATE,
    LEFT_RING_DISTAL,
    LEFT_LITTLE_PROXIMAL,
    LEFT_LITTLE_INTERMEDIATE,
    LEFT_LITTLE_DISTAL,
    RIGHT_THUMB_PROXIMAL,
    RIGHT_THUMB_INTERMEDIATE,
    RIGHT_THUMB_DISTAL,
    RIGHT_INDEX_PROXIMAL,
    RIGHT_INDEX_INTERMEDIATE,
    RIGHT_INDEX_DISTAL,
    RIGHT_MIDDLE_PROXIMAL,
    RIGHT_MIDDLE_INTERMEDIATE,
    RIGHT_MIDDLE_DISTAL,
    RIGHT_RING_PROXIMAL,
    RIGHT_RING_INTERMEDIATE,
    RIGHT_RING_DISTAL,
    RIGHT_LITTLE_PROXIMAL,
    RIGHT_LITTLE_INTERMEDIATE,
    RIGHT_LITTLE_DISTAL,
    UPPER_CHEST
  };

  static std::optional<BoneName> BoneNameFromString(const std::string &value) {
    if (value == "hips")
      return BoneName::HIPS;
    if (value == "leftUpperLeg")
      return BoneName::LEFT_UPPER_LEG;
    if (value == "rightUpperLeg")
      return BoneName::RIGHT_UPPER_LEG;
    if (value == "leftLowerLeg")
      return BoneName::LEFT_LOWER_LEG;
    if (value == "rightLowerLeg")
      return BoneName::RIGHT_LOWER_LEG;
    if (value == "leftFoot")
      return BoneName::LEFT_FOOT;
    if (value == "rightFoot")
      return BoneName::RIGHT_FOOT;
    if (value == "spine")
      return BoneName::SPINE;
    if (value == "chest")
      return BoneName::CHEST;
    if (value == "neck")
      return BoneName::NECK;
    if (value == "head")
      return BoneName::HEAD;
    if (value == "leftShoulder")
      return BoneName::LEFT_SHOULDER;
    if (value == "rightShoulder")
      return BoneName::RIGHT_SHOULDER;
    if (value == "leftUpperArm")
      return BoneName::LEFT_UPPER_ARM;
    if (value == "rightUpperArm")
      return BoneName::RIGHT_UPPER_ARM;
    if (value == "leftLowerArm")
      return BoneName::LEFT_LOWER_ARM;
    if (value == "rightLowerArm")
      return BoneName::RIGHT_LOWER_ARM;
    if (value == "leftHand")
      return BoneName::LEFT_HAND;
    if (value == "rightHand")
      return BoneName::RIGHT_HAND;
    if (value == "leftToes")
      return BoneName::LEFT_TOES;
    if (value == "rightToes")
      return BoneName::RIGHT_TOES;
    if (value == "leftEye")
      return BoneName::LEFT_EYE;
    if (value == "rightEye")
      return BoneName::RIGHT_EYE;
    if (value == "jaw")
      return BoneName::JAW;
    if (value == "leftThumbProximal")
      return BoneName::LEFT_THUMB_PROXIMAL;
    if (value == "leftThumbIntermediate")
      return BoneName::LEFT_THUMB_INTERMEDIATE;
    if (value == "leftThumbDistal")
      return BoneName::LEFT_THUMB_DISTAL;
    if (value == "leftIndexProximal")
      return BoneName::LEFT_INDEX_PROXIMAL;
    if (value == "leftIndexIntermediate")
      return BoneName::LEFT_INDEX_INTERMEDIATE;
    if (value == "leftIndexDistal")
      return BoneName::LEFT_INDEX_DISTAL;
    if (value == "leftMiddleProximal")
      return BoneName::LEFT_MIDDLE_PROXIMAL;
    if (value == "leftMiddleIntermediate")
      return BoneName::LEFT_MIDDLE_INTERMEDIATE;
    if (value == "leftMiddleDistal")
      return BoneName::LEFT_MIDDLE_DISTAL;
    if (value == "leftRingProximal")
      return BoneName::LEFT_RING_PROXIMAL;
    if (value == "leftRingIntermediate")
      return BoneName::LEFT_RING_INTERMEDIATE;
    if (value == "leftRingDistal")
      return BoneName::LEFT_RING_DISTAL;
    if (value == "leftLittleProximal")
      return BoneName::LEFT_LITTLE_PROXIMAL;
    if (value == "leftLittleIntermediate")
      return BoneName::LEFT_LITTLE_INTERMEDIATE;
    if (value == "leftLittleDistal")
      return BoneName::LEFT_LITTLE_DISTAL;
    if (value == "rightThumbProximal")
      return BoneName::RIGHT_THUMB_PROXIMAL;
    if (value == "rightThumbIntermediate")
      return BoneName::RIGHT_THUMB_INTERMEDIATE;
    if (value == "rightThumbDistal")
      return BoneName::RIGHT_THUMB_DISTAL;
    if (value == "rightIndexProximal")
      return BoneName::RIGHT_INDEX_PROXIMAL;
    if (value == "rightIndexIntermediate")
      return BoneName::RIGHT_INDEX_INTERMEDIATE;
    if (value == "rightIndexDistal")
      return BoneName::RIGHT_INDEX_DISTAL;
    if (value == "rightMiddleProximal")
      return BoneName::RIGHT_MIDDLE_PROXIMAL;
    if (value == "rightMiddleIntermediate")
      return BoneName::RIGHT_MIDDLE_INTERMEDIATE;
    if (value == "rightMiddleDistal")
      return BoneName::RIGHT_MIDDLE_DISTAL;
    if (value == "rightRingProximal")
      return BoneName::RIGHT_RING_PROXIMAL;
    if (value == "rightRingIntermediate")
      return BoneName::RIGHT_RING_INTERMEDIATE;
    if (value == "rightRingDistal")
      return BoneName::RIGHT_RING_DISTAL;
    if (value == "rightLittleProximal")
      return BoneName::RIGHT_LITTLE_PROXIMAL;
    if (value == "rightLittleIntermediate")
      return BoneName::RIGHT_LITTLE_INTERMEDIATE;
    if (value == "rightLittleDistal")
      return BoneName::RIGHT_LITTLE_DISTAL;
    if (value == "upperChest")
      return BoneName::UPPER_CHEST;
    return std::nullopt;
  }

  std::optional<BoneName> bone;
  std::optional<uint32_t> node;
  std::optional<bool> useDefaultValues;
  std::optional<Vec3> min;
  std::optional<Vec3> max;
  std::optional<Vec3> center;
  std::optional<float> axisLength;
};

class Humanoid {
public:
  std::optional<std::vector<HumanoidBone>> humanBones;
  std::optional<float> armStretch;
  std::optional<float> legStretch;
  std::optional<float> upperArmTwist;
  std::optional<float> lowerArmTwist;
  std::optional<float> upperLegTwist;
  std::optional<float> lowerLegTwist;
  std::optional<float> feetSpacing;
  std::optional<bool> hasTranslationDoF;
};

// FirstPerson

class FirstPersonMeshAnnotation {
public:
  std::optional<uint32_t> mesh;
  std::optional<std::string> firstPersonFlag;
};

class FirstPersonDegreeMapCurve {
public:
  float time;
  float value;
  float inTangent;
  float outTangent;
};

class FirstPersonDegreeMap {
public:
  std::optional<std::vector<FirstPersonDegreeMapCurve>> curve;
  std::optional<float> xRange;
  std::optional<float> yRange;
};

class FirstPerson {
public:
  enum class LookAtType { BONE, BLEND_SHAPE };

  static std::optional<LookAtType>
  LookAtTypeFromString(const std::string &value) {
    if (value == "Bone")
      return LookAtType::BONE;
    else if (value == "BlendShape")
      return LookAtType::BLEND_SHAPE;
    else
      return std::nullopt;
  }

  std::optional<uint32_t> firstPersonBone;
  std::optional<Vec3> firstPersonBoneOffset;
  std::optional<std::vector<FirstPersonMeshAnnotation>> meshAnnotations;
  std::optional<LookAtType> lookAtTypeName;
  std::optional<FirstPersonDegreeMap> lookAtHorizontalInner;
  std::optional<FirstPersonDegreeMap> lookAtHorizontalOuter;
  std::optional<FirstPersonDegreeMap> lookAtVerticalDown;
  std::optional<FirstPersonDegreeMap> lookAtVerticalUp;
};

// BlendShape

class BlendShapeBind {
public:
  std::optional<uint32_t> mesh;
  std::optional<uint32_t> index;
  std::optional<float> weight;
};

class BlendShapeMaterialBind {
public:
  std::optional<std::string> materialName;
  std::optional<std::string> propertyName;
  std::optional<std::vector<float>> targetValue;
};

class BlendShapeGroup {
public:
  enum class PresetName {
    UNKNOWN,
    NEUTRAL,
    A,
    I,
    U,
    E,
    O,
    BLINK,
    JOY,
    ANGRY,
    SORROW,
    FUN,
    LOOKUP,
    LOOKDOWN,
    LOOKLEFT,
    LOOKRIGHT,
    BLINK_L,
    BLINK_R
  };

  static std::optional<PresetName>
  PresetNameFromString(const std::string &value) {
    if (value == "unknown")
      return PresetName::UNKNOWN;
    if (value == "neutral")
      return PresetName::NEUTRAL;
    if (value == "a")
      return PresetName::A;
    if (value == "i")
      return PresetName::I;
    if (value == "u")
      return PresetName::U;
    if (value == "e")
      return PresetName::E;
    if (value == "o")
      return PresetName::O;
    if (value == "blink")
      return PresetName::BLINK;
    if (value == "joy")
      return PresetName::JOY;
    if (value == "angry")
      return PresetName::ANGRY;
    if (value == "sorrow")
      return PresetName::SORROW;
    if (value == "fun")
      return PresetName::FUN;
    if (value == "lookup")
      return PresetName::LOOKUP;
    if (value == "lookdown")
      return PresetName::LOOKDOWN;
    if (value == "lookleft")
      return PresetName::LOOKLEFT;
    if (value == "lookright")
      return PresetName::LOOKRIGHT;
    if (value == "blink_l")
      return PresetName::BLINK_L;
    if (value == "blink_r")
      return PresetName::BLINK_R;
    return std::nullopt;
  }

  static std::string PresetNameToString(PresetName presetName) {
    switch (presetName) {
    case PresetName::UNKNOWN:
      return "unknown";
    case PresetName::NEUTRAL:
      return "neutral";
    case PresetName::A:
      return "a";
    case PresetName::I:
      return "i";
    case PresetName::U:
      return "u";
    case PresetName::E:
      return "e";
    case PresetName::O:
      return "o";
    case PresetName::BLINK:
      return "blink";
    case PresetName::JOY:
      return "joy";
    case PresetName::ANGRY:
      return "angry";
    case PresetName::SORROW:
      return "sorrow";
    case PresetName::FUN:
      return "fun";
    case PresetName::LOOKUP:
      return "lookup";
    case PresetName::LOOKDOWN:
      return "lookdown";
    case PresetName::LOOKLEFT:
      return "lookleft";
    case PresetName::LOOKRIGHT:
      return "lookright";
    case PresetName::BLINK_L:
      return "blink_l";
    case PresetName::BLINK_R:
      return "blink_r";
    default:
      return "";
    }
  }

  std::optional<std::string> name;
  std::optional<PresetName> presetName;
  std::optional<std::vector<BlendShapeBind>> binds;
  std::optional<std::vector<BlendShapeMaterialBind>> materialValues;
  std::optional<bool> isBinary;

  std::string groupName() const {
    if (presetName.has_value()) {
      return PresetNameToString(*presetName);
    } else {
      return name.value_or("");
    }
  }

  bool isBinaryValue() const { return isBinary.value_or(false); }
};

class BlendShape {
public:
  std::optional<std::vector<BlendShapeGroup>> blendShapeGroups;

  const BlendShapeGroup *blendShapeGroupByPreset(std::string presetName) const {
    if (!blendShapeGroups.has_value())
      return nullptr;
    std::transform(presetName.begin(), presetName.end(), presetName.begin(),
                   ::tolower);
    for (const auto &group : *blendShapeGroups) {
      std::string groupName = group.groupName();
      std::transform(groupName.begin(), groupName.end(), groupName.begin(),
                     ::tolower);
      if (groupName == presetName) {
        return &group;
      }
    }
    return nullptr;
  }
};

// SecondaryAnimation

class SecondaryAnimationCollider {
public:
  std::optional<Vec3> offset;
  std::optional<float> radius;

  Vec3 offsetValue() const { return offset.value_or(Vec3::zero()); }

  float radiusValue() const { return radius.value_or(0); }
};

class SecondaryAnimationColliderGroup {
public:
  std::optional<uint32_t> node;
  std::optional<std::vector<SecondaryAnimationCollider>> colliders;
};

class SecondaryAnimationSpring {
public:
  std::optional<std::string> comment;
  std::optional<float> stiffiness;
  std::optional<float> gravityPower;
  std::optional<Vec3> gravityDir;
  std::optional<float> dragForce;
  std::optional<int> center;
  std::optional<float> hitRadius;
  std::optional<std::vector<uint32_t>> bones;
  std::optional<std::vector<uint32_t>> colliderGroups;
};

class SecondaryAnimation {
public:
  std::optional<std::vector<SecondaryAnimationSpring>> boneGroups;
  std::optional<std::vector<SecondaryAnimationColliderGroup>> colliderGroups;
};

// Material

class Material {
public:
  std::optional<std::string> name;
  std::optional<std::string> shader;
  std::optional<uint32_t> renderQueue;
  std::optional<std::map<std::string, float>> floatProperties;
  std::optional<std::map<std::string, std::vector<float>>> vectorProperties;
  std::optional<std::map<std::string, uint32_t>> textureProperties;
  std::optional<std::map<std::string, bool>> keywordMap;
  std::optional<std::map<std::string, std::string>> tagMap;
};

// VRM

class VRM {
public:
  std::optional<std::string> exporterVersion;
  std::optional<std::string> specVersion;
  std::optional<Meta> meta;
  std::optional<Humanoid> humanoid;
  std::optional<FirstPerson> firstPerson;
  std::optional<BlendShape> blendShapeMaster;
  std::optional<SecondaryAnimation> secondaryAnimation;
  std::optional<std::vector<Material>> materialProperties;

  const BlendShapeGroup *
  blendShapeGroupByPreset(const std::string &preset) const {
    if (!blendShapeMaster.has_value())
      return nullptr;
    return blendShapeMaster->blendShapeGroupByPreset(preset);
  }
};

} // namespace vrm0
} // namespace json
}; // namespace gltf2

#endif /* Json_VRM0_h */
