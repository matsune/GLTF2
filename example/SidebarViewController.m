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

- (void)scnViewController:(SCNViewController *)scnViewController
             didLoadAsset:(GLTFSCNAsset *)asset {
  self.animationPlayers = asset.animationPlayers;

  BOOL hasAnimations = self.animationPlayers.count > 0;
  self.animationsPopUpButton.enabled = hasAnimations;
  self.playButton.enabled = hasAnimations;

  for (int i = 0; i < self.animationPlayers.count; i++) {
    SCNAnimationPlayer *animationPlayer = self.animationPlayers[i];
    [self.animationsPopUpButton
        addItemWithTitle:asset.data.json.animations[i].name
                             ?: [NSString stringWithFormat:@"Animation %d", i]];
  }

  self.currentAnimationPlayer = self.animationPlayers.firstObject;
}

@end
