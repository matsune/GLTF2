#import "GLTF2.h"
#import "config.h"
#import <XCTest/XCTest.h>

@interface GLTFObjectTests : XCTestCase

@end

@implementation GLTFObjectTests

- (void)testGLB {
  NSURL *url = [[NSURL fileURLWithPath:SAMPLE_MODELS_DIR]
      URLByAppendingPathComponent:
          @"2CylinderEngine/glTF-Binary/2CylinderEngine.glb"];
  NSError *error;
  GLTFObject *object = [GLTFObject objectWithGlbFile:[url path] error:&error];
  XCTAssertNil(error);
  XCTAssertNotNil(object);
  XCTAssertNotEqual(object.buffers.count, 0);
  XCTAssertNotNil(object.buffers[0].data);
}

- (void)testGLTF {
  NSURL *url = [[NSURL fileURLWithPath:SAMPLE_MODELS_DIR]
      URLByAppendingPathComponent:@"2CylinderEngine/glTF/2CylinderEngine.gltf"];
  NSError *error;
  GLTFObject *object = [GLTFObject objectWithGltfFile:[url path] error:&error];
  XCTAssertNil(error);
  XCTAssertNotNil(object);
  XCTAssertNotEqual(object.buffers.count, 0);
  XCTAssertNotNil(object.buffers[0].data);
}

- (void)testGLTFEmbedded {
  NSURL *url = [[NSURL fileURLWithPath:SAMPLE_MODELS_DIR]
      URLByAppendingPathComponent:
          @"2CylinderEngine/glTF-Embedded/2CylinderEngine.gltf"];
  NSError *error;
  GLTFObject *object = [GLTFObject objectWithGltfFile:[url path] error:&error];
  XCTAssertNil(error);
  XCTAssertNotNil(object);
  XCTAssertNotEqual(object.buffers.count, 0);
  XCTAssertNotNil(object.buffers[0].data);
}

@end
