#import "GLTFData.h"
#import "Errors.h"
#import "GLTFBinary.h"
#import "GLTFDecoder.h"
#import "GLTFJson.h"
#if DRACO_SUPPORT
#include "draco/compression/decode.h"
#include "draco/core/decoder_buffer.h"
#endif
#import "GLTFConstants.h"
#import <MetalKit/MetalKit.h>
#include <cstring>

@implementation GLTFData

- (instancetype)initWithJson:(GLTFJson *)json
                        path:(nullable NSString *)path
                      binary:(nullable NSData *)binary {
  self = [super init];
  if (self) {
    _json = json;
    _path = path;
    _binary = binary;
  }
  return self;
}

+ (nullable instancetype)dataWithFile:(NSString *)path
                                error:(NSError *_Nullable *_Nullable)error {
  NSString *extension = path.pathExtension.lowercaseString;
  NSData *data = [NSData dataWithContentsOfFile:path];
  if ([extension isEqualToString:@"glb"]) {
    return [self dataWithGlbData:data error:error];
  } else if ([extension isEqualToString:@"gltf"]) {
    return [self dataWithGltfData:data path:path error:error];
  } else {
    if (error) {
      *error = [NSError
          errorWithDomain:GLTF2BinaryErrorDomain
                     code:GLTF2BinaryErrorUnsupportedFile
                 userInfo:@{
                   NSLocalizedDescriptionKey : @"Unsupported file format"
                 }];
    }
    return nil;
  }
}

+ (nullable instancetype)dataWithGlbData:(NSData *)data
                                   error:(NSError *_Nullable *_Nullable)error {
  GLTFBinary *binary = [GLTFBinary binaryWithData:data error:error];
  if (!binary)
    return nil;

  NSError *extensionErr = [self checkRequiredExtensions:binary.json];
  if (extensionErr) {
    if (error)
      *error = extensionErr;
    return nil;
  }

  return [[GLTFData alloc] initWithJson:binary.json
                                   path:nil
                                 binary:binary.binary];
}

+ (nullable instancetype)dataWithGltfData:(NSData *)data
                                     path:(nullable NSString *)path
                                    error:(NSError *_Nullable *_Nullable)error {
  GLTFJson *json = [GLTFDecoder decodeJsonData:data error:error];
  if (!json)
    return nil;

  NSError *extensionErr = [self checkRequiredExtensions:json];
  if (extensionErr) {
    if (error)
      *error = extensionErr;
    return nil;
  }

  return [[GLTFData alloc] initWithJson:json path:path binary:nil];
}

+ (nullable NSError *)checkRequiredExtensions:(GLTFJson *)json {
  NSMutableArray<NSString *> *unsupportedExtensions = [NSMutableArray array];
  if (json.extensionsRequired) {
    for (NSString *extension in json.extensionsRequired) {
      if (![GLTFData isSupportedExtension:extension]) {
        [unsupportedExtensions addObject:extension];
      }
    }
  }
  if (unsupportedExtensions.count > 0) {
    return [NSError
        errorWithDomain:GLTF2DataErrorDomain
                   code:GLTF2DataErrorUnsupportedExtensionRequired
               userInfo:@{
                 NSLocalizedDescriptionKey : [NSString
                     stringWithFormat:@"Unsupported extensions: %@",
                                      [unsupportedExtensions
                                          componentsJoinedByString:@", "]]
               }];
  }
  return nil;
}

+ (NSArray<NSString *> *)supportedExtensions {
  NSMutableArray<NSString *> *list = [NSMutableArray array];
#if DRACO_SUPPORT
  [list addObject:GLTFExtensionKHRDracoMeshCompression];
#endif
  return [list copy];
}

+ (BOOL)isSupportedExtension:(NSString *)extension {
  return [[GLTFData supportedExtensions] containsObject:extension];
}

