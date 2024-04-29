#import "GLTFAccessor.h"

BOOL isValidGLTFAccessorComponentType(NSUInteger value) {
  return value == GLTFAccessorComponentTypeByte ||
         value == GLTFAccessorComponentTypeUnsignedByte ||
         value == GLTFAccessorComponentTypeShort ||
         value == GLTFAccessorComponentTypeUnsignedShort ||
         value == GLTFAccessorComponentTypeUnsignedInt ||
         value == GLTFAccessorComponentTypeFloat;
}

NSUInteger GLTFAccessorTypeFromString(NSString *typeString) {
  if ([typeString isEqualToString:@"SCALAR"]) {
    return GLTFAccessorTypeScalar;
  } else if ([typeString isEqualToString:@"VEC2"]) {
    return GLTFAccessorTypeVec2;
  } else if ([typeString isEqualToString:@"VEC3"]) {
    return GLTFAccessorTypeVec3;
  } else if ([typeString isEqualToString:@"VEC4"]) {
    return GLTFAccessorTypeVec4;
  } else if ([typeString isEqualToString:@"MAT2"]) {
    return GLTFAccessorTypeMat2;
  } else if ([typeString isEqualToString:@"MAT3"]) {
    return GLTFAccessorTypeMat3;
  } else if ([typeString isEqualToString:@"MAT4"]) {
    return GLTFAccessorTypeMat4;
  } else {
    return NSNotFound;
  }
}

@implementation GLTFAccessor

@end
