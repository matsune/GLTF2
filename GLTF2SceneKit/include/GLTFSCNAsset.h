#import "GLTF2.h"
#import <Cocoa/Cocoa.h>
#import <SceneKit/SceneKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GLTFSCNAsset : NSObject

@property(nonatomic, strong, readonly) GLTFData *data;
@property(nonatomic, strong) NSArray<SCNScene *> *scenes;

- (instancetype)initWithGLTFData:(GLTFData *)data;

+ (instancetype)assetWithGLTFData:(GLTFData *)data;

- (void)loadScenes;
- (nullable SCNScene *)defaultScene;

@end

NS_ASSUME_NONNULL_END
