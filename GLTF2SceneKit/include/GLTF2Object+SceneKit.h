#import "GLTFData.h"
#import <Foundation/Foundation.h>
#import <SceneKit/SceneKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GLTFData (SceneKitExtension)

- (nullable SCNScene *)defaultScene;
- (NSArray<SCNScene *> *)scnScenes;
- (SCNScene *)scnSceneFromGLTFScene:(GLTFScene *)scene;
- (SCNNode *)scnNodeFromGLTFNode:(GLTFNode *)node;

@end

NS_ASSUME_NONNULL_END
