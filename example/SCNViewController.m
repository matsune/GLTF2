#import "SCNViewController.h"
#import <Foundation/Foundation.h>

@interface SCNViewController ()

@property(nonatomic, strong) SCNNode *lookAtTargetSphere;

@end

@implementation SCNViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.scnView.autoenablesDefaultLighting = YES;
  self.scnView.allowsCameraControl = YES;
  self.scnView.backgroundColor = [NSColor grayColor];
  self.scnView.showsStatistics = YES;
  //  self.scnView.debugOptions = SCNDebugOptionShowWireframe;

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

  //  [self.scnView.scene.rootNode addChildNode:self.lightNode];

  self.lookAtTargetSphere =
      [SCNNode nodeWithGeometry:[SCNSphere sphereWithRadius:0.03]];
  self.lookAtTargetSphere.position = SCNVector3Make(0, 0, 0);
  self.lookAtTargetSphere.geometry.firstMaterial.diffuse.contents =
      [NSColor blueColor];
  [self.scnView.scene.rootNode addChildNode:self.lookAtTargetSphere];

  if ([self.delegate respondsToSelector:@selector(scnViewController:
                                                       didLoadAsset:)]) {
    [self.delegate scnViewController:self didLoadAsset:self.asset];
  }

  //  NSString *path = [[NSBundle mainBundle] pathForResource:@"Cannon_Exterior"
  //                                                   ofType:@"hdr"];
  //  NSImage *hdr = [[NSImage alloc] initWithContentsOfFile:path];
  //  self.scnView.scene.lightingEnvironment.contents = hdr;
  if (self.asset.json.vrm0 || self.asset.json.vrm1) {
    SCNFloor *floor = [SCNFloor floor];
    SCNNode *floorNode = [SCNNode nodeWithGeometry:floor];
    floorNode.physicsBody = [SCNPhysicsBody
        bodyWithType:SCNPhysicsBodyTypeStatic
               shape:[SCNPhysicsShape shapeWithGeometry:floor options:nil]];
    [self.scnView.scene.rootNode addChildNode:floorNode];
  }

  [self lookAt:SCNVector3Make(0, 1.5, 1.0)];

  // test collision
  SCNBox *box = [SCNBox boxWithWidth:0.1 height:0.1 length:0.1 chamferRadius:0];
  SCNNode *b = [SCNNode nodeWithGeometry:box];
  b.position = SCNVector3Make(0, 12.0, 0);
  b.physicsBody = [SCNPhysicsBody
      bodyWithType:SCNPhysicsBodyTypeDynamic
             shape:[SCNPhysicsShape shapeWithGeometry:box options:nil]];
  [self.scnView.scene.rootNode addChildNode:b];
}

- (void)sidebarViewController:(SidebarViewController *)sidebarViewController
       didSelectCameraAtIndex:(NSInteger)index {
  SCNNode *cameraNode = self.asset.cameraNodes[index];
  self.scnView.pointOfView = cameraNode;
}

- (void)sidebarViewController:(SidebarViewController *)sidebarViewController
              didChangeLightX:(float)x {
  SCNVector3 pos = self.lightNode.position;
  pos.x = x;
  self.lightNode.position = pos;
}

- (void)sidebarViewController:(SidebarViewController *)sidebarViewController
              didChangeWeight:(float)weight
             forBlendShapeKey:(NSString *)key {
  [self.asset setBlendShapeWeight:weight forKey:key];
}

- (void)sidebarViewController:(SidebarViewController *)sidebarViewController
             didChangeLookAtX:(float)value {
  SCNVector3 position = self.lookAtTargetSphere.position;
  position.x = value;
  [self lookAt:position];
}

- (void)sidebarViewController:(SidebarViewController *)sidebarViewController
             didChangeLookAtY:(float)value {
  SCNVector3 position = self.lookAtTargetSphere.position;
  position.y = value;
  [self lookAt:position];
}

- (void)sidebarViewController:(SidebarViewController *)sidebarViewController
             didChangeLookAtZ:(float)value {
  SCNVector3 position = self.lookAtTargetSphere.position;
  position.z = value;
  [self lookAt:position];
}

- (void)lookAt:(SCNVector3)value {
  self.lookAtTargetSphere.position = value;
  [self.asset lookAtTarget:value];
}

@end
