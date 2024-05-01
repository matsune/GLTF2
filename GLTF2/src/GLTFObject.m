#import "GLTFObject.h"
#import "GLTFBinary.h"
#import "GLTFJSONDecoder.h"

@interface GLTFObject ()

@end

@implementation GLTFObject

- (instancetype)init {
  self = [super init];
  if (self) {
    _buffers = [NSArray array];
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

  if (binary.binary) {
    // json must have buffers[0]
    if (binary.json.buffers && [binary.json.buffers count] > 0) {
      GLTFBuffer *buffer = [GLTFBuffer data:binary.binary
                                       name:binary.json.buffers[0].name];
      object.buffers = [NSArray arrayWithObject:buffer];
    }
  }

  return object;
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
  if (json.buffers && json.buffers.count > 0) {
    NSMutableArray<GLTFBuffer *> *buffers =
        [NSMutableArray arrayWithCapacity:json.buffers.count];
    for (GLTFJSONBuffer *buffer in json.buffers) {
      if ([[NSURL URLWithString:buffer.uri].scheme isEqualToString:@"data"]) {
        NSData *bufferData =
            [NSData dataWithContentsOfURL:[NSURL URLWithString:buffer.uri]];
        [buffers addObject:[GLTFBuffer data:bufferData name:buffer.name]];
      } else {
        // external file, relative path
        NSURL *bufferURL = [NSURL fileURLWithPath:buffer.uri
                                    relativeToURL:[NSURL URLWithString:path]];
        NSData *bufferData = [NSData dataWithContentsOfFile:[bufferURL path]];
        [buffers addObject:[GLTFBuffer data:bufferData name:buffer.name]];
      }
    }
    object.buffers = [buffers copy];
  }

  return object;
}

@end
