#include "GLTF2Core.h"

#include <assert.h>
#include <iostream>

int main(int argc, const char **argv) {
  try {
    auto rawJson = R"(
      {
        "asset": {
          "copyright": "COPYRIGHT",
          "generator": "GENERATOR",
          "version": "1.0",
          "minVersion": "0.1"
        }
      }
    )";
    auto data = gltf2::GLTFData::parse(rawJson);
    assert(data.json.asset.copyright == "COPYRIGHT");
    assert(data.json.asset.generator == "GENERATOR");
    assert(data.json.asset.version == "1.0");
    assert(data.json.asset.minVersion == "0.1");
  } catch (gltf2::InputException e) {
    std::cerr << e.what() << std::endl;
    return 1;
  } catch (gltf2::KeyNotFoundException e) {
    std::cerr << e.what() << std::endl;
    return 1;
  } catch (gltf2::InvalidFormatException e) {
    std::cerr << e.what() << std::endl;
    return 1;
  }

  return 0;
}
