#include "GLTFJsonDecoder.h"
#include "GLTFExtension.h"

namespace {
template <typename... Args>
std::string format(const std::string &fmt, Args... args) {
  size_t len = std::snprintf(nullptr, 0, fmt.c_str(), args...);
  std::vector<char> buf(len + 1);
  std::snprintf(&buf[0], len + 1, fmt.c_str(), args...);
  return std::string(&buf[0], &buf[0] + len);
}
} // namespace

namespace gltf2 {

void GLTFJsonDecoder::pushStack(const std::string ctx) { stack.push(ctx); }

void GLTFJsonDecoder::pushStackIndex(const std::string ctx, int index) {
  stack.push(format("%s[%d]", ctx.c_str(), index));
}

void GLTFJsonDecoder::popStack() { stack.pop(); }

std::string GLTFJsonDecoder::context() const {
  auto separator = ".";
  std::stack<std::string> tempStack = stack;
  std::vector<std::string> elements;

  while (!tempStack.empty()) {
    elements.push_back(tempStack.top());
    tempStack.pop();
  }

  std::reverse(elements.begin(), elements.end());

  std::string result;
  if (!elements.empty()) {
    result = elements[0];
    for (size_t i = 1; i < elements.size(); ++i) {
      result += separator + elements[i];
    }
  }

  return result;
}

std::string GLTFJsonDecoder::contextKey(const std::string &key) const {
  return format("%s.%s", context().c_str(), key.c_str());
}

GLTFAccessorSparseIndices
GLTFJsonDecoder::decodeAccessorSparseIndices(const nlohmann::json &j) {
  GLTFAccessorSparseIndices indices;
  decodeTo(j, "bufferView", indices.bufferView);
  decodeTo(j, "byteOffset", indices.byteOffset);
  decodeToMapValue<GLTFAccessorSparseIndices::ComponentType>(
      j, "componentType", indices.componentType,
      [this](const nlohmann::json &value) {
        auto type = GLTFAccessorSparseIndices::ComponentTypeFromInt(
            decodeAs<uint32_t>(value));
        if (!type)
          throw InvalidFormatException(context());
        return *type;
      });
  return indices;
}

GLTFAccessorSparseValues
GLTFJsonDecoder::decodeAccessorSparseValues(const nlohmann::json &j) {
  GLTFAccessorSparseValues values;
  decodeTo(j, "bufferView", values.bufferView);
  decodeTo(j, "byteOffset", values.byteOffset);
  return values;
}

GLTFAccessorSparse
GLTFJsonDecoder::decodeAccessorSparse(const nlohmann::json &j) {
  GLTFAccessorSparse sparse;
  decodeTo(j, "count", sparse.count);
  decodeToMapObj<GLTFAccessorSparseIndices>(
      j, "indices", sparse.indices, [this](const nlohmann::json &value) {
        return decodeAccessorSparseIndices(value);
      });
  decodeToMapObj<GLTFAccessorSparseValues>(
      j, "values", sparse.values, [this](const nlohmann::json &value) {
        return decodeAccessorSparseValues(value);
      });
  return sparse;
}

GLTFAccessor GLTFJsonDecoder::decodeAccessor(const nlohmann::json &j) {
  GLTFAccessor accessor;
  decodeTo(j, "bufferView", accessor.bufferView);
  decodeTo(j, "byteOffset", accessor.byteOffset);
  decodeToMapValue<GLTFAccessor::ComponentType>(
      j, "componentType", accessor.componentType,
      [this](const nlohmann::json &value) {
        auto type =
            GLTFAccessor::ComponentTypeFromInt(decodeAs<uint32_t>(value));
        if (!type)
          throw InvalidFormatException(context());
        return *type;
      });
  decodeTo(j, "normalized", accessor.normalized);
  decodeTo(j, "count", accessor.count);
  decodeToMapValue<GLTFAccessor::Type>(
      j, "type", accessor.type, [this](const nlohmann::json &value) {
        auto type = GLTFAccessor::TypeFromString(decodeAs<std::string>(value));
        if (!type)
          throw InvalidFormatException(context());
        return *type;
      });
  decodeTo(j, "max", accessor.max);
  decodeTo(j, "min", accessor.min);
  decodeToMapObj<GLTFAccessorSparse>(j, "sparse", accessor.sparse,
                                     [this](const nlohmann::json &value) {
                                       return decodeAccessorSparse(value);
                                     });
  decodeTo(j, "name", accessor.name);
  return accessor;
}

GLTFAnimationChannelTarget
GLTFJsonDecoder::decodeAnimationChannelTarget(const nlohmann::json &j) {
  GLTFAnimationChannelTarget target;
  decodeTo(j, "node", target.node);
  decodeToMapValue<GLTFAnimationChannelTarget::Path>(
      j, "path", target.path, [this](const nlohmann::json &value) {
        auto path = GLTFAnimationChannelTarget::PathFromString(
            decodeAs<std::string>(value));
        if (!path)
          throw InvalidFormatException(context());
        return *path;
      });
  return target;
}

GLTFAnimationChannel
GLTFJsonDecoder::decodeAnimationChannel(const nlohmann::json &j) {
  GLTFAnimationChannel channel;
  decodeTo(j, "sampler", channel.sampler);
  decodeToMapObj<GLTFAnimationChannelTarget>(
      j, "target", channel.target, [this](const nlohmann::json &value) {
        return decodeAnimationChannelTarget(value);
      });
  return channel;
}

GLTFAnimationSampler
GLTFJsonDecoder::decodeAnimationSampler(const nlohmann::json &j) {
  GLTFAnimationSampler sampler;
  decodeTo(j, "input", sampler.input);
  decodeToMapValue<GLTFAnimationSampler::Interpolation>(
      j, "interpolation", sampler.interpolation,
      [this](const nlohmann::json &value) {
        auto interp = GLTFAnimationSampler::InterpolationFromString(
            decodeAs<std::string>(value));
        if (!interp)
          throw InvalidFormatException(context());
        return *interp;
      });
  decodeTo(j, "output", sampler.output);
  return sampler;
}

GLTFAnimation GLTFJsonDecoder::decodeAnimation(const nlohmann::json &j) {
  GLTFAnimation animation;
  decodeTo(j, "name", animation.name);

  decodeToMapArray<GLTFAnimationChannel>(j, "channels", animation.channels,
                                         [this](const nlohmann::json &value) {
                                           return decodeAnimationChannel(value);
                                         });

  decodeToMapArray<GLTFAnimationSampler>(j, "samplers", animation.samplers,
                                         [this](const nlohmann::json &value) {
                                           return decodeAnimationSampler(value);
                                         });

  return animation;
}

GLTFAsset GLTFJsonDecoder::decodeAsset(const nlohmann::json &j) {
  GLTFAsset asset;
  decodeTo(j, "copyright", asset.copyright);
  decodeTo(j, "generator", asset.generator);
  decodeTo(j, "version", asset.version);
  decodeTo(j, "minVersion", asset.minVersion);
  return asset;
}

GLTFBuffer GLTFJsonDecoder::decodeBuffer(const nlohmann::json &j) {
  GLTFBuffer buffer;
  decodeTo(j, "uri", buffer.uri);
  decodeTo(j, "byteLength", buffer.byteLength);
  decodeTo(j, "name", buffer.name);
  return buffer;
}

GLTFBufferView GLTFJsonDecoder::decodeBufferView(const nlohmann::json &j) {
  GLTFBufferView bufferView;
  decodeTo(j, "buffer", bufferView.buffer);
  decodeTo(j, "byteOffset", bufferView.byteOffset);
  decodeTo(j, "byteLength", bufferView.byteLength);
  decodeTo(j, "byteStride", bufferView.byteStride);
  decodeTo(j, "target", bufferView.target);
  decodeTo(j, "name", bufferView.name);
  return bufferView;
}

GLTFCameraOrthographic
GLTFJsonDecoder::decodeCameraOrthographic(const nlohmann::json &j) {
  GLTFCameraOrthographic camera;
  decodeTo(j, "xmag", camera.xmag);
  decodeTo(j, "ymag", camera.ymag);
  decodeTo(j, "zfar", camera.zfar);
  decodeTo(j, "znear", camera.znear);
  return camera;
}

GLTFCameraPerspective
GLTFJsonDecoder::decodeCameraPerspective(const nlohmann::json &j) {
  GLTFCameraPerspective camera;
  decodeTo(j, "aspectRatio", camera.aspectRatio);
  decodeTo(j, "yfov", camera.yfov);
  decodeTo(j, "zfar", camera.zfar);
  decodeTo(j, "znear", camera.znear);
  return camera;
}

GLTFCamera GLTFJsonDecoder::decodeCamera(const nlohmann::json &j) {
  GLTFCamera camera;
  decodeToMapValue<GLTFCamera::Type>(
      j, "type", camera.type, [this](const nlohmann::json &value) {
        auto type = GLTFCamera::TypeFromString(decodeAs<std::string>(value));
        if (!type)
          throw InvalidFormatException(context());
        return *type;
      });
  decodeTo(j, "name", camera.name);

  if (camera.type == GLTFCamera::Type::PERSPECTIVE) {
    decodeToMapObj<GLTFCameraPerspective>(j, "perspective", camera.perspective,
                                          [this](const nlohmann::json &value) {
                                            return decodeCameraPerspective(
                                                value);
                                          });
  } else if (camera.type == GLTFCamera::Type::ORTHOGRAPHIC) {
    decodeToMapObj<GLTFCameraOrthographic>(
        j, "orthographic", camera.orthographic,
        [this](const nlohmann::json &value) {
          return decodeCameraOrthographic(value);
        });
  }

  return camera;
}

GLTFImage GLTFJsonDecoder::decodeImage(const nlohmann::json &j) {
  GLTFImage image;
  decodeTo(j, "uri", image.uri);
  decodeToMapValue<GLTFImage::MimeType>(
      j, "mimeType", image.mimeType, [this](const nlohmann::json &value) {
        auto mime = GLTFImage::MimeTypeFromString(decodeAs<std::string>(value));
        if (!mime)
          throw InvalidFormatException(context());
        return *mime;
      });
  decodeTo(j, "bufferView", image.bufferView);
  decodeTo(j, "name", image.name);

  return image;
}

GLTFTexture GLTFJsonDecoder::decodeTexture(const nlohmann::json &j) {
  GLTFTexture texture;
  decodeTo(j, "sampler", texture.sampler);
  decodeTo(j, "source", texture.source);
  decodeTo(j, "name", texture.name);
  return texture;
}

GLTFTextureInfo GLTFJsonDecoder::decodeTextureInfo(const nlohmann::json &j) {
  GLTFTextureInfo textureInfo;
  decodeTo(j, "index", textureInfo.index);
  decodeTo(j, "texCoord", textureInfo.texCoord);
  return textureInfo;
}

GLTFMaterialPBRMetallicRoughness
GLTFJsonDecoder::decodeMaterialPBRMetallicRoughness(const nlohmann::json &j) {
  GLTFMaterialPBRMetallicRoughness pbr;
  decodeToMapValue<std::array<float, 4>>(
      j, "baseColorFactor", pbr.baseColorFactor,
      [this](const nlohmann::json &value) {
        if (!value.is_array())
          throw InvalidFormatException(context());
        return value.get<std::array<float, 4>>();
      });
  decodeToMapObj<GLTFTextureInfo>(
      j, "baseColorTexture", pbr.baseColorTexture,
      [this](const nlohmann::json &value) { return decodeTextureInfo(value); });
  decodeTo(j, "metallicFactor", pbr.metallicFactor);
  decodeTo(j, "roughnessFactor", pbr.roughnessFactor);
  decodeToMapObj<GLTFTextureInfo>(
      j, "metallicRoughnessTexture", pbr.metallicRoughnessTexture,
      [this](const nlohmann::json &value) { return decodeTextureInfo(value); });
  return pbr;
}

GLTFMaterialNormalTextureInfo
GLTFJsonDecoder::decodeMaterialNormalTextureInfo(const nlohmann::json &j) {
  GLTFMaterialNormalTextureInfo normal;
  decodeTo(j, "index", normal.index);
  decodeTo(j, "texCoord", normal.texCoord);
  decodeTo(j, "scale", normal.scale);
  return normal;
}

GLTFMaterialOcclusionTextureInfo
GLTFJsonDecoder::decodeMaterialOcclusionTextureInfo(const nlohmann::json &j) {
  GLTFMaterialOcclusionTextureInfo occlusion;
  decodeTo(j, "index", occlusion.index);
  decodeTo(j, "texCoord", occlusion.texCoord);
  decodeTo(j, "strength", occlusion.strength);
  return occlusion;
}

GLTFMaterial GLTFJsonDecoder::decodeMaterial(const nlohmann::json &j) {
  GLTFMaterial material;
  decodeTo(j, "name", material.name);
  decodeToMapObj<GLTFMaterialPBRMetallicRoughness>(
      j, "pbrMetallicRoughness", material.pbrMetallicRoughness,
      [this](const nlohmann::json &value) {
        return decodeMaterialPBRMetallicRoughness(value);
      });
  decodeToMapObj<GLTFMaterialNormalTextureInfo>(
      j, "normalTexture", material.normalTexture,
      [this](const nlohmann::json &value) {
        return decodeMaterialNormalTextureInfo(value);
      });
  decodeToMapObj<GLTFMaterialOcclusionTextureInfo>(
      j, "occlusionTexture", material.occlusionTexture,
      [this](const nlohmann::json &value) {
        return decodeMaterialOcclusionTextureInfo(value);
      });
  decodeToMapObj<GLTFTextureInfo>(
      j, "emissiveTexture", material.emissiveTexture,
      [this](const nlohmann::json &value) { return decodeTextureInfo(value); });
  decodeToMapValue<std::array<float, 3>>(
      j, "emissiveFactor", material.emissiveFactor,
      [this](const nlohmann::json &value) {
        if (!value.is_array())
          throw InvalidFormatException(context());
        return value.get<std::array<float, 3>>();
      });
  decodeToMapValue<GLTFMaterial::AlphaMode>(
      j, "alphaMode", material.alphaMode, [this](const nlohmann::json &value) {
        auto mode =
            GLTFMaterial::AlphaModeFromString(decodeAs<std::string>(value));
        if (!mode)
          throw InvalidFormatException(context());
        return *mode;
      });
  decodeTo(j, "alphaCutoff", material.alphaCutoff);
  decodeTo(j, "doubleSided", material.doubleSided);
  return material;
}

void GLTFJsonDecoder::decodeMeshPrimitiveTarget(
    const nlohmann::json &j, GLTFMeshPrimitiveTarget &target) {
  decodeTo(j, "POSITION", target.position);
  decodeTo(j, "NORMAL", target.normal);
  decodeTo(j, "TANGENT", target.tangent);
}

std::optional<std::vector<uint32_t>>
GLTFJsonDecoder::decodeMeshPrimitiveAttributesSequenceKey(
    const nlohmann::json &j, const std::string &prefix) {
  std::vector<uint32_t> values;
  int i = 0;
  while (true) {
    std::string key = format("%s_%d", prefix.c_str(), i);
    if (!j.contains(key) || j[key].is_null())
      break;
    if (!j[key].is_number_unsigned())
      throw InvalidFormatException(context());
    values.push_back(j[key].get<uint32_t>());
    i++;
  }
  return values.empty() ? std::nullopt : std::make_optional(values);
}

GLTFMeshPrimitiveAttributes
GLTFJsonDecoder::decodeMeshPrimitiveAttributes(const nlohmann::json &j) {
  GLTFMeshPrimitiveAttributes attributes;
  decodeMeshPrimitiveTarget(j, attributes);
  attributes.texcoords =
      decodeMeshPrimitiveAttributesSequenceKey(j, "TEXCOORD");
  attributes.colors = decodeMeshPrimitiveAttributesSequenceKey(j, "COLOR");
  attributes.joints = decodeMeshPrimitiveAttributesSequenceKey(j, "JOINTS");
  attributes.weights = decodeMeshPrimitiveAttributesSequenceKey(j, "WEIGHTS");
  return attributes;
}

GLTFMeshPrimitiveDracoExtension
GLTFJsonDecoder::decodeMeshPrimitiveDracoExtension(const nlohmann::json &j) {
  GLTFMeshPrimitiveDracoExtension dracoExtension;
  decodeTo(j, "bufferView", dracoExtension.bufferView);
  decodeToMapObj<GLTFMeshPrimitiveAttributes>(
      j, "attributes", dracoExtension.attributes,
      [this](const nlohmann::json &value) {
        return decodeMeshPrimitiveAttributes(value);
      });
  return dracoExtension;
}

GLTFMeshPrimitive
GLTFJsonDecoder::decodeMeshPrimitive(const nlohmann::json &j) {
  GLTFMeshPrimitive primitive;
  decodeToMapObj<GLTFMeshPrimitiveAttributes>(
      j, "attributes", primitive.attributes,
      [this](const nlohmann::json &value) {
        return decodeMeshPrimitiveAttributes(value);
      });
  decodeTo(j, "indices", primitive.indices);
  decodeTo(j, "material", primitive.material);
  decodeToMapValue<GLTFMeshPrimitive::Mode>(
      j, "mode", primitive.mode, [this](const nlohmann::json &value) {
        auto mode = GLTFMeshPrimitive::ModeFromInt(decodeAs<uint32_t>(value));
        if (!mode)
          throw InvalidFormatException(context());
        return *mode;
      });

  decodeToMapArray<GLTFMeshPrimitiveTarget>(
      j, "targets", primitive.targets, [this](const nlohmann::json &value) {
        GLTFMeshPrimitiveTarget target;
        decodeMeshPrimitiveTarget(value, target);
        return target;
      });

  auto extensionsObj = decodeOptObject(j, "extensions");
  if (extensionsObj) {
    decodeToMapObj<GLTFMeshPrimitiveDracoExtension>(
        *extensionsObj, GLTFExtensionKHRDracoMeshCompression,
        primitive.dracoExtension, [this](const nlohmann::json &value) {
          return decodeMeshPrimitiveDracoExtension(value);
        });
  }

  return primitive;
}

GLTFMesh GLTFJsonDecoder::decodeMesh(const nlohmann::json &j) {
  GLTFMesh mesh;
  decodeToMapArray<GLTFMeshPrimitive>(j, "primitives", mesh.primitives,
                                      [this](const nlohmann::json &value) {
                                        return decodeMeshPrimitive(value);
                                      });
  decodeTo(j, "name", mesh.name);
  decodeTo(j, "weights", mesh.weights);
  return mesh;
}

GLTFNode GLTFJsonDecoder::decodeNode(const nlohmann::json &j) {
  GLTFNode node;

  decodeTo(j, "camera", node.camera);
  decodeTo(j, "children", node.children);
  decodeTo(j, "skin", node.skin);
  decodeToMapValue<std::array<float, 16>>(
      j, "matrix", node.matrix, [this](const nlohmann::json &value) {
        if (!value.is_array())
          throw InvalidFormatException(context());
        return value.get<std::array<float, 16>>();
      });
  decodeTo(j, "mesh", node.mesh);
  decodeToMapValue<std::array<float, 4>>(
      j, "rotation", node.rotation, [this](const nlohmann::json &value) {
        if (!value.is_array())
          throw InvalidFormatException(context());
        return value.get<std::array<float, 4>>();
      });
  decodeToMapValue<std::array<float, 3>>(
      j, "scale", node.scale, [this](const nlohmann::json &value) {
        if (!value.is_array())
          throw InvalidFormatException(context());
        return value.get<std::array<float, 3>>();
      });
  decodeToMapValue<std::array<float, 3>>(
      j, "translation", node.translation, [this](const nlohmann::json &value) {
        if (!value.is_array())
          throw InvalidFormatException(context());
        return value.get<std::array<float, 3>>();
      });
  decodeTo(j, "weights", node.weights);
  decodeTo(j, "name", node.name);

  return node;
}

GLTFSampler GLTFJsonDecoder::decodeSampler(const nlohmann::json &j) {
  GLTFSampler sampler;

  decodeToMapValue<GLTFSampler::MagFilter>(
      j, "magFilter", sampler.magFilter, [this](const nlohmann::json &value) {
        auto filter = GLTFSampler::MagFilterFromInt(decodeAs<uint32_t>(value));
        if (!filter) {
          throw InvalidFormatException(context());
        }
        return *filter;
      });

  decodeToMapValue<GLTFSampler::MinFilter>(
      j, "minFilter", sampler.minFilter, [this](const nlohmann::json &value) {
        auto filter = GLTFSampler::MinFilterFromInt(decodeAs<uint32_t>(value));
        if (!filter) {
          throw InvalidFormatException(context());
        }
        return *filter;
      });

  decodeToMapValue<GLTFSampler::WrapMode>(
      j, "wrapS", sampler.wrapS, [this](const nlohmann::json &value) {
        auto mode = GLTFSampler::WrapModeFromInt(decodeAs<uint32_t>(value));
        if (!mode) {
          throw InvalidFormatException(context());
        }
        return *mode;
      });

  decodeToMapValue<GLTFSampler::WrapMode>(
      j, "wrapT", sampler.wrapT, [this](const nlohmann::json &value) {
        auto mode = GLTFSampler::WrapModeFromInt(decodeAs<uint32_t>(value));
        if (!mode) {
          throw InvalidFormatException(context());
        }
        return *mode;
      });

  decodeTo(j, "name", sampler.name);

  return sampler;
}

GLTFScene GLTFJsonDecoder::decodeScene(const nlohmann::json &j) {
  GLTFScene scene;
  decodeTo(j, "nodes", scene.nodes);
  decodeTo(j, "name", scene.name);
  return scene;
}

GLTFSkin GLTFJsonDecoder::decodeSkin(const nlohmann::json &j) {
  GLTFSkin skin;
  decodeTo(j, "inverseBindMatrices", skin.inverseBindMatrices);
  decodeTo(j, "skeleton", skin.skeleton);
  decodeTo(j, "joints", skin.joints);
  decodeTo(j, "name", skin.name);
  return skin;
}

GLTFJson GLTFJsonDecoder::decodeJson(const nlohmann::json &j) {
  pushStack("root");

  GLTFJson data;

  decodeTo(j, "extensionsUsed", data.extensionsUsed);
  decodeTo(j, "extensionsRequired", data.extensionsRequired);

  decodeToMapArray<GLTFAccessor>(
      j, "accessors", data.accessors,
      [this](const nlohmann::json &item) { return decodeAccessor(item); });
  decodeToMapArray<GLTFAnimation>(
      j, "animations", data.animations,
      [this](const nlohmann::json &item) { return decodeAnimation(item); });

  decodeToMapObj<GLTFAsset>(
      j, "asset", data.asset,
      [this](const nlohmann::json &obj) { return decodeAsset(obj); });

  decodeToMapArray<GLTFBuffer>(
      j, "buffers", data.buffers,
      [this](const nlohmann::json &item) { return decodeBuffer(item); });
  decodeToMapArray<GLTFBufferView>(
      j, "bufferViews", data.bufferViews,
      [this](const nlohmann::json &item) { return decodeBufferView(item); });
  decodeToMapArray<GLTFCamera>(
      j, "cameras", data.cameras,
      [this](const nlohmann::json &item) { return decodeCamera(item); });
  decodeToMapArray<GLTFImage>(
      j, "images", data.images,
      [this](const nlohmann::json &item) { return decodeImage(item); });
  decodeToMapArray<GLTFMaterial>(
      j, "materials", data.materials,
      [this](const nlohmann::json &item) { return decodeMaterial(item); });
  decodeToMapArray<GLTFMesh>(
      j, "meshes", data.meshes,
      [this](const nlohmann::json &item) { return decodeMesh(item); });
  decodeToMapArray<GLTFNode>(
      j, "nodes", data.nodes,
      [this](const nlohmann::json &item) { return decodeNode(item); });
  decodeToMapArray<GLTFSampler>(
      j, "samplers", data.samplers,
      [this](const nlohmann::json &item) { return decodeSampler(item); });

  decodeTo(j, "scene", data.scene);

  decodeToMapArray<GLTFScene>(
      j, "scenes", data.scenes,
      [this](const nlohmann::json &item) { return decodeScene(item); });
  decodeToMapArray<GLTFSkin>(
      j, "skins", data.skins,
      [this](const nlohmann::json &item) { return decodeSkin(item); });
  decodeToMapArray<GLTFTexture>(
      j, "textures", data.textures,
      [this](const nlohmann::json &item) { return decodeTexture(item); });

  popStack();

  return data;
}

} // namespace gltf2
