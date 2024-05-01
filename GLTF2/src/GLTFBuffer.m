#import "GLTFBuffer.h"

@implementation GLTFBuffer

- (instancetype)initWithData:(NSData *)data name:(nullable NSString *)name {
  self = [super init];
  if (self) {
    _data = data;
    _name = name;
  }
  return self;
}

+ (instancetype)data:(NSData *)data name:(nullable NSString *)name {
  return [[GLTFBuffer alloc] initWithData:data name:name];
}

@end
