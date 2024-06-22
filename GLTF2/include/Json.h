#ifndef Json_h
#define Json_h

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

class VRMCMeta {
public:
  enum class AvatarPermission {
    ONLY_AUTHOR,
    ONLY_SEPARATELY_LICENSED_PERSON,
    EVERYONE
  };

  enum class CommercialUsage {
    PERSONAL_NON_PROFIT,
    PERSONAL_PROFIT,
    CORPORATION
  };

  enum class CreditNotation { REQUIRED, UNNECESSARY };

  enum class Modification {
    PROHIBITED,
    ALLOW_MODIFICATION,
    ALLOW_MODIFICATION_REDISTRIBUTION
  };

  static std::optional<AvatarPermission>
  AvatarPermissionFromString(const std::string &value) {
    if (value == "onlyAuthor")
      return AvatarPermission::ONLY_AUTHOR;
    if (value == "onlySeparatelyLicensedPerson")
      return AvatarPermission::ONLY_SEPARATELY_LICENSED_PERSON;
    if (value == "everyone")
      return AvatarPermission::EVERYONE;
    return std::nullopt;
  }

  static std::optional<CommercialUsage>
  CommercialUsageFromString(const std::string &value) {
    if (value == "personalNonProfit")
      return CommercialUsage::PERSONAL_NON_PROFIT;
    if (value == "personalProfit")
      return CommercialUsage::PERSONAL_PROFIT;
    if (value == "corporation")
      return CommercialUsage::CORPORATION;
    return std::nullopt;
  }

  static std::optional<CreditNotation>
  CreditNotationFromString(const std::string &value) {
    if (value == "required")
      return CreditNotation::REQUIRED;
    if (value == "unnecessary")
      return CreditNotation::UNNECESSARY;
    return std::nullopt;
  }

  static std::optional<Modification>
  ModificationFromString(const std::string &value) {
    if (value == "prohibited")
      return Modification::PROHIBITED;
    if (value == "allowModification")
      return Modification::ALLOW_MODIFICATION;
    if (value == "allowModificationRedistribution")
      return Modification::ALLOW_MODIFICATION_REDISTRIBUTION;
    return std::nullopt;
  }

  std::string name;
  std::optional<std::string> version;
  std::vector<std::string> authors;
  std::optional<std::string> copyrightInformation;
  std::optional<std::string> contactInformation;
  std::optional<std::vector<std::string>> references;
  std::optional<std::string> thirdPartyLicenses;
  std::optional<uint32_t> thumbnailImage;
  std::string licenseUrl;
  std::optional<AvatarPermission> avatarPermission;
  std::optional<bool> allowExcessivelyViolentUsage;
  std::optional<bool> allowExcessivelySexualUsage;
  std::optional<CommercialUsage> commercialUsage;
  std::optional<bool> allowPoliticalOrReligiousUsage;
  std::optional<bool> allowAntisocialOrHateUsage;
  std::optional<CreditNotation> creditNotation;
  std::optional<bool> allowRedistribution;
  std::optional<Modification> modification;
  std::optional<std::string> otherLicenseUrl;

  AvatarPermission avatarPermissionValue() const {
    return avatarPermission.value_or(AvatarPermission::ONLY_AUTHOR);
  }

  bool allowExcessivelyViolentUsageValue() const {
    return allowExcessivelyViolentUsage.value_or(false);
  }

  bool allowExcessivelySexualUsageValue() const {
    return allowExcessivelySexualUsage.value_or(false);
  }

  CommercialUsage commercialUsageValue() const {
    return commercialUsage.value_or(CommercialUsage::PERSONAL_NON_PROFIT);
  }

  bool allowPoliticalOrReligiousUsageValue() const {
    return allowPoliticalOrReligiousUsage.value_or(false);
  }

  bool allowAntisocialOrHateUsageValue() const {
    return allowAntisocialOrHateUsage.value_or(false);
  }

  CreditNotation creditNotationValue() const {
    return creditNotation.value_or(CreditNotation::REQUIRED);
  }

  Modification modificationValue() const {
    return modification.value_or(Modification::PROHIBITED);
  }
};

class VRMCHumanBone {
public:
  uint32_t node;
};

