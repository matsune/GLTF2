#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GLTFCameraPerspective : NSObject

@property(nonatomic, strong, nullable) NSNumber *aspectRatio;
@property(nonatomic, assign) float yfov;
@property(nonatomic, strong, nullable) NSNumber *zfar;
@property(nonatomic, assign) float znear;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

NS_ASSUME_NONNULL_END
