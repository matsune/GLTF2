#import "GLTFObject.h"
#import "GLTFBinary.h"
#import "GLTFJSONDecoder.h"

@implementation GLTFObject

//+ (nullable instancetype)objectWithPath:(NSString *)path error:(NSError
//*_Nullable *_Nullable)error {
//
//}

+ (nullable instancetype)objectWithGlbFile:(NSString *)path
                                     error:
                                         (NSError *_Nullable *_Nullable)error {
  NSError *err;
  NSData *data = [NSData dataWithContentsOfFile:path];
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
      NSLog(@">>>>>>>byteLength %ld actual %ld",
            binary.json.buffers[0].byteLength, binary.binary.length);
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
}

@end
