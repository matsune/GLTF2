#include "GLTF2.h"
#include "config.h"
#include <cppcodec/base64_rfc4648.hpp>
#include <gtest/gtest.h>
#include <iostream>

using namespace gltf2;

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
          "type": "perspective",
          "perspective": {
            "aspectRatio": 1.333,
            "yfov": 1.0,
            "zfar": 100.0,
            "znear": 0.1
          }
        },
        {
          "type": "orthographic",
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
          "doubleSided": true,
          "extensions": {
              "KHR_materials_unlit": {}
          }
        },
        {
          "name": "MaterialTwo",
          "pbrMetallicRoughness": {
            "metallicFactor": 0.3,
            "roughnessFactor": 0.4
          },
          "emissiveTexture": {
            "index": 0,
            "extensions": {
              "KHR_texture_transform": {
                "offset": [0, 1],
                "rotation": 1.5,
                "scale": [0.5, 0.5],
                "texCoord": 1
              }
            }
          },
          "extensions": {
            "KHR_materials_anisotropy": {
                "anisotropyStrength": 0.6,
                "anisotropyRotation": 1.57,
                "anisotropyTexture": {
                    "index": 0
                }
            },
            "KHR_materials_sheen": {
              "sheenColorFactor": [0.9, 0.9, 0.9],
              "sheenColorTexture": {
                "index": 0
              },
              "sheenRoughnessFactor": 0.3,
              "sheenRoughnessTexture": {
                "index": 1
              }
            },
            "KHR_materials_specular": {
              "specularFactor": 0.3,
              "specularTexture": {
                "index": 2
              },
              "specularColorFactor": [0.6, 0.7, 0.8],
              "specularColorTexture": {
                "index": 3
              }
            },
            "KHR_materials_ior": {
              "ior": 1.4
            },
            "KHR_materials_clearcoat": {
              "clearcoatFactor": 1.0,
              "clearcoatTexture": {
                  "index": 0,
                  "texCoord": 0
              },
              "clearcoatRoughnessFactor": 0.5,
              "clearcoatRoughnessTexture": {
                  "index": 1,
                  "texCoord": 0
              },
              "clearcoatNormalTexture": {
                  "index": 2,
                  "texCoord": 0,
                  "scale": 1.0
              }
            },
            "KHR_materials_transmission": {
              "transmissionFactor": 1.0,
              "transmissionTexture": {
                  "index": 0,
                  "texCoord": 0
              }
            }
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
  EXPECT_EQ(channel1.target.path, GLTFAnimationChannelTarget::Path::ROTATION);
  auto &channel2 = data.json.animations.value()[0].channels[1];
  EXPECT_EQ(channel2.sampler, 1);
  EXPECT_EQ(channel2.target.node.value(), 3);
  EXPECT_EQ(channel2.target.path,
            GLTFAnimationChannelTarget::Path::TRANSLATION);
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
  EXPECT_EQ(data.json.materials.value()[0].isUnlit(), true);
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
  EXPECT_EQ(data.json.materials.value()[1]
                .emissiveTexture->khrTextureTransform->offset,
            (std::array<float, 2>{0, 1.0f}));
  EXPECT_EQ(data.json.materials.value()[1]
                .emissiveTexture->khrTextureTransform->rotation,
            1.5f);
  EXPECT_EQ(data.json.materials.value()[1]
                .emissiveTexture->khrTextureTransform->scale,
            (std::array<float, 2>{0.5f, 0.5f}));
  EXPECT_EQ(data.json.materials.value()[1]
                .emissiveTexture->khrTextureTransform->texCoord,
            1);
  EXPECT_EQ(
      data.json.materials.value()[1].anisotropy->anisotropyStrength.value(),
      0.6f);
  EXPECT_EQ(
      data.json.materials.value()[1].anisotropy->anisotropyRotation.value(),
      1.57f);
  EXPECT_EQ(data.json.materials.value()[1].anisotropy->anisotropyTexture->index,
            0);
  EXPECT_EQ(data.json.materials.value()[1].sheen->sheenColorFactor.value(),
            (std::array<float, 3>{0.9f, 0.9f, 0.9f}));
  EXPECT_EQ(data.json.materials.value()[1].sheen->sheenColorTexture->index, 0);
  EXPECT_EQ(data.json.materials.value()[1].sheen->sheenRoughnessFactor.value(),
            0.3f);
  EXPECT_EQ(data.json.materials.value()[1].sheen->sheenRoughnessTexture->index,
            1);
  EXPECT_EQ(data.json.materials.value()[1].specular->specularFactor.value(),
            0.3f);
  EXPECT_EQ(data.json.materials.value()[1].specular->specularTexture->index, 2);
  EXPECT_EQ(
      data.json.materials.value()[1].specular->specularColorFactor.value(),
      (std::array<float, 3>{0.6f, 0.7f, 0.8f}));
  EXPECT_EQ(
      data.json.materials.value()[1].specular->specularColorTexture->index, 3);
  EXPECT_EQ(data.json.materials.value()[1].ior->iorValue(), 1.4f);
  EXPECT_EQ(data.json.materials.value()[1].clearcoat->clearcoatFactorValue(),
            1.0f);
  EXPECT_EQ(data.json.materials.value()[1].clearcoat->clearcoatTexture->index,
            0);
  EXPECT_EQ(
      data.json.materials.value()[1].clearcoat->clearcoatTexture->texCoord, 0);
  EXPECT_EQ(
      data.json.materials.value()[1].clearcoat->clearcoatRoughnessFactorValue(),
      0.5f);
  EXPECT_EQ(data.json.materials.value()[1]
                .clearcoat->clearcoatRoughnessTexture->index,
            1);
  EXPECT_EQ(data.json.materials.value()[1]
                .clearcoat->clearcoatRoughnessTexture->texCoord,
            0);
  EXPECT_EQ(
      data.json.materials.value()[1].clearcoat->clearcoatNormalTexture->index,
      2);
  EXPECT_EQ(data.json.materials.value()[1]
                .clearcoat->clearcoatNormalTexture->texCoord,
            0);
  EXPECT_EQ(data.json.materials.value()[1]
                .clearcoat->clearcoatNormalTexture->scaleValue(),
            1.0f);
  EXPECT_EQ(
      data.json.materials.value()[1].transmission->transmissionFactorValue(),
      1.0f);
  EXPECT_EQ(
      data.json.materials.value()[1].transmission->transmissionTexture->index,
      0);
  EXPECT_EQ(data.json.materials.value()[1]
                .transmission->transmissionTexture->texCoord,
            0);

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
  EXPECT_EQ(
      data.json.nodes.value()[0].matrix.value(),
      (std::array<float, 16>{1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f,
                             0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f}));
  EXPECT_EQ(data.json.nodes.value()[0].mesh.value(), 0);
  EXPECT_EQ(data.json.nodes.value()[0].rotation.value(),
            (std::array<float, 4>{1.0f, 1.0f, 1.0f, 1.0f}));
  EXPECT_EQ(data.json.nodes.value()[0].scale.value(),
            (std::array<float, 3>{1.0f, 1.0f, 1.0f}));
  EXPECT_EQ(data.json.nodes.value()[0].translation.value(),
            (std::array<float, 3>{1.0f, 1.0f, 1.0f}));
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

TEST(TestGLTFData, dataForBufferView) {
  std::filesystem::path root(PROJECT_SOURCE_DIR);
  auto path = root / "sample-models/a/a.gltf";
  auto data = gltf2::GLTFData::parseFile(path);
  auto buf = data.dataForBufferView(0);
  EXPECT_EQ(buf, std::vector<uint8_t>({0, 1, 2, 3}));

  buf = data.dataForBufferView(1);
  EXPECT_EQ(buf, std::vector<uint8_t>({4, 5, 6, 7, 8, 9}));

  // absolute path
  data.json.buffers->at(0).uri = root / "sample-models/a/a.bin";
  buf = data.dataForBufferView(0);
  EXPECT_EQ(buf, std::vector<uint8_t>({0, 1, 2, 3}));
}

TEST(TestGLTFData, dataForAccessor) {
  // vec2<uint8_t> { 'a', 'b' }
  auto encoded = cppcodec::base64_rfc4648::encode({'a', 'b'});
  auto rawJson = R"(
    {
      "asset": { "version": "1.0" },
      "accessors": [
        {
          "bufferView": 0,
          "byteOffset": 0,
          "componentType": 5121,
          "count": 1,
          "type": "VEC2"
        }
      ],
      "bufferViews": [
        {
          "buffer": 0,
          "byteOffset": 0,
          "byteLength": 2
        }
      ],
      "buffers": [
        {
          "byteLength": 2,
          "uri": "data:base64,)" +
                 encoded + R"("
        }
      ]
    }
  )";
  auto gltf = gltf2::GLTFData::parseJson(rawJson);
  bool normalized = false;
  auto data = gltf.dataForAccessor(gltf.json.accessors->at(0), &normalized);
  EXPECT_FALSE(normalized);
  EXPECT_EQ(data.size(), 2);
  EXPECT_EQ(data[0], 'a');
  EXPECT_EQ(data[1], 'b');
}

TEST(TestGLTFData, dataForAccessorWithNormalized) {
  // vec2<uint8_t> { 'a', 'b' }
  auto rawJson = R"(
    {
      "asset": { "version": "1.0" },
      "accessors": [
        {
          "bufferView": 0,
          "byteOffset": 0,
          "componentType": 5121,
          "count": 1,
          "type": "VEC2",
          "normalized": true
        }
      ],
      "bufferViews": [
        {
          "buffer": 0,
          "byteOffset": 0,
          "byteLength": 2
        }
      ],
      "buffers": [
        {
          "byteLength": 2,
          "uri": "data:base64,YWI="
        }
      ]
    }
  )";
  auto gltf = gltf2::GLTFData::parseJson(rawJson);
  bool normalized = false;
  auto data = gltf.dataForAccessor(gltf.json.accessors->at(0), &normalized);
  EXPECT_TRUE(normalized);
  EXPECT_EQ(data.size(), sizeof(float) * 2);
  EXPECT_EQ(((float *)data.data())[0], (float)'a' / (float)UINT8_MAX);
  EXPECT_EQ(((float *)data.data())[1], (float)'b' / (float)UINT8_MAX);
}

