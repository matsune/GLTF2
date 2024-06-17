#include "GLTF2.h"
#include "config.h"
#include <cppcodec/base64_rfc4648.hpp>
#include <gtest/gtest.h>
#include <iostream>

using namespace gltf2;

TEST(TestGLTFData, parseStream) {
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
            "KHR_materials_dispersion": {
              "dispersion": 0.1
            },
            "KHR_materials_emissive_strength": {
              "emissiveStrength": 5.0
            },
            "KHR_materials_iridescence": {
              "iridescenceFactor": 1.2,
              "iridescenceIor": 1.3,
              "iridescenceThicknessMinimum": 200.0,
              "iridescenceThicknessMaximum": 500.0
            },
            "KHR_materials_transmission": {
              "transmissionFactor": 1.0,
              "transmissionTexture": {
                  "index": 0,
                  "texCoord": 0
              }
            },
            "KHR_materials_volume": {
              "thicknessFactor": 1.0,
              "attenuationDistance":  0.006,
              "attenuationColor": [ 0.5, 0.5, 0.5 ]
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
      ],
      "extensions": {
        "KHR_lights_punctual" : {
          "lights": [
            {
              "spot": {
                  "innerConeAngle": 0.78,
                  "outerConeAngle": 1.57
              },
              "color": [
                  0.0,
                  0.5,
                  1.0
              ],
              "type": "spot"
            }
          ]
        }
      }
    }
  )";
  auto data = GLTFFile::parseStream(std::istringstream(rawJson));

  EXPECT_EQ(data.json().extensionsUsed->size(), 2);
  EXPECT_EQ(data.json().extensionsUsed.value()[0], "ext1");
  EXPECT_EQ(data.json().extensionsUsed.value()[1], "ext2");
  EXPECT_EQ(data.json().extensionsRequired->size(), 1);
  EXPECT_EQ(data.json().extensionsRequired.value()[0], "ext1");

  EXPECT_EQ(data.json().accessors.value().size(), 2);
  auto &accessor1 = data.json().accessors.value()[0];
  EXPECT_EQ(accessor1.bufferView, 0);
  EXPECT_EQ(accessor1.byteOffset, 0);
  EXPECT_EQ(accessor1.componentType,
            json::Accessor::ComponentType::UNSIGNED_SHORT);
  EXPECT_EQ(accessor1.normalized, false);
  EXPECT_EQ(accessor1.count, 3);
  EXPECT_EQ(accessor1.type, json::Accessor::Type::VEC3);
  EXPECT_EQ(accessor1.max.value(), std::vector<float>({1, 1, 1}));
  EXPECT_EQ(accessor1.min.value(), std::vector<float>({-1, -1, -1}));
  auto &accessor2 = data.json().accessors.value()[1];
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

  auto &channel1 = data.json().animations.value()[0].channels[0];
  EXPECT_EQ(channel1.sampler, 0);
  EXPECT_EQ(channel1.target.node.value(), 2);
  EXPECT_EQ(channel1.target.path, json::AnimationChannelTarget::Path::ROTATION);
  auto &channel2 = data.json().animations.value()[0].channels[1];
  EXPECT_EQ(channel2.sampler, 1);
  EXPECT_EQ(channel2.target.node.value(), 3);
  EXPECT_EQ(channel2.target.path,
            json::AnimationChannelTarget::Path::TRANSLATION);
  auto &sampler1 = data.json().animations.value()[0].samplers[0];
  EXPECT_EQ(sampler1.input, 0);
  EXPECT_EQ(sampler1.interpolation,
            json::AnimationSampler::Interpolation::LINEAR);
  EXPECT_EQ(sampler1.output, 1);
  auto &sampler2 = data.json().animations.value()[0].samplers[1];
  EXPECT_EQ(sampler2.input, 2);
  EXPECT_EQ(sampler2.interpolation,
            json::AnimationSampler::Interpolation::CUBICSPLINE);
  EXPECT_EQ(sampler2.output, 3);

  EXPECT_EQ(data.json().buffers.value().size(), 1);
  EXPECT_EQ(data.json().buffers.value()[0].uri, "buffer.bin");
  EXPECT_EQ(data.json().buffers.value()[0].byteLength, 1024);

  EXPECT_EQ(data.json().bufferViews.value().size(), 2);
  EXPECT_EQ(data.json().bufferViews.value()[0].buffer, 0);
  EXPECT_EQ(data.json().bufferViews.value()[0].byteOffset, 0);
  EXPECT_EQ(data.json().bufferViews.value()[0].byteLength, 512);
  EXPECT_EQ(data.json().bufferViews.value()[0].byteStride, 12);
  EXPECT_EQ(data.json().bufferViews.value()[0].target, 34962);

  EXPECT_EQ(data.json().bufferViews.value()[1].buffer, 0);
  EXPECT_EQ(data.json().bufferViews.value()[1].byteOffset, 512);
  EXPECT_EQ(data.json().bufferViews.value()[1].byteLength, 512);
  EXPECT_EQ(data.json().bufferViews.value()[1].byteStride, 16);
  EXPECT_EQ(data.json().bufferViews.value()[1].target, 34963);

  EXPECT_EQ(data.json().asset.copyright, "COPYRIGHT");
  EXPECT_EQ(data.json().asset.generator, "GENERATOR");
  EXPECT_EQ(data.json().asset.version, "1.0");
  EXPECT_EQ(data.json().asset.minVersion, "0.1");

  EXPECT_EQ(data.json().cameras.value().size(), 2);
  EXPECT_EQ(data.json().cameras.value()[0].type,
            json::Camera::Type::PERSPECTIVE);
  EXPECT_EQ(data.json().cameras.value()[0].perspective.value().aspectRatio,
            1.333f);
  EXPECT_EQ(data.json().cameras.value()[0].perspective.value().yfov, 1.0f);
  EXPECT_EQ(data.json().cameras.value()[0].perspective.value().zfar, 100.0f);
  EXPECT_EQ(data.json().cameras.value()[0].perspective.value().znear, 0.1f);
  EXPECT_EQ(data.json().cameras.value()[1].type,
            json::Camera::Type::ORTHOGRAPHIC);
  EXPECT_EQ(data.json().cameras.value()[1].orthographic.value().xmag, 2.0f);
  EXPECT_EQ(data.json().cameras.value()[1].orthographic.value().ymag, 2.0f);
  EXPECT_EQ(data.json().cameras.value()[1].orthographic.value().zfar, 50.0f);
  EXPECT_EQ(data.json().cameras.value()[1].orthographic.value().znear, 0.5f);

  EXPECT_EQ(data.json().images.value().size(), 2);
  EXPECT_EQ(data.json().images.value()[0].uri.value(), "image1.png");
  EXPECT_EQ(data.json().images.value()[0].mimeType.value(),
            json::Image::MimeType::PNG);
  EXPECT_EQ(data.json().images.value()[1].uri.value(), "image2.jpeg");
  EXPECT_EQ(data.json().images.value()[1].mimeType.value(),
            json::Image::MimeType::JPEG);

  EXPECT_EQ(data.json().materials.value().size(), 2);
  EXPECT_EQ(data.json().materials.value()[0].name, "MaterialOne");
  std::array<float, 4> baseColorFactor{0.5, 0.5, 0.5, 1.0};
  EXPECT_EQ(data.json()
                .materials.value()[0]
                .pbrMetallicRoughness->baseColorFactor.value(),
            baseColorFactor);
  EXPECT_EQ(data.json()
                .materials.value()[0]
                .pbrMetallicRoughness->metallicFactor.value(),
            0.1f);
  EXPECT_EQ(data.json().materials.value()[0].alphaMode,
            json::Material::AlphaMode::BLEND);
  EXPECT_EQ(data.json().materials.value()[0].doubleSided, true);
  EXPECT_EQ(data.json().materials.value()[0].isUnlit(), true);
  EXPECT_EQ(data.json().materials.value()[1].name, "MaterialTwo");
  EXPECT_EQ(
      data.json().materials.value()[1].pbrMetallicRoughness->baseColorFactor,
      std::nullopt);
  EXPECT_EQ(data.json()
                .materials.value()[1]
                .pbrMetallicRoughness->metallicFactor.value(),
            0.3f);
  EXPECT_EQ(data.json()
                .materials.value()[1]
                .pbrMetallicRoughness->roughnessFactor.value(),
            0.4f);
  EXPECT_EQ(data.json()
                .materials.value()[1]
                .emissiveTexture->khrTextureTransform->offset,
            (std::array<float, 2>{0, 1.0f}));
  EXPECT_EQ(data.json()
                .materials.value()[1]
                .emissiveTexture->khrTextureTransform->rotation,
            1.5f);
  EXPECT_EQ(data.json()
                .materials.value()[1]
                .emissiveTexture->khrTextureTransform->scale,
            (std::array<float, 2>{0.5f, 0.5f}));
  EXPECT_EQ(data.json()
                .materials.value()[1]
                .emissiveTexture->khrTextureTransform->texCoord,
            1);
  EXPECT_EQ(
      data.json().materials.value()[1].anisotropy->anisotropyStrength.value(),
      0.6f);
  EXPECT_EQ(
      data.json().materials.value()[1].anisotropy->anisotropyRotation.value(),
      1.57f);
  EXPECT_EQ(
      data.json().materials.value()[1].anisotropy->anisotropyTexture->index, 0);
  EXPECT_EQ(data.json().materials.value()[1].sheen->sheenColorFactor.value(),
            (std::array<float, 3>{0.9f, 0.9f, 0.9f}));
  EXPECT_EQ(data.json().materials.value()[1].sheen->sheenColorTexture->index,
            0);
  EXPECT_EQ(
      data.json().materials.value()[1].sheen->sheenRoughnessFactor.value(),
      0.3f);
  EXPECT_EQ(
      data.json().materials.value()[1].sheen->sheenRoughnessTexture->index, 1);
  EXPECT_EQ(data.json().materials.value()[1].specular->specularFactor.value(),
            0.3f);
  EXPECT_EQ(data.json().materials.value()[1].specular->specularTexture->index,
            2);
  EXPECT_EQ(
      data.json().materials.value()[1].specular->specularColorFactor.value(),
      (std::array<float, 3>{0.6f, 0.7f, 0.8f}));
  EXPECT_EQ(
      data.json().materials.value()[1].specular->specularColorTexture->index,
      3);
  EXPECT_EQ(data.json().materials.value()[1].ior->iorValue(), 1.4f);
  EXPECT_EQ(data.json().materials.value()[1].clearcoat->clearcoatFactorValue(),
            1.0f);
  EXPECT_EQ(data.json().materials.value()[1].clearcoat->clearcoatTexture->index,
            0);
  EXPECT_EQ(
      data.json().materials.value()[1].clearcoat->clearcoatTexture->texCoord,
      0);
  EXPECT_EQ(data.json()
                .materials.value()[1]
                .clearcoat->clearcoatRoughnessFactorValue(),
            0.5f);
  EXPECT_EQ(data.json()
                .materials.value()[1]
                .clearcoat->clearcoatRoughnessTexture->index,
            1);
  EXPECT_EQ(data.json()
                .materials.value()[1]
                .clearcoat->clearcoatRoughnessTexture->texCoord,
            0);
  EXPECT_EQ(
      data.json().materials.value()[1].clearcoat->clearcoatNormalTexture->index,
      2);
  EXPECT_EQ(data.json()
                .materials.value()[1]
                .clearcoat->clearcoatNormalTexture->texCoord,
            0);
  EXPECT_EQ(data.json()
                .materials.value()[1]
                .clearcoat->clearcoatNormalTexture->scaleValue(),
            1.0f);
  EXPECT_EQ(data.json().materials.value()[1].dispersion->dispersionValue(),
            0.1f);
  EXPECT_EQ(data.json()
                .materials.value()[1]
                .emissiveStrength->emissiveStrengthValue(),
            5.0f);
  EXPECT_EQ(
      data.json().materials.value()[1].iridescence->iridescenceFactorValue(),
      1.2f);
  EXPECT_EQ(data.json().materials.value()[1].iridescence->iridescenceIorValue(),
            1.3f);
  EXPECT_EQ(data.json()
                .materials.value()[1]
                .iridescence->iridescenceThicknessMinimumValue(),
            200.0f);
  EXPECT_EQ(data.json()
                .materials.value()[1]
                .iridescence->iridescenceThicknessMaximumValue(),
            500.0f);
  EXPECT_EQ(
      data.json().materials.value()[1].transmission->transmissionFactorValue(),
      1.0f);
  EXPECT_EQ(
      data.json().materials.value()[1].transmission->transmissionTexture->index,
      0);
  EXPECT_EQ(data.json()
                .materials.value()[1]
                .transmission->transmissionTexture->texCoord,
            0);
  EXPECT_EQ(data.json().materials.value()[1].volume->thicknessFactorValue(),
            1.0f);
  EXPECT_EQ(data.json().materials.value()[1].volume->attenuationDistanceValue(),
            0.006f);
  EXPECT_EQ(data.json().materials.value()[1].volume->attenuationColorValue(),
            (std::array<float, 3>{0.5f, 0.5f, 0.5f}));

  EXPECT_EQ(data.json().meshes.value().size(), 1);
  EXPECT_EQ(data.json().meshes.value()[0].name, "MeshOne");
  EXPECT_EQ(data.json().meshes.value()[0].primitives.size(), 2);
  EXPECT_EQ(data.json().meshes.value()[0].primitives[0].mode,
            json::MeshPrimitive::ModeFromInt(4));
  EXPECT_EQ(data.json().meshes.value()[0].primitives[0].indices, 1);
  EXPECT_EQ(data.json().meshes.value()[0].primitives[0].attributes.position, 0);
  EXPECT_EQ(data.json().meshes.value()[0].primitives[0].attributes.normal, 2);
  EXPECT_EQ(data.json().meshes.value()[0].primitives[0].mode,
            json::MeshPrimitive::ModeFromInt(4));
  EXPECT_EQ(data.json().meshes.value()[0].primitives[1].indices, 2);
  EXPECT_EQ(data.json().meshes.value()[0].primitives[1].attributes.position, 1);
  EXPECT_EQ(
      data.json().meshes.value()[0].primitives[1].attributes.texcoords->size(),
      2);
  EXPECT_EQ(data.json()
                .meshes.value()[0]
                .primitives[1]
                .attributes.texcoords.value()[0],
            3);
  EXPECT_EQ(data.json()
                .meshes.value()[0]
                .primitives[1]
                .attributes.texcoords.value()[1],
            4);
  EXPECT_EQ(data.json().meshes.value()[0].primitives[1].mode,
            json::MeshPrimitive::ModeFromInt(3));

  EXPECT_EQ(data.json().nodes.value().size(), 1);
  EXPECT_EQ(data.json().nodes.value()[0].name, "Node 1");
  EXPECT_EQ(data.json().nodes.value()[0].camera.value(), 0);
  EXPECT_EQ(data.json().nodes.value()[0].children.value(),
            std::vector<uint32_t>{1});
  EXPECT_EQ(data.json().nodes.value()[0].skin.value(), 0);
  EXPECT_EQ(
      data.json().nodes.value()[0].matrix.value(),
      (std::array<float, 16>{1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f,
                             0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f}));
  EXPECT_EQ(data.json().nodes.value()[0].mesh.value(), 0);
  EXPECT_EQ(data.json().nodes.value()[0].rotation.value(),
            (std::array<float, 4>{1.0f, 1.0f, 1.0f, 1.0f}));
  EXPECT_EQ(data.json().nodes.value()[0].scale.value(),
            (std::array<float, 3>{1.0f, 1.0f, 1.0f}));
  EXPECT_EQ(data.json().nodes.value()[0].translation.value(),
            (std::array<float, 3>{1.0f, 1.0f, 1.0f}));
  EXPECT_EQ(data.json().nodes.value()[0].weights.value(),
            std::vector<float>({1.0f, 1.0f}));

  EXPECT_EQ(data.json().textures.value().size(), 1);
  EXPECT_EQ(data.json().textures.value()[0].sampler.value(), 0);
  EXPECT_EQ(data.json().textures.value()[0].source.value(), 0);
  EXPECT_EQ(data.json().textures.value()[0].name, "tex1");

  EXPECT_EQ(data.json().scene.value(), 0);

  EXPECT_EQ(data.json().scenes.value().size(), 1);
  EXPECT_EQ(data.json().scenes.value()[0].nodes.value()[0], 1);
  EXPECT_EQ(data.json().scenes.value()[0].nodes.value()[1], 2);
  EXPECT_EQ(data.json().scenes.value()[0].name, "Scene1");

  EXPECT_EQ(data.json().skins.value().size(), 1);
  EXPECT_EQ(data.json().skins.value()[0].inverseBindMatrices.value(), 0);
  EXPECT_EQ(data.json().skins.value()[0].skeleton.value(), 1);
  EXPECT_EQ(data.json().skins.value()[0].joints.size(), 3);
  EXPECT_EQ(data.json().skins.value()[0].joints[0], 0);
  EXPECT_EQ(data.json().skins.value()[0].name, "Skin1");

  EXPECT_EQ(data.json().lights->size(), 1);
  EXPECT_EQ(data.json().lights->at(0).type, json::KHRLight::Type::SPOT);
  EXPECT_EQ(data.json().lights->at(0).colorValue(),
            (std::array<float, 3>{0.0f, 0.5f, 1.0f}));
  EXPECT_EQ(data.json().lights->at(0).spot->innerConeAngleValue(), 0.78f);
  EXPECT_EQ(data.json().lights->at(0).spot->outerConeAngleValue(), 1.57f);
}

