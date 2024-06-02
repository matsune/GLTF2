#ifndef GLTFData_h
#define GLTFData_h

#include "GLTFJson.h"
#include <filesystem>
#include <fstream>
#include <memory>
#include <string>

namespace gltf2 {

using Data = std::vector<uint8_t>;

class MeshPrimitiveSource {
public:
  Data data;
  uint vectorCount;
  uint componentsPerVector;
  GLTFAccessor::ComponentType componentType;
};

class MeshPrimitiveElement {
public:
  Data data;
  GLTFMeshPrimitive::Mode primitiveMode;
  uint primitiveCount;
  GLTFAccessor::ComponentType componentType;
};

class MeshPrimitiveSources {
public:
  std::optional<MeshPrimitiveSource> position;
  std::optional<MeshPrimitiveSource> normal;
  std::optional<MeshPrimitiveSource> tangent;
  std::vector<MeshPrimitiveSource> texcoords;
  std::vector<MeshPrimitiveSource> colors;
  std::vector<MeshPrimitiveSource> joints;
  std::vector<MeshPrimitiveSource> weights;
};

class MeshPrimitive {
public:
  MeshPrimitiveSources sources;
  std::optional<MeshPrimitiveElement> element;
};

class GLTFData {
public:
  static GLTFData
  parseJson(const std::string &raw,
            std::optional<std::filesystem::path> path = std::nullopt);
  static GLTFData
  parseData(const char *bytes, uint64_t length,
            std::optional<std::filesystem::path> path = std::nullopt);
  static GLTFData parseFile(const std::filesystem::path &path);
  static GLTFData parseStream(std::istream &fs,
                              std::optional<std::filesystem::path> path);

  GLTFData() = delete;
  GLTFData(GLTFJson json,
           std::optional<std::filesystem::path> path = std::nullopt,
           std::optional<Data> bin = std::nullopt)
      : json(json), path(path), bin(bin){};

  GLTFJson json;
  std::optional<std::filesystem::path> path;
  std::optional<Data> bin;

  Data dataOfUri(const std::string &uri) const;

  Data dataForBufferView(const GLTFBufferView &bufferView,
                         uint32_t offset = 0) const;
  Data dataForBufferView(uint32_t index, uint32_t offset = 0) const;
  Data dataForBufferView(uint32_t index, std::optional<uint32_t> offset) const;
  Data dataForBuffer(const GLTFBuffer &buffer) const;
  Data dataForBuffer(uint32_t index) const;

  Data dataForAccessor(const GLTFAccessor &accessor, bool *normalized) const;
  Data dataForAccessor(uint32_t index, bool *normalized) const;
  std::vector<uint32_t>
  indicesForAccessorSparse(const GLTFAccessorSparse &sparse) const;
  Data normalizeData(const Data &data, const GLTFAccessor &accessor) const;

  MeshPrimitive
  meshPrimitiveFromPrimitive(const GLTFMeshPrimitive &primitive) const;
  MeshPrimitiveSource
  meshPrimitiveSourceFromAccessor(const GLTFAccessor &accessor) const;
  MeshPrimitiveSource meshPrimitiveSourceFromAccessor(uint32_t index) const;
  MeshPrimitiveSources
  meshPrimitiveSourcesFromTarget(const GLTFMeshPrimitiveTarget &target) const;
  MeshPrimitive meshPrimitiveFromDracoExtension(
      const GLTFMeshPrimitiveDracoExtension &extension) const;
};

} // namespace gltf2

#endif /* GLTFData_h */
