#import "GLTFDecoder.h"
#import <XCTest/XCTest.h>

@interface GLTFDecoderTests : XCTestCase
@end

@implementation GLTFDecoderTests

#pragma mark - GLTFAccessor

- (void)testDecodeAccessorFromJsonWithValidData {
  NSDictionary *validJson = @{
    @"bufferView" : @1,
    @"byteOffset" : @256,
    @"componentType" : @5126,
    @"normalized" : @false,
    @"count" : @100,
    @"type" : @"VEC3",
    @"max" : @[ @1.0, @2.0, @3.0 ],
    @"min" : @[ @0.0, @0.0, @0.0 ],
    @"sparse" : @{
      @"count" : @3,
      @"indices" : @{
        @"bufferView" : @0,
        @"byteOffset" : @0,
        @"componentType" : @5123,
        @"extensions" : @{@"exampleExtension" : @true},
        @"extras" : @{@"note" : @"This is a test."}
      },
      @"values" : @{
        @"bufferView" : @1,
        @"byteOffset" : @0,
        @"componentType" : @5126,
        @"extensions" : @{@"exampleExtension" : @true},
        @"extras" : @{@"note" : @"This is a test."}
      },
      @"extensions" : @{@"exampleExtension" : @true},
      @"extras" : @{@"note" : @"This is a test."}
    },
    @"name" : @"test_accessor",
    @"extensions" : @{@"exampleExtension" : @true},
    @"extras" : @{@"note" : @"This is a test."}
  };

  NSError *error = nil;
  GLTFAccessor *accessor = [GLTFDecoder decodeAccessorFromJson:validJson
                                                         error:&error];

  XCTAssertNotNil(accessor, @"Decoding should succeed");
  XCTAssertNil(error, @"There should be no error");

  XCTAssertEqual(accessor.bufferView, 1, @"BufferView should be 1");
  XCTAssertEqual(accessor.byteOffset, 256, @"ByteOffset should be 256");
  XCTAssertEqual(accessor.componentType, GLTFAccessorComponentTypeFloat,
                 @"ComponentType should be GLTFAccessorComponentTypeFloat");
  XCTAssertFalse(accessor.normalized, @"Normalized should be false");
  XCTAssertEqual(accessor.count, 100, @"Count should be 100");
  XCTAssertEqual(accessor.type, GLTFAccessorTypeVec3,
                 @"Type should be GLTFAccessorTypeVec3");
  NSArray *max = @[ @(1.0), @(2.0), @(3.0) ];
  XCTAssertEqualObjects(accessor.max, max, @"Max values should match");
  NSArray *min = @[ @(0.0), @(0.0), @(0.0) ];
  XCTAssertEqualObjects(accessor.min, min, @"Min values should match");

  XCTAssertEqualObjects(accessor.name, @"test_accessor", @"Name should match");

  XCTAssertNotNil(accessor.sparse, @"Sparse should not be nil");
  XCTAssertEqual(accessor.sparse.count, 3, @"Sparse count should be 3");

  XCTAssertEqualObjects(accessor.extensions, validJson[@"extensions"],
                        @"Extensions should match");
  XCTAssertEqualObjects(accessor.extras, validJson[@"extras"],
                        @"Extras should match");
}