// TEST(TestGLTFData, binaryForAccessor) {
//   // vec2<uint8_t> { 'a', 'b' }
//   auto encoded = cppcodec::base64_rfc4648::encode({'a', 'b'});
//   auto rawJson = R"(
//     {
//       "asset": { "version": "1.0" },
//       "accessors": [
//         {
//           "bufferView": 0,
//           "byteOffset": 0,
//           "componentType": 5121,
//           "count": 1,
//           "type": "VEC2"
//         }
//       ],
//       "bufferViews": [
//         {
//           "buffer": 0,
//           "byteOffset": 0,
//           "byteLength": 2
//         }
//       ],
//       "buffers": [
//         {
//           "byteLength": 2,
//           "uri": "data:base64,)" +
//                  encoded + R"("
//         }
//       ]
//     }
//   )";
//   auto gltf = GLTF2::GLTFFile::parseStream( std::istringstream(rawJson));
//   bool normalized = false;
//   auto data = json::.binaryForAccessor(gltf.json().accessors->at(0),
//   &normalized); EXPECT_FALSE(normalized); EXPECT_EQ(data.size(), 2);
//   EXPECT_EQ(data[0], 'a');
//   EXPECT_EQ(data[1], 'b');
// }

// TEST(TestGLTFData, binaryForAccessorWithNormalized) {
//   // vec2<uint8_t> { 'a', 'b' }
//   auto rawJson = R"(
//     {
//       "asset": { "version": "1.0" },
//       "accessors": [
//         {
//           "bufferView": 0,
//           "byteOffset": 0,
//           "componentType": 5121,
//           "count": 1,
//           "type": "VEC2",
//           "normalized": true
//         }
//       ],
//       "bufferViews": [
//         {
//           "buffer": 0,
//           "byteOffset": 0,
//           "byteLength": 2
//         }
//       ],
//       "buffers": [
//         {
//           "byteLength": 2,
//           "uri": "data:base64,YWI="
//         }
//       ]
//     }
//   )";
//   auto gltf = GLTF2::GLTFFile::parseStream( std::istringstream(rawJson));
//   bool normalized = false;
//   auto data = json::.binaryForAccessor(gltf.json().accessors->at(0),
//   &normalized); EXPECT_TRUE(normalized); EXPECT_EQ(data.size(), sizeof(float)
//   * 2); EXPECT_EQ(((float *)data.data())[0], (float)'a' / (float)UINT8_MAX);
//   EXPECT_EQ(((float *)data.data())[1], (float)'b' / (float)UINT8_MAX);
// }