class VRMCHumanBones {
public:
  VRMCHumanBone hips;
  VRMCHumanBone spine;
  std::optional<VRMCHumanBone> chest;
  std::optional<VRMCHumanBone> upperChest;
  std::optional<VRMCHumanBone> neck;
  VRMCHumanBone head;
  std::optional<VRMCHumanBone> leftEye;
  std::optional<VRMCHumanBone> rightEye;
  std::optional<VRMCHumanBone> jaw;
  VRMCHumanBone leftUpperLeg;
  VRMCHumanBone leftLowerLeg;
  VRMCHumanBone leftFoot;
  std::optional<VRMCHumanBone> leftToes;
  VRMCHumanBone rightUpperLeg;
  VRMCHumanBone rightLowerLeg;
  VRMCHumanBone rightFoot;
  std::optional<VRMCHumanBone> rightToes;
  std::optional<VRMCHumanBone> leftShoulder;
  VRMCHumanBone leftUpperArm;
  VRMCHumanBone leftLowerArm;
  VRMCHumanBone leftHand;
  std::optional<VRMCHumanBone> rightShoulder;
  VRMCHumanBone rightUpperArm;
  VRMCHumanBone rightLowerArm;
  VRMCHumanBone rightHand;
  std::optional<VRMCHumanBone> leftThumbMetacarpal;
  std::optional<VRMCHumanBone> leftThumbProximal;
  std::optional<VRMCHumanBone> leftThumbDistal;
  std::optional<VRMCHumanBone> leftIndexProximal;
  std::optional<VRMCHumanBone> leftIndexIntermediate;
  std::optional<VRMCHumanBone> leftIndexDistal;
  std::optional<VRMCHumanBone> leftMiddleProximal;
  std::optional<VRMCHumanBone> leftMiddleIntermediate;
  std::optional<VRMCHumanBone> leftMiddleDistal;
  std::optional<VRMCHumanBone> leftRingProximal;
  std::optional<VRMCHumanBone> leftRingIntermediate;
  std::optional<VRMCHumanBone> leftRingDistal;
  std::optional<VRMCHumanBone> leftLittleProximal;
  std::optional<VRMCHumanBone> leftLittleIntermediate;
  std::optional<VRMCHumanBone> leftLittleDistal;
  std::optional<VRMCHumanBone> rightThumbMetacarpal;
  std::optional<VRMCHumanBone> rightThumbProximal;
  std::optional<VRMCHumanBone> rightThumbDistal;
  std::optional<VRMCHumanBone> rightIndexProximal;
  std::optional<VRMCHumanBone> rightIndexIntermediate;
  std::optional<VRMCHumanBone> rightIndexDistal;
  std::optional<VRMCHumanBone> rightMiddleProximal;
  std::optional<VRMCHumanBone> rightMiddleIntermediate;
  std::optional<VRMCHumanBone> rightMiddleDistal;
  std::optional<VRMCHumanBone> rightRingProximal;
  std::optional<VRMCHumanBone> rightRingIntermediate;
  std::optional<VRMCHumanBone> rightRingDistal;
  std::optional<VRMCHumanBone> rightLittleProximal;
  std::optional<VRMCHumanBone> rightLittleIntermediate;
  std::optional<VRMCHumanBone> rightLittleDistal;
};

class VRMCHumanoid {
public:
  VRMCHumanBones humanBones;
};

class VRMCFirstPersonMeshAnnotation {
public:
  enum class Type { AUTO, BOTH, THIRD_PERSON_ONLY, FIRST_PERSON_ONLY };

  static std::optional<Type> TypeFromString(const std::string &value) {
    if (value == "auto")
      return Type::AUTO;
    else if (value == "both")
      return Type::BOTH;
    else if (value == "thirdPersonOnly")
      return Type::THIRD_PERSON_ONLY;
    else if (value == "firstPersonOnly")
      return Type::FIRST_PERSON_ONLY;
    else
      return std::nullopt;
  }

  uint32_t node;
  Type type;
};

class VRMCFirstPerson {
public:
  std::optional<std::vector<VRMCFirstPersonMeshAnnotation>> meshAnnotations;
};

class VRMCLookAtRangeMap {
public:
  std::optional<float> inputMaxValue;
  std::optional<float> outputScale;
};

class VRMCLookAt {
public:
  enum class Type { BONE, EXPRESSION };

  static std::optional<Type> TypeFromString(const std::string &value) {
    if (value == "bone")
      return Type::BONE;
    else if (value == "expression")
      return Type::EXPRESSION;
    else
      return std::nullopt;
  }

  std::optional<std::array<float, 3>> offsetFromHeadBone;
  std::optional<Type> type;
  std::optional<VRMCLookAtRangeMap> rangeMapHorizontalInner;
  std::optional<VRMCLookAtRangeMap> rangeMapHorizontalOuter;
  std::optional<VRMCLookAtRangeMap> rangeMapVerticalDown;
  std::optional<VRMCLookAtRangeMap> rangeMapVerticalUp;
};

class VRMCExpressionMaterialColorBind {
public:
  enum class Type {
    COLOR,
    EMISSION_COLOR,
    SHADE_COLOR,
    MATCAP_COLOR,
    RIM_COLOR,
    OUTLINE_COLOR
  };

  static std::optional<Type> TypeFromString(const std::string &value) {
    if (value == "color")
      return Type::COLOR;
    else if (value == "emissionColor")
      return Type::EMISSION_COLOR;
    else if (value == "shadeColor")
      return Type::SHADE_COLOR;
    else if (value == "matcapColor")
      return Type::MATCAP_COLOR;
    else if (value == "rimColor")
      return Type::RIM_COLOR;
    else if (value == "outlineColor")
      return Type::OUTLINE_COLOR;
    else
      return std::nullopt;
  }

  uint32_t material;
  Type type;
  std::array<float, 4> targetValue;
};

