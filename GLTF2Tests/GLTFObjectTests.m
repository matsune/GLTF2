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
}

- (void)testGLTF {
  NSURL *url = [[NSURL fileURLWithPath:SAMPLE_MODELS_DIR]
      URLByAppendingPathComponent:@"2CylinderEngine/glTF/2CylinderEngine.gltf"];
  NSError *error;
  GLTFObject *object = [GLTFObject objectWithGltfFile:[url path] error:&error];
  XCTAssertNil(error);
  XCTAssertNotNil(object);
}

- (void)testGLTFEmbedded {
  NSURL *url = [[NSURL fileURLWithPath:SAMPLE_MODELS_DIR]
      URLByAppendingPathComponent:
          @"2CylinderEngine/glTF-Embedded/2CylinderEngine.gltf"];
  NSError *error;
  GLTFObject *object = [GLTFObject objectWithGltfFile:[url path] error:&error];
  XCTAssertNil(error);
  XCTAssertNotNil(object);
}

- (void)testGLTFBoxTextured {
  NSURL *url = [[NSURL fileURLWithPath:SAMPLE_MODELS_DIR]
      URLByAppendingPathComponent:@"BoxTextured/glTF/BoxTextured.gltf"];
  NSError *error;
  GLTFObject *object = [GLTFObject objectWithGltfFile:[url path] error:&error];
  XCTAssertNil(error);
  XCTAssertNotNil(object);
}

- (void)testGLTFBoxTexturedEmbedded {
  NSURL *url = [[NSURL fileURLWithPath:SAMPLE_MODELS_DIR]
      URLByAppendingPathComponent:
          @"BoxTextured/glTF-Embedded/BoxTextured.gltf"];
  NSError *error;
  GLTFObject *object = [GLTFObject objectWithGltfFile:[url path] error:&error];
  XCTAssertNil(error);
  XCTAssertNotNil(object);
}

@end
