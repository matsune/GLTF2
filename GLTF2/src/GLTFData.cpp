#include "GLTFData.h"
#include "GLTFException.h"
#include "GLTFExtension.h"
#include "JsonDecoder.h"
#include "boost/url.hpp"
#include "cppcodec/base64_rfc4648.hpp"
#include "draco/compression/decode.h"
#include "draco/core/decoder_buffer.h"
#include "nlohmann/json.hpp"
#include <fstream>
#include <iostream>
#include <sstream>
#include <string>

namespace gltf2 {

static void waitFutures(std::vector<std::future<void>> &futures) {
  for (auto &future : futures) {
    future.get();
  }
}

static float normalize(const void *bytes, int index,
                       json::Accessor::ComponentType compType) {
  switch (compType) {
  case json::Accessor::ComponentType::BYTE: {
    int8_t value = *((int8_t *)bytes + index);
    float f = (float)value;
    return f > 0 ? f / (float)INT8_MAX : f / (float)INT8_MIN;
  }
  case json::Accessor::ComponentType::UNSIGNED_BYTE: {
    uint8_t value = *((uint8_t *)bytes + index);
    float f = (float)value;
    return f / (float)UINT8_MAX;
  }
  case json::Accessor::ComponentType::SHORT: {
    int16_t value = *((int16_t *)bytes + index);
    float f = (float)value;
    return f > 0 ? f / (float)INT16_MAX : f / (float)INT16_MIN;
  }
  case json::Accessor::ComponentType::UNSIGNED_SHORT: {
    uint16_t value = *((uint16_t *)bytes + index);
    float f = (float)value;
    return f / (float)UINT16_MAX;
  }
  case json::Accessor::ComponentType::UNSIGNED_INT: {
    uint32_t value = *((uint32_t *)bytes + index);
    float f = (float)value;
    return f / (float)UINT32_MAX;
  }
  case json::Accessor::ComponentType::FLOAT: {
    return *((float *)bytes + index);
  }
  }
}

static Buffer normalizeBuffer(const Buffer &binary,
                              const json::Accessor &accessor) {
  auto compCount = json::Accessor::componentsCountOfType(accessor.type);
  auto length = sizeof(float) * compCount * accessor.count;
  std::vector<float> values(compCount * accessor.count);
  for (int i = 0; i < accessor.count; i++) {
    for (int j = 0; j < compCount; j++) {
      int index = i * compCount + j;
      float value = normalize(binary.data(), index, accessor.componentType);
      values[index] = value;
    }
  }
  Buffer res(length);
  std::memcpy(res.data(), values.data(), length);
  return res;
}

std::future<void> GLTFData::eagerLoad() {
  return std::async(std::launch::async, [this] {
    clear();

    loadBuffers().get();
    loadBufferViews().get(); // depends buffer

    std::vector<std::future<void>> futures;
    futures.push_back(loadAccessorBuffers());
    futures.push_back(loadImageBuffers());
    waitFutures(futures);

    loadMeshPrimitives().get(); // depends accessor
  });
}

void GLTFData::clear() {
  _buffers.clear();
  _bufferViews.clear();
  _accessorBuffers.clear();
  _imageBuffers.clear();
  _meshPrimitives.clear();
}

std::future<void> GLTFData::loadBuffers() {
  return std::async(std::launch::async, [this] {
    if (!json().buffers.has_value())
      return;

    auto count = json().buffers->size();
    _buffers.resize(count);

    std::vector<std::future<void>> futures;
    futures.reserve(count);

    for (uint32_t i = 0; i < count; i++) {
      futures.push_back(loadBufferAt(i));
    }
    waitFutures(futures);
  });
}

std::future<void> GLTFData::loadBufferAt(uint32_t index) {
  return std::async(std::launch::async, [this, index] {
    _buffers[index] = std::make_unique<Buffer>(_file.getBuffer(index));
  });
}

std::future<void> GLTFData::loadBufferViews() {
  return std::async(std::launch::async, [this] {
    if (!json().bufferViews.has_value())
      return;

    auto count = json().bufferViews->size();
    _bufferViews.resize(count);

    std::vector<std::future<void>> futures;
    futures.reserve(count);

    for (uint32_t i = 0; i < count; i++) {
      futures.push_back(loadBufferViewAt(i));
    }
    waitFutures(futures);
  });
}

std::future<void> GLTFData::loadBufferViewAt(uint32_t index) {
  const auto &bufferView = json().bufferViews->at(index);
  return std::async(std::launch::async, [this, index, &bufferView] {
    uint8_t *begin = (uint8_t *)_buffers[bufferView.buffer]->data() +
                     bufferView.byteOffset.value_or(0);
    _bufferViews[index] =
        std::make_unique<BufferView>(begin, bufferView.byteLength);
  });
}

std::future<void> GLTFData::loadAccessorBuffers() {
  return std::async(std::launch::async, [this] {
    if (!json().accessors.has_value())
      return;

    auto count = json().accessors->size();
    _accessorBuffers.resize(count);

    std::vector<std::future<void>> futures;
    futures.reserve(count);

    for (uint32_t i = 0; i < count; i++) {
      futures.push_back(loadAccessorBufferAt(i));
    }
    waitFutures(futures);
  });
}

std::future<void> GLTFData::loadAccessorBufferAt(uint32_t index) {
  const auto &accessor = json().accessors->at(index);
  return std::async(std::launch::async, [this, index, &accessor] {
    auto compTypeSize =
        json::Accessor::sizeOfComponentType(accessor.componentType);
    auto compCount = json::Accessor::componentsCountOfType(accessor.type);
    auto typeSize = compTypeSize * compCount;
    auto length = typeSize * accessor.count;
    Buffer binary(length);
    bool normalized = false;

    // fill data
    if (accessor.bufferView.has_value()) {
      const auto &bufferView = json().bufferViews->at(*accessor.bufferView);
      const char *dstBase = (const char *)binary.data();
      const char *srcBase =
          (const char *)_bufferViews[*accessor.bufferView]->data +
          accessor.byteOffset.value_or(0);
      auto byteStride = bufferView.byteStride.value_or(typeSize);
      if (byteStride != typeSize) {
        // copy with byteStride
        for (int i = 0; i < accessor.count; i++) {
          const char *dst = dstBase + i * typeSize;
          const char *src = srcBase + i * byteStride;
          std::memcpy((void *)dst, src, typeSize);
        }
      } else {
        // copy all
        std::memcpy((void *)dstBase, srcBase, length);
      }
    }

    // sparse
    if (accessor.sparse) {
      const auto &sparse = *accessor.sparse;
      const auto indices = indicesForAccessorSparse(sparse);
      const auto valuesData = _bufferViews[sparse.values.bufferView]->data +
                              sparse.values.byteOffset.value_or(0);
      const char *dstBase = (const char *)binary.data();
      const char *srcBase = (const char *)valuesData;
      for (int i = 0; i < sparse.count; i++) {
        auto index = indices[i];
        const char *dst = dstBase + typeSize * index;
        const char *src = srcBase + typeSize * i;
        std::memcpy((void *)dst, src, typeSize);
      }
    }

    // normalize
    if (accessor.normalized.value_or(false) &&
        accessor.componentType != json::Accessor::ComponentType::FLOAT &&
        accessor.componentType != json::Accessor::ComponentType::UNSIGNED_INT) {
      binary = normalizeBuffer(binary, accessor);
      normalized = true;
    }

    _accessorBuffers[index] =
        std::make_unique<AccessorBuffer>(binary, normalized);
  });
}

std::future<void> GLTFData::loadImageBuffers() {
  return std::async(std::launch::async, [this] {
    if (!json().images.has_value())
      return;

    auto count = json().images->size();
    _imageBuffers.resize(count);

    std::vector<std::future<void>> futures;
    futures.reserve(count);

    for (uint32_t i = 0; i < count; i++) {
      futures.push_back(loadImageBufferAt(i));
    }
    waitFutures(futures);
  });
}

std::future<void> GLTFData::loadImageBufferAt(uint32_t index) {
  const auto &image = json().images->at(index);
  return std::async(std::launch::async, [this, index, &image] {
    if (image.uri.has_value()) {
      _imageBuffers[index] =
          std::make_unique<Buffer>(_file.bufferFromUri(*image.uri));
    } else {
      _imageBuffers[index] = std::make_unique<Buffer>(
          _bufferViews[image.bufferView.value_or(0)]->toBuffer());
    }
  });
}

std::vector<uint32_t>
GLTFData::indicesForAccessorSparse(const json::AccessorSparse &sparse) const {
  std::vector<uint32_t> data(sparse.count);
  const uint8_t *ptr = _bufferViews[sparse.indices.bufferView]->data +
                       sparse.indices.byteOffset.value_or(0);
  for (int i = 0; i < sparse.count; i++) {
    switch (sparse.indices.componentType) {
    case json::AccessorSparseIndices::ComponentType::UNSIGNED_BYTE:
      data.push_back(*ptr);
      ptr += sizeof(uint8_t);
      break;

    case json::AccessorSparseIndices::ComponentType::UNSIGNED_SHORT:
      data.push_back(*reinterpret_cast<const uint16_t *>(ptr));
      ptr += sizeof(uint16_t);
      break;

    case json::AccessorSparseIndices::ComponentType::UNSIGNED_INT:
      data.push_back(*reinterpret_cast<const uint32_t *>(ptr));
      ptr += sizeof(uint32_t);
      break;
    }
  }
  return data;
}

std::future<void> GLTFData::loadMeshPrimitives() {
  return std::async(std::launch::async, [this] {
    if (!json().meshes.has_value())
      return;

    auto meshCount = json().meshes->size();
    _meshPrimitives.resize(meshCount);

    std::vector<std::future<void>> meshFutures;
    meshFutures.reserve(meshCount);

    for (uint32_t i = 0; i < meshCount; i++) {
      meshFutures.push_back(loadMeshPrimitiveAtMesh(i));
    }
    waitFutures(meshFutures);
  });
}

std::future<void> GLTFData::loadMeshPrimitiveAtMesh(uint32_t meshIndex) {
  return std::async(std::launch::async, [this, meshIndex] {
    const auto &mesh = json().meshes->at(meshIndex);
    auto primitivesCount = mesh.primitives.size();
    _meshPrimitives[meshIndex].resize(primitivesCount);

    std::vector<std::future<void>> futures;
    futures.reserve(primitivesCount);

    for (uint32_t primitiveIndex = 0; primitiveIndex < primitivesCount;
         primitiveIndex++) {
      futures.push_back(loadMeshPrimitiveAt(meshIndex, primitiveIndex));
    }
    waitFutures(futures);
  });
}

std::future<void> GLTFData::loadMeshPrimitiveAt(uint32_t meshIndex,
                                                uint32_t primitiveIndex) {
  const auto &primitive =
      json().meshes->at(meshIndex).primitives.at(primitiveIndex);
  return std::async(std::launch::async, [this, meshIndex, primitiveIndex,
                                         &primitive] {
    MeshPrimitive meshPrimitive;
    if (primitive.dracoExtension) {
      meshPrimitive =
          meshPrimitiveFromDracoExtension(*primitive.dracoExtension).get();
    } else {
      std::vector<std::future<void>> futures;
      if (primitive.attributes.position) {
        futures.push_back(std::async(std::launch::async, [this, &meshPrimitive,
                                                          &primitive] {
          meshPrimitive.sources.position =
              meshPrimitiveSourceFromAccessor(*primitive.attributes.position);
        }));
      }
      if (primitive.attributes.normal) {
        futures.push_back(
            std::async(std::launch::async, [this, &meshPrimitive, &primitive] {
              meshPrimitive.sources.normal =
                  meshPrimitiveSourceFromAccessor(*primitive.attributes.normal);
            }));
      }
      if (primitive.attributes.tangent) {
        futures.push_back(std::async(std::launch::async, [this, &meshPrimitive,
                                                          &primitive] {
          meshPrimitive.sources.tangent =
              meshPrimitiveSourceFromAccessor(*primitive.attributes.tangent);
        }));
      }
      if (primitive.attributes.texcoords) {
        futures.push_back(
            std::async(std::launch::async, [this, &meshPrimitive, &primitive] {
              for (auto index : *primitive.attributes.texcoords) {
                meshPrimitive.sources.texcoords.push_back(
                    meshPrimitiveSourceFromAccessor(index));
              }
            }));
      }
      if (primitive.attributes.colors) {
        futures.push_back(
            std::async(std::launch::async, [this, &meshPrimitive, &primitive] {
              for (auto index : *primitive.attributes.colors) {
                meshPrimitive.sources.colors.push_back(
                    meshPrimitiveSourceFromAccessor(index));
              }
            }));
      }
      if (primitive.attributes.joints) {
        futures.push_back(
            std::async(std::launch::async, [this, &meshPrimitive, &primitive] {
              for (auto index : *primitive.attributes.joints) {
                meshPrimitive.sources.joints.push_back(
                    meshPrimitiveSourceFromAccessor(index));
              }
            }));
      }
      if (primitive.attributes.weights) {
        futures.push_back(
            std::async(std::launch::async, [this, &meshPrimitive, &primitive] {
              for (auto index : *primitive.attributes.weights) {
                meshPrimitive.sources.weights.push_back(
                    meshPrimitiveSourceFromAccessor(index));
              }
            }));
      }

      if (primitive.indices) {
        futures.push_back(
            std::async(std::launch::async, [this, &meshPrimitive, &primitive] {
              MeshPrimitiveElement element;
              auto &accessor = json().accessors->at(*primitive.indices);
              element.buffer = accessorBufferAt(*primitive.indices).buffer;
              element.primitiveMode = primitive.modeValue();
              auto indicesCount = accessor.count;
              switch (primitive.modeValue()) {
              case json::MeshPrimitive::Mode::POINTS:
                element.primitiveCount = indicesCount;
                break;
              case json::MeshPrimitive::Mode::LINES:
                element.primitiveCount = indicesCount / 2;
                break;
              case json::MeshPrimitive::Mode::LINE_LOOP:
                element.primitiveCount = indicesCount;
                break;
              case json::MeshPrimitive::Mode::LINE_STRIP:
                element.primitiveCount = indicesCount - 1;
                break;
              case json::MeshPrimitive::Mode::TRIANGLES:
                element.primitiveCount = indicesCount / 3;
                break;
              case json::MeshPrimitive::Mode::TRIANGLE_STRIP:
                element.primitiveCount = indicesCount - 2;
                break;
              case json::MeshPrimitive::Mode::TRIANGLE_FAN:
                element.primitiveCount = indicesCount - 2;
                break;
              }
              element.componentType = accessor.componentType;
              meshPrimitive.element = element;
            }));
      }

      waitFutures(futures);
    }

    if (primitive.targets.has_value()) {
      for (const auto &target : *primitive.targets) {
        meshPrimitive.targets.push_back(meshPrimitiveSourcesFromTarget(target));
      }
    }

    _meshPrimitives[meshIndex][primitiveIndex] =
        std::make_unique<MeshPrimitive>(meshPrimitive);
  });
}

MeshPrimitiveSource
GLTFData::meshPrimitiveSourceFromAccessor(uint32_t index) const {
  MeshPrimitiveSource source;

  const auto &accessor = json().accessors->at(index);
  const auto &accessorBuffer = accessorBufferAt(index);
  bool isFloat =
      accessor.componentType == json::Accessor::ComponentType::FLOAT ||
      accessorBuffer.normalized;
  json::Accessor::ComponentType componentType =
      isFloat ? json::Accessor::ComponentType::FLOAT : accessor.componentType;

  source.buffer = accessorBuffer.buffer;
  source.vectorCount = accessor.count;
  source.componentsPerVector =
      json::Accessor::componentsCountOfType(accessor.type);
  source.componentType = componentType;
  return source;
}

MeshPrimitiveSources GLTFData::meshPrimitiveSourcesFromTarget(
    const json::MeshPrimitiveTarget &target) const {
  MeshPrimitiveSources sources;
  std::vector<std::future<void>> futures;

  if (target.position) {
    futures.push_back(std::async(std::launch::async, [this, &sources, &target] {
      sources.position = meshPrimitiveSourceFromAccessor(*target.position);
    }));
  }
  if (target.normal) {
    futures.push_back(std::async(std::launch::async, [this, &sources, &target] {
      sources.normal = meshPrimitiveSourceFromAccessor(*target.normal);
    }));
  }
  if (target.tangent) {
    futures.push_back(std::async(std::launch::async, [this, &sources, &target] {
      sources.tangent = meshPrimitiveSourceFromAccessor(*target.tangent);
    }));
  }
  waitFutures(futures);
  return sources;
}

static std::unique_ptr<draco::Mesh>
decodeDracoMesh(const BufferView &bufferView) {
  draco::DecoderBuffer buffer;
  buffer.Init((const char *)bufferView.data, bufferView.bytes);

  draco::Decoder decoder;
  auto status_or_mesh = decoder.DecodeMeshFromBuffer(&buffer);
  if (!status_or_mesh.ok()) {
    std::cerr << "Failed to decode Draco mesh: "
              << status_or_mesh.status().error_msg() << std::endl;
    return nullptr;
  }

  return std::move(status_or_mesh).value();
}

static json::Accessor::ComponentType
convertDracoDataTypeToGLTFComponentType(draco::DataType dracoType) {
  switch (dracoType) {
  case draco::DT_INT8:
    return json::Accessor::ComponentType::BYTE;
  case draco::DT_UINT8:
    return json::Accessor::ComponentType::UNSIGNED_BYTE;
  case draco::DT_INT16:
    return json::Accessor::ComponentType::SHORT;
  case draco::DT_UINT16:
    return json::Accessor::ComponentType::UNSIGNED_SHORT;
  case draco::DT_INT32:
    return json::Accessor::ComponentType::UNSIGNED_INT;
  case draco::DT_FLOAT32:
    return json::Accessor::ComponentType::FLOAT;
  default:
    throw std::runtime_error("Unsupported Draco data type");
  }
}

static MeshPrimitiveSource
processDracoMeshPrimitiveSource(const std::unique_ptr<draco::Mesh> &dracoMesh,
                                draco::GeometryAttribute::Type type) {
  const draco::PointAttribute *attr = dracoMesh->GetNamedAttribute(type);
  auto vectorCount = dracoMesh->num_points();
  auto componentsPerVector = attr->num_components();
  auto bytesPerComponent = draco::DataTypeLength(attr->data_type());
  auto length = vectorCount * componentsPerVector * bytesPerComponent;
  Buffer data(length);
  for (draco::PointIndex i(0); i < dracoMesh->num_points(); ++i) {
    uint8_t *bytes =
        data.data() + i.value() * componentsPerVector * bytesPerComponent;
    attr->GetMappedValue(i, bytes);
  }
  MeshPrimitiveSource source;
  source.buffer = data;
  source.vectorCount = vectorCount;
  source.componentsPerVector = componentsPerVector;
  source.componentType =
      convertDracoDataTypeToGLTFComponentType(attr->data_type());
  return source;
}

std::future<MeshPrimitive> GLTFData::meshPrimitiveFromDracoExtension(
    const json::MeshPrimitiveDracoExtension &extension) const {
  return std::async(std::launch::async, [this, &extension] {
    auto dracoMesh = decodeDracoMesh(bufferViewAt(extension.bufferView));
    auto primitiveCount = dracoMesh->num_faces();
    auto indicesCount = primitiveCount * 3;
    Buffer indicesData(sizeof(uint32_t) * indicesCount);
    for (draco::FaceIndex i(0); i < dracoMesh->num_faces(); i++) {
      const auto &face = dracoMesh->face(i);
      uint32_t indices[3] = {face[0].value(), face[1].value(), face[2].value()};
      auto offset = sizeof(uint32_t) * 3 * i.value();
      std::memcpy(indicesData.data() + offset, indices, sizeof(uint32_t) * 3);
    }
    MeshPrimitiveElement element;
    element.buffer = indicesData;
    element.primitiveMode = json::MeshPrimitive::Mode::TRIANGLES;
    element.primitiveCount = primitiveCount;
    element.componentType = json::Accessor::ComponentType::UNSIGNED_INT;

    MeshPrimitiveSources sources;
    for (int i = 0; i < dracoMesh->num_attributes(); i++) {
      const auto *attr = dracoMesh->attribute(i);
      auto source =
          processDracoMeshPrimitiveSource(dracoMesh, attr->attribute_type());
      if (attr->attribute_type() == draco::GeometryAttribute::POSITION) {
        sources.position = source;
      } else if (attr->attribute_type() == draco::GeometryAttribute::NORMAL) {
        sources.normal = source;
      } else if (attr->attribute_type() == draco::GeometryAttribute::COLOR) {
        sources.colors.push_back(source);
      } else if (attr->attribute_type() ==
                 draco::GeometryAttribute::TEX_COORD) {
        sources.texcoords.push_back(source);
      }
    }

    MeshPrimitive primitive;
    primitive.sources = sources;
    primitive.element = element;
    return primitive;
  });
}

} // namespace gltf2
