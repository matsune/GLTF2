#import "GLTFSCNAsset.h"
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@class SidebarViewController;

@protocol SidebarViewControllerDelegate <NSObject>

- (void)sidebarViewController:(SidebarViewController *)sidebarViewController
       didSelectCameraAtIndex:(NSInteger)index;

@end

@interface SidebarViewController : NSViewController

@property(weak) IBOutlet NSPopUpButton *animationsPopUpButton;
@property(weak) IBOutlet NSButton *playButton;
@property(weak) IBOutlet NSPopUpButton *camerasPopUpButton;
@property(nonatomic, weak) id<SidebarViewControllerDelegate> delegate;

- (IBAction)animationsPopUpButtonAction:(NSPopUpButton *)sender;
- (IBAction)playButtonAction:(NSButton *)sender;
- (IBAction)camerasPopUpButtonAction:(NSPopUpButton *)sender;

- (void)setupAsset:(GLTFSCNAsset *)asset;
@end

NS_ASSUME_NONNULL_END