// TEST(TestGLTFData, binaryForAccessorWithSparse) {
//   // buffer data: uint8_t[3] {0x00, 0x00, 0x20}
//   // indices: 0, values: 0x20
//   auto encoded = cppcodec::base64_rfc4648::encode({0x00, 0x00, 0x20});
//   auto rawJson = R"(
//     {
//       "asset": { "version": "1.0" },
//       "accessors": [
//         {
//           "bufferView": 0,
//           "byteOffset": 0,
//           "componentType": 5121,
//           "count": 1,
//           "type": "SCALAR",
//           "sparse": {
//             "count": 1,
//             "indices": {
//               "bufferView": 0,
//               "byteOffset": 0,
//               "componentType": 5123
//             },
//             "values": {
//               "bufferView": 0,
//               "byteOffset": 2
//             }
//           }
//         }
//       ],
//       "bufferViews": [
//         {
//           "buffer": 0,
//           "byteOffset": 0,
//           "byteLength": 3
//         }
//       ],
//       "buffers": [
//         {
//           "byteLength": 3,
//           "uri": "data:base64,)" +
//                  encoded + R"("
//         }
//       ]
//     }
//   )";
//   auto gltf = GLTF2::GLTFFile::parseStream( std::istringstream(rawJson));
//   bool normalized = false;
//   auto data = json::.binaryForAccessor(gltf.json().accessors->at(0),
//   &normalized); EXPECT_FALSE(normalized); EXPECT_EQ(data.size(), 1);
//   EXPECT_EQ(data[0], 0x20);
// }