class VRMCExpressionMorphTargetBind {
public:
  uint32_t node;
  uint32_t index;
  float weight;
};

class VRMCExpressionTextureTransformBind {
public:
  uint32_t material;
  std::optional<std::array<float, 2>> scale;
  std::optional<std::array<float, 2>> offset;

  std::array<float, 2> scaleValue() const {
    return scale.value_or(std::array<float, 2>{1.0f, 1.0f});
  }

  std::array<float, 2> offsetValue() const {
    return offset.value_or(std::array<float, 2>{0.0f, 0.0f});
  }
};

class VRMCExpression {
public:
  enum class Override { NONE, BLOCK, BLEND };

  static std::optional<Override> OverrideFromString(const std::string &value) {
    if (value == "none")
      return Override::NONE;
    else if (value == "block")
      return Override::BLOCK;
    else if (value == "blend")
      return Override::BLEND;
    else
      return std::nullopt;
  }

  std::optional<std::vector<VRMCExpressionMorphTargetBind>> morphTargetBinds;
  std::optional<std::vector<VRMCExpressionMaterialColorBind>>
      materialColorBinds;
  std::optional<std::vector<VRMCExpressionTextureTransformBind>>
      textureTransformBinds;
  std::optional<bool> isBinary;
  std::optional<Override> overrideBlink;
  std::optional<Override> overrideLookAt;
  std::optional<Override> overrideMouth;

  bool isBinaryValue() const { return isBinary.value_or(false); }

  Override overrideBlinkValue() const {
    return overrideBlink.value_or(Override::NONE);
  }

  Override overrideLookAtValue() const {
    return overrideLookAt.value_or(Override::NONE);
  }

  Override overrideMouthValue() const {
    return overrideMouth.value_or(Override::NONE);
  }
};

class VRMCExpressionsPreset {
public:
  std::optional<VRMCExpression> happy;
  std::optional<VRMCExpression> angry;
  std::optional<VRMCExpression> sad;
  std::optional<VRMCExpression> relaxed;
  std::optional<VRMCExpression> surprised;
  std::optional<VRMCExpression> aa;
  std::optional<VRMCExpression> ih;
  std::optional<VRMCExpression> ou;
  std::optional<VRMCExpression> ee;
  std::optional<VRMCExpression> oh;
  std::optional<VRMCExpression> blink;
  std::optional<VRMCExpression> blinkLeft;
  std::optional<VRMCExpression> blinkRight;
  std::optional<VRMCExpression> lookUp;
  std::optional<VRMCExpression> lookDown;
  std::optional<VRMCExpression> lookLeft;
  std::optional<VRMCExpression> lookRight;
  std::optional<VRMCExpression> neutral;

  std::vector<std::string> expressionNames() const {
    std::vector<std::string> names;
    if (happy.has_value()) {
      names.push_back("happy");
    }
    if (angry.has_value()) {
      names.push_back("angry");
    }
    if (sad.has_value()) {
      names.push_back("sad");
    }
    if (relaxed.has_value()) {
      names.push_back("relaxed");
    }
    if (surprised.has_value()) {
      names.push_back("surprised");
    }
    if (aa.has_value()) {
      names.push_back("aa");
    }
    if (ih.has_value()) {
      names.push_back("ih");
    }
    if (ou.has_value()) {
      names.push_back("ou");
    }
    if (ee.has_value()) {
      names.push_back("ee");
    }
    if (oh.has_value()) {
      names.push_back("oh");
    }
    if (blink.has_value()) {
      names.push_back("blink");
    }
    if (blinkLeft.has_value()) {
      names.push_back("blinkLeft");
    }
    if (blinkRight.has_value()) {
      names.push_back("blinkRight");
    }
    if (lookUp.has_value()) {
      names.push_back("lookUp");
    }
    if (lookDown.has_value()) {
      names.push_back("lookDown");
    }
    if (lookLeft.has_value()) {
      names.push_back("lookLeft");
    }
    if (lookRight.has_value()) {
      names.push_back("lookRight");
    }
    if (neutral.has_value()) {
      names.push_back("neutral");
    }
    return names;
  }
};

class VRMCExpressions {
public:
  std::optional<VRMCExpressionsPreset> preset;
  std::optional<std::map<std::string, VRMCExpression>> custom;

