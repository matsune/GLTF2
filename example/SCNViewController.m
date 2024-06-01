#import "SCNViewController.h"
#import <Foundation/Foundation.h>

@interface SCNViewController ()

@end

@implementation SCNViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  //  self.scnView.autoenablesDefaultLighting = YES;
  self.scnView.allowsCameraControl = YES;
  self.scnView.backgroundColor = [NSColor grayColor];
  self.scnView.showsStatistics = YES;

  self.light = [SCNLight light];
  self.light.type = SCNLightTypeOmni;
  self.light.color = [NSColor whiteColor];
  self.lightNode = [SCNNode node];
  self.lightNode.light = self.light;
  self.lightNode.position = SCNVector3Make(0, 10, 10);
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
  [self.asset setLightNode:self.lightNode];

  [self.scnView.scene.rootNode addChildNode:self.lightNode];

  if ([self.delegate respondsToSelector:@selector(scnViewController:
                                                       didLoadAsset:)]) {
    [self.delegate scnViewController:self didLoadAsset:self.asset];
  }

  NSString *path = [[NSBundle mainBundle] pathForResource:@"Cannon_Exterior"
                                                   ofType:@"hdr"];
  NSImage *hdr = [[NSImage alloc] initWithContentsOfFile:path];
  self.scnView.scene.lightingEnvironment.contents = hdr;
}

@end