// TEST(TestGLTFData, binaryForAccessorWithByteStride) {
//   // stride is 16 but each data is vec3<float>
//   float bufferData[10 * 4 * 4] = {0};
//   for (int i = 0; i < 10; ++i) {
//     bufferData[i * 4] = (float)i;
//     bufferData[i * 4 + 1] = (float)i + 1;
//     bufferData[i * 4 + 2] = (float)i + 2;
//   }
//   auto encoded = cppcodec::base64_rfc4648::encode(bufferData);
//   auto rawJson = R"(
//     {
//       "asset": { "version": "1.0" },
//       "accessors": [
//         {
//           "bufferView": 0,
//           "byteOffset": 0,
//           "componentType": 5126,
//           "count": 10,
//           "type": "VEC3"
//         }
//       ],
//       "bufferViews": [
//         {
//           "buffer": 0,
//           "byteOffset": 0,
//           "byteLength": 156,
//           "byteStride": 16
//         }
//       ],
//       "buffers": [
//         {
//           "byteLength": 160,
//           "uri": "data:base64,)" +
//                  encoded + R"("
//         }
//       ]
//     }
//   )";
//   auto gltf = GLTF2::GLTFFile::parseStream( std::istringstream(rawJson));
//   bool normalized = false;
//   auto data = json::.binaryForAccessor(gltf.json().accessors->at(0),
//   &normalized); EXPECT_FALSE(normalized); EXPECT_EQ(data.size(), 4 * 3 * 10);
//   float *floatArray = (float *)data.data();
//   for (int i = 0; i < 10; ++i) {
//     int baseIndex = i * 3;
//     EXPECT_EQ(floatArray[baseIndex], (float)i);
//     EXPECT_EQ(floatArray[baseIndex + 1], (float)i + 1);
//     EXPECT_EQ(floatArray[baseIndex + 2], (float)i + 2);
//   }
// }

