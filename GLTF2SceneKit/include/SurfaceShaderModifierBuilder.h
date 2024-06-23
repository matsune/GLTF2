#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SurfaceShaderModifierBuilder : NSObject

@property(nonatomic, assign) BOOL transparent;
@property(nonatomic, assign) BOOL hasBaseColorTexture;
@property(nonatomic, assign) BOOL enableDiffuseAlphaCutoff;
@property(nonatomic, assign) BOOL isDiffuseOpaque;
@property(nonatomic, assign) BOOL enableAnisotropy;
@property(nonatomic, assign) BOOL hasAnisotropyTexture;
@property(nonatomic, assign) BOOL enableSheen;
@property(nonatomic, assign) BOOL hasSheenColorTexture;
@property(nonatomic, assign) BOOL hasSheenRoughnessTexture;

- (NSString *)buildShader;

@end

NS_ASSUME_NONNULL_END
