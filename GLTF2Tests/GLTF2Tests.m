#import "GLTFJson.h"
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
  // This is an example of a functional test case.
  // Use XCTAssert and related functions to verify your tests produce the
  // correct results.
  NSURL *url = [[NSURL fileURLWithPath:@PROJECT_SOURCE_DIR]
      URLByAppendingPathComponent:
          @"gltf-sample-models/2CylinderEngine/glTF/2CylinderEngine.gltf"];
  [GLTFJson loadWithData:[NSData dataWithContentsOfURL:url]];
}

- (void)testPerformanceExample {
  // This is an example of a performance test case.
  [self measureBlock:^{
      // Put the code you want to measure the time of here.
  }];
}

@end