// TEST(TestGLTFData, meshPrimitive) {
//   // bufferViews[0]: vec3<float, 1>
//   // bufferViews[1]: vec3<float, 1>
//   // bufferViews[2]: vec2<float, 1>
//   // bufferViews[3]: uint16_t
//   std::vector<float> bufs = {// bufferViews[0]
//                              0.0f, -1.0f, 1.0f,
//                              // bufferViews[1]
//                              1.0f, 1.0f, 0.0f,
//                              // bufferViews[2]
//                              0.1f, 1.1f};
//   // bufferViews[3]
//   uint16_t b3 = 2;
//
//   std::vector<uint8_t> bin(sizeof(float) * 8 + sizeof(uint16_t));
//   std::memcpy(bin.data(), bufs.data(), sizeof(float) * 8);
//   std::memcpy(bin.data() + sizeof(float) * 8, &b3, sizeof(uint16_t));
//
//   auto rawJson = R"(
//     {
//       "asset": { "version": "1.0" },
//       "meshes": [
//         {
//           "primitives": [
//             {
//               "attributes": {
//                 "POSITION": 0,
//                 "NORMAL": 1,
//                 "TEXCOORD_0": 2
//               },
//               "indices": 3,
//               "mode": 4
//             }
//           ]
//         }
//       ],
//       "accessors": [
//         {
//           "bufferView": 0,
//           "componentType": 5126,
//           "count": 1,
//           "type": "VEC3",
//           "max": [1.0, 1.0, 1.0],
//           "min": [-1.0, -1.0, -1.0]
//         },
//         {
//           "bufferView": 1,
//           "componentType": 5126,
//           "count": 1,
//           "type": "VEC3"
//         },
//         {
//           "bufferView": 2,
//           "componentType": 5126,
//           "count": 1,
//           "type": "VEC2"
//         },
//         {
//           "bufferView": 3,
//           "componentType": 5123,
//           "count": 1,
//           "type": "SCALAR"
//         }
//       ],
//       "bufferViews": [
//         {
//           "buffer": 0,
//           "byteOffset": 0,
//           "byteLength": 12
//         },
//         {
//           "buffer": 0,
//           "byteOffset": 12,
//           "byteLength": 12
//         },
//         {
//           "buffer": 0,
//           "byteOffset": 24,
//           "byteLength": 8
//         },
//         {
//           "buffer": 0,
//           "byteOffset": 32,
//           "byteLength": 2
//         }
//       ],
//       "buffers": [
//         {
//           "byteLength": 34
//         }
//       ]
//     }
//   )";
//   auto gltf = GLTF2::GLTFFile::parseStream( std::istringstream(rawJson),
//   std::nullopt, bin);
//
//   auto meshPrimitive = json::.meshPrimitiveFromPrimitive(
//       json::.json().meshes->at(0).primitives.at(0));
//
//   // position
//   EXPECT_EQ(((float *)meshPrimitive.sources.position->binary.data())[0],
//             bufs[0]);
//   EXPECT_EQ(((float *)meshPrimitive.sources.position->binary.data())[1],
//             bufs[1]);
//   EXPECT_EQ(((float *)meshPrimitive.sources.position->binary.data())[2],
//             bufs[2]);
//   EXPECT_EQ(meshPrimitive.sources.position->vectorCount, 1);
//   EXPECT_EQ(meshPrimitive.sources.position->componentType,
//             json::Accessor::ComponentType::FLOAT);
//   EXPECT_EQ(meshPrimitive.sources.position->componentsPerVector, 3);
//
//   // normal
//   EXPECT_EQ(((float *)meshPrimitive.sources.normal->binary.data())[0],
//   bufs[3]); EXPECT_EQ(((float
//   *)meshPrimitive.sources.normal->binary.data())[1], bufs[4]);
//   EXPECT_EQ(((float *)meshPrimitive.sources.normal->binary.data())[2],
//   bufs[5]); EXPECT_EQ(meshPrimitive.sources.normal->vectorCount, 1);
//   EXPECT_EQ(meshPrimitive.sources.normal->componentType,
//             json::Accessor::ComponentType::FLOAT);
//   EXPECT_EQ(meshPrimitive.sources.normal->componentsPerVector, 3);
//
//   // texcoord
//   EXPECT_EQ(((float *)meshPrimitive.sources.texcoords[0].binary.data())[0],
//             bufs[6]);
//   EXPECT_EQ(((float *)meshPrimitive.sources.texcoords[0].binary.data())[1],
//             bufs[7]);
//   EXPECT_EQ(meshPrimitive.sources.texcoords[0].vectorCount, 1);
//   EXPECT_EQ(meshPrimitive.sources.texcoords[0].componentType,
//             json::Accessor::ComponentType::FLOAT);
//   EXPECT_EQ(meshPrimitive.sources.texcoords[0].componentsPerVector, 2);
//
//   // indices
//   EXPECT_EQ(((uint16_t *)meshPrimitive.element->binary.data())[0], b3);
//   EXPECT_EQ(meshPrimitive.element->primitiveMode,
//             json::MeshPrimitive::Mode::TRIANGLES);
//   EXPECT_EQ(meshPrimitive.element->componentType,
//             json::Accessor::ComponentType::UNSIGNED_SHORT);
// }

