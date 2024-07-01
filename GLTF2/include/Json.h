#ifndef Json_h
#define Json_h

#include "Json_SpringBone.h"
#include "Json_VRM0.h"
#include "Json_VRM1.h"
#include <algorithm>
#include <map>
#include <optional>
#include <stdint.h>
#include <string>
#include <vector>

namespace gltf2 {
namespace json {

// Accessor

class AccessorSparseIndices {
public:
  enum class ComponentType {
    UNSIGNED_BYTE = 5121,
    UNSIGNED_SHORT = 5123,
    UNSIGNED_INT = 5125
  };

  static std::optional<ComponentType> ComponentTypeFromInt(uint32_t value) {
    switch (value) {
    case 5121:
      return ComponentType::UNSIGNED_BYTE;
    case 5123:
      return ComponentType::UNSIGNED_SHORT;
    case 5125:
      return ComponentType::UNSIGNED_INT;
    default:
      return std::nullopt;
    }
  }

  uint32_t bufferView;
  std::optional<uint32_t> byteOffset;
  ComponentType componentType;
};

class AccessorSparseValues {
public:
  uint32_t bufferView;
  std::optional<uint32_t> byteOffset;
};

class AccessorSparse {
public:
  uint32_t count;
  AccessorSparseIndices indices;
  AccessorSparseValues values;
};

class Accessor {
public:
  enum class ComponentType {
    BYTE = 5120,
    UNSIGNED_BYTE = 5121,
    SHORT = 5122,
    UNSIGNED_SHORT = 5123,
    UNSIGNED_INT = 5125,
    FLOAT = 5126
  };

  enum class Type { SCALAR, VEC2, VEC3, VEC4, MAT2, MAT3, MAT4 };

  static uint sizeOfComponentType(ComponentType type) {
    switch (type) {
    case ComponentType::BYTE:
    case ComponentType::UNSIGNED_BYTE:
      return 1;
    case ComponentType::SHORT:
    case ComponentType::UNSIGNED_SHORT:
      return 2;
    case ComponentType::UNSIGNED_INT:
    case ComponentType::FLOAT:
      return 4;
    }
  }

  static uint componentsCountOfType(Type type) {
    switch (type) {
    case Type::SCALAR:
      return 1;
    case Type::VEC2:
      return 2;
    case Type::VEC3:
      return 3;
    case Type::VEC4:
      return 4;
    case Type::MAT2:
      return 4;
    case Type::MAT3:
      return 9;
    case Type::MAT4:
      return 16;
    }
  }

  static std::optional<ComponentType> ComponentTypeFromInt(uint32_t value) {
    switch (value) {
    case 5120:
      return ComponentType::BYTE;
    case 5121:
      return ComponentType::UNSIGNED_BYTE;
    case 5122:
      return ComponentType::SHORT;
    case 5123:
      return ComponentType::UNSIGNED_SHORT;
    case 5125:
      return ComponentType::UNSIGNED_INT;
    case 5126:
      return ComponentType::FLOAT;
    default:
      return std::nullopt;
    }
  }

  static std::optional<Type> TypeFromString(const std::string &value) {
    if (value == "SCALAR")
      return Type::SCALAR;
    else if (value == "VEC2")
      return Type::VEC2;
    else if (value == "VEC3")
      return Type::VEC3;
    else if (value == "VEC4")
      return Type::VEC4;
    else if (value == "MAT2")
      return Type::MAT2;
    else if (value == "MAT3")
      return Type::MAT3;
    else if (value == "MAT4")
      return Type::MAT4;
    else
      return std::nullopt;
  }

  std::optional<uint32_t> bufferView;
  std::optional<uint32_t> byteOffset;
  ComponentType componentType;
  std::optional<bool> normalized;
  uint32_t count;
  Type type;
  std::optional<std::vector<float>> max;
  std::optional<std::vector<float>> min;
  std::optional<AccessorSparse> sparse;
  std::optional<std::string> name;
};

// Animation

class AnimationChannelTarget {
public:
  enum class Path { TRANSLATION, ROTATION, SCALE, WEIGHTS };

