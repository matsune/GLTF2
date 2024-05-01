#import "GLTFObject.h"
#import "GLTFBinary.h"
#import "GLTFJSONDecoder.h"

@implementation GLTFObject

- (instancetype)initWithJson:(GLTFJson *)json {
  return [self initWithJson:json
                bufferDatas:[NSArray array]
                 imageDatas:[NSArray array]];
}

- (instancetype)initWithJson:(GLTFJson *)json
                 bufferDatas:(NSArray<NSData *> *)bufferDatas
                  imageDatas:(NSArray<NSData *> *)imageDatas {
  self = [super init];
  if (self) {
    _json = json;
    _bufferDatas = bufferDatas;
    _imageDatas = imageDatas;
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

  GLTFObject *object = [[GLTFObject alloc] init];

  GLTFJson *json = binary.json;
  NSData *bufferData = binary.binary;

  object.bufferDatas = [NSArray arrayWithObject:bufferData];

  if (json.images) {
    NSMutableArray<NSData *> *imageDatas =
        [NSMutableArray arrayWithCapacity:json.images.count];
    for (GLTFJSONImage *jsonImage in json.images) {
      NSData *data;
      if (jsonImage.bufferView) {
        // use bufferView, mimeType
        GLTFJSONBufferView *bufferView =
            json.bufferViews[[jsonImage.bufferView integerValue]];
        data = [object dataFromBufferView:bufferView];
      }
      [imageDatas addObject:data];
    }
    object.imageDatas = [imageDatas copy];
  }

  return object;
}

+ (NSData *)dataOfUri:(NSString *)uri relativeToPath:(NSString *)basePath {
  if ([[NSURL URLWithString:uri].scheme isEqualToString:@"data"]) {
    return [NSData dataWithContentsOfURL:[NSURL URLWithString:uri]];
  } else {
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
  GLTFJson *json = [GLTFJSONDecoder decodeJsonData:jsonData error:&err];
  if (err) {
    if (error)
      *error = err;
    return nil;
  }

  GLTFObject *object = [[GLTFObject alloc] init];

  if (json.buffers) {
    NSMutableArray<NSData *> *bufferDatas =
        [NSMutableArray arrayWithCapacity:json.buffers.count];
    for (GLTFJSONBuffer *jsonBuffer in json.buffers) {
      NSString *uri = jsonBuffer.uri;
      NSData *data = [self dataOfUri:uri relativeToPath:path];
      [bufferDatas addObject:data];
    }
    object.bufferDatas = [bufferDatas copy];
  }

  if (json.images) {
    NSMutableArray<NSData *> *imageDatas =
        [NSMutableArray arrayWithCapacity:json.images.count];
    for (GLTFJSONImage *jsonImage in json.images) {
      NSData *data;
      if (jsonImage.bufferView) {
        // use bufferView, mimeType
        GLTFJSONBufferView *bufferView =
            json.bufferViews[[jsonImage.bufferView integerValue]];
        data = [object dataFromBufferView:bufferView];
      } else {
        // use uri
        NSString *uri = jsonImage.uri;
        data = [self dataOfUri:uri relativeToPath:path];
      }
      [imageDatas addObject:data];
    }
    object.imageDatas = [imageDatas copy];
  }

  return object;
}

- (NSData *)dataFromBufferView:(GLTFJSONBufferView *)bufferView {
  NSData *bufferData = self.bufferDatas[bufferView.buffer];
  if (bufferView.byteStride &&
      bufferView.byteLength < [bufferView.byteStride integerValue]) {
    NSMutableData *stridedData = [NSMutableData data];
    NSUInteger offset = bufferView.byteOffset;
    NSUInteger endOffset = offset + bufferView.byteLength;
    while (offset < endOffset) {
      [stridedData
          appendData:[bufferData
                         subdataWithRange:NSMakeRange(offset,
                                                      bufferView.byteLength)]];
      offset += [bufferView.byteStride integerValue];
    }
    return stridedData;
  } else {
    return [bufferData subdataWithRange:NSMakeRange(bufferView.byteOffset,
                                                    bufferView.byteLength)];
  }
}

@end
