#import <Cocoa/Cocoa.h>
#import <SceneKit/SceneKit.h>

@interface ViewController : NSViewController

@property(weak) IBOutlet SCNView *scnView;

- (void)loadModelURL:(NSURL *)url;

@end
