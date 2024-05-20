#ifndef GLTFData_h
#define GLTFData_h

#include "GLTFJson.h"
#include <string>

namespace gltf2 {

class GLTFData {
public:
  static GLTFData parse(const std::string &raw);

  GLTFData() = delete;
  GLTFData(GLTFJson json) : json(json){};

  GLTFJson json;
};

} // namespace gltf2

#endif /* GLTFData_h */