  const VRMCExpression *expressionByName(std::string name) const {
    std::transform(name.begin(), name.end(), name.begin(), ::tolower);

    if (preset) {
      if (name == "happy") {
        return preset->happy.has_value() ? &(*preset->happy) : nullptr;
      } else if (name == "angry") {
        return preset->angry.has_value() ? &(*preset->angry) : nullptr;
      } else if (name == "sad") {
        return preset->sad.has_value() ? &(*preset->sad) : nullptr;
      } else if (name == "relaxed") {
        return preset->relaxed.has_value() ? &(*preset->relaxed) : nullptr;
      } else if (name == "surprised") {
        return preset->surprised.has_value() ? &(*preset->surprised) : nullptr;
      } else if (name == "aa") {
        return preset->aa.has_value() ? &(*preset->aa) : nullptr;
      } else if (name == "ih") {
        return preset->ih.has_value() ? &(*preset->ih) : nullptr;
      } else if (name == "ou") {
        return preset->ou.has_value() ? &(*preset->ou) : nullptr;
      } else if (name == "ee") {
        return preset->ee.has_value() ? &(*preset->ee) : nullptr;
      } else if (name == "oh") {
        return preset->oh.has_value() ? &(*preset->oh) : nullptr;
      } else if (name == "blink") {
        return preset->blink.has_value() ? &(*preset->blink) : nullptr;
      } else if (name == "blinkleft") {
        return preset->blinkLeft.has_value() ? &(*preset->blinkLeft) : nullptr;
      } else if (name == "blinkright") {
        return preset->blinkRight.has_value() ? &(*preset->blinkRight)
                                              : nullptr;
      } else if (name == "lookup") {
        return preset->lookUp.has_value() ? &(*preset->lookUp) : nullptr;
      } else if (name == "lookdown") {
        return preset->lookDown.has_value() ? &(*preset->lookDown) : nullptr;
      } else if (name == "lookleft") {
        return preset->lookLeft.has_value() ? &(*preset->lookLeft) : nullptr;
      } else if (name == "lookright") {
        return preset->lookRight.has_value() ? &(*preset->lookRight) : nullptr;
      } else if (name == "neutral") {
        return preset->neutral.has_value() ? &(*preset->neutral) : nullptr;
      }
    }

    if (custom) {
      for (const auto &pair : *custom) {
        std::string key = pair.first;
        std::transform(key.begin(), key.end(), key.begin(), ::tolower);
        if (key == name) {
          return &pair.second;
        }
      }
    }

    return nullptr;
  }

  std::vector<std::string> expressionNames() const {
    std::vector<std::string> names;
    if (preset.has_value()) {
      names = preset->expressionNames();
    }
    if (custom.has_value()) {
      for (const auto &pair : *custom) {
        names.push_back(pair.first);
      }
    }
    return names;
  }
};

class VRMCVrm {
public:
  std::string specVersion;
  VRMCMeta meta;
  VRMCHumanoid humanoid;
  std::optional<VRMCFirstPerson> firstPerson;
  std::optional<VRMCLookAt> lookAt;
  std::optional<VRMCExpressions> expressions;

  const VRMCExpression *expressionByName(const std::string &name) const {
    if (!expressions.has_value())
      return nullptr;
    return expressions->expressionByName(name);
  }
};

// VRM0

struct VRMVec3 {
  std::optional<float> x;
  std::optional<float> y;
  std::optional<float> z;

  static VRMVec3 zero() {
    VRMVec3 v;
    v.x = 0;
    v.y = 0;
    v.z = 0;
    return v;
  }
};

class VRMHumanoidBone {
public:
  enum class Bone {
    HIPS,
    LEFT_UPPER_LEG,
    RIGHT_UPPER_LEG,
    LEFT_LOWER_LEG,
    RIGHT_LOWER_LEG,
    LEFT_FOOT,
    RIGHT_FOOT,
    SPINE,
    CHEST,
    NECK,
    HEAD,
    LEFT_SHOULDER,
    RIGHT_SHOULDER,
    LEFT_UPPER_ARM,
    RIGHT_UPPER_ARM,
    LEFT_LOWER_ARM,
    RIGHT_LOWER_ARM,
    LEFT_HAND,
    RIGHT_HAND,
    LEFT_TOES,
    RIGHT_TOES,
    LEFT_EYE,
    RIGHT_EYE,
    JAW,
    LEFT_THUMB_PROXIMAL,
    LEFT_THUMB_INTERMEDIATE,
    LEFT_THUMB_DISTAL,
    LEFT_INDEX_PROXIMAL,
    LEFT_INDEX_INTERMEDIATE,
    LEFT_INDEX_DISTAL,
    LEFT_MIDDLE_PROXIMAL,
    LEFT_MIDDLE_INTERMEDIATE,
    LEFT_MIDDLE_DISTAL,
    LEFT_RING_PROXIMAL,
    LEFT_RING_INTERMEDIATE,
    LEFT_RING_DISTAL,
    LEFT_LITTLE_PROXIMAL,
    LEFT_LITTLE_INTERMEDIATE,
    LEFT_LITTLE_DISTAL,
    RIGHT_THUMB_PROXIMAL,
    RIGHT_THUMB_INTERMEDIATE,
    RIGHT_THUMB_DISTAL,
    RIGHT_INDEX_PROXIMAL,
    RIGHT_INDEX_INTERMEDIATE,
    RIGHT_INDEX_DISTAL,
    RIGHT_MIDDLE_PROXIMAL,
    RIGHT_MIDDLE_INTERMEDIATE,
    RIGHT_MIDDLE_DISTAL,
    RIGHT_RING_PROXIMAL,
    RIGHT_RING_INTERMEDIATE,
    RIGHT_RING_DISTAL,
    RIGHT_LITTLE_PROXIMAL,
    RIGHT_LITTLE_INTERMEDIATE,
    RIGHT_LITTLE_DISTAL,
    UPPER_CHEST
  };

