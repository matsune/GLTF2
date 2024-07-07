#include "GLTF2.h"
#include "JsonDecoder.h"
#include "config.h"
#include "nlohmann/json.hpp"
#include <gtest/gtest.h>

using namespace gltf2;

gltf2::json::Json readVRM1Json() {
  std::ifstream fs;
  fs.open(VRM1_JSON_PATH, std::ios::binary);
  return gltf2::json::JsonDecoder::decode(nlohmann::json::parse(fs));
}

TEST(TestGLTFData, validVRM1) {
  const auto j = readVRM1Json();
  const auto &vrm = *j.vrm1;

  ASSERT_EQ(vrm.specVersion, "1.0");

  auto &meta = vrm.meta;
  ASSERT_EQ(meta.name, "test");
  ASSERT_EQ(meta.authors, std::vector<std::string>{"test author 1"});
  ASSERT_EQ(meta.copyrightInformation, "copyrightInformation");
  ASSERT_EQ(meta.contactInformation, "contactInformation");
  ASSERT_EQ(meta.references, std::vector<std::string>{"references_1"});
  ASSERT_EQ(meta.thumbnailImage, 0);
  ASSERT_EQ(meta.thirdPartyLicenses, "thirdPartyLicenses");
  ASSERT_EQ(meta.licenseUrl, "https://vrm.dev/licenses/1.0");
  ASSERT_EQ(
      meta.avatarPermission,
      json::vrmc::Meta::AvatarPermission::ONLY_SEPARATELY_LICENSED_PERSON);
  ASSERT_TRUE(meta.allowExcessivelyViolentUsage);
  ASSERT_TRUE(meta.allowExcessivelySexualUsage);
  ASSERT_EQ(meta.commercialUsage,
            json::vrmc::Meta::CommercialUsage::PERSONAL_PROFIT);
  ASSERT_TRUE(meta.allowPoliticalOrReligiousUsage);
  ASSERT_TRUE(meta.allowAntisocialOrHateUsage);
  ASSERT_EQ(meta.creditNotation, json::vrmc::Meta::CreditNotation::UNNECESSARY);
  ASSERT_TRUE(meta.allowRedistribution);
  ASSERT_EQ(meta.modification,
            json::vrmc::Meta::Modification::ALLOW_MODIFICATION_REDISTRIBUTION);
  ASSERT_EQ(meta.otherLicenseUrl, "otherLicenseUrl");

  auto &humanBones = vrm.humanoid.humanBones;
  ASSERT_EQ(humanBones.chest->node, 22);
  ASSERT_EQ(humanBones.head.node, 25);
  ASSERT_EQ(humanBones.hips.node, 4);
  ASSERT_EQ(humanBones.leftEye->node, 26);
  ASSERT_EQ(humanBones.leftFoot.node, 162);
  ASSERT_EQ(humanBones.leftHand.node, 98);
  ASSERT_EQ(humanBones.leftIndexDistal->node, 101);
  ASSERT_EQ(humanBones.leftIndexIntermediate->node, 100);
  ASSERT_EQ(humanBones.leftIndexProximal->node, 99);
  ASSERT_EQ(humanBones.leftLittleDistal->node, 105);
  ASSERT_EQ(humanBones.leftLittleIntermediate->node, 104);
  ASSERT_EQ(humanBones.leftLittleProximal->node, 103);
  ASSERT_EQ(humanBones.leftLowerArm.node, 97);
  ASSERT_EQ(humanBones.leftLowerLeg.node, 161);
  ASSERT_EQ(humanBones.leftMiddleDistal->node, 109);
  ASSERT_EQ(humanBones.leftMiddleIntermediate->node, 108);
  ASSERT_EQ(humanBones.leftMiddleProximal->node, 107);
  ASSERT_EQ(humanBones.leftRingDistal->node, 113);
  ASSERT_EQ(humanBones.leftRingIntermediate->node, 112);
  ASSERT_EQ(humanBones.leftRingProximal->node, 111);
  ASSERT_EQ(humanBones.leftShoulder->node, 88);
  ASSERT_EQ(humanBones.leftThumbDistal->node, 117);
  ASSERT_EQ(humanBones.leftThumbMetacarpal->node, 115);
  ASSERT_EQ(humanBones.leftThumbProximal->node, 116);
  ASSERT_EQ(humanBones.leftToes->node, 163);
  ASSERT_EQ(humanBones.leftUpperArm.node, 96);
  ASSERT_EQ(humanBones.leftUpperLeg.node, 160);
  ASSERT_EQ(humanBones.neck->node, 24);
  ASSERT_EQ(humanBones.rightEye->node, 27);
  ASSERT_EQ(humanBones.rightFoot.node, 167);
  ASSERT_EQ(humanBones.rightHand.node, 132);
  ASSERT_EQ(humanBones.rightIndexDistal->node, 135);
  ASSERT_EQ(humanBones.rightIndexIntermediate->node, 134);
  ASSERT_EQ(humanBones.rightIndexProximal->node, 133);
  ASSERT_EQ(humanBones.rightLittleDistal->node, 139);
  ASSERT_EQ(humanBones.rightLittleIntermediate->node, 138);
  ASSERT_EQ(humanBones.rightLittleProximal->node, 137);
  ASSERT_EQ(humanBones.rightLowerArm.node, 131);
  ASSERT_EQ(humanBones.rightLowerLeg.node, 166);
  ASSERT_EQ(humanBones.rightMiddleDistal->node, 143);
  ASSERT_EQ(humanBones.rightMiddleIntermediate->node, 142);
  ASSERT_EQ(humanBones.rightMiddleProximal->node, 141);
  ASSERT_EQ(humanBones.rightRingDistal->node, 147);
  ASSERT_EQ(humanBones.rightRingIntermediate->node, 146);
  ASSERT_EQ(humanBones.rightRingProximal->node, 145);
  ASSERT_EQ(humanBones.rightShoulder->node, 122);
  ASSERT_EQ(humanBones.rightThumbDistal->node, 151);
  ASSERT_EQ(humanBones.rightThumbMetacarpal->node, 149);
  ASSERT_EQ(humanBones.rightThumbProximal->node, 150);
  ASSERT_EQ(humanBones.rightToes->node, 168);
  ASSERT_EQ(humanBones.rightUpperArm.node, 130);
  ASSERT_EQ(humanBones.rightUpperLeg.node, 165);
  ASSERT_EQ(humanBones.spine.node, 21);
  ASSERT_EQ(humanBones.upperChest->node, 23);

  auto &firstPerson = *vrm.firstPerson;
  auto &meshAnnotation = firstPerson.meshAnnotations->at(0);
  ASSERT_EQ(meshAnnotation.node, 1);
  ASSERT_EQ(meshAnnotation.type,
            json::vrmc::FirstPersonMeshAnnotation::Type::FIRST_PERSON_ONLY);

  const auto &lookAt = *vrm.lookAt;
  ASSERT_EQ(lookAt.offsetFromHeadBone->at(0), 1.0f);
  ASSERT_EQ(lookAt.offsetFromHeadBone->at(1), 2.0f);
  ASSERT_EQ(lookAt.offsetFromHeadBone->at(2), 3.0f);
  ASSERT_EQ(lookAt.type, json::vrmc::LookAt::Type::EXPRESSION);
  ASSERT_EQ(lookAt.rangeMapHorizontalInner->inputMaxValue, 1.0f);
  ASSERT_EQ(lookAt.rangeMapHorizontalInner->outputScale, 2.0f);
  ASSERT_EQ(lookAt.rangeMapHorizontalOuter->inputMaxValue, 3.0f);
  ASSERT_EQ(lookAt.rangeMapHorizontalOuter->outputScale, 4.0f);
  ASSERT_EQ(lookAt.rangeMapVerticalDown->inputMaxValue, 5.0f);
  ASSERT_EQ(lookAt.rangeMapVerticalDown->outputScale, 6.0f);
  ASSERT_EQ(lookAt.rangeMapVerticalUp->inputMaxValue, 7.0f);
  ASSERT_EQ(lookAt.rangeMapVerticalUp->outputScale, 8.0f);

  const auto &happy = *vrm.expressions->preset->happy;
  ASSERT_EQ(happy.morphTargetBinds->at(0).node, 1);
  ASSERT_EQ(happy.morphTargetBinds->at(0).index, 2);
  ASSERT_EQ(happy.morphTargetBinds->at(0).weight, 3.0f);
  ASSERT_EQ(happy.materialColorBinds->at(0).material, 1);
  ASSERT_EQ(happy.materialColorBinds->at(0).type,
            json::vrmc::ExpressionMaterialColorBind::Type::OUTLINE_COLOR);
  ASSERT_EQ(happy.materialColorBinds->at(0).targetValue.at(0), 0.0f);
  ASSERT_EQ(happy.materialColorBinds->at(0).targetValue.at(1), 1.0f);
  ASSERT_EQ(happy.materialColorBinds->at(0).targetValue.at(2), 2.0f);
  ASSERT_EQ(happy.materialColorBinds->at(0).targetValue.at(3), 3.0f);
  ASSERT_EQ(happy.textureTransformBinds->at(0).material, 3);
  ASSERT_EQ(happy.textureTransformBinds->at(0).scale->at(0), 0.1f);
  ASSERT_EQ(happy.textureTransformBinds->at(0).scale->at(1), 0.2f);
  ASSERT_EQ(happy.textureTransformBinds->at(0).offset->at(0), 1.0f);
  ASSERT_EQ(happy.textureTransformBinds->at(0).offset->at(1), 2.0f);
  ASSERT_EQ(happy.isBinary, true);
  ASSERT_EQ(happy.overrideBlink, json::vrmc::Expression::Override::NONE);
  ASSERT_EQ(happy.overrideLookAt, json::vrmc::Expression::Override::BLOCK);
  ASSERT_EQ(happy.overrideMouth, json::vrmc::Expression::Override::BLEND);
}
