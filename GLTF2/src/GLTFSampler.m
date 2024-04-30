#import "GLTFSampler.h"

//BOOL isValidGLTFSamplerMagFilter(NSInteger value) {
//  return value == GLTFSamplerMagFilterNearest ||
//         value == GLTFSamplerMagFilterLinear;
//}
//
//BOOL isValidGLTFSamplerMinFilter(NSInteger value) {
//  switch (value) {
//  case GLTFSamplerMinFilterNearest:
//  case GLTFSamplerMinFilterLinear:
//  case GLTFSamplerMinFilterNearestMipmapNearest:
//  case GLTFSamplerMinFilterLinearMipmapNearest:
//  case GLTFSamplerMinFilterNearestMipmapLinear:
//  case GLTFSamplerMinFilterLinearMipmapLinear:
//    return YES;
//  default:
//    return NO;
//  }
//}
//
//BOOL isValidGLTFSamplerWrapMode(NSInteger value) {
//  switch (value) {
//  case GLTFSamplerWrapModeClampToEdge:
//  case GLTFSamplerWrapModeMirroredRepeat:
//  case GLTFSamplerWrapModeRepeat:
//    return YES;
//  default:
//    return NO;
//  }
//}

@implementation GLTFSampler

- (instancetype)init
{
    self = [super init];
    if (self) {
        _wrapS = GLTFSamplerWrapModeRepeat;
        _wrapT = GLTFSamplerWrapModeRepeat;
    }
    return self;
}

@end