- (nullable NSData *)dataOfUri:(NSString *)uri {
  NSString *decodedUri = [uri stringByRemovingPercentEncoding];
  NSURL *url = [NSURL URLWithString:decodedUri];
  if (url && url.scheme) {
    if ([url.scheme isEqualToString:@"data"]) {
      // base64
      NSRange range = [decodedUri rangeOfString:@"base64,"];
      NSString *encodedString = decodedUri;
      if (range.location != NSNotFound) {
        encodedString = [decodedUri substringFromIndex:NSMaxRange(range)];
      }
      return [[NSData alloc]
          initWithBase64EncodedString:encodedString
                              options:
                                  NSDataBase64DecodingIgnoreUnknownCharacters];
    } else {
      // unsupported scheme
      return nil;
    }
  } else if ([decodedUri hasPrefix:@"/"]) {
    // absolute path
    return [NSData dataWithContentsOfFile:decodedUri];
  } else {
    // relative path
    NSURL *relativeURL =
        [NSURL fileURLWithPath:decodedUri
                 relativeToURL:[NSURL URLWithString:self.path]];
    return [NSData dataWithContentsOfFile:[relativeURL path]];
  }
}

- (NSData *)dataForBuffer:(GLTFBuffer *)buffer {
  if (buffer.uri) {
    return [self dataOfUri:buffer.uri];
  } else {
    assert(self.binary != nil);
    return self.binary;
  }
}

- (NSData *)dataForBufferIndex:(NSInteger)bufferIndex {
  return [self dataForBuffer:self.json.buffers[bufferIndex]];
}

- (NSData *)dataForBufferView:(GLTFBufferView *)bufferView {
  NSData *data = [self dataForBufferIndex:bufferView.buffer];
  return [data subdataWithRange:NSMakeRange(bufferView.byteOffsetValue,
                                            bufferView.byteLength)];
}

- (NSData *)dataForBufferViewIndex:(NSInteger)bufferViewIndex {
  return [self dataForBufferView:self.json.bufferViews[bufferViewIndex]];
}

- (NSData *)dataForBufferViewIndex:(NSInteger)bufferViewIndex
                    withByteOffset:(NSUInteger)byteOffset {
  NSData *bufferData = [self dataForBufferViewIndex:bufferViewIndex];
  NSRange range = NSMakeRange(byteOffset, bufferData.length - byteOffset);
  return [bufferData subdataWithRange:range];
}

- (CGImageRef)createCGImageFromData:(NSData *)data {
  CGImageSourceRef source =
      CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
  CGImageRef imageRef = CGImageSourceCreateImageAtIndex(source, 0, NULL);
  CFRelease(source);
  return imageRef;
}

- (CGImageRef)cgImageForImage:(GLTFImage *)image {
  NSData *data;
  if (image.uri) {
    data = [self dataOfUri:image.uri];
  } else {
    assert(image.bufferView != nil);
    data = [self dataForBufferViewIndex:image.bufferView.integerValue];
  }
  return [self createCGImageFromData:data];
}

