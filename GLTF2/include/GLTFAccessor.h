#import "GLTFAccessorSparse.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, GLTFAccessorComponentType) {
  GLTFAccessorComponentTypeByte = 5120,
  GLTFAccessorComponentTypeUnsignedByte = 5121,
  GLTFAccessorComponentTypeShort = 5122,
  GLTFAccessorComponentTypeUnsignedShort = 5123,
  GLTFAccessorComponentTypeUnsignedInt = 5125,
  GLTFAccessorComponentTypeFloat = 5126
};

BOOL isValidGLTFAccessorComponentType(NSUInteger value);

typedef NS_ENUM(NSUInteger, GLTFAccessorType) {
  GLTFAccessorTypeScalar,
  GLTFAccessorTypeVec2,
  GLTFAccessorTypeVec3,
  GLTFAccessorTypeVec4,
  GLTFAccessorTypeMat2,
  GLTFAccessorTypeMat3,
  GLTFAccessorTypeMat4
};

NSUInteger GLTFAccessorTypeFromString(NSString *typeString);

@interface GLTFAccessor : NSObject

@property(nonatomic, assign) NSUInteger bufferView;
@property(nonatomic, assign) NSUInteger byteOffset;
@property(nonatomic, assign) GLTFAccessorComponentType componentType;
@property(nonatomic, assign) BOOL normalized;
@property(nonatomic, assign) NSUInteger count;
@property(nonatomic, assign) GLTFAccessorType type;
@property(nonatomic, strong, nullable) NSArray<NSNumber *> *max;
@property(nonatomic, strong, nullable) NSArray<NSNumber *> *min;
@property(nonatomic, strong, nullable) GLTFAccessorSparse *sparse;
@property(nonatomic, copy, nullable) NSString *name;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

NS_ASSUME_NONNULL_END
