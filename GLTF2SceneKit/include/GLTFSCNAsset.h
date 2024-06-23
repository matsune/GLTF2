#import "GLTF2Availability.h"
#import "GLTFJson.h"
#import <Cocoa/Cocoa.h>
#import <SceneKit/SceneKit.h>

NS_ASSUME_NONNULL_BEGIN

GLTF_EXPORT @interface GLTFSCNAsset : NSObject

@property(nonatomic, strong) NSArray<SCNScene *> *scenes;
@property(nonatomic, strong) NSArray<SCNAnimationPlayer *> *animationPlayers;
@property(nonatomic, strong, nullable, readonly) GLTFJson *json;
@property(nonatomic, strong, readonly) NSArray<SCNNode *> *scnNodes;
@property(nonatomic, strong, readonly) NSArray<SCNNode *> *meshNodes;

- (BOOL)loadFile:(const NSString *)path
           error:(NSError *_Nullable *_Nullable)error;

- (SCNScene *)defaultScene;
- (NSArray<SCNNode *> *)cameraNodes;

@end

NS_ASSUME_NONNULL_END
