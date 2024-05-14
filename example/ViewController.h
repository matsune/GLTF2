#import <Cocoa/Cocoa.h>
#import <SceneKit/SceneKit.h>

@interface ViewController : NSViewController

@property(weak) IBOutlet SCNView *scnView;
@property(weak) IBOutlet NSPopUpButton *animationsPopUpButton;

- (void)loadModelURL:(NSURL *)url;

- (IBAction)animationsPopUpButtonAction:(id)sender;

@end
