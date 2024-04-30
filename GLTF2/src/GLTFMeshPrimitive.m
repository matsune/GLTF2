#import "GLTFMeshPrimitive.h"

//NSInteger GLTFPrimitiveModeFromString(NSString *modeString) {
//  if ([modeString isEqualToString:@"POINTS"]) {
//    return GLTFPrimitiveModePoints;
//  } else if ([modeString isEqualToString:@"LINES"]) {
//    return GLTFPrimitiveModeLines;
//  } else if ([modeString isEqualToString:@"LINE_LOOP"]) {
//    return GLTFPrimitiveModeLineLoop;
//  } else if ([modeString isEqualToString:@"LINE_STRIP"]) {
//    return GLTFPrimitiveModeLineStrip;
//  } else if ([modeString isEqualToString:@"TRIANGLES"]) {
//    return GLTFPrimitiveModeTriangles;
//  } else if ([modeString isEqualToString:@"TRIANGLE_STRIP"]) {
//    return GLTFPrimitiveModeTriangleStrip;
//  } else if ([modeString isEqualToString:@"TRIANGLE_FAN"]) {
//    return GLTFPrimitiveModeTriangleFan;
//  } else {
//    return NSNotFound;
//  }
//}

@implementation GLTFMeshPrimitive

- (instancetype)init
{
    self = [super init];
    if (self) {
        _mode = GLTFMeshPrimitiveModeTriangles;
    }
    return self;
}

@end
