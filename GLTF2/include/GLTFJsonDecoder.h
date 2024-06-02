#ifndef GLTFJsonDecoder_h
#define GLTFJsonDecoder_h

#include "GLTFException.h"
#include "GLTFJson.h"
#include "nlohmann/json.hpp"
#include <stack>

namespace {

template <typename T> bool isValueType(const nlohmann::json &j);

template <> bool isValueType<std::string>(const nlohmann::json &j) {
  return j.is_string();
}

template <> bool isValueType<uint32_t>(const nlohmann::json &j) {
  return j.is_number_unsigned();
}

template <> bool isValueType<float>(const nlohmann::json &j) {
  return j.is_number_float() || j.is_number_integer();
}

template <> bool isValueType<bool>(const nlohmann::json &j) {
  return j.is_boolean();
}

} // namespace

namespace gltf2 {

class GLTFJsonDecoder {
private:
  std::stack<std::string> stack;

  GLTFJsonDecoder(){};

  void pushStack(const std::string ctx);
  void pushStackIndex(const std::string ctx, int index);
  void popStack();
  std::string context() const;
  std::string contextKey(const std::string &key) const;

  // decode basic value by key and assign to required field
  template <typename T>
  void decodeTo(const nlohmann::json &j, const std::string &key, T &to) {
    if (!j.contains(key) || j[key].is_null())
      throw KeyNotFoundException(contextKey(key));
    if (!isValueType<T>(j[key]))
      throw InvalidFormatException(contextKey(key));
    j[key].get_to(to);
  }

  // decode baisc value by key and assign to optional field
  template <typename T>
  void decodeTo(const nlohmann::json &j, const std::string &key,
                std::optional<T> &to) {
    if (!j.contains(key) || j[key].is_null())
      return;
    if (!isValueType<T>(j[key]))
      throw InvalidFormatException(contextKey(key));
    T value;
    j[key].get_to(value);
    to = value;
  }

  // decode array by key, decode elements as T, assign to required field
  template <typename T>
  void decodeTo(const nlohmann::json &j, const std::string &key,
                std::vector<T> &to) {
    decodeToMapArray<T>(j, key, to, [this](const nlohmann::json &value) -> T {
      return decodeAs<T>(value);
    });
  }

  // decode array by key, decode elements as T, assign to optional field
  template <typename T>
  void decodeTo(const nlohmann::json &j, const std::string &key,
                std::optional<std::vector<T>> &to) {
    decodeToMapArray<T>(j, key, to, [this](const nlohmann::json &value) -> T {
      return decodeAs<T>(value);
    });
  }

  // decode array by key, decode elements as T using mapFunc, assign to required
  // field
  template <typename T>
  void decodeToMapArray(const nlohmann::json &j, const std::string &key,
                        std::vector<T> &to,
                        std::function<T(const nlohmann::json &)> mapFunc) {
    auto array = decodeArray(j, key);

    std::vector<T> values;
    for (const auto &value : array) {
      pushStackIndex(key, static_cast<int>(values.size()));
      values.push_back(mapFunc(value));
      popStack();
    }
    to = values;
  }

  // decode array by key, decode elements as T using mapFunc, assign to optional
  // field
  template <typename T>
  void decodeToMapArray(const nlohmann::json &j, const std::string &key,
                        std::optional<std::vector<T>> &to,
                        std::function<T(const nlohmann::json &)> mapFunc) {
    auto array = decodeOptArray(j, key);
    if (!array)
      return;

    std::vector<T> values;
    for (const auto &value : *array) {
      pushStackIndex(key, static_cast<int>(values.size()));
      values.push_back(mapFunc(value));
      popStack();
    }
    to = values;
  }

  // decode basic value by key, decode value as T using mapFunc, assign to
  // required field
  template <typename T>
  void decodeToMapValue(const nlohmann::json &j, const std::string &key, T &to,
                        std::function<T(const nlohmann::json &)> mapFunc) {
    if (!j.contains(key) || j[key].is_null())
      throw KeyNotFoundException(contextKey(key));
    to = mapFunc(j[key]);
  }

  // decode basic value by key, decode value as T using mapFunc, assign to
  // optional field
  template <typename T>
  void decodeToMapValue(const nlohmann::json &j, const std::string &key,
                        std::optional<T> &to,
                        std::function<T(const nlohmann::json &)> mapFunc) {
    if (!j.contains(key) || j[key].is_null())
      return;
    to = mapFunc(j[key]);
  }

  // decode object by key, decode object as T using mapFunc, assign to required
  // field
  template <typename T>
  void decodeToMapObj(const nlohmann::json &j, const std::string &key, T &to,
                      std::function<T(const nlohmann::json &)> mapFunc) {
    auto obj = decodeObject(j, key);
    pushStack(key);
    to = mapFunc(obj);
    popStack();
  }

  // decode object by key, decode object as T using mapFunc, assign to optional
  // field
  template <typename T>
  void decodeToMapObj(const nlohmann::json &j, const std::string &key,
                      std::optional<T> &to,
                      std::function<T(const nlohmann::json &)> mapFunc) {
    auto obj = decodeOptObject(j, key);
    if (!obj)
      return;

    pushStack(key);
    to = mapFunc(*obj);
    popStack();
  }

