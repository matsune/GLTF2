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

#pragma mark - GLTFMesh

- (void)testDecodeMeshFromJsonWithValidData {
  NSDictionary *validJson = @{
    @"primitives" : @[ @{
      @"attributes" : @{@"POSITION" : @0, @"NORMAL" : @1},
      @"indices" : @2,
      @"material" : @3,
      @"mode" : @"TRIANGLES",
      @"targets" : @[ @4, @5 ],
      @"extensions" : @{@"exampleExtension" : @true},
      @"extras" : @{@"note" : @"This is a test."}
    } ],
    @"weights" : @[ @0.5, @0.5 ],
    @"name" : @"testMesh",
    @"extensions" : @{@"exampleExtension" : @true},
    @"extras" : @{@"note" : @"This is a note."}
  };

  NSError *error = nil;
  GLTFMesh *mesh = [GLTFDecoder decodeMeshFromJson:validJson error:&error];

  XCTAssertNotNil(mesh, @"Decoding should succeed.");
  XCTAssertNil(error, @"There should be no error.");
  XCTAssertEqual(mesh.primitives.count, 1, @"There should be one primitive.");
  NSArray *weights = @[ @0.5, @0.5 ];
  XCTAssertEqualObjects(mesh.weights, weights, @"Weights should match.");
  XCTAssertEqualObjects(mesh.name, @"testMesh", @"Name should match.");
  NSDictionary *expectedExtensions = @{@"exampleExtension" : @true};
  XCTAssertEqualObjects(mesh.extensions, expectedExtensions,
                        @"Extensions should match.");
  NSDictionary *expectedExtras = @{@"note" : @"This is a note."};
  XCTAssertEqualObjects(mesh.extras, expectedExtras, @"Extras should match.");
}

- (void)testDecodeMeshFromJsonWithMissingData {
  NSDictionary *missingDataJson = @{
    // Missing primitives
    @"weights" : @[ @0.5, @0.5 ],
    @"name" : @"testMesh",
    @"extensions" : @{@"exampleExtension" : @true},
    @"extras" : @{@"note" : @"This is a note."}
  };

  NSError *error = nil;
  GLTFMesh *mesh = [GLTFDecoder decodeMeshFromJson:missingDataJson
                                             error:&error];

  XCTAssertNil(mesh, @"Mesh should be nil due to missing 'primitives'.");
  XCTAssertNotNil(error, @"There should be an error.");
  XCTAssertEqual(error.code, GLTF2ErrorMissingData,
                 @"Error code should indicate missing data.");
}

- (void)testDecodeMeshFromJsonWithInvalidDataType {
  NSDictionary *invalidDataTypeJson = @{
    @"primitives" : @"This should be an array, not a string.",
    @"weights" : @[ @0.5, @0.5 ],
    @"name" : @"testMesh",
    @"extensions" : @{@"exampleExtension" : @true},
    @"extras" : @{@"note" : @"This is a note."}
  };

  NSError *error = nil;
  GLTFMesh *mesh = [GLTFDecoder decodeMeshFromJson:invalidDataTypeJson
                                             error:&error];

  XCTAssertNil(
      mesh, @"Mesh should be nil due to invalid data type for 'primitives'.");
  XCTAssertNotNil(error, @"There should be an error.");
  XCTAssertEqual(error.code, GLTF2ErrorInvalidFormat,
                 @"Error code should indicate invalid format.");
}

#pragma mark - GLTFMeshPrimitive

