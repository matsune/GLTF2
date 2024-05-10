#import "ViewController.h"
#import "GLTF2.h"
#import "GLTF2SceneKit.h"
#import "GLTFJson.h"
#import "config.h"
#import <Foundation/Foundation.h>
#import <Metal/Metal.h>

@interface ViewController ()

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
  GLTFData *object = [GLTFData dataWithFile:[url path] error:&err];
  if (err) {
    NSLog(@"%@", err);
    abort();
  }
  self.scnView.scene = object.defaultScene;
}

@end
