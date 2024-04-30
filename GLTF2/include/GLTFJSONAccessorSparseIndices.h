#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, GLTFJSONAccessorSparseIndicesComponentType) {
  GLTFJSONAccessorSparseIndicesComponentTypeUnsignedByte = 5121,
  GLTFJSONAccessorSparseIndicesComponentTypeUnsignedShort = 5123,
  GLTFJSONAccessorSparseIndicesComponentTypeUnsignedInt = 5125
};

@interface GLTFJSONAccessorSparseIndices : NSObject

@property(nonatomic, assign) NSInteger bufferView;
@property(nonatomic, assign) NSInteger byteOffset;
@property(nonatomic, assign) NSInteger componentType;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

NS_ASSUME_NONNULL_END
