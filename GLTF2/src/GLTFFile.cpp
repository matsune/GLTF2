#include "GLTFData.h"
#include "GLTFException.h"
#include "GLTFExtension.h"
#include "JsonDecoder.h"
#include "boost/url.hpp"
#include "cppcodec/base64_rfc4648.hpp"
#include "draco/compression/decode.h"
#include "draco/core/decoder_buffer.h"
#include "nlohmann/json.hpp"
#include <fstream>
#include <iostream>
#include <sstream>
#include <string>

namespace gltf2 {

static const uint32_t GLBHeaderMagic = 0x46546C67;
static const uint32_t GLBChunkTypeJSON = 0x4E4F534A;
static const uint32_t GLBChunkTypeBIN = 0x004E4942;

struct GLBHeader {
  uint32_t magic = 0;
  uint32_t version = 0;
  uint32_t length = 0;
};

struct GLBChunkHead {
  uint32_t length = 0;
  uint32_t type = 0;
};

static uint32_t peekMagic(std::istream &fs) {
  uint32_t magic;
  if (!fs.read(reinterpret_cast<char *>(&magic), sizeof(uint32_t))) {
    throw InputException("Failed to read file");
  }
  fs.seekg(0, std::ios::beg);
  return magic;
}

static uint32_t readGLBJsonLength(std::istream &fs) {
  GLBHeader header;
  if (!fs.read(reinterpret_cast<char *>(&header), sizeof(GLBHeader))) {
    throw InputException("Failed to read glb header");
  }
  if (header.version != 2) {
    std::cerr << "Expected glTF version is 2." << std::endl;
  }

  GLBChunkHead chunkHead0;
  if (!fs.read(reinterpret_cast<char *>(&chunkHead0), sizeof(GLBChunkHead))) {
    throw InputException("Failed to read chunk head");
  }
  if (chunkHead0.type != GLBChunkTypeJSON) {
    throw InputException("Chunk type is not JSON");
  }

  return chunkHead0.length;
}

static json::Json readGLBJson(std::istream &fs) {
  auto jsonLength = readGLBJsonLength(fs);

  std::string jsonBuf(jsonLength, '\0');
  fs.read(&jsonBuf[0], jsonLength);
  if (fs.gcount() != jsonLength) {
    throw InputException("Failed to read json data");
  }
  auto data = nlohmann::json::parse(jsonBuf);
  return json::JsonDecoder::decode(data);
}

static std::optional<Buffer> readGLBBin(std::istream &fs) {
  std::optional<Buffer> bin;
  if (!fs.eof()) {
    GLBChunkHead chunkHead1;
    if (!fs.read(reinterpret_cast<char *>(&chunkHead1), sizeof(GLBChunkHead))) {
      throw InputException("Failed to read chunk head");
    }
    if (chunkHead1.type != GLBChunkTypeBIN) {
      throw InputException("Chunk type is not BIN");
    }
    Buffer binBuf(chunkHead1.length);
    fs.read(reinterpret_cast<char *>(binBuf.data()), binBuf.size());
    if (fs.gcount() != chunkHead1.length) {
      throw InputException("Failed to read bin data");
    }
    bin = binBuf;
  }
  return bin;
}

GLTFFile GLTFFile::parseFile(const std::filesystem::path &path) {
  std::ifstream fs;
  fs.open(path.string(), std::ios::binary);
  if (!fs)
    throw InputException("Failed to open file");

  return parseStream(std::move(fs), path);
}

GLTFFile GLTFFile::parseStream(std::istream &&fs,
                               const std::optional<std::filesystem::path> path,
                               const std::optional<Buffer> bin) {
  if (peekMagic(fs) == GLBHeaderMagic) {
    // GLB
    auto json = readGLBJson(fs);
    auto bin = readGLBBin(fs);
    return GLTFFile(json, path, bin);
  } else {
    // GLTF
    std::string raw((std::istreambuf_iterator<char>(fs)),
                    std::istreambuf_iterator<char>());
    try {
      auto data = nlohmann::json::parse(raw);
      auto json = json::JsonDecoder::decode(data);
      return GLTFFile(json, path, bin);
    } catch (nlohmann::json::exception e) {
      throw InputException(e.what());
    }
  }
}

Buffer GLTFFile::bufferFromUri(const std::string &uri) const {
  // decode percent-encoding
  auto url = boost::url(uri);
  if (url.has_scheme()) {
    std::string scheme = url.scheme();
    if (scheme == "data") {
      // base64
      std::string urlStr(url.c_str());
      auto encoded = urlStr.substr(urlStr.find(',') + 1);
      return cppcodec::base64_rfc4648::decode(encoded);
    } else {
      // unsupported scheme
      throw InvalidFormatException(
          format("unsupported buffer url scheme %s", scheme.c_str()));
    }
  } else if (url.is_path_absolute()) {
    // absolute path
    std::ifstream file(uri, std::ios::binary);
    return {std::istreambuf_iterator<char>(file),
            std::istreambuf_iterator<char>()};

  } else {
    // relative path
    std::filesystem::path basePathUrl(_path.value());
    std::filesystem::path fullUrl = basePathUrl.parent_path() / url.c_str();
    std::ifstream file(fullUrl.string(), std::ios::binary);
    return {std::istreambuf_iterator<char>(file),
            std::istreambuf_iterator<char>()};
  }
}

Buffer GLTFFile::getBuffer(const json::Buffer &buffer) const {
  if (buffer.uri) {
    return bufferFromUri(*buffer.uri);
  } else {
    assert(_bin.has_value());
    return *_bin;
  }
}

Buffer GLTFFile::getBuffer(uint32_t index) const {
  return getBuffer(_json.buffers->at(index));
}

} // namespace gltf2
