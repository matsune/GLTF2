#import "GLTFDecoder.h"
#import "config.h"
#import <XCTest/XCTest.h>

@interface GLTF2Tests : XCTestCase

@end

@implementation GLTF2Tests

- (void)setUp {
  // Put setup code here. This method is called before the invocation of each
  // test method in the class.
}

- (void)tearDown {
  // Put teardown code here. This method is called after the invocation of each
  // test method in the class.
}

- (void)testExample {
  NSURL *url = [[NSURL fileURLWithPath:@PROJECT_SOURCE_DIR]
      URLByAppendingPathComponent:
          @"gltf-sample-models/2CylinderEngine/glTF/2CylinderEngine.gltf"];
  NSData *data = [NSData dataWithContentsOfURL:url];
  NSError *error;
  GLTFJson *json = [GLTFDecoder decodeJsonData:data error:&error];
  XCTAssertNil(error);
  XCTAssertNotNil(json);
}

@end
