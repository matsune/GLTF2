#import "GLTF2.h"
#import "config.h"
#import <XCTest/XCTest.h>

@interface GLTFObjectTests : XCTestCase

@end

@implementation GLTFObjectTests

- (void)setUp {
  // Put setup code here. This method is called before the invocation of each
  // test method in the class.
}

- (void)tearDown {
  // Put teardown code here. This method is called after the invocation of each
  // test method in the class.
}

- (void)testExample {
  NSURL *url = [[NSURL fileURLWithPath:SAMPLE_MODELS_DIR]
      URLByAppendingPathComponent:
          @"2CylinderEngine/glTF-Binary/2CylinderEngine.glb"];
  NSError *error;
  GLTFObject *object = [GLTFObject objectWithGlbFile:[url path] error:&error];
  XCTAssertNil(error);
  XCTAssertNotNil(object);
}

@end
