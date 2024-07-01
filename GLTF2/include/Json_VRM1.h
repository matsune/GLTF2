#ifndef Json__h
#define Json__h

#include <optional>
#include <string>
#include <vector>

namespace gltf2 {
namespace json {
namespace vrmc {

// Meta

class Meta {
public:
  enum class AvatarPermission {
    ONLY_AUTHOR,
    ONLY_SEPARATELY_LICENSED_PERSON,
    EVERYONE
  };

  enum class CommercialUsage {
    PERSONAL_NON_PROFIT,
    PERSONAL_PROFIT,
    CORPORATION
  };

  enum class CreditNotation { REQUIRED, UNNECESSARY };

  enum class Modification {
    PROHIBITED,
    ALLOW_MODIFICATION,
    ALLOW_MODIFICATION_REDISTRIBUTION
  };

  static std::optional<AvatarPermission>
  AvatarPermissionFromString(const std::string &value) {
    if (value == "onlyAuthor")
      return AvatarPermission::ONLY_AUTHOR;
    if (value == "onlySeparatelyLicensedPerson")
      return AvatarPermission::ONLY_SEPARATELY_LICENSED_PERSON;
    if (value == "everyone")
      return AvatarPermission::EVERYONE;
    return std::nullopt;
  }

  static std::optional<CommercialUsage>
  CommercialUsageFromString(const std::string &value) {
    if (value == "personalNonProfit")
      return CommercialUsage::PERSONAL_NON_PROFIT;
    if (value == "personalProfit")
      return CommercialUsage::PERSONAL_PROFIT;
    if (value == "corporation")
      return CommercialUsage::CORPORATION;
    return std::nullopt;
  }

  static std::optional<CreditNotation>
  CreditNotationFromString(const std::string &value) {
    if (value == "required")
      return CreditNotation::REQUIRED;
    if (value == "unnecessary")
      return CreditNotation::UNNECESSARY;
    return std::nullopt;
  }

  static std::optional<Modification>
  ModificationFromString(const std::string &value) {
    if (value == "prohibited")
      return Modification::PROHIBITED;
    if (value == "allowModification")
      return Modification::ALLOW_MODIFICATION;
    if (value == "allowModificationRedistribution")
      return Modification::ALLOW_MODIFICATION_REDISTRIBUTION;
    return std::nullopt;
  }

  std::string name;
  std::optional<std::string> version;
  std::vector<std::string> authors;
  std::optional<std::string> copyrightInformation;
  std::optional<std::string> contactInformation;
  std::optional<std::vector<std::string>> references;
  std::optional<std::string> thirdPartyLicenses;
  std::optional<uint32_t> thumbnailImage;
  std::string licenseUrl;
  std::optional<AvatarPermission> avatarPermission;
  std::optional<bool> allowExcessivelyViolentUsage;
  std::optional<bool> allowExcessivelySexualUsage;
  std::optional<CommercialUsage> commercialUsage;
  std::optional<bool> allowPoliticalOrReligiousUsage;
  std::optional<bool> allowAntisocialOrHateUsage;
  std::optional<CreditNotation> creditNotation;
  std::optional<bool> allowRedistribution;
  std::optional<Modification> modification;
  std::optional<std::string> otherLicenseUrl;

  AvatarPermission avatarPermissionValue() const {
    return avatarPermission.value_or(AvatarPermission::ONLY_AUTHOR);
  }

  bool allowExcessivelyViolentUsageValue() const {
    return allowExcessivelyViolentUsage.value_or(false);
  }

  bool allowExcessivelySexualUsageValue() const {
    return allowExcessivelySexualUsage.value_or(false);
  }

  CommercialUsage commercialUsageValue() const {
    return commercialUsage.value_or(CommercialUsage::PERSONAL_NON_PROFIT);
  }

  bool allowPoliticalOrReligiousUsageValue() const {
    return allowPoliticalOrReligiousUsage.value_or(false);
  }

  bool allowAntisocialOrHateUsageValue() const {
    return allowAntisocialOrHateUsage.value_or(false);
  }

  CreditNotation creditNotationValue() const {
    return creditNotation.value_or(CreditNotation::REQUIRED);
  }

