#ifndef GLTFJson_h
#define GLTFJson_h

#include <optional>
#include <stdint.h>
#include <string>
#include <vector>

namespace gltf2 {

// Accessor

class GLTFAccessorSparseIndices {
public:
  enum class ComponentType {
    UNSIGNED_BYTE = 5121,
    UNSIGNED_SHORT = 5123,
    UNSIGNED_INT = 5125
  };

  uint32_t bufferView;
  uint32_t byteOffset = 0;
  uint32_t componentType;
};

class GLTFAccessorSparseValues {
public:
  uint32_t bufferView;
  std::optional<uint32_t> byteOffset;
};

class GLTFAccessorSparse {
public:
  uint32_t count;
  GLTFAccessorSparseIndices indices;
  GLTFAccessorSparseValues values;
};

class GLTFAccessor {
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

  std::optional<uint32_t> bufferView;
  std::optional<uint32_t> byteOffset;
  ComponentType componentType;
  std::optional<bool> normalized;
  uint32_t count;
  Type type;
  std::optional<std::vector<float>> max;
  std::optional<std::vector<float>> min;
  std::optional<GLTFAccessorSparse> sparse;
  std::optional<std::string> name;
};

// Animation

class GLTFAnimationChannelTarget {
public:
  std::optional<uint32_t> node;
  std::string path;
};

class GLTFAnimationChannel {
public:
  uint32_t sampler;
  GLTFAnimationChannelTarget target;
};

class GLTFAnimationSampler {
public:
  enum class Interpolation { LINEAR, STEP, CUBICSPLINE };

  uint32_t input;
  Interpolation interpolation;
  uint32_t output;
};

class GLTFAnimation {
public:
  std::vector<GLTFAnimationChannel> channels;
  std::vector<GLTFAnimationSampler> samplers;
  std::optional<std::string> name;
};

// Asset

class GLTFAsset {
public:
  std::optional<std::string> copyright;
  std::optional<std::string> generator;
  std::string version;
  std::optional<std::string> minVersion;
};

// Buffer

class GLTFBuffer {
public:
  std::optional<std::string> uri;
  uint32_t byteLength;
  std::optional<std::string> name;
};

class GLTFBufferView {
public:
  uint32_t buffer;
  std::optional<uint32_t> byteOffset;
  uint32_t byteLength;
  std::optional<uint32_t> byteStride;
  std::optional<uint32_t> target;
  std::optional<std::string> name;
};

// Camera

class GLTFCameraOrthographic {
public:
  float xmag;
  float ymag;
  float zfar;
  float znear;
};

class GLTFCameraPerspective {
public:
  std::optional<float> aspectRatio;
  float yfov;
  std::optional<float> zfar;
  float znear;
};

class GLTFCamera {
public:
  enum class Type { PERSPECTIVE, ORTHOGRAPHIC };

  std::optional<GLTFCameraOrthographic> orthographic;
  std::optional<GLTFCameraPerspective> perspective;
  std::string type;
  std::optional<std::string> name;
};

// Image

class GLTFImage {
public:
  enum class MimeType { JPEG, PNG };

  std::optional<std::string> uri;
  std::optional<MimeType> mimeType;
  std::optional<uint32_t> bufferView;
  std::optional<std::string> name;
};

// Texture

class GLTFTexture {
public:
  std::optional<uint32_t> sampler;
  std::optional<uint32_t> source;
  std::optional<std::string> name;
};

class GLTFTextureInfo {
public:
  uint32_t index;
  std::optional<uint32_t> texCoord;
};

// Material

class GLTFMaterialPBRMetallicRoughness {
public:
  std::optional<std::array<float, 4>> baseColorFactor;
  std::optional<GLTFTextureInfo> baseColorTexture;
  std::optional<float> metallicFactor;
  std::optional<float> roughnessFactor;
  std::optional<GLTFTextureInfo> metallicRoughnessTexture;
};

class GLTFMaterialNormalTextureInfo {
public:
  uint32_t index;
  std::optional<uint32_t> texCoord;
  std::optional<float> scale;
};

class GLTFMaterialOcclusionTextureInfo {
public:
  uint32_t index;
  std::optional<uint32_t> texCoord;
  std::optional<float> strength;
};

class GLTFMaterial {
public:
  enum class AlphaMode { OPAQUE, MASK, BLEND };

  std::optional<std::string> name;
  std::optional<GLTFMaterialPBRMetallicRoughness> pbrMetallicRoughness;
  std::optional<GLTFMaterialNormalTextureInfo> normalTexture;
  std::optional<GLTFMaterialOcclusionTextureInfo> occlusionTexture;
  std::optional<GLTFTextureInfo> emissiveTexture;
  std::optional<std::array<float, 3>> emissiveFactor;
  std::optional<AlphaMode> alphaMode;
  std::optional<float> alphaCutoff;
  std::optional<bool> doubleSided;
};

// Mesh

class GLTFMeshPrimitiveTarget {
public:
  std::optional<uint32_t> position;
  std::optional<uint32_t> normal;
  std::optional<uint32_t> tangent;
};

class GLTFMeshPrimitiveAttributes : public GLTFMeshPrimitiveTarget {
public:
  std::optional<std::vector<uint32_t>> texcoords;
  std::optional<std::vector<uint32_t>> colors;
  std::optional<std::vector<uint32_t>> joints;
  std::optional<std::vector<uint32_t>> weights;
};

class GLTFMeshPrimitive {
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

  GLTFMeshPrimitiveAttributes attributes;
  std::optional<uint32_t> indices;
  std::optional<uint32_t> material;
  std::optional<Mode> mode;
  std::optional<std::vector<GLTFMeshPrimitiveTarget>> targets;
};

class GLTFMesh {
public:
  std::vector<GLTFMeshPrimitive> primitives;
  std::optional<std::vector<float>> weights;
  std::optional<std::string> name;
};

// Node

class GLTFNode {
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
};

// Sampler

class GLTFSampler {
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

  std::optional<MagFilter> magFilter;
  std::optional<MinFilter> minFilter;
  std::optional<WrapMode> wrapS;
  std::optional<WrapMode> wrapT;
  std::optional<std::string> name;
};

// Scene

class GLTFScene {
public:
  std::optional<std::vector<uint32_t>> nodes;
  std::optional<std::string> name;
};

// Skin

class GLTFSkin {
public:
  std::optional<uint32_t> inverseBindMatrices;
  std::optional<uint32_t> skeleton;
  std::vector<uint32_t> joints;
  std::optional<std::string> name;
};

// Json

class GLTFJson {
public:
  std::optional<std::vector<std::string>> extensionsUsed;
  std::optional<std::vector<std::string>> extensionsRequired;
  std::optional<std::vector<GLTFAccessor>> accessors;
  std::optional<std::vector<GLTFAnimation>> animations;
  GLTFAsset asset;
  std::optional<std::vector<GLTFBuffer>> buffers;
  std::optional<std::vector<GLTFBufferView>> bufferViews;
  std::optional<std::vector<GLTFCamera>> cameras;
  std::optional<std::vector<GLTFImage>> images;
  std::optional<std::vector<GLTFMaterial>> materials;
  std::optional<std::vector<GLTFMesh>> meshes;
  std::optional<std::vector<GLTFNode>> nodes;
  std::optional<std::vector<GLTFSampler>> samplers;
  std::optional<uint32_t> scene;
  std::optional<std::vector<GLTFScene>> scenes;
  std::optional<std::vector<GLTFSkin>> skins;
  std::optional<std::vector<GLTFTexture>> textures;
};

}; // namespace gltf2

#endif /* GLTFJson_h */
