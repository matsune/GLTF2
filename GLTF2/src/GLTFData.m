#import "GLTFData.h"
#import "Errors.h"
#import "GLTFBinary.h"
#import "GLTFDecoder.h"
#import "GLTFJson.h"
#import <MetalKit/MetalKit.h>

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

- (NSData *)dataForAccessor:(GLTFAccessor *)accessor {
  NSInteger componentTypeSize = sizeOfComponentType(accessor.componentType);
  NSInteger componentsCount = componentsCountOfAccessorType(accessor.type);
  NSInteger length = componentsCount * accessor.count * componentTypeSize;
  NSMutableData *data = [NSMutableData dataWithLength:length];

  [self fillData:data
               fromAccessor:accessor
      withComponentTypeSize:componentTypeSize
            componentsCount:componentsCount];

  if (accessor.sparse) {
    [self applySparseToData:data
                 fromAccessor:accessor
        withComponentTypeSize:componentTypeSize
              componentsCount:componentsCount];
  }

  if (accessor.normalized &&
      accessor.componentType != GLTFAccessorComponentTypeFloat &&
      accessor.componentType != GLTFAccessorComponentTypeUnsignedInt) {
    // accessor.normalized must not be true with component type float or
    // unsigned int
    data = [self normalizeData:data
                  fromAccessor:accessor
           withComponentsCount:componentsCount];
  }

  return [data copy];
}

- (void)fillData:(NSMutableData *)data
             fromAccessor:(GLTFAccessor *)accessor
    withComponentTypeSize:(NSInteger)componentTypeSize
          componentsCount:(NSInteger)componentsCount {
  if (accessor.bufferView) {
    GLTFBufferView *bufferView =
        self.json.bufferViews[accessor.bufferView.integerValue];
    NSData *bufferData = [self dataForBufferView:bufferView];
    NSData *subdata = [bufferData
        subdataWithRange:NSMakeRange(accessor.byteOffsetValue, data.length)];
    memcpy(data.mutableBytes, subdata.bytes, subdata.length);
  }
}

- (void)applySparseToData:(NSMutableData *)data
             fromAccessor:(GLTFAccessor *)accessor
    withComponentTypeSize:(NSInteger)componentTypeSize
          componentsCount:(NSInteger)componentsCount {
  NSArray<NSNumber *> *indices =
      [self accessorSparseIndices:accessor.sparse.indices
                            count:accessor.sparse.count];
  NSData *bufferData =
      [self dataForBufferViewIndex:accessor.sparse.values.bufferView];
  NSUInteger byteOffset = accessor.sparse.values.byteOffsetValue;
  NSRange range = NSMakeRange(byteOffset, bufferData.length - byteOffset);
  NSData *valuesData = [bufferData subdataWithRange:range];

  for (int i = 0; i < accessor.sparse.count; i++) {
    NSUInteger index = indices[i].unsignedIntValue;
    NSUInteger bytesOffset = componentTypeSize * componentsCount * index;
    NSUInteger valuesOffset = componentTypeSize * componentsCount * i;
    memcpy(data.mutableBytes + bytesOffset, valuesData.bytes + valuesOffset,
           componentTypeSize * componentsCount);
  }
}

- (NSArray<NSNumber *> *)accessorSparseIndices:
                             (GLTFAccessorSparseIndices *)indices
                                         count:(NSInteger)count {
  NSData *bufferData = [self dataForBufferViewIndex:indices.bufferView];
  NSUInteger byteOffset = indices.byteOffsetValue;
  NSRange range = NSMakeRange(byteOffset, bufferData.length - byteOffset);
  NSData *indicesData = [bufferData subdataWithRange:range];

  NSMutableArray *array = [NSMutableArray arrayWithCapacity:count];
  for (int i = 0; i < count; i++) {
    switch (indices.componentType) {
    case GLTFAccessorSparseIndicesComponentTypeUnsignedByte: {
      // u8
      uint8_t *ptr = (uint8_t *)indicesData.bytes;
      uint8_t value = ptr[i];
      [array addObject:@(value)];
      break;
    }
    case GLTFAccessorSparseIndicesComponentTypeUnsignedShort: {
      // u16
      uint16_t *ptr = (uint16_t *)indicesData.bytes;
      uint16_t value = ptr[i];
      [array addObject:@(value)];
      break;
    }
    case GLTFAccessorSparseIndicesComponentTypeUnsignedInt: {
      // u32
      uint32_t *ptr = (uint32_t *)indicesData.bytes;
      uint32_t value = ptr[i];
      [array addObject:@(value)];
      break;
    }
    default:
      break;
    }
  }
  return [array copy];
}

- (NSMutableData *)normalizeData:(NSMutableData *)data
                    fromAccessor:(GLTFAccessor *)accessor
             withComponentsCount:(NSInteger)componentsCount {
  NSMutableData *normalizedData = [NSMutableData data];
  void *bytes = data.mutableBytes;

  for (NSInteger i = 0; i < accessor.count; i++) {
    for (NSInteger j = 0; j < componentsCount; j++) {
      NSInteger offset = i * componentsCount + j;
      float normalizedValue =
          [self normalizedValueFromBytes:bytes
                                atOffset:offset
                       withComponentType:accessor.componentType];
      [normalizedData appendBytes:&normalizedValue
                           length:sizeof(normalizedValue)];
    }
  }

  return normalizedData;
}

- (float)normalizedValueFromBytes:(void *)bytes
                         atOffset:(NSInteger)offset
                withComponentType:(GLTFAccessorComponentType)componentType {
  switch (componentType) {
  case GLTFAccessorComponentTypeByte: {
    int8_t value = *((int8_t *)bytes + offset);
    return (float)value / (float)INT8_MAX;
  }
  case GLTFAccessorComponentTypeUnsignedByte: {
    uint8_t value = *((uint8_t *)bytes + offset);
    return (float)value / (float)UINT8_MAX;
  }
  case GLTFAccessorComponentTypeShort: {
    int16_t value = *((int16_t *)bytes + offset);
    return (float)value / (float)INT16_MAX;
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

@end
