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

  return [[GLTFData alloc] initWithJson:json path:path binary:nil];
}

+ (NSArray<NSString *> *)supportedExtensions {
  NSMutableArray<NSString *> *list = [NSMutableArray array];
#if DRACO_SUPPORT
  [list addObject:GLTFExtensionKHRDracoMeshCompression];
#endif
  return [list copy];
}

- (BOOL)isAvailableExtension:(NSString *)extension {
  return [[GLTFData supportedExtensions] containsObject:extension] &&
         self.json.extensionsRequired &&
         [self.json.extensionsRequired containsObject:extension];
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
  MeshPrimitive *meshPrimitive = [[MeshPrimitive alloc] init];
  if (primitive.dracoExtension &&
      [self isAvailableExtension:GLTFExtensionKHRDracoMeshCompression]) {
    // TODO: draco
  }

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
  meshPrimitive.sources = sources;

  if (primitive.indices) {
    GLTFAccessor *accessor =
        self.json.accessors[primitive.indices.integerValue];
    NSData *data = [self dataForAccessor:accessor normalized:nil];
    NSInteger primitiveCount = accessor.count;
    GLTFMeshPrimitiveMode primitiveMode =
        (GLTFMeshPrimitiveMode)primitive.modeValue;
    meshPrimitive.element = [MeshPrimitiveElement
        elementWithData:data
          primitiveMode:primitiveMode
         primitiveCount:primitiveCount
          componentType:(GLTFAccessorComponentType)accessor.componentType];
  }

  return meshPrimitive;
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

@end
