#import "SCNViewController.h"
#import <Foundation/Foundation.h>

@interface SCNViewController ()

@end

@implementation SCNViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  //  self.scnView.autoenablesDefaultLighting = YES;
  self.scnView.allowsCameraControl = YES;
  self.scnView.backgroundColor = [NSColor blackColor];
  self.scnView.showsStatistics = YES;
}

- (void)loadModelURL:(NSURL *)url {
  NSError *error;
  self.asset = [[GLTFSCNAsset alloc] init];
  [self.asset loadFile:[url path] error:&error];
  if (error) {
    [[NSAlert alertWithError:error] runModal];
    return;
  }

  self.scnView.scene = self.asset.defaultScene;
  for (SCNAnimationPlayer *player in self.asset.animationPlayers) {
    [self.scnView.scene.rootNode addAnimationPlayer:player forKey:nil];
  }

  SCNLight *light = [SCNLight light];
  light.type = SCNLightTypeOmni;
  light.color = [NSColor whiteColor];
  SCNNode *lightNode = [SCNNode node];
  lightNode.light = light;
  lightNode.position = SCNVector3Make(0, 10, 10);
  [self.scnView.scene.rootNode addChildNode:lightNode];

  if ([self.delegate respondsToSelector:@selector(scnViewController:
                                                       didLoadAsset:)]) {
    [self.delegate scnViewController:self didLoadAsset:self.asset];
  }
}

@end
