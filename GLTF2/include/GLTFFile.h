#ifndef GLTFFile_h
#define GLTFFile_h

#include "GLTFJson.h"
#include <filesystem>
#include <fstream>
#include <future>
#include <iostream>
#include <memory>
#include <string>

namespace gltf2 {

using Buffer = std::vector<uint8_t>;

class GLTFFile {
public:
  /**
   * @brief Parse a file and create GLTFFile object.
   *
   * @param path The filesystem path to the file.
   * @return GLTFFile Parsed GLTF data object.
   * @throws InputException If file opening or parsing fails.
   */
  static GLTFFile parseFile(const std::filesystem::path &path);

  /**
   * @brief Parse an input stream and create GLTFFile object.
   *
   * @param fs The input stream to read the data from.
   * @param path An optional filesystem path associated with the data.
   * @param bin An optional external binary data.
   * @return GLTFFile Parsed GLTF data object.
   * @throws InputException If stream reading or data parsing fails.
   */
  static GLTFFile
  parseStream(std::istream &&fs,
              const std::optional<std::filesystem::path> path = std::nullopt,
              const std::optional<Buffer> bin = std::nullopt);

  GLTFFile() = delete;

  const GLTFJson &json() const { return _json; }

  const GLTFJson &&moveJson() const { return std::move(_json); }

  const std::optional<std::filesystem::path> &path() const { return _path; }

  const std::optional<Buffer> &bin() const { return _bin; }

  Buffer bufferFromUri(const std::string &uri) const;

  Buffer getBuffer(const GLTFBuffer &buffer) const;
  Buffer getBuffer(uint32_t index) const;

private:
  GLTFFile(GLTFJson json,
           std::optional<std::filesystem::path> path = std::nullopt,
           std::optional<Buffer> bin = std::nullopt)
      : _json(json), _path(path), _bin(bin){};

  GLTFJson _json;
  std::optional<std::filesystem::path> _path;
  std::optional<Buffer> _bin;
};

} // namespace gltf2

#endif /* GLTFFile_h */
