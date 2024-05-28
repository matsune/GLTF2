# GLTF2

GLTF2 library is a C++ decoder for glTF 2.0 format .gltf and .glb files.

## Supported Extensions

- [x] KHR_draco_mesh_compression
- [x] KHR_materials_sheen
- [x] KHR_materials_unlit
- [x] KHR_texture_transform

TODO: other extensions

# GLTF2SceneKit

GLTF2SceneKit framework provides a bridge to display glTF models using SceneKit on macOS.

## Requirements

Building these libraries requires [CMake]((https://cmake.org/)). Ensure you have CMake installed on your system before proceeding with the build process.

```sh
mkdir build
cd build
cmake ..
make
```