#import "GLTFBinary.h"
#import "Errors.h"
#import "GLTFJSONDecoder.h"

#pragma mark - GLTFBinaryReader

@interface GLTFBinaryReader : NSObject

@property(nonatomic, strong) NSData *data;
@property(nonatomic, assign) NSUInteger offset;

- (instancetype)initWithData:(NSData *)data;
- (nullable NSData *)readDataWithLength:(NSUInteger)length;
- (void)advanceCursorBy:(NSUInteger)step;
- (BOOL)canReadDataWithLength:(NSUInteger)length;

@end

@implementation GLTFBinaryReader

- (instancetype)initWithData:(NSData *)data {
  self = [super init];
  if (self) {
    _data = data;
    _offset = 0;
  }
  return self;
}

- (nullable NSData *)readDataWithLength:(NSUInteger)length {
  if (![self canReadDataWithLength:length]) {
    return nil;
  }
  NSData *chunk = [self.data subdataWithRange:NSMakeRange(self.offset, length)];
  [self advanceCursorBy:length];
  return chunk;
}

- (void)advanceCursorBy:(NSUInteger)step {
  self.offset += step;
}

- (BOOL)canReadDataWithLength:(NSUInteger)length {
  return self.offset + length <= self.data.length;
}

@end

#pragma mark - GLTFBinary

typedef struct {
  uint32_t magic;
  uint32_t version;
  uint32_t length;
} GLTFBinHeader;

typedef struct {
  uint32_t chunkLength;
  uint32_t chunkType;
} GLTFChunkHead;

static uint32_t const GLTF2BinaryHeaderMagic = 0x46546C67;
static uint32_t const GLTF2BinaryChunkTypeJSON = 0x4E4F534A;
static uint32_t const GLTF2BinaryChunkTypeBIN = 0x004E4942;

@implementation GLTFBinary

- (instancetype)init {
  self = [super init];
  if (self) {
    _json = [[GLTFJson alloc] init];
  }
  return self;
}

+ (nullable instancetype)binaryWithData:(NSData *)data
                                  error:(NSError *_Nullable *_Nullable)error {
  NSError *err;
  GLTFBinary *binary = [[GLTFBinary alloc] init];
  if (![binary loadWithData:data error:&err]) {
    if (error)
      *error = err;
    return nil;
  }
  return binary;
}

- (NSError *)invalidBinaryErrorWithDescription:(NSString *)description {
  return [NSError errorWithDomain:GLTF2BinaryErrorDomain
                             code:GLTF2BinaryErrorInvalidFormat
                         userInfo:@{NSLocalizedDescriptionKey : description}];
}

- (BOOL)loadWithData:(NSData *)data error:(NSError *_Nullable *)error {
  GLTFBinaryReader *reader = [[GLTFBinaryReader alloc] initWithData:data];

  // Header
  GLTFBinHeader header;
  if (![reader canReadDataWithLength:sizeof(GLTFBinHeader)]) {
    if (error)
      *error =
          [self invalidBinaryErrorWithDescription:@"Data too short for header"];
    return NO;
  }
  NSData *headerData = [reader readDataWithLength:sizeof(GLTFBinHeader)];
  [headerData getBytes:&header length:sizeof(GLTFBinHeader)];
  if (header.magic != GLTF2BinaryHeaderMagic) {
    if (error)
      *error =
          [self invalidBinaryErrorWithDescription:@"Invalid magic in header"];
    return NO;
  }
  self.version = (NSInteger)header.version;

  // JSON chunk
  GLTFChunkHead jsonChunkHead;
  if (![reader canReadDataWithLength:sizeof(GLTFChunkHead)]) {
    if (error)
      *error = [self invalidBinaryErrorWithDescription:
                         @"Data too short for json chunk head"];
    return NO;
  }
  NSData *jsonChunkHeadData = [reader readDataWithLength:sizeof(GLTFChunkHead)];
  [jsonChunkHeadData getBytes:&jsonChunkHead length:sizeof(GLTFChunkHead)];
  if (jsonChunkHead.chunkType != GLTF2BinaryChunkTypeJSON) {
    if (error)
      *error =
          [self invalidBinaryErrorWithDescription:@"Chunk type is not JSON"];
    return NO;
  }
  if (![reader canReadDataWithLength:jsonChunkHead.chunkLength]) {
    if (error)
      *error = [self invalidBinaryErrorWithDescription:
                         @"Data too short for json chunk data"];
    return NO;
  }
  NSData *jsonChunkData = [reader readDataWithLength:jsonChunkHead.chunkLength];
  self.json = [GLTFJSONDecoder decodeJsonData:jsonChunkData error:error];
  if (*error)
    return NO;

  // BIN chunk
  if ([reader canReadDataWithLength:sizeof(GLTFChunkHead)]) {
    GLTFChunkHead binChunkHead;
    NSData *binChunkHeadData =
        [reader readDataWithLength:sizeof(GLTFChunkHead)];
    [binChunkHeadData getBytes:&binChunkHead length:sizeof(GLTFChunkHead)];
    if (binChunkHead.chunkType != GLTF2BinaryChunkTypeBIN) {
      *error =
          [self invalidBinaryErrorWithDescription:@"Chunk type is not BIN"];
      return NO;
    }
    if (![reader canReadDataWithLength:binChunkHead.chunkLength]) {
      *error = [self invalidBinaryErrorWithDescription:
                         @"Data too short for binary chunk data"];
      return NO;
    }
    NSData *binChunkData = [reader readDataWithLength:binChunkHead.chunkLength];
    self.binary = binChunkData;
  }

  return YES;
}

@end
