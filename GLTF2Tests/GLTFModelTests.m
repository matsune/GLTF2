#import "GLTF2.h"
#import "config.h"
#import <XCTest/XCTest.h>

@interface GLTFModelTests : XCTestCase

@end

@implementation GLTFModelTests

- (void)testDataByAccessorWithNormalized {
  // R: 255, G: 128, B: 0, A: 255
  unsigned char colorBytes[] = {0xFF, 0x80, 0x00, 0xFF};
  NSData *colorData = [NSData dataWithBytes:colorBytes
                                     length:sizeof(colorBytes)];

  NSString *base64String = [colorData base64EncodedStringWithOptions:0];

  NSString *jsonString =
      [NSString stringWithFormat:
                    @"{"
                     " \"asset\": { \"version\": \"\" },"
                     " \"buffers\": ["
                     "  {"
                     "   \"byteLength\": %lu,"
                     "   \"uri\": \"data:application/octet-stream;base64,%@\""
                     "  }"
                     " ],"
                     " \"bufferViews\": ["
                     "  {"
                     "   \"buffer\": 0,"
                     "   \"byteOffset\": 0,"
                     "   \"byteLength\": 4,"
                     "   \"target\": 34962"
                     "  }"
                     " ],"
                     " \"accessors\": ["
                     "  {"
                     "   \"bufferView\": 0,"
                     "   \"byteOffset\": 0,"
                     "   \"componentType\": 5121,"
                     "   \"normalized\": true,"
                     "   \"count\": 1,"
                     "   \"type\": \"VEC4\","
                     "   \"max\": [255, 255, 255, 255],"
                     "   \"min\": [0, 0, 0, 0]"
                     "  }"
                     " ]"
                     "}",
                    (unsigned long)colorData.length, base64String];

  NSError *error;
  GLTFModel *object = [GLTFModel
      objectWithGltfData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]
                    path:nil
                   error:&error];
  XCTAssertNil(error);
  XCTAssertNotNil(object);

  GLTFAccessor *accessor = object.json.accessors.firstObject;
  NSData *normalizedData = [object dataByAccessor:accessor];
  XCTAssertNotNil(normalizedData, "Normalized data should not be nil.");

  float expectedValues[4] = {1.0, 128.0 / 255.0, 0.0, 1.0};
  float *normalizedValues = (float *)normalizedData.bytes;
  NSUInteger numComponents = normalizedData.length / sizeof(float);

  XCTAssertEqual(
      numComponents, 4,
      "There should be exactly four components in the normalized data.");

  for (NSUInteger i = 0; i < numComponents; i++) {
    XCTAssertEqualWithAccuracy(normalizedValues[i], expectedValues[i], 0.0001,
                               @"Normalized value at index %lu is incorrect",
                               (unsigned long)i);
  }
}

- (void)testDataByAccessorWithSparse {
  // index: 0, sparse value: 0xFF
  unsigned char sparseColorBytes[] = {0x00, 0x00, 0x20};
  NSData *sparseColorData = [NSData dataWithBytes:sparseColorBytes
                                           length:sizeof(sparseColorBytes)];

  NSString *base64String = [sparseColorData base64EncodedStringWithOptions:0];

  NSString *jsonString =
      [NSString stringWithFormat:
                    @"{"
                     " \"asset\": { \"version\": \"2.0\" },"
                     " \"buffers\": ["
                     "  {"
                     "   \"byteLength\": %lu,"
                     "   \"uri\": \"data:application/octet-stream;base64,%@\""
                     "  }"
                     " ],"
                     " \"bufferViews\": ["
                     "  {"
                     "   \"buffer\": 0,"
                     "   \"byteOffset\": 0,"
                     "   \"byteLength\": 3,"
                     "   \"target\": 34962"
                     "  }"
                     " ],"
                     " \"accessors\": ["
                     "  {"
                     "   \"componentType\": 5121," // unsigned byte
                     "   \"count\": 1,"
                     "   \"type\": \"SCALAR\","
                     "   \"max\": [255],"
                     "   \"min\": [0],"
                     "   \"sparse\": {"
                     "    \"count\": 1,"
                     "    \"indices\": {"
                     "     \"bufferView\": 0,"
                     "     \"byteOffset\": 0,"
                     "     \"componentType\": 5123" // unsigned short
                     "    },"
                     "    \"values\": {"
                     "     \"bufferView\": 0,"
                     "     \"byteOffset\": 2"
                     "    }"
                     "   }"
                     "  }"
                     " ]"
                     "}",
                    (unsigned long)sparseColorData.length, base64String];

  NSError *error;
  GLTFModel *object = [GLTFModel
      objectWithGltfData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]
                    path:nil
                   error:&error];
  XCTAssertNil(error);
  XCTAssertNotNil(object);

  GLTFAccessor *accessor = object.json.accessors.firstObject;
  NSData *normalizedData = [object dataByAccessor:accessor];
  XCTAssertNotNil(normalizedData, "Normalized data should not be nil.");

  uint8_t expectedValue = 0x20;
  uint8_t normalizedValue = *((uint8_t *)normalizedData.bytes);

  XCTAssertEqualWithAccuracy(normalizedValue, expectedValue, 0.0001,
                             @"Normalized value is incorrect");
}

@end
