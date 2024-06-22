#import "SidebarViewController.h"

@interface SidebarViewController ()

@property(nonatomic, nullable) GLTFSCNAsset *asset;
@property(nonatomic, nullable) SCNAnimationPlayer *currentAnimationPlayer;
@property(nonatomic, nullable) NSArray<SCNAnimationPlayer *> *animationPlayers;
@property(nonatomic, nullable) NSString *blendShapeKey;

@end

@implementation SidebarViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.animationsPopUpButton.enabled = NO;
  self.playButton.enabled = NO;
  self.camerasPopUpButton.enabled = NO;
  self.lightXTextField.floatValue = 0.0f;
}

- (IBAction)animationsPopUpButtonAction:(NSPopUpButton *)sender {
  if (self.currentAnimationPlayer)
    [self.currentAnimationPlayer stop];
  self.currentAnimationPlayer =
      self.animationPlayers[sender.indexOfSelectedItem];
}

- (IBAction)playButtonAction:(NSButton *)sender {
  if (self.currentAnimationPlayer) {
    if (self.currentAnimationPlayer.paused) {
      [self.currentAnimationPlayer play];
    } else {
      [self.currentAnimationPlayer stop];
    }
  }
}

- (void)setAsset:(GLTFSCNAsset *)asset {
  _asset = asset;
  self.animationPlayers = asset.animationPlayers;

  BOOL hasAnimations = self.animationPlayers.count > 0;
  self.animationsPopUpButton.enabled = hasAnimations;
  self.playButton.enabled = hasAnimations;

  for (int i = 0; i < self.animationPlayers.count; i++) {
    SCNAnimationPlayer *animationPlayer = self.animationPlayers[i];
    [self.animationsPopUpButton
        addItemWithTitle:[NSString stringWithFormat:@"Animation %d", i]];
  }

  self.currentAnimationPlayer = self.animationPlayers.firstObject;

  for (int i = 0; i < asset.cameraNodes.count; i++) {
    [self.camerasPopUpButton
        addItemWithTitle:[NSString stringWithFormat:@"Camera %d", i]];
  }
  self.camerasPopUpButton.enabled = asset.cameraNodes.count > 0;

  NSArray<NSString *> *keys = asset.blendShapeKeys;
  self.blendShapePopUpButton.enabled = keys.count > 0;
  [self.blendShapePopUpButton addItemsWithTitles:keys];
  self.blendShapeKey = keys.firstObject;

  self.lookAtXTextField.floatValue = 0.0f;
  self.lookAtYTextField.floatValue = 1.5f;
  self.lookAtZTextField.floatValue = 1.0f;

  self.vrmPositionXTextField.floatValue = 0.0f;
  self.vrmPositionYTextField.floatValue = 0.0f;
  self.vrmPositionZTextField.floatValue = 0.0f;
}

- (IBAction)onChangeBlendShapeValue:(NSSlider *)sender {
  if ([self.delegate respondsToSelector:@selector
                     (sidebarViewController:
                            didChangeWeight:forBlendShapeKey:)]) {
    [self.delegate sidebarViewController:self
                         didChangeWeight:sender.floatValue
                        forBlendShapeKey:self.blendShapeKey];
  }
}

- (IBAction)onChangeBlendShapeKey:(NSPopUpButton *)sender {
  self.blendShapeKey = sender.title;
}

- (void)setBlendShapeKey:(NSString *)blendShapeKey {
  _blendShapeKey = blendShapeKey;
  if (blendShapeKey) {
    CGFloat weight = [self.asset weightForBlendShapeKey:blendShapeKey];
    self.blendShapeValueSlider.floatValue = weight;
  }
}

- (IBAction)lightXAction:(NSTextField *)sender {
  if ([self.delegate respondsToSelector:@selector(sidebarViewController:
                                                        didChangeLightX:)]) {
    [self.delegate sidebarViewController:self
                         didChangeLightX:sender.floatValue];
  }
}

- (IBAction)camerasPopUpButtonAction:(NSPopUpButton *)sender {
  if ([self.delegate respondsToSelector:@selector(sidebarViewController:
                                                 didSelectCameraAtIndex:)]) {
    [self.delegate sidebarViewController:self
                  didSelectCameraAtIndex:sender.indexOfSelectedItem];
  }
}

- (IBAction)lookAtXAction:(NSTextField *)sender {
  if ([self.delegate respondsToSelector:@selector(sidebarViewController:
                                                       didChangeLookAtX:)]) {
    [self.delegate sidebarViewController:self
                        didChangeLookAtX:sender.floatValue];
  }
}

- (IBAction)lookAtYAction:(NSTextField *)sender {
  if ([self.delegate respondsToSelector:@selector(sidebarViewController:
                                                       didChangeLookAtY:)]) {
    [self.delegate sidebarViewController:self
                        didChangeLookAtY:sender.floatValue];
  }
}

- (IBAction)lookAtZAction:(NSTextField *)sender {
  if ([self.delegate respondsToSelector:@selector(sidebarViewController:
                                                       didChangeLookAtZ:)]) {
    [self.delegate sidebarViewController:self
                        didChangeLookAtZ:sender.floatValue];
  }
}

- (IBAction)vrmPositionXAction:(NSTextField *)sender {
  if ([self.delegate respondsToSelector:@selector(sidebarViewController:
                                                  didChangeVrmPositionX:)]) {
    [self.delegate sidebarViewController:self
                   didChangeVrmPositionX:sender.floatValue];
  }
}

- (IBAction)vrmPositionYAction:(NSTextField *)sender {
  if ([self.delegate respondsToSelector:@selector(sidebarViewController:
                                                  didChangeVrmPositionY:)]) {
    [self.delegate sidebarViewController:self
                   didChangeVrmPositionY:sender.floatValue];
  }
}

- (IBAction)vrmPositionZAction:(NSTextField *)sender {
  if ([self.delegate respondsToSelector:@selector(sidebarViewController:
                                                  didChangeVrmPositionZ:)]) {
    [self.delegate sidebarViewController:self
                   didChangeVrmPositionZ:sender.floatValue];
  }
}

- (void)scnViewController:(SCNViewController *)scnViewController
             didLoadAsset:(GLTFSCNAsset *)asset {
  self.asset = asset;
}

@end