- (void)testDecodeMeshPrimitiveFromJsonWithValidData {
  NSDictionary *validJson = @{
    @"attributes" : @{@"POSITION" : @0, @"NORMAL" : @1},
    @"indices" : @2,
    @"material" : @3,
    @"mode" : @"TRIANGLES",
    @"targets" : @[ @4, @5 ],
    @"extensions" : @{@"exampleExtension" : @true},
    @"extras" : @{@"note" : @"This is a test."}
  };

  NSError *error = nil;
  GLTFMeshPrimitive *primitive =
      [GLTFDecoder decodeMeshPrimitiveFromJson:validJson error:&error];

  XCTAssertNotNil(primitive, @"Decoding should succeed.");
  XCTAssertNil(error, @"There should be no error.");

  NSDictionary *expectedAttributes = @{@"POSITION" : @0, @"NORMAL" : @1};
  XCTAssertEqualObjects(primitive.attributes, expectedAttributes,
                        @"Attributes should match.");
  XCTAssertEqual(primitive.indices, 2, @"Indices should match.");
  XCTAssertEqual(primitive.material, 3, @"Material should match.");
  XCTAssertEqual(primitive.mode, GLTFPrimitiveModeTriangles,
                 @"Mode should be triangles.");

  NSArray *expectedTargets = @[ @4, @5 ];
  XCTAssertEqualObjects(primitive.targets, expectedTargets,
                        @"Targets should match.");

  NSDictionary *expectedExtensions = @{@"exampleExtension" : @true};
  XCTAssertEqualObjects(primitive.extensions, expectedExtensions,
                        @"Extensions should match.");

  NSDictionary *expectedExtras = @{@"note" : @"This is a test."};
  XCTAssertEqualObjects(primitive.extras, expectedExtras,
                        @"Extras should match.");
}

- (void)testDecodeMeshPrimitiveFromJsonWithMissingData {
  NSDictionary *missingDataJson = @{
    // Missing attributes
    @"indices" : @2,
    @"material" : @3,
    @"mode" : @"TRIANGLES",
    @"targets" : @[ @{@"POSITION" : @4}, @{@"NORMAL" : @5} ],
    @"extensions" : @{@"exampleExtension" : @true},
    @"extras" : @{@"note" : @"This is a test."}
  };

  NSError *error = nil;
  GLTFMeshPrimitive *primitive =
      [GLTFDecoder decodeMeshPrimitiveFromJson:missingDataJson error:&error];

  XCTAssertNil(primitive,
               @"Primitive should be nil due to missing 'attributes'.");
  XCTAssertNotNil(error, @"There should be an error.");
  XCTAssertEqual(error.code, GLTF2ErrorMissingData,
                 @"Error code should indicate missing data.");
}

- (void)testDecodeMeshPrimitiveFromJsonWithInvalidDataType {
  NSDictionary *invalidDataTypeJson = @{
    @"attributes" : @"This should be a dictionary, not a string.",
    @"indices" : @2,
    @"material" : @3,
    @"mode" : @"TRIANGLES",
    @"targets" : @[ @{@"POSITION" : @4}, @{@"NORMAL" : @5} ],
    @"extensions" : @{@"exampleExtension" : @true},
    @"extras" : @{@"note" : @"This is a test."}
  };

  NSError *error = nil;
  GLTFMeshPrimitive *primitive =
      [GLTFDecoder decodeMeshPrimitiveFromJson:invalidDataTypeJson
                                         error:&error];

  XCTAssertNil(
      primitive,
      @"Primitive should be nil due to invalid data type for attributes.");
  XCTAssertNotNil(error, @"There should be an error.");
  XCTAssertEqual(error.code, GLTF2ErrorInvalidFormat,
                 @"Error code should indicate invalid format.");
}

#pragma mark - GLTFNode

