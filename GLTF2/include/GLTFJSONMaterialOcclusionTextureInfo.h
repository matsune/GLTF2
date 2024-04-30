#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GLTFJSONMaterialOcclusionTextureInfo : NSObject

@property(nonatomic, assign) NSInteger index;
@property(nonatomic, assign) NSInteger texCoord;
@property(nonatomic, assign) float strength;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

NS_ASSUME_NONNULL_END