- (NSData *)dataForAccessor:(GLTFAccessor *)accessor
                 normalized:(nullable BOOL *)normalized {
  NSInteger componentTypeSize =
      sizeOfComponentType((GLTFAccessorComponentType)accessor.componentType);
  NSInteger componentsCount = componentsCountOfAccessorType(accessor.type);
  NSInteger packedSize = componentTypeSize * componentsCount;
  NSInteger length = packedSize * accessor.count;
  NSMutableData *data = [NSMutableData dataWithLength:length];

  // fill data
  if (accessor.bufferView) {
    GLTFBufferView *bufferView =
        self.json.bufferViews[accessor.bufferView.integerValue];
    NSData *bufferData = [self dataForBufferView:bufferView];
    const char *dstBaseAddress = (const char *)data.mutableBytes;
    const char *srcBaseAddress =
        (const char *)bufferData.bytes + accessor.byteOffsetValue;
    if (bufferView.byteStride &&
        bufferView.byteStride.integerValue != packedSize) {
      for (int i = 0; i < accessor.count; i++) {
        const char *dst = dstBaseAddress + i * packedSize;
        const void *src =
            srcBaseAddress + i * bufferView.byteStride.integerValue;
        std::memcpy((void *)dst, (void *)src, packedSize);
      }
    } else {
      std::memcpy((void *)dstBaseAddress, (void *)srcBaseAddress, length);
    }
  }

  // sparse
  if (accessor.sparse) {
    NSArray<NSNumber *> *indices =
        [self accessorSparseIndices:accessor.sparse.indices
                              count:accessor.sparse.count];
    NSData *valuesData =
        [self dataForBufferViewIndex:accessor.sparse.values.bufferView
                      withByteOffset:accessor.sparse.values.byteOffsetValue];

    const char *dstBaseAddress = (const char *)data.mutableBytes;
    const char *srcBaseAddress = (const char *)valuesData.bytes;
    for (int i = 0; i < accessor.sparse.count; i++) {
      NSUInteger index = indices[i].unsignedIntegerValue;
      const char *dst = dstBaseAddress + packedSize * index;
      const char *src = srcBaseAddress + packedSize * i;
      std::memcpy((void *)dst, (void *)src, packedSize);
    }
  }

  // normalize
  if (accessor.normalized &&
      accessor.componentType != GLTFAccessorComponentTypeFloat &&
      accessor.componentType != GLTFAccessorComponentTypeUnsignedInt) {
    NSData *normalizedData = [self normalizeData:data fromAccessor:accessor];
    if (normalized)
      *normalized = YES;
    return normalizedData;
  }

  return [data copy];
}

- (NSArray<NSNumber *> *)accessorSparseIndices:
                             (GLTFAccessorSparseIndices *)indices
                                         count:(NSInteger)count {
  NSData *indicesData = [self dataForBufferViewIndex:indices.bufferView
                                      withByteOffset:indices.byteOffsetValue];
  NSMutableArray *array = [NSMutableArray arrayWithCapacity:count];
  for (int i = 0; i < count; i++) {
    switch (indices.componentType) {
    case GLTFAccessorSparseIndicesComponentTypeUnsignedByte: {
      uint8_t value = ((uint8_t *)indicesData.bytes)[i];
      [array addObject:@(value)];
      break;
    }
    case GLTFAccessorSparseIndicesComponentTypeUnsignedShort: {
      uint16_t value = ((uint16_t *)indicesData.bytes)[i];
      [array addObject:@(value)];
      break;
    }
    case GLTFAccessorSparseIndicesComponentTypeUnsignedInt: {
      uint32_t value = ((uint32_t *)indicesData.bytes)[i];
      [array addObject:@(value)];
      break;
    }
    default:
      break;
    }
  }
  return [array copy];
}

- (NSData *)normalizeData:(NSMutableData *)data
             fromAccessor:(GLTFAccessor *)accessor {
  NSUInteger componentsCount = componentsCountOfAccessorType(accessor.type);
  NSUInteger length = sizeof(float) * componentsCount * accessor.count;
  float *normalizedValues = (float *)malloc(length);

  for (NSInteger i = 0; i < accessor.count; i++) {
    for (NSInteger j = 0; j < componentsCount; j++) {
      NSInteger componentOffset = i * componentsCount + j;
      float normalizedValue =
          [self normalizedValueFromBytes:data.bytes
                                atOffset:componentOffset
                       withComponentType:(GLTFAccessorComponentType)
                                             accessor.componentType];
      normalizedValues[componentOffset] = normalizedValue;
    }
  }
  return [NSData dataWithBytesNoCopy:normalizedValues
                              length:length
                        freeWhenDone:YES];
}

