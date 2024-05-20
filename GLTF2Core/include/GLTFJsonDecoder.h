#ifndef GLTFJsonDecoder_h
#define GLTFJsonDecoder_h

#include "GLTFJson.h"
#include "nlohmann/json.hpp"

namespace gltf2 {

class GLTFJsonDecoder {
public:
  void decodeSparseIndices(const nlohmann::json &j,
                           GLTFAccessorSparseIndices &v);
  void decodeSparse(const nlohmann::json &j, GLTFAccessorSparse &v);
  void decodeJson(const nlohmann::json &j, GLTFJson &v);
};

} // namespace gltf2

#endif /* GLTFJsonDecoder_h */
