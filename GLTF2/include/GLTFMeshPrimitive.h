#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//typedef NS_ENUM(NSInteger, GLTFPrimitiveMode) {
//  GLTFPrimitiveModePoints,
//  GLTFPrimitiveModeLines,
//  GLTFPrimitiveModeLineLoop,
//  GLTFPrimitiveModeLineStrip,
//  GLTFPrimitiveModeTriangles,
//  GLTFPrimitiveModeTriangleStrip,
//  GLTFPrimitiveModeTriangleFan
//};
//
//NSInteger GLTFPrimitiveModeFromString(NSString *modeString);
typedef NS_ENUM(NSInteger, GLTFMeshPrimitiveMode) {
    GLTFMeshPrimitiveModePoints = 0,
    GLTFMeshPrimitiveModeLines = 1,
    GLTFMeshPrimitiveModeLineLoop = 2,
    GLTFMeshPrimitiveModeLineStrip = 3,
    GLTFMeshPrimitiveModeTriangles = 4,
    GLTFMeshPrimitiveModeTriangleStrip = 5,
    GLTFMeshPrimitiveModeTriangleFan = 6
};

@interface GLTFMeshPrimitive : NSObject

@property(nonatomic, strong) NSDictionary<NSString *, NSNumber *> *attributes;
@property(nonatomic, strong, nullable) NSNumber *indices;
@property(nonatomic, strong, nullable) NSNumber *material;
@property(nonatomic, assign) NSInteger mode;
@property(nonatomic, strong, nullable) NSArray<NSNumber *> *targets;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

NS_ASSUME_NONNULL_END