  static std::optional<Bone> BoneFromString(const std::string &value) {
    if (value == "hips")
      return Bone::HIPS;
    if (value == "leftUpperLeg")
      return Bone::LEFT_UPPER_LEG;
    if (value == "rightUpperLeg")
      return Bone::RIGHT_UPPER_LEG;
    if (value == "leftLowerLeg")
      return Bone::LEFT_LOWER_LEG;
    if (value == "rightLowerLeg")
      return Bone::RIGHT_LOWER_LEG;
    if (value == "leftFoot")
      return Bone::LEFT_FOOT;
    if (value == "rightFoot")
      return Bone::RIGHT_FOOT;
    if (value == "spine")
      return Bone::SPINE;
    if (value == "chest")
      return Bone::CHEST;
    if (value == "neck")
      return Bone::NECK;
    if (value == "head")
      return Bone::HEAD;
    if (value == "leftShoulder")
      return Bone::LEFT_SHOULDER;
    if (value == "rightShoulder")
      return Bone::RIGHT_SHOULDER;
    if (value == "leftUpperArm")
      return Bone::LEFT_UPPER_ARM;
    if (value == "rightUpperArm")
      return Bone::RIGHT_UPPER_ARM;
    if (value == "leftLowerArm")
      return Bone::LEFT_LOWER_ARM;
    if (value == "rightLowerArm")
      return Bone::RIGHT_LOWER_ARM;
    if (value == "leftHand")
      return Bone::LEFT_HAND;
    if (value == "rightHand")
      return Bone::RIGHT_HAND;
    if (value == "leftToes")
      return Bone::LEFT_TOES;
    if (value == "rightToes")
      return Bone::RIGHT_TOES;
    if (value == "leftEye")
      return Bone::LEFT_EYE;
    if (value == "rightEye")
      return Bone::RIGHT_EYE;
    if (value == "jaw")
      return Bone::JAW;
    if (value == "leftThumbProximal")
      return Bone::LEFT_THUMB_PROXIMAL;
    if (value == "leftThumbIntermediate")
      return Bone::LEFT_THUMB_INTERMEDIATE;
    if (value == "leftThumbDistal")
      return Bone::LEFT_THUMB_DISTAL;
    if (value == "leftIndexProximal")
      return Bone::LEFT_INDEX_PROXIMAL;
    if (value == "leftIndexIntermediate")
      return Bone::LEFT_INDEX_INTERMEDIATE;
    if (value == "leftIndexDistal")
      return Bone::LEFT_INDEX_DISTAL;
    if (value == "leftMiddleProximal")
      return Bone::LEFT_MIDDLE_PROXIMAL;
    if (value == "leftMiddleIntermediate")
      return Bone::LEFT_MIDDLE_INTERMEDIATE;
    if (value == "leftMiddleDistal")
      return Bone::LEFT_MIDDLE_DISTAL;
    if (value == "leftRingProximal")
      return Bone::LEFT_RING_PROXIMAL;
    if (value == "leftRingIntermediate")
      return Bone::LEFT_RING_INTERMEDIATE;
    if (value == "leftRingDistal")
      return Bone::LEFT_RING_DISTAL;
    if (value == "leftLittleProximal")
      return Bone::LEFT_LITTLE_PROXIMAL;
    if (value == "leftLittleIntermediate")
      return Bone::LEFT_LITTLE_INTERMEDIATE;
    if (value == "leftLittleDistal")
      return Bone::LEFT_LITTLE_DISTAL;
    if (value == "rightThumbProximal")
      return Bone::RIGHT_THUMB_PROXIMAL;
    if (value == "rightThumbIntermediate")
      return Bone::RIGHT_THUMB_INTERMEDIATE;
    if (value == "rightThumbDistal")
      return Bone::RIGHT_THUMB_DISTAL;
    if (value == "rightIndexProximal")
      return Bone::RIGHT_INDEX_PROXIMAL;
    if (value == "rightIndexIntermediate")
      return Bone::RIGHT_INDEX_INTERMEDIATE;
    if (value == "rightIndexDistal")
      return Bone::RIGHT_INDEX_DISTAL;
    if (value == "rightMiddleProximal")
      return Bone::RIGHT_MIDDLE_PROXIMAL;
    if (value == "rightMiddleIntermediate")
      return Bone::RIGHT_MIDDLE_INTERMEDIATE;
    if (value == "rightMiddleDistal")
      return Bone::RIGHT_MIDDLE_DISTAL;
    if (value == "rightRingProximal")
      return Bone::RIGHT_RING_PROXIMAL;
    if (value == "rightRingIntermediate")
      return Bone::RIGHT_RING_INTERMEDIATE;
    if (value == "rightRingDistal")
      return Bone::RIGHT_RING_DISTAL;
    if (value == "rightLittleProximal")
      return Bone::RIGHT_LITTLE_PROXIMAL;
    if (value == "rightLittleIntermediate")
      return Bone::RIGHT_LITTLE_INTERMEDIATE;
    if (value == "rightLittleDistal")
      return Bone::RIGHT_LITTLE_DISTAL;
    if (value == "upperChest")
      return Bone::UPPER_CHEST;
    return std::nullopt;
  }

