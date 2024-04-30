#import "GLTFJSONMaterialNormalTextureInfo.h"
#import "GLTFJSONMaterialOcclusionTextureInfo.h"
#import "GLTFJSONMaterialPBRMetallicRoughness.h"
#import "GLTFJSONTextureInfo.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const GLTFJSONMaterialAlphaModeOpaque;
extern NSString *const GLTFJSONMaterialAlphaModeMask;
extern NSString *const GLTFJSONMaterialAlphaModeBlend;

@interface GLTFJSONMaterial : NSObject

@property(nonatomic, copy, nullable) NSString *name;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;
@property(nonatomic, strong, nullable)
    GLTFJSONMaterialPBRMetallicRoughness *pbrMetallicRoughness;
@property(nonatomic, strong, nullable)
    GLTFJSONMaterialNormalTextureInfo *normalTexture;
@property(nonatomic, strong, nullable)
    GLTFJSONMaterialOcclusionTextureInfo *occlusionTexture;
@property(nonatomic, strong, nullable) GLTFJSONTextureInfo *emissiveTexture;
@property(nonatomic, strong) NSArray<NSNumber *> *emissiveFactor;
@property(nonatomic, copy) NSString *alphaMode;
@property(nonatomic, assign) float alphaCutoff;
@property(nonatomic, assign) BOOL doubleSided;

@end

NS_ASSUME_NONNULL_END
