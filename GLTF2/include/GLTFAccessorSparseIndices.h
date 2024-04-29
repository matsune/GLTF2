#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, GLTFAccessorSparseIndicesComponentType) {
  GLTFAccessorSparseIndicesComponentTypeUnsignedByte = 5121,
  GLTFAccessorSparseIndicesComponentTypeUnsignedShort = 5123,
  GLTFAccessorSparseIndicesComponentTypeUnsignedInt = 5125
};

BOOL isValidGLTFAccessorSparseIndicesComponentType(NSUInteger value);

@interface GLTFAccessorSparseIndices : NSObject

@property(nonatomic, assign) NSUInteger bufferView;
@property(nonatomic, assign) NSUInteger byteOffset;
@property(nonatomic, assign)
    GLTFAccessorSparseIndicesComponentType componentType;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

NS_ASSUME_NONNULL_END
