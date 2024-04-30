#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, GLTFJSONMeshPrimitiveMode) {
  GLTFJSONMeshPrimitiveModePoints = 0,
  GLTFJSONMeshPrimitiveModeLines = 1,
  GLTFJSONMeshPrimitiveModeLineLoop = 2,
  GLTFJSONMeshPrimitiveModeLineStrip = 3,
  GLTFJSONMeshPrimitiveModeTriangles = 4,
  GLTFJSONMeshPrimitiveModeTriangleStrip = 5,
  GLTFJSONMeshPrimitiveModeTriangleFan = 6
};

@interface GLTFJSONMeshPrimitive : NSObject

@property(nonatomic, strong) NSDictionary<NSString *, NSNumber *> *attributes;
@property(nonatomic, strong, nullable) NSNumber *indices;
@property(nonatomic, strong, nullable) NSNumber *material;
@property(nonatomic, assign) NSInteger mode;
@property(nonatomic, strong, nullable) NSArray<NSNumber *> *targets;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

NS_ASSUME_NONNULL_END
