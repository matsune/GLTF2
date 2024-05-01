#import "GLTFJSONAccessor.h"
#import "GLTFJSONAnimation.h"
#import "GLTFJSONAsset.h"
#import "GLTFJSONBuffer.h"
#import "GLTFJSONBufferView.h"
#import "GLTFJSONCamera.h"
#import "GLTFJSONImage.h"
#import "GLTFJSONMaterial.h"
#import "GLTFJSONMesh.h"
#import "GLTFJSONNode.h"
#import "GLTFJSONSampler.h"
#import "GLTFJSONScene.h"
#import "GLTFJSONSkin.h"
#import "GLTFJSONTexture.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GLTFJson : NSObject

@property(nonatomic, copy, nullable) NSArray<NSString *> *extensionsUsed;
@property(nonatomic, copy, nullable) NSArray<NSString *> *extensionsRequired;
@property(nonatomic, strong, nullable) NSArray<GLTFJSONAccessor *> *accessors;
@property(nonatomic, strong) GLTFJSONAsset *asset;
@property(nonatomic, strong, nullable) NSArray<GLTFJSONAnimation *> *animations;
@property(nonatomic, strong, nullable) NSArray<GLTFJSONBuffer *> *buffers;
@property(nonatomic, strong, nullable)
    NSArray<GLTFJSONBufferView *> *bufferViews;
@property(nonatomic, strong, nullable) NSArray<GLTFJSONCamera *> *cameras;
@property(nonatomic, strong, nullable) NSArray<GLTFJSONImage *> *images;
@property(nonatomic, strong, nullable) NSArray<GLTFJSONMaterial *> *materials;
@property(nonatomic, strong, nullable) NSArray<GLTFJSONMesh *> *meshes;
@property(nonatomic, strong, nullable) NSArray<GLTFJSONNode *> *nodes;
@property(nonatomic, strong, nullable) NSArray<GLTFJSONSampler *> *samplers;
@property(nonatomic, strong, nullable) NSNumber *scene;
@property(nonatomic, strong, nullable) NSArray<GLTFJSONScene *> *scenes;
@property(nonatomic, strong, nullable) NSArray<GLTFJSONSkin *> *skins;
@property(nonatomic, strong, nullable) NSArray<GLTFJSONTexture *> *textures;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

NS_ASSUME_NONNULL_END