  std::optional<Bone> bone;
  std::optional<uint32_t> node;
  std::optional<bool> useDefaultValues;
  std::optional<VRMVec3> min;
  std::optional<VRMVec3> max;
  std::optional<VRMVec3> center;
  std::optional<float> axisLength;
};

class VRMHumanoid {
public:
  std::optional<std::vector<VRMHumanoidBone>> humanBones;
  std::optional<float> armStretch;
  std::optional<float> legStretch;
  std::optional<float> upperArmTwist;
  std::optional<float> lowerArmTwist;
  std::optional<float> upperLegTwist;
  std::optional<float> lowerLegTwist;
  std::optional<float> feetSpacing;
  std::optional<bool> hasTranslationDoF;
};

class VRMMeta {
public:
  enum class AllowedUserName {
    ONLY_AUTHOR,
    EXPLICITLY_LICENSED_PERSON,
    EVERYONE
  };

  enum class UsagePermission { DISALLOW, ALLOW };

  enum class LicenseName {
    REDISTRIBUTION_PROHIBITED,
    CC0,
    CC_BY,
    CC_BY_NC,
    CC_BY_SA,
    CC_BY_NC_SA,
    CC_BY_ND,
    CC_BY_NC_ND,
    OTHER
  };

  static std::optional<AllowedUserName>
  AllowedUserNameFromString(const std::string &value) {
    if (value == "OnlyAuthor")
      return AllowedUserName::ONLY_AUTHOR;
    if (value == "ExplicitlyLicensedPerson")
      return AllowedUserName::EXPLICITLY_LICENSED_PERSON;
    if (value == "Everyone")
      return AllowedUserName::EVERYONE;
    return std::nullopt;
  }

  static std::optional<UsagePermission>
  UsagePermissionFromString(const std::string &value) {
    if (value == "Disallow")
      return UsagePermission::DISALLOW;
    if (value == "Allow")
      return UsagePermission::ALLOW;
    return std::nullopt;
  }

  static std::optional<LicenseName>
  LicenseNameFromString(const std::string &value) {
    if (value == "Redistribution_Prohibited")
      return LicenseName::REDISTRIBUTION_PROHIBITED;
    if (value == "CC0")
      return LicenseName::CC0;
    if (value == "CC_BY")
      return LicenseName::CC_BY;
    if (value == "CC_BY_NC")
      return LicenseName::CC_BY_NC;
    if (value == "CC_BY_SA")
      return LicenseName::CC_BY_SA;
    if (value == "CC_BY_NC_SA")
      return LicenseName::CC_BY_NC_SA;
    if (value == "CC_BY_ND")
      return LicenseName::CC_BY_ND;
    if (value == "CC_BY_NC_ND")
      return LicenseName::CC_BY_NC_ND;
    if (value == "Other")
      return LicenseName::OTHER;
    return std::nullopt;
  }

  std::optional<std::string> title;
  std::optional<std::string> version;
  std::optional<std::string> author;
  std::optional<std::string> contactInformation;
  std::optional<std::string> reference;
  std::optional<uint32_t> texture;
  std::optional<AllowedUserName> allowedUserName;
  std::optional<UsagePermission> violentUsage;
  std::optional<UsagePermission> sexualUsage;
  std::optional<UsagePermission> commercialUsage;
  std::optional<std::string> otherPermissionUrl;
  std::optional<LicenseName> licenseName;
  std::optional<std::string> otherLicenseUrl;

  AllowedUserName allowedUserNameValue() const {
    return allowedUserName.value_or(AllowedUserName::ONLY_AUTHOR);
  }

  UsagePermission violentUsageValue() const {
    return violentUsage.value_or(UsagePermission::DISALLOW);
  }

  UsagePermission sexualUsageValue() const {
    return sexualUsage.value_or(UsagePermission::DISALLOW);
  }

  UsagePermission commercialUsageValue() const {
    return commercialUsage.value_or(UsagePermission::DISALLOW);
  }

  LicenseName licenseNameValue() const {
    return licenseName.value_or(LicenseName::REDISTRIBUTION_PROHIBITED);
  }
};

class VRMMeshAnnotation {
public:
  std::optional<uint32_t> mesh;
  std::optional<std::string> firstPersonFlag;
};

class VRMDegreeMapCurveMapping {
public:
  float time;
  float value;
  float inTangent;
  float outTangent;
};

class VRMDegreeMap {
public:
  std::optional<std::vector<VRMDegreeMapCurveMapping>> curve;
  std::optional<float> xRange;
  std::optional<float> yRange;
};

class VRMFirstPerson {
public:
  enum class LookAtType { BONE, BLEND_SHAPE };

