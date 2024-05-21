#ifndef GLTFData_h
#define GLTFData_h

#include "GLTFJson.h"
#include <filesystem>
#include <fstream>
#include <memory>
#include <string>

namespace gltf2 {

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
           std::optional<std::vector<uint8_t>> bin = std::nullopt)
      : json(json), path(path), bin(bin){};

  GLTFJson json;
  std::optional<std::filesystem::path> path;
  std::optional<std::vector<uint8_t>> bin;

  std::vector<uint8_t> dataForBufferView(const GLTFBufferView &bufferView,
                                         uint32_t offset = 0) const;
  std::vector<uint8_t> dataForBuffer(const GLTFBuffer &buffer) const;
  std::vector<uint8_t> dataOfUri(const std::string &uri) const;
};

} // namespace gltf2

#endif /* GLTFData_h */
