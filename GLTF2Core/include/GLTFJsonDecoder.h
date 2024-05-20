#ifndef GLTFJsonDecoder_h
#define GLTFJsonDecoder_h

#include "GLTFJson.h"
#include "nlohmann/json.hpp"
#include <stack>

namespace gltf2 {

class GLTFJsonDecoder {
public:
  GLTFJson decodeJson(const nlohmann::json &j);

  GLTFJsonDecoder() { stack.push("root"); }

private:
  std::stack<std::string> stack;

  std::string decodeString(const nlohmann::json &j, const std::string &key);
  std::optional<std::string> decodeStringOptional(const nlohmann::json &j,
                                                  const std::string &key);

  uint32_t decodeNumber(const nlohmann::json &j, const std::string &key);
  nlohmann::json decodeObject(const nlohmann::json &j, const std::string &key);
  std::optional<nlohmann::json> decodeObjectOptional(const nlohmann::json &j,
                                                     const std::string &key);

  void pushStack(const std::string ctx);
  void pushStackIndex(const std::string ctx, int index);
  void popStack();
  std::string context() const;
  std::string contextKey(std::string key) const;

  GLTFAsset decodeAsset(const nlohmann::json &j);
  //  void decodeSparseIndices(const nlohmann::json &j,
  //                           GLTFAccessorSparseIndices &v);
  //  void decodeSparse(const nlohmann::json &j, GLTFAccessorSparse &v);
};

} // namespace gltf2

#endif /* GLTFJsonDecoder_h */
