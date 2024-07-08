#include "GLTF2.h"
#include "JsonDecoder.h"
#include "config.h"
#include "nlohmann/json.hpp"
#include <gtest/gtest.h>

using namespace gltf2;

gltf2::json::Json readMToonJson() {
  std::ifstream fs;
  fs.open(MTOON_JSON_PATH, std::ios::binary);
  return gltf2::json::JsonDecoder::decode(nlohmann::json::parse(fs));
}

TEST(TestGLTFData, validMToon) {
  const auto j = readMToonJson();
  const auto &mtoon = *j.materials->at(0).mtoon;

  ASSERT_EQ(mtoon.specVersion, "1.0");

  ASSERT_TRUE(mtoon.transparentWithZWrite.has_value());
  ASSERT_FALSE(mtoon.transparentWithZWrite.value());

  ASSERT_TRUE(mtoon.renderQueueOffsetNumber.has_value());
  ASSERT_EQ(mtoon.renderQueueOffsetNumber.value(), 5);

  ASSERT_TRUE(mtoon.shadeColorFactor.has_value());
  ASSERT_FLOAT_EQ(mtoon.shadeColorFactor->at(0), 0.7f);
  ASSERT_FLOAT_EQ(mtoon.shadeColorFactor->at(1), 0.6f);
  ASSERT_FLOAT_EQ(mtoon.shadeColorFactor->at(2), 0.5f);

  ASSERT_TRUE(mtoon.shadeMultiplyTexture.has_value());
  ASSERT_EQ(mtoon.shadeMultiplyTexture->index, 2);
  ASSERT_EQ(mtoon.shadeMultiplyTexture->texCoord, 0);

  ASSERT_TRUE(mtoon.shadingShiftFactor.has_value());
  ASSERT_FLOAT_EQ(mtoon.shadingShiftFactor.value(), 0.3f);

  ASSERT_TRUE(mtoon.shadingShiftTexture.has_value());
  ASSERT_EQ(mtoon.shadingShiftTexture->index.value(), 1);
  ASSERT_EQ(mtoon.shadingShiftTexture->texCoord.value(), 1);
  ASSERT_FLOAT_EQ(mtoon.shadingShiftTexture->scale.value(), 0.5f);

  ASSERT_TRUE(mtoon.shadingToonyFactor.has_value());
  ASSERT_FLOAT_EQ(mtoon.shadingToonyFactor.value(), 0.85f);

  ASSERT_TRUE(mtoon.giEqualizationFactor.has_value());
  ASSERT_FLOAT_EQ(mtoon.giEqualizationFactor.value(), 0.95f);

  ASSERT_TRUE(mtoon.matcapFactor.has_value());
  ASSERT_FLOAT_EQ(mtoon.matcapFactor->at(0), 0.9f);
  ASSERT_FLOAT_EQ(mtoon.matcapFactor->at(1), 0.8f);
  ASSERT_FLOAT_EQ(mtoon.matcapFactor->at(2), 0.85f);

  ASSERT_TRUE(mtoon.matcapTexture.has_value());
  ASSERT_EQ(mtoon.matcapTexture->index, 3);
  ASSERT_EQ(mtoon.matcapTexture->texCoord, 0);

  ASSERT_TRUE(mtoon.parametricRimColorFactor.has_value());
  ASSERT_FLOAT_EQ(mtoon.parametricRimColorFactor->at(0), 0.2f);
  ASSERT_FLOAT_EQ(mtoon.parametricRimColorFactor->at(1), 0.3f);
  ASSERT_FLOAT_EQ(mtoon.parametricRimColorFactor->at(2), 0.1f);

  ASSERT_TRUE(mtoon.rimMultiplyTexture.has_value());
  ASSERT_EQ(mtoon.rimMultiplyTexture->index, 4);
  ASSERT_EQ(mtoon.rimMultiplyTexture->texCoord, 0);

  ASSERT_TRUE(mtoon.rimLightingMixFactor.has_value());
  ASSERT_FLOAT_EQ(mtoon.rimLightingMixFactor.value(), 0.75f);

  ASSERT_TRUE(mtoon.parametricRimFresnelPowerFactor.has_value());
  ASSERT_FLOAT_EQ(mtoon.parametricRimFresnelPowerFactor.value(), 1.0f);

  ASSERT_TRUE(mtoon.parametricRimLiftFactor.has_value());
  ASSERT_FLOAT_EQ(mtoon.parametricRimLiftFactor.value(), 0.0f);

  ASSERT_TRUE(mtoon.outlineWidthMode.has_value());
  ASSERT_EQ(mtoon.outlineWidthMode.value(),
            json::vrmc::MaterialsMtoon::OutlineWidthMode::SCREEN_COORDINATES);

  ASSERT_TRUE(mtoon.outlineWidthFactor.has_value());
  ASSERT_FLOAT_EQ(mtoon.outlineWidthFactor.value(), 0.1f);

  ASSERT_TRUE(mtoon.outlineWidthMultiplyTexture.has_value());
  ASSERT_EQ(mtoon.outlineWidthMultiplyTexture->index, 5);
  ASSERT_EQ(mtoon.outlineWidthMultiplyTexture->texCoord, 0);

  ASSERT_TRUE(mtoon.outlineColorFactor.has_value());
  ASSERT_FLOAT_EQ(mtoon.outlineColorFactor->at(0), 0.05f);
  ASSERT_FLOAT_EQ(mtoon.outlineColorFactor->at(1), 0.05f);
  ASSERT_FLOAT_EQ(mtoon.outlineColorFactor->at(2), 0.05f);

  ASSERT_TRUE(mtoon.outlineLightingMixFactor.has_value());
  ASSERT_FLOAT_EQ(mtoon.outlineLightingMixFactor.value(), 1.0f);

  ASSERT_TRUE(mtoon.uvAnimationMaskTexture.has_value());
  ASSERT_EQ(mtoon.uvAnimationMaskTexture->index, 6);
  ASSERT_EQ(mtoon.uvAnimationMaskTexture->texCoord, 0);

  ASSERT_TRUE(mtoon.uvAnimationScrollXSpeedFactor.has_value());
  ASSERT_FLOAT_EQ(mtoon.uvAnimationScrollXSpeedFactor.value(), 0.02f);

  ASSERT_TRUE(mtoon.uvAnimationScrollYSpeedFactor.has_value());
  ASSERT_FLOAT_EQ(mtoon.uvAnimationScrollYSpeedFactor.value(), -0.03f);

  ASSERT_TRUE(mtoon.uvAnimationRotationSpeedFactor.has_value());
  ASSERT_FLOAT_EQ(mtoon.uvAnimationRotationSpeedFactor.value(), 0.01f);
}
