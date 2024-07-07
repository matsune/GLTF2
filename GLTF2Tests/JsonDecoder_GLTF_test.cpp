#include "GLTF2.h"
#include "JsonDecoder.h"
#include "config.h"
#include "nlohmann/json.hpp"
#include <gtest/gtest.h>

using namespace gltf2;

gltf2::json::Json readTestJson() {
  std::ifstream fs;
  fs.open(GLTF_JSON_PATH, std::ios::binary);
  return gltf2::json::JsonDecoder::decode(nlohmann::json::parse(fs));
}

TEST(JsonDecoder, extensionsUsed) {
  const auto j = readTestJson();
  EXPECT_EQ(j.extensionsUsed->size(), 2);
  EXPECT_EQ(j.extensionsUsed->at(0), "ext1");
  EXPECT_EQ(j.extensionsUsed->at(1), "ext2");
  EXPECT_EQ(j.extensionsRequired->size(), 1);
  EXPECT_EQ(j.extensionsRequired->at(0), "ext1");
}

TEST(JsonDecoder, extensionsRequired) {
  const auto j = readTestJson();
  EXPECT_EQ(j.extensionsRequired->size(), 1);
  EXPECT_EQ(j.extensionsRequired->at(0), "ext1");
}

TEST(JsonDecoder, accessors) {
  const auto j = readTestJson();
  EXPECT_EQ(j.accessors->size(), 2);

  auto &accessor1 = j.accessors->at(0);
  EXPECT_EQ(accessor1.bufferView, 0);
  EXPECT_EQ(accessor1.byteOffset, 0);
  EXPECT_EQ(accessor1.componentType,
            json::Accessor::ComponentType::UNSIGNED_SHORT);
  EXPECT_EQ(accessor1.normalized, false);
  EXPECT_EQ(accessor1.count, 3);
  EXPECT_EQ(accessor1.type, json::Accessor::Type::VEC3);
  EXPECT_EQ(accessor1.max.value(), std::vector<float>({1, 1, 1}));
  EXPECT_EQ(accessor1.min.value(), std::vector<float>({-1, -1, -1}));

  auto &accessor2 = j.accessors->at(1);
  EXPECT_EQ(accessor2.bufferView, 1);
  EXPECT_EQ(accessor2.byteOffset, 24);
  EXPECT_EQ(accessor2.componentType,
            json::Accessor::ComponentType::UNSIGNED_INT);
  EXPECT_EQ(accessor2.normalized, true);
  EXPECT_EQ(accessor2.count, 3);
  EXPECT_EQ(accessor2.type, json::Accessor::Type::SCALAR);
  EXPECT_TRUE(accessor2.sparse.has_value());
  auto &sparse = accessor2.sparse.value();
  EXPECT_EQ(sparse.count, 2);
  EXPECT_EQ(sparse.indices.bufferView, 3);
  EXPECT_EQ(sparse.indices.byteOffset, 0);
  EXPECT_EQ(sparse.indices.componentType,
            json::AccessorSparseIndices::ComponentType::UNSIGNED_SHORT);
  EXPECT_EQ(sparse.values.bufferView, 4);
  EXPECT_EQ(sparse.values.byteOffset, 8);
}

TEST(JsonDecoder, animations) {
  const auto j = readTestJson();
  EXPECT_EQ(j.animations->size(), 1);

  const auto &animation1 = j.animations->at(0);
  auto &channel1 = animation1.channels[0];
  EXPECT_EQ(channel1.sampler, 0);
  EXPECT_EQ(channel1.target.node.value(), 2);
  EXPECT_EQ(channel1.target.path, json::AnimationChannelTarget::Path::ROTATION);
  auto &channel2 = j.animations->at(0).channels[1];
  EXPECT_EQ(channel2.sampler, 1);
  EXPECT_EQ(channel2.target.node.value(), 3);
  EXPECT_EQ(channel2.target.path,
            json::AnimationChannelTarget::Path::TRANSLATION);
  auto &sampler1 = j.animations->at(0).samplers[0];
  EXPECT_EQ(sampler1.input, 0);
  EXPECT_EQ(sampler1.interpolation,
            json::AnimationSampler::Interpolation::LINEAR);
  EXPECT_EQ(sampler1.output, 1);
  auto &sampler2 = j.animations->at(0).samplers[1];
  EXPECT_EQ(sampler2.input, 2);
  EXPECT_EQ(sampler2.interpolation,
            json::AnimationSampler::Interpolation::CUBICSPLINE);
  EXPECT_EQ(sampler2.output, 3);
}

