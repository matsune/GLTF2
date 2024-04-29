#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GLTFMaterialOcclusionTextureInfo : NSObject

@property(nonatomic, assign) NSUInteger index;
@property(nonatomic, assign) NSUInteger texCoord;
@property(nonatomic, assign) float strength;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

NS_ASSUME_NONNULL_END