- (float)normalizedValueFromBytes:(const void *)bytes
                         atOffset:(NSInteger)offset
                withComponentType:(GLTFAccessorComponentType)componentType {
  switch (componentType) {
  case GLTFAccessorComponentTypeByte: {
    int8_t value = *((int8_t *)bytes + offset);
    float f = (float)value;
    return f > 0 ? f / (float)INT8_MAX : f / (float)INT8_MIN;
  }
  case GLTFAccessorComponentTypeUnsignedByte: {
    uint8_t value = *((uint8_t *)bytes + offset);
    return (float)value / (float)UINT8_MAX;
  }
  case GLTFAccessorComponentTypeShort: {
    int16_t value = *((int16_t *)bytes + offset);
    float f = (float)value;
    return f > 0 ? f / (float)INT16_MAX : f / (float)INT16_MIN;
  }
  case GLTFAccessorComponentTypeUnsignedShort: {
    uint16_t value = *((uint16_t *)bytes + offset);
    return (float)value / (float)UINT16_MAX;
  }
  case GLTFAccessorComponentTypeUnsignedInt: {
    uint32_t value = *((uint32_t *)bytes + offset);
    return (float)value / (float)UINT32_MAX;
  }
  case GLTFAccessorComponentTypeFloat: {
    float value = *((float *)bytes + offset);
    return value;
  }
  default:
    return 0.0f;
  }
}

- (MeshPrimitive *)meshPrimitive:(GLTFMeshPrimitive *)primitive {
#if DRACO_SUPPORT
  if (primitive.dracoExtension) {
    return [self meshPrimitiveFromDracoExtension:primitive.dracoExtension];
  }
#endif

  MeshPrimitiveSources *sources = [[MeshPrimitiveSources alloc] init];
  if (primitive.attributes.position) {
    GLTFAccessor *accessor =
        self.json.accessors[primitive.attributes.position.integerValue];
    MeshPrimitiveSource *source =
        [self meshPrimitiveSourceFromAccessor:accessor];
    sources.position = source;
  }
  if (primitive.attributes.normal) {
    GLTFAccessor *accessor =
        self.json.accessors[primitive.attributes.normal.integerValue];
    MeshPrimitiveSource *source =
        [self meshPrimitiveSourceFromAccessor:accessor];
    sources.normal = source;
  }
  if (primitive.attributes.tangent) {
    GLTFAccessor *accessor =
        self.json.accessors[primitive.attributes.tangent.integerValue];
    MeshPrimitiveSource *source =
        [self meshPrimitiveSourceFromAccessor:accessor];
    sources.tangent = source;
  }
  if (primitive.attributes.texcoord) {
    NSMutableArray<MeshPrimitiveSource *> *texcoords = [NSMutableArray array];
    for (NSNumber *texcoord in primitive.attributes.texcoord) {
      GLTFAccessor *accessor = self.json.accessors[texcoord.integerValue];
      MeshPrimitiveSource *source =
          [self meshPrimitiveSourceFromAccessor:accessor];
      [texcoords addObject:source];
    }
    sources.texcoords = texcoords;
  }
  if (primitive.attributes.color) {
    NSMutableArray<MeshPrimitiveSource *> *colors = [NSMutableArray array];
    for (NSNumber *color in primitive.attributes.color) {
      GLTFAccessor *accessor = self.json.accessors[color.integerValue];
      MeshPrimitiveSource *source =
          [self meshPrimitiveSourceFromAccessor:accessor];
      [colors addObject:source];
    }
    sources.colors = colors;
  }
  if (primitive.attributes.joints) {
    NSMutableArray<MeshPrimitiveSource *> *joints = [NSMutableArray array];
    for (NSNumber *joint in primitive.attributes.joints) {
      GLTFAccessor *accessor = self.json.accessors[joint.integerValue];
      MeshPrimitiveSource *source =
          [self meshPrimitiveSourceFromAccessor:accessor];
      [joints addObject:source];
    }
    sources.joints = joints;
  }
  if (primitive.attributes.weights) {
    NSMutableArray<MeshPrimitiveSource *> *weights = [NSMutableArray array];
    for (NSNumber *weight in primitive.attributes.weights) {
      GLTFAccessor *accessor = self.json.accessors[weight.integerValue];
      MeshPrimitiveSource *source =
          [self meshPrimitiveSourceFromAccessor:accessor];
      [weights addObject:source];
    }
    sources.weights = weights;
  }

  MeshPrimitiveElement *element;
  if (primitive.indices) {
    GLTFAccessor *accessor =
        self.json.accessors[primitive.indices.integerValue];
    NSData *data = [self dataForAccessor:accessor normalized:nil];
    NSInteger primitiveCount = accessor.count;
    GLTFMeshPrimitiveMode primitiveMode =
        (GLTFMeshPrimitiveMode)primitive.modeValue;
    element = [MeshPrimitiveElement
        elementWithData:data
          primitiveMode:primitiveMode
         primitiveCount:primitiveCount
          componentType:(GLTFAccessorComponentType)accessor.componentType];
  }

  return [[MeshPrimitive alloc] initWithSources:sources element:element];
}

