#import <XCTest/XCTest.h>
#import "config.h"
#import "GLTF2.h"

@interface GLTFObjectTests : XCTestCase

@end

@implementation GLTFObjectTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    NSURL *url = [[NSURL fileURLWithPath:@PROJECT_SOURCE_DIR]
        URLByAppendingPathComponent:
            @"gltf-sample-models/2CylinderEngine/glb/2CylinderEngine.glb"];
    NSError *error;
    GLTFObject *object = [GLTFObject objectWithGlbFile:[url path] error:&error];
    XCTAssertNil(error);
    XCTAssertNotNil(object);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