  static std::optional<Path> PathFromString(const std::string &value) {
    if (value == "translation")
      return Path::TRANSLATION;
    else if (value == "rotation")
      return Path::ROTATION;
    else if (value == "scale")
      return Path::SCALE;
    else if (value == "weights")
      return Path::WEIGHTS;
    else
      return std::nullopt;
  }

  std::optional<uint32_t> node;
  Path path;
};

class AnimationChannel {
public:
  uint32_t sampler;
  AnimationChannelTarget target;
};

class AnimationSampler {
public:
  enum class Interpolation { LINEAR, STEP, CUBICSPLINE };

  static std::optional<Interpolation>
  InterpolationFromString(const std::string &value) {
    if (value == "LINEAR")
      return Interpolation::LINEAR;
    else if (value == "STEP")
      return Interpolation::STEP;
    else if (value == "CUBICSPLINE")
      return Interpolation::CUBICSPLINE;
    else
      return std::nullopt;
  }

  uint32_t input;
  std::optional<Interpolation> interpolation;
  uint32_t output;

  Interpolation interpolationValue() const {
    return interpolation.value_or(Interpolation::LINEAR);
  }
};

class Animation {
public:
  std::vector<AnimationChannel> channels;
  std::vector<AnimationSampler> samplers;
  std::optional<std::string> name;
};

// Asset

class Asset {
public:
  std::optional<std::string> copyright;
  std::optional<std::string> generator;
  std::string version;
  std::optional<std::string> minVersion;
};

// Buffer

class Buffer {
public:
  std::optional<std::string> uri;
  uint32_t byteLength;
  std::optional<std::string> name;
};

class BufferView {
public:
  uint32_t buffer;
  std::optional<uint32_t> byteOffset;
  uint32_t byteLength;
  std::optional<uint32_t> byteStride;
  std::optional<uint32_t> target;
  std::optional<std::string> name;
};

// Camera

class CameraOrthographic {
public:
  float xmag;
  float ymag;
  float zfar;
  float znear;
};

class CameraPerspective {
public:
  std::optional<float> aspectRatio;
  float yfov;
  std::optional<float> zfar;
  float znear;
};

class Camera {
public:
  enum class Type { PERSPECTIVE, ORTHOGRAPHIC };

  static std::optional<Type> TypeFromString(const std::string &value) {
    if (value == "perspective")
      return Type::PERSPECTIVE;
    else if (value == "orthographic")
      return Type::ORTHOGRAPHIC;
    else
      return std::nullopt;
  }

  std::optional<CameraOrthographic> orthographic;
  std::optional<CameraPerspective> perspective;
  Type type;
  std::optional<std::string> name;
};

// Image

class Image {
public:
  enum class MimeType { JPEG, PNG };

  static std::optional<MimeType> MimeTypeFromString(const std::string &value) {
    if (value == "image/jpeg")
      return MimeType::JPEG;
    else if (value == "image/png")
      return MimeType::PNG;
    else
      return std::nullopt;
  }

  std::optional<std::string> uri;
  std::optional<MimeType> mimeType;
  std::optional<uint32_t> bufferView;
  std::optional<std::string> name;
};

// Texture

class Texture {
public:
  std::optional<uint32_t> sampler;
  std::optional<uint32_t> source;
  std::optional<std::string> name;
};

class KHRTextureTransform {
public:
  std::optional<std::array<float, 2>> offset;
  std::optional<float> rotation;
  std::optional<std::array<float, 2>> scale;
  std::optional<uint32_t> texCoord;

  std::array<float, 2> offsetValue() const {
    return offset.value_or(std::array<float, 2>({0.0f, 0.0f}));
  }

  float rotationValue() const { return rotation.value_or(0); }

