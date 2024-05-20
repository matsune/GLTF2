#include "GLTFJsonDecoder.h"
#include "GLTFException.h"

namespace {
template <typename... Args>
std::string format(const std::string &fmt, Args... args) {
  size_t len = std::snprintf(nullptr, 0, fmt.c_str(), args...);
  std::vector<char> buf(len + 1);
  std::snprintf(&buf[0], len + 1, fmt.c_str(), args...);
  return std::string(&buf[0], &buf[0] + len);
}
} // namespace

namespace gltf2 {

void GLTFJsonDecoder::pushStack(const std::string ctx) { stack.push(ctx); }

void GLTFJsonDecoder::pushStackIndex(const std::string ctx, int index) {
  stack.push(format("%s[%d]", ctx.c_str(), index));
}

void GLTFJsonDecoder::popStack() { stack.pop(); }

std::string GLTFJsonDecoder::context() const {
  auto separator = ".";
  std::stack<std::string> tempStack = stack;
  std::vector<std::string> elements;

  while (!tempStack.empty()) {
    elements.push_back(tempStack.top());
    tempStack.pop();
  }

  std::reverse(elements.begin(), elements.end());

  std::string result;
  if (!elements.empty()) {
    result = elements[0];
    for (size_t i = 1; i < elements.size(); ++i) {
      result += separator + elements[i];
    }
  }

  return result;
}

std::string GLTFJsonDecoder::contextKey(std::string key) const {
  return format("%s.%s", context().c_str(), key.c_str());
}

// void GLTFJsonDecoder::decodeObject(const nlohmann::json &j, GLTFObject &v) {
//   if (j.contains("extensions") && j["extensions"].is_object()) {
//     v.extensions = j.at("extensions");
//   }
//   if (j.contains("extras")) {
//     v.extras = j.at("extras");
//   }
// }

// void GLTFJsonDecoder::decodeSparseIndices(const nlohmann::json &j,
//                                           GLTFAccessorSparseIndices &v) {
//   //  j.at("bufferView")
//   //  j.at("count").get_to(v.count);
//   //   j.at("indices").get_to(v.indices);
//   //   j.at("values").get_to(v.values);
// }

GLTFJson GLTFJsonDecoder::decodeJson(const nlohmann::json &j) {
  auto assetObject = decodeObject(j, "asset");
  auto asset = decodeAsset(assetObject);

  GLTFJson v;
  v.asset = asset;
  return v;
}

GLTFAsset GLTFJsonDecoder::decodeAsset(const nlohmann::json &j) {
  pushStack("asset");

  GLTFAsset asset;
  asset.copyright = decodeStringOptional(j, "copyright");
  asset.generator = decodeStringOptional(j, "generator");
  asset.version = decodeString(j, "version");
  asset.minVersion = decodeStringOptional(j, "minVersion");

  popStack();
  return asset;
}

std::string GLTFJsonDecoder::decodeString(const nlohmann::json &j,
                                          const std::string &key) {
  if (!j.contains(key))
    throw KeyNotFoundException(contextKey(key));
  if (!j[key].is_string())
    throw InvalidFormatException(contextKey(key));
  return j[key].get<std::string>();
}

std::optional<std::string>
GLTFJsonDecoder::decodeStringOptional(const nlohmann::json &j,
                                      const std::string &key) {
  if (!j.contains(key))
    return std::nullopt;
  if (!j[key].is_string())
    throw InvalidFormatException(contextKey(key));
  return j[key].get<std::string>();
}

nlohmann::json GLTFJsonDecoder::decodeObject(const nlohmann::json &j,
                                             const std::string &key) {
  if (!j.contains(key))
    throw KeyNotFoundException(contextKey(key));
  if (!j[key].is_object())
    throw InvalidFormatException(contextKey(key));
  return j[key].get<nlohmann::json>();
}

std::optional<nlohmann::json>
GLTFJsonDecoder::decodeObjectOptional(const nlohmann::json &j,
                                      const std::string &key) {
  if (!j.contains(key))
    return std::nullopt;
  if (!j[key].is_object())
    throw InvalidFormatException(contextKey(key));
  return j[key].get<nlohmann::json>();
}

uint32_t GLTFJsonDecoder::decodeNumber(const nlohmann::json &j,
                                       const std::string &key) {
  if (!j.contains(key))
    throw KeyNotFoundException(contextKey(key));
  if (!j[key].is_string())
    throw InvalidFormatException(contextKey(key));
  return j[key].get<std::uint32_t>();
}

} // namespace gltf2
