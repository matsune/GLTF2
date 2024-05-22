#import "Errors.h"
#import "GLTFDecoder.h"
#import <XCTest/XCTest.h>

@interface GLTFDecoderTests : XCTestCase
@end

@implementation GLTFDecoderTests

#pragma mark - GLTFJson

//- (void)testDecodeJsonWithAllFieldsPresent {
//  // Creating a GLTFDecoder instance
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//
//  // Sample JSON Dictionary representing a full glTF asset
//  NSDictionary *jsonDict = @{
//    @"extensionsUsed" : @[ @"KHR_lights_punctual" ],
//    @"extensionsRequired" : @[ @"KHR_texture_transform" ],
//    @"accessors" : @[ @{
//      @"bufferView" : @1,
//      @"componentType" : @5123,
//      @"type" : @"SCALAR",
//      @"count" : @3
//    } ],
//    @"animations" : @[ @{
//      @"channels" : @[ @{
//        @"sampler" : @0,
//        @"target" : @{@"node" : @1, @"path" : @"translation"}
//      } ],
//      @"samplers" :
//          @[ @{@"input" : @1, @"output" : @2, @"interpolation" : @"LINEAR"} ]
//    } ],
//    @"asset" : @{@"version" : @"2.0", @"generator" : @"ExampleGenerator"},
//    @"buffers" : @[ @{@"byteLength" : @1024} ],
//    @"bufferViews" : @[ @{@"buffer" : @0, @"byteLength" : @512} ],
//    @"cameras" : @[ @{
//      @"type" : @"perspective",
//      @"perspective" : @{@"yfov" : @1.047, @"znear" : @0.01}
//    } ],
//    @"images" : @[ @{@"uri" : @"image.png"} ],
//    @"materials" : @[ @{@"name" : @"Material1"} ],
//    @"meshes" :
//        @[ @{@"primitives" : @[ @{@"attributes" : @{@"POSITION" : @0}} ]} ],
//    @"nodes" : @[ @{@"mesh" : @0} ],
//    @"samplers" : @[ @{@"magFilter" : @9729, @"minFilter" : @9986} ],
//    @"scene" : @0,
//    @"scenes" : @[ @{@"nodes" : @[ @0 ]} ],
//    @"skins" : @[ @{@"inverseBindMatrices" : @0, @"joints" : @[ @0 ]} ],
//    @"textures" : @[ @{@"source" : @0} ],
//    @"extensions" : @{@"someExtension" : @{@"value" : @123}},
//    @"extras" : @{@"someExtraData" : @"data"}
//  };
//
//  NSError *error = nil;
//
//  // Decode the JSON into a GLTFJson object
//  GLTFJson *decodedJson = [decoder decodeJson:jsonDict error:&error];
//
//  // Assertions to ensure all fields are correctly decoded and present
//  XCTAssertNotNil(
//      decodedJson,
//      "GLTFJson should not be nil when all required fields are present");
//  XCTAssertNotNil(decodedJson.extensionsUsed,
//                  "Extensions used should be decoded");
//  XCTAssertNotNil(decodedJson.extensionsRequired,
//                  "Extensions required should be decoded");
//  XCTAssertNotNil(decodedJson.accessors, "Accessors should be decoded");
//  XCTAssertNotNil(decodedJson.animations,
//                  "Animations should be decoded and not nil");
//  XCTAssertEqual(decodedJson.animations.firstObject.channels.count, 1,
//                 "There should be one channel in the first animation");
//  XCTAssertEqual(decodedJson.animations.firstObject.samplers.count, 1,
//                 "There should be one sampler in the first animation");
//  XCTAssertNotNil(decodedJson.asset, "Asset should be decoded");
//  XCTAssertNotNil(decodedJson.buffers, "Buffers should be decoded");
//  XCTAssertNotNil(decodedJson.bufferViews, "BufferViews should be decoded");
//  XCTAssertNotNil(decodedJson.cameras, "Cameras should be decoded");
//  XCTAssertNotNil(decodedJson.images, "Images should be decoded");
//  XCTAssertNotNil(decodedJson.materials, "Materials should be decoded");
//  XCTAssertNotNil(decodedJson.meshes, "Meshes should be decoded");
//  XCTAssertNotNil(decodedJson.nodes, "Nodes should be decoded");
//  XCTAssertNotNil(decodedJson.samplers, "Samplers should be decoded");
//  XCTAssertEqual(decodedJson.scene, @0, "Scene index should be decoded");
//  XCTAssertNotNil(decodedJson.scenes, "Scenes should be decoded");
//  XCTAssertNotNil(decodedJson.skins, "Skins should be decoded");
//  XCTAssertNotNil(decodedJson.textures, "Textures should be decoded");
//  XCTAssertNotNil(decodedJson.extensions, "Extensions should be decoded");
//  XCTAssertNotNil(decodedJson.extras, "Extras should be decoded");
//  XCTAssertNil(
//      error, "Error should be nil when decoding is successful with all
//      fields");
//}
//
//- (void)testDecodeJsonWithMissingRequiredFields {
//  // Creating a GLTFDecoder instance
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//
//  // JSON Dictionary with missing 'asset' field which is required
//  NSDictionary *jsonDict = @{@"extensionsUsed" : @[ @"KHR_lights_punctual" ]};
//
//  NSError *error = nil;
//
//  // Attempt to decode the incomplete JSON
//  GLTFJson *decodedJson = [decoder decodeJson:jsonDict error:&error];
//
//  // Assertions to check proper error handling
//  XCTAssertNil(decodedJson,
//               "GLTFJson should be nil when a required field is missing");
//  XCTAssertNotNil(error,
//                  "Error should not be nil when a required field is missing");
//}
//
//- (void)testDecodeJsonWithOptionalFieldsMissing {
//  // Creating a GLTFDecoder instance
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//
//  // JSON Dictionary with only the required 'asset' field
//  NSDictionary *jsonDict = @{@"asset" : @{@"version" : @"2.0"}};
//
//  NSError *error = nil;
//
//  // Decode the minimal JSON
//  GLTFJson *decodedJson = [decoder decodeJson:jsonDict error:&error];
//
//  // Assertions to ensure the decoding still works with only required fields
//  XCTAssertNotNil(
//      decodedJson,
//      "GLTFJson should not be nil even if optional fields are missing");
//  XCTAssertNil(decodedJson.extensionsUsed,
//               "Extensions used should be nil when not provided");
//  XCTAssertNil(decodedJson.extensionsRequired,
//               "Extensions required should be nil when not provided");
//  XCTAssertNil(decodedJson.accessors,
//               "Accessors should be nil when not provided");
//  XCTAssertNil(decodedJson.animations,
//               "Animations should be nil when not provided");
//  XCTAssertNil(decodedJson.buffers, "Buffers should be nil when not
//  provided"); XCTAssertNil(decodedJson.bufferViews,
//               "BufferViews should be nil when not provided");
//  XCTAssertNil(decodedJson.cameras, "Cameras should be nil when not
//  provided"); XCTAssertNil(decodedJson.images, "Images should be nil when not
//  provided"); XCTAssertNil(decodedJson.materials,
//               "Materials should be nil when not provided");
//  XCTAssertNil(decodedJson.meshes, "Meshes should be nil when not provided");
//  XCTAssertNil(decodedJson.nodes, "Nodes should be nil when not provided");
//  XCTAssertNil(decodedJson.samplers,
//               "Samplers should be nil when not provided");
//  XCTAssertNil(decodedJson.scenes, "Scenes should be nil when not provided");
//  XCTAssertNil(decodedJson.skins, "Skins should be nil when not provided");
//  XCTAssertNil(decodedJson.textures,
//               "Textures should be nil when not provided");
//  XCTAssertNil(decodedJson.extensions,
//               "Extensions should be nil when not provided");
//  XCTAssertNil(decodedJson.extras, "Extras should be nil when not provided");
//  XCTAssertNil(error, "Error should be nil when optional fields are missing");
//}
//
// #pragma mark - GLTFAccessor
//
//- (void)testDecodeAccessorWithAllFieldsPresentAndOptionalFields {
//  // Create a GLTFDecoder instance
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//
//  NSDictionary *jsonDict = @{
//    @"bufferView" : @1,
//    @"byteOffset" : @10,
//    @"componentType" : @5123,
//    @"normalized" : @YES,
//    @"count" : @34,
//    @"type" : @"VEC3",
//    @"max" : @[ @1, @1, @1 ],
//    @"min" : @[ @0, @0, @0 ],
//    @"sparse" : @{
//      @"count" : @3,
//      @"indices" :
//          @{@"bufferView" : @2, @"byteOffset" : @0, @"componentType" : @5125},
//      @"values" : @{@"bufferView" : @3, @"byteOffset" : @0}
//    },
//    @"name" : @"ExampleAccessor",
//    @"extensions" : @{@"someExtension" : @{@"value" : @123}},
//    @"extras" : @{@"someExtraData" : @"data"}
//  };
//  NSError *error = nil;
//
//  GLTFAccessor *accessor = [decoder decodeAccessor:jsonDict error:&error];
//
//  XCTAssertNotNil(
//      accessor,
//      "Accessor should not be nil when all required fields are present");
//  XCTAssertEqual(accessor.bufferView, @1);
//  XCTAssertEqual(accessor.byteOffsetValue, 10);
//  XCTAssertEqual(accessor.componentType, 5123);
//  XCTAssertTrue(accessor.normalized);
//  XCTAssertEqual(accessor.count, 34);
//  XCTAssertEqualObjects(accessor.type, @"VEC3");
//  XCTAssertEqualObjects(accessor.max, (@[ @1, @1, @1 ]));
//  XCTAssertEqualObjects(accessor.min, (@[ @0, @0, @0 ]));
//  XCTAssertNotNil(accessor.sparse, "Sparse should not be nil when provided");
//  XCTAssertEqualObjects(accessor.name, @"ExampleAccessor");
//  XCTAssertEqualObjects(accessor.extensions,
//                        @{@"someExtension" : @{@"value" : @123}});
//  XCTAssertEqualObjects(accessor.extras, @{@"someExtraData" : @"data"});
//  XCTAssertNil(
//      error, "Error should be nil when decoding is successful with all
//      fields");
//}
//
//- (void)testDecodeAccessorWithMissingRequiredFields {
//  // Create a GLTFDecoder instance
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//
//  NSDictionary *jsonDict = @{};
//  NSError *error = nil;
//
//  GLTFAccessor *accessor = [decoder decodeAccessor:jsonDict error:&error];
//
//  XCTAssertNil(accessor,
//               "Accessor should be nil when a required field is missing");
//  XCTAssertNotNil(error,
//                  "Error should not be nil when a required field is missing");
//  XCTAssertEqual(error.code, GLTF2DecodeErrorMissingData,
//                 "Error code should indicate missing data");
//}
//
//- (void)testDecodeAccessorWithOptionalFieldsMissing {
//  // Create a GLTFDecoder instance
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//
//  NSDictionary *jsonDict =
//      @{@"componentType" : @5121, @"count" : @34, @"type" : @"MAT4"};
//  NSError *error = nil;
//
//  GLTFAccessor *accessor = [decoder decodeAccessor:jsonDict error:&error];
//
//  XCTAssertNotNil(accessor);
//  XCTAssertEqual(accessor.componentType, 5121);
//  XCTAssertEqual(accessor.count, 34);
//  XCTAssertEqualObjects(accessor.type, @"MAT4");
//  XCTAssertNil(error, "Error should be nil when optional fields are missing");
//}
//
// #pragma mark - GLTFAccessorSparse
//
//- (void)testDecodeSparseWithAllFieldsPresent {
//  NSDictionary *jsonDict = @{
//    @"count" : @3,
//    @"indices" :
//        @{@"bufferView" : @1, @"byteOffset" : @0, @"componentType" : @5123},
//    @"values" : @{@"bufferView" : @2, @"byteOffset" : @0},
//    @"extensions" : @{@"someKey" : @"someValue"},
//    @"extras" : @{@"anotherKey" : @"anotherValue"}
//  };
//  NSError *error = nil;
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//
//  GLTFAccessorSparse *sparse = [decoder decodeAccessorSparse:jsonDict
//                                                       error:&error];
//
//  XCTAssertNotNil(sparse);
//  XCTAssertEqual(sparse.count, 3);
//  XCTAssertNotNil(sparse.indices);
//  XCTAssertNotNil(sparse.values);
//  XCTAssertEqualObjects(sparse.extensions, @{@"someKey" : @"someValue"});
//  XCTAssertEqualObjects(sparse.extras, @{@"anotherKey" : @"anotherValue"});
//  XCTAssertNil(error, "Error should be nil when decoding is successful");
//}
//
//- (void)testDecodeSparseWithMissingRequiredFields {
//  NSDictionary *jsonDict = @{
//    @"count" : @3,
//    @"indices" :
//        @{@"bufferView" : @1, @"byteOffset" : @0, @"componentType" : @5123}
//    // 'indices' field is missing
//  };
//  NSError *error = nil;
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//
//  GLTFAccessorSparse *sparse = [decoder decodeAccessorSparse:jsonDict
//                                                       error:&error];
//
//  XCTAssertNil(sparse, "Sparse should be nil when a required field is
//  missing"); XCTAssertNotNil(error,
//                  "Error should not be nil when a required field is missing");
//  XCTAssertEqual(error.code, GLTF2DecodeErrorMissingData,
//                 "Error code should indicate missing data");
//}
//
//- (void)testDecodeSparseWithOptionalFieldsMissing {
//  // Optional 'extensions' and 'extras' are missing
//  NSDictionary *jsonDict = @{
//    @"count" : @3,
//    @"indices" :
//        @{@"bufferView" : @1, @"byteOffset" : @0, @"componentType" : @5123},
//    @"values" : @{@"bufferView" : @2, @"byteOffset" : @0}
//  };
//  NSError *error = nil;
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//
//  GLTFAccessorSparse *sparse = [decoder decodeAccessorSparse:jsonDict
//                                                       error:&error];
//
//  XCTAssertNotNil(
//      sparse, "Sparse should not be nil even if optional fields are missing");
//  XCTAssertEqual(sparse.count, 3);
//  XCTAssertNotNil(sparse.indices);
//  XCTAssertNotNil(sparse.values);
//  XCTAssertNil(sparse.extensions, "Extensions should be nil when not
//  provided"); XCTAssertNil(sparse.extras, "Extras should be nil when not
//  provided"); XCTAssertNil(error, "Error should be nil when optional fields
//  are missing");
//}
//
// #pragma mark - GLTFAccessorSparseIndices
//
//- (void)testSuccessfulDecode {
//  // Sample JSON with all fields correctly set
//  NSDictionary *jsonDict = @{
//    @"bufferView" : @1,
//    @"byteOffset" : @0,
//    @"componentType" : @5123,
//    @"extensions" : @{@"someKey" : @"someValue"},
//    @"extras" : @{@"anotherKey" : @"anotherValue"}
//  };
//  NSError *error = nil;
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//
//  GLTFAccessorSparseIndices *indices =
//      [decoder decodeAccessorSparseIndices:jsonDict error:&error];
//
//  XCTAssertNotNil(indices);
//  XCTAssertEqual(indices.bufferView, 1);
//  XCTAssertEqual(indices.byteOffsetValue, 0);
//  XCTAssertEqual(indices.componentType, 5123);
//  XCTAssertEqualObjects(indices.extensions, @{@"someKey" : @"someValue"});
//  XCTAssertEqualObjects(indices.extras, @{@"anotherKey" : @"anotherValue"});
//  XCTAssertNil(error);
//}
//
//- (void)testMissingRequiredFields {
//  // Sample JSON missing the 'componentType' field
//  NSDictionary *jsonDict = @{@"bufferView" : @1};
//  NSError *error = nil;
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//
//  GLTFAccessorSparseIndices *indices =
//      [decoder decodeAccessorSparseIndices:jsonDict error:&error];
//
//  XCTAssertNil(indices);
//  XCTAssertNotNil(error);
//  XCTAssertEqual(error.code, GLTF2DecodeErrorMissingData);
//  XCTAssertTrue([error.localizedDescription
//      containsString:@"Key 'componentType' not found"]);
//}
//
//- (void)testOptionalFieldDefaults {
//  // Sample JSON without 'byteOffset'
//  NSDictionary *jsonDict = @{@"bufferView" : @1, @"componentType" : @5123};
//  NSError *error = nil;
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//
//  GLTFAccessorSparseIndices *indices =
//      [decoder decodeAccessorSparseIndices:jsonDict error:&error];
//
//  XCTAssertNotNil(indices);
//  XCTAssertEqual(indices.byteOffsetValue,
//                 0); // Confirm default value is correctly used
//  XCTAssertNil(error);
//}
//
// #pragma mark - GLTFAccessorSparseValues
//
//- (void)testDecodeSparseValuesWithAllFieldsPresent {
//  NSDictionary *jsonDict = @{
//    @"bufferView" : @5,
//    @"byteOffset" : @10,
//    @"extensions" : @{@"someKey" : @"someValue"},
//    @"extras" : @{@"anotherKey" : @"anotherValue"}
//  };
//  NSError *error = nil;
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//
//  GLTFAccessorSparseValues *values =
//      [decoder decodeAccessorSparseValues:jsonDict error:&error];
//
//  XCTAssertNotNil(
//      values, "Sparse values should not be nil when all fields are provided");
//  XCTAssertEqual(values.bufferView, 5,
//                 "Buffer view should match the provided JSON value");
//  XCTAssertEqual(values.byteOffsetValue, 10,
//                 "Byte offset should match the provided JSON value");
//  XCTAssertEqualObjects(values.extensions, @{@"someKey" : @"someValue"},
//                        "Extensions should match the provided JSON");
//  XCTAssertEqualObjects(values.extras, @{@"anotherKey" : @"anotherValue"},
//                        "Extras should match the provided JSON");
//  XCTAssertNil(error, "Error should be nil when decoding is successful");
//}
//
//- (void)testDecodeSparseValuesWithMissingRequiredField {
//  NSDictionary *jsonDict = @{
//    // 'bufferView' is omitted to simulate a missing required field
//    @"byteOffset" : @10
//  };
//  NSError *error = nil;
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//
//  GLTFAccessorSparseValues *values =
//      [decoder decodeAccessorSparseValues:jsonDict error:&error];
//
//  XCTAssertNil(values,
//               "Sparse values should be nil when required field is missing");
//  XCTAssertNotNil(error,
//                  "Error should not be nil when a required field is missing");
//  XCTAssertEqual(error.code, GLTF2DecodeErrorMissingData,
//                 "Error code should indicate missing data");
//}
//
//- (void)testDecodeSparseValuesWithOptionalFieldsMissing {
//  NSDictionary *jsonDict = @{
//    @"bufferView" : @5
//    // 'byteOffset', 'extensions', and 'extras' are omitted
//  };
//  NSError *error = nil;
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//
//  GLTFAccessorSparseValues *values =
//      [decoder decodeAccessorSparseValues:jsonDict error:&error];
//
//  XCTAssertNotNil(
//      values,
//      "Sparse values should not be nil even if optional fields are missing");
//  XCTAssertEqual(values.bufferView, 5,
//                 "Buffer view should match the provided JSON value");
//  XCTAssertEqual(values.byteOffsetValue, 0,
//                 "Byte offset should default to 0 when not provided");
//  XCTAssertNil(values.extensions, "Extensions should be nil when not
//  provided"); XCTAssertNil(values.extras, "Extras should be nil when not
//  provided"); XCTAssertNil(error, "Error should be nil when optional fields
//  are missing");
//}
//
// #pragma mark - GLTFAnimation
//
//- (void)testDecodeAnimationWithAllFieldsPresent {
//  NSDictionary *jsonDict = @{
//    @"channels" : @[
//      @{@"sampler" : @0, @"target" : @{@"node" : @1, @"path" :
//      @"translation"}}
//    ],
//    @"samplers" : @[ @{@"input" : @1, @"output" : @2} ],
//    @"name" : @"Walk",
//    @"extensions" : @{@"customExtension" : @{}},
//    @"extras" : @{@"customData" : @"data"}
//  };
//  NSError *error = nil;
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//
//  GLTFAnimation *animation = [decoder decodeAnimation:jsonDict error:&error];
//
//  XCTAssertNotNil(animation);
//  XCTAssertEqual(animation.channels.count, 1);
//  XCTAssertEqual(animation.samplers.count, 1);
//  XCTAssertEqualObjects(animation.name, @"Walk");
//  XCTAssertNotNil(animation.extensions);
//  XCTAssertNotNil(animation.extras);
//  XCTAssertNil(error);
//}
//
//- (void)testDecodeAnimationWithMissingRequiredFields {
//  NSDictionary *jsonDict = @{
//      // Missing 'channels' and 'samplers'
//  };
//  NSError *error = nil;
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//
//  GLTFAnimation *animation = [decoder decodeAnimation:jsonDict error:&error];
//
//  XCTAssertNil(animation);
//  XCTAssertNotNil(error);
//  XCTAssertEqual(error.code, GLTF2DecodeErrorMissingData);
//}
//
//- (void)testDecodeAnimationWithOptionalFieldsMissing {
//  NSDictionary *jsonDict = @{
//    @"channels" : @[
//      @{@"sampler" : @0, @"target" : @{@"node" : @1, @"path" :
//      @"translation"}}
//    ],
//    @"samplers" : @[ @{@"input" : @1, @"output" : @2} ]
//    // Missing 'name', 'extensions', and 'extras'
//  };
//  NSError *error = nil;
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//
//  GLTFAnimation *animation = [decoder decodeAnimation:jsonDict error:&error];
//
//  XCTAssertNotNil(animation);
//  XCTAssertNil(animation.name);
//  XCTAssertNil(animation.extensions);
//  XCTAssertNil(animation.extras);
//  XCTAssertNil(error);
//}
//
// #pragma mark - GLTFAnimationChannel
//
//- (void)testDecodeAnimationChannelWithAllFieldsPresent {
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//  NSDictionary *jsonDict = @{
//    @"sampler" : @0,
//    @"target" : @{@"node" : @1, @"path" : @"rotation"},
//    @"extensions" : @{@"extensionData" : @{}},
//    @"extras" : @{@"extraData" : @{}}
//  };
//  NSError *error = nil;
//
//  GLTFAnimationChannel *channel = [decoder decodeAnimationChannel:jsonDict
//                                                            error:&error];
//
//  XCTAssertNotNil(channel,
//                  "Channel should not be nil when all fields are present");
//  XCTAssertEqual(channel.sampler, 0,
//                 "Sampler index should be correctly decoded");
//  XCTAssertNotNil(channel.target, "Target should not be nil");
//  XCTAssertEqualObjects(channel.target.node, @1,
//                        "Node should be correctly decoded");
//  XCTAssertEqualObjects(channel.target.path, @"rotation",
//                        "Path should be correctly decoded");
//  XCTAssertNotNil(channel.extensions, "Extensions should be present");
//  XCTAssertNotNil(channel.extras, "Extras should be present");
//  XCTAssertNil(
//      error, "Error should be nil when decoding is successful with all
//      fields");
//}
//
//- (void)testDecodeAnimationChannelWithMissingRequiredFields {
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//  NSDictionary *jsonDict = @{}; // Empty dictionary to simulate missing fields
//  NSError *error = nil;
//
//  GLTFAnimationChannel *channel = [decoder decodeAnimationChannel:jsonDict
//                                                            error:&error];
//
//  XCTAssertNil(channel,
//               "Channel should be nil when required fields are missing");
//  XCTAssertNotNil(error,
//                  "Error should not be nil when required fields are missing");
//  XCTAssertEqual(error.code, GLTF2DecodeErrorMissingData,
//                 "Error code should indicate missing required fields");
//}
//
//- (void)testDecodeAnimationChannelWithOptionalFieldsMissing {
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//  NSDictionary *jsonDict = @{
//    @"sampler" : @0,
//    @"target" : @{@"node" : @1, @"path" : @"rotation"}
//    // 'extensions' and 'extras' are omitted
//  };
//  NSError *error = nil;
//
//  GLTFAnimationChannel *channel = [decoder decodeAnimationChannel:jsonDict
//                                                            error:&error];
//
//  XCTAssertNotNil(
//      channel, "Channel should not be nil even if optional fields are
//      missing");
//  XCTAssertNil(channel.extensions,
//               "Extensions should be nil when not provided");
//  XCTAssertNil(channel.extras, "Extras should be nil when not provided");
//  XCTAssertNil(error, "Error should be nil when optional fields are missing");
//}
//
// #pragma mark - GLTFAnimationChannelTarget
//
//- (void)testDecodeAnimationChannelTargetWithAllFieldsPresent {
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//  NSDictionary *jsonDict = @{
//    @"node" : @10,
//    @"path" : @"translation",
//    @"extensions" : @{@"customExtension" : @{@"param" : @"value"}},
//    @"extras" : @{@"info" : @"extra data"}
//  };
//  NSError *error = nil;
//
//  GLTFAnimationChannelTarget *target =
//      [decoder decodeAnimationChannelTarget:jsonDict error:&error];
//
//  XCTAssertNotNil(target,
//                  "Target should not be nil when all fields are present");
//  XCTAssertEqualObjects(target.node, @10, "Node should be correctly decoded");
//  XCTAssertEqualObjects(target.path, @"translation",
//                        "Path should be correctly decoded");
//  XCTAssertEqualObjects(target.extensions,
//                        @{@"customExtension" : @{@"param" : @"value"}},
//                        "Extensions should be correctly decoded");
//  XCTAssertEqualObjects(target.extras, @{@"info" : @"extra data"},
//                        "Extras should be correctly decoded");
//  XCTAssertNil(error, "Error should be nil when all fields are provided");
//}
//
//- (void)testDecodeAnimationChannelTargetWithMissingRequiredPath {
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//  NSDictionary *jsonDict = @{};
//  NSError *error = nil;
//
//  GLTFAnimationChannelTarget *target =
//      [decoder decodeAnimationChannelTarget:jsonDict error:&error];
//
//  XCTAssertNil(
//      target, "Target should be nil when the required field 'path' is
//      missing");
//  XCTAssertNotNil(
//      error,
//      "Error should not be nil when the required field 'path' is missing");
//  XCTAssertEqual(
//      error.code, GLTF2DecodeErrorMissingData,
//      "Error code should indicate missing data due to lack of required
//      field");
//}
//
//- (void)testDecodeAnimationChannelTargetWithOptionalFieldsMissing {
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//  NSDictionary *jsonDict = @{@"path" : @"rotation"};
//  NSError *error = nil;
//
//  GLTFAnimationChannelTarget *target =
//      [decoder decodeAnimationChannelTarget:jsonDict error:&error];
//
//  XCTAssertNotNil(
//      target, "Target should not be nil even if optional fields are missing");
//  XCTAssertNil(target.node, "Node should be nil when not provided");
//  XCTAssertEqualObjects(target.path, @"rotation",
//                        "Path should be correctly decoded");
//  XCTAssertNil(target.extensions, "Extensions should be nil when not
//  provided"); XCTAssertNil(target.extras, "Extras should be nil when not
//  provided"); XCTAssertNil(error, "Error should be nil when optional fields
//  are missing");
//}
//
// #pragma mark - GLTFAnimationSampler
//
//- (void)testDecodeAnimationSamplerWithAllFieldsPresent {
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//  NSDictionary *jsonDict = @{
//    @"input" : @0,
//    @"interpolation" : @"CUBICSPLINE",
//    @"output" : @1,
//    @"extensions" : @{@"extensionData" : @{}},
//    @"extras" : @{@"extraData" : @{}}
//  };
//  NSError *error = nil;
//
//  GLTFAnimationSampler *sampler = [decoder decodeAnimationSampler:jsonDict
//                                                            error:&error];
//
//  XCTAssertNotNil(sampler,
//                  "Sampler should not be nil when all fields are present");
//  XCTAssertEqual(sampler.input, 0, "Input index should be correctly decoded");
//  XCTAssertEqualObjects(
//      sampler.interpolation, @"CUBICSPLINE",
//      "Interpolation should be correctly decoded as 'CUBICSPLINE'");
//  XCTAssertEqual(sampler.output, 1, "Output index should be correctly
//  decoded"); XCTAssertNotNil(sampler.extensions, "Extensions should be
//  present"); XCTAssertNotNil(sampler.extras, "Extras should be present");
//  XCTAssertNil(
//      error, "Error should be nil when decoding is successful with all
//      fields");
//}
//
//- (void)testDecodeAnimationSamplerWithMissingRequiredFields {
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//  NSDictionary *jsonDict = @{
//    // 'input' is missing
//    @"output" : @1,
//    @"interpolation" : @"LINEAR"
//  };
//  NSError *error = nil;
//
//  GLTFAnimationSampler *sampler = [decoder decodeAnimationSampler:jsonDict
//                                                            error:&error];
//
//  XCTAssertNil(sampler,
//               "Sampler should be nil when required fields are missing");
//  XCTAssertNotNil(error,
//                  "Error should not be nil when required fields are missing");
//  XCTAssertEqual(error.code, GLTF2DecodeErrorMissingData,
//                 "Error code should indicate missing required fields");
//}
//
//- (void)testDecodeAnimationSamplerWithDefaultInterpolation {
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//  NSDictionary *jsonDict = @{
//    @"input" : @0,
//    @"output" : @1
//    // 'interpolation' is missing
//  };
//  NSError *error = nil;
//
//  GLTFAnimationSampler *sampler = [decoder decodeAnimationSampler:jsonDict
//                                                            error:&error];
//
//  XCTAssertNotNil(
//      sampler, "Sampler should not be nil even if 'interpolation' is
//      missing");
//  XCTAssertEqualObjects(
//      sampler.interpolationValue, @"LINEAR",
//      "Interpolation should default to 'LINEAR' when not provided");
//  XCTAssertNil(error, "Error should be nil when optional fields are missing");
//}
//
//- (void)testDecodeAnimationSamplerWithOptionalFieldsMissing {
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//  NSDictionary *jsonDict = @{
//    @"input" : @0,
//    @"interpolation" : @"LINEAR",
//    @"output" : @1
//    // 'extensions' and 'extras' are omitted
//  };
//  NSError *error = nil;
//
//  GLTFAnimationSampler *sampler = [decoder decodeAnimationSampler:jsonDict
//                                                            error:&error];
//
//  XCTAssertNotNil(
//      sampler, "Sampler should not be nil even if optional fields are
//      missing");
//  XCTAssertNil(sampler.extensions,
//               "Extensions should be nil when not provided");
//  XCTAssertNil(sampler.extras, "Extras should be nil when not provided");
//  XCTAssertNil(error, "Error should be nil when optional fields are missing");
//}
//
// #pragma mark - GLTFAsset
//
//- (void)testDecodeAssetWithAllFieldsPresent {
//  NSDictionary *jsonDict = @{
//    @"version" : @"2.0",
//    @"copyright" : @"Copyright 2021 by Example Co.",
//    @"generator" : @"ExampleGenerator 1.0",
//    @"minVersion" : @"1.0",
//    @"extensions" : @{@"someExtension" : @{@"value" : @123}},
//    @"extras" : @{@"someExtraInfo" : @"value"}
//  };
//  NSError *error = nil;
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//
//  GLTFAsset *asset = [decoder decodeAsset:jsonDict error:&error];
//
//  XCTAssertNotNil(asset, "Asset should not be nil when all fields are
//  present"); XCTAssertEqualObjects(asset.version, @"2.0",
//                        "Version should be correctly decoded");
//  XCTAssertEqualObjects(asset.copyright, @"Copyright 2021 by Example Co.",
//                        "Copyright should be correctly decoded");
//  XCTAssertEqualObjects(asset.generator, @"ExampleGenerator 1.0",
//                        "Generator should be correctly decoded");
//  XCTAssertEqualObjects(asset.minVersion, @"1.0",
//                        "MinVersion should be correctly decoded");
//  XCTAssertNotNil(asset.extensions, "Extensions should be present");
//  XCTAssertNotNil(asset.extras, "Extras should be present");
//  XCTAssertNil(
//      error, "Error should be nil when decoding is successful with all
//      fields");
//}
//
//- (void)testDecodeAssetWithMissingRequiredField {
//  NSDictionary *jsonDict = @{
//    // 'version' is missing
//    @"copyright" : @"Copyright 2021 by Example Co.",
//    @"generator" : @"ExampleGenerator 1.0"
//  };
//  NSError *error = nil;
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//
//  GLTFAsset *asset = [decoder decodeAsset:jsonDict error:&error];
//
//  XCTAssertNil(asset,
//               "Asset should be nil when required field 'version' is
//               missing");
//  XCTAssertNotNil(
//      error,
//      "Error should not be nil when required field 'version' is missing");
//  XCTAssertEqual(error.code, GLTF2DecodeErrorMissingData,
//                 "Error code should indicate missing required fields");
//}
//
//- (void)testDecodeAssetWithOptionalFieldsMissing {
//  NSDictionary *jsonDict = @{
//    @"version" : @"2.0"
//    // Optional fields are missing
//  };
//  NSError *error = nil;
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//
//  GLTFAsset *asset = [decoder decodeAsset:jsonDict error:&error];
//
//  XCTAssertNotNil(
//      asset, "Asset should not be nil even if optional fields are missing");
//  XCTAssertEqualObjects(asset.version, @"2.0",
//                        "Version should be correctly decoded");
//  XCTAssertNil(asset.copyright, "Copyright should be nil when not provided");
//  XCTAssertNil(asset.generator, "Generator should be nil when not provided");
//  XCTAssertNil(asset.minVersion, "MinVersion should be nil when not
//  provided"); XCTAssertNil(asset.extensions, "Extensions should be nil when
//  not provided"); XCTAssertNil(asset.extras, "Extras should be nil when not
//  provided"); XCTAssertNil(error, "Error should be nil when optional fields
//  are missing");
//}
//
// #pragma mark - GLTFBuffer
//
//- (void)testDecodeBufferWithAllFieldsPresent {
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//  NSDictionary *jsonDict = @{
//    @"byteLength" : @1024,
//    @"uri" : @"http://example.com/buffer.bin",
//    @"name" : @"ExampleBuffer",
//    @"extensions" : @{@"customExtension" : @{@"key" : @"value"}},
//    @"extras" : @{@"info" : @"data"}
//  };
//  NSError *error = nil;
//
//  GLTFBuffer *buffer = [decoder decodeBuffer:jsonDict error:&error];
//
//  XCTAssertNotNil(buffer,
//                  "Buffer should not be nil when all fields are present");
//  XCTAssertEqual(buffer.byteLength, 1024,
//                 "Byte length should be correctly decoded");
//  XCTAssertEqualObjects(buffer.uri, @"http://example.com/buffer.bin",
//                        "URI should be correctly decoded");
//  XCTAssertEqualObjects(buffer.name, @"ExampleBuffer",
//                        "Name should be correctly decoded");
//  XCTAssertNotNil(buffer.extensions, "Extensions should be correctly parsed");
//  XCTAssertNotNil(buffer.extras, "Extras should be correctly parsed");
//  XCTAssertNil(error,
//               "Error should be nil when all fields are correctly provided");
//}
//
//- (void)testDecodeBufferWithMissingRequiredFields {
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//  NSDictionary *jsonDict = @{}; // Missing 'byteLength'
//  NSError *error = nil;
//
//  GLTFBuffer *buffer = [decoder decodeBuffer:jsonDict error:&error];
//
//  XCTAssertNil(buffer, "Buffer should be nil when required fields are
//  missing"); XCTAssertNotNil(
//      error,
//      "Error should be present when required field 'byteLength' is missing");
//}
//
//- (void)testDecodeBufferWithOptionalFieldsMissing {
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//  NSDictionary *jsonDict = @{
//    @"byteLength" : @2048 // Only the required field
//  };
//  NSError *error = nil;
//
//  GLTFBuffer *buffer = [decoder decodeBuffer:jsonDict error:&error];
//
//  XCTAssertNotNil(
//      buffer, "Buffer should not be nil even if optional fields are missing");
//  XCTAssertEqual(buffer.byteLength, 2048,
//                 "Byte length should still be correctly decoded");
//  XCTAssertNil(buffer.uri, "URI should be nil when not provided");
//  XCTAssertNil(buffer.name, "Name should be nil when not provided");
//  XCTAssertNil(buffer.extensions, "Extensions should be nil when not
//  provided"); XCTAssertNil(buffer.extras, "Extras should be nil when not
//  provided"); XCTAssertNil(error,
//               "Error should be nil when only optional fields are missing");
//}
//
// #pragma mark - GLTFBufferView
//
//- (void)testDecodeBufferViewWithAllFieldsPresent {
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//  NSDictionary *jsonDict = @{
//    @"buffer" : @1,
//    @"byteLength" : @1024,
//    @"byteOffset" : @256,
//    @"byteStride" : @16,
//    @"target" : @34962,
//    @"name" : @"TestBufferView"
//  };
//  NSError *error = nil;
//
//  GLTFBufferView *bufferView = [decoder decodeBufferView:jsonDict
//  error:&error];
//
//  XCTAssertNotNil(bufferView,
//                  "BufferView should not be nil when all fields are present");
//  XCTAssertEqual(bufferView.buffer, 1);
//  XCTAssertEqual(bufferView.byteLength, 1024);
//  XCTAssertEqual(bufferView.byteOffsetValue, 256);
//  XCTAssertEqual(bufferView.byteStride.integerValue, 16);
//  XCTAssertEqual(bufferView.target.integerValue, 34962);
//  XCTAssertEqualObjects(bufferView.name, @"TestBufferView");
//  XCTAssertNil(error, "Error should be nil when all fields are valid");
//}
//
//- (void)testDecodeBufferViewWithMissingRequiredFields {
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//  NSDictionary *jsonDict = @{};
//  NSError *error = nil;
//
//  GLTFBufferView *bufferView = [decoder decodeBufferView:jsonDict
//  error:&error];
//
//  XCTAssertNil(bufferView,
//               "BufferView should be nil when required fields are missing");
//  XCTAssertNotNil(error,
//                  "Error should be present when required fields are missing");
//}
//
// #pragma mark - GLTFCamera
//
//- (void)testDecodeCameraWithAllFieldsPresent {
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//  NSDictionary *jsonDict = @{
//    @"type" : @"perspective",
//    @"perspective" : @{@"yfov" : @1.5, @"znear" : @0.1},
//    @"name" : @"TestCamera"
//  };
//  NSError *error = nil;
//
//  GLTFCamera *camera = [decoder decodeCamera:jsonDict error:&error];
//
//  XCTAssertNotNil(camera,
//                  "Camera should not be nil when all fields are present");
//  XCTAssertEqualObjects(camera.type, @"perspective");
//  XCTAssertNotNil(camera.perspective);
//  XCTAssertEqualObjects(camera.name, @"TestCamera");
//  XCTAssertNil(error, "Error should be nil when all fields are valid");
//}
//
//- (void)testDecodeCameraWithMissingRequiredFields {
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//  NSDictionary *jsonDict = @{}; // Missing 'type'
//  NSError *error = nil;
//
//  GLTFCamera *camera = [decoder decodeCamera:jsonDict error:&error];
//
//  XCTAssertNil(camera, "Camera should be nil when required fields are
//  missing"); XCTAssertNotNil(error,
//                  "Error should be present when required fields are missing");
//}
//
// #pragma mark - GLTFCameraOrthographic
//
//- (void)testDecodeCameraOrthographicWithAllFieldsPresent {
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//  NSDictionary *jsonDict =
//      @{@"xmag" : @1.0, @"ymag" : @1.0, @"zfar" : @100.0, @"znear" : @0.1};
//  NSError *error = nil;
//
//  GLTFCameraOrthographic *cameraOrtho =
//      [decoder decodeCameraOrthographic:jsonDict error:&error];
//
//  XCTAssertNotNil(
//      cameraOrtho,
//      "CameraOrthographic should not be nil when all fields are present");
//  XCTAssertEqualWithAccuracy(
//      cameraOrtho.xmag, 1.0, 0.001,
//      "xmag should be as expected with a small tolerance");
//  XCTAssertEqualWithAccuracy(
//      cameraOrtho.ymag, 1.0, 0.001,
//      "ymag should be as expected with a small tolerance");
//  XCTAssertEqualWithAccuracy(
//      cameraOrtho.zfar, 100.0, 0.001,
//      "zfar should be as expected with a small tolerance");
//  XCTAssertEqualWithAccuracy(
//      cameraOrtho.znear, 0.1, 0.001,
//      "znear should be as expected with a small tolerance");
//  XCTAssertNil(error,
//               "Error should be nil when all fields are present and valid");
//}
//
//- (void)testDecodeCameraOrthographicWithMissingRequiredFields {
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//  NSDictionary *jsonDict = @{}; // Missing 'xmag', 'ymag', 'zfar', 'znear'
//  NSError *error = nil;
//
//  GLTFCameraOrthographic *cameraOrtho =
//      [decoder decodeCameraOrthographic:jsonDict error:&error];
//
//  XCTAssertNil(
//      cameraOrtho,
//      "CameraOrthographic should be nil when required fields are missing");
//  XCTAssertNotNil(error,
//                  "Error should be present when required fields are missing");
//}
//
// #pragma mark - GLTFCameraPerspective
//
//- (void)testDecodeCameraPerspectiveWithAllFieldsPresent {
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//  NSDictionary *jsonDict = @{
//    @"yfov" : @1.5,
//    @"znear" : @0.1,
//    @"aspectRatio" : @1.77,
//    @"zfar" : @100.0
//  };
//  NSError *error = nil;
//
//  GLTFCameraPerspective *camera = [decoder decodeCameraPerspective:jsonDict
//                                                             error:&error];
//
//  XCTAssertNotNil(camera, "Camera perspective should not be nil");
//  XCTAssertEqualWithAccuracy(
//      camera.yfov, 1.5, 0.001,
//      "yfov should be as expected with a small tolerance");
//  XCTAssertEqualWithAccuracy(
//      camera.znear, 0.1, 0.001,
//      "znear should be as expected with a small tolerance");
//  XCTAssertEqualWithAccuracy(
//      camera.aspectRatio.floatValue, 1.77, 0.001,
//      "aspectRatio should be as expected with a small tolerance");
//  XCTAssertEqualWithAccuracy(
//      camera.zfar.floatValue, 100.0, 0.001,
//      "zfar should be as expected with a small tolerance");
//  XCTAssertNil(error,
//               "Error should be nil when all fields are present and valid");
//}
//
//- (void)testDecodeCameraPerspectiveWithMissingRequiredFields {
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//  NSDictionary *jsonDict = @{}; // Missing 'yfov' and 'znear'
//  NSError *error = nil;
//
//  GLTFCameraPerspective *camera = [decoder decodeCameraPerspective:jsonDict
//                                                             error:&error];
//
//  XCTAssertNil(
//      camera,
//      "Camera perspective should be nil when required fields are missing");
//  XCTAssertNotNil(error,
//                  "Error should be generated when required fields are
//                  missing");
//}
//
// #pragma mark - GLTFImage
//
//- (void)testDecodeImageWithAllFieldsPresent {
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//  NSDictionary *jsonDict = @{
//    @"uri" : @"http://example.com/image.png",
//    @"mimeType" : @"image/png",
//    @"bufferView" : @2,
//    @"name" : @"ExampleImage"
//  };
//
//  GLTFImage *image = [decoder decodeImage:jsonDict];
//
//  XCTAssertNotNil(image, "Image should not be nil when all fields are
//  present"); XCTAssertEqualObjects(image.uri,
//  @"http://example.com/image.png"); XCTAssertEqualObjects(image.mimeType,
//  @"image/png"); XCTAssertEqualObjects(image.bufferView, @2);
//  XCTAssertEqualObjects(image.name, @"ExampleImage");
//}
//
//- (void)testDecodeImageWithOptionalFieldsMissing {
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//  NSDictionary *jsonDict = @{}; // No optional fields provided
//
//  GLTFImage *image = [decoder decodeImage:jsonDict];
//
//  XCTAssertNotNil(
//      image, "Image should not be nil even if optional fields are missing");
//  XCTAssertNil(image.uri);
//  XCTAssertNil(image.mimeType);
//  XCTAssertNil(image.bufferView);
//  XCTAssertNil(image.name);
//}
//
// #pragma mark - GLTFMaterial
//
//- (void)testDecodeMaterialWithAllFieldsPresent {
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//  NSDictionary *jsonDict = @{
//    @"name" : @"TestMaterial",
//    @"pbrMetallicRoughness" : @{
//      @"baseColorFactor" : @[ @0.5, @0.5, @0.5, @1.0 ],
//      @"baseColorTexture" : @{@"index" : @0},
//      @"metallicFactor" : @1.0,
//      @"roughnessFactor" : @0.5,
//      @"metallicRoughnessTexture" : @{@"index" : @1}
//    },
//    @"normalTexture" : @{@"index" : @2, @"scale" : @1.0},
//    @"occlusionTexture" : @{@"index" : @3, @"strength" : @0.5},
//    @"emissiveTexture" : @{@"index" : @4},
//    @"emissiveFactor" : @[ @1.0, @0.0, @0.0 ],
//    @"alphaMode" : @"BLEND",
//    @"alphaCutoff" : @0.5,
//    @"doubleSided" : @YES
//  };
//  NSError *error = nil;
//
//  GLTFMaterial *material = [decoder decodeMaterial:jsonDict error:&error];
//
//  XCTAssertNotNil(material,
//                  "Material should not be nil when all fields are present");
//  XCTAssertEqualObjects(material.name, @"TestMaterial");
//
//  // PBR Metallic Roughness
//  XCTAssertNotNil(material.pbrMetallicRoughness,
//                  "PBR Metallic Roughness should not be nil");
//  XCTAssertEqual(material.pbrMetallicRoughness.baseColorFactorValue[0], 0.5);
//  XCTAssertEqual(material.pbrMetallicRoughness.baseColorFactorValue[1], 0.5);
//  XCTAssertEqual(material.pbrMetallicRoughness.baseColorFactorValue[2], 0.5);
//  XCTAssertEqual(material.pbrMetallicRoughness.baseColorFactorValue[3], 1.0);
//  XCTAssertNotNil(material.pbrMetallicRoughness.baseColorTexture);
//  XCTAssertEqual(material.pbrMetallicRoughness.metallicFactorValue, 1.0);
//  XCTAssertEqual(material.pbrMetallicRoughness.roughnessFactorValue, 0.5);
//  XCTAssertNotNil(material.pbrMetallicRoughness.metallicRoughnessTexture);
//
//  // Normal Texture
//  XCTAssertNotNil(material.normalTexture, "Normal Texture should not be nil");
//  XCTAssertEqual(material.normalTexture.index, 2);
//  XCTAssertEqual(material.normalTexture.scaleValue, 1.0);
//
//  // Occlusion Texture
//  XCTAssertNotNil(material.occlusionTexture,
//                  "Occlusion Texture should not be nil");
//  XCTAssertEqual(material.occlusionTexture.index, 3);
//  XCTAssertEqual(material.occlusionTexture.strengthValue, 0.5);
//
//  // Emissive Texture
//  XCTAssertNotNil(material.emissiveTexture,
//                  "Emissive Texture should not be nil");
//  XCTAssertEqual(material.emissiveTexture.index, 4);
//
//  // Other properties
//  XCTAssertEqualObjects(material.emissiveFactor, (@[ @1.0, @0.0, @0.0 ]));
//  XCTAssertEqualObjects(material.alphaMode, @"BLEND");
//  XCTAssertEqual(material.alphaCutoffValue, 0.5);
//  XCTAssertTrue(material.isDoubleSided);
//  XCTAssertNil(error,
//               "Error should be nil when all fields are provided and valid");
//}
//
//- (void)testDecodeMaterialWithMissingOptionalFields {
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//  NSDictionary *jsonDict = @{}; // No fields provided
//
//  NSError *error = nil;
//  GLTFMaterial *material = [decoder decodeMaterial:jsonDict error:&error];
//
//  XCTAssertNotNil(material,
//                  "Material should not be nil even if all fields are
//                  missing");
//  XCTAssertNil(material.name);
//  XCTAssertNil(material.pbrMetallicRoughness);
//  XCTAssertNil(material.normalTexture);
//  XCTAssertNil(material.occlusionTexture);
//  XCTAssertNil(material.emissiveTexture);
//  XCTAssertEqual(material.emissiveFactorValue[0], 0);
//  XCTAssertEqual(material.emissiveFactorValue[1], 0);
//  XCTAssertEqual(material.emissiveFactorValue[2], 0);
//  XCTAssertEqualObjects(material.alphaModeValue, @"OPAQUE");
//  XCTAssertEqual(material.alphaCutoffValue, 0.5);
//  XCTAssertNil(material.isDoubleSided);
//  XCTAssertNil(error, "Error should be nil when optional fields are missing");
//}
//
// #pragma mark - GLTFMaterialNormalTextureInfo
//
//- (void)testDecodeMaterialNormalTextureInfoWithAllFieldsPresent {
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//  NSDictionary *jsonDict = @{
//    @"index" : @1,
//    @"texCoord" : @2,
//    @"scale" : @1.5,
//    @"extensions" : @{@"someExtension" : @{}},
//    @"extras" : @{@"someExtra" : @"data"}
//  };
//  NSError *error = nil;
//
//  GLTFMaterialNormalTextureInfo *textureInfo =
//      [decoder decodeMaterialNormalTextureInfo:jsonDict error:&error];
//
//  XCTAssertNotNil(textureInfo,
//                  "TextureInfo should not be nil when all fields are
//                  present");
//  XCTAssertEqual(textureInfo.index, 1);
//  XCTAssertEqual(textureInfo.texCoordValue, 2);
//  XCTAssertEqual(textureInfo.scaleValue, 1.5);
//  XCTAssertNotNil(textureInfo.extensions);
//  XCTAssertNotNil(textureInfo.extras);
//  XCTAssertNil(error);
//}
//
//- (void)testDecodeMaterialNormalTextureInfoWithMissingRequiredFields {
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//  NSDictionary *jsonDict = @{  // Missing 'index'
//        @"texCoord": @2,
//        @"scale": @1.5
//    };
//  NSError *error = nil;
//
//  GLTFMaterialNormalTextureInfo *textureInfo =
//      [decoder decodeMaterialNormalTextureInfo:jsonDict error:&error];
//
//  XCTAssertNil(
//      textureInfo,
//      "TextureInfo should be nil when required 'index' field is missing");
//  XCTAssertNotNil(
//      error, "Error should not be nil when required field 'index' is
//      missing");
//}
//
// #pragma mark - GLTFMaterialOcclusionTextureInfo
//
//- (void)testDecodeMaterialOcclusionTextureInfoWithAllFieldsPresent {
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//  NSDictionary *jsonDict = @{
//    @"index" : @1,
//    @"texCoord" : @2,
//    @"strength" : @0.8,
//    @"extensions" : @{@"extension" : @{}},
//    @"extras" : @{@"extra" : @"info"}
//  };
//  NSError *error = nil;
//
//  GLTFMaterialOcclusionTextureInfo *textureInfo =
//      [decoder decodeMaterialOcclusionTextureInfo:jsonDict error:&error];
//
//  XCTAssertNotNil(textureInfo,
//                  "TextureInfo should not be nil when all fields are
//                  present");
//  XCTAssertEqual(textureInfo.index, 1);
//  XCTAssertEqual(textureInfo.texCoordValue, 2);
//  XCTAssertEqualWithAccuracy(textureInfo.strengthValue, 0.8, 0.001,
//                             "Strength should be approximately 0.8");
//  XCTAssertNotNil(textureInfo.extensions);
//  XCTAssertNotNil(textureInfo.extras);
//  XCTAssertNil(error);
//}
//
//- (void)testDecodeMaterialOcclusionTextureInfoWithMissingRequiredFields {
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//  NSDictionary *jsonDict = @{  // Missing 'index'
//        @"strength": @0.8
//    };
//  NSError *error = nil;
//
//  GLTFMaterialOcclusionTextureInfo *textureInfo =
//      [decoder decodeMaterialOcclusionTextureInfo:jsonDict error:&error];
//
//  XCTAssertNil(
//      textureInfo,
//      "TextureInfo should be nil when required 'index' field is missing");
//  XCTAssertNotNil(
//      error, "Error should not be nil when required field 'index' is
//      missing");
//}
//
// #pragma mark - GLTFMaterialPBRMetallicRoughness
//
//- (void)testDecodeMaterialPBRMetallicRoughnessWithAllFieldsPresent {
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//  NSDictionary *jsonDict = @{
//    @"baseColorFactor" : @[ @1.0, @0.5, @0.5, @1.0 ],
//    @"baseColorTexture" : @{@"index" : @1},
//    @"metallicFactor" : @0.5,
//    @"roughnessFactor" : @0.5,
//    @"metallicRoughnessTexture" : @{@"index" : @2},
//    @"extensions" : @{@"extension" : @{}},
//    @"extras" : @{@"extra" : @"info"}
//  };
//  NSError *error = nil;
//
//  GLTFMaterialPBRMetallicRoughness *roughness =
//      [decoder decodeMaterialPBRMetallicRoughness:jsonDict error:&error];
//
//  XCTAssertNotNil(
//      roughness,
//      "PBRMetallicRoughness should not be nil when all fields are present");
//  XCTAssertEqualObjects(roughness.baseColorFactor,
//                        (@[ @1.0, @0.5, @0.5, @1.0 ]));
//  XCTAssertNotNil(roughness.baseColorTexture);
//  XCTAssertEqual(roughness.metallicFactorValue, 0.5);
//  XCTAssertEqual(roughness.roughnessFactorValue, 0.5);
//  XCTAssertNotNil(roughness.metallicRoughnessTexture);
//  XCTAssertNotNil(roughness.extensions);
//  XCTAssertNotNil(roughness.extras);
//  XCTAssertNil(error);
//}
//
//- (void)testDecodeMaterialPBRMetallicRoughnessWithMissingOptionalFields {
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//  NSDictionary *jsonDict = @{}; // All optional fields missing
//  NSError *error = nil;
//
//  GLTFMaterialPBRMetallicRoughness *roughness =
//      [decoder decodeMaterialPBRMetallicRoughness:jsonDict error:&error];
//
//  XCTAssertNotNil(roughness, "PBRMetallicRoughness should not be nil even if "
//                             "optional fields are missing");
//  XCTAssertEqual(roughness.baseColorFactorValue[0], 1);
//  XCTAssertEqual(roughness.baseColorFactorValue[1], 1);
//  XCTAssertEqual(roughness.baseColorFactorValue[2], 1);
//  XCTAssertEqual(roughness.baseColorFactorValue[3], 1);
//  XCTAssertNil(roughness.baseColorTexture);
//  XCTAssertEqual(roughness.metallicFactorValue, 1);
//  XCTAssertEqual(roughness.roughnessFactorValue, 1);
//  XCTAssertNil(roughness.metallicRoughnessTexture);
//  XCTAssertNil(roughness.extensions);
//  XCTAssertNil(roughness.extras);
//  XCTAssertNil(error);
//}
//
// #pragma mark - GLTFMesh
//
//- (void)testDecodeMeshWithAllFieldsPresent {
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//  NSDictionary *jsonDict = @{
//    @"primitives" : @[ @{@"attributes" : @{@"POSITION" : @0}} ],
//    @"weights" : @[ @1.0, @0.5 ],
//    @"name" : @"ExampleMesh",
//    @"extensions" : @{@"extensionData" : @{}},
//    @"extras" : @{@"extraData" : @"data"}
//  };
//  NSError *error = nil;
//
//  GLTFMesh *mesh = [decoder decodeMesh:jsonDict error:&error];
//
//  XCTAssertNotNil(mesh, "Mesh should not be nil when all fields are present");
//  XCTAssertEqual(mesh.primitives.count, 1, "There should be one primitive");
//  XCTAssertEqualObjects(mesh.weights, (@[ @1.0, @0.5 ]),
//                        "Weights should be correctly decoded");
//  XCTAssertEqualObjects(mesh.name, @"ExampleMesh",
//                        "Name should be correctly decoded");
//  XCTAssertNotNil(mesh.extensions, "Extensions should be present");
//  XCTAssertNotNil(mesh.extras, "Extras should be present");
//  XCTAssertNil(
//      error, "Error should be nil when decoding is successful with all
//      fields");
//}
//
//- (void)testDecodeMeshWithMissingRequiredFields {
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//  NSDictionary *jsonDict = @{}; // Missing 'primitives', which is required
//  NSError *error = nil;
//
//  GLTFMesh *mesh = [decoder decodeMesh:jsonDict error:&error];
//
//  XCTAssertNil(mesh, "Mesh should be nil when required fields are missing");
//  XCTAssertNotNil(
//      error,
//      "Error should not be nil when required field 'primitives' is missing");
//}
//
// #pragma mark - GLTFMeshPrimitive
//
//- (void)testDecodeMeshPrimitiveWithAllFieldsPresent {
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//  NSDictionary *jsonDict = @{
//    @"attributes" : @{@"POSITION" : @0, @"TEXCOORD_0" : @1, @"TEXCOORD_1" :
//    @2},
//    @"indices" : @1,
//    @"material" : @2,
//    @"mode" : @3,
//    @"targets" : @[ @{@"POSITION" : @4} ],
//    @"extensions" : @{@"extensionData" : @{}},
//    @"extras" : @{@"extraData" : @"data"}
//  };
//  NSError *error = nil;
//
//  GLTFMeshPrimitive *primitive = [decoder decodeMeshPrimitive:jsonDict
//                                                        error:&error];
//
//  XCTAssertNotNil(
//      primitive, "MeshPrimitive should not be nil when all fields are
//      present");
//  NSDictionary *attributes =
//      @{@"POSITION" : @0, @"TEXCOORD_0" : @1, @"TEXCOORD_1" : @2};
//  XCTAssertNotNil(primitive.attributes.position);
//  XCTAssertEqual(primitive.attributes.position.integerValue, 0);
//  XCTAssertNotNil(primitive.attributes.texcoord);
//  XCTAssertEqual(primitive.attributes.texcoord[0], @1);
//  XCTAssertEqual(primitive.attributes.texcoord[1], @2);
//  XCTAssertEqualObjects(primitive.indices, @1,
//                        "Indices should be correctly decoded");
//  XCTAssertEqualObjects(primitive.material, @2,
//                        "Material should be correctly decoded");
//  XCTAssertEqual(primitive.modeValue, 3, "Mode should be correctly decoded");
//  XCTAssertNotNil(primitive.targets);
//  XCTAssertEqual(primitive.targets.count, 1);
//  XCTAssertEqual(primitive.targets[0].position, @4);
//  XCTAssertNotNil(primitive.extensions, "Extensions should be present");
//  XCTAssertNotNil(primitive.extras, "Extras should be present");
//  XCTAssertNil(
//      error, "Error should be nil when decoding is successful with all
//      fields");
//}
//
//- (void)testDecodeMeshPrimitiveWithMissingRequiredFields {
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//  NSDictionary *jsonDict = @{}; // Missing 'attributes', which is required
//  NSError *error = nil;
//
//  GLTFMeshPrimitive *primitive = [decoder decodeMeshPrimitive:jsonDict
//                                                        error:&error];
//
//  XCTAssertNil(primitive,
//               "MeshPrimitive should be nil when required fields are
//               missing");
//  XCTAssertNotNil(
//      error,
//      "Error should not be nil when required field 'attributes' is missing");
//}
//
// #pragma mark - GLTFNode
//
//- (void)testDecodeNodeWithNonDefaultValues {
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//  NSDictionary *jsonDict = @{
//    @"camera" : @1,
//    @"children" : @[ @2, @3 ],
//    @"skin" : @4,
//    @"matrix" :
//        @[ @0, @1, @0, @0, @1, @0, @0, @0, @0, @0, @0, @1, @1, @1, @1, @0 ],
//    @"mesh" : @5,
//    @"rotation" : @[ @1, @0, @0, @0 ],   // Non-default quaternion
//    @"scale" : @[ @2, @2, @2 ],          // Non-default scale factors
//    @"translation" : @[ @10, @20, @30 ], // Non-default translation values
//    @"weights" : @[ @0.75, @0.25 ],      // Different weights
//    @"name" : @"NodeA",
//    @"extensions" : @{@"someExtension" : @{@"key" : @"value"}},
//    @"extras" : @{@"someExtra" : @"data"}
//  };
//
//  GLTFNode *node = [decoder decodeNode:jsonDict];
//
//  XCTAssertEqualObjects(node.camera, @1);
//  XCTAssertEqualObjects(node.children, (@[ @2, @3 ]));
//  XCTAssertEqualObjects(node.skin, @4);
//  XCTAssertTrue(node.matrixValue.columns[0].x == 0 &&
//                    node.matrixValue.columns[1].x == 1,
//                "Matrix should be set as provided");
//  XCTAssertEqualObjects(node.mesh, @5);
//  XCTAssertEqualObjects(node.rotation, (@[ @1, @0, @0, @0 ]),
//                        "Rotation should be set as provided");
//  XCTAssertEqualObjects(node.scale, (@[ @2, @2, @2 ]),
//                        "Scale should be set as provided");
//  XCTAssertEqualObjects(node.translation, (@[ @10, @20, @30 ]),
//                        "Translation should be set as provided");
//  XCTAssertEqualObjects(node.weights, (@[ @0.75, @0.25 ]),
//                        "Weights should be set as provided");
//  XCTAssertEqualObjects(node.name, @"NodeA");
//  XCTAssertNotNil(node.extensions);
//  XCTAssertNotNil(node.extras);
//}
//
//- (void)testDecodeNodeWithOptionalFieldsMissing {
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//  NSDictionary *jsonDict = @{}; // No optional fields provided
//
//  GLTFNode *node = [decoder decodeNode:jsonDict];
//
//  XCTAssertNil(node.camera);
//  XCTAssertNil(node.children);
//  XCTAssertNil(node.skin);
//  XCTAssertTrue([self isIdentityMatrix:node.matrixValue],
//                "Matrix should be identity by default");
//  XCTAssertNil(node.mesh);
//  XCTAssertEqual(node.rotationValue.vector[0], 0);
//  XCTAssertEqual(node.rotationValue.vector[1], 0);
//  XCTAssertEqual(node.rotationValue.vector[2], 0);
//  XCTAssertEqual(node.rotationValue.vector[3], 1);
//  XCTAssertEqual(node.scaleValue[0], 1);
//  XCTAssertEqual(node.scaleValue[1], 1);
//  XCTAssertEqual(node.scaleValue[2], 1);
//  XCTAssertEqual(node.translationValue[0], 0);
//  XCTAssertEqual(node.translationValue[1], 0);
//  XCTAssertEqual(node.translationValue[2], 0);
//  XCTAssertNil(node.weights);
//  XCTAssertNil(node.name);
//  XCTAssertNil(node.extensions);
//  XCTAssertNil(node.extras);
//}
//
//// Helper method to check if a matrix is the identity matrix
//- (BOOL)isIdentityMatrix:(simd_float4x4)matrix {
//  simd_float4x4 identity = matrix_identity_float4x4;
//  for (int i = 0; i < 4; i++) {
//    for (int j = 0; j < 4; j++) {
//      if (matrix.columns[i][j] != identity.columns[i][j]) {
//        return NO;
//      }
//    }
//  }
//  return YES;
//}
//
// #pragma mark - GLTFSampler
//
//- (void)testDecodeSamplerWithAllFieldsPresent {
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//  NSDictionary *jsonDict = @{
//    @"magFilter" : @9729,
//    @"minFilter" : @9986,
//    @"wrapS" : @10497,
//    @"wrapT" : @33071,
//    @"name" : @"DefaultSampler",
//    @"extensions" : @{@"someExtension" : @{@"param" : @"value"}},
//    @"extras" : @{@"info" : @"extra data"}
//  };
//  GLTFSampler *sampler = [decoder decodeSampler:jsonDict];
//
//  XCTAssertEqualObjects(sampler.magFilter, @9729,
//                        "MagFilter should be correctly decoded");
//  XCTAssertEqualObjects(sampler.minFilter, @9986,
//                        "MinFilter should be correctly decoded");
//  XCTAssertEqual(sampler.wrapSValue, 10497,
//                 "WrapS should be correctly decoded");
//  XCTAssertEqual(sampler.wrapTValue, 33071,
//                 "WrapT should be correctly decoded");
//  XCTAssertEqualObjects(sampler.name, @"DefaultSampler",
//                        "Name should be correctly decoded");
//  XCTAssertNotNil(sampler.extensions, "Extensions should be correctly
//  decoded"); XCTAssertNotNil(sampler.extras, "Extras should be correctly
//  decoded");
//}
//
//- (void)testDecodeSamplerWithDefaultValues {
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//  NSDictionary *jsonDict =
//      @{}; // No fields provided, default values should be used
//
//  GLTFSampler *sampler = [decoder decodeSampler:jsonDict];
//
//  XCTAssertNil(sampler.magFilter, "MagFilter should be nil when not
//  provided"); XCTAssertNil(sampler.minFilter, "MinFilter should be nil when
//  not provided"); XCTAssertEqual(sampler.wrapSValue, 10497,
//                 "WrapS should default to 10497 when not provided");
//  XCTAssertEqual(sampler.wrapTValue, 10497,
//                 "WrapT should default to 10497 when not provided");
//  XCTAssertNil(sampler.name, "Name should be nil when not provided");
//  XCTAssertNil(sampler.extensions,
//               "Extensions should be nil when not provided");
//  XCTAssertNil(sampler.extras, "Extras should be nil when not provided");
//}
//
// #pragma mark - GLTFScene
//
//- (void)testDecodeSceneWithAllFieldsPresent {
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//  NSDictionary *jsonDict = @{
//    @"nodes" : @[ @1, @2, @3 ],
//    @"name" : @"MainScene",
//    @"extensions" : @{@"someExtension" : @{@"param" : @"value"}},
//    @"extras" : @{@"info" : @"extra data"}
//  };
//
//  GLTFScene *scene = [decoder decodeScene:jsonDict];
//
//  XCTAssertEqualObjects(scene.nodes, (@[ @1, @2, @3 ]),
//                        "Nodes should be correctly decoded");
//  XCTAssertEqualObjects(scene.name, @"MainScene",
//                        "Name should be correctly decoded");
//  XCTAssertNotNil(scene.extensions, "Extensions should be correctly decoded");
//  XCTAssertNotNil(scene.extras, "Extras should be correctly decoded");
//}
//
//- (void)testDecodeSceneWithOptionalFieldsMissing {
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//  NSDictionary *jsonDict = @{}; // No fields provided
//
//  GLTFScene *scene = [decoder decodeScene:jsonDict];
//
//  XCTAssertNil(scene.nodes, "Nodes should be nil when not provided");
//  XCTAssertNil(scene.name, "Name should be nil when not provided");
//  XCTAssertNil(scene.extensions, "Extensions should be nil when not
//  provided"); XCTAssertNil(scene.extras, "Extras should be nil when not
//  provided");
//}
//
// #pragma mark - GLTFSkin
//
//- (void)testDecodeSkinWithAllFieldsPresent {
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//  NSDictionary *jsonDict = @{
//    @"joints" : @[ @1, @2, @3 ],
//    @"inverseBindMatrices" : @5,
//    @"skeleton" : @10,
//    @"name" : @"TestSkin",
//    @"extensions" : @{@"someExtension" : @{@"key" : @"value"}},
//    @"extras" : @{@"someExtra" : @"data"}
//  };
//  NSError *error = nil;
//
//  GLTFSkin *skin = [decoder decodeSkin:jsonDict error:&error];
//
//  XCTAssertNotNil(skin, "Skin should not be nil when all fields are present");
//  XCTAssertEqualObjects(skin.joints, (@[ @1, @2, @3 ]),
//                        "Joints should be correctly decoded");
//  XCTAssertEqualObjects(skin.inverseBindMatrices, @5,
//                        "InverseBindMatrices should be correctly decoded");
//  XCTAssertEqualObjects(skin.skeleton, @10,
//                        "Skeleton should be correctly decoded");
//  XCTAssertEqualObjects(skin.name, @"TestSkin",
//                        "Name should be correctly decoded");
//  XCTAssertEqualObjects(skin.extensions,
//                        @{@"someExtension" : @{@"key" : @"value"}},
//                        "Extensions should be correctly decoded");
//  XCTAssertEqualObjects(skin.extras, @{@"someExtra" : @"data"},
//                        "Extras should be correctly decoded");
//  XCTAssertNil(
//      error, "Error should be nil when decoding is successful with all
//      fields");
//}
//
//- (void)testDecodeSkinWithMissingRequiredFields {
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//  NSDictionary *jsonDict = @{  // Missing 'joints', which is required
//        @"inverseBindMatrices": @5,
//        @"name": @"TestSkin"
//    };
//  NSError *error = nil;
//
//  GLTFSkin *skin = [decoder decodeSkin:jsonDict error:&error];
//
//  XCTAssertNil(skin,
//               "Skin should be nil when required 'joints' field is missing");
//  XCTAssertNotNil(
//      error, "Error should not be nil when required field 'joints' is
//      missing");
//}
//
//- (void)testDecodeSkinWithOptionalFieldsMissing {
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//  NSDictionary *jsonDict = @{
//    @"joints" : @[
//      @1, @2, @3
//    ] // Optional fields 'inverseBindMatrices', 'skeleton', 'name' are missing
//  };
//  NSError *error = nil;
//
//  GLTFSkin *skin = [decoder decodeSkin:jsonDict error:&error];
//
//  XCTAssertNotNil(skin,
//                  "Skin should not be nil even if optional fields are
//                  missing");
//  XCTAssertEqualObjects(skin.joints, (@[ @1, @2, @3 ]),
//                        "Joints should be correctly decoded");
//  XCTAssertNil(skin.inverseBindMatrices,
//               "InverseBindMatrices should be nil when not provided");
//  XCTAssertNil(skin.skeleton, "Skeleton should be nil when not provided");
//  XCTAssertNil(skin.name, "Name should be nil when not provided");
//  XCTAssertNil(skin.extensions, "Extensions should be nil when not provided");
//  XCTAssertNil(skin.extras, "Extras should be nil when not provided");
//  XCTAssertNil(error, "Error should be nil when optional fields are missing");
//}
//
// #pragma mark - GLTFTexture
//
//- (void)testDecodeTextureWithAllFieldsPresent {
//  NSDictionary *jsonDict = @{
//    @"sampler" : @1,
//    @"source" : @2,
//    @"name" : @"ExampleTexture",
//    @"extensions" : @{@"extensionKey" : @"extensionValue"},
//    @"extras" : @{@"extraKey" : @"extraValue"}
//  };
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//
//  GLTFTexture *texture = [decoder decodeTexture:jsonDict];
//
//  XCTAssertEqualObjects(texture.sampler, @1,
//                        "Sampler should be correctly decoded");
//  XCTAssertEqualObjects(texture.source, @2,
//                        "Source should be correctly decoded");
//  XCTAssertEqualObjects(texture.name, @"ExampleTexture",
//                        "Name should be correctly decoded");
//  XCTAssertEqualObjects(texture.extensions,
//                        @{@"extensionKey" : @"extensionValue"},
//                        "Extensions should be correctly decoded");
//  XCTAssertEqualObjects(texture.extras, @{@"extraKey" : @"extraValue"},
//                        "Extras should be correctly decoded");
//}
//
//- (void)testDecodeTextureWithOptionalFieldsMissing {
//  NSDictionary *jsonDict = @{}; // Empty dictionary to simulate missing fields
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//
//  GLTFTexture *texture = [decoder decodeTexture:jsonDict];
//
//  XCTAssertNil(texture.sampler, "Sampler should be nil when not provided");
//  XCTAssertNil(texture.source, "Source should be nil when not provided");
//  XCTAssertNil(texture.name, "Name should be nil when not provided");
//  XCTAssertNil(texture.extensions,
//               "Extensions should be nil when not provided");
//  XCTAssertNil(texture.extras, "Extras should be nil when not provided");
//}
//
//- (void)testDecodeTextureWithIncorrectTypes {
//  NSDictionary *jsonDict = @{
//    @"sampler" : @"incorrectType",
//    @"source" : @"alsoIncorrect",
//    @"name" : @123,      // Incorrect type, should be a string
//    @"extensions" : @[], // Incorrect type, should be a dictionary
//    @"extras" : @123     // Incorrect type, should be a dictionary
//  };
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//
//  GLTFTexture *texture = [decoder decodeTexture:jsonDict];
//
//  XCTAssertNil(texture.sampler,
//               "Sampler should be nil when the type is incorrect");
//  XCTAssertNil(texture.source,
//               "Source should be nil when the type is incorrect");
//  XCTAssertNil(texture.name, "Name should be nil when the type is incorrect");
//  XCTAssertNil(texture.extensions,
//               "Extensions should be nil when the type is incorrect");
//  XCTAssertNil(texture.extras,
//               "Extras should be nil when the type is incorrect");
//}
//
// #pragma mark - GLTFTextureInfo
//
//- (void)testDecodeTextureInfoWithAllFieldsPresent {
//  NSDictionary *jsonDict = @{
//    @"index" : @2,
//    @"texCoord" : @1,
//    @"extensions" : @{@"someExtension" : @{@"param" : @"value"}},
//    @"extras" : @{@"someData" : @"data"}
//  };
//  NSError *error = nil;
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//
//  GLTFTextureInfo *textureInfo = [decoder decodeTextureInfo:jsonDict
//                                                      error:&error];
//
//  XCTAssertNotNil(textureInfo,
//                  "TextureInfo should not be nil when all fields are
//                  present");
//  XCTAssertEqual(textureInfo.index, 2, "Index should be correctly decoded");
//  XCTAssertEqual(textureInfo.texCoordValue, 1,
//                 "TexCoord should be correctly decoded");
//  XCTAssertNotNil(textureInfo.extensions,
//                  "Extensions should be correctly decoded");
//  XCTAssertNotNil(textureInfo.extras, "Extras should be correctly decoded");
//  XCTAssertNil(
//      error, "Error should be nil when decoding is successful with all
//      fields");
//}
//
//- (void)testDecodeTextureInfoWithMissingRequiredField {
//  NSDictionary *jsonDict = @{ // Missing 'index'
//        @"texCoord": @1
//    };
//  NSError *error = nil;
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//
//  GLTFTextureInfo *textureInfo = [decoder decodeTextureInfo:jsonDict
//                                                      error:&error];
//
//  XCTAssertNil(
//      textureInfo,
//      "TextureInfo should be nil when required 'index' field is missing");
//  XCTAssertNotNil(
//      error, "Error should not be nil when required field 'index' is
//      missing");
//}
//
//- (void)testDecodeTextureInfoWithOptionalFieldsMissing {
//  NSDictionary *jsonDict = @{
//    @"index" : @2 // Optional 'texCoord', 'extensions', and 'extras' are
//    missing
//  };
//  NSError *error = nil;
//  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
//
//  GLTFTextureInfo *textureInfo = [decoder decodeTextureInfo:jsonDict
//                                                      error:&error];
//
//  XCTAssertNotNil(
//      textureInfo,
//      "TextureInfo should not be nil even if optional fields are missing");
//  XCTAssertEqual(textureInfo.index, 2, "Index should be correctly decoded");
//  XCTAssertEqual(textureInfo.texCoordValue, 0,
//                 "TexCoord should default to 0 when not provided");
//  XCTAssertNil(textureInfo.extensions,
//               "Extensions should be nil when not provided");
//  XCTAssertNil(textureInfo.extras, "Extras should be nil when not provided");
//  XCTAssertNil(error, "Error should be nil when optional fields are missing");
//}

@end