  Modification modificationValue() const {
    return modification.value_or(Modification::PROHIBITED);
  }
};

// Humanoid

class HumanoidHumanBone {
public:
  uint32_t node;
};

class HumanoidHumanBones {
public:
  HumanoidHumanBone hips;
  HumanoidHumanBone spine;
  std::optional<HumanoidHumanBone> chest;
  std::optional<HumanoidHumanBone> upperChest;
  std::optional<HumanoidHumanBone> neck;
  HumanoidHumanBone head;
  std::optional<HumanoidHumanBone> leftEye;
  std::optional<HumanoidHumanBone> rightEye;
  std::optional<HumanoidHumanBone> jaw;
  HumanoidHumanBone leftUpperLeg;
  HumanoidHumanBone leftLowerLeg;
  HumanoidHumanBone leftFoot;
  std::optional<HumanoidHumanBone> leftToes;
  HumanoidHumanBone rightUpperLeg;
  HumanoidHumanBone rightLowerLeg;
  HumanoidHumanBone rightFoot;
  std::optional<HumanoidHumanBone> rightToes;
  std::optional<HumanoidHumanBone> leftShoulder;
  HumanoidHumanBone leftUpperArm;
  HumanoidHumanBone leftLowerArm;
  HumanoidHumanBone leftHand;
  std::optional<HumanoidHumanBone> rightShoulder;
  HumanoidHumanBone rightUpperArm;
  HumanoidHumanBone rightLowerArm;
  HumanoidHumanBone rightHand;
  std::optional<HumanoidHumanBone> leftThumbMetacarpal;
  std::optional<HumanoidHumanBone> leftThumbProximal;
  std::optional<HumanoidHumanBone> leftThumbDistal;
  std::optional<HumanoidHumanBone> leftIndexProximal;
  std::optional<HumanoidHumanBone> leftIndexIntermediate;
  std::optional<HumanoidHumanBone> leftIndexDistal;
  std::optional<HumanoidHumanBone> leftMiddleProximal;
  std::optional<HumanoidHumanBone> leftMiddleIntermediate;
  std::optional<HumanoidHumanBone> leftMiddleDistal;
  std::optional<HumanoidHumanBone> leftRingProximal;
  std::optional<HumanoidHumanBone> leftRingIntermediate;
  std::optional<HumanoidHumanBone> leftRingDistal;
  std::optional<HumanoidHumanBone> leftLittleProximal;
  std::optional<HumanoidHumanBone> leftLittleIntermediate;
  std::optional<HumanoidHumanBone> leftLittleDistal;
  std::optional<HumanoidHumanBone> rightThumbMetacarpal;
  std::optional<HumanoidHumanBone> rightThumbProximal;
  std::optional<HumanoidHumanBone> rightThumbDistal;
  std::optional<HumanoidHumanBone> rightIndexProximal;
  std::optional<HumanoidHumanBone> rightIndexIntermediate;
  std::optional<HumanoidHumanBone> rightIndexDistal;
  std::optional<HumanoidHumanBone> rightMiddleProximal;
  std::optional<HumanoidHumanBone> rightMiddleIntermediate;
  std::optional<HumanoidHumanBone> rightMiddleDistal;
  std::optional<HumanoidHumanBone> rightRingProximal;
  std::optional<HumanoidHumanBone> rightRingIntermediate;
  std::optional<HumanoidHumanBone> rightRingDistal;
  std::optional<HumanoidHumanBone> rightLittleProximal;
  std::optional<HumanoidHumanBone> rightLittleIntermediate;
  std::optional<HumanoidHumanBone> rightLittleDistal;
};

class Humanoid {
public:
  HumanoidHumanBones humanBones;
};

// FirstPerson

class FirstPersonMeshAnnotation {
public:
  enum class Type { AUTO, BOTH, THIRD_PERSON_ONLY, FIRST_PERSON_ONLY };

  static std::optional<Type> TypeFromString(const std::string &value) {
    if (value == "auto")
      return Type::AUTO;
    else if (value == "both")
      return Type::BOTH;
    else if (value == "thirdPersonOnly")
      return Type::THIRD_PERSON_ONLY;
    else if (value == "firstPersonOnly")
      return Type::FIRST_PERSON_ONLY;
    else
      return std::nullopt;
  }

  uint32_t node;
  Type type;
};

class FirstPerson {
public:
  std::optional<std::vector<FirstPersonMeshAnnotation>> meshAnnotations;
};

// LookAt

class LookAtRangeMap {
public:
  std::optional<float> inputMaxValue;
  std::optional<float> outputScale;
};

class LookAt {
public:
  enum class Type { BONE, EXPRESSION };