  static std::optional<LookAtType>
  LookAtTypeFromString(const std::string &value) {
    if (value == "Bone")
      return LookAtType::BONE;
    else if (value == "BlendShape")
      return LookAtType::BLEND_SHAPE;
    else
      return std::nullopt;
  }

  std::optional<uint32_t> firstPersonBone;
  std::optional<VRMVec3> firstPersonBoneOffset;
  std::optional<std::vector<VRMMeshAnnotation>> meshAnnotations;
  std::optional<LookAtType> lookAtTypeName;
  std::optional<VRMDegreeMap> lookAtHorizontalInner;
  std::optional<VRMDegreeMap> lookAtHorizontalOuter;
  std::optional<VRMDegreeMap> lookAtVerticalDown;
  std::optional<VRMDegreeMap> lookAtVerticalUp;
};

class VRMBlendShapeBind {
public:
  std::optional<uint32_t> mesh;
  std::optional<uint32_t> index;
  std::optional<float> weight;
};

class VRMBlendShapeMaterialBind {
public:
  std::optional<std::string> materialName;
  std::optional<std::string> propertyName;
  std::optional<std::vector<float>> targetValue;
};

class VRMBlendShapeGroup {
public:
  enum class PresetName {
    UNKNOWN,
    NEUTRAL,
    A,
    I,
    U,
    E,
    O,
    BLINK,
    JOY,
    ANGRY,
    SORROW,
    FUN,
    LOOKUP,
    LOOKDOWN,
    LOOKLEFT,
    LOOKRIGHT,
    BLINK_L,
    BLINK_R
  };

  static std::optional<PresetName>
  PresetNameFromString(const std::string &value) {
    if (value == "unknown")
      return PresetName::UNKNOWN;
    if (value == "neutral")
      return PresetName::NEUTRAL;
    if (value == "a")
      return PresetName::A;
    if (value == "i")
      return PresetName::I;
    if (value == "u")
      return PresetName::U;
    if (value == "e")
      return PresetName::E;
    if (value == "o")
      return PresetName::O;
    if (value == "blink")
      return PresetName::BLINK;
    if (value == "joy")
      return PresetName::JOY;
    if (value == "angry")
      return PresetName::ANGRY;
    if (value == "sorrow")
      return PresetName::SORROW;
    if (value == "fun")
      return PresetName::FUN;
    if (value == "lookup")
      return PresetName::LOOKUP;
    if (value == "lookdown")
      return PresetName::LOOKDOWN;
    if (value == "lookleft")
      return PresetName::LOOKLEFT;
    if (value == "lookright")
      return PresetName::LOOKRIGHT;
    if (value == "blink_l")
      return PresetName::BLINK_L;
    if (value == "blink_r")
      return PresetName::BLINK_R;
    return std::nullopt;
  }

  static std::string PresetNameToString(PresetName presetName) {
    switch (presetName) {
    case PresetName::UNKNOWN:
      return "unknown";
    case PresetName::NEUTRAL:
      return "neutral";
    case PresetName::A:
      return "a";
    case PresetName::I:
      return "i";
    case PresetName::U:
      return "u";
    case PresetName::E:
      return "e";
    case PresetName::O:
      return "o";
    case PresetName::BLINK:
      return "blink";
    case PresetName::JOY:
      return "joy";
    case PresetName::ANGRY:
      return "angry";
    case PresetName::SORROW:
      return "sorrow";
    case PresetName::FUN:
      return "fun";
    case PresetName::LOOKUP:
      return "lookup";
    case PresetName::LOOKDOWN:
      return "lookdown";
    case PresetName::LOOKLEFT:
      return "lookleft";
    case PresetName::LOOKRIGHT:
      return "lookright";
    case PresetName::BLINK_L:
      return "blink_l";
    case PresetName::BLINK_R:
      return "blink_r";
    default:
      return "";
    }
  }

  std::optional<std::string> name;
  std::optional<PresetName> presetName;
  std::optional<std::vector<VRMBlendShapeBind>> binds;
  std::optional<std::vector<VRMBlendShapeMaterialBind>> materialValues;
  std::optional<bool> isBinary;

  std::string groupName() const {
    if (presetName.has_value()) {
      return PresetNameToString(*presetName);
    } else {
      return name.value_or("");
    }
  }

  bool isBinaryValue() const { return isBinary.value_or(false); }
};

class VRMBlendShape {
public:
  std::optional<std::vector<VRMBlendShapeGroup>> blendShapeGroups;

  const VRMBlendShapeGroup *
  blendShapeGroupByPreset(std::string presetName) const {
    if (!blendShapeGroups.has_value())
      return nullptr;
    std::transform(presetName.begin(), presetName.end(), presetName.begin(),
                   ::tolower);
    for (const auto &group : *blendShapeGroups) {
      std::string groupName = group.groupName();
      std::transform(groupName.begin(), groupName.end(), groupName.begin(),
                     ::tolower);
      if (groupName == presetName) {
        return &group;
      }
    }
    return nullptr;
  }
};

class VRMSecondaryAnimationCollider {
public:
  std::optional<VRMVec3> offset;
  std::optional<float> radius;

