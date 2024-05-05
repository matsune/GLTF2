#import "GLTFObject.h"
#import <Foundation/Foundation.h>
#import <SceneKit/SceneKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GLTFObject (SceneKitExtension)

- (nullable SCNScene *)defaultScene;

@end

NS_ASSUME_NONNULL_END
