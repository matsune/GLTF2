#import "GLTFObject.h"
#import "GLTFBinary.h"
#import "GLTFDecoder.h"
#import "GLTFJson.h"

@implementation GLTFObject

- (instancetype)initWithJson:(GLTFJson *)json
                 bufferDatas:(NSArray<NSData *> *)bufferDatas {
  self = [super init];
  if (self) {
    _json = json;
    _bufferDatas = bufferDatas;
  }
  return self;
}

+ (nullable instancetype)objectWithGlbFile:(NSString *)path
                                     error:
                                         (NSError *_Nullable *_Nullable)error {
  NSData *data = [NSData dataWithContentsOfFile:path];
  return [self objectWithGlbData:data error:error];
}

+ (nullable instancetype)objectWithGlbData:(NSData *)data
                                     error:
                                         (NSError *_Nullable *_Nullable)error {
  NSError *err;
  GLTFBinary *binary = [GLTFBinary binaryWithData:data error:&err];
  if (err) {
    if (error)
      *error = err;
    return nil;
  }
  return
      [[GLTFObject alloc] initWithJson:binary.json
                           bufferDatas:[NSArray arrayWithObject:binary.binary]];
}

+ (NSData *)dataOfUri:(NSString *)uri
       relativeToPath:(nullable NSString *)basePath {
  if ([[NSURL URLWithString:uri].scheme isEqualToString:@"data"]) {
    NSRange range = [uri rangeOfString:@"base64,"];
    NSString *encodedString = uri;
    if (range.location != NSNotFound) {
      encodedString = [uri substringFromIndex:NSMaxRange(range)];
    }
    return [[NSData alloc]
        initWithBase64EncodedString:encodedString
                            options:
                                NSDataBase64DecodingIgnoreUnknownCharacters];
  } else {
    assert(basePath != nil);
    // external file, relative path
    NSURL *bufferURL = [NSURL fileURLWithPath:uri
                                relativeToURL:[NSURL URLWithString:basePath]];
    return [NSData dataWithContentsOfFile:[bufferURL path]];
  }
}

+ (nullable instancetype)objectWithGltfFile:(NSString *)path
                                      error:
                                          (NSError *_Nullable *_Nullable)error {
  NSError *err;
  NSData *jsonData = [NSData dataWithContentsOfFile:path];
  GLTFJson *json = [GLTFDecoder decodeJsonData:jsonData error:&err];
  if (err) {
    if (error)
      *error = err;
    return nil;
  }

  NSMutableArray<NSData *> *bufferDatas = [NSMutableArray array];
  if (json.buffers) {
    for (GLTFBuffer *jsonBuffer in json.buffers) {
      NSString *uri = jsonBuffer.uri;
      NSData *data = [self dataOfUri:uri relativeToPath:path];
      [bufferDatas addObject:data];
    }
  }

  return [[GLTFObject alloc] initWithJson:json bufferDatas:[bufferDatas copy]];
}

+ (nullable instancetype)objectWithGltfData:(NSData *)jsonData
                                      error:
                                          (NSError *_Nullable *_Nullable)error {
  NSError *err;
  GLTFJson *json = [GLTFDecoder decodeJsonData:jsonData error:&err];
  if (err) {
    if (error)
      *error = err;
    return nil;
  }

  NSMutableArray<NSData *> *bufferDatas = [NSMutableArray array];
  if (json.buffers) {
    for (GLTFBuffer *jsonBuffer in json.buffers) {
      NSString *uri = jsonBuffer.uri;
      NSData *data = [self dataOfUri:uri relativeToPath:nil];
      [bufferDatas addObject:data];
    }
  }

  return [[GLTFObject alloc] initWithJson:json bufferDatas:[bufferDatas copy]];
}

- (NSData *)dataFromBufferViewIndex:(NSInteger)bufferViewIndex
                         byteOffset:(NSInteger)byteOffset {
  GLTFBufferView *bufferView = self.json.bufferViews[bufferViewIndex];
  return [self dataFromBufferView:bufferView byteOffset:byteOffset];
}

- (NSData *)dataFromBufferView:(GLTFBufferView *)bufferView
                    byteOffset:(NSInteger)byteOffset {
  NSData *bufferData = self.bufferDatas[bufferView.buffer];
  return [bufferData
      subdataWithRange:NSMakeRange(bufferView.byteOffset + byteOffset,
                                   bufferView.byteLength - byteOffset)];
}

- (NSData *)dataByAccessor:(GLTFAccessor *)accessor {
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

  return data;
}

- (void)fillData:(NSMutableData *)data
             fromAccessor:(GLTFAccessor *)accessor
    withComponentTypeSize:(NSInteger)componentTypeSize
          componentsCount:(NSInteger)componentsCount {
  if (accessor.bufferView) {
    GLTFBufferView *bufferView =
        self.json.bufferViews[accessor.bufferView.integerValue];
    NSData *bufferData = self.bufferDatas[bufferView.buffer];
    NSData *subdata =
        [bufferData subdataWithRange:NSMakeRange(bufferView.byteOffset +
                                                     accessor.byteOffset,
                                                 data.length)];
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
  NSData *valuesData =
      [self dataFromBufferViewIndex:accessor.sparse.values.bufferView
                         byteOffset:accessor.sparse.values.byteOffset];

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
  NSData *indicesData = [self dataFromBufferViewIndex:indices.bufferView
                                           byteOffset:indices.byteOffset];
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
