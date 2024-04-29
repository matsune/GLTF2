#import "GLTFTextureInfo.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GLTFMaterialPBRMetallicRoughness : NSObject

@property(nonatomic, strong) NSArray<NSNumber *> *baseColorFactor;
@property(nonatomic, strong, nullable) GLTFTextureInfo *baseColorTexture;
@property(nonatomic, assign) float metallicFactor;
@property(nonatomic, assign) float roughnessFactor;
@property(nonatomic, strong, nullable)
    GLTFTextureInfo *metallicRoughnessTexture;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

NS_ASSUME_NONNULL_END
