#include "GLTFData.h"
#include "GLTFException.h"
#include "GLTFJsonDecoder.h"
#include <boost/beast/core/detail/base64.hpp>
#include <boost/url.hpp>
#include <fstream>
#include <iostream>
#include <nlohmann/json.hpp>
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

GLTFData GLTFData::parseJson(const std::string &raw,
                             std::optional<std::filesystem::path> path) {
  try {
    auto data = nlohmann::json::parse(raw);
    auto json = GLTFJsonDecoder::decode(data);
    return GLTFData(json, path);
  } catch (nlohmann::json::exception e) {
    throw InputException(e.what());
  }
}

GLTFData GLTFData::parseData(const char *bytes, uint64_t length,
                             std::optional<std::filesystem::path> path) {
  std::istringstream fs(std::string(bytes, length), std::ios::binary);
  return parseStream(fs, path);
}

GLTFData GLTFData::parseFile(const std::filesystem::path &path) {
  std::ifstream fs;
  fs.open(path.string(), std::ios::binary);
  if (!fs)
    throw InputException("Failed to open file");

  return parseStream(fs, path);
}

GLTFData GLTFData::parseStream(std::istream &fs,
                               std::optional<std::filesystem::path> path) {
  uint32_t magic;
  if (!fs.read(reinterpret_cast<char *>(&magic), sizeof(uint32_t))) {
    throw InputException("Failed to read file");
  }
  fs.seekg(0, std::ios::beg);

  if (magic == GLBHeaderMagic) {
    // GLB
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
    std::string jsonBuf(chunkHead0.length, '\0');
    fs.read(&jsonBuf[0], chunkHead0.length);
    if (fs.gcount() != chunkHead0.length) {
      throw InputException("Failed to read json data");
    }
    auto data = nlohmann::json::parse(jsonBuf);
    auto json = GLTFJsonDecoder::decode(data);

    std::optional<std::vector<uint8_t>> bin;
    if (!fs.eof()) {
      // binary buffer
      GLBChunkHead chunkHead1;
      if (!fs.read(reinterpret_cast<char *>(&chunkHead1),
                   sizeof(GLBChunkHead))) {
        throw InputException("Failed to read chunk head");
      }
      if (chunkHead1.type != GLBChunkTypeBIN) {
        throw InputException("Chunk type is not BIN");
      }
      std::vector<uint8_t> binBuf(chunkHead1.length);
      fs.read(reinterpret_cast<char *>(binBuf.data()), binBuf.size());
      if (fs.gcount() != chunkHead1.length) {
        throw InputException("Failed to read bin data");
      }
      bin = binBuf;
    }
    return GLTFData(json, path, bin);
  } else {
    // GLTF
    std::string raw((std::istreambuf_iterator<char>(fs)),
                    std::istreambuf_iterator<char>());
    try {
      auto data = nlohmann::json::parse(raw);
      auto json = GLTFJsonDecoder::decode(data);
      return GLTFData(json, path);
    } catch (nlohmann::json::exception e) {
      throw InputException(e.what());
    }
  }
}

std::vector<uint8_t> GLTFData::dataOfUri(const std::string &uri) const {
  // decode percent-encoding
  auto url = boost::url(uri);
  if (url.has_scheme()) {
    if (url.scheme() == "data") {
      // base64
      std::string urlStr(url.c_str());
      auto encoded = urlStr.substr(urlStr.find(',') + 1);
      auto size = boost::beast::detail::base64::decoded_size(encoded.size());
      std::vector<uint8_t> buf(size);
      auto res = boost::beast::detail::base64::decode(buf.data(),
                                                      encoded.c_str(), size);
      buf.resize(res.first);
    } else {
      // unsupported scheme
    }
  } else if (url.is_path_absolute()) {
    // absolute path
    std::ifstream file(uri, std::ios::binary);
    return {std::istreambuf_iterator<char>(file),
            std::istreambuf_iterator<char>()};

  } else {
    // relative path
    std::filesystem::path basePathUrl(path.value());
    std::filesystem::path fullUrl = basePathUrl.parent_path() / url.c_str();
    std::ifstream file(fullUrl.string(), std::ios::binary);
    return {std::istreambuf_iterator<char>(file),
            std::istreambuf_iterator<char>()};
  }
  return {};
}

std::vector<uint8_t> GLTFData::dataForBuffer(const GLTFBuffer &buffer) const {
  if (buffer.uri) {
    return dataOfUri(*buffer.uri);
  } else {
    return bin.value();
  }
}

std::vector<uint8_t>
GLTFData::dataForBufferView(const GLTFBufferView &bufferView,
                            uint32_t offset) const {
  auto data = dataForBuffer(json.buffers->at(bufferView.buffer));
  auto loc = data.begin() + bufferView.byteOffset.value_or(0) + offset;
  return std::vector<uint8_t>(loc, loc + bufferView.byteLength);
}

} // namespace gltf2