  std::array<float, 2> scaleValue() const {
    return scale.value_or(std::array<float, 2>({1.0f, 1.0f}));
  }
};

class TextureInfo {
public:
  uint32_t index;
  std::optional<uint32_t> texCoord;
  std::optional<KHRTextureTransform> khrTextureTransform;

  uint32_t texCoordValue() const { return texCoord.value_or(0); }
};

// Material

class MaterialPBRMetallicRoughness {
public:
  std::optional<std::array<float, 4>> baseColorFactor;
  std::optional<TextureInfo> baseColorTexture;
  std::optional<float> metallicFactor;
  std::optional<float> roughnessFactor;
  std::optional<TextureInfo> metallicRoughnessTexture;

  std::array<float, 4> baseColorFactorValue() const {
    return baseColorFactor.value_or(
        std::array<float, 4>{1.0f, 1.0f, 1.0f, 1.0f});
  }

  float metallicFactorValue() const { return metallicFactor.value_or(1.0f); }

  float roughnessFactorValue() const { return roughnessFactor.value_or(1.0f); }
};

class MaterialNormalTextureInfo : public TextureInfo {
public:
  std::optional<float> scale;

  float scaleValue() const { return scale.value_or(1.0f); }
};

class MaterialOcclusionTextureInfo : public TextureInfo {
public:
  std::optional<float> strength;

  float strengthValue() const { return strength.value_or(1.0f); }
};

class KHRMaterialAnisotropy {
public:
  std::optional<float> anisotropyStrength;
  std::optional<float> anisotropyRotation;
  std::optional<TextureInfo> anisotropyTexture;

  float anisotropyStrengthValue() const {
    return anisotropyStrength.value_or(0.0f);
  }

  float anisotropyRotationValue() const {
    return anisotropyRotation.value_or(0.0f);
  }
};

class KHRMaterialSheen {
public:
  std::optional<std::array<float, 3>> sheenColorFactor;
  std::optional<TextureInfo> sheenColorTexture;
  std::optional<float> sheenRoughnessFactor;
  std::optional<TextureInfo> sheenRoughnessTexture;

  std::array<float, 3> sheenColorFactorValue() const {
    return sheenColorFactor.value_or(std::array<float, 3>({0.0f, 0.0f, 0.0f}));
  }

  float sheenRoughnessFactorValue() const {
    return sheenRoughnessFactor.value_or(0);
  }
};

class KHRMaterialSpecular {
public:
  std::optional<float> specularFactor;
  std::optional<TextureInfo> specularTexture;
  std::optional<std::array<float, 3>> specularColorFactor;
  std::optional<TextureInfo> specularColorTexture;

  float specularFactorValue() const { return specularFactor.value_or(1.0f); }

  std::array<float, 3> specularColorFactorValue() {
    return specularColorFactor.value_or(
        std::array<float, 3>({1.0f, 1.0f, 1.0f}));
  }
};

class KHRMaterialIor {
public:
  std::optional<float> ior;

  float iorValue() const { return ior.value_or(1.5f); }
};

class KHRMaterialClearcoat {
public:
  std::optional<float> clearcoatFactor;
  std::optional<TextureInfo> clearcoatTexture;
  std::optional<float> clearcoatRoughnessFactor;
  std::optional<TextureInfo> clearcoatRoughnessTexture;
  std::optional<MaterialNormalTextureInfo> clearcoatNormalTexture;

  float clearcoatFactorValue() const { return clearcoatFactor.value_or(0.0f); }

  float clearcoatRoughnessFactorValue() const {
    return clearcoatRoughnessFactor.value_or(0.0f);
  }
};

class KHRMaterialDispersion {
public:
  std::optional<float> dispersion;

  float dispersionValue() const { return dispersion.value_or(0.0f); }
};

class KHRMaterialEmissiveStrength {
public:
  std::optional<float> emissiveStrength;

  float emissiveStrengthValue() const {
    return emissiveStrength.value_or(1.0f);
  }
};

class KHRMaterialIridescence {
public:
  std::optional<float> iridescenceFactor;
  std::optional<TextureInfo> iridescenceTexture;
  std::optional<float> iridescenceIor;
  std::optional<float> iridescenceThicknessMinimum;
  std::optional<float> iridescenceThicknessMaximum;
  std::optional<TextureInfo> iridescenceThicknessTexture;

