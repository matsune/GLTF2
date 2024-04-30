#import "GLTFMaterialNormalTextureInfo.h"
#import "GLTFMaterialOcclusionTextureInfo.h"
#import "GLTFMaterialPBRMetallicRoughness.h"
#import "GLTFTextureInfo.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const GLTFMaterialAlphaModeOpaque;
extern NSString *const GLTFMaterialAlphaModeMask;
extern NSString *const GLTFMaterialAlphaModeBlend;

@interface GLTFMaterial : NSObject

@property(nonatomic, copy, nullable) NSString *name;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;
@property(nonatomic, strong, nullable)
    GLTFMaterialPBRMetallicRoughness *pbrMetallicRoughness;
@property(nonatomic, strong, nullable)
    GLTFMaterialNormalTextureInfo *normalTexture;
@property(nonatomic, strong, nullable)
    GLTFMaterialOcclusionTextureInfo *occlusionTexture;
@property(nonatomic, strong, nullable) GLTFTextureInfo *emissiveTexture;
@property(nonatomic, strong) NSArray<NSNumber *> *emissiveFactor;
@property(nonatomic, copy) NSString *alphaMode;
@property(nonatomic, assign) float alphaCutoff;
@property(nonatomic, assign) BOOL doubleSided;

@end

NS_ASSUME_NONNULL_END