TEST(TestGLTFData, validVRM1) {
  auto rawJson = R"(
    {
      "asset": { "version": "1.0" },
      "extensionsUsed": ["VRMC_vrm"],
      "extensions": {
        "VRMC_vrm": {
          "specVersion": "1.0",
          "meta": {
            "name": "test",
            "authors": [ "test author 1" ],
            "copyrightInformation": "copyrightInformation",
            "contactInformation": "contactInformation",
            "references": ["references_1"],
            "thumbnailImage": 0,
            "thirdPartyLicenses": "thirdPartyLicenses",
            "licenseUrl": "https://vrm.dev/licenses/1.0",
            "avatarPermission": "onlySeparatelyLicensedPerson",
            "allowExcessivelyViolentUsage": true,
            "allowExcessivelySexualUsage": true,
            "commercialUsage": "personalProfit",
            "allowPoliticalOrReligiousUsage": true,
            "allowAntisocialOrHateUsage": true,
            "creditNotation": "unnecessary",
            "allowRedistribution": true,
            "modification": "allowModificationRedistribution",
            "otherLicenseUrl": "otherLicenseUrl"
          },
          "humanoid": {
            "humanBones": {
              "chest":{
                "node":22
              },
              "head":{
                "node":25
              },
              "hips":{
                "node":4
              },
              "leftEye":{
                "node":26
              },
              "leftFoot":{
                "node":162
              },
              "leftHand":{
                "node":98
              },
              "leftIndexDistal":{
                "node":101
              },
              "leftIndexIntermediate":{
                "node":100
              },
              "leftIndexProximal":{
                "node":99
              },
              "leftLittleDistal":{
                "node":105
              },
              "leftLittleIntermediate":{
                "node":104
              },
              "leftLittleProximal":{
                "node":103
              },
              "leftLowerArm":{
                "node":97
              },
              "leftLowerLeg":{
                "node":161
              },
              "leftMiddleDistal":{
                "node":109
              },
              "leftMiddleIntermediate":{
                "node":108
              },
              "leftMiddleProximal":{
                "node":107
              },
              "leftRingDistal":{
                "node":113
              },
              "leftRingIntermediate":{
                "node":112
              },
              "leftRingProximal":{
                "node":111
              },
              "leftShoulder":{
                "node":88
              },
              "leftThumbDistal":{
                "node":117
              },
              "leftThumbMetacarpal":{
                "node":115
              },
              "leftThumbProximal":{
                "node":116
              },
              "leftToes":{
                "node":163
              },
              "leftUpperArm":{
                "node":96
              },
              "leftUpperLeg":{
                "node":160
              },
              "neck":{
                "node":24
              },
              "rightEye":{
                "node":27
              },
              "rightFoot":{
                "node":167
              },
              "rightHand":{
                "node":132
              },
              "rightIndexDistal":{
                "node":135
              },
              "rightIndexIntermediate":{
                "node":134
              },
              "rightIndexProximal":{
                "node":133
              },
              "rightLittleDistal":{
                "node":139
              },
              "rightLittleIntermediate":{
                "node":138
              },
              "rightLittleProximal":{
                "node":137
              },
              "rightLowerArm":{
                "node":131
              },
              "rightLowerLeg":{
                "node":166
              },
              "rightMiddleDistal":{
                "node":143
              },
              "rightMiddleIntermediate":{
                "node":142
              },
              "rightMiddleProximal":{
                "node":141
              },
              "rightRingDistal":{
                "node":147
              },
              "rightRingIntermediate":{
                "node":146
              },
              "rightRingProximal":{
                "node":145
              },
              "rightShoulder":{
                "node":122
              },
              "rightThumbDistal":{
                "node":151
              },
              "rightThumbMetacarpal":{
                "node":149
              },
              "rightThumbProximal":{
                "node":150
              },
              "rightToes":{
                "node":168
              },
              "rightUpperArm":{
                "node":130
              },
              "rightUpperLeg":{
                "node":165
              },
              "spine":{
                "node":21
              },
              "upperChest":{
                "node":23
              }
            }
          },
          "firstPerson": {
            "meshAnnotations": [
              {
                "node": 1,
                "type": "firstPersonOnly"
              }
            ]
          },
          "lookAt": {
            "offsetFromHeadBone": [1.0, 2.0, 3.0],
            "type": "expression",
            "rangeMapHorizontalInner": {
              "inputMaxValue": 1.0,
              "outputScale": 2.0
            },
            "rangeMapHorizontalOuter": {
              "inputMaxValue": 3.0,
              "outputScale": 4.0
            },
            "rangeMapVerticalDown": {
              "inputMaxValue": 5.0,
              "outputScale": 6.0
            },
            "rangeMapVerticalUp": {
              "inputMaxValue": 7.0,
              "outputScale": 8.0
            }
          },
          "expressions": {
            "preset": {
              "happy": {
                "morphTargetBinds": [
                  {
                    "node": 1,
                    "index": 2,
                    "weight": 3.0
                  }
                ],
                "materialColorBinds": [
                  {
                    "material": 1,
                    "type": "outlineColor",
                    "targetValue": [0.0, 1.0, 2.0, 3.0]
                  }
                ],
                "textureTransformBinds": [
                  {
                    "material": 3,
                    "scale": [0.1, 0.2],
                    "offset": [1, 2]
                  }
                ],
                "isBinary": true,
                "overrideBlink": "none",
                "overrideLookAt": "block",
                "overrideMouth": "blend"
              }
            }
          }
        }
      }
    }
  )";
  auto gltf = GLTFFile::parseStream(std::istringstream(rawJson));
  ASSERT_TRUE(gltf.json().vrm1.has_value());
  auto vrm = *gltf.json().vrm1;

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
  ASSERT_EQ(meta.avatarPermission,
            json::VRMCMeta::AvatarPermission::ONLY_SEPARATELY_LICENSED_PERSON);
  ASSERT_TRUE(meta.allowExcessivelyViolentUsage);
  ASSERT_TRUE(meta.allowExcessivelySexualUsage);
  ASSERT_EQ(meta.commercialUsage,
            json::VRMCMeta::CommercialUsage::PERSONAL_PROFIT);
  ASSERT_TRUE(meta.allowPoliticalOrReligiousUsage);
  ASSERT_TRUE(meta.allowAntisocialOrHateUsage);
  ASSERT_EQ(meta.creditNotation, json::VRMCMeta::CreditNotation::UNNECESSARY);
  ASSERT_TRUE(meta.allowRedistribution);
  ASSERT_EQ(meta.modification,
            json::VRMCMeta::Modification::ALLOW_MODIFICATION_REDISTRIBUTION);
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
            json::VRMCFirstPersonMeshAnnotation::Type::FIRST_PERSON_ONLY);

  json::VRMCLookAt &lookAt = *vrm.lookAt;
  ASSERT_EQ(lookAt.offsetFromHeadBone->at(0), 1.0f);
  ASSERT_EQ(lookAt.offsetFromHeadBone->at(1), 2.0f);
  ASSERT_EQ(lookAt.offsetFromHeadBone->at(2), 3.0f);
  ASSERT_EQ(lookAt.type, json::VRMCLookAt::Type::EXPRESSION);
  ASSERT_EQ(lookAt.rangeMapHorizontalInner->inputMaxValue, 1.0f);
  ASSERT_EQ(lookAt.rangeMapHorizontalInner->outputScale, 2.0f);
  ASSERT_EQ(lookAt.rangeMapHorizontalOuter->inputMaxValue, 3.0f);
  ASSERT_EQ(lookAt.rangeMapHorizontalOuter->outputScale, 4.0f);
  ASSERT_EQ(lookAt.rangeMapVerticalDown->inputMaxValue, 5.0f);
  ASSERT_EQ(lookAt.rangeMapVerticalDown->outputScale, 6.0f);
  ASSERT_EQ(lookAt.rangeMapVerticalUp->inputMaxValue, 7.0f);
  ASSERT_EQ(lookAt.rangeMapVerticalUp->outputScale, 8.0f);

  json::VRMCExpression &happy = *vrm.expressions->preset->happy;
  ASSERT_EQ(happy.morphTargetBinds->at(0).node, 1);
  ASSERT_EQ(happy.morphTargetBinds->at(0).index, 2);
  ASSERT_EQ(happy.morphTargetBinds->at(0).weight, 3.0f);
  ASSERT_EQ(happy.materialColorBinds->at(0).material, 1);
  ASSERT_EQ(happy.materialColorBinds->at(0).type,
            json::VRMCExpressionMaterialColorBind::Type::OUTLINE_COLOR);
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
  ASSERT_EQ(happy.overrideBlink, json::VRMCExpression::Override::NONE);
  ASSERT_EQ(happy.overrideLookAt, json::VRMCExpression::Override::BLOCK);
  ASSERT_EQ(happy.overrideMouth, json::VRMCExpression::Override::BLEND);
}