- (MeshPrimitiveSource *)meshPrimitiveSourceFromAccessor:
    (GLTFAccessor *)accessor {
  BOOL normalized;
  NSData *data = [self dataForAccessor:accessor normalized:&normalized];
  BOOL isFloat =
      accessor.componentType == GLTFAccessorComponentTypeFloat || normalized;
  GLTFAccessorComponentType componentType =
      isFloat ? GLTFAccessorComponentTypeFloat
              : (GLTFAccessorComponentType)accessor.componentType;
  return [MeshPrimitiveSource
           sourceWithData:data
              vectorCount:accessor.count
      componentsPerVector:componentsCountOfAccessorType(accessor.type)
            componentType:componentType];
}

- (MeshPrimitiveSources *)meshPrimitiveSourcesFromTarget:
    (GLTFMeshPrimitiveTarget *)target {
  MeshPrimitiveSources *sources = [[MeshPrimitiveSources alloc] init];
  if (target.position) {
    GLTFAccessor *accessor = self.json.accessors[target.position.integerValue];
    MeshPrimitiveSource *source =
        [self meshPrimitiveSourceFromAccessor:accessor];
    sources.position = source;
  }
  if (target.normal) {
    GLTFAccessor *accessor = self.json.accessors[target.normal.integerValue];
    MeshPrimitiveSource *source =
        [self meshPrimitiveSourceFromAccessor:accessor];
    sources.normal = source;
  }
  if (target.tangent) {
    GLTFAccessor *accessor = self.json.accessors[target.tangent.integerValue];
    MeshPrimitiveSource *source =
        [self meshPrimitiveSourceFromAccessor:accessor];
    sources.tangent = source;
  }
  return sources;
}

#if DRACO_SUPPORT
std::unique_ptr<draco::Mesh> DecodeDracoMesh(NSData *data) {
  draco::DecoderBuffer buffer;
  buffer.Init(reinterpret_cast<const char *>(data.bytes), data.length);

  draco::Decoder decoder;
  auto status_or_mesh = decoder.DecodeMeshFromBuffer(&buffer);
  if (!status_or_mesh.ok()) {
    std::cerr << "Failed to decode Draco mesh: "
              << status_or_mesh.status().error_msg() << std::endl;
    return nullptr;
  }

  return std::move(status_or_mesh).value();
}

- (NSData *)dataWithDracoMesh:(std::unique_ptr<draco::Mesh> &)mesh
                    attribute:(draco::GeometryAttribute::Type)attribute {
  const draco::PointAttribute *attr = mesh->GetNamedAttribute(attribute);
  return [NSData dataWithBytes:attr->buffer()->data()
                        length:attr->buffer()->data_size()];
}

GLTFAccessorComponentType
convertDracoDataTypeToGLTFComponentType(draco::DataType dracoType) {
  switch (dracoType) {
  case draco::DT_INT8:
    return GLTFAccessorComponentTypeByte;
  case draco::DT_UINT8:
    return GLTFAccessorComponentTypeUnsignedByte;
  case draco::DT_INT16:
    return GLTFAccessorComponentTypeShort;
  case draco::DT_UINT16:
    return GLTFAccessorComponentTypeUnsignedShort;
  case draco::DT_INT32:
    return GLTFAccessorComponentTypeUnsignedInt;
  case draco::DT_FLOAT32:
    return GLTFAccessorComponentTypeFloat;
  default:
    throw std::runtime_error("Unsupported Draco data type");
  }
}

