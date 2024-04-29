#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, GLTFPrimitiveMode) {
  GLTFPrimitiveModePoints,
  GLTFPrimitiveModeLines,
  GLTFPrimitiveModeLineLoop,
  GLTFPrimitiveModeLineStrip,
  GLTFPrimitiveModeTriangles,
  GLTFPrimitiveModeTriangleStrip,
  GLTFPrimitiveModeTriangleFan
};

NSUInteger GLTFPrimitiveModeFromString(NSString *modeString);

@interface GLTFMeshPrimitive : NSObject

@property(nonatomic, strong) NSDictionary<NSString *, NSNumber *> *attributes;
@property(nonatomic, assign) NSUInteger indices;
@property(nonatomic, assign) NSUInteger material;
@property(nonatomic, assign) GLTFPrimitiveMode mode;
@property(nonatomic, strong) NSArray<NSNumber *> *targets;
@property(nonatomic, strong) NSDictionary *extensions;
@property(nonatomic, strong) NSDictionary *extras;

@end

NS_ASSUME_NONNULL_END