  VRMVec3 offsetValue() const { return offset.value_or(VRMVec3::zero()); }

  float radiusValue() const { return radius.value_or(0); }
};

class VRMSecondaryAnimationColliderGroup {
public:
  std::optional<uint32_t> node;
  std::optional<std::vector<VRMSecondaryAnimationCollider>> colliders;
};

class VRMSecondaryAnimationSpring {
public:
  std::optional<std::string> comment;
  std::optional<float> stiffiness;
  std::optional<float> gravityPower;
  std::optional<VRMVec3> gravityDir;
  std::optional<float> dragForce;
  std::optional<int> center;
  std::optional<float> hitRadius;
  std::optional<std::vector<uint32_t>> bones;
  std::optional<std::vector<uint32_t>> colliderGroups;
};

class VRMSecondaryAnimation {
public:
  std::optional<std::vector<VRMSecondaryAnimationSpring>> boneGroups;
  std::optional<std::vector<VRMSecondaryAnimationColliderGroup>> colliderGroups;
};

class VRMMaterial {
public:
  std::optional<std::string> name;
  std::optional<std::string> shader;
  std::optional<uint32_t> renderQueue;
  std::optional<std::map<std::string, float>> floatProperties;
  std::optional<std::map<std::string, std::vector<float>>> vectorProperties;
  std::optional<std::map<std::string, uint32_t>> textureProperties;
  std::optional<std::map<std::string, bool>> keywordMap;
  std::optional<std::map<std::string, std::string>> tagMap;
};

class VRMVrm {
public:
  std::optional<std::string> exporterVersion;
  std::optional<std::string> specVersion;
  std::optional<VRMMeta> meta;
  std::optional<VRMHumanoid> humanoid;
  std::optional<VRMFirstPerson> firstPerson;
  std::optional<VRMBlendShape> blendShapeMaster;
  std::optional<VRMSecondaryAnimation> secondaryAnimation;
  std::optional<std::vector<VRMMaterial>> materialProperties;

  const VRMBlendShapeGroup *
  blendShapeGroupByPreset(const std::string &preset) const {
    if (!blendShapeMaster.has_value())
      return nullptr;
    return blendShapeMaster->blendShapeGroupByPreset(preset);
  }
};

class VRMCSpringBoneColliderGroup {
public:
  std::optional<std::string> name;
  std::vector<uint32_t> colliders;
};

class VRMCSpringBoneJoint {
public:
  uint32_t node;
  std::optional<float> hitRadius;
  std::optional<float> stiffness;
  std::optional<float> gravityPower;
  std::optional<std::array<float, 3>> gravityDir;
  std::optional<float> dragForce;

  float hitRadiusValue() const { return hitRadius.value_or(0); }

  float stiffnessValue() const { return stiffness.value_or(1.0f); }

  float gravityPowerValue() const { return gravityPower.value_or(0); }

  std::array<float, 3> gravityDirValue() const {
    return gravityDir.value_or(std::array<float, 3>({0, -1.0f, 0}));
  }

  float dragForceValue() const { return dragForce.value_or(0.5f); }
};

class VRMCSpringBoneShapeSphere {
public:
  std::optional<std::array<float, 3>> offset;
  std::optional<float> radius;

  std::array<float, 3> offsetValue() const {
    return offset.value_or(std::array<float, 3>({0, 0, 0}));
  }

  float radiusValue() const { return radius.value_or(0); }
};

class VRMCSpringBoneShapeCapsule {
public:
  std::optional<std::array<float, 3>> offset;
  std::optional<float> radius;
  std::optional<std::array<float, 3>> tail;

  std::array<float, 3> offsetValue() const {
    return offset.value_or(std::array<float, 3>({0, 0, 0}));
  }

  float radiusValue() const { return radius.value_or(0); }

  std::array<float, 3> tailValue() const {
    return tail.value_or(std::array<float, 3>({0, 0, 0}));
  }
};

class VRMCSpringBoneShape {
public:
  std::optional<VRMCSpringBoneShapeSphere> sphere;
  std::optional<VRMCSpringBoneShapeCapsule> capsule;
};

class VRMCSpringBoneCollider {
public:
  uint32_t node;
  VRMCSpringBoneShape shape;
};

class VRMCSpringBoneSpring {
public:
  std::optional<std::string> name;
  std::vector<VRMCSpringBoneJoint> joints;
  std::optional<std::vector<uint32_t>> colliderGroups;
  std::optional<uint32_t> center;
};

class VRMCSpringBone {
public:
  std::string specVersion;
  std::optional<std::vector<VRMCSpringBoneCollider>> colliders;
  std::optional<std::vector<VRMCSpringBoneColliderGroup>> colliderGroups;
  std::optional<std::vector<VRMCSpringBoneSpring>> springs;
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
  std::optional<VRMVrm> vrm0;
  std::optional<VRMCVrm> vrm1;
  std::optional<VRMCSpringBone> springBone;
};

} // namespace json
}; // namespace gltf2

#endif /* Json_h */
