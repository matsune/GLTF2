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
  if (self.asset.animationPlayers.count > 0) {
    SCNAnimationPlayer *animationPlayer = self.asset.animationPlayers[0];
    [self.scnView.scene.rootNode addAnimationPlayer:animationPlayer
                                             forKey:@"Playback"];
    [animationPlayer play];
  }
}

@end
