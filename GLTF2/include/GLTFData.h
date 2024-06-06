#ifndef GLTFData_h
#define GLTFData_h

#include "GLTFFile.h"
#include "GLTFJson.h"
#include <filesystem>
#include <fstream>
#include <future>
#include <iostream>
#include <memory>
#include <string>

namespace gltf2 {

struct BufferView {
  uint8_t *data;
  uint32_t bytes;

  BufferView(uint8_t *data, uint32_t bytes) : data(data), bytes(bytes) {}

  Buffer toBuffer() const { return Buffer(data, data + bytes); }
};

struct AccessorBuffer {
  Buffer buffer;
  bool normalized;

  AccessorBuffer(Buffer buffer, bool normalized)
      : buffer(buffer), normalized(normalized) {}
};

struct MeshPrimitiveSource {
  Buffer buffer;
  uint32_t vectorCount;
  uint8_t componentsPerVector;
  GLTFAccessor::ComponentType componentType;
};

struct MeshPrimitiveSources {
  std::optional<MeshPrimitiveSource> position;
  std::optional<MeshPrimitiveSource> normal;
  std::optional<MeshPrimitiveSource> tangent;
  std::vector<MeshPrimitiveSource> texcoords;
  std::vector<MeshPrimitiveSource> colors;
  std::vector<MeshPrimitiveSource> joints;
  std::vector<MeshPrimitiveSource> weights;
};

struct MeshPrimitiveElement {
  Buffer buffer;
  GLTFMeshPrimitive::Mode primitiveMode;
  uint32_t primitiveCount;
  GLTFAccessor::ComponentType componentType;
};

struct MeshPrimitive {
  MeshPrimitiveSources sources;
  std::optional<MeshPrimitiveElement> element;
  std::vector<MeshPrimitiveSources> targets;
};

class GLTFData {
public:
  GLTFData(const GLTFFile &&file) : _file(std::move(file)){};

  std::future<void> eagerLoad();

  static GLTFData load(const GLTFFile &&file) {
    GLTFData data(std::move(file));
    data.eagerLoad().get();
    return std::move(data);
  }

  const GLTFJson &json() const { return _file.json(); }

  const GLTFJson &&moveJson() const { return _file.moveJson(); }

  const std::vector<std::unique_ptr<Buffer>> &buffers() const {
    return _buffers;
  }

  const Buffer &bufferAt(uint32_t index) const { return *_buffers[index]; }

  const std::vector<std::unique_ptr<BufferView>> &bufferViews() const {
    return _bufferViews;
  }

  const BufferView &bufferViewAt(uint32_t index) const {
    return *_bufferViews[index];
  }

  const std::vector<std::unique_ptr<AccessorBuffer>> &accessorBuffers() const {
    return _accessorBuffers;
  }

  const AccessorBuffer &accessorBufferAt(uint32_t index) const {
    return *_accessorBuffers[index];
  }

  const std::vector<std::unique_ptr<Buffer>> &imageBuffers() const {
    return _imageBuffers;
  }

  const Buffer &imageBufferAt(uint32_t index) const {
    return *_imageBuffers[index];
  }

  const std::vector<std::unique_ptr<MeshPrimitive>> &
  meshPrimitivesAt(uint32_t meshIndex) const {
    return _meshPrimitives.at(meshIndex);
  }

  const MeshPrimitive &meshPrimitiveAt(uint32_t meshIndex,
                                       uint32_t index) const {
    return *_meshPrimitives.at(meshIndex).at(index);
  }

private:
  GLTFFile _file;
  std::vector<std::unique_ptr<Buffer>> _buffers;
  std::vector<std::unique_ptr<BufferView>> _bufferViews;
  std::vector<std::unique_ptr<AccessorBuffer>> _accessorBuffers;
  std::vector<std::unique_ptr<Buffer>> _imageBuffers;
  std::vector<std::vector<std::unique_ptr<MeshPrimitive>>> _meshPrimitives;

  void clear();

  std::future<void> loadBuffers();
  std::future<void> loadBufferAt(uint32_t index);

  std::future<void> loadBufferViews();
  std::future<void> loadBufferViewAt(uint32_t index);

  std::future<void> loadAccessorBuffers();
  std::future<void> loadAccessorBufferAt(uint32_t index);

  std::future<void> loadImageBuffers();
  std::future<void> loadImageBufferAt(uint32_t index);

  std::future<void> loadMeshPrimitives();
  std::future<void> loadMeshPrimitiveAtMesh(uint32_t meshIndex);
  std::future<void> loadMeshPrimitiveAt(uint32_t meshIndex,
                                        uint32_t primitiveIndex);

  std::vector<uint32_t>
  indicesForAccessorSparse(const GLTFAccessorSparse &sparse) const;

  MeshPrimitiveSource meshPrimitiveSourceFromAccessor(uint32_t index) const;
  std::future<MeshPrimitive> meshPrimitiveFromDracoExtension(
      const GLTFMeshPrimitiveDracoExtension &extension) const;
  MeshPrimitiveSources
  meshPrimitiveSourcesFromTarget(const GLTFMeshPrimitiveTarget &target) const;
};

} // namespace gltf2

#endif /* GLTFData_h */
