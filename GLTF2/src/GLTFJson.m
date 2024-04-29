#import "GLTFJson.h"

@implementation GLTFJson

+ (void)loadWithData:(nonnull NSData *)data {
  NSError *error;
  NSDictionary *root = [NSJSONSerialization JSONObjectWithData:data
                                                       options:0
                                                         error:&error];
  if (error) {
    NSLog(@"JSON parse error: %@", error);
  } else {
    NSLog(@">>>%@", root);
  }
}

@end
