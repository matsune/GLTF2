#include "GLTFData.h"
#include "GLTFException.h"
#include "GLTFExtension.h"
#include "GLTFJsonDecoder.h"
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

static const uint32_t GLBHeaderMagic = 0x46546C67;
static const uint32_t GLBChunkTypeJSON = 0x4E4F534A;
static const uint32_t GLBChunkTypeBIN = 0x004E4942;

struct GLBHeader {
  uint32_t magic = 0;
  uint32_t version = 0;
  uint32_t length = 0;
};

struct GLBChunkHead {
  uint32_t length = 0;
  uint32_t type = 0;
};

GLTFData GLTFData::parseJson(const std::string &raw,
                             std::optional<std::filesystem::path> path) {
  try {
    auto data = nlohmann::json::parse(raw);
    auto json = GLTFJsonDecoder::decode(data);
    return GLTFData(json, path);
  } catch (nlohmann::json::exception e) {
    throw InputException(e.what());
  }
}

GLTFData GLTFData::parseData(const char *bytes, uint64_t length,
                             std::optional<std::filesystem::path> path) {
  std::istringstream fs(std::string(bytes, length), std::ios::binary);
  return parseStream(fs, path);
}

GLTFData GLTFData::parseFile(const std::filesystem::path &path) {
  std::ifstream fs;
  fs.open(path.string(), std::ios::binary);
  if (!fs)
    throw InputException("Failed to open file");

  return parseStream(fs, path);
}

GLTFData GLTFData::parseStream(std::istream &fs,
                               std::optional<std::filesystem::path> path) {
  uint32_t magic;
  if (!fs.read(reinterpret_cast<char *>(&magic), sizeof(uint32_t))) {
    throw InputException("Failed to read file");
  }
  fs.seekg(0, std::ios::beg);

  if (magic == GLBHeaderMagic) {
    // GLB
    GLBHeader header;
    if (!fs.read(reinterpret_cast<char *>(&header), sizeof(GLBHeader))) {
      throw InputException("Failed to read glb header");
    }
    if (header.version != 2) {
      std::cerr << "Expected glTF version is 2." << std::endl;
    }

    GLBChunkHead chunkHead0;
    if (!fs.read(reinterpret_cast<char *>(&chunkHead0), sizeof(GLBChunkHead))) {
      throw InputException("Failed to read chunk head");
    }
    if (chunkHead0.type != GLBChunkTypeJSON) {
      throw InputException("Chunk type is not JSON");
    }
    std::string jsonBuf(chunkHead0.length, '\0');
    fs.read(&jsonBuf[0], chunkHead0.length);
    if (fs.gcount() != chunkHead0.length) {
      throw InputException("Failed to read json data");
    }
    auto data = nlohmann::json::parse(jsonBuf);
    auto json = GLTFJsonDecoder::decode(data);

    std::optional<Data> bin;
    if (!fs.eof()) {
      // binary buffer
      GLBChunkHead chunkHead1;
      if (!fs.read(reinterpret_cast<char *>(&chunkHead1),
                   sizeof(GLBChunkHead))) {
        throw InputException("Failed to read chunk head");
      }
      if (chunkHead1.type != GLBChunkTypeBIN) {
        throw InputException("Chunk type is not BIN");
      }
      Data binBuf(chunkHead1.length);
      fs.read(reinterpret_cast<char *>(binBuf.data()), binBuf.size());
      if (fs.gcount() != chunkHead1.length) {
        throw InputException("Failed to read bin data");
      }
      bin = binBuf;
    }
    return GLTFData(json, path, bin);
  } else {
    // GLTF
    std::string raw((std::istreambuf_iterator<char>(fs)),
                    std::istreambuf_iterator<char>());
    try {
      auto data = nlohmann::json::parse(raw);
      auto json = GLTFJsonDecoder::decode(data);
      return GLTFData(json, path);
    } catch (nlohmann::json::exception e) {
      throw InputException(e.what());
    }
  }
}

std::vector<std::string> GLTFData::supportedExtensions() {
  std::vector<std::string> list = {};
  list.push_back(GLTFExtensionKHRDracoMeshCompression);
  return list;
}

