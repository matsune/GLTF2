#import <Cocoa/Cocoa.h>
#import "SidebarViewController.h"
#import "SCNViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface WindowController : NSWindowController <SidebarViewControllerDelegate, SCNViewControllerDelegate>

@end

NS_ASSUME_NONNULL_END
