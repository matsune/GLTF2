#import "GLTFSampler.h"

BOOL isValidGLTFSamplerMagFilter(NSUInteger value) {
  return value == GLTFSamplerMagFilterNearest ||
         value == GLTFSamplerMagFilterLinear;
}

BOOL isValidGLTFSamplerMinFilter(NSUInteger value) {
  switch (value) {
  case GLTFSamplerMinFilterNearest:
  case GLTFSamplerMinFilterLinear:
  case GLTFSamplerMinFilterNearestMipmapNearest:
  case GLTFSamplerMinFilterLinearMipmapNearest:
  case GLTFSamplerMinFilterNearestMipmapLinear:
  case GLTFSamplerMinFilterLinearMipmapLinear:
    return YES;
  default:
    return NO;
  }
}

BOOL isValidGLTFSamplerWrapMode(NSUInteger value) {
  switch (value) {
  case GLTFSamplerWrapModeClampToEdge:
  case GLTFSamplerWrapModeMirroredRepeat:
  case GLTFSamplerWrapModeRepeat:
    return YES;
  default:
    return NO;
  }
}

@implementation GLTFSampler

@end
