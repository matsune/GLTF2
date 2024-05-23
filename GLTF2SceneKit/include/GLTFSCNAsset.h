#import <Cocoa/Cocoa.h>
#import <SceneKit/SceneKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GLTFSCNAsset : NSObject

@property(nonatomic, strong) NSArray<SCNScene *> *scenes;
@property(nonatomic, strong, readonly) NSArray<SCNNode *> *cameraNodes;
@property(nonatomic, strong) NSArray<SCNAnimationPlayer *> *animationPlayers;

+ (instancetype)assetWithFile:(NSString *)path
                        error:(NSError *_Nullable *_Nullable)error;

- (BOOL)loadFile:(const NSString *)path
           error:(NSError *_Nullable *_Nullable)error;

//- (instancetype)initWithGLTFData:(GLTFData *)data;
//
//+ (instancetype)assetWithGLTFData:(GLTFData *)data;
//
//- (void)loadScenes;
- (nullable SCNScene *)defaultScene;

@end

NS_ASSUME_NONNULL_END