- (void)testDecodeAccessorFromJsonWithMissingData {
  NSDictionary *missingDataJson = @{
    @"byteOffset" : @256,
    @"componentType" : @5126,
    @"normalized" : @false,
    @"count" : @100,
    @"type" : @"VEC3",
    @"max" : @[ @1.0, @2.0, @3.0 ],
    @"min" : @[ @0.0, @0.0, @0.0 ],
    @"sparse" : @{
      @"count" : @3,
      @"indices" : @{
        @"bufferView" : @0,
        @"byteOffset" : @0,
        @"componentType" : @5123,
        @"extensions" : @{@"exampleExtension" : @true},
        @"extras" : @{@"note" : @"This is a test."}
      },
      @"values" : @{
        @"bufferView" : @1,
        @"byteOffset" : @0,
        @"componentType" : @5126,
        @"extensions" : @{@"exampleExtension" : @true},
        @"extras" : @{@"note" : @"This is a test."}
      },
      @"extensions" : @{@"exampleExtension" : @true},
      @"extras" : @{@"note" : @"This is a test."}
    },
    @"name" : @"test_accessor",
    @"extensions" : @{@"exampleExtension" : @true},
    @"extras" : @{@"note" : @"This is a test."}
  };

  NSError *error = nil;
  GLTFAccessor *accessor = [GLTFDecoder decodeAccessorFromJson:missingDataJson
                                                         error:&error];

  XCTAssertNil(accessor,
               @"Accessor should be nil due to missing 'bufferView' key");
  XCTAssertNotNil(error, @"There should be an error");
  XCTAssertEqual(error.code, GLTF2ErrorMissingData,
                 @"Error code should indicate missing data");
}

- (void)testDecodeAccessorFromJsonWithInvalidDataType {
  NSDictionary *invalidDataTypeJson = @{
    @"bufferView" : @1,
    @"byteOffset" : @256,
    @"componentType" : @"This is a string, not a number.",
    @"normalized" : @false,
    @"count" : @100,
    @"type" : @"VEC3",
    @"max" : @[ @1.0, @2.0, @3.0 ],
    @"min" : @[ @0.0, @0.0, @0.0 ],
    @"sparse" : @{
      @"count" : @3,
      @"indices" : @{
        @"bufferView" : @0,
        @"byteOffset" : @0,
        @"componentType" : @5123,
        @"extensions" : @{@"exampleExtension" : @true},
        @"extras" : @{@"note" : @"This is a test."}
      },
      @"values" : @{
        @"bufferView" : @1,
        @"byteOffset" : @0,
        @"componentType" : @5126,
        @"extensions" : @{@"exampleExtension" : @true},
        @"extras" : @{@"note" : @"This is a test."}
      },
      @"extensions" : @{@"exampleExtension" : @true},
      @"extras" : @{@"note" : @"This is a test."}
    },
    @"name" : @"test_accessor",
    @"extensions" : @{@"exampleExtension" : @true},
    @"extras" : @{@"note" : @"This is a test."}
  };

  NSError *error = nil;
  GLTFAccessor *accessor =
      [GLTFDecoder decodeAccessorFromJson:invalidDataTypeJson error:&error];

  XCTAssertNil(accessor, @"Accessor should be nil due to invalid data type");
  XCTAssertNotNil(error, @"There should be an error");
  XCTAssertEqual(error.code, GLTF2ErrorInvalidFormat,
                 @"Error code should indicate invalid format");
}

#pragma mark - GLTFAccessorSparse

- (void)testDecodeAccessorSparseFromJsonWithValidData {
  NSDictionary *validJson = @{
    @"count" : @3,
    @"indices" : @{
      @"bufferView" : @0,
      @"byteOffset" : @0,
      @"componentType" : @5123,
      @"extensions" : @{@"exampleExtension" : @true},
      @"extras" : @{@"note" : @"This is a test."}
    },
    @"values" : @{
      @"bufferView" : @1,
      @"byteOffset" : @0,
      @"componentType" : @5126,
      @"extensions" : @{@"exampleExtension" : @true},
      @"extras" : @{@"note" : @"This is a test."}
    },
    @"extensions" : @{@"exampleExtension" : @true},
    @"extras" : @{@"note" : @"This is a test."}
  };

  NSError *error = nil;
  GLTFAccessorSparse *sparse =
      [GLTFDecoder decodeAccessorSparseFromJson:validJson error:&error];

  XCTAssertNotNil(sparse, @"Decoding should succeed");
  XCTAssertNil(error, @"There should be no error");

  XCTAssertEqual(sparse.count, 3, @"Count should be 3");

  XCTAssertNotNil(sparse.indices, @"Indices should not be nil");
  XCTAssertEqual(sparse.indices.bufferView, 0,
                 @"Indices bufferView should be 0");

  XCTAssertNotNil(sparse.values, @"Values should not be nil");
  XCTAssertEqual(sparse.values.bufferView, 1, @"Values bufferView should be 1");

  XCTAssertEqualObjects(sparse.extensions, validJson[@"extensions"],
                        @"Extensions should match");
  XCTAssertEqualObjects(sparse.extras, validJson[@"extras"],
                        @"Extras should match");
}

