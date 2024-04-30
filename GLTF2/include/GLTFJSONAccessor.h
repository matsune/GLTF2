#import "GLTFJSONAccessorSparse.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, GLTFJSONAccessorComponentType) {
  GLTFJSONAccessorComponentTypeByte = 5120,
  GLTFJSONAccessorComponentTypeUnsignedByte = 5121,
  GLTFJSONAccessorComponentTypeShort = 5122,
  GLTFJSONAccessorComponentTypeUnsignedShort = 5123,
  GLTFJSONAccessorComponentTypeUnsignedInt = 5125,
  GLTFJSONAccessorComponentTypeFloat = 5126
};

extern NSString *const GLTFJSONAccessorTypeScalar;
extern NSString *const GLTFJSONAccessorTypeVec2;
extern NSString *const GLTFJSONAccessorTypeVec3;
extern NSString *const GLTFJSONAccessorTypeVec4;
extern NSString *const GLTFJSONAccessorTypeMat2;
extern NSString *const GLTFJSONAccessorTypeMat3;
extern NSString *const GLTFJSONAccessorTypeMat4;

@interface GLTFJSONAccessor : NSObject

@property(nonatomic, strong, nullable) NSNumber *bufferView;
@property(nonatomic, assign) NSInteger byteOffset;
@property(nonatomic, assign) NSInteger componentType;
@property(nonatomic, assign) BOOL normalized;
@property(nonatomic, assign) NSInteger count;
@property(nonatomic, assign) NSString *type;
@property(nonatomic, strong, nullable) NSArray<NSNumber *> *max;
@property(nonatomic, strong, nullable) NSArray<NSNumber *> *min;
@property(nonatomic, strong, nullable) GLTFJSONAccessorSparse *sparse;
@property(nonatomic, copy, nullable) NSString *name;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

NS_ASSUME_NONNULL_END
