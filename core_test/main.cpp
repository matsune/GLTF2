#include "GLTF2Core.h"

#include <iostream>

int main(int argc, const char **argv) {
  try {
    gltf2::GLTFData::parse("{");
  } catch (gltf2::InputException e) {
    std::cerr << e.what() << std::endl;
    return 1;
  }

  return 0;
}
