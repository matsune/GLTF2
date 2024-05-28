#import "WindowController.h"

@interface WindowController ()

@property(nonatomic, readonly) SidebarViewController *sidebarViewController;
@property(nonatomic, readonly) SCNViewController *scnViewController;

@end

@implementation WindowController

- (SidebarViewController *)sidebarViewController {
  return (SidebarViewController *)((NSSplitViewController *)
                                       self.contentViewController)
      .splitViewItems[0]
      .viewController;
}

- (SCNViewController *)scnViewController {
  return (SCNViewController *)((NSSplitViewController *)
                                   self.contentViewController)
      .splitViewItems[1]
      .viewController;
}

- (void)windowDidLoad {
  [super windowDidLoad];
}

- (void)scnViewController:(SCNViewController *)scnViewController
             didLoadAsset:(GLTFSCNAsset *)asset {
  [self.sidebarViewController setupAsset:asset];
}

- (void)sidebarViewController:(SidebarViewController *)sidebarViewController
       didSelectCameraAtIndex:(NSInteger)index {
  SCNNode *cameraNode = self.scnViewController.asset.cameraNodes[index];
  self.scnViewController.scnView.pointOfView = cameraNode;
}

- (void)sidebarViewController:(SidebarViewController *)sidebarViewController
              didChangeLightX:(float)x {
  SCNVector3 pos = self.scnViewController.lightNode.position;
  pos.x = x;
  self.scnViewController.lightNode.position = pos;
}

@end
