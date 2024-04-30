#import "GLTFAccessor.h"
#import "GLTFAnimation.h"
#import "GLTFAsset.h"
#import "GLTFBuffer.h"
#import "GLTFBufferView.h"
#import "GLTFCamera.h"
#import "GLTFImage.h"
#import "GLTFMaterial.h"
#import "GLTFMesh.h"
#import "GLTFNode.h"
#import "GLTFSampler.h"
#import "GLTFScene.h"
#import "GLTFSkin.h"
#import "GLTFTexture.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GLTFJson : NSObject

@property(nonatomic, copy, nullable) NSArray<NSString *> *extensionsUsed;
@property(nonatomic, copy, nullable) NSArray<NSString *> *extensionsRequired;
@property(nonatomic, strong, nullable) NSArray<GLTFAccessor *> *accessors;
@property(nonatomic, strong) GLTFAsset *asset;
@property(nonatomic, strong, nullable) NSArray<GLTFAnimation *> *animations;
@property(nonatomic, strong, nullable) NSArray<GLTFBuffer *> *buffers;
@property(nonatomic, strong, nullable) NSArray<GLTFBufferView *> *bufferViews;
@property(nonatomic, strong, nullable) NSArray<GLTFCamera *> *cameras;
@property(nonatomic, strong, nullable) NSArray<GLTFImage *> *images;
@property(nonatomic, strong, nullable) NSArray<GLTFMaterial *> *materials;
@property(nonatomic, strong, nullable) NSArray<GLTFMesh *> *meshes;
@property(nonatomic, strong, nullable) NSArray<GLTFNode *> *nodes;
@property(nonatomic, strong, nullable) NSArray<GLTFSampler *> *samplers;
@property(nonatomic, strong, nullable) NSNumber *scene;
@property(nonatomic, strong, nullable) NSArray<GLTFScene *> *scenes;
@property(nonatomic, strong, nullable) NSArray<GLTFSkin *> *skins;
@property(nonatomic, strong, nullable) NSArray<GLTFTexture *> *textures;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

NS_ASSUME_NONNULL_END
