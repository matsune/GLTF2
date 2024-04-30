#import "GLTFCameraOrthographic.h"
#import "GLTFCameraPerspective.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GLTFCamera : NSObject

@property(nonatomic, strong, nullable) GLTFCameraOrthographic *orthographic;
@property(nonatomic, strong, nullable) GLTFCameraPerspective *perspective;
@property(nonatomic, copy) NSString *type;
@property(nonatomic, copy, nullable) NSString *name;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

NS_ASSUME_NONNULL_END
