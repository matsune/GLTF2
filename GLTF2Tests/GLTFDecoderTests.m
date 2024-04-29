#import "GLTFDecoder.h"
#import <XCTest/XCTest.h>

@interface GLTFDecoderTests : XCTestCase
@end

@implementation GLTFDecoderTests

#pragma mark - GLTFAccessorSparseIndices

- (void)testDecodeAccessorSparseIndicesFromJsonWithValidData {
  NSDictionary *validJson = @{
    @"bufferView" : @1,
    @"byteOffset" : @256,
    @"componentType" : @5123, // UNSIGNED_SHORT
    @"extensions" : @{@"exampleExtension" : @true},
    @"extras" : @{@"note" : @"This is a test."}
  };
  NSError *error = nil;

  GLTFAccessorSparseIndices *indices =
      [GLTFDecoder decodeAccessorSparseIndicesFromJson:validJson error:&error];

  XCTAssertNotNil(indices, "The decoded object should not be nil.");
  XCTAssertNil(error, "There should be no error during the decoding process.");

  XCTAssertEqual(indices.bufferView, 1,
                 "The bufferView should be decoded correctly.");
  XCTAssertEqual(indices.byteOffset, 256,
                 "The byteOffset should be decoded correctly.");
  XCTAssertEqual(indices.componentType, 5123,
                 "The componentType should be decoded correctly.");

  NSDictionary *expectedExtensions = @{@"exampleExtension" : @true};
  XCTAssertEqualObjects(indices.extensions, expectedExtensions,
                        "The extensions should be decoded correctly.");

  NSDictionary *expectedExtras = @{@"note" : @"This is a test."};
  XCTAssertEqualObjects(indices.extras, expectedExtras,
                        "The extras should be decoded correctly.");
}

- (void)testDecodeAccessorSparseIndicesFromJsonWithMissingData {
  NSDictionary *missingDataJson = @{};
  NSError *error = nil;
  GLTFAccessorSparseIndices *indices =
      [GLTFDecoder decodeAccessorSparseIndicesFromJson:missingDataJson
                                                 error:&error];

  XCTAssertNil(indices, "Indices should be nil because of missing data.");
  XCTAssertNotNil(
      error, "Error should not be nil because the required key is missing.");
  XCTAssertEqual(error.code, GLTF2ErrorMissingData,
                 "Error code should indicate missing data.");
}

- (void)testDecodeAccessorSparseIndicesFromJsonWithInvalidDataType {
  NSDictionary *invalidDataTypeJson =
      @{@"bufferView" : @"This is a string, not a number."};
  NSError *error = nil;
  GLTFAccessorSparseIndices *indices =
      [GLTFDecoder decodeAccessorSparseIndicesFromJson:invalidDataTypeJson
                                                 error:&error];

  XCTAssertNil(indices, "Indices should be nil because of invalid data type.");
  XCTAssertNotNil(
      error, "Error should not be nil because the data type is incorrect.");
  XCTAssertEqual(error.code, GLTF2ErrorInvalidFormat,
                 "Error code should indicate invalid data format.");
}

#pragma mark - GLTFAccessorSparseValues

- (void)testDecodeAccessorSparseValuesFromJsonWithValidData {
  NSDictionary *validJson = @{
    @"bufferView" : @1,
    @"byteOffset" : @256,
    @"extensions" : @{@"exampleExtension" : @true},
    @"extras" : @{@"note" : @"This is a test."}
  };
  NSError *error;

  GLTFAccessorSparseValues *values =
      [GLTFDecoder decodeAccessorSparseValuesFromJson:validJson error:&error];

  XCTAssertNotNil(values, "The decoded object should not be nil.");
  XCTAssertNil(error, "There should be no error during the decoding process.");

  XCTAssertEqual(values.bufferView, 1,
                 "The bufferView should be decoded correctly.");
  XCTAssertEqual(values.byteOffset, 256,
                 "The byteOffset should be decoded correctly.");

  NSDictionary *expectedExtensions = @{@"exampleExtension" : @true};
  XCTAssertEqualObjects(values.extensions, expectedExtensions,
                        "The extensions should be decoded correctly.");

  NSDictionary *expectedExtras = @{@"note" : @"This is a test."};
  XCTAssertEqualObjects(values.extras, expectedExtras,
                        "The extras should be decoded correctly.");
}

- (void)testDecodeAccessorSparseValuesFromJsonWithMissingData {
  NSDictionary *missingDataJson = @{};
  NSError *error = nil;
  GLTFAccessorSparseValues *values =
      [GLTFDecoder decodeAccessorSparseValuesFromJson:missingDataJson
                                                error:&error];

  XCTAssertNil(values, "Values should be nil because of missing data.");
  XCTAssertNotNil(
      error, "Error should not be nil because the required key is missing.");
  XCTAssertEqual(error.code, GLTF2ErrorMissingData,
                 "Error code should indicate missing data.");
}

- (void)testDecodeAccessorSparseValuesFromJsonWithInvalidDataType {
  NSDictionary *invalidDataTypeJson =
      @{@"bufferView" : @"This is a string, not a number."};
  NSError *error = nil;
  GLTFAccessorSparseValues *values =
      [GLTFDecoder decodeAccessorSparseValuesFromJson:invalidDataTypeJson
                                                error:&error];

  XCTAssertNil(values, "Values should be nil because of invalid data type.");
  XCTAssertNotNil(
      error, "Error should not be nil because the data type is incorrect.");
  XCTAssertEqual(error.code, GLTF2ErrorInvalidFormat,
                 "Error code should indicate invalid data format.");
}

@end
