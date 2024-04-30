#import "GLTFJSONCameraOrthographic.h"
#import "GLTFJSONCameraPerspective.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GLTFJSONCamera : NSObject

@property(nonatomic, strong, nullable) GLTFJSONCameraOrthographic *orthographic;
@property(nonatomic, strong, nullable) GLTFJSONCameraPerspective *perspective;
@property(nonatomic, copy) NSString *type;
@property(nonatomic, copy, nullable) NSString *name;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

NS_ASSUME_NONNULL_END