TEST(JsonDecoder, asset) {
  const auto j = readTestJson();
  EXPECT_EQ(j.asset.copyright, "COPYRIGHT");
  EXPECT_EQ(j.asset.generator, "GENERATOR");
  EXPECT_EQ(j.asset.version, "1.0");
  EXPECT_EQ(j.asset.minVersion, "0.1");
}

TEST(JsonDecoder, buffers) {
  const auto j = readTestJson();
  EXPECT_EQ(j.buffers->size(), 1);
  EXPECT_EQ(j.buffers->at(0).uri, "buffer.bin");
  EXPECT_EQ(j.buffers->at(0).byteLength, 1024);
}

TEST(JsonDecoder, bufferViews) {
  const auto j = readTestJson();

  EXPECT_EQ(j.bufferViews->size(), 2);

  const auto &bufferView1 = j.bufferViews->at(0);
  EXPECT_EQ(bufferView1.buffer, 0);
  EXPECT_EQ(bufferView1.byteOffset, 0);
  EXPECT_EQ(bufferView1.byteLength, 512);
  EXPECT_EQ(bufferView1.byteStride, 12);
  EXPECT_EQ(bufferView1.target, 34962);

  const auto &bufferView2 = j.bufferViews->at(1);
  EXPECT_EQ(bufferView2.buffer, 0);
  EXPECT_EQ(bufferView2.byteOffset, 512);
  EXPECT_EQ(bufferView2.byteLength, 512);
  EXPECT_EQ(bufferView2.byteStride, 16);
  EXPECT_EQ(bufferView2.target, 34963);
}

TEST(JsonDecoder, cameras) {
  const auto j = readTestJson();

  EXPECT_EQ(j.cameras->size(), 2);

  const auto &camera1 = j.cameras->at(0);
  EXPECT_EQ(camera1.type, json::Camera::Type::PERSPECTIVE);
  EXPECT_EQ(camera1.perspective.value().aspectRatio, 1.333f);
  EXPECT_EQ(camera1.perspective.value().yfov, 1.0f);
  EXPECT_EQ(camera1.perspective.value().zfar, 100.0f);
  EXPECT_EQ(camera1.perspective.value().znear, 0.1f);

  const auto &camera2 = j.cameras->at(1);
  EXPECT_EQ(camera2.type, json::Camera::Type::ORTHOGRAPHIC);
  EXPECT_EQ(camera2.orthographic.value().xmag, 2.0f);
  EXPECT_EQ(camera2.orthographic.value().ymag, 2.0f);
  EXPECT_EQ(camera2.orthographic.value().zfar, 50.0f);
  EXPECT_EQ(camera2.orthographic.value().znear, 0.5f);
}

TEST(JsonDecoder, images) {
  const auto j = readTestJson();

  EXPECT_EQ(j.images->size(), 2);

  const auto &image1 = j.images->at(0);
  EXPECT_EQ(image1.uri.value(), "image1.png");
  EXPECT_EQ(image1.mimeType.value(), json::Image::MimeType::PNG);

  const auto &image2 = j.images->at(1);
  EXPECT_EQ(image2.uri.value(), "image2.jpeg");
  EXPECT_EQ(image2.mimeType.value(), json::Image::MimeType::JPEG);
}

TEST(JsonDecoder, materials) {
  const auto j = readTestJson();

  EXPECT_EQ(j.materials->size(), 3);

  const auto &material1 = j.materials->at(0);
  EXPECT_EQ(material1.name, "MaterialOne");
  std::array<float, 4> baseColorFactor{0.5, 0.5, 0.5, 1.0};
  EXPECT_EQ(j.materials->at(0).pbrMetallicRoughness->baseColorFactor.value(),
            baseColorFactor);
  EXPECT_EQ(j.materials->at(0).pbrMetallicRoughness->metallicFactor.value(),
            0.1f);
  EXPECT_EQ(material1.alphaMode, json::Material::AlphaMode::BLEND);
  EXPECT_EQ(material1.doubleSided, true);
  EXPECT_EQ(material1.isUnlit(), true);

  const auto &material2 = j.materials->at(1);
  EXPECT_EQ(material2.name, "MaterialTwo");
  EXPECT_EQ(material2.pbrMetallicRoughness->baseColorFactor, std::nullopt);
  EXPECT_EQ(material2.pbrMetallicRoughness->metallicFactor.value(), 0.3f);
  EXPECT_EQ(material2.pbrMetallicRoughness->roughnessFactor.value(), 0.4f);
  EXPECT_EQ(material2.emissiveTexture->khrTextureTransform->offset,
            (std::array<float, 2>{0, 1.0f}));
  EXPECT_EQ(material2.emissiveTexture->khrTextureTransform->rotation, 1.5f);
  EXPECT_EQ(material2.emissiveTexture->khrTextureTransform->scale,
            (std::array<float, 2>{0.5f, 0.5f}));
  EXPECT_EQ(material2.emissiveTexture->khrTextureTransform->texCoord, 1);
}

