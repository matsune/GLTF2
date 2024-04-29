#import "GLTFAccessorSparseIndices.h"

BOOL isValidGLTFAccessorSparseIndicesComponentType(NSUInteger value) {
  return value == GLTFAccessorSparseIndicesComponentTypeUnsignedByte ||
         value == GLTFAccessorSparseIndicesComponentTypeUnsignedShort ||
         value == GLTFAccessorSparseIndicesComponentTypeUnsignedInt;
}

@implementation GLTFAccessorSparseIndices

@end
