#include "GLTF2Core.h"

#include <assert.h>
#include <iostream>

using namespace gltf2;

int main(int argc, const char **argv) {
  try {
    if (argc > 1) {
      auto data = gltf2::GLTFData::parseFile(argv[1]);
      return 0;
    }

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

    assert(data.json.extensionsUsed->size() == 2);
    assert(data.json.extensionsUsed.value()[0] == "ext1");
    assert(data.json.extensionsUsed.value()[1] == "ext2");
    assert(data.json.extensionsRequired->size() == 1);
    assert(data.json.extensionsRequired.value()[0] == "ext1");

    assert(data.json.accessors.value().size() == 2);
    auto &accessor1 = data.json.accessors.value()[0];
    assert(accessor1.bufferView == 0);
    assert(accessor1.byteOffset == 0);
    assert(accessor1.componentType ==
           GLTFAccessor::ComponentType::UNSIGNED_SHORT);
    assert(accessor1.normalized == false);
    assert(accessor1.count == 3);
    assert(accessor1.type == GLTFAccessor::Type::VEC3);
    assert(accessor1.max.value() == std::vector<float>({1, 1, 1}));
    assert(accessor1.min.value() == std::vector<float>({-1, -1, -1}));
    auto &accessor2 = data.json.accessors.value()[1];
    assert(accessor2.bufferView == 1);
    assert(accessor2.byteOffset == 24);
    assert(accessor2.componentType ==
           GLTFAccessor::ComponentType::UNSIGNED_INT);
    assert(accessor2.normalized == true);
    assert(accessor2.count == 3);
    assert(accessor2.type == GLTFAccessor::Type::SCALAR);
    assert(accessor2.sparse.has_value());
    auto &sparse = accessor2.sparse.value();
    assert(sparse.count == 2);
    assert(sparse.indices.bufferView == 3);
    assert(sparse.indices.byteOffset == 0);
    assert(sparse.indices.componentType ==
           GLTFAccessorSparseIndices::ComponentType::UNSIGNED_SHORT);
    assert(sparse.values.bufferView == 4);
    assert(sparse.values.byteOffset == 8);

    auto &channel1 = data.json.animations.value()[0].channels[0];
    assert(channel1.sampler == 0);
    assert(channel1.target.node.value() == 2);
    assert(channel1.target.path == "rotation");
    auto &channel2 = data.json.animations.value()[0].channels[1];
    assert(channel2.sampler == 1);
    assert(channel2.target.node.value() == 3);
    assert(channel2.target.path == "translation");
    auto &sampler1 = data.json.animations.value()[0].samplers[0];
    assert(sampler1.input == 0);
    assert(sampler1.interpolation ==
           GLTFAnimationSampler::Interpolation::LINEAR);
    assert(sampler1.output == 1);
    auto &sampler2 = data.json.animations.value()[0].samplers[1];
    assert(sampler2.input == 2);
    assert(sampler2.interpolation ==
           GLTFAnimationSampler::Interpolation::CUBICSPLINE);
    assert(sampler2.output == 3);

    assert(data.json.buffers.value().size() == 1);
    assert(data.json.buffers.value()[0].uri == "buffer.bin");
    assert(data.json.buffers.value()[0].byteLength == 1024);

    assert(data.json.bufferViews.value().size() == 2);
    assert(data.json.bufferViews.value()[0].buffer == 0);
    assert(data.json.bufferViews.value()[0].byteOffset == 0);
    assert(data.json.bufferViews.value()[0].byteLength == 512);
    assert(data.json.bufferViews.value()[0].byteStride == 12);
    assert(data.json.bufferViews.value()[0].target == 34962);

    assert(data.json.bufferViews.value()[1].buffer == 0);
    assert(data.json.bufferViews.value()[1].byteOffset == 512);
    assert(data.json.bufferViews.value()[1].byteLength == 512);
    assert(data.json.bufferViews.value()[1].byteStride == 16);
    assert(data.json.bufferViews.value()[1].target == 34963);

    assert(data.json.asset.copyright == "COPYRIGHT");
    assert(data.json.asset.generator == "GENERATOR");
    assert(data.json.asset.version == "1.0");
    assert(data.json.asset.minVersion == "0.1");

    assert(data.json.cameras.value().size() == 2);
    assert(data.json.cameras.value()[0].type == GLTFCamera::Type::PERSPECTIVE);
    assert(data.json.cameras.value()[0].perspective.value().aspectRatio ==
           1.333f);
    assert(data.json.cameras.value()[0].perspective.value().yfov == 1.0f);
    assert(data.json.cameras.value()[0].perspective.value().zfar == 100.0f);
    assert(data.json.cameras.value()[0].perspective.value().znear == 0.1f);
    assert(data.json.cameras.value()[1].type == GLTFCamera::Type::ORTHOGRAPHIC);
    assert(data.json.cameras.value()[1].orthographic.value().xmag == 2.0f);
    assert(data.json.cameras.value()[1].orthographic.value().ymag == 2.0f);
    assert(data.json.cameras.value()[1].orthographic.value().zfar == 50.0f);
    assert(data.json.cameras.value()[1].orthographic.value().znear == 0.5f);

    assert(data.json.images.value().size() == 2);
    assert(data.json.images.value()[0].uri.value() == "image1.png");
    assert(data.json.images.value()[0].mimeType.value() ==
           GLTFImage::MimeType::PNG);
    assert(data.json.images.value()[1].uri.value() == "image2.jpeg");
    assert(data.json.images.value()[1].mimeType.value() ==
           GLTFImage::MimeType::JPEG);

    assert(data.json.materials.value().size() == 2);
    assert(data.json.materials.value()[0].name == "MaterialOne");
    std::array<float, 4> baseColorFactor{0.5, 0.5, 0.5, 1.0};
    assert(data.json.materials.value()[0]
               .pbrMetallicRoughness->baseColorFactor.value() ==
           baseColorFactor);
    assert(data.json.materials.value()[0]
               .pbrMetallicRoughness->metallicFactor.value() == 0.1f);
    assert(data.json.materials.value()[0].alphaMode ==
           GLTFMaterial::AlphaMode::BLEND);
    assert(data.json.materials.value()[0].doubleSided == true);
    assert(data.json.materials.value()[1].name == "MaterialTwo");
    assert(
        data.json.materials.value()[1].pbrMetallicRoughness->baseColorFactor ==
        std::nullopt);
    assert(data.json.materials.value()[1]
               .pbrMetallicRoughness->metallicFactor.value() == 0.3f);
    assert(data.json.materials.value()[1]
               .pbrMetallicRoughness->roughnessFactor.value() == 0.4f);

    assert(data.json.meshes.value().size() == 1);
    assert(data.json.meshes.value()[0].name == "MeshOne");
    assert(data.json.meshes.value()[0].primitives.size() == 2);
    assert(data.json.meshes.value()[0].primitives[0].mode ==
           GLTFMeshPrimitive::ModeFromInt(4));
    assert(data.json.meshes.value()[0].primitives[0].indices == 1);
    assert(data.json.meshes.value()[0].primitives[0].attributes.position == 0);
    assert(data.json.meshes.value()[0].primitives[0].attributes.normal == 2);
    assert(data.json.meshes.value()[0].primitives[0].mode ==
           GLTFMeshPrimitive::ModeFromInt(4));
    assert(data.json.meshes.value()[0].primitives[1].indices == 2);
    assert(data.json.meshes.value()[0].primitives[1].attributes.position == 1);
    assert(data.json.meshes.value()[0]
               .primitives[1]
               .attributes.texcoords->size() == 2);
    assert(data.json.meshes.value()[0]
               .primitives[1]
               .attributes.texcoords.value()[0] == 3);
    assert(data.json.meshes.value()[0]
               .primitives[1]
               .attributes.texcoords.value()[1] == 4);
    assert(data.json.meshes.value()[0].primitives[1].mode ==
           GLTFMeshPrimitive::ModeFromInt(3));

    assert(data.json.nodes.value().size() == 1);
    assert(data.json.nodes.value()[0].name == "Node 1");
    assert(data.json.nodes.value()[0].camera.value() == 0);
    assert(data.json.nodes.value()[0].children.value() ==
           std::vector<uint32_t>{1});
    assert(data.json.nodes.value()[0].skin.value() == 0);
    std::array<float, 16> matrix{1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f,
                                 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f,
                                 0.0f, 0.0f, 0.0f, 1.0f};
    assert(data.json.nodes.value()[0].matrix.value() == matrix);
    assert(data.json.nodes.value()[0].mesh.value() == 0);
    std::array<float, 4> rotation{1.0f, 1.0f, 1.0f, 1.0f};
    std::array<float, 3> scale{1.0f, 1.0f, 1.0f};
    std::array<float, 3> translation{1.0f, 1.0f, 1.0f};
    assert(data.json.nodes.value()[0].rotation.value() == rotation);
    assert(data.json.nodes.value()[0].scale.value() == scale);
    assert(data.json.nodes.value()[0].translation.value() == translation);
    assert(data.json.nodes.value()[0].weights.value() ==
           std::vector<float>({1.0f, 1.0f}));

    assert(data.json.textures.value().size() == 1);
    assert(data.json.textures.value()[0].sampler.value() == 0);
    assert(data.json.textures.value()[0].source.value() == 0);
    assert(data.json.textures.value()[0].name == "tex1");

    assert(data.json.scene.value() == 0);

    assert(data.json.scenes.value().size() == 1);
    assert(data.json.scenes.value()[0].nodes.value()[0] == 1);
    assert(data.json.scenes.value()[0].nodes.value()[1] == 2);
    assert(data.json.scenes.value()[0].name == "Scene1");

    assert(data.json.skins.value().size() == 1);
    assert(data.json.skins.value()[0].inverseBindMatrices.value() == 0);
    assert(data.json.skins.value()[0].skeleton.value() == 1);
    assert(data.json.skins.value()[0].joints.size() == 3);
    assert(data.json.skins.value()[0].joints[0] == 0);
    assert(data.json.skins.value()[0].name == "Skin1");

  } catch (gltf2::InputException e) {
    std::cerr << e.what() << std::endl;
    return 1;
  } catch (gltf2::KeyNotFoundException e) {
    std::cerr << e.what() << std::endl;
    return 1;
  } catch (gltf2::InvalidFormatException e) {
    std::cerr << e.what() << std::endl;
    return 1;
  }

  return 0;
}