- (void)testDecodeAccessorSparseFromJsonWithMissingData {
  NSDictionary *missingDataJson = @{
    @"values" : @{
      @"bufferView" : @1,
      @"byteOffset" : @0,
      @"componentType" : @5126,
      @"extensions" : @{@"exampleExtension" : @true},
      @"extras" : @{@"note" : @"This is a test."}
    },
    @"extensions" : @{@"exampleExtension" : @true},
    @"extras" : @{@"note" : @"This is a test."}
  };

  NSError *error = nil;
  GLTFAccessorSparse *sparse =
      [GLTFDecoder decodeAccessorSparseFromJson:missingDataJson error:&error];

  XCTAssertNil(sparse, @"Sparse should be nil due to missing 'count' key");
  XCTAssertNotNil(error, @"There should be an error");
  XCTAssertEqual(error.code, GLTF2ErrorMissingData,
                 @"Error code should indicate missing data");
}

- (void)testDecodeAccessorSparseFromJsonWithInvalidDataType {
  NSDictionary *invalidDataTypeJson = @{
    @"count" : @"This is a string, not a number.",
    @"indices" : @{
      @"bufferView" : @0,
      @"byteOffset" : @0,
      @"componentType" : @5123,
      @"extensions" : @{@"exampleExtension" : @true},
      @"extras" : @{@"note" : @"This is a test."}
    },
    @"values" : @{
      @"bufferView" : @1,
      @"byteOffset" : @0,
      @"componentType" : @5126,
      @"extensions" : @{@"exampleExtension" : @true},
      @"extras" : @{@"note" : @"This is a test."}
    },
    @"extensions" : @{@"exampleExtension" : @true},
    @"extras" : @{@"note" : @"This is a test."}
  };

  NSError *error = nil;
  GLTFAccessorSparse *sparse =
      [GLTFDecoder decodeAccessorSparseFromJson:invalidDataTypeJson
                                          error:&error];

  XCTAssertNil(sparse, @"Sparse should be nil due to invalid data type");
  XCTAssertNotNil(error, @"There should be an error");
  XCTAssertEqual(error.code, GLTF2ErrorInvalidFormat,
                 @"Error code should indicate invalid format");
}

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

#pragma mark - GLTFSkin

- (void)testDecodeSkinFromJsonWithValidData {
  NSDictionary *validJson = @{
    @"inverseBindMatrices" : @1,
    @"skeleton" : @2,
    @"joints" : @[ @3, @4, @5 ],
    @"name" : @"testSkin",
    @"extensions" : @{@"exampleExtension" : @true},
    @"extras" : @{@"note" : @"This is a test."}
  };

  NSError *error = nil;
  GLTFSkin *skin = [GLTFDecoder decodeSkinFromJson:validJson error:&error];

  XCTAssertNotNil(skin, "The decoded object should not be nil.");
  XCTAssertNil(error, "There should be no error during the decoding process.");

  XCTAssertEqual(skin.inverseBindMatrices, 1,
                 "The inverseBindMatrices should be decoded correctly.");
  XCTAssertEqual(skin.skeleton, 2, "The skeleton should be decoded correctly.");
  NSArray *joints = @[ @3, @4, @5 ];
  XCTAssertEqualObjects(skin.joints, joints,
                        "The joints should be decoded correctly.");
  XCTAssertEqualObjects(skin.name, @"testSkin",
                        "The name should be decoded correctly.");

  NSDictionary *expectedExtensions = @{@"exampleExtension" : @true};
  XCTAssertEqualObjects(skin.extensions, expectedExtensions,
                        "The extensions should be decoded correctly.");

  NSDictionary *expectedExtras = @{@"note" : @"This is a test."};
  XCTAssertEqualObjects(skin.extras, expectedExtras,
                        "The extras should be decoded correctly.");
}