TEST(JsonDecoder, material_extensions) {
  const auto j = readTestJson();
  const auto &material = j.materials->at(2);

  EXPECT_EQ(material.anisotropy->anisotropyStrength.value(), 0.6f);
  EXPECT_EQ(material.anisotropy->anisotropyRotation.value(), 1.57f);
  EXPECT_EQ(material.anisotropy->anisotropyTexture->index, 0);
  EXPECT_EQ(material.sheen->sheenColorFactor.value(),
            (std::array<float, 3>{0.9f, 0.9f, 0.9f}));
  EXPECT_EQ(material.sheen->sheenColorTexture->index, 0);
  EXPECT_EQ(material.sheen->sheenRoughnessFactor.value(), 0.3f);
  EXPECT_EQ(material.sheen->sheenRoughnessTexture->index, 1);
  EXPECT_EQ(material.specular->specularFactor.value(), 0.3f);
  EXPECT_EQ(material.specular->specularTexture->index, 2);
  EXPECT_EQ(material.specular->specularColorFactor.value(),
            (std::array<float, 3>{0.6f, 0.7f, 0.8f}));
  EXPECT_EQ(material.specular->specularColorTexture->index, 3);
  EXPECT_EQ(material.ior->iorValue(), 1.4f);
  EXPECT_EQ(material.clearcoat->clearcoatFactorValue(), 1.0f);
  EXPECT_EQ(material.clearcoat->clearcoatTexture->index, 0);
  EXPECT_EQ(material.clearcoat->clearcoatTexture->texCoord, 0);
  EXPECT_EQ(material.clearcoat->clearcoatRoughnessFactorValue(), 0.5f);
  EXPECT_EQ(material.clearcoat->clearcoatRoughnessTexture->index, 1);
  EXPECT_EQ(material.clearcoat->clearcoatRoughnessTexture->texCoord, 0);
  EXPECT_EQ(material.clearcoat->clearcoatNormalTexture->index, 2);
  EXPECT_EQ(material.clearcoat->clearcoatNormalTexture->texCoord, 0);
  EXPECT_EQ(material.clearcoat->clearcoatNormalTexture->scaleValue(), 1.0f);
  EXPECT_EQ(material.dispersion->dispersionValue(), 0.1f);
  EXPECT_EQ(material.emissiveStrength->emissiveStrengthValue(), 5.0f);
  EXPECT_EQ(material.iridescence->iridescenceFactorValue(), 1.2f);
  EXPECT_EQ(material.iridescence->iridescenceIorValue(), 1.3f);
  EXPECT_EQ(material.iridescence->iridescenceThicknessMinimumValue(), 200.0f);
  EXPECT_EQ(material.iridescence->iridescenceThicknessMaximumValue(), 500.0f);
  EXPECT_EQ(material.transmission->transmissionFactorValue(), 1.0f);
  EXPECT_EQ(material.transmission->transmissionTexture->index, 0);
  EXPECT_EQ(material.transmission->transmissionTexture->texCoord, 0);
  EXPECT_EQ(material.volume->thicknessFactorValue(), 1.0f);
  EXPECT_EQ(material.volume->attenuationDistanceValue(), 0.006f);
  EXPECT_EQ(material.volume->attenuationColorValue(),
            (std::array<float, 3>{0.5f, 0.5f, 0.5f}));
}

