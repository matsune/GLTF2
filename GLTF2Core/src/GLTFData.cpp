#include "GLTFData.h"
#include "GLTFJsonDecoder.h"
#include <fstream>
#include <iostream>
#include <nlohmann/json.hpp>

namespace gltf2 {

GLTFData GLTFData::parse(const std::string &raw) {
  GLTFJsonDecoder decoder;
  GLTFJson json;
  try {
    auto data = nlohmann::json::parse(raw);
    std::cout << data << std::endl;
    decoder.decodeJson(data, json);
    return GLTFData(json);
  } catch (nlohmann::json::exception e) {
    throw InputException(e.what());
  }
}

} // namespace gltf2