MeshPrimitiveSource *
processDracoMeshPrimitiveSource(const std::unique_ptr<draco::Mesh> &dracoMesh,
                                draco::GeometryAttribute::Type type) {
  const draco::PointAttribute *attr = dracoMesh->GetNamedAttribute(type);
  int vectorCount = dracoMesh->num_points();
  int componentsPerVector = attr->num_components();
  int bytesPerComponent = draco::DataTypeLength(attr->data_type());
  int length = vectorCount * componentsPerVector * bytesPerComponent;

  NSMutableData *data = [NSMutableData dataWithLength:length];
  for (draco::PointIndex i(0); i < dracoMesh->num_points(); ++i) {
    uint8_t *bytes = (uint8_t *)data.mutableBytes +
                     i.value() * componentsPerVector * bytesPerComponent;
    attr->GetMappedValue(i, bytes);
  }

  return [MeshPrimitiveSource
           sourceWithData:[data copy]
              vectorCount:vectorCount
      componentsPerVector:componentsPerVector
            componentType:convertDracoDataTypeToGLTFComponentType(
                              attr->data_type())];
}

- (MeshPrimitive *)meshPrimitiveFromDracoExtension:
    (GLTFMeshPrimitiveDracoExtension *)dracoExtension {
  NSData *compressedData =
      [self dataForBufferViewIndex:dracoExtension.bufferView];
  auto dracoMesh = DecodeDracoMesh(compressedData);

  NSInteger primitiveCount = dracoMesh->num_faces() * 3;
  NSMutableData *indicesData =
      [NSMutableData dataWithLength:sizeof(uint32_t) * primitiveCount];
  for (draco::FaceIndex i(0); i < dracoMesh->num_faces(); i++) {
    const auto &face = dracoMesh->face(i);
    uint32_t indices[3] = {face[0].value(), face[1].value(), face[2].value()};
    NSInteger offset = sizeof(uint32_t) * 3 * i.value();
    std::memcpy((uint8_t *)indicesData.mutableBytes + offset, indices,
                sizeof(uint32_t) * 3);
  }

  MeshPrimitiveElement *element = [MeshPrimitiveElement
      elementWithData:[indicesData copy]
        primitiveMode:GLTFMeshPrimitiveModeTriangles
       primitiveCount:primitiveCount
        componentType:GLTFAccessorComponentTypeUnsignedInt];

  MeshPrimitiveSources *sources = [[MeshPrimitiveSources alloc] init];
  NSMutableArray<MeshPrimitiveSource *> *colors;
  NSMutableArray<MeshPrimitiveSource *> *texcoords;
  for (int32_t i = 0; i < dracoMesh->num_attributes(); ++i) {
    const auto *attr = dracoMesh->attribute(i);

    MeshPrimitiveSource *source =
        processDracoMeshPrimitiveSource(dracoMesh, attr->attribute_type());
    if (attr->attribute_type() == draco::GeometryAttribute::POSITION) {
      sources.position = source;
    } else if (attr->attribute_type() == draco::GeometryAttribute::NORMAL) {
      sources.normal = source;
    } else if (attr->attribute_type() == draco::GeometryAttribute::COLOR) {
      if (!colors)
        colors = [NSMutableArray array];
      [colors addObject:source];
    } else if (attr->attribute_type() == draco::GeometryAttribute::TEX_COORD) {
      if (!texcoords)
        texcoords = [NSMutableArray array];
      [texcoords addObject:source];
    }
  }
  sources.colors = colors;
  sources.texcoords = texcoords;

  return [[MeshPrimitive alloc] initWithSources:sources element:element];
}
#endif

@end