TEST(TestGLTFData, dataForAccessorWithSparse) {
  // buffer data: uint8_t[3] {0x00, 0x00, 0x20}
  // indices: 0, values: 0x20
  auto encoded = cppcodec::base64_rfc4648::encode({0x00, 0x00, 0x20});
  auto rawJson = R"(
    {
      "asset": { "version": "1.0" },
      "accessors": [
        {
          "bufferView": 0,
          "byteOffset": 0,
          "componentType": 5121,
          "count": 1,
          "type": "SCALAR",
          "sparse": {
            "count": 1,
            "indices": {
              "bufferView": 0,
              "byteOffset": 0,
              "componentType": 5123
            },
            "values": {
              "bufferView": 0,
              "byteOffset": 2
            }
          }
        }
      ],
      "bufferViews": [
        {
          "buffer": 0,
          "byteOffset": 0,
          "byteLength": 3
        }
      ],
      "buffers": [
        {
          "byteLength": 3,
          "uri": "data:base64,)" +
                 encoded + R"("
        }
      ]
    }
  )";
  auto gltf = gltf2::GLTFData::parseJson(rawJson);
  bool normalized = false;
  auto data = gltf.dataForAccessor(gltf.json.accessors->at(0), &normalized);
  EXPECT_FALSE(normalized);
  EXPECT_EQ(data.size(), 1);
  EXPECT_EQ(data[0], 0x20);
}