Data GLTFData::dataOfUri(const std::string &uri) const {
  // decode percent-encoding
  auto url = boost::url(uri);
  if (url.has_scheme()) {
    if (url.scheme() == "data") {
      // base64
      std::string urlStr(url.c_str());
      auto encoded = urlStr.substr(urlStr.find(',') + 1);
      return cppcodec::base64_rfc4648::decode(encoded);
    } else {
      // unsupported scheme
      return {};
    }
  } else if (url.is_path_absolute()) {
    // absolute path
    std::ifstream file(uri, std::ios::binary);
    return {std::istreambuf_iterator<char>(file),
            std::istreambuf_iterator<char>()};

  } else {
    // relative path
    std::filesystem::path basePathUrl(path.value());
    std::filesystem::path fullUrl = basePathUrl.parent_path() / url.c_str();
    std::ifstream file(fullUrl.string(), std::ios::binary);
    return {std::istreambuf_iterator<char>(file),
            std::istreambuf_iterator<char>()};
  }
}

Data GLTFData::dataForBuffer(const GLTFBuffer &buffer) const {
  if (buffer.uri) {
    return dataOfUri(*buffer.uri);
  } else {
    return bin.value();
  }
}

Data GLTFData::dataForBufferView(uint32_t index, uint32_t offset) const {
  return dataForBufferView(json.bufferViews->at(index), offset);
}

Data GLTFData::dataForBufferView(const GLTFBufferView &bufferView,
                                 uint32_t offset) const {
  auto data = dataForBuffer(json.buffers->at(bufferView.buffer));
  auto loc = data.begin() + bufferView.byteOffset.value_or(0) + offset;
  return Data(loc, loc + bufferView.byteLength);
}

Data GLTFData::dataForBufferView(uint32_t index,
                                 std::optional<uint32_t> offset) const {
  return dataForBufferView(index, offset.value_or(0));
}

Data GLTFData::dataForBuffer(uint32_t index) const {
  return dataForBuffer(json.buffers->at(index));
}

Data GLTFData::dataForAccessor(const GLTFAccessor &accessor,
                               bool *normalized) const {
  auto compTypeSize = GLTFAccessor::sizeOfComponentType(accessor.componentType);
  auto compCount = GLTFAccessor::componentsCountOfType(accessor.type);
  auto typeSize = compTypeSize * compCount;
  auto length = typeSize * accessor.count;
  Data data(length);

  // fill data
  if (accessor.bufferView) {
    const GLTFBufferView &bufferView =
        json.bufferViews->at(*accessor.bufferView);
    auto bufData = dataForBufferView(bufferView);
    const char *dstBase = (const char *)data.data();
    const char *srcBase =
        (const char *)bufData.data() + accessor.byteOffset.value_or(0);
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
    auto sparse = *accessor.sparse;
    auto indices = indicesForAccessorSparse(sparse);
    auto valuesData =
        dataForBufferView(sparse.values.bufferView, sparse.values.byteOffset);
    const char *dstBase = (const char *)data.data();
    const char *srcBase = (const char *)valuesData.data();
    for (int i = 0; i < sparse.count; i++) {
      auto index = indices[i];
      const char *dst = dstBase + typeSize * index;
      const char *src = srcBase + typeSize * i;
      std::memcpy((void *)dst, src, typeSize);
    }
  }

  // normalize
  if (accessor.normalized.value_or(false) &&
      accessor.componentType != GLTFAccessor::ComponentType::FLOAT &&
      accessor.componentType != GLTFAccessor::ComponentType::UNSIGNED_INT) {
    auto normalizedData = normalizeData(data, accessor);
    if (normalized)
      *normalized = true;
    return normalizedData;
  }

  return data;
}

Data GLTFData::dataForAccessor(uint32_t index, bool *normalized) const {
  return dataForAccessor(json.accessors->at(index), normalized);
}

std::vector<uint32_t>
GLTFData::indicesForAccessorSparse(const GLTFAccessorSparse &sparse) const {
  Data indicesData =
      dataForBufferView(sparse.indices.bufferView, sparse.indices.byteOffset);
  std::vector<uint32_t> data(sparse.count);
  uint8_t *ptr = indicesData.data();
  for (int i = 0; i < sparse.count; i++) {
    switch (sparse.indices.componentType) {
    case GLTFAccessorSparseIndices::ComponentType::UNSIGNED_BYTE:
      data.push_back(*ptr);
      ptr += sizeof(uint8_t);
      break;

    case GLTFAccessorSparseIndices::ComponentType::UNSIGNED_SHORT:
      data.push_back(*reinterpret_cast<uint16_t *>(ptr));
      ptr += sizeof(uint16_t);
      break;

    case GLTFAccessorSparseIndices::ComponentType::UNSIGNED_INT:
      data.push_back(*reinterpret_cast<uint32_t *>(ptr));
      ptr += sizeof(uint32_t);
      break;
    }
  }
  return data;
}