  float iridescenceFactorValue() const {
    return iridescenceFactor.value_or(0.0f);
  }

  float iridescenceIorValue() const { return iridescenceIor.value_or(1.3f); }

  float iridescenceThicknessMinimumValue() const {
    return iridescenceThicknessMinimum.value_or(100.0f);
  }

  float iridescenceThicknessMaximumValue() const {
    return iridescenceThicknessMaximum.value_or(400.0f);
  }
};

class KHRMaterialVolume {
public:
  std::optional<float> thicknessFactor;
  std::optional<TextureInfo> thicknessTexture;
  std::optional<float> attenuationDistance;
  std::optional<std::array<float, 3>> attenuationColor;

  float thicknessFactorValue() const { return thicknessFactor.value_or(0.0f); }

  float attenuationDistanceValue() const {
    return attenuationDistance.value_or(std::numeric_limits<float>::infinity());
  }

  std::array<float, 3> attenuationColorValue() const {
    return attenuationColor.value_or(std::array<float, 3>({1.0f, 1.0f, 1.0f}));
  }
};

class KHRMaterialTransmission {
public:
  std::optional<float> transmissionFactor;
  std::optional<TextureInfo> transmissionTexture;

  float transmissionFactorValue() const {
    return transmissionFactor.value_or(0.0f);
  }
};


class Material {
public:
  enum class AlphaMode { OPAQUE, MASK, BLEND };

  static std::optional<AlphaMode>
  AlphaModeFromString(const std::string &value) {
    if (value == "OPAQUE")
      return AlphaMode::OPAQUE;
    else if (value == "MASK")
      return AlphaMode::MASK;
    else if (value == "BLEND")
      return AlphaMode::BLEND;
    else
      return std::nullopt;
  }

  std::optional<std::string> name;
  std::optional<MaterialPBRMetallicRoughness> pbrMetallicRoughness;
  std::optional<MaterialNormalTextureInfo> normalTexture;
  std::optional<MaterialOcclusionTextureInfo> occlusionTexture;
  std::optional<TextureInfo> emissiveTexture;
  std::optional<std::array<float, 3>> emissiveFactor;
  std::optional<AlphaMode> alphaMode;
  std::optional<float> alphaCutoff;
  std::optional<bool> doubleSided;
  std::optional<KHRMaterialAnisotropy> anisotropy;
  std::optional<KHRMaterialClearcoat> clearcoat;
  std::optional<KHRMaterialDispersion> dispersion;
  std::optional<KHRMaterialEmissiveStrength> emissiveStrength;
  std::optional<KHRMaterialIor> ior;
  std::optional<KHRMaterialIridescence> iridescence;
  std::optional<KHRMaterialSheen> sheen;
  std::optional<KHRMaterialSpecular> specular;
  std::optional<KHRMaterialTransmission> transmission;
  std::optional<bool> unlit;
  std::optional<KHRMaterialVolume> volume;

  std::array<float, 3> emissiveFactorValue() const {
    return emissiveFactor.value_or(std::array<float, 3>{0.0f, 0.0f, 0.0f});
  }

  AlphaMode alphaModeValue() const {
    return alphaMode.value_or(AlphaMode::OPAQUE);
  }

  float alphaCutoffValue() const { return alphaCutoff.value_or(0.5f); }

  bool isDoubleSided() const { return doubleSided.value_or(false); }

