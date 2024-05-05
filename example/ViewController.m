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

  NSURL *url = [[NSURL fileURLWithPath:SAMPLE_MODELS_DIR]
      URLByAppendingPathComponent:@"AntiqueCamera/glTF/AntiqueCamera.gltf"];
  NSError *err;
  GLTFObject *object = [GLTFObject objectWithFile:[url path] error:&err];
  if (err) {
    NSLog(@"%@", err);
    abort();
  }

  self.scnView.autoenablesDefaultLighting = YES;
  self.scnView.allowsCameraControl = YES;
  self.scnView.scene = object.defaultScene;
}

@end
