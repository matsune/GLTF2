#import "GLTFAccessorSparse.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, GLTFAccessorComponentType) {
  GLTFAccessorComponentTypeByte = 5120,
  GLTFAccessorComponentTypeUnsignedByte = 5121,
  GLTFAccessorComponentTypeShort = 5122,
  GLTFAccessorComponentTypeUnsignedShort = 5123,
  GLTFAccessorComponentTypeUnsignedInt = 5125,
  GLTFAccessorComponentTypeFloat = 5126
};

extern NSString *const GLTFAccessorTypeScalar;
extern NSString *const GLTFAccessorTypeVec2;
extern NSString *const GLTFAccessorTypeVec3;
extern NSString *const GLTFAccessorTypeVec4;
extern NSString *const GLTFAccessorTypeMat2;
extern NSString *const GLTFAccessorTypeMat3;
extern NSString *const GLTFAccessorTypeMat4;

@interface GLTFAccessor : NSObject

@property(nonatomic, strong, nullable) NSNumber *bufferView;
@property(nonatomic, assign) NSInteger byteOffset;
@property(nonatomic, assign) NSInteger componentType;
@property(nonatomic, assign) BOOL normalized;
@property(nonatomic, assign) NSInteger count;
@property(nonatomic, assign) NSInteger type;
@property(nonatomic, strong, nullable) NSArray<NSNumber *> *max;
@property(nonatomic, strong, nullable) NSArray<NSNumber *> *min;
@property(nonatomic, strong, nullable) GLTFAccessorSparse *sparse;
@property(nonatomic, copy, nullable) NSString *name;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

NS_ASSUME_NONNULL_END
