#import "GLTF2.h"
#import <XCTest/XCTest.h>

@interface GLTFDataTests : XCTestCase

@end

@implementation GLTFDataTests

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
  GLTFData *object = [GLTFData
      dataWithGltfData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]
                  path:nil
                 error:&error];
  XCTAssertNil(error);
  XCTAssertNotNil(object);

  GLTFAccessor *accessor = object.json.accessors.firstObject;
  NSData *normalizedData = [object dataForAccessor:accessor];
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

- (void)testDataForAccessorWithByteStride {
  float bufferData[10 * 4 * 4] = {0}; // sizeof(float) * 3 * 10
  for (int i = 0; i < 10; ++i) {
    bufferData[i * 4] = (float)i;
    bufferData[i * 4 + 1] = (float)i + 1;
    bufferData[i * 4 + 2] = (float)i + 2;
  }
  NSData *bufData = [NSData dataWithBytes:bufferData length:sizeof(bufferData)];

  NSString *base64String = [bufData base64EncodedStringWithOptions:0];

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
                     "   \"byteLength\": 156,"
                     "   \"byteStride\": 16,"
                     "   \"target\": 34962"
                     "  }"
                     " ],"
                     " \"accessors\": ["
                     "  {"
                     "   \"bufferView\": 0,"
                     "   \"byteOffset\": 0,"
                     "   \"componentType\": 5126,"
                     "   \"count\": 10,"
                     "   \"type\": \"VEC3\""
                     "  }"
                     " ]"
                     "}",
                    (unsigned long)bufData.length, base64String];

  NSError *error;
  GLTFData *object = [GLTFData
      dataWithGltfData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]
                  path:nil
                 error:&error];
  XCTAssertNotNil(error);
  XCTAssertNotNil(object);

  GLTFAccessor *accessor = object.json.accessors.firstObject;
  NSData *data = [object dataForAccessor:accessor];
  XCTAssertNotNil(data);
  XCTAssertEqual(data.length, 120);

  float *floatArray = (float *)[data bytes];
  for (int i = 0; i < 10; ++i) {
    int baseIndex = i * 3;
    XCTAssertEqualWithAccuracy(floatArray[baseIndex], (float)i, 0.0001);
    XCTAssertEqualWithAccuracy(floatArray[baseIndex + 1], (float)i + 1, 0.0001);
    XCTAssertEqualWithAccuracy(floatArray[baseIndex + 2], (float)i + 2, 0.0001);
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
  GLTFData *object = [GLTFData
      dataWithGltfData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]
                  path:nil
                 error:&error];
  XCTAssertNil(error);
  XCTAssertNotNil(object);

  GLTFAccessor *accessor = object.json.accessors.firstObject;
  NSData *normalizedData = [object dataForAccessor:accessor];
  XCTAssertNotNil(normalizedData, "Normalized data should not be nil.");

  uint8_t expectedValue = 0x20;
  uint8_t normalizedValue = *((uint8_t *)normalizedData.bytes);

  XCTAssertEqualWithAccuracy(normalizedValue, expectedValue, 0.0001,
                             @"Normalized value is incorrect");
}

@end
