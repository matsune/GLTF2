#import "GLTF2Availability.h"
#import <Cocoa/Cocoa.h>
#import <SceneKit/SceneKit.h>

NS_ASSUME_NONNULL_BEGIN

GLTF_EXPORT @interface GLTFSCNAsset : NSObject

@property(nonatomic, strong) NSArray<SCNScene *> *scenes;
@property(nonatomic, strong, readonly) NSArray<SCNNode *> *cameraNodes;
@property(nonatomic, strong) NSArray<SCNAnimationPlayer *> *animationPlayers;
@property(nonatomic, strong) SCNNode *lightNode;

- (BOOL)loadFile:(const NSString *)path
           error:(NSError *_Nullable *_Nullable)error;

- (nullable SCNScene *)defaultScene;

@end

NS_ASSUME_NONNULL_END
