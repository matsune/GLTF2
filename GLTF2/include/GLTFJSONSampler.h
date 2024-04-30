#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, GLTFJSONSamplerMagFilter) {
  GLTFJSONSamplerMagFilterNearest = 9728,
  GLTFJSONSamplerMagFilterLinear = 9729
};

typedef NS_ENUM(NSInteger, GLTFJSONSamplerMinFilter) {
  GLTFJSONSamplerMinFilterNearest = 9728,
  GLTFJSONSamplerMinFilterLinear = 9729,
  GLTFJSONSamplerMinFilterNearestMipmapNearest = 9984,
  GLTFJSONSamplerMinFilterLinearMipmapNearest = 9985,
  GLTFJSONSamplerMinFilterNearestMipmapLinear = 9986,
  GLTFJSONSamplerMinFilterLinearMipmapLinear = 9987
};

typedef NS_ENUM(NSInteger, GLTFJSONSamplerWrapMode) {
  GLTFJSONSamplerWrapModeClampToEdge = 33071,
  GLTFJSONSamplerWrapModeMirroredRepeat = 33648,
  GLTFJSONSamplerWrapModeRepeat = 10497
};

@interface GLTFJSONSampler : NSObject

@property(nonatomic, strong, nullable) NSNumber *magFilter;
@property(nonatomic, strong, nullable) NSNumber *minFilter;
@property(nonatomic, assign) NSInteger wrapS;
@property(nonatomic, assign) NSInteger wrapT;
@property(nonatomic, copy, nullable) NSString *name;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

NS_ASSUME_NONNULL_END
