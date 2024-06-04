#import "AppDelegate.h"
#import "SCNViewController.h"
#import "SidebarViewController.h"
#import "WindowController.h"
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

@interface AppDelegate ()

@property(strong, nonatomic)
    NSMutableArray<WindowController *> *windowControllers;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  self.windowControllers = [NSMutableArray array];
  [self openDocument:nil];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
  // Insert code here to tear down your application
}

- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
  return YES;
}

- (void)openDocument:(id)sender {
  NSOpenPanel *openPanel = [NSOpenPanel openPanel];
  [openPanel setAllowsMultipleSelection:NO];
  [openPanel setCanChooseDirectories:NO];
  [openPanel setCanChooseFiles:YES];
  [openPanel setAllowedContentTypes:@[
    [UTType typeWithFilenameExtension:@"gltf"],
    [UTType typeWithFilenameExtension:@"glb"],
    [UTType typeWithFilenameExtension:@"vrm"]
  ]];

  [openPanel beginWithCompletionHandler:^(NSInteger result) {
    if (result == NSModalResponseOK) {
      NSURL *fileURL = [[openPanel URLs] firstObject];
      WindowController *windowController =
          (WindowController *)[[NSStoryboard mainStoryboard]
              instantiateControllerWithIdentifier:@"MainWindowController"];
      NSSplitViewController *splitVC =
          (NSSplitViewController *)windowController.contentViewController;
      SidebarViewController *sidebarViewController =
          (SidebarViewController *)splitVC.splitViewItems[0].viewController;
      SCNViewController *scnViewController =
          (SCNViewController *)splitVC.splitViewItems[1].viewController;
      sidebarViewController.delegate = windowController;
      scnViewController.delegate = windowController;
      [scnViewController loadModelURL:fileURL];
      [windowController showWindow:nil];

      [self.windowControllers addObject:windowController];
      [windowController.window setDelegate:self];
    }
  }];
}

- (void)windowWillClose:(NSNotification *)notification {
  NSWindow *closedWindow = notification.object;
  for (WindowController *wc in self.windowControllers) {
    if ([wc.window isEqual:closedWindow]) {
      [self.windowControllers removeObject:wc];
      break;
    }
  }
}

@end
