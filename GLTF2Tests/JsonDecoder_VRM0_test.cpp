#include "GLTF2.h"
#include "JsonDecoder.h"
#include "config.h"
#include "nlohmann/json.hpp"
#include <gtest/gtest.h>

using namespace gltf2;

gltf2::json::Json readVRM0Json() {
  std::ifstream fs;
  fs.open(VRM0_JSON_PATH, std::ios::binary);
  return gltf2::json::JsonDecoder::decode(nlohmann::json::parse(fs));
}

TEST(TestGLTFData, validVRM0) {
  const auto j = readVRM0Json();
  const auto &vrm = *j.vrm0;

  ASSERT_EQ(vrm.exporterVersion, "UniVRM-0.46");
  ASSERT_EQ(vrm.specVersion, "0.0");

  auto &meta = vrm.meta;
  ASSERT_EQ(meta->title, "Sample json::vrm0:: Model");
  ASSERT_EQ(meta->version, "1.0");
  ASSERT_EQ(meta->author, "John Doe");
  ASSERT_EQ(meta->contactInformation, "john.doe@example.com");
  ASSERT_EQ(meta->reference, "https://example.com/reference");
  ASSERT_EQ(meta->texture, 1);
  ASSERT_EQ(meta->allowedUserNameValue(),
            json::vrm0::Meta::AllowedUserName::EVERYONE);
  ASSERT_EQ(meta->violentUsageValue(),
            json::vrm0::Meta::UsagePermission::ALLOW);
  ASSERT_EQ(meta->sexualUsageValue(),
            json::vrm0::Meta::UsagePermission::DISALLOW);
  ASSERT_EQ(meta->commercialUsageValue(),
            json::vrm0::Meta::UsagePermission::ALLOW);
  ASSERT_EQ(meta->otherPermissionUrl, "https://example.com/permissions");
  ASSERT_EQ(meta->licenseNameValue(), json::vrm0::Meta::LicenseName::CC_BY);
  ASSERT_EQ(meta->otherLicenseUrl, "https://example.com/other-license");

  auto &humanoid = vrm.humanoid;
  ASSERT_EQ(humanoid->armStretch.value(), 0.05f);
  ASSERT_EQ(humanoid->legStretch.value(), 0.03f);
  ASSERT_EQ(humanoid->upperArmTwist.value(), 0.5f);
  ASSERT_EQ(humanoid->lowerArmTwist.value(), 0.4f);
  ASSERT_EQ(humanoid->upperLegTwist.value(), 0.6f);
  ASSERT_EQ(humanoid->lowerLegTwist.value(), 0.5f);
  ASSERT_EQ(humanoid->feetSpacing.value(), 0.2f);
  ASSERT_TRUE(humanoid->hasTranslationDoF.value());

  auto &humanBones = humanoid->humanBones;
  ASSERT_EQ(humanBones->size(), 2);

  auto &bone1 = humanBones->at(0);
  ASSERT_EQ(bone1.bone, json::vrm0::HumanoidBone::BoneName::HIPS);
  ASSERT_EQ(bone1.node, 0);
  ASSERT_TRUE(bone1.useDefaultValues.value());
  ASSERT_EQ(bone1.min->x.value(), -0.5f);
  ASSERT_EQ(bone1.min->y.value(), -0.5f);
  ASSERT_EQ(bone1.min->z.value(), -0.5f);
  ASSERT_EQ(bone1.max->x.value(), 0.5f);
  ASSERT_EQ(bone1.max->y.value(), 0.5f);
  ASSERT_EQ(bone1.max->z.value(), 0.5f);
  ASSERT_EQ(bone1.center->x.value(), 0.0f);
  ASSERT_EQ(bone1.center->y.value(), 0.0f);
  ASSERT_EQ(bone1.center->z.value(), 0.0f);
  ASSERT_EQ(bone1.axisLength.value(), 1.0f);

  auto &bone2 = humanBones->at(1);
  ASSERT_EQ(bone2.bone, json::vrm0::HumanoidBone::BoneName::LEFT_UPPER_LEG);
  ASSERT_EQ(bone2.node, 1);
  ASSERT_FALSE(bone2.useDefaultValues.value());
  ASSERT_EQ(bone2.min->x.value(), -0.3f);
  ASSERT_EQ(bone2.min->y.value(), -0.3f);
  ASSERT_EQ(bone2.min->z.value(), -0.3f);
  ASSERT_EQ(bone2.max->x.value(), 0.3f);
  ASSERT_EQ(bone2.max->y.value(), 0.3f);
  ASSERT_EQ(bone2.max->z.value(), 0.3f);
  ASSERT_EQ(bone2.center->x.value(), 0.1f);
  ASSERT_EQ(bone2.center->y.value(), 0.1f);
  ASSERT_EQ(bone2.center->z.value(), 0.1f);
  ASSERT_EQ(bone2.axisLength.value(), 1.2f);

  auto &firstPerson = vrm.firstPerson;
  ASSERT_EQ(firstPerson->firstPersonBone.value(), 1);
  ASSERT_EQ(firstPerson->firstPersonBoneOffset->x.value(), 0.0f);
  ASSERT_EQ(firstPerson->firstPersonBoneOffset->y.value(), 0.1f);
  ASSERT_EQ(firstPerson->firstPersonBoneOffset->z.value(), 0.2f);

  ASSERT_EQ(firstPerson->meshAnnotations->size(), 1);
  ASSERT_EQ(firstPerson->meshAnnotations->at(0).mesh, 0);
  ASSERT_EQ(firstPerson->meshAnnotations->at(0).firstPersonFlag, "Auto");

  ASSERT_EQ(firstPerson->lookAtTypeName.value(),
            json::vrm0::FirstPerson::LookAtType::BONE);

  auto &horizontalInner = firstPerson->lookAtHorizontalInner.value();
  ASSERT_EQ(horizontalInner.curve->size(), 1);
  ASSERT_EQ(horizontalInner.curve->at(0).time, 0.0f);
  ASSERT_EQ(horizontalInner.curve->at(0).value, 0.5f);
  ASSERT_EQ(horizontalInner.curve->at(0).inTangent, 1.0f);
  ASSERT_EQ(horizontalInner.curve->at(0).outTangent, 1.5f);
  ASSERT_EQ(horizontalInner.xRange.value(), 90.0f);
  ASSERT_EQ(horizontalInner.yRange.value(), 10.0f);

  auto &horizontalOuter = firstPerson->lookAtHorizontalOuter.value();
  ASSERT_EQ(horizontalOuter.curve->size(), 1);
  ASSERT_EQ(horizontalOuter.curve->at(0).time, 0.0f);
  ASSERT_EQ(horizontalOuter.curve->at(0).value, 0.5f);
  ASSERT_EQ(horizontalOuter.curve->at(0).inTangent, 1.0f);
  ASSERT_EQ(horizontalOuter.curve->at(0).outTangent, 1.5f);
  ASSERT_EQ(horizontalOuter.xRange.value(), 90.0f);
  ASSERT_EQ(horizontalOuter.yRange.value(), 10.0f);

  auto &verticalDown = firstPerson->lookAtVerticalDown.value();
  ASSERT_EQ(verticalDown.curve->size(), 1);
  ASSERT_EQ(verticalDown.curve->at(0).time, 0.0f);
  ASSERT_EQ(verticalDown.curve->at(0).value, 0.5f);
  ASSERT_EQ(verticalDown.curve->at(0).inTangent, 1.0f);
  ASSERT_EQ(verticalDown.curve->at(0).outTangent, 1.5f);
  ASSERT_EQ(verticalDown.xRange.value(), 90.0f);
  ASSERT_EQ(verticalDown.yRange.value(), 10.0f);

  auto &verticalUp = firstPerson->lookAtVerticalUp.value();
  ASSERT_EQ(verticalUp.curve->size(), 1);
  ASSERT_EQ(verticalUp.curve->at(0).time, 0.0f);
  ASSERT_EQ(verticalUp.curve->at(0).value, 0.5f);
  ASSERT_EQ(verticalUp.curve->at(0).inTangent, 1.0f);
  ASSERT_EQ(verticalUp.curve->at(0).outTangent, 1.5f);
  ASSERT_EQ(verticalUp.xRange.value(), 90.0f);
  ASSERT_EQ(verticalUp.yRange.value(), 10.0f);

  auto &blendShape = vrm.blendShapeMaster;
  ASSERT_EQ(blendShape->blendShapeGroups->size(), 1);

  auto &blendShapeGroup = blendShape->blendShapeGroups->at(0);
  ASSERT_EQ(blendShapeGroup.name, "smile");
  ASSERT_EQ(blendShapeGroup.presetName.value(),
            json::vrm0::BlendShapeGroup::PresetName::JOY);
  ASSERT_EQ(blendShapeGroup.binds->size(), 1);
  ASSERT_EQ(blendShapeGroup.materialValues->size(), 1);
  ASSERT_TRUE(blendShapeGroup.isBinary.value());

  auto &bind = blendShapeGroup.binds->at(0);
  ASSERT_EQ(bind.mesh, 0);
  ASSERT_EQ(bind.index, 1);
  ASSERT_EQ(bind.weight, 50.0f);

  auto &materialBind = blendShapeGroup.materialValues->at(0);
  ASSERT_EQ(materialBind.materialName, "face");
  ASSERT_EQ(materialBind.propertyName, "_Color");
  ASSERT_EQ(materialBind.targetValue->size(), 4);
  ASSERT_EQ(materialBind.targetValue->at(0), 1.0f);
  ASSERT_EQ(materialBind.targetValue->at(1), 0.5f);
  ASSERT_EQ(materialBind.targetValue->at(2), 0.5f);
  ASSERT_EQ(materialBind.targetValue->at(3), 1.0f);

  auto &secondaryAnimation = vrm.secondaryAnimation;
  ASSERT_EQ(secondaryAnimation->boneGroups->size(), 1);
  ASSERT_EQ(secondaryAnimation->colliderGroups->size(), 1);

  auto &boneGroup = secondaryAnimation->boneGroups->at(0);
  ASSERT_EQ(boneGroup.comment, "Hair");
  ASSERT_EQ(boneGroup.stiffiness.value(), 0.5f);
  ASSERT_EQ(boneGroup.gravityPower.value(), 0.98f);
  ASSERT_EQ(boneGroup.gravityDir->x.value(), 0.0f);
  ASSERT_EQ(boneGroup.gravityDir->y.value(), -1.0f);
  ASSERT_EQ(boneGroup.gravityDir->z.value(), 0.0f);
  ASSERT_EQ(boneGroup.dragForce.value(), 0.3f);
  ASSERT_EQ(boneGroup.center.value(), 0);
  ASSERT_EQ(boneGroup.hitRadius.value(), 0.2f);
  ASSERT_EQ(boneGroup.bones->size(), 3);
  ASSERT_EQ(boneGroup.bones->at(0), 1);
  ASSERT_EQ(boneGroup.bones->at(1), 2);
  ASSERT_EQ(boneGroup.bones->at(2), 3);
  ASSERT_EQ(boneGroup.colliderGroups->size(), 1);
  ASSERT_EQ(boneGroup.colliderGroups->at(0), 0);

  auto &colliderGroup = secondaryAnimation->colliderGroups->at(0);
  ASSERT_EQ(colliderGroup.node, 0);
  ASSERT_EQ(colliderGroup.colliders->size(), 1);

  auto &collider = colliderGroup.colliders->at(0);
  ASSERT_EQ(collider.offset->x.value(), 0.0f);
  ASSERT_EQ(collider.offset->y.value(), 0.0f);
  ASSERT_EQ(collider.offset->z.value(), 0.0f);
  ASSERT_EQ(collider.radius.value(), 0.5f);

  auto &material = vrm.materialProperties->at(0);
  ASSERT_EQ(material.name, "exampleMaterial");
  ASSERT_EQ(material.shader, "VRM/MToon");
  ASSERT_EQ(material.renderQueue.value(), 2000);

  ASSERT_EQ(material.floatProperties->size(), 2);
  ASSERT_EQ(material.floatProperties->at("_Cutoff"), 0.5f);
  ASSERT_EQ(material.floatProperties->at("_BumpScale"), 1.0f);

  ASSERT_EQ(material.vectorProperties->size(), 2);
  ASSERT_EQ(material.vectorProperties->at("_MainTex").size(), 4);
  ASSERT_EQ(material.vectorProperties->at("_MainTex")[0], 1.0f);
  ASSERT_EQ(material.vectorProperties->at("_MainTex")[1], 1.0f);
  ASSERT_EQ(material.vectorProperties->at("_MainTex")[2], 0.0f);
  ASSERT_EQ(material.vectorProperties->at("_MainTex")[3], 0.0f);
  ASSERT_EQ(material.vectorProperties->at("_Color").size(), 4);
  ASSERT_EQ(material.vectorProperties->at("_Color")[0], 1.0f);
  ASSERT_EQ(material.vectorProperties->at("_Color")[1], 0.5f);
  ASSERT_EQ(material.vectorProperties->at("_Color")[2], 0.5f);
  ASSERT_EQ(material.vectorProperties->at("_Color")[3], 1.0f);

  ASSERT_EQ(material.textureProperties->size(), 2);
  ASSERT_EQ(material.textureProperties->at("_MainTex"), 0);
  ASSERT_EQ(material.textureProperties->at("_BumpMap"), 1);

  ASSERT_EQ(material.keywordMap->size(), 2);
  ASSERT_TRUE(material.keywordMap->at("_ALPHABLEND_ON"));
  ASSERT_FALSE(material.keywordMap->at("_ALPHATEST_ON"));

  ASSERT_EQ(material.tagMap->size(), 1);
  ASSERT_EQ(material.tagMap->at("RenderType"), "Transparent");
}