TEST(TestGLTFData, dataForAccessorWithByteStride) {
  // stride is 16 but each data is vec3<float>
  float bufferData[10 * 4 * 4] = {0};
  for (int i = 0; i < 10; ++i) {
    bufferData[i * 4] = (float)i;
    bufferData[i * 4 + 1] = (float)i + 1;
    bufferData[i * 4 + 2] = (float)i + 2;
  }
  auto encoded = cppcodec::base64_rfc4648::encode(bufferData);
  auto rawJson = R"(
    {
      "asset": { "version": "1.0" },
      "accessors": [
        {
          "bufferView": 0,
          "byteOffset": 0,
          "componentType": 5126,
          "count": 10,
          "type": "VEC3"
        }
      ],
      "bufferViews": [
        {
          "buffer": 0,
          "byteOffset": 0,
          "byteLength": 156,
          "byteStride": 16
        }
      ],
      "buffers": [
        {
          "byteLength": 160,
          "uri": "data:base64,)" +
                 encoded + R"("
        }
      ]
    }
  )";
  auto gltf = gltf2::GLTFData::parseJson(rawJson);
  bool normalized = false;
  auto data = gltf.dataForAccessor(gltf.json.accessors->at(0), &normalized);
  EXPECT_FALSE(normalized);
  EXPECT_EQ(data.size(), 4 * 3 * 10);
  float *floatArray = (float *)data.data();
  for (int i = 0; i < 10; ++i) {
    int baseIndex = i * 3;
    EXPECT_EQ(floatArray[baseIndex], (float)i);
    EXPECT_EQ(floatArray[baseIndex + 1], (float)i + 1);
    EXPECT_EQ(floatArray[baseIndex + 2], (float)i + 2);
  }
}

