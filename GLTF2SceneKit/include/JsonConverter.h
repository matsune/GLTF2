#include "GLTF2.h"
#import "GLTFJson.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JsonConverter : NSObject

+ (GLTFJson *)convertGLTFJson:(const gltf2::json::Json &)cppJson;

@end

NS_ASSUME_NONNULL_END
