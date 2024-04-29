#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, GLTFSamplerMagFilter) {
  GLTFSamplerMagFilterNearest = 9728,
  GLTFSamplerMagFilterLinear = 9729
};

BOOL isValidGLTFSamplerMagFilter(NSUInteger value);

typedef NS_ENUM(NSUInteger, GLTFSamplerMinFilter) {
  GLTFSamplerMinFilterNearest = 9728,
  GLTFSamplerMinFilterLinear = 9729,
  GLTFSamplerMinFilterNearestMipmapNearest = 9984,
  GLTFSamplerMinFilterLinearMipmapNearest = 9985,
  GLTFSamplerMinFilterNearestMipmapLinear = 9986,
  GLTFSamplerMinFilterLinearMipmapLinear = 9987
};

BOOL isValidGLTFSamplerMinFilter(NSUInteger value);

typedef NS_ENUM(NSUInteger, GLTFSamplerWrapMode) {
  GLTFSamplerWrapModeClampToEdge = 33071,
  GLTFSamplerWrapModeMirroredRepeat = 33648,
  GLTFSamplerWrapModeRepeat = 10497
};

BOOL isValidGLTFSamplerWrapMode(NSUInteger value);

@interface GLTFSampler : NSObject

@property(nonatomic, assign) GLTFSamplerMagFilter magFilter;
@property(nonatomic, assign) GLTFSamplerMinFilter minFilter;
@property(nonatomic, assign) GLTFSamplerWrapMode wrapS;
@property(nonatomic, assign) GLTFSamplerWrapMode wrapT;
@property(nonatomic, copy, nullable) NSString *name;
@property(nonatomic, copy, nullable) NSDictionary *extensions;
@property(nonatomic, copy, nullable) NSDictionary *extras;

@end

NS_ASSUME_NONNULL_END
