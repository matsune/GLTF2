#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  // Insert code here to initialize your application
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
  [openPanel setAllowedFileTypes:@[ @"gltf", @"glb" ]];

  [openPanel beginWithCompletionHandler:^(NSInteger result) {
    if (result == NSModalResponseOK) {
      NSURL *fileURL = [[openPanel URLs] firstObject];
      NSWindowController *windowController = [[NSStoryboard mainStoryboard]
          instantiateControllerWithIdentifier:@"MainWindowController"];
      ViewController *vc =
          (ViewController *)windowController.contentViewController;
      [vc loadModelURL:fileURL];
      [windowController showWindow:nil];
    }
  }];
}

@end
