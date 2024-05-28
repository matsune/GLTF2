#import "SidebarViewController.h"

@interface SidebarViewController ()

@property(nonatomic, nullable) SCNAnimationPlayer *currentAnimationPlayer;
@property(nonatomic, nullable) NSArray<SCNAnimationPlayer *> *animationPlayers;

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

- (void)setupAsset:(GLTFSCNAsset *)asset {
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

@end
