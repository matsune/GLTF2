#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GLTFCameraOrthographic : NSObject

@property(nonatomic, assign) float xmag;
@property(nonatomic, assign) float ymag;
@property(nonatomic, assign) float zfar;
@property(nonatomic, assign) float znear;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

NS_ASSUME_NONNULL_END