- (void)testDecodeNodeWithValidData {
  NSDictionary *validJson = @{
    @"camera" : @1,
    @"children" : @[ @2, @3 ],
    @"skin" : @4,
    @"matrix" :
        @[ @1, @0, @0, @0, @0, @1, @0, @0, @0, @0, @1, @0, @0, @0, @0, @1 ],
    @"mesh" : @5,
    @"rotation" : @[ @0, @0, @0, @1 ],
    @"scale" : @[ @1, @1, @1 ],
    @"translation" : @[ @0, @0, @0 ],
    @"weights" : @[ @0.5, @0.5 ],
    @"name" : @"testNode",
    @"extensions" : @{@"exampleExtension" : @true},
    @"extras" : @{@"note" : @"This is a test."}
  };

  NSError *error = nil;
  GLTFNode *node = [GLTFDecoder decodeNodeFromJson:validJson error:&error];

  XCTAssertNotNil(node, "The decoded object should not be nil.");
  XCTAssertNil(error, "There should be no error during the decoding process.");

  XCTAssertEqual(node.camera, 1,
                 "The camera index should be decoded correctly.");
  NSArray *children = @[ @2, @3 ];
  XCTAssertEqualObjects(node.children, children,
                        "The children array should be decoded correctly.");
  XCTAssertEqual(node.skin, 4, "The skin index should be decoded correctly.");
  simd_float4x4 matrix =
      (simd_float4x4){(simd_float4){1, 0, 0, 0}, (simd_float4){0, 1, 0, 0},
                      (simd_float4){0, 0, 1, 0}, (simd_float4){0, 0, 0, 1}};
  for (int i = 0; i < 4; i++) {
    for (int j = 0; j < 4; j++) {
      XCTAssertEqual(node.matrix.columns[i][j], matrix.columns[i][j],
                     @"The element at row %d column %d should match", i, j);
    }
  }
  XCTAssertEqual(node.mesh, 5, "The mesh index should be decoded correctly.");
  NSArray *rotation = @[ @0, @0, @0, @1 ];
  XCTAssertEqualObjects(node.rotation, rotation,
                        "The rotation should be decoded correctly.");
  NSArray *scale = @[ @1, @1, @1 ];
  XCTAssertEqualObjects(node.scale, scale,
                        "The scale should be decoded correctly.");
  NSArray *translation = @[ @0, @0, @0 ];
  XCTAssertEqualObjects(node.translation, translation,
                        "The translation should be decoded correctly.");
  NSArray *weights = @[ @0.5, @0.5 ];
  XCTAssertEqualObjects(node.weights, weights,
                        "The weights should be decoded correctly.");
  XCTAssertEqualObjects(node.name, @"testNode",
                        "The name should be decoded correctly.");

  NSDictionary *expectedExtensions = @{@"exampleExtension" : @true};
  XCTAssertEqualObjects(node.extensions, expectedExtensions,
                        "The extensions should be decoded correctly.");

  NSDictionary *expectedExtras = @{@"note" : @"This is a test."};
  XCTAssertEqualObjects(node.extras, expectedExtras,
                        "The extras should be decoded correctly.");
}

- (void)testDefaultValues {
  NSDictionary *emptyJson = @{};
  NSError *error = nil;
  GLTFNode *node = [GLTFDecoder decodeNodeFromJson:emptyJson error:&error];

  XCTAssertNotNil(node, "Node object should not be nil.");
  XCTAssertNil(error, "There should be no error for empty JSON data.");

  XCTAssertEqual(node.camera, 0, "Default value for camera should be 0.");
  XCTAssertNil(node.children, "Default value for children should be nil.");
  XCTAssertEqual(node.skin, 0, "Default value for skin should be 0.");

  simd_float4x4 defaultMatrix =
      (simd_float4x4){(simd_float4){1, 0, 0, 0}, (simd_float4){0, 1, 0, 0},
                      (simd_float4){0, 0, 1, 0}, (simd_float4){0, 0, 0, 1}};
  for (int i = 0; i < 4; i++) {
    for (int j = 0; j < 4; j++) {
      XCTAssertEqual(node.matrix.columns[i][j], defaultMatrix.columns[i][j],
                     @"Default value for matrix should be identity matrix.");
    }
  }

  XCTAssertEqual(node.mesh, 0, "Default value for mesh should be 0.");

  NSArray *defaultRotation = @[ @0, @0, @0, @1 ];
  XCTAssertEqualObjects(node.rotation, defaultRotation,
                        "Default value for rotation should be [0, 0, 0, 1].");

  NSArray *defaultScale = @[ @1, @1, @1 ];
  XCTAssertEqualObjects(node.scale, defaultScale,
                        "Default value for scale should be [1, 1, 1].");

  NSArray *defaultTranslation = @[ @0, @0, @0 ];
  XCTAssertEqualObjects(node.translation, defaultTranslation,
                        "Default value for translation should be [0, 0, 0].");

  XCTAssertNil(node.weights, "Default value for weights should be nil.");
  XCTAssertNil(node.name, "Default value for name should be nil.");
  XCTAssertNil(node.extensions, "Default value for extensions should be nil.");
  XCTAssertNil(node.extras, "Default value for extras should be nil.");
}