static float normalizeValue(const void *bytes, int index,
                            GLTFAccessor::ComponentType compType) {
  switch (compType) {
  case GLTFAccessor::ComponentType::BYTE: {
    int8_t value = *((int8_t *)bytes + index);
    float f = (float)value;
    return f > 0 ? f / (float)INT8_MAX : f / (float)INT8_MIN;
  }
  case GLTFAccessor::ComponentType::UNSIGNED_BYTE: {
    uint8_t value = *((uint8_t *)bytes + index);
    float f = (float)value;
    return f / (float)UINT8_MAX;
  }
  case GLTFAccessor::ComponentType::SHORT: {
    int16_t value = *((int16_t *)bytes + index);
    float f = (float)value;
    return f > 0 ? f / (float)INT16_MAX : f / (float)INT16_MIN;
  }
  case GLTFAccessor::ComponentType::UNSIGNED_SHORT: {
    uint16_t value = *((uint16_t *)bytes + index);
    float f = (float)value;
    return f / (float)UINT16_MAX;
  }
  case GLTFAccessor::ComponentType::UNSIGNED_INT: {
    uint32_t value = *((uint32_t *)bytes + index);
    float f = (float)value;
    return f / (float)UINT32_MAX;
  }
  case GLTFAccessor::ComponentType::FLOAT: {
    return *((float *)bytes + index);
  }
  }
}

Data GLTFData::normalizeData(const Data &data,
                             const GLTFAccessor &accessor) const {
  auto compCount = GLTFAccessor::componentsCountOfType(accessor.type);
  auto length = sizeof(float) * compCount * accessor.count;
  std::vector<float> values(compCount * accessor.count);
  for (int i = 0; i < accessor.count; i++) {
    for (int j = 0; j < compCount; j++) {
      int index = i * compCount + j;
      float value = normalizeValue(data.data(), index, accessor.componentType);
      values[index] = value;
    }
  }
  Data res(length);
  std::memcpy(res.data(), values.data(), length);
  return res;
}

MeshPrimitive
GLTFData::meshPrimitiveFromPrimitive(const GLTFMeshPrimitive &primitive) const {
  if (primitive.dracoExtension) {
    return meshPrimitiveFromDracoExtension(*primitive.dracoExtension);
  }
  MeshPrimitive meshPrimitive;
  if (primitive.attributes.position) {
    meshPrimitive.sources.position =
        meshPrimitiveSourceFromAccessor(*primitive.attributes.position);
  }
  if (primitive.attributes.normal) {
    meshPrimitive.sources.normal =
        meshPrimitiveSourceFromAccessor(*primitive.attributes.normal);
  }
  if (primitive.attributes.tangent) {
    meshPrimitive.sources.tangent =
        meshPrimitiveSourceFromAccessor(*primitive.attributes.tangent);
  }
  if (primitive.attributes.texcoords) {
    for (auto index : *primitive.attributes.texcoords) {
      meshPrimitive.sources.texcoords.push_back(
          meshPrimitiveSourceFromAccessor(index));
    }
  }
  if (primitive.attributes.colors) {
    for (auto index : *primitive.attributes.colors) {
      meshPrimitive.sources.colors.push_back(
          meshPrimitiveSourceFromAccessor(index));
    }
  }
  if (primitive.attributes.joints) {
    for (auto index : *primitive.attributes.joints) {
      meshPrimitive.sources.joints.push_back(
          meshPrimitiveSourceFromAccessor(index));
    }
  }
  if (primitive.attributes.weights) {
    for (auto index : *primitive.attributes.weights) {
      meshPrimitive.sources.weights.push_back(
          meshPrimitiveSourceFromAccessor(index));
    }
  }

  if (primitive.indices) {
    MeshPrimitiveElement element;
    auto &accessor = json.accessors->at(*primitive.indices);
    element.data = dataForAccessor(accessor, nullptr);
    element.primitiveMode = primitive.modeValue();
    element.primitiveCount = accessor.count;
    element.componentType = accessor.componentType;
    meshPrimitive.element = element;
  }

  return meshPrimitive;
}

