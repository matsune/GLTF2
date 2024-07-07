#include "GLTF2.h"
#include "JsonDecoder.h"
#include "config.h"
#include "nlohmann/json.hpp"
#include <gtest/gtest.h>

using namespace gltf2;

gltf2::json::Json readSpringBoneJson() {
  std::ifstream fs;
  fs.open(SPRINGBONE_JSON_PATH, std::ios::binary);
  return gltf2::json::JsonDecoder::decode(nlohmann::json::parse(fs));
}

TEST(TestGLTFData, validSpringBone) {
  const auto j = readSpringBoneJson();
  const auto &springBone = *j.springBone;

  ASSERT_EQ(springBone.specVersion, "1.0");

  ASSERT_TRUE(springBone.colliders.has_value());
  ASSERT_EQ(springBone.colliders->size(), 1);
  auto &collider = springBone.colliders->at(0);
  ASSERT_EQ(collider.node, 0);
  ASSERT_TRUE(collider.shape.sphere.has_value());
  ASSERT_EQ(collider.shape.sphere->offsetValue().at(0), 0.0f);
  ASSERT_EQ(collider.shape.sphere->offsetValue().at(1), 0.1f);
  ASSERT_EQ(collider.shape.sphere->offsetValue().at(2), 0.2f);
  ASSERT_EQ(collider.shape.sphere->radiusValue(), 0.3f);

  ASSERT_TRUE(springBone.colliderGroups.has_value());
  ASSERT_EQ(springBone.colliderGroups->size(), 1);
  auto &colliderGroup = springBone.colliderGroups->at(0);
  ASSERT_EQ(colliderGroup.name.value(), "Group1");
  ASSERT_EQ(colliderGroup.colliders.size(), 1);
  ASSERT_EQ(colliderGroup.colliders.at(0), 0);

  ASSERT_TRUE(springBone.springs.has_value());
  ASSERT_EQ(springBone.springs->size(), 1);
  auto &spring = springBone.springs->at(0);
  ASSERT_EQ(spring.name.value(), "Spring1");
  ASSERT_EQ(spring.joints.size(), 1);
  auto &joint = spring.joints.at(0);
  ASSERT_EQ(joint.node, 1);
  ASSERT_EQ(joint.hitRadius.value(), 0.2f);
  ASSERT_EQ(joint.stiffnessValue(), 0.5f);
  ASSERT_EQ(joint.gravityPowerValue(), 1.0f);
  ASSERT_EQ(joint.gravityDirValue().at(0), 0.0f);
  ASSERT_EQ(joint.gravityDirValue().at(1), -1.0f);
  ASSERT_EQ(joint.gravityDirValue().at(2), 0.0f);
  ASSERT_EQ(joint.dragForceValue(), 0.3f);
  ASSERT_EQ(spring.colliderGroups->size(), 1);
  ASSERT_EQ(spring.colliderGroups->at(0), 0);
  ASSERT_EQ(spring.center.value(), 1);
}