  static std::optional<Type> TypeFromString(const std::string &value) {
    if (value == "bone")
      return Type::BONE;
    else if (value == "expression")
      return Type::EXPRESSION;
    else
      return std::nullopt;
  }

  std::optional<std::array<float, 3>> offsetFromHeadBone;
  std::optional<Type> type;
  std::optional<LookAtRangeMap> rangeMapHorizontalInner;
  std::optional<LookAtRangeMap> rangeMapHorizontalOuter;
  std::optional<LookAtRangeMap> rangeMapVerticalDown;
  std::optional<LookAtRangeMap> rangeMapVerticalUp;
};

// Expression

class ExpressionMaterialColorBind {
public:
  enum class Type {
    COLOR,
    EMISSION_COLOR,
    SHADE_COLOR,
    MATCAP_COLOR,
    RIM_COLOR,
    OUTLINE_COLOR
  };

  static std::optional<Type> TypeFromString(const std::string &value) {
    if (value == "color")
      return Type::COLOR;
    else if (value == "emissionColor")
      return Type::EMISSION_COLOR;
    else if (value == "shadeColor")
      return Type::SHADE_COLOR;
    else if (value == "matcapColor")
      return Type::MATCAP_COLOR;
    else if (value == "rimColor")
      return Type::RIM_COLOR;
    else if (value == "outlineColor")
      return Type::OUTLINE_COLOR;
    else
      return std::nullopt;
  }

  uint32_t material;
  Type type;
  std::array<float, 4> targetValue;
};

class ExpressionMorphTargetBind {
public:
  uint32_t node;
  uint32_t index;
  float weight;
};

class ExpressionTextureTransformBind {
public:
  uint32_t material;
  std::optional<std::array<float, 2>> scale;
  std::optional<std::array<float, 2>> offset;

  std::array<float, 2> scaleValue() const {
    return scale.value_or(std::array<float, 2>{1.0f, 1.0f});
  }

  std::array<float, 2> offsetValue() const {
    return offset.value_or(std::array<float, 2>{0.0f, 0.0f});
  }
};

class Expression {
public:
  enum class Override { NONE, BLOCK, BLEND };

  static std::optional<Override> OverrideFromString(const std::string &value) {
    if (value == "none")
      return Override::NONE;
    else if (value == "block")
      return Override::BLOCK;
    else if (value == "blend")
      return Override::BLEND;
    else
      return std::nullopt;
  }

  std::optional<std::vector<ExpressionMorphTargetBind>> morphTargetBinds;
  std::optional<std::vector<ExpressionMaterialColorBind>> materialColorBinds;
  std::optional<std::vector<ExpressionTextureTransformBind>>
      textureTransformBinds;
  std::optional<bool> isBinary;
  std::optional<Override> overrideBlink;
  std::optional<Override> overrideLookAt;
  std::optional<Override> overrideMouth;

  bool isBinaryValue() const { return isBinary.value_or(false); }

  Override overrideBlinkValue() const {
    return overrideBlink.value_or(Override::NONE);
  }

  Override overrideLookAtValue() const {
    return overrideLookAt.value_or(Override::NONE);
  }

  Override overrideMouthValue() const {
    return overrideMouth.value_or(Override::NONE);
  }
};

class ExpressionsPreset {
public:
  std::optional<Expression> happy;
  std::optional<Expression> angry;
  std::optional<Expression> sad;
  std::optional<Expression> relaxed;
  std::optional<Expression> surprised;
  std::optional<Expression> aa;
  std::optional<Expression> ih;
  std::optional<Expression> ou;
  std::optional<Expression> ee;
  std::optional<Expression> oh;
  std::optional<Expression> blink;
  std::optional<Expression> blinkLeft;
  std::optional<Expression> blinkRight;
  std::optional<Expression> lookUp;
  std::optional<Expression> lookDown;
  std::optional<Expression> lookLeft;
  std::optional<Expression> lookRight;
  std::optional<Expression> neutral;