- (void)testDecodeSkinFromJsonWithEmptyData {
  NSDictionary *emptyJson = @{@"joints" : @[]};
  NSError *error = nil;
  GLTFSkin *skin = [GLTFDecoder decodeSkinFromJson:emptyJson error:&error];

  XCTAssertNotNil(skin, "Skin object should not be nil.");
  XCTAssertNil(error, "There should be no error for empty JSON data.");

  XCTAssertEqual(skin.inverseBindMatrices, 0,
                 "InverseBindMatrices should default to 0.");
  XCTAssertEqual(skin.skeleton, 0, "Skeleton should default to 0.");
  XCTAssertEqualObjects(skin.joints, @[],
                        "Joints should default to an empty array.");
  XCTAssertNil(skin.name, "Name should be nil for empty JSON.");
  XCTAssertNil(skin.extensions, "Extensions should be nil for empty JSON.");
  XCTAssertNil(skin.extras, "Extras should be nil for empty JSON.");
}

- (void)testDecodeSkinFromJsonWithInvalidDataType {
  NSDictionary *invalidDataTypeJson =
      @{@"inverseBindMatrices" : @"This is a string, not a number."};
  NSError *error = nil;
  GLTFSkin *skin = [GLTFDecoder decodeSkinFromJson:invalidDataTypeJson
                                             error:&error];

  XCTAssertNil(skin, "Skin should be nil because of invalid data type.");
  XCTAssertNotNil(
      error, "Error should not be nil because the data type is incorrect.");
  XCTAssertEqual(error.code, GLTF2ErrorInvalidFormat,
                 "Error code should indicate invalid data format.");
}

#pragma mark - GLTFTexture

- (void)testDecodeTextureFromJsonWithValidData {
  NSDictionary *validJson = @{
    @"sampler" : @1,
    @"source" : @2,
    @"name" : @"testTexture",
    @"extensions" : @{@"exampleExtension" : @true},
    @"extras" : @{@"note" : @"This is a test."}
  };
  NSError *error;

  GLTFTexture *texture = [GLTFDecoder decodeTextureFromJson:validJson
                                                      error:&error];

  XCTAssertNotNil(texture, "The decoded object should not be nil.");
  XCTAssertNil(error, "There should be no error during the decoding process.");

  XCTAssertEqual(texture.sampler, 1,
                 "The sampler should be decoded correctly.");
  XCTAssertEqual(texture.source, 2, "The source should be decoded correctly.");
  XCTAssertEqualObjects(texture.name, @"testTexture",
                        "The name should be decoded correctly.");

  NSDictionary *expectedExtensions = @{@"exampleExtension" : @true};
  XCTAssertEqualObjects(texture.extensions, expectedExtensions,
                        "The extensions should be decoded correctly.");

  NSDictionary *expectedExtras = @{@"note" : @"This is a test."};
  XCTAssertEqualObjects(texture.extras, expectedExtras,
                        "The extras should be decoded correctly.");
}

