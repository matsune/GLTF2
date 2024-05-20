#include "GLTFJsonDecoder.h"

namespace gltf2 {

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

void GLTFJsonDecoder::decodeJson(const nlohmann::json &j, GLTFJson &v) {}

} // namespace gltf2
