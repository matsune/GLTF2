#import "AppDelegate.h"
#import "SCNViewController.h"
#import "SidebarViewController.h"
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
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
    [UTType typeWithFilenameExtension:@"glb"]
  ]];

  [openPanel beginWithCompletionHandler:^(NSInteger result) {
    if (result == NSModalResponseOK) {
      NSURL *fileURL = [[openPanel URLs] firstObject];
      NSWindowController *windowController = [[NSStoryboard mainStoryboard]
          instantiateControllerWithIdentifier:@"MainWindowController"];
      NSSplitViewController *splitVC =
          (NSSplitViewController *)windowController.contentViewController;
      SidebarViewController *sidebarViewController =
          (SidebarViewController *)splitVC.splitViewItems[0].viewController;
      SCNViewController *scnViewController =
          (SCNViewController *)splitVC.splitViewItems[1].viewController;
      scnViewController.delegate = sidebarViewController;
      [scnViewController loadModelURL:fileURL];
      [windowController showWindow:nil];
    }
  }];
}

@end