TEST(TestGLTFData, meshPrimitive) {
  // bufferViews[0]: vec3<float, 1>
  // bufferViews[1]: vec3<float, 1>
  // bufferViews[2]: vec2<float, 1>
  // bufferViews[3]: uint16_t
  std::vector<float> bufs = {// bufferViews[0]
                             0.0f, -1.0f, 1.0f,
                             // bufferViews[1]
                             1.0f, 1.0f, 0.0f,
                             // bufferViews[2]
                             0.1f, 1.1f};
  // bufferViews[3]
  uint16_t b3 = 2;

  std::vector<uint8_t> bin(sizeof(float) * 8 + sizeof(uint16_t));
  std::memcpy(bin.data(), bufs.data(), sizeof(float) * 8);
  std::memcpy(bin.data() + sizeof(float) * 8, &b3, sizeof(uint16_t));

  auto rawJson = R"(
    {
      "asset": { "version": "1.0" },
      "meshes": [
        {
          "primitives": [
            {
              "attributes": {
                "POSITION": 0,
                "NORMAL": 1,
                "TEXCOORD_0": 2
              },
              "indices": 3,
              "mode": 4
            }
          ]
        }
      ],
      "accessors": [
        {
          "bufferView": 0,
          "componentType": 5126,
          "count": 1,
          "type": "VEC3",
          "max": [1.0, 1.0, 1.0],
          "min": [-1.0, -1.0, -1.0]
        },
        {
          "bufferView": 1,
          "componentType": 5126,
          "count": 1,
          "type": "VEC3"
        },
        {
          "bufferView": 2,
          "componentType": 5126,
          "count": 1,
          "type": "VEC2"
        },
        {
          "bufferView": 3,
          "componentType": 5123,
          "count": 1,
          "type": "SCALAR"
        }
      ],
      "bufferViews": [
        {
          "buffer": 0,
          "byteOffset": 0,
          "byteLength": 12
        },
        {
          "buffer": 0,
          "byteOffset": 12,
          "byteLength": 12
        },
        {
          "buffer": 0,
          "byteOffset": 24,
          "byteLength": 8
        },
        {
          "buffer": 0,
          "byteOffset": 32,
          "byteLength": 2
        }
      ],
      "buffers": [
        {
          "byteLength": 34
        }
      ]
    }
  )";
  auto gltf = gltf2::GLTFData::parseJson(rawJson);
  gltf.bin = bin;

  auto meshPrimitive =
      gltf.meshPrimitiveFromPrimitive(gltf.json.meshes->at(0).primitives.at(0));

  // position
  EXPECT_EQ(((float *)meshPrimitive.sources.position->data.data())[0], bufs[0]);
  EXPECT_EQ(((float *)meshPrimitive.sources.position->data.data())[1], bufs[1]);
  EXPECT_EQ(((float *)meshPrimitive.sources.position->data.data())[2], bufs[2]);
  EXPECT_EQ(meshPrimitive.sources.position->vectorCount, 1);
  EXPECT_EQ(meshPrimitive.sources.position->componentType,
            GLTFAccessor::ComponentType::FLOAT);
  EXPECT_EQ(meshPrimitive.sources.position->componentsPerVector, 3);

  // normal
  EXPECT_EQ(((float *)meshPrimitive.sources.normal->data.data())[0], bufs[3]);
  EXPECT_EQ(((float *)meshPrimitive.sources.normal->data.data())[1], bufs[4]);
  EXPECT_EQ(((float *)meshPrimitive.sources.normal->data.data())[2], bufs[5]);
  EXPECT_EQ(meshPrimitive.sources.normal->vectorCount, 1);
  EXPECT_EQ(meshPrimitive.sources.normal->componentType,
            GLTFAccessor::ComponentType::FLOAT);
  EXPECT_EQ(meshPrimitive.sources.normal->componentsPerVector, 3);

  // texcoord
  EXPECT_EQ(((float *)meshPrimitive.sources.texcoords[0].data.data())[0],
            bufs[6]);
  EXPECT_EQ(((float *)meshPrimitive.sources.texcoords[0].data.data())[1],
            bufs[7]);
  EXPECT_EQ(meshPrimitive.sources.texcoords[0].vectorCount, 1);
  EXPECT_EQ(meshPrimitive.sources.texcoords[0].componentType,
            GLTFAccessor::ComponentType::FLOAT);
  EXPECT_EQ(meshPrimitive.sources.texcoords[0].componentsPerVector, 2);

  // indices
  EXPECT_EQ(((uint16_t *)meshPrimitive.element->data.data())[0], b3);
  EXPECT_EQ(meshPrimitive.element->primitiveMode,
            GLTFMeshPrimitive::Mode::TRIANGLES);
  EXPECT_EQ(meshPrimitive.element->componentType,
            GLTFAccessor::ComponentType::UNSIGNED_SHORT);
}
