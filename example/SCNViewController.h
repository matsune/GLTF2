#import "GLTF2SceneKit.h"
#import <Cocoa/Cocoa.h>
#import <SceneKit/SceneKit.h>

@class SCNViewController;

@protocol SCNViewControllerDelegate <NSObject>

- (void)scnViewController:(SCNViewController *)scnViewController
             didLoadAsset:(GLTFSCNAsset *)asset;

@end

@interface SCNViewController : NSViewController

@property(weak) IBOutlet SCNView *scnView;
@property(nonatomic) GLTFSCNAsset *asset;
@property(nonatomic, weak) id<SCNViewControllerDelegate> delegate;

@property(nonatomic) SCNLight *light;
@property(nonatomic) SCNNode *lightNode;

- (void)loadModelURL:(NSURL *)url;

@end
