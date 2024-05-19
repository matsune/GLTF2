#include "GLTFJson.h"

namespace gltf2 {

// GLTFAccessor::ComponentType GLTFAccessor::getComponentType() const {
//   switch (componentType) {
//   case 5120:
//     return ComponentType::BYTE;
//   case 5121:
//     return ComponentType::UNSIGNED_BYTE;
//   case 5122:
//     return ComponentType::SHORT;
//   case 5123:
//     return ComponentType::UNSIGNED_SHORT;
//   case 5125:
//     return ComponentType::UNSIGNED_INT;
//   case 5126:
//     return ComponentType::FLOAT;
//   default:
//     return ComponentType::UNKNOWN;
//   }
// }
//
// GLTFAccessor::Type GLTFAccessor::getType() const {
//   if (type == "SCALAR")
//     return Type::SCALAR;
//   if (type == "VEC2")
//     return Type::VEC2;
//   if (type == "VEC3")
//     return Type::VEC3;
//   if (type == "VEC4")
//     return Type::VEC4;
//   if (type == "MAT2")
//     return Type::MAT2;
//   if (type == "MAT3")
//     return Type::MAT3;
//   if (type == "MAT4")
//     return Type::MAT4;
//   return Type::UNKNOWN;
// }
//
// void from_json(const nlohmann::json &j, GLTFAccessor &v) {
//   if (j.contains("bufferView")) {
//     v.bufferView = j.at("bufferView").get<unsigned int>();
//   }
//   v.byteOffset = j.value("byteOffset", 0);
//   j.at("componentType").get_to(v.componentType);
//   v.normalized = j.value("normalized", false);
//   j.at("count").get_to(v.count);
//   j.at("type").get_to(v.type);
//   if (j.contains("max")) {
//     j.at("max").get_to(v.max);
//   }
//   if (j.contains("min")) {
//     j.at("min").get_to(v.min);
//   }
//   if (j.contains("name")) {
//     v.name = j.at("name").get<std::string>();
//   }
//   if (j.contains("extensions")) {
//     v.extensions = j.at("extensions");
//   }
//   if (j.contains("extras")) {
//     v.extras = j.at("extras");
//   }
// }

} // namespace gltf2
