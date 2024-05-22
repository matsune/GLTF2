#import "Errors.h"
#import "GLTFBinary.h"
#import <XCTest/XCTest.h>

@interface GLTFBinaryTests : XCTestCase

@end

@implementation GLTFBinaryTests

//- (void)testInvalidBinarySize {
//  char invalidSizeData[] = {'g', 'l', 'T'};
//  NSData *data = [NSData dataWithBytes:invalidSizeData
//                                length:sizeof(invalidSizeData)];
//  NSError *error = nil;
//
//  GLTFBinary *binary = [GLTFBinary binaryWithData:data error:&error];
//
//  XCTAssertNil(binary, "Binary object should be nil for invalid size");
//  XCTAssertNotNil(error, "Error should be set for invalid binary size");
//  XCTAssertEqual(error.code, GLTF2BinaryErrorInvalidFormat,
//                 "Error code should match invalid format");
//}

@end
