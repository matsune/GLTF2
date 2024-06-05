#ifndef GLTFData_h
#define GLTFData_h

#include "GLTFJson.h"
#include <filesystem>
#include <fstream>
#include <memory>
#include <string>

namespace gltf2 {

using Binary = std::vector<uint8_t>;

struct MeshPrimitiveSource {
  Binary binary;
  uint vectorCount;
  uint componentsPerVector;
  GLTFAccessor::ComponentType componentType;
};

struct MeshPrimitiveElement {
  Binary binary;
  GLTFMeshPrimitive::Mode primitiveMode;
  uint primitiveCount;
  GLTFAccessor::ComponentType componentType;
};

struct MeshPrimitiveSources {
  std::optional<MeshPrimitiveSource> position;
  std::optional<MeshPrimitiveSource> normal;
  std::optional<MeshPrimitiveSource> tangent;
  std::vector<MeshPrimitiveSource> texcoords;
  std::vector<MeshPrimitiveSource> colors;
  std::vector<MeshPrimitiveSource> joints;
  std::vector<MeshPrimitiveSource> weights;
};

struct MeshPrimitive {
  MeshPrimitiveSources sources;
  std::optional<MeshPrimitiveElement> element;
};

class GLTFData {
public:
  /**
   * @brief Parse JSON string and create GLTFData object.
   *
   * @param raw A string containing the raw JSON data.
   * @param path An optional filesystem path associated with the JSON data.
   * @param bin An optional binary data buffer associated with the GLTF file.
   * @return GLTFData Parsed GLTF data object.
   * @throws InputException If JSON parsing fails.
   */
  static GLTFData
  parseJson(const std::string &raw,
            const std::optional<std::filesystem::path> path = std::nullopt,
            const std::optional<Binary> bin = std::nullopt);

  /**
   * @brief Parse raw byte data and create GLTFData object.
   *
   * @param bytes A pointer to the raw byte data.
   * @param length The length of the byte data.
   * @param path An optional filesystem path associated with the byte data.
   * @return GLTFData Parsed GLTF data object.
   * @throws InputException If data parsing fails.
   */
  static GLTFData
  parseData(const char *bytes, uint64_t length,
            const std::optional<std::filesystem::path> path = std::nullopt);

  /**
   * @brief Parse a file and create GLTFData object.
   *
   * @param path The filesystem path to the file.
   * @return GLTFData Parsed GLTF data object.
   * @throws InputException If file opening or parsing fails.
   */
  static GLTFData parseFile(const std::filesystem::path &path);

  /**
   * @brief Parse an input stream and create GLTFData object.
   *
   * @param fs The input stream to read the data from.
   * @param path An optional filesystem path associated with the data.
   * @return GLTFData Parsed GLTF data object.
   * @throws InputException If stream reading or data parsing fails.
   */
  static GLTFData parseStream(std::istream &fs,
                              std::optional<std::filesystem::path> path);

  GLTFData() = delete;

  const GLTFJson &json() const { return _json; }

  const std::optional<std::filesystem::path> &path() const { return _path; }

  const std::optional<Binary> &bin() const { return _bin; }

  Binary binaryForBufferView(const GLTFBufferView &bufferView,
                             uint32_t offset = 0) const;
  Binary binaryForBufferView(uint32_t index, uint32_t offset = 0) const;

  Binary binaryForBuffer(const GLTFBuffer &buffer) const;
  Binary binaryForBuffer(uint32_t index) const;

  Binary binaryForAccessor(const GLTFAccessor &accessor,
                           bool *normalized) const;
  Binary binaryForAccessor(uint32_t index, bool *normalized) const;

  Binary binaryForImage(const GLTFImage &image) const;

  MeshPrimitive
  meshPrimitiveFromPrimitive(const GLTFMeshPrimitive &primitive) const;

  MeshPrimitiveSources
  meshPrimitiveSourcesFromTarget(const GLTFMeshPrimitiveTarget &target) const;

private:
  GLTFData(GLTFJson json,
           std::optional<std::filesystem::path> path = std::nullopt,
           std::optional<Binary> bin = std::nullopt)
      : _json(json), _path(path), _bin(bin){};

  GLTFJson _json;
  std::optional<std::filesystem::path> _path;
  std::optional<Binary> _bin;

  Binary binaryOfUri(const std::string &uri) const;

  std::vector<uint32_t>
  indicesForAccessorSparse(const GLTFAccessorSparse &sparse) const;

  Binary normalizeBinary(const Binary &binary,
                         const GLTFAccessor &accessor) const;

  MeshPrimitiveSource
  meshPrimitiveSourceFromAccessor(const GLTFAccessor &accessor) const;
  MeshPrimitiveSource meshPrimitiveSourceFromAccessor(uint32_t index) const;
  MeshPrimitive meshPrimitiveFromDracoExtension(
      const GLTFMeshPrimitiveDracoExtension &extension) const;
};

} // namespace gltf2

#endif /* GLTFData_h */
