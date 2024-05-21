#include "GLTF2Core.h"
#include "config.h"
#include <gtest/gtest.h>
#include <iostream>

using namespace gltf2;

TEST(TestGLTFData, parseGLTF) {
  std::filesystem::path root(PROJECT_SOURCE_DIR);
  auto path = root / "sample-models/a/a.gltf";
  auto data = gltf2::GLTFData::parseFile(path);
  auto buf = data.dataForBufferView(data.json.bufferViews->at(0));
  EXPECT_EQ(buf, std::vector<uint8_t>({0, 1, 2, 3}));

  buf = data.dataForBufferView(data.json.bufferViews->at(1));
  EXPECT_EQ(buf, std::vector<uint8_t>({4, 5, 6, 7, 8, 9}));
  
  // absolute path
  data.json.buffers->at(0).uri = root / "sample-models/a/a.bin";
  buf = data.dataForBufferView(data.json.bufferViews->at(0));
  EXPECT_EQ(buf, std::vector<uint8_t>({0, 1, 2, 3}));
}

TEST(TestGLTFData, parseJson) {
  auto rawJson = R"(
    {
      "extensionsUsed": ["ext1", "ext2"],
      "extensionsRequired": ["ext1"],
      "accessors": [
        {
          "bufferView": 0,
          "byteOffset": 0,
          "componentType": 5123,
          "normalized": false,
          "count": 3,
          "type": "VEC3",
          "max": [1, 1, 1],
          "min": [-1, -1, -1]
        },
        {
          "bufferView": 1,
          "byteOffset": 24,
          "componentType": 5125,
          "normalized": true,
          "count": 3,
          "type": "SCALAR",
          "sparse": {
            "count": 2,
            "indices": {
              "bufferView": 3,
              "byteOffset": 0,
              "componentType": 5123
            },
            "values": {
              "bufferView": 4,
              "byteOffset": 8
            }
          }
        }
      ],
      "animations": [
        {
          "name": "WaveAnimation",
          "channels": [
            {
              "sampler": 0,
              "target": {
                "node": 2,
                "path": "rotation"
              }
            },
            {
              "sampler": 1,
              "target": {
                "node": 3,
                "path": "translation"
              }
            }
          ],
          "samplers": [
            {
              "input": 0,
              "interpolation": "LINEAR",
              "output": 1
            },
            {
              "input": 2,
              "interpolation": "CUBICSPLINE",
              "output": 3
            }
          ]
        }
      ],
      "asset": {
        "copyright": "COPYRIGHT",
        "generator": "GENERATOR",
        "version": "1.0",
        "minVersion": "0.1"
      },
      "buffers": [
        {
          "uri": "buffer.bin",
          "byteLength": 1024
        }
      ],
      "bufferViews": [
        {
          "buffer": 0,
          "byteOffset": 0,
          "byteLength": 512,
          "byteStride": 12,
          "target": 34962
        },
        {
          "buffer": 0,
          "byteOffset": 512,
          "byteLength": 512,
          "byteStride": 16,
          "target": 34963
        }
      ],
      "cameras": [
        {
          "type": "PERSPECTIVE",
          "perspective": {
            "aspectRatio": 1.333,
            "yfov": 1.0,
            "zfar": 100.0,
            "znear": 0.1
          }
        },
        {
          "type": "ORTHOGRAPHIC",
          "orthographic": {
            "xmag": 2.0,
            "ymag": 2.0,
            "zfar": 50.0,
            "znear": 0.5
          }
        }
      ],
      "images": [
        {
          "uri": "image1.png",
          "mimeType": "image/png"
        },
        {
          "uri": "image2.jpeg",
          "mimeType": "image/jpeg"
        }
      ],
      "materials": [
        {
          "name": "MaterialOne",
          "pbrMetallicRoughness": {
            "baseColorFactor": [0.5, 0.5, 0.5, 1.0],
            "metallicFactor": 0.1
          },
          "alphaMode": "BLEND",
          "doubleSided": true
        },
        {
          "name": "MaterialTwo",
          "pbrMetallicRoughness": {
            "metallicFactor": 0.3,
            "roughnessFactor": 0.4
          }
        }
      ],
      "meshes": [
        {
          "name": "MeshOne",
          "primitives": [
            {
              "mode": 4,
              "indices": 1,
              "attributes": {
                "POSITION": 0,
                "NORMAL": 2
              }
            },
            {
              "mode": 3,
              "indices": 2,
              "attributes": {
                "POSITION": 1,
                "TEXCOORD_0": 3,
                "TEXCOORD_1": 4
              }
            }
          ]
        }
      ],
      "nodes": [
        {
          "camera": 0,
          "children": [1],
          "skin": 0,
          "matrix": [1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1],
          "mesh": 0,
          "rotation": [1.0, 1.0, 1.0, 1.0],
          "scale": [1.0, 1.0, 1.0],
          "translation": [1.0, 1.0, 1.0],
          "weights": [1.0, 1.0],
          "name": "Node 1"
        }
      ],
      "textures": [
        {
          "sampler": 0,
          "source": 0,
          "name": "tex1"
        }
      ],
      "scene": 0,
      "scenes": [
        {
          "nodes": [1, 2],
          "name": "Scene1"
        }
      ],
      "skins": [
        {
          "inverseBindMatrices": 0,
          "skeleton": 1,
          "joints": [0, 2, 3],
          "name": "Skin1"
        }
      ],
      "samplers": [
        {
          "magFilter": 9729,
          "minFilter": 9728,
          "wrapS": 33071,
          "wrapT": 10497,
          "name": "Sampler1"
        }
      ]
    }
  )";
  auto data = gltf2::GLTFData::parseJson(rawJson);

  EXPECT_EQ(data.json.extensionsUsed->size(), 2);
  EXPECT_EQ(data.json.extensionsUsed.value()[0], "ext1");
  EXPECT_EQ(data.json.extensionsUsed.value()[1], "ext2");
  EXPECT_EQ(data.json.extensionsRequired->size(), 1);
  EXPECT_EQ(data.json.extensionsRequired.value()[0], "ext1");

  EXPECT_EQ(data.json.accessors.value().size(), 2);
  auto &accessor1 = data.json.accessors.value()[0];
  EXPECT_EQ(accessor1.bufferView, 0);
  EXPECT_EQ(accessor1.byteOffset, 0);
  EXPECT_EQ(accessor1.componentType,
            GLTFAccessor::ComponentType::UNSIGNED_SHORT);
  EXPECT_EQ(accessor1.normalized, false);
  EXPECT_EQ(accessor1.count, 3);
  EXPECT_EQ(accessor1.type, GLTFAccessor::Type::VEC3);
  EXPECT_EQ(accessor1.max.value(), std::vector<float>({1, 1, 1}));
  EXPECT_EQ(accessor1.min.value(), std::vector<float>({-1, -1, -1}));
  auto &accessor2 = data.json.accessors.value()[1];
  EXPECT_EQ(accessor2.bufferView, 1);
  EXPECT_EQ(accessor2.byteOffset, 24);
  EXPECT_EQ(accessor2.componentType, GLTFAccessor::ComponentType::UNSIGNED_INT);
  EXPECT_EQ(accessor2.normalized, true);
  EXPECT_EQ(accessor2.count, 3);
  EXPECT_EQ(accessor2.type, GLTFAccessor::Type::SCALAR);
  EXPECT_TRUE(accessor2.sparse.has_value());
  auto &sparse = accessor2.sparse.value();
  EXPECT_EQ(sparse.count, 2);
  EXPECT_EQ(sparse.indices.bufferView, 3);
  EXPECT_EQ(sparse.indices.byteOffset, 0);
  EXPECT_EQ(sparse.indices.componentType,
            GLTFAccessorSparseIndices::ComponentType::UNSIGNED_SHORT);
  EXPECT_EQ(sparse.values.bufferView, 4);
  EXPECT_EQ(sparse.values.byteOffset, 8);

  auto &channel1 = data.json.animations.value()[0].channels[0];
  EXPECT_EQ(channel1.sampler, 0);
  EXPECT_EQ(channel1.target.node.value(), 2);
  EXPECT_EQ(channel1.target.path, "rotation");
  auto &channel2 = data.json.animations.value()[0].channels[1];
  EXPECT_EQ(channel2.sampler, 1);
  EXPECT_EQ(channel2.target.node.value(), 3);
  EXPECT_EQ(channel2.target.path, "translation");
  auto &sampler1 = data.json.animations.value()[0].samplers[0];
  EXPECT_EQ(sampler1.input, 0);
  EXPECT_EQ(sampler1.interpolation,
            GLTFAnimationSampler::Interpolation::LINEAR);
  EXPECT_EQ(sampler1.output, 1);
  auto &sampler2 = data.json.animations.value()[0].samplers[1];
  EXPECT_EQ(sampler2.input, 2);
  EXPECT_EQ(sampler2.interpolation,
            GLTFAnimationSampler::Interpolation::CUBICSPLINE);
  EXPECT_EQ(sampler2.output, 3);

  EXPECT_EQ(data.json.buffers.value().size(), 1);
  EXPECT_EQ(data.json.buffers.value()[0].uri, "buffer.bin");
  EXPECT_EQ(data.json.buffers.value()[0].byteLength, 1024);

  EXPECT_EQ(data.json.bufferViews.value().size(), 2);
  EXPECT_EQ(data.json.bufferViews.value()[0].buffer, 0);
  EXPECT_EQ(data.json.bufferViews.value()[0].byteOffset, 0);
  EXPECT_EQ(data.json.bufferViews.value()[0].byteLength, 512);
  EXPECT_EQ(data.json.bufferViews.value()[0].byteStride, 12);
  EXPECT_EQ(data.json.bufferViews.value()[0].target, 34962);

  EXPECT_EQ(data.json.bufferViews.value()[1].buffer, 0);
  EXPECT_EQ(data.json.bufferViews.value()[1].byteOffset, 512);
  EXPECT_EQ(data.json.bufferViews.value()[1].byteLength, 512);
  EXPECT_EQ(data.json.bufferViews.value()[1].byteStride, 16);
  EXPECT_EQ(data.json.bufferViews.value()[1].target, 34963);

  EXPECT_EQ(data.json.asset.copyright, "COPYRIGHT");
  EXPECT_EQ(data.json.asset.generator, "GENERATOR");
  EXPECT_EQ(data.json.asset.version, "1.0");
  EXPECT_EQ(data.json.asset.minVersion, "0.1");

  EXPECT_EQ(data.json.cameras.value().size(), 2);
  EXPECT_EQ(data.json.cameras.value()[0].type, GLTFCamera::Type::PERSPECTIVE);
  EXPECT_EQ(data.json.cameras.value()[0].perspective.value().aspectRatio,
            1.333f);
  EXPECT_EQ(data.json.cameras.value()[0].perspective.value().yfov, 1.0f);
  EXPECT_EQ(data.json.cameras.value()[0].perspective.value().zfar, 100.0f);
  EXPECT_EQ(data.json.cameras.value()[0].perspective.value().znear, 0.1f);
  EXPECT_EQ(data.json.cameras.value()[1].type, GLTFCamera::Type::ORTHOGRAPHIC);
  EXPECT_EQ(data.json.cameras.value()[1].orthographic.value().xmag, 2.0f);
  EXPECT_EQ(data.json.cameras.value()[1].orthographic.value().ymag, 2.0f);
  EXPECT_EQ(data.json.cameras.value()[1].orthographic.value().zfar, 50.0f);
  EXPECT_EQ(data.json.cameras.value()[1].orthographic.value().znear, 0.5f);

  EXPECT_EQ(data.json.images.value().size(), 2);
  EXPECT_EQ(data.json.images.value()[0].uri.value(), "image1.png");
  EXPECT_EQ(data.json.images.value()[0].mimeType.value(),
            GLTFImage::MimeType::PNG);
  EXPECT_EQ(data.json.images.value()[1].uri.value(), "image2.jpeg");
  EXPECT_EQ(data.json.images.value()[1].mimeType.value(),
            GLTFImage::MimeType::JPEG);

  EXPECT_EQ(data.json.materials.value().size(), 2);
  EXPECT_EQ(data.json.materials.value()[0].name, "MaterialOne");
  std::array<float, 4> baseColorFactor{0.5, 0.5, 0.5, 1.0};
  EXPECT_EQ(data.json.materials.value()[0]
                .pbrMetallicRoughness->baseColorFactor.value(),
            baseColorFactor);
  EXPECT_EQ(data.json.materials.value()[0]
                .pbrMetallicRoughness->metallicFactor.value(),
            0.1f);
  EXPECT_EQ(data.json.materials.value()[0].alphaMode,
            GLTFMaterial::AlphaMode::BLEND);
  EXPECT_EQ(data.json.materials.value()[0].doubleSided, true);
  EXPECT_EQ(data.json.materials.value()[1].name, "MaterialTwo");
  EXPECT_EQ(
      data.json.materials.value()[1].pbrMetallicRoughness->baseColorFactor,
      std::nullopt);
  EXPECT_EQ(data.json.materials.value()[1]
                .pbrMetallicRoughness->metallicFactor.value(),
            0.3f);
  EXPECT_EQ(data.json.materials.value()[1]
                .pbrMetallicRoughness->roughnessFactor.value(),
            0.4f);

  EXPECT_EQ(data.json.meshes.value().size(), 1);
  EXPECT_EQ(data.json.meshes.value()[0].name, "MeshOne");
  EXPECT_EQ(data.json.meshes.value()[0].primitives.size(), 2);
  EXPECT_EQ(data.json.meshes.value()[0].primitives[0].mode,
            GLTFMeshPrimitive::ModeFromInt(4));
  EXPECT_EQ(data.json.meshes.value()[0].primitives[0].indices, 1);
  EXPECT_EQ(data.json.meshes.value()[0].primitives[0].attributes.position, 0);
  EXPECT_EQ(data.json.meshes.value()[0].primitives[0].attributes.normal, 2);
  EXPECT_EQ(data.json.meshes.value()[0].primitives[0].mode,
            GLTFMeshPrimitive::ModeFromInt(4));
  EXPECT_EQ(data.json.meshes.value()[0].primitives[1].indices, 2);
  EXPECT_EQ(data.json.meshes.value()[0].primitives[1].attributes.position, 1);
  EXPECT_EQ(
      data.json.meshes.value()[0].primitives[1].attributes.texcoords->size(),
      2);
  EXPECT_EQ(
      data.json.meshes.value()[0].primitives[1].attributes.texcoords.value()[0],
      3);
  EXPECT_EQ(
      data.json.meshes.value()[0].primitives[1].attributes.texcoords.value()[1],
      4);
  EXPECT_EQ(data.json.meshes.value()[0].primitives[1].mode,
            GLTFMeshPrimitive::ModeFromInt(3));

  EXPECT_EQ(data.json.nodes.value().size(), 1);
  EXPECT_EQ(data.json.nodes.value()[0].name, "Node 1");
  EXPECT_EQ(data.json.nodes.value()[0].camera.value(), 0);
  EXPECT_EQ(data.json.nodes.value()[0].children.value(),
            std::vector<uint32_t>{1});
  EXPECT_EQ(data.json.nodes.value()[0].skin.value(), 0);
  std::array<float, 16> matrix{1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f,
                               0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f};
  EXPECT_EQ(data.json.nodes.value()[0].matrix.value(), matrix);
  EXPECT_EQ(data.json.nodes.value()[0].mesh.value(), 0);
  std::array<float, 4> rotation{1.0f, 1.0f, 1.0f, 1.0f};
  std::array<float, 3> scale{1.0f, 1.0f, 1.0f};
  std::array<float, 3> translation{1.0f, 1.0f, 1.0f};
  EXPECT_EQ(data.json.nodes.value()[0].rotation.value(), rotation);
  EXPECT_EQ(data.json.nodes.value()[0].scale.value(), scale);
  EXPECT_EQ(data.json.nodes.value()[0].translation.value(), translation);
  EXPECT_EQ(data.json.nodes.value()[0].weights.value(),
            std::vector<float>({1.0f, 1.0f}));

  EXPECT_EQ(data.json.textures.value().size(), 1);
  EXPECT_EQ(data.json.textures.value()[0].sampler.value(), 0);
  EXPECT_EQ(data.json.textures.value()[0].source.value(), 0);
  EXPECT_EQ(data.json.textures.value()[0].name, "tex1");

  EXPECT_EQ(data.json.scene.value(), 0);

  EXPECT_EQ(data.json.scenes.value().size(), 1);
  EXPECT_EQ(data.json.scenes.value()[0].nodes.value()[0], 1);
  EXPECT_EQ(data.json.scenes.value()[0].nodes.value()[1], 2);
  EXPECT_EQ(data.json.scenes.value()[0].name, "Scene1");

  EXPECT_EQ(data.json.skins.value().size(), 1);
  EXPECT_EQ(data.json.skins.value()[0].inverseBindMatrices.value(), 0);
  EXPECT_EQ(data.json.skins.value()[0].skeleton.value(), 1);
  EXPECT_EQ(data.json.skins.value()[0].joints.size(), 3);
  EXPECT_EQ(data.json.skins.value()[0].joints[0], 0);
  EXPECT_EQ(data.json.skins.value()[0].name, "Skin1");
}