  std::vector<std::string> expressionNames() const {
    std::vector<std::string> names;
    if (happy.has_value()) {
      names.push_back("happy");
    }
    if (angry.has_value()) {
      names.push_back("angry");
    }
    if (sad.has_value()) {
      names.push_back("sad");
    }
    if (relaxed.has_value()) {
      names.push_back("relaxed");
    }
    if (surprised.has_value()) {
      names.push_back("surprised");
    }
    if (aa.has_value()) {
      names.push_back("aa");
    }
    if (ih.has_value()) {
      names.push_back("ih");
    }
    if (ou.has_value()) {
      names.push_back("ou");
    }
    if (ee.has_value()) {
      names.push_back("ee");
    }
    if (oh.has_value()) {
      names.push_back("oh");
    }
    if (blink.has_value()) {
      names.push_back("blink");
    }
    if (blinkLeft.has_value()) {
      names.push_back("blinkLeft");
    }
    if (blinkRight.has_value()) {
      names.push_back("blinkRight");
    }
    if (lookUp.has_value()) {
      names.push_back("lookUp");
    }
    if (lookDown.has_value()) {
      names.push_back("lookDown");
    }
    if (lookLeft.has_value()) {
      names.push_back("lookLeft");
    }
    if (lookRight.has_value()) {
      names.push_back("lookRight");
    }
    if (neutral.has_value()) {
      names.push_back("neutral");
    }
    return names;
  }
};

class Expressions {
public:
  std::optional<ExpressionsPreset> preset;
  std::optional<std::map<std::string, Expression>> custom;

  const Expression *expressionByName(std::string name) const {
    std::transform(name.begin(), name.end(), name.begin(), ::tolower);

    if (preset) {
      if (name == "happy") {
        return preset->happy.has_value() ? &(*preset->happy) : nullptr;
      } else if (name == "angry") {
        return preset->angry.has_value() ? &(*preset->angry) : nullptr;
      } else if (name == "sad") {
        return preset->sad.has_value() ? &(*preset->sad) : nullptr;
      } else if (name == "relaxed") {
        return preset->relaxed.has_value() ? &(*preset->relaxed) : nullptr;
      } else if (name == "surprised") {
        return preset->surprised.has_value() ? &(*preset->surprised) : nullptr;
      } else if (name == "aa") {
        return preset->aa.has_value() ? &(*preset->aa) : nullptr;
      } else if (name == "ih") {
        return preset->ih.has_value() ? &(*preset->ih) : nullptr;
      } else if (name == "ou") {
        return preset->ou.has_value() ? &(*preset->ou) : nullptr;
      } else if (name == "ee") {
        return preset->ee.has_value() ? &(*preset->ee) : nullptr;
      } else if (name == "oh") {
        return preset->oh.has_value() ? &(*preset->oh) : nullptr;
      } else if (name == "blink") {
        return preset->blink.has_value() ? &(*preset->blink) : nullptr;
      } else if (name == "blinkleft") {
        return preset->blinkLeft.has_value() ? &(*preset->blinkLeft) : nullptr;
      } else if (name == "blinkright") {
        return preset->blinkRight.has_value() ? &(*preset->blinkRight)
                                              : nullptr;
      } else if (name == "lookup") {
        return preset->lookUp.has_value() ? &(*preset->lookUp) : nullptr;
      } else if (name == "lookdown") {
        return preset->lookDown.has_value() ? &(*preset->lookDown) : nullptr;
      } else if (name == "lookleft") {
        return preset->lookLeft.has_value() ? &(*preset->lookLeft) : nullptr;
      } else if (name == "lookright") {
        return preset->lookRight.has_value() ? &(*preset->lookRight) : nullptr;
      } else if (name == "neutral") {
        return preset->neutral.has_value() ? &(*preset->neutral) : nullptr;
      }
    }

    if (custom) {
      for (const auto &pair : *custom) {
        std::string key = pair.first;
        std::transform(key.begin(), key.end(), key.begin(), ::tolower);
        if (key == name) {
          return &pair.second;
        }
      }
    }

    return nullptr;
  }

  std::vector<std::string> expressionNames() const {
    std::vector<std::string> names;
    if (preset.has_value()) {
      names = preset->expressionNames();
    }
    if (custom.has_value()) {
      for (const auto &pair : *custom) {
        names.push_back(pair.first);
      }
    }
    return names;
  }
};

// VRM

class VRM {
public:
  std::string specVersion;
  Meta meta;
  Humanoid humanoid;
  std::optional<FirstPerson> firstPerson;
  std::optional<LookAt> lookAt;
  std::optional<Expressions> expressions;

  const Expression *expressionByName(const std::string &name) const {
    if (!expressions.has_value())
      return nullptr;
    return expressions->expressionByName(name);
  }
};

} // namespace vrm1
} // namespace json
}; // namespace gltf2

#endif /* Json__h */