- (void)testDecodeNodeWithInvalidData {
  NSDictionary *invalidDataJson =
      @{@"matrix" : @"This is a string, not an array."};
  NSError *error = nil;
  GLTFNode *node = [GLTFDecoder decodeNodeFromJson:invalidDataJson
                                             error:&error];

  XCTAssertNil(node, "Node should be nil because of invalid data.");
  XCTAssertNotNil(error,
                  "Error should not be nil because the data is incorrect.");
  XCTAssertEqual(error.code, GLTF2ErrorInvalidFormat,
                 "Error code should indicate invalid data format.");
}

#pragma mark - GLTFSampler

- (void)testDecodeSamplerFromJsonWithValidData {
  NSDictionary *validJson = @{
    @"magFilter" : @9728, // NEAREST
    @"minFilter" : @9729, // LINEAR
    @"wrapS" : @10497,    // REPEAT
    @"wrapT" : @10497,    // REPEAT
    @"name" : @"testSampler",
    @"extensions" : @{@"exampleExtension" : @true},
    @"extras" : @{@"note" : @"This is a test."}
  };

  NSError *error = nil;
  GLTFSampler *sampler = [GLTFDecoder decodeSamplerFromJson:validJson
                                                      error:&error];

  XCTAssertNotNil(sampler, "The decoded object should not be nil.");
  XCTAssertNil(error, "There should be no error during the decoding process.");

  XCTAssertEqual(sampler.magFilter, 9728,
                 "The magFilter should be decoded correctly.");
  XCTAssertEqual(sampler.minFilter, 9729,
                 "The minFilter should be decoded correctly.");
  XCTAssertEqual(sampler.wrapS, 10497,
                 "The wrapS should be decoded correctly.");
  XCTAssertEqual(sampler.wrapT, 10497,
                 "The wrapT should be decoded correctly.");
  XCTAssertEqualObjects(sampler.name, @"testSampler",
                        "The name should be decoded correctly.");

  NSDictionary *expectedExtensions = @{@"exampleExtension" : @true};
  XCTAssertEqualObjects(sampler.extensions, expectedExtensions,
                        "The extensions should be decoded correctly.");

  NSDictionary *expectedExtras = @{@"note" : @"This is a test."};
  XCTAssertEqualObjects(sampler.extras, expectedExtras,
                        "The extras should be decoded correctly.");
}

- (void)testDecodeSamplerFromJsonWithEmptyData {
  NSDictionary *emptyJson = @{};
  NSError *error = nil;
  GLTFSampler *sampler = [GLTFDecoder decodeSamplerFromJson:emptyJson
                                                      error:&error];

  XCTAssertNotNil(sampler, "Sampler object should not be nil.");
  XCTAssertNil(error, "There should be no error for empty JSON data.");

  // Check default values
  XCTAssertEqual(sampler.magFilter, 0, "MagFilter should default to 0.");
  XCTAssertEqual(sampler.minFilter, 0, "MinFilter should default to 0.");
  XCTAssertEqual(sampler.wrapS, 10497, // Default value
                 "WrapS should default to 10497.");
  XCTAssertEqual(sampler.wrapT, 10497, // Default value
                 "WrapT should default to 10497.");
  XCTAssertNil(sampler.name, "Name should be nil for empty JSON.");
  XCTAssertNil(sampler.extensions, "Extensions should be nil for empty JSON.");
  XCTAssertNil(sampler.extras, "Extras should be nil for empty JSON.");
}