TEST(TestGLTFData, validVRM0) {
  auto rawJson = R"(
    {
      "asset": { "version": "1.0" },
      "extensionsUsed": ["VRM"],
      "extensions": {
        "VRM": {
          "exporterVersion": "UniVRM-0.46",
          "specVersion": "0.0",
          "meta": {
            "title": "Sample json::VRM Model",
            "version": "1.0",
            "author": "John Doe",
            "contactInformation": "john.doe@example.com",
            "reference": "https://example.com/reference",
            "texture": 1,
            "allowedUserName": "Everyone",
            "violentUssageName": "Allow",
            "sexualUssageName": "Disallow",
            "commercialUssageName": "Allow",
            "otherPermissionUrl": "https://example.com/permissions",
            "licenseName": "CC_BY",
            "otherLicenseUrl": "https://example.com/other-license"
          },
          "humanoid": {
            "humanBones": [
              {
                "bone": "hips",
                "node": 0,
                "useDefaultValues": true,
                "min": { "x": -0.5, "y": -0.5, "z": -0.5 },
                "max": { "x": 0.5, "y": 0.5, "z": 0.5 },
                "center": { "x": 0.0, "y": 0.0, "z": 0.0 },
                "axisLength": 1.0
              },
              {
                "bone": "leftUpperLeg",
                "node": 1,
                "useDefaultValues": false,
                "min": { "x": -0.3, "y": -0.3, "z": -0.3 },
                "max": { "x": 0.3, "y": 0.3, "z": 0.3 },
                "center": { "x": 0.1, "y": 0.1, "z": 0.1 },
                "axisLength": 1.2
              }
            ],
            "armStretch": 0.05,
            "legStretch": 0.03,
            "upperArmTwist": 0.5,
            "lowerArmTwist": 0.4,
            "upperLegTwist": 0.6,
            "lowerLegTwist": 0.5,
            "feetSpacing": 0.2,
            "hasTranslationDoF": true
          },
          "firstPerson": {
            "firstPersonBone": 1,
            "firstPersonBoneOffset": {
              "x": 0.0,
              "y": 0.1,
              "z": 0.2
            },
            "meshAnnotations": [
              {
                "mesh": 0,
                "firstPersonFlag": "Auto"
              }
            ],
            "lookAtTypeName": "Bone",
            "lookAtHorizontalInner": {
              "curve": [0.0, 0.5, 1.0, 1.5],
              "xRange": 90.0,
              "yRange": 10.0
            },
            "lookAtHorizontalOuter": {
              "curve": [0.0, 0.5, 1.0, 1.5],
              "xRange": 90.0,
              "yRange": 10.0
            },
            "lookAtVerticalDown": {
              "curve": [0.0, 0.5, 1.0, 1.5],
              "xRange": 90.0,
              "yRange": 10.0
            },
            "lookAtVerticalUp": {
              "curve": [0.0, 0.5, 1.0, 1.5],
              "xRange": 90.0,
              "yRange": 10.0
            }
          },
          "blendShapeMaster": {
            "blendShapeGroups": [
              {
                "name": "smile",
                "presetName": "joy",
                "binds": [
                  {
                    "mesh": 0,
                    "index": 1,
                    "weight": 50.0
                  }
                ],
                "materialValues": [
                  {
                    "materialName": "face",
                    "propertyName": "_Color",
                    "targetValue": [1.0, 0.5, 0.5, 1.0]
                  }
                ],
                "isBinary": true
              }
            ]
          },
          "secondaryAnimation": {
            "boneGroups": [
              {
                "comment": "Hair",
                "stiffiness": 0.5,
                "gravityPower": 0.98,
                "gravityDir": { "x": 0.0, "y": -1.0, "z": 0.0 },
                "dragForce": 0.3,
                "center": 0,
                "hitRadius": 0.2,
                "bones": [1, 2, 3],
                "colliderGroups": [0]
              }
            ],
            "colliderGroups": [
              {
                "node": 0,
                "colliders": [
                  {
                    "offset": { "x": 0.0, "y": 0.0, "z": 0.0 },
                    "radius": 0.5
                  }
                ]
              }
            ]
          },
          "materialProperties": [
            {
              "name": "exampleMaterial",
              "shader": "VRM/MToon",
              "renderQueue": 2000,
              "floatProperties": {
                "_Cutoff": 0.5,
                "_BumpScale": 1.0
              },
              "vectorProperties": {
                "_MainTex": [1.0, 1.0, 0.0, 0.0],
                "_Color": [1.0, 0.5, 0.5, 1.0]
              },
              "textureProperties": {
                "_MainTex": 0,
                "_BumpMap": 1
              },
              "keywordMap": {
                "_ALPHABLEND_ON": true,
                "_ALPHATEST_ON": false
              },
              "tagMap": {
                "RenderType": "Transparent"
              }
            }
          ]
        }
      }
    }
  )";
  auto gltf = GLTFFile::parseStream(std::istringstream(rawJson));
  ASSERT_TRUE(gltf.json().vrm0.has_value());
  auto vrm = *gltf.json().vrm0;

  ASSERT_EQ(vrm.exporterVersion, "UniVRM-0.46");
  ASSERT_EQ(vrm.specVersion, "0.0");

  auto &meta = vrm.meta;
  ASSERT_EQ(meta->title, "Sample json::VRM Model");
  ASSERT_EQ(meta->version, "1.0");
  ASSERT_EQ(meta->author, "John Doe");
  ASSERT_EQ(meta->contactInformation, "john.doe@example.com");
  ASSERT_EQ(meta->reference, "https://example.com/reference");
  ASSERT_EQ(meta->texture, 1);
  ASSERT_EQ(meta->allowedUserNameValue(),
            json::VRMMeta::AllowedUserName::EVERYONE);
  ASSERT_EQ(meta->violentUsageValue(), json::VRMMeta::UsagePermission::ALLOW);
  ASSERT_EQ(meta->sexualUsageValue(), json::VRMMeta::UsagePermission::DISALLOW);
  ASSERT_EQ(meta->commercialUsageValue(),
            json::VRMMeta::UsagePermission::ALLOW);
  ASSERT_EQ(meta->otherPermissionUrl, "https://example.com/permissions");
  ASSERT_EQ(meta->licenseNameValue(), json::VRMMeta::LicenseName::CC_BY);
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
  ASSERT_EQ(bone1.bone, json::VRMHumanoidBone::Bone::HIPS);
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
  ASSERT_EQ(bone2.bone, json::VRMHumanoidBone::Bone::LEFT_UPPER_LEG);
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
            json::VRMFirstPerson::LookAtType::BONE);

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
            json::VRMBlendShapeGroup::PresetName::JOY);
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
