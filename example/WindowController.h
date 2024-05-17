#import "SCNViewController.h"
#import "SidebarViewController.h"
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface WindowController : NSWindowController <SidebarViewControllerDelegate,
                                                  SCNViewControllerDelegate>

@end

NS_ASSUME_NONNULL_END
