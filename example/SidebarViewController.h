#import "GLTFSCNAsset.h"
#import "SCNViewControllerDelegate.h"
#import "SidebarViewControllerDelegate.h"
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface SidebarViewController : NSViewController <SCNViewControllerDelegate>

@property(weak) IBOutlet NSPopUpButton *animationsPopUpButton;
@property(weak) IBOutlet NSButton *playButton;
@property(weak) IBOutlet NSPopUpButton *camerasPopUpButton;
@property(nonatomic, weak) id<SidebarViewControllerDelegate> delegate;
@property(weak) IBOutlet NSTextField *lightXTextField;
@property(weak) IBOutlet NSPopUpButton *blendShapePopUpButton;
@property(weak) IBOutlet NSSlider *blendShapeValueSlider;

- (IBAction)animationsPopUpButtonAction:(NSPopUpButton *)sender;
- (IBAction)playButtonAction:(NSButton *)sender;
- (IBAction)camerasPopUpButtonAction:(NSPopUpButton *)sender;
- (IBAction)lightXAction:(NSTextField *)sender;
- (IBAction)onChangeBlendShapeKey:(NSPopUpButton *)sender;
- (IBAction)onChangeBlendShapeValue:(NSSlider *)sender;

@end

NS_ASSUME_NONNULL_END
