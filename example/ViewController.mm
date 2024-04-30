#import "ViewController.h"
#import "GLTF2.h"
#import <Foundation/Foundation.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  NSString *path = [[NSBundle mainBundle] pathForResource:@"2CylinderEngine"
                                                   ofType:@"glb"];
  //  NSData *data = [NSData dataWithContentsOfURL:[NSURL
  //  fileURLWithPath:path]]; GLTFBinary *binary = [GLTFBinary
  //  binaryWithData:data error:nil];
  NSError *err;
  GLTFObject *object = [GLTFObject objectWithGlbFile:path error:&err];
  if (err) {
    NSLog(@"%@", err);
    abort();
  }
  NSLog(@">>>%@", object);
}

- (void)setRepresentedObject:(id)representedObject {
  [super setRepresentedObject:representedObject];

  // Update the view, if already loaded.
}

@end
