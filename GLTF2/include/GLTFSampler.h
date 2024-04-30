#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, GLTFSamplerMagFilter) {
  GLTFSamplerMagFilterNearest = 9728,
  GLTFSamplerMagFilterLinear = 9729
};
//
//BOOL isValidGLTFSamplerMagFilter(NSInteger value);
//
typedef NS_ENUM(NSInteger, GLTFSamplerMinFilter) {
  GLTFSamplerMinFilterNearest = 9728,
  GLTFSamplerMinFilterLinear = 9729,
  GLTFSamplerMinFilterNearestMipmapNearest = 9984,
  GLTFSamplerMinFilterLinearMipmapNearest = 9985,
  GLTFSamplerMinFilterNearestMipmapLinear = 9986,
  GLTFSamplerMinFilterLinearMipmapLinear = 9987
};
//
//BOOL isValidGLTFSamplerMinFilter(NSInteger value);
//
typedef NS_ENUM(NSInteger, GLTFSamplerWrapMode) {
  GLTFSamplerWrapModeClampToEdge = 33071,
  GLTFSamplerWrapModeMirroredRepeat = 33648,
  GLTFSamplerWrapModeRepeat = 10497
};
//
//BOOL isValidGLTFSamplerWrapMode(NSInteger value);

@interface GLTFSampler : NSObject

@property(nonatomic, strong, nullable) NSNumber *magFilter;
@property(nonatomic, strong, nullable) NSNumber *minFilter;
@property(nonatomic, assign) NSInteger wrapS;
@property(nonatomic, assign) NSInteger wrapT;
@property(nonatomic, copy, nullable) NSString *name;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

NS_ASSUME_NONNULL_END