TEST(JsonDecoder, meshes) {
  const auto j = readTestJson();

  EXPECT_EQ(j.meshes->size(), 1);

  const auto &mesh1 = j.meshes->at(0);
  EXPECT_EQ(mesh1.name, "MeshOne");
  EXPECT_EQ(mesh1.primitives.size(), 2);

  const auto &primitive1 = mesh1.primitives[0];
  EXPECT_EQ(primitive1.mode, json::MeshPrimitive::ModeFromInt(4));
  EXPECT_EQ(primitive1.indices, 1);
  EXPECT_EQ(primitive1.attributes.position, 0);
  EXPECT_EQ(primitive1.attributes.normal, 2);
  EXPECT_EQ(primitive1.mode, json::MeshPrimitive::ModeFromInt(4));

  const auto &primitive2 = mesh1.primitives[1];
  EXPECT_EQ(primitive2.indices, 2);
  EXPECT_EQ(primitive2.attributes.position, 1);
  EXPECT_EQ(primitive2.attributes.texcoords->size(), 2);
  EXPECT_EQ(j.meshes->at(0).primitives[1].attributes.texcoords->at(0), 3);
  EXPECT_EQ(j.meshes->at(0).primitives[1].attributes.texcoords->at(1), 4);
  EXPECT_EQ(primitive2.mode, json::MeshPrimitive::ModeFromInt(3));
}

TEST(JsonDecoder, nodes) {
  const auto j = readTestJson();
  EXPECT_EQ(j.nodes->size(), 1);

  const auto &node1 = j.nodes->at(0);
  EXPECT_EQ(node1.name, "Node 1");
  EXPECT_EQ(node1.camera.value(), 0);
  EXPECT_EQ(node1.children.value(), std::vector<uint32_t>{1});
  EXPECT_EQ(node1.skin.value(), 0);
  EXPECT_EQ(
      node1.matrix.value(),
      (std::array<float, 16>{1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f,
                             0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f}));
  EXPECT_EQ(node1.mesh.value(), 0);
  EXPECT_EQ(node1.rotation.value(),
            (std::array<float, 4>{1.0f, 1.0f, 1.0f, 1.0f}));
  EXPECT_EQ(node1.scale.value(), (std::array<float, 3>{1.0f, 1.0f, 1.0f}));
  EXPECT_EQ(node1.translation.value(),
            (std::array<float, 3>{1.0f, 1.0f, 1.0f}));
  EXPECT_EQ(node1.weights.value(), std::vector<float>({1.0f, 1.0f}));
}

TEST(JsonDecoder, textures) {
  const auto j = readTestJson();
  EXPECT_EQ(j.textures->size(), 1);
  const auto &texture1 = j.textures->at(0);
  EXPECT_EQ(texture1.sampler.value(), 0);
  EXPECT_EQ(texture1.source.value(), 0);
  EXPECT_EQ(texture1.name, "tex1");
}

TEST(JsonDecoder, scene) {
  const auto j = readTestJson();
  EXPECT_EQ(j.scene.value(), 0);
}

TEST(JsonDecoder, scenes) {
  const auto j = readTestJson();

  EXPECT_EQ(j.scenes->size(), 1);

  const auto &scene1 = j.scenes->at(0);
  EXPECT_EQ(scene1.nodes->at(0), 1);
  EXPECT_EQ(scene1.nodes->at(1), 2);
  EXPECT_EQ(scene1.name, "Scene1");
}

TEST(JsonDecoder, skins) {
  const auto j = readTestJson();
  EXPECT_EQ(j.skins->size(), 1);
  const auto &skin1 = j.skins->at(0);
  EXPECT_EQ(skin1.inverseBindMatrices.value(), 0);
  EXPECT_EQ(skin1.skeleton.value(), 1);
  EXPECT_EQ(skin1.joints.size(), 3);
  EXPECT_EQ(skin1.joints[0], 0);
  EXPECT_EQ(skin1.name, "Skin1");
}

TEST(JsonDecoder, KHR_lights_punctual) {
  const auto j = readTestJson();

  EXPECT_EQ(j.lights->size(), 1);

  const auto &light1 = j.lights->at(0);
  EXPECT_EQ(light1.type, json::KHRLight::Type::SPOT);
  EXPECT_EQ(light1.colorValue(), (std::array<float, 3>{0.0f, 0.5f, 1.0f}));
  EXPECT_EQ(light1.spot->innerConeAngleValue(), 0.78f);
  EXPECT_EQ(light1.spot->outerConeAngleValue(), 1.57f);
}