MeshPrimitiveSource
GLTFData::meshPrimitiveSourceFromAccessor(const GLTFAccessor &accessor) const {
  MeshPrimitiveSource source;

  bool normalized = false;
  auto data = dataForAccessor(accessor, &normalized);
  bool isFloat = accessor.componentType == GLTFAccessor::ComponentType::FLOAT ||
                 normalized;
  GLTFAccessor::ComponentType componentType =
      isFloat ? GLTFAccessor::ComponentType::FLOAT : accessor.componentType;

  source.data = data;
  source.vectorCount = accessor.count;
  source.componentsPerVector =
      GLTFAccessor::componentsCountOfType(accessor.type);
  source.componentType = componentType;
  return source;
}

MeshPrimitiveSource
GLTFData::meshPrimitiveSourceFromAccessor(uint32_t index) const {
  return meshPrimitiveSourceFromAccessor(json.accessors->at(index));
}

MeshPrimitiveSources GLTFData::meshPrimitiveSourcesFromTarget(
    const GLTFMeshPrimitiveTarget &target) const {
  MeshPrimitiveSources sources;
  if (target.position) {
    sources.position = meshPrimitiveSourceFromAccessor(*target.position);
  }
  if (target.normal) {
    sources.normal = meshPrimitiveSourceFromAccessor(*target.normal);
  }
  if (target.tangent) {
    sources.tangent = meshPrimitiveSourceFromAccessor(*target.tangent);
  }
  return sources;
}

static std::unique_ptr<draco::Mesh> decodeDracoMesh(const Data &data) {
  draco::DecoderBuffer buffer;
  buffer.Init((const char *)data.data(), data.size());

  draco::Decoder decoder;
  auto status_or_mesh = decoder.DecodeMeshFromBuffer(&buffer);
  if (!status_or_mesh.ok()) {
    std::cerr << "Failed to decode Draco mesh: "
              << status_or_mesh.status().error_msg() << std::endl;
    return nullptr;
  }

  return std::move(status_or_mesh).value();
}

static GLTFAccessor::ComponentType
convertDracoDataTypeToGLTFComponentType(draco::DataType dracoType) {
  switch (dracoType) {
  case draco::DT_INT8:
    return GLTFAccessor::ComponentType::BYTE;
  case draco::DT_UINT8:
    return GLTFAccessor::ComponentType::UNSIGNED_BYTE;
  case draco::DT_INT16:
    return GLTFAccessor::ComponentType::SHORT;
  case draco::DT_UINT16:
    return GLTFAccessor::ComponentType::UNSIGNED_SHORT;
  case draco::DT_INT32:
    return GLTFAccessor::ComponentType::UNSIGNED_INT;
  case draco::DT_FLOAT32:
    return GLTFAccessor::ComponentType::FLOAT;
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
  Data data(length);
  for (draco::PointIndex i(0); i < dracoMesh->num_points(); ++i) {
    uint8_t *bytes =
        data.data() + i.value() * componentsPerVector * bytesPerComponent;
    attr->GetMappedValue(i, bytes);
  }
  MeshPrimitiveSource source;
  source.data = data;
  source.vectorCount = vectorCount;
  source.componentsPerVector = componentsPerVector;
  source.componentType =
      convertDracoDataTypeToGLTFComponentType(attr->data_type());
  return source;
}

MeshPrimitive GLTFData::meshPrimitiveFromDracoExtension(
    const GLTFMeshPrimitiveDracoExtension &extension) const {
  auto compressedData = dataForBufferView(extension.bufferView);
  auto dracoMesh = decodeDracoMesh(compressedData);
  auto primitiveCount = dracoMesh->num_faces() * 3;
  Data indicesData(sizeof(uint32_t) * primitiveCount);
  for (draco::FaceIndex i(0); i < dracoMesh->num_faces(); i++) {
    const auto &face = dracoMesh->face(i);
    uint32_t indices[3] = {face[0].value(), face[1].value(), face[2].value()};
    auto offset = sizeof(uint32_t) * 3 * i.value();
    std::memcpy(indicesData.data() + offset, indices, sizeof(uint32_t) * 3);
  }
  MeshPrimitiveElement element;
  element.data = indicesData;
  element.primitiveMode = GLTFMeshPrimitive::Mode::TRIANGLES;
  element.primitiveCount = primitiveCount;
  element.componentType = GLTFAccessor::ComponentType::UNSIGNED_INT;

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
    } else if (attr->attribute_type() == draco::GeometryAttribute::TEX_COORD) {
      sources.texcoords.push_back(source);
    }
  }

  MeshPrimitive primitive;
  primitive.sources = sources;
  primitive.element = element;
  return primitive;
}

} // namespace gltf2