- (void)testDecodeSamplerFromJsonWithInvalidDataType {
  NSDictionary *invalidDataTypeJson =
      @{@"magFilter" : @"This is a string, not a number."};
  NSError *error = nil;
  GLTFSampler *sampler = [GLTFDecoder decodeSamplerFromJson:invalidDataTypeJson
                                                      error:&error];

  XCTAssertNil(sampler, "Sampler should be nil because of invalid data type.");
  XCTAssertNotNil(
      error, "Error should not be nil because the data type is incorrect.");
  XCTAssertEqual(error.code, GLTF2ErrorInvalidFormat,
                 "Error code should indicate invalid data format.");
}

#pragma mark - GLTFScene

- (void)testDecodeSceneFromJsonWithValidData {
  NSDictionary *validJson = @{
    @"nodes" : @[ @1, @2, @3 ],
    @"name" : @"testScene",
    @"extensions" : @{@"exampleExtension" : @true},
    @"extras" : @{@"note" : @"This is a test."}
  };
  NSError *error;

  GLTFScene *scene = [GLTFDecoder decodeSceneFromJson:validJson error:&error];

  XCTAssertNotNil(scene, "The decoded object should not be nil.");
  XCTAssertNil(error, "There should be no error during the decoding process.");

  NSArray *nodes = @[ @1, @2, @3 ];
  XCTAssertEqualObjects(scene.nodes, nodes,
                        "The nodes should be decoded correctly.");
  XCTAssertEqualObjects(scene.name, @"testScene",
                        "The name should be decoded correctly.");

  NSDictionary *expectedExtensions = @{@"exampleExtension" : @true};
  XCTAssertEqualObjects(scene.extensions, expectedExtensions,
                        "The extensions should be decoded correctly.");

  NSDictionary *expectedExtras = @{@"note" : @"This is a test."};
  XCTAssertEqualObjects(scene.extras, expectedExtras,
                        "The extras should be decoded correctly.");
}

- (void)testDecodeSceneFromJsonWithEmptyData {
  NSDictionary *emptyJson = @{};
  NSError *error = nil;
  GLTFScene *scene = [GLTFDecoder decodeSceneFromJson:emptyJson error:&error];

  XCTAssertNotNil(scene, "Scene object should not be nil.");
  XCTAssertNil(error, "There should be no error for empty JSON data.");

  XCTAssertNil(scene.nodes, "Nodes should be nil for empty JSON.");
  XCTAssertNil(scene.name, "Name should be nil for empty JSON.");
  XCTAssertNil(scene.extensions, "Extensions should be nil for empty JSON.");
  XCTAssertNil(scene.extras, "Extras should be nil for empty JSON.");
}

- (void)testDecodeSceneFromJsonWithMissingData {
  NSDictionary *missingDataJson = @{};
  NSError *error = nil;
  GLTFScene *scene = [GLTFDecoder decodeSceneFromJson:missingDataJson
                                                error:&error];

  XCTAssertNotNil(scene, "Scene object should not be nil for empty JSON data.");

  XCTAssertNil(scene.nodes, "Nodes should be nil for empty JSON data.");
  XCTAssertNil(scene.name, "Name should be nil for empty JSON data.");
  XCTAssertNil(scene.extensions,
               "Extensions should be nil for empty JSON data.");
  XCTAssertNil(scene.extras, "Extras should be nil for empty JSON data.");
  XCTAssertNil(error, "There should be no error for empty JSON data.");
}

- (void)testDecodeSceneFromJsonWithInvalidDataType {
  NSDictionary *invalidDataTypeJson =
      @{@"nodes" : @"This is a string, not an array."};
  NSError *error = nil;
  GLTFScene *scene = [GLTFDecoder decodeSceneFromJson:invalidDataTypeJson
                                                error:&error];

  XCTAssertNil(scene, "Scene object should be nil due to invalid data type.");
  XCTAssertNotNil(error, "There should be an error.");
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
