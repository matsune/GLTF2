#import "GLTFData.h"
#import <Foundation/Foundation.h>
#import <SceneKit/SceneKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GLTFData (SceneKitExtension)

- (nullable SCNScene *)defaultScene;
- (NSArray<SCNScene *> *)scnScenes;

@end

NS_ASSUME_NONNULL_END