- (void)testDecodeTextureFromJsonWithEmptyData {
  NSDictionary *emptyJson = @{};
  NSError *error = nil;
  GLTFTexture *texture = [GLTFDecoder decodeTextureFromJson:emptyJson
                                                      error:&error];

  XCTAssertNotNil(texture, "Texture object should not be nil.");
  XCTAssertNil(error, "There should be no error for empty JSON data.");

  XCTAssertEqual(texture.sampler, 0, "Sampler index should default to 0.");
  XCTAssertEqual(texture.source, 0, "Source index should default to 0.");
  XCTAssertNil(texture.name, "Name should be nil for empty JSON.");
  XCTAssertNil(texture.extensions, "Extensions should be nil for empty JSON.");
  XCTAssertNil(texture.extras, "Extras should be nil for empty JSON.");
}

- (void)testDecodeTextureFromJsonWithInvalidDataType {
  NSDictionary *invalidDataTypeJson =
      @{@"sampler" : @"This is a string, not a number."};
  NSError *error = nil;
  GLTFTexture *texture = [GLTFDecoder decodeTextureFromJson:invalidDataTypeJson
                                                      error:&error];

  XCTAssertNil(texture, "Texture should be nil because of invalid data type.");
  XCTAssertNotNil(
      error, "Error should not be nil because the data type is incorrect.");
  XCTAssertEqual(error.code, GLTF2ErrorInvalidFormat,
                 "Error code should indicate invalid data format.");
}

#pragma mark - GLTFTextureInfo

- (void)testDecodeTextureInfoFromJsonWithValidData {
  NSDictionary *validJson = @{
    @"index" : @1,
    @"texCoord" : @2,
    @"extensions" : @{@"exampleExtension" : @true},
    @"extras" : @{@"note" : @"This is a test."}
  };

  NSError *error = nil;
  GLTFTextureInfo *textureInfo =
      [GLTFDecoder decodeTextureInfoFromJson:validJson error:&error];

  XCTAssertNotNil(textureInfo, "Decoding should succeed.");
  XCTAssertNil(error, "There should be no error during decoding.");

  XCTAssertEqual(textureInfo.index, 1,
                 "The index should be decoded correctly.");
  XCTAssertEqual(textureInfo.texCoord, 2,
                 "The texCoord should be decoded correctly.");

  NSDictionary *expectedExtensions = @{@"exampleExtension" : @true};
  XCTAssertEqualObjects(textureInfo.extensions, expectedExtensions,
                        "Extensions should be decoded correctly.");

  NSDictionary *expectedExtras = @{@"note" : @"This is a test."};
  XCTAssertEqualObjects(textureInfo.extras, expectedExtras,
                        "Extras should be decoded correctly.");
}

- (void)testDecodeTextureInfoFromJsonWithEmptyData {
  NSDictionary *emptyJson = @{@"index" : @1};
  NSError *error = nil;
  GLTFTextureInfo *textureInfo =
      [GLTFDecoder decodeTextureInfoFromJson:emptyJson error:&error];

  XCTAssertNotNil(textureInfo, "TextureInfo object should not be nil.");
  XCTAssertNil(error, "There should be no error for empty JSON data.");

  XCTAssertEqual(textureInfo.index, 1, "Index should default to 1.");
  XCTAssertEqual(textureInfo.texCoord, 0, "TexCoord should default to 0.");
  XCTAssertNil(textureInfo.extensions,
               "Extensions should be nil for empty JSON.");
  XCTAssertNil(textureInfo.extras, "Extras should be nil for empty JSON.");
}

- (void)testDecodeTextureInfoFromJsonWithInvalidDataType {
  NSDictionary *invalidDataTypeJson =
      @{@"index" : @"This is a string, not a number."};
  NSError *error = nil;
  GLTFTextureInfo *textureInfo =
      [GLTFDecoder decodeTextureInfoFromJson:invalidDataTypeJson error:&error];

  XCTAssertNil(textureInfo,
               "TextureInfo should be nil due to invalid data type.");
  XCTAssertNotNil(
      error, "Error should not be nil because the data type is incorrect.");
  XCTAssertEqual(error.code, GLTF2ErrorInvalidFormat,
                 "Error code should indicate invalid data format.");
}

@end