  bool isUnlit() const { return unlit.value_or(false); }
};

// Mesh

class MeshPrimitiveTarget {
public:
  std::optional<uint32_t> position;
  std::optional<uint32_t> normal;
  std::optional<uint32_t> tangent;
};

class MeshPrimitiveAttributes : public MeshPrimitiveTarget {
public:
  std::optional<std::vector<uint32_t>> texcoords;
  std::optional<std::vector<uint32_t>> colors;
  std::optional<std::vector<uint32_t>> joints;
  std::optional<std::vector<uint32_t>> weights;
};

class MeshPrimitiveDracoExtension {
public:
  uint32_t bufferView;
  MeshPrimitiveAttributes attributes;
};

class MeshPrimitive {
public:
  enum class Mode {
    POINTS = 0,
    LINES = 1,
    LINE_LOOP = 2,
    LINE_STRIP = 3,
    TRIANGLES = 4,
    TRIANGLE_STRIP = 5,

    TRIANGLE_FAN = 6
  };

  static std::optional<Mode> ModeFromInt(uint32_t value) {
    switch (value) {
    case 0:
      return Mode::POINTS;
    case 1:
      return Mode::LINES;
    case 2:
      return Mode::LINE_LOOP;
    case 3:
      return Mode::LINE_STRIP;
    case 4:
      return Mode::TRIANGLES;
    case 5:
      return Mode::TRIANGLE_STRIP;
    case 6:
      return Mode::TRIANGLE_FAN;
    default:
      return std::nullopt;
    }
  }
  MeshPrimitiveAttributes attributes;
  std::optional<uint32_t> indices;
  std::optional<uint32_t> material;
  std::optional<Mode> mode;
  std::optional<std::vector<MeshPrimitiveTarget>> targets;
  std::optional<MeshPrimitiveDracoExtension> dracoExtension;

  Mode modeValue() const { return mode.value_or(Mode::TRIANGLES); }
};

class Mesh {
public:
  std::vector<MeshPrimitive> primitives;
  std::optional<std::vector<float>> weights;
  std::optional<std::string> name;
};

// Node

class Node {
public:
  std::optional<uint32_t> camera;
  std::optional<std::vector<uint32_t>> children;
  std::optional<uint32_t> skin;
  std::optional<std::array<float, 16>> matrix;
  std::optional<uint32_t> mesh;
  std::optional<std::array<float, 4>> rotation;
  std::optional<std::array<float, 3>> scale;
  std::optional<std::array<float, 3>> translation;
  std::optional<std::vector<float>> weights;
  std::optional<std::string> name;

  std::array<float, 16> matrixValue() const {
    return matrix.value_or(std::array<float, 16>{
        1.0f,
        0.0f,
        0.0f,
        0.0f,
        0.0f,
        1.0f,
        0.0f,
        0.0f,
        0.0f,
        0.0f,
        1.0f,
        0.0f,
        0.0f,
        0.0f,
        0.0f,
        1.0f,
    });
  }

  std::array<float, 4> rotationValue() const {
    return rotation.value_or(std::array<float, 4>{0.0f, 0.0f, 0.0f, 1.0f});
  }

  std::array<float, 3> scaleValue() const {
    return scale.value_or(std::array<float, 3>{1.0f, 1.0f, 1.0f});
  }

  std::array<float, 3> translationValue() const {
    return translation.value_or(std::array<float, 3>{0.0f, 0.0f, 0.0f});
  }
};

// Sampler

class Sampler {
public:
  enum class MagFilter { NEAREST = 9728, LINEAR = 9729 };

  enum class MinFilter {
    NEAREST = 9728,
    LINEAR = 9729,
    NEAREST_MIPMAP_NEAREST = 9984,
    LINEAR_MIPMAP_NEAREST = 9985,
    NEAREST_MIPMAP_LINEAR = 9986,
    LINEAR_MIPMAP_LINEAR = 9987
  };

  enum class WrapMode {
    CLAMP_TO_EDGE = 33071,
    MIRRORED_REPEAT = 33648,
    REPEAT = 10497
  };

  static std::optional<MagFilter> MagFilterFromInt(uint32_t value) {
    switch (value) {
    case 9728:
      return MagFilter::NEAREST;
    case 9729:
      return MagFilter::LINEAR;
    default:
      return std::nullopt;
    }
  }

