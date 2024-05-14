#import "SCNViewController.h"
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface SidebarViewController : NSViewController <SCNViewControllerDelegate>

@property(weak) IBOutlet NSPopUpButton *animationsPopUpButton;
@property(weak) IBOutlet NSButton *playButton;

- (IBAction)animationsPopUpButtonAction:(NSPopUpButton *)sender;
- (IBAction)playButtonAction:(NSButton *)sender;

@end

NS_ASSUME_NONNULL_END