  std::vector<nlohmann::json> decodeArray(const nlohmann::json &j,
                                          const std::string &key) {
    if (!j.contains(key) || j[key].is_null())
      throw KeyNotFoundException(contextKey(key));
    if (!j[key].is_array())
      throw InvalidFormatException(contextKey(key));
    return j[key].get<std::vector<nlohmann::json>>();
  }

  std::optional<std::vector<nlohmann::json>>
  decodeOptArray(const nlohmann::json &j, const std::string &key) {
    if (!j.contains(key) || j[key].is_null())
      return std::nullopt;
    if (!j[key].is_array())
      throw InvalidFormatException(contextKey(key));
    return j[key].get<std::vector<nlohmann::json>>();
  }

  nlohmann::json decodeObject(const nlohmann::json &j, const std::string &key) {
    if (!j.contains(key) || j[key].is_null())
      throw KeyNotFoundException(contextKey(key));
    if (!j[key].is_object())
      throw InvalidFormatException(contextKey(key));
    return j[key].get<nlohmann::json>();
  }

  std::optional<nlohmann::json> decodeOptObject(const nlohmann::json &j,
                                                const std::string &key) {
    if (!j.contains(key) || j[key].is_null())
      return std::nullopt;
    if (!j[key].is_object())
      throw InvalidFormatException(contextKey(key));
    return j[key].get<nlohmann::json>();
  }

  template <typename T> T decodeAs(const nlohmann::json &j) {
    if (!isValueType<T>(j))
      throw InvalidFormatException(context());
    return j.get<T>();
  }

  GLTFAccessorSparseIndices
  decodeAccessorSparseIndices(const nlohmann::json &j);
  GLTFAccessorSparseValues decodeAccessorSparseValues(const nlohmann::json &j);
  GLTFAccessorSparse decodeAccessorSparse(const nlohmann::json &j);
  GLTFAccessor decodeAccessor(const nlohmann::json &j);
  GLTFAnimationChannelTarget
  decodeAnimationChannelTarget(const nlohmann::json &j);
  GLTFAnimationChannel decodeAnimationChannel(const nlohmann::json &j);
  GLTFAnimationSampler decodeAnimationSampler(const nlohmann::json &j);
  GLTFAnimation decodeAnimation(const nlohmann::json &j);
  GLTFAsset decodeAsset(const nlohmann::json &j);
  GLTFBuffer decodeBuffer(const nlohmann::json &j);
  GLTFBufferView decodeBufferView(const nlohmann::json &j);
  GLTFCameraOrthographic decodeCameraOrthographic(const nlohmann::json &j);
  GLTFCameraPerspective decodeCameraPerspective(const nlohmann::json &j);
  GLTFCamera decodeCamera(const nlohmann::json &j);
  GLTFImage decodeImage(const nlohmann::json &j);
  GLTFTexture decodeTexture(const nlohmann::json &j);
  GLTFKHRTextureTransform decodeKHRTextureTransform(const nlohmann::json &j);
  GLTFTextureInfo decodeTextureInfo(const nlohmann::json &j);
  GLTFMaterialPBRMetallicRoughness
  decodeMaterialPBRMetallicRoughness(const nlohmann::json &j);
  GLTFMaterialNormalTextureInfo
  decodeMaterialNormalTextureInfo(const nlohmann::json &j);
  GLTFMaterialOcclusionTextureInfo
  decodeMaterialOcclusionTextureInfo(const nlohmann::json &j);
  GLTFMaterial decodeMaterial(const nlohmann::json &j);
  GLTFMaterialAnisotropy decodeMaterialAnisotropy(const nlohmann::json &j);
  GLTFMaterialSheen decodeMaterialSheen(const nlohmann::json &j);
  GLTFMaterialSpecular decodeMaterialSpecular(const nlohmann::json &j);
  GLTFMaterialIor decodeMaterialIor(const nlohmann::json &j);
  GLTFMaterialClearcoat decodeMaterialClearcoat(const nlohmann::json &j);
  void decodeMeshPrimitiveTarget(const nlohmann::json &j,
                                 GLTFMeshPrimitiveTarget &target);
  GLTFMeshPrimitiveAttributes
  decodeMeshPrimitiveAttributes(const nlohmann::json &j);
  std::optional<std::vector<uint32_t>>
  decodeMeshPrimitiveAttributesSequenceKey(const nlohmann::json &j,
                                           const std::string &prefix);
  GLTFMeshPrimitiveDracoExtension
  decodeMeshPrimitiveDracoExtension(const nlohmann::json &j);
  GLTFMeshPrimitive decodeMeshPrimitive(const nlohmann::json &j);
  GLTFMesh decodeMesh(const nlohmann::json &j);
  GLTFNode decodeNode(const nlohmann::json &j);
  GLTFSampler decodeSampler(const nlohmann::json &j);
  GLTFScene decodeScene(const nlohmann::json &j);
  GLTFSkin decodeSkin(const nlohmann::json &j);
  GLTFJson decodeJson(const nlohmann::json &j);

public:
  static GLTFJson decode(const nlohmann::json &j) {
    return GLTFJsonDecoder().decodeJson(j);
  }

  GLTFJsonDecoder(const GLTFJsonDecoder &) = delete;
  GLTFJsonDecoder &operator=(const GLTFJsonDecoder &) = delete;
};

} // namespace gltf2

#endif /* GLTFJsonDecoder_h */
