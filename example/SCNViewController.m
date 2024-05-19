#import "SCNViewController.h"
#import <Foundation/Foundation.h>

@interface SCNViewController ()

@end

@implementation SCNViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.scnView.autoenablesDefaultLighting = YES;
  self.scnView.allowsCameraControl = YES;
  self.scnView.backgroundColor = [NSColor blackColor];
}

- (void)loadModelURL:(NSURL *)url {
  NSError *err;
  GLTFData *data = [GLTFData dataWithFile:[url path] error:&err];
  if (err) {
    NSLog(@"%@", err);
    abort();
  }
  self.asset = [GLTFSCNAsset assetWithGLTFData:data];
  [self.asset loadScenes];
  self.scnView.scene = self.asset.defaultScene;
  for (SCNAnimationPlayer *player in self.asset.animationPlayers) {
    [self.scnView.scene.rootNode addAnimationPlayer:player forKey:nil];
  }

  if ([self.delegate respondsToSelector:@selector(scnViewController:
                                                       didLoadAsset:)]) {
    [self.delegate scnViewController:self didLoadAsset:self.asset];
  }
}

@end
