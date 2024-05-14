#import "ViewController.h"
#import "GLTF2.h"
#import "GLTF2SceneKit.h"
#import "GLTFJson.h"
#import "config.h"
#import <Foundation/Foundation.h>
#import <Metal/Metal.h>

@interface ViewController ()

@property(nonatomic) GLTFSCNAsset *asset;

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.scnView.autoenablesDefaultLighting = YES;
  self.scnView.allowsCameraControl = YES;
  self.scnView.backgroundColor = [NSColor windowBackgroundColor];
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

  for (int i = 0; i < self.asset.animationPlayers.count; i++) {
    SCNAnimationPlayer *animationPlayer = self.asset.animationPlayers[i];
    [self.scnView.scene.rootNode
        addAnimationPlayer:animationPlayer
                    forKey:[NSString stringWithFormat:@"animation %d", i]];
    [self.animationsPopUpButton
        addItemWithTitle:self.asset.data.json.animations[i].name];
  }
  self.animationsPopUpButton.enabled = self.asset.animationPlayers.count > 0;
}

- (IBAction)animationsPopUpButtonAction:(NSPopUpButton *)sender {
  for (SCNAnimationPlayer *player in self.asset.animationPlayers) {
    [player stop];
  }
  SCNAnimationPlayer *player =
      self.asset.animationPlayers[sender.indexOfSelectedItem];
  [player play];
}

@end
