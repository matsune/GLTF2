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

- (void)loadModelURL:(NSURL *)url;

@end