  static std::optional<MinFilter> MinFilterFromInt(uint32_t value) {
    switch (value) {
    case 9728:
      return MinFilter::NEAREST;
    case 9729:
      return MinFilter::LINEAR;
    case 9984:
      return MinFilter::NEAREST_MIPMAP_NEAREST;
    case 9985:
      return MinFilter::LINEAR_MIPMAP_NEAREST;
    case 9986:
      return MinFilter::NEAREST_MIPMAP_LINEAR;
    case 9987:
      return MinFilter::LINEAR_MIPMAP_LINEAR;
    default:
      return std::nullopt;
    }
  }

  static std::optional<WrapMode> WrapModeFromInt(uint32_t value) {
    switch (value) {
    case 33071:
      return WrapMode::CLAMP_TO_EDGE;
    case 33648:
      return WrapMode::MIRRORED_REPEAT;
    case 10497:
      return WrapMode::REPEAT;
    default:
      return std::nullopt;
    }
  }

  std::optional<MagFilter> magFilter;
  std::optional<MinFilter> minFilter;
  std::optional<WrapMode> wrapS;
  std::optional<WrapMode> wrapT;
  std::optional<std::string> name;

  WrapMode wrapSValue() const { return wrapS.value_or(WrapMode::REPEAT); }

  WrapMode wrapTValue() const { return wrapT.value_or(WrapMode::REPEAT); }
};

// Scene

class Scene {
public:
  std::optional<std::vector<uint32_t>> nodes;
  std::optional<std::string> name;
};

// Skin

class Skin {
public:
  std::optional<uint32_t> inverseBindMatrices;
  std::optional<uint32_t> skeleton;
  std::vector<uint32_t> joints;
  std::optional<std::string> name;
};

// Light

class KHRLightSpot {
public:
  std::optional<float> innerConeAngle;
  std::optional<float> outerConeAngle;

  float innerConeAngleValue() const { return innerConeAngle.value_or(0.0f); }

  float outerConeAngleValue() const {
    return outerConeAngle.value_or(M_PI / 4.0f);
  }
};

class KHRLight {
public:
  enum class Type { POINT, SPOT, DIRECTIONAL };

  static std::optional<Type> TypeFromString(const std::string &value) {
    if (value == "point")
      return Type::POINT;
    else if (value == "spot")
      return Type::SPOT;
    else if (value == "directional")
      return Type::DIRECTIONAL;
    else
      return std::nullopt;
  }

  std::optional<std::string> name;
  std::optional<std::array<float, 3>> color;
  std::optional<float> intensity;
  Type type;
  std::optional<KHRLightSpot> spot;

  float intensityValue() const { return intensity.value_or(1.0f); }

  std::array<float, 3> colorValue() const {
    return color.value_or(std::array<float, 3>{1.0f, 1.0f, 1.0f});
  }
};

// Json

class Json {
public:
  std::optional<std::vector<std::string>> extensionsUsed;
  std::optional<std::vector<std::string>> extensionsRequired;
  std::optional<std::vector<Accessor>> accessors;
  std::optional<std::vector<Animation>> animations;
  Asset asset;
  std::optional<std::vector<Buffer>> buffers;
  std::optional<std::vector<BufferView>> bufferViews;
  std::optional<std::vector<Camera>> cameras;
  std::optional<std::vector<Image>> images;
  std::optional<std::vector<Material>> materials;
  std::optional<std::vector<Mesh>> meshes;
  std::optional<std::vector<Node>> nodes;
  std::optional<std::vector<Sampler>> samplers;
  std::optional<uint32_t> scene;
  std::optional<std::vector<Scene>> scenes;
  std::optional<std::vector<Skin>> skins;
  std::optional<std::vector<Texture>> textures;
  std::optional<std::vector<KHRLight>> lights;
  std::optional<vrm0::VRM> vrm0;
  std::optional<vrmc::VRM> vrm1;
  std::optional<vrmc::SpringBone> springBone;
};

} // namespace json
}; // namespace gltf2

#endif /* Json_h */
