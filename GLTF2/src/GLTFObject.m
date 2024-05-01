#import "GLTFObject.h"
#import "GLTFBinary.h"
#import "GLTFBuffer.h"
#import "GLTFJSONDecoder.h"

@interface GLTFObject ()

@property(nonatomic, strong) NSArray<GLTFBinary *> *buffers;

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

  return object;
}

@end
