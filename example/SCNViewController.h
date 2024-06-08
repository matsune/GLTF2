#import "GLTF2SceneKit.h"
#import "SCNViewControllerDelegate.h"
#import "SidebarViewControllerDelegate.h"
#import <Cocoa/Cocoa.h>
#import <SceneKit/SceneKit.h>

@interface SCNViewController : NSViewController <SidebarViewControllerDelegate>

@property(weak) IBOutlet SCNView *scnView;
@property(nonatomic) GLTFSCNAsset *asset;
@property(nonatomic, weak) id<SCNViewControllerDelegate> delegate;

@property(nonatomic) SCNLight *light;
@property(nonatomic) SCNNode *lightNode;

- (void)loadModelURL:(NSURL *)url;

@end
