#import "GLTFDecoder.h"
#import "Errors.h"

@interface NSDictionary (Private)

- (nullable NSNumber *)getNumber:(const NSString *)key;

@end

@implementation NSDictionary (Private)

- (nullable id)getValue:(const NSString *)key ofClass:(Class)aClass {
  id value = self[key];
  return [value isKindOfClass:aClass] ? value : nil;
}

- (nullable NSNumber *)getNumber:(const NSString *)key {
  return [self getValue:key ofClass:[NSNumber class]];
}

- (NSInteger)getInteger:(const NSString *)key {
  return [self getNumber:key].integerValue;
}

- (float)getFloat:(const NSString *)key {
  return [self getNumber:key].floatValue;
}

- (nullable NSString *)getString:(const NSString *)key {
  return [self getValue:key ofClass:[NSString class]];
}

- (nullable NSDictionary *)getDict:(const NSString *)key {
  return [self getValue:key ofClass:[NSDictionary class]];
}

- (nullable NSArray *)getArray:(const NSString *)key {
  return [self getValue:key ofClass:[NSArray class]];
}

- (nullable NSArray *)getArray:(const NSString *)key ofClass:(Class)aClass {
  NSArray *array = [self getArray:key];
  if (!array)
    return nil;
  NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:array.count];
  for (id item in array) {
    if ([item isKindOfClass:aClass]) {
      [mutableArray addObject:item];
    }
  }
  return [mutableArray copy];
}

- (nullable NSArray<NSString *> *)getStringArray:(const NSString *)key {
  return [self getArray:key ofClass:[NSString class]];
}

- (nullable NSArray<NSNumber *> *)getNumberArray:(const NSString *)key {
  return [self getArray:key ofClass:[NSNumber class]];
}

- (nullable NSArray<NSDictionary *> *)getDictArray:(const NSString *)key {
  return [self getArray:key ofClass:[NSDictionary class]];
}

- (nullable NSDictionary *)getExtensions {
  return [self getDict:@"extensions"];
}

- (nullable NSDictionary *)getExtras {
  return [self getDict:@"extras"];
}

- (nullable NSString *)getName {
  return [self getString:@"name"];
}

@end

@interface DecodeContext : NSObject

@property(nonatomic, strong, nonnull) NSMutableArray<NSString *> *stacks;

@end

@implementation DecodeContext

- (instancetype)init {
  self = [super init];
  if (self) {
    _stacks = [NSMutableArray array];
  }
  return self;
}

- (void)push:(NSString *)value {
  [self.stacks addObject:value];
}

- (NSString *)pop {
  NSString *last = [self.stacks lastObject];
  if (last) {
    [self.stacks removeLastObject];
  }
  return last;
}

- (NSString *)description {
  return [self.stacks componentsJoinedByString:@"."];
}

@end

@interface GLTFDecoder ()

@property(nonatomic, strong, nonnull) DecodeContext *context;

@end

@implementation GLTFDecoder

- (instancetype)init {
  self = [super init];
  if (self) {
    _context = [[DecodeContext alloc] init];
  }
  return self;
}

- (NSError *)missingDataErrorWithKey:(const NSString *)key {
  return [NSError errorWithDomain:GLTF2DecodeErrorDomain
                             code:GLTF2DecodeErrorMissingData
                         userInfo:@{
                           NSLocalizedDescriptionKey : [NSString
                               stringWithFormat:@"Key '%@' not found in %@",
                                                key, self.context]
                         }];
}

- (nullable NSNumber *)getRequiredNumber:(const NSDictionary *)jsonDict
                                     key:(const NSString *)key
                                   error:(NSError *_Nullable *)error {
  NSNumber *value = [jsonDict getNumber:key];
  if (!value)
    *error = [self missingDataErrorWithKey:key];
  return value;
}

- (NSInteger)getRequiredInteger:(const NSDictionary *)jsonDict
                            key:(const NSString *)key
                          error:(NSError *_Nullable *)error {
  NSNumber *value = [jsonDict getNumber:key];
  if (!value)
    *error = [self missingDataErrorWithKey:key];
  return value.integerValue;
}

- (nullable NSString *)getRequiredString:(const NSDictionary *)jsonDict
                                     key:(const NSString *)key
                                   error:(NSError *_Nullable *)error {
  NSString *value = [jsonDict getString:key];
  if (!value)
    *error = [self missingDataErrorWithKey:key];
  return value;
}

- (NSDictionary *)getRequiredDict:(const NSDictionary *)jsonDict
                              key:(const NSString *)key
                            error:(NSError *_Nullable *)error {
  NSDictionary *value = [jsonDict getDict:key];
  if (!value)
    *error = [self missingDataErrorWithKey:key];
  return value;
}

- (NSArray *)getRequiredArray:(const NSDictionary *)jsonDict
                          key:(const NSString *)key
                        error:(NSError *_Nullable *)error {
  NSArray *value = [jsonDict getArray:key];
  if (!value)
    *error = [self missingDataErrorWithKey:key];
  return value;
}

- (NSArray *)getRequiredArray:(const NSDictionary *)jsonDict
                          key:(const NSString *)key
                      ofClass:(Class)aClass
                        error:(NSError *_Nullable *)error {
  NSArray *value = [self getRequiredArray:jsonDict key:key error:error];
  if (!value)
    return nil;
  NSMutableArray *array = [NSMutableArray arrayWithCapacity:value.count];
  for (id item in value) {
    if ([item isKindOfClass:aClass]) {
      [array addObject:item];
    }
  }
  return [array copy];
}

- (NSArray<NSNumber *> *)getRequiredNumberArray:(NSDictionary *)jsonDict
                                            key:(const NSString *)key
                                          error:(NSError *_Nullable *)error {
  return [self getRequiredArray:jsonDict
                            key:key
                        ofClass:[NSNumber class]
                          error:error];
}

- (NSArray<NSDictionary *> *)getRequiredDictArray:(NSDictionary *)jsonDict
                                              key:(const NSString *)key
                                            error:(NSError *_Nullable *)error {
  return [self getRequiredArray:jsonDict
                            key:key
                        ofClass:[NSDictionary class]
                          error:error];
}

#pragma mark - GLTFJson

+ (nullable GLTFJson *)decodeJsonData:(NSData *)data
                                error:(NSError *_Nullable *_Nullable)error {
  NSError *err;
  NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data
                                                           options:0
                                                             error:&err];
  if (err) {
    if (error) {
      *error = err;
    }
    return nil;
  }
  return [self decodeJsonDict:jsonDict error:error];
}

+ (nullable GLTFJson *)decodeJsonDict:(NSDictionary *)jsonDict
                                error:(NSError *_Nullable *_Nullable)error {
  NSError *err;
  GLTFDecoder *decoder = [[GLTFDecoder alloc] init];
  GLTFJson *json = [decoder decodeJson:jsonDict error:&err];
  if (err) {
    if (error) {
      *error = err;
    }
    return nil;
  }
  return json;
}

- (nullable GLTFJson *)decodeJson:(NSDictionary *)jsonDict
                            error:(NSError *_Nullable *)error {
  [self.context push:@"root"];

  GLTFJson *decodedJson = [[GLTFJson alloc] init];
  decodedJson.extensionsUsed = [jsonDict getStringArray:@"extensionsUsed"];
  decodedJson.extensionsRequired =
      [jsonDict getStringArray:@"extensionsRequired"];

  NSArray<NSDictionary *> *accessorsArray =
      [jsonDict getDictArray:@"accessors"];
  if (accessorsArray) {
    NSMutableArray<GLTFAccessor *> *accessors =
        [NSMutableArray arrayWithCapacity:accessorsArray.count];
    for (NSDictionary *accessorDict in accessorsArray) {
      GLTFAccessor *accessor = [self decodeAccessor:accessorDict error:error];
      if (*error) {
        [self.context pop];
        return nil;
      }
      [accessors addObject:accessor];
    }
    decodedJson.accessors = [accessors copy];
  }

  NSArray<NSDictionary *> *animationsArray =
      [jsonDict getDictArray:@"animations"];
  if (animationsArray) {
    NSMutableArray<GLTFAnimation *> *animations =
        [NSMutableArray arrayWithCapacity:animationsArray.count];
    for (NSDictionary *animationDict in animationsArray) {
      GLTFAnimation *animation = [self decodeAnimation:animationDict
                                                 error:error];
      if (*error) {
        [self.context pop];
        return nil;
      }
      [animations addObject:animation];
    }
    decodedJson.animations = [animations copy];
  }

  // Decode 'asset'
  NSDictionary *assetDict = [self getRequiredDict:jsonDict
                                              key:@"asset"
                                            error:error];
  if (*error) {
    [self.context pop];
    return nil;
  }
  decodedJson.asset = [self decodeAsset:assetDict error:error];
  if (*error) {
    [self.context pop];
    return nil;
  }

  // Decode 'buffers'
  NSArray<NSDictionary *> *buffersArray = [jsonDict getDictArray:@"buffers"];
  if (buffersArray) {
    NSMutableArray<GLTFBuffer *> *buffers =
        [NSMutableArray arrayWithCapacity:buffersArray.count];
    for (NSDictionary *bufferDict in buffersArray) {
      GLTFBuffer *buffer = [self decodeBuffer:bufferDict error:error];
      if (*error) {
        [self.context pop];
        return nil;
      }
      [buffers addObject:buffer];
    }
    decodedJson.buffers = [buffers copy];
  }

  // Decode 'bufferViews'
  NSArray<NSDictionary *> *bufferViewsArray =
      [jsonDict getDictArray:@"bufferViews"];
  if (bufferViewsArray) {
    NSMutableArray<GLTFBufferView *> *bufferViews =
        [NSMutableArray arrayWithCapacity:bufferViewsArray.count];
    for (NSDictionary *bufferViewDict in bufferViewsArray) {
      GLTFBufferView *bufferView = [self decodeBufferView:bufferViewDict
                                                    error:error];
      if (*error) {
        [self.context pop];
        return nil;
      }
      [bufferViews addObject:bufferView];
    }
    decodedJson.bufferViews = [bufferViews copy];
  }

  // Decode 'cameras'
  NSArray<NSDictionary *> *camerasArray = [jsonDict getDictArray:@"cameras"];
  if (camerasArray) {
    NSMutableArray<GLTFCamera *> *cameras =
        [NSMutableArray arrayWithCapacity:camerasArray.count];
    for (NSDictionary *cameraDict in camerasArray) {
      GLTFCamera *camera = [self decodeCamera:cameraDict error:error];
      if (*error) {
        [self.context pop];
        return nil;
      }
      [cameras addObject:camera];
    }
    decodedJson.cameras = [cameras copy];
  }

  // Decode 'images'
  NSArray<NSDictionary *> *imagesArray = [jsonDict getDictArray:@"images"];
  if (imagesArray) {
    NSMutableArray<GLTFImage *> *images =
        [NSMutableArray arrayWithCapacity:imagesArray.count];
    for (NSDictionary *imageDict in imagesArray) {
      GLTFImage *image = [self decodeImage:imageDict];
      [images addObject:image];
    }
    decodedJson.images = [images copy];
  }

  // Decode 'materials'
  NSArray<NSDictionary *> *materialsArray =
      [jsonDict getDictArray:@"materials"];
  if (materialsArray) {
    NSMutableArray<GLTFMaterial *> *materials =
        [NSMutableArray arrayWithCapacity:materialsArray.count];
    for (NSDictionary *materialDict in materialsArray) {
      GLTFMaterial *material = [self decodeMaterial:materialDict error:error];
      if (*error) {
        [self.context pop];
        return nil;
      }
      [materials addObject:material];
    }
    decodedJson.materials = [materials copy];
  }

  // Decode 'meshes'
  NSArray<NSDictionary *> *meshesArray = [jsonDict getDictArray:@"meshes"];
  if (meshesArray) {
    NSMutableArray<GLTFMesh *> *meshes =
        [NSMutableArray arrayWithCapacity:meshesArray.count];
    for (NSDictionary *meshDict in meshesArray) {
      GLTFMesh *mesh = [self decodeMesh:meshDict error:error];
      if (*error) {
        [self.context pop];
        return nil;
      }
      [meshes addObject:mesh];
    }
    decodedJson.meshes = [meshes copy];
  }

  // Decode 'nodes'
  NSArray<NSDictionary *> *nodesArray = [jsonDict getDictArray:@"nodes"];
  if (nodesArray) {
    NSMutableArray<GLTFNode *> *nodes =
        [NSMutableArray arrayWithCapacity:nodesArray.count];
    for (NSDictionary *nodeDict in nodesArray) {
      GLTFNode *node = [self decodeNode:nodeDict];
      [nodes addObject:node];
    }
    decodedJson.nodes = [nodes copy];
  }

  // Decode 'samplers'
  NSArray<NSDictionary *> *samplersArray = [jsonDict getDictArray:@"samplers"];
  if (samplersArray) {
    NSMutableArray<GLTFSampler *> *samplers =
        [NSMutableArray arrayWithCapacity:samplersArray.count];
    for (NSDictionary *samplerDict in samplersArray) {
      GLTFSampler *sampler = [self decodeSampler:samplerDict];
      [samplers addObject:sampler];
    }
    decodedJson.samplers = [samplers copy];
  }

  // Decode 'scene'
  decodedJson.scene = [jsonDict getNumber:@"scene"];

  // Decode 'scenes'
  NSArray<NSDictionary *> *scenesArray = [jsonDict getDictArray:@"scenes"];
  if (scenesArray) {
    NSMutableArray<GLTFScene *> *scenes =
        [NSMutableArray arrayWithCapacity:scenesArray.count];
    for (NSDictionary *sceneDict in scenesArray) {
      GLTFScene *scene = [self decodeScene:sceneDict];
      [scenes addObject:scene];
    }
    decodedJson.scenes = [scenes copy];
  }

  // Decode 'skins'
  NSArray<NSDictionary *> *skinsArray = [jsonDict getDictArray:@"skins"];
  if (skinsArray) {
    NSMutableArray<GLTFSkin *> *skins =
        [NSMutableArray arrayWithCapacity:skinsArray.count];
    for (NSDictionary *skinDict in skinsArray) {
      GLTFSkin *skin = [self decodeSkin:skinDict error:error];
      if (*error) {
        [self.context pop];
        return nil;
      }
      [skins addObject:skin];
    }
    decodedJson.skins = [skins copy];
  }

  // Decode 'textures'
  NSArray<NSDictionary *> *texturesArray = [jsonDict getDictArray:@"textures"];
  if (texturesArray) {
    NSMutableArray<GLTFTexture *> *textures =
        [NSMutableArray arrayWithCapacity:texturesArray.count];
    for (NSDictionary *textureDict in texturesArray) {
      GLTFTexture *texture = [self decodeTexture:textureDict];
      [textures addObject:texture];
    }
    decodedJson.textures = [textures copy];
  }

  decodedJson.extensions = [jsonDict getExtensions];
  decodedJson.extras = [jsonDict getExtras];

  [self.context pop];
  return decodedJson;
}

#pragma mark - GLTFAccessor

- (nullable GLTFAccessor *)decodeAccessor:(NSDictionary *)jsonDict
                                    error:(NSError *_Nullable *)error {
  [self.context push:@"GLTFAccessor"];

  GLTFAccessor *accessor = [[GLTFAccessor alloc] init];

  accessor.componentType = [self getRequiredInteger:jsonDict
                                                key:@"componentType"
                                              error:error];
  if (*error) {
    [self.context pop];
    return nil;
  }

  accessor.count = [self getRequiredInteger:jsonDict key:@"count" error:error];
  if (*error) {
    [self.context pop];
    return nil;
  }

  accessor.type = [self getRequiredString:jsonDict key:@"type" error:error];
  if (*error) {
    [self.context pop];
    return nil;
  }

  NSDictionary *sparseDict = [jsonDict getDict:@"sparse"];
  if (sparseDict) {
    accessor.sparse = [self decodeAccessorSparse:sparseDict error:error];
    if (*error) {
      [self.context pop];
      return nil;
    }
  }

  accessor.bufferView = [jsonDict getNumber:@"bufferView"];
  accessor.byteOffset = [jsonDict getNumber:@"byteOffset"];
  accessor.normalized = [jsonDict getNumber:@"normalized"];
  accessor.max = [jsonDict getNumberArray:@"max"];
  accessor.min = [jsonDict getNumberArray:@"min"];
  accessor.name = [jsonDict getName];
  accessor.extensions = [jsonDict getExtensions];
  accessor.extras = [jsonDict getExtras];

  [self.context pop];
  return accessor;
}

#pragma mark - GLTFAccessorSparse

- (nullable GLTFAccessorSparse *)decodeAccessorSparse:(NSDictionary *)jsonDict
                                                error:(NSError *_Nullable *)
                                                          error {
  [self.context push:@"GLTFAccessorSparse"];

  GLTFAccessorSparse *sparse = [[GLTFAccessorSparse alloc] init];

  sparse.count = [self getRequiredInteger:jsonDict key:@"count" error:error];
  if (*error) {
    [self.context pop];
    return nil;
  }

  NSDictionary *indicesDict = [self getRequiredDict:jsonDict
                                                key:@"indices"
                                              error:error];
  if (*error) {
    [self.context pop];
    return nil;
  }
  sparse.indices = [self decodeAccessorSparseIndices:indicesDict error:error];
  if (*error) {
    [self.context pop];
    return nil;
  }

  NSDictionary *valuesDict = [self getRequiredDict:jsonDict
                                               key:@"values"
                                             error:error];
  if (*error) {
    [self.context pop];
    return nil;
  }
  sparse.values = [self decodeAccessorSparseValues:valuesDict error:error];
  if (*error) {
    [self.context pop];
    return nil;
  }

  sparse.extensions = [jsonDict getExtensions];
  sparse.extras = [jsonDict getExtras];

  [self.context pop];
  return sparse;
}

#pragma mark - GLTFAccessorSparseIndices

- (nullable GLTFAccessorSparseIndices *)
    decodeAccessorSparseIndices:(NSDictionary *)jsonDict
                          error:(NSError *_Nullable *)error {
  [self.context push:@"GLTFAccessorSparseIndices"];

  GLTFAccessorSparseIndices *obj = [[GLTFAccessorSparseIndices alloc] init];

  obj.bufferView = [self getRequiredInteger:jsonDict
                                        key:@"bufferView"
                                      error:error];
  if (*error) {
    [self.context pop];
    return nil;
  }

  obj.componentType = [[self getRequiredNumber:jsonDict
                                           key:@"componentType"
                                         error:error] integerValue];
  if (*error) {
    [self.context pop];
    return nil;
  }

  obj.byteOffset = [jsonDict getNumber:@"byteOffset"];
  obj.extensions = [jsonDict getExtensions];
  obj.extras = [jsonDict getExtras];

  [self.context pop];
  return obj;
}

#pragma mark - GLTFAccessorSparseValues

- (nullable GLTFAccessorSparseValues *)
    decodeAccessorSparseValues:(NSDictionary *)jsonDict
                         error:(NSError *_Nullable *)error {
  [self.context push:@"GLTFAccessorSparseValues"];

  GLTFAccessorSparseValues *obj = [[GLTFAccessorSparseValues alloc] init];

  obj.bufferView = [self getRequiredInteger:jsonDict
                                        key:@"bufferView"
                                      error:error];
  if (*error) {
    [self.context pop];
    return nil;
  }

  obj.byteOffset = [jsonDict getNumber:@"byteOffset"];
  obj.extensions = [jsonDict getExtensions];
  obj.extras = [jsonDict getExtras];

  [self.context pop];
  return obj;
}

#pragma mark - GLTFAnimation

- (nullable GLTFAnimation *)decodeAnimation:(NSDictionary *)jsonDict
                                      error:(NSError *_Nullable *)error {
  [self.context push:@"GLTFAnimation"];

  GLTFAnimation *animation = [[GLTFAnimation alloc] init];

  NSArray<NSDictionary *> *channelsArray =
      [self getRequiredDictArray:jsonDict key:@"channels" error:error];
  if (*error) {
    [self.context pop];
    return nil;
  }
  NSMutableArray<GLTFAnimationChannel *> *channels = [NSMutableArray array];
  for (NSDictionary *channelDict in channelsArray) {
    GLTFAnimationChannel *channel = [self decodeAnimationChannel:channelDict
                                                           error:error];
    if (*error) {
      [self.context pop];
      return nil;
    }
    [channels addObject:channel];
  }
  animation.channels = channels;

  NSArray<NSDictionary *> *samplersArray =
      [self getRequiredDictArray:jsonDict key:@"samplers" error:error];
  if (*error) {
    [self.context pop];
    return nil;
  }
  NSMutableArray<GLTFAnimationSampler *> *samplers = [NSMutableArray array];
  for (id samplerDict in samplersArray) {
    GLTFAnimationSampler *sampler = [self decodeAnimationSampler:samplerDict
                                                           error:error];
    if (*error) {
      [self.context pop];
      return nil;
    }
    [samplers addObject:sampler];
  }
  animation.samplers = samplers;

  animation.name = [jsonDict getName];
  animation.extensions = [jsonDict getExtensions];
  animation.extras = [jsonDict getExtras];

  [self.context pop];
  return animation;
}

#pragma mark - GLTFAnimationChannel

- (nullable GLTFAnimationChannel *)
    decodeAnimationChannel:(NSDictionary *)jsonDict
                     error:(NSError *_Nullable *)error {
  [self.context push:@"GLTFAnimationChannel"];

  GLTFAnimationChannel *channel = [[GLTFAnimationChannel alloc] init];

  NSInteger samplerIndex = [self getRequiredInteger:jsonDict
                                                key:@"sampler"
                                              error:error];
  if (*error) {
    [self.context pop];
    return nil;
  }
  channel.sampler = samplerIndex;

  NSDictionary *targetDict = [self getRequiredDict:jsonDict
                                               key:@"target"
                                             error:error];
  if (!targetDict) {
    [self.context pop];
    return nil;
  }
  channel.target = [self decodeAnimationChannelTarget:targetDict error:error];
  if (!channel.target) {
    [self.context pop];
    return nil;
  }

  channel.extensions = [jsonDict getExtensions];
  channel.extras = [jsonDict getExtras];

  [self.context pop];
  return channel;
}

#pragma mark - GLTFAnimationChannelTarget

- (nullable GLTFAnimationChannelTarget *)
    decodeAnimationChannelTarget:(NSDictionary *)jsonDict
                           error:(NSError *_Nullable *)error {
  [self.context push:@"GLTFAnimationChannelTarget"];

  GLTFAnimationChannelTarget *target =
      [[GLTFAnimationChannelTarget alloc] init];

  NSString *path = [self getRequiredString:jsonDict key:@"path" error:error];
  if (*error) {
    [self.context pop];
    return nil;
  }
  target.path = path;

  target.node = [jsonDict getNumber:@"node"];
  target.extensions = [jsonDict getExtensions];
  target.extras = [jsonDict getExtras];

  [self.context pop];
  return target;
}

#pragma mark - GLTFAnimationSampler

- (nullable GLTFAnimationSampler *)
    decodeAnimationSampler:(NSDictionary *)jsonDict
                     error:(NSError *_Nullable *)error {
  [self.context push:@"GLTFAnimationSampler"];

  GLTFAnimationSampler *sampler = [[GLTFAnimationSampler alloc] init];

  NSInteger inputIndex = [self getRequiredInteger:jsonDict
                                              key:@"input"
                                            error:error];
  if (*error) {
    [self.context pop];
    return nil;
  }
  sampler.input = inputIndex;

  NSInteger outputIndex = [self getRequiredInteger:jsonDict
                                               key:@"output"
                                             error:error];
  if (*error) {
    [self.context pop];
    return nil;
  }
  sampler.output = outputIndex;

  sampler.interpolation = [jsonDict getString:@"interpolation"];
  sampler.extensions = [jsonDict getExtensions];
  sampler.extras = [jsonDict getExtras];

  [self.context pop];
  return sampler;
}

#pragma mark - GLTFAsset

- (nullable GLTFAsset *)decodeAsset:(NSDictionary *)jsonDict
                              error:(NSError *_Nullable *)error {
  [self.context push:@"GLTFAsset"];

  GLTFAsset *asset = [[GLTFAsset alloc] init];

  asset.version = [self getRequiredString:jsonDict key:@"version" error:error];
  if (*error) {
    [self.context pop];
    return nil;
  }

  asset.copyright = [jsonDict getString:@"copyright"];
  asset.generator = [jsonDict getString:@"generator"];
  asset.minVersion = [jsonDict getString:@"minVersion"];
  asset.extensions = [jsonDict getExtensions];
  asset.extras = [jsonDict getExtras];

  [self.context pop];
  return asset;
}

#pragma mark - GLTFBuffer

- (nullable GLTFBuffer *)decodeBuffer:(NSDictionary *)jsonDict
                                error:(NSError *_Nullable *)error {
  [self.context push:@"GLTFBuffer"];

  GLTFBuffer *buffer = [[GLTFBuffer alloc] init];

  buffer.byteLength = [self getRequiredInteger:jsonDict
                                           key:@"byteLength"
                                         error:error];
  if (*error) {
    [self.context pop];
    return nil;
  }

  buffer.uri = [jsonDict getString:@"uri"];
  buffer.name = [jsonDict getName];
  buffer.extensions = [jsonDict getExtensions];
  buffer.extras = [jsonDict getExtras];

  [self.context pop];
  return buffer;
}

#pragma mark - GLTFBufferView

- (nullable GLTFBufferView *)decodeBufferView:(NSDictionary *)jsonDict
                                        error:(NSError *_Nullable *)error {
  [self.context push:@"GLTFBufferView"];

  GLTFBufferView *bufferView = [[GLTFBufferView alloc] init];

  bufferView.buffer = [self getRequiredInteger:jsonDict
                                           key:@"buffer"
                                         error:error];
  if (*error) {
    [self.context pop];
    return nil;
  }

  bufferView.byteLength = [self getRequiredInteger:jsonDict
                                               key:@"byteLength"
                                             error:error];
  if (*error) {
    [self.context pop];
    return nil;
  }

  bufferView.byteOffset = [jsonDict getNumber:@"byteOffset"];
  bufferView.byteStride = [jsonDict getNumber:@"byteStride"];
  bufferView.target = [jsonDict getNumber:@"target"];
  bufferView.name = [jsonDict getName];
  bufferView.extensions = [jsonDict getExtensions];
  bufferView.extras = [jsonDict getExtras];

  [self.context pop];
  return bufferView;
}

#pragma mark - GLTFCamera

- (nullable GLTFCamera *)decodeCamera:(NSDictionary *)jsonDict
                                error:(NSError *_Nullable *)error {
  [self.context push:@"GLTFCamera"];

  GLTFCamera *camera = [[GLTFCamera alloc] init];

  camera.type = [self getRequiredString:jsonDict key:@"type" error:error];
  if (*error) {
    [self.context pop];
    return nil;
  }

  NSDictionary *orthographicDict = [jsonDict getDict:@"orthographic"];
  if (orthographicDict) {
    camera.orthographic = [self decodeCameraOrthographic:orthographicDict
                                                   error:error];
    if (*error) {
      [self.context pop];
      return nil;
    }
  }

  NSDictionary *perspectiveDict = [jsonDict getDict:@"perspective"];
  if (perspectiveDict) {
    camera.perspective = [self decodeCameraPerspective:perspectiveDict
                                                 error:error];
    if (*error) {
      [self.context pop];
      return nil;
    }
  }

  camera.name = [jsonDict getName];
  camera.extensions = [jsonDict getExtensions];
  camera.extras = [jsonDict getExtras];

  [self.context pop];
  return camera;
}

#pragma mark - GLTFCameraOrthographic

- (nullable GLTFCameraOrthographic *)
    decodeCameraOrthographic:(NSDictionary *)jsonDict
                       error:(NSError *_Nullable *)error {
  [self.context push:@"GLTFCameraOrthographic"];

  GLTFCameraOrthographic *camera = [[GLTFCameraOrthographic alloc] init];

  NSNumber *xmag = [self getRequiredNumber:jsonDict key:@"xmag" error:error];
  if (*error) {
    [self.context pop];
    return nil;
  }
  camera.xmag = [xmag floatValue];

  NSNumber *ymag = [self getRequiredNumber:jsonDict key:@"ymag" error:error];
  if (*error) {
    [self.context pop];
    return nil;
  }
  camera.ymag = [ymag floatValue];

  NSNumber *zfar = [self getRequiredNumber:jsonDict key:@"zfar" error:error];
  if (*error) {
    [self.context pop];
    return nil;
  }
  camera.zfar = [zfar floatValue];

  NSNumber *znear = [self getRequiredNumber:jsonDict key:@"znear" error:error];
  if (*error) {
    [self.context pop];
    return nil;
  }
  camera.znear = [znear floatValue];

  camera.extensions = [jsonDict getExtensions];
  camera.extras = [jsonDict getExtras];

  [self.context pop];
  return camera;
}

#pragma mark - GLTFCameraPerspective

- (nullable GLTFCameraPerspective *)
    decodeCameraPerspective:(NSDictionary *)jsonDict
                      error:(NSError *_Nullable *)error {
  [self.context push:@"GLTFCameraPerspective"];

  GLTFCameraPerspective *camera = [[GLTFCameraPerspective alloc] init];

  NSNumber *yfov = [self getRequiredNumber:jsonDict key:@"yfov" error:error];
  if (*error) {
    [self.context pop];
    return nil;
  }
  camera.yfov = [yfov floatValue];

  NSNumber *znear = [self getRequiredNumber:jsonDict key:@"znear" error:error];
  if (*error) {
    [self.context pop];
    return nil;
  }
  camera.znear = [znear floatValue];

  camera.aspectRatio = [jsonDict getNumber:@"aspectRatio"];
  camera.zfar = [jsonDict getNumber:@"zfar"];
  camera.extensions = [jsonDict getExtensions];
  camera.extras = [jsonDict getExtras];

  [self.context pop];
  return camera;
}

#pragma mark - GLTFImage

- (GLTFImage *)decodeImage:(NSDictionary *)jsonDict {
  [self.context push:@"GLTFImage"];

  GLTFImage *image = [[GLTFImage alloc] init];

  image.uri = [jsonDict getString:@"uri"];
  image.mimeType = [jsonDict getString:@"mimeType"];
  image.bufferView = [jsonDict getNumber:@"bufferView"];
  image.name = [jsonDict getName];
  image.extensions = [jsonDict getExtensions];
  image.extras = [jsonDict getExtras];

  [self.context pop];
  return image;
}

#pragma mark - GLTFTexture

- (GLTFTexture *)decodeTexture:(NSDictionary *)jsonDict {
  [self.context push:@"GLTFTexture"];

  GLTFTexture *texture = [[GLTFTexture alloc] init];

  texture.sampler = [jsonDict getNumber:@"sampler"];
  texture.source = [jsonDict getNumber:@"source"];
  texture.name = [jsonDict getName];
  texture.extensions = [jsonDict getExtensions];
  texture.extras = [jsonDict getExtras];

  [self.context pop];
  return texture;
}

#pragma mark - GLTFTextureInfo

- (nullable GLTFTextureInfo *)decodeTextureInfo:(NSDictionary *)jsonDict
                                          error:(NSError *_Nullable *)error {
  [self.context push:@"GLTFTextureInfo"];

  GLTFTextureInfo *textureInfo = [[GLTFTextureInfo alloc] init];

  textureInfo.index = [self getRequiredInteger:jsonDict
                                           key:@"index"
                                         error:error];
  if (*error) {
    [self.context pop];
    return nil;
  }

  textureInfo.texCoord = [jsonDict getNumber:@"texCoord"];
  textureInfo.extensions = [jsonDict getExtensions];
  textureInfo.extras = [jsonDict getExtras];

  [self.context pop];
  return textureInfo;
}

#pragma mark - GLTFMaterial

- (nullable GLTFMaterial *)decodeMaterial:(NSDictionary *)jsonDict
                                    error:(NSError *_Nullable *)error {
  [self.context push:@"GLTFMaterial"];

  GLTFMaterial *material = [[GLTFMaterial alloc] init];

  NSDictionary *pbrMetallicRoughnessDict =
      [jsonDict getDict:@"pbrMetallicRoughness"];
  if (pbrMetallicRoughnessDict) {
    material.pbrMetallicRoughness =
        [self decodeMaterialPBRMetallicRoughness:pbrMetallicRoughnessDict
                                           error:error];
    if (*error) {
      [self.context pop];
      return nil;
    }
  }

  NSDictionary *normalTextureDict = [jsonDict getDict:@"normalTexture"];
  if (normalTextureDict) {
    material.normalTexture =
        [self decodeMaterialNormalTextureInfo:normalTextureDict error:error];
    if (*error) {
      [self.context pop];
      return nil;
    }
  }

  NSDictionary *occlusionTextureDict = [jsonDict getDict:@"occlusionTexture"];
  if (occlusionTextureDict) {
    material.occlusionTexture =
        [self decodeMaterialOcclusionTextureInfo:occlusionTextureDict
                                           error:error];
    if (*error) {
      [self.context pop];
      return nil;
    }
  }

  NSDictionary *emissiveTextureDict = [jsonDict getDict:@"emissiveTexture"];
  if (emissiveTextureDict) {
    material.emissiveTexture = [self decodeTextureInfo:emissiveTextureDict
                                                 error:error];
    if (*error) {
      [self.context pop];
      return nil;
    }
  }

  material.emissiveFactor = [jsonDict getNumberArray:@"emissiveFactor"];
  material.alphaMode = [jsonDict getString:@"alphaMode"];
  material.alphaCutoff = [jsonDict getNumber:@"alphaCutoff"];
  material.doubleSided = [jsonDict getNumber:@"doubleSided"];
  material.name = [jsonDict getName];
  material.extensions = [jsonDict getExtensions];
  material.extras = [jsonDict getExtras];

  [self.context pop];
  return material;
}

#pragma mark - GLTFMaterialNormalTextureInfo

- (nullable GLTFMaterialNormalTextureInfo *)
    decodeMaterialNormalTextureInfo:(NSDictionary *)jsonDict
                              error:(NSError *_Nullable *)error {
  [self.context push:@"GLTFMaterialNormalTextureInfo"];

  GLTFMaterialNormalTextureInfo *textureInfo =
      [[GLTFMaterialNormalTextureInfo alloc] init];

  textureInfo.index = [self getRequiredInteger:jsonDict
                                           key:@"index"
                                         error:error];
  if (*error) {
    [self.context pop];
    return nil;
  }

  textureInfo.texCoord = [jsonDict getNumber:@"texCoord"];
  textureInfo.scale = [jsonDict getNumber:@"scale"];
  textureInfo.extensions = [jsonDict getExtensions];
  textureInfo.extras = [jsonDict getExtras];

  [self.context pop];
  return textureInfo;
}

#pragma mark - GLTFMaterialOcclusionTextureInfo

- (nullable GLTFMaterialOcclusionTextureInfo *)
    decodeMaterialOcclusionTextureInfo:(NSDictionary *)jsonDict
                                 error:(NSError *_Nullable *)error {
  [self.context push:@"GLTFMaterialOcclusionTextureInfo"];

  GLTFMaterialOcclusionTextureInfo *textureInfo =
      [[GLTFMaterialOcclusionTextureInfo alloc] init];

  textureInfo.index = [self getRequiredInteger:jsonDict
                                           key:@"index"
                                         error:error];
  if (*error) {
    [self.context pop];
    return nil;
  }

  textureInfo.texCoord = [jsonDict getNumber:@"texCoord"];
  textureInfo.strength = [jsonDict getNumber:@"strength"];
  textureInfo.extensions = [jsonDict getExtensions];
  textureInfo.extras = [jsonDict getExtras];

  [self.context pop];
  return textureInfo;
}

#pragma mark - GLTFMaterialPBRMetallicRoughness

- (nullable GLTFMaterialPBRMetallicRoughness *)
    decodeMaterialPBRMetallicRoughness:(NSDictionary *)jsonDict
                                 error:(NSError *_Nullable *)error {
  [self.context push:@"GLTFMaterialPBRMetallicRoughness"];

  GLTFMaterialPBRMetallicRoughness *roughness =
      [[GLTFMaterialPBRMetallicRoughness alloc] init];

  NSDictionary *baseColorTextureDict = [jsonDict getDict:@"baseColorTexture"];
  if (baseColorTextureDict) {
    roughness.baseColorTexture = [self decodeTextureInfo:baseColorTextureDict
                                                   error:error];
    if (*error) {
      [self.context pop];
      return nil;
    }
  }

  NSDictionary *metallicRoughnessTextureDict =
      [jsonDict getDict:@"metallicRoughnessTexture"];
  if (metallicRoughnessTextureDict) {
    roughness.metallicRoughnessTexture =
        [self decodeTextureInfo:metallicRoughnessTextureDict error:error];
    if (*error) {
      [self.context pop];
      return nil;
    }
  }

  roughness.baseColorFactor = [jsonDict getNumberArray:@"baseColorFactor"];
  roughness.metallicFactor = [jsonDict getNumber:@"metallicFactor"];
  roughness.roughnessFactor = [jsonDict getNumber:@"roughnessFactor"];
  roughness.extensions = [jsonDict getExtensions];
  roughness.extras = [jsonDict getExtras];

  [self.context pop];
  return roughness;
}

#pragma mark - GLTFMesh

- (nullable GLTFMesh *)decodeMesh:(NSDictionary *)jsonDict
                            error:(NSError *_Nullable *)error {
  [self.context push:@"GLTFMesh"];

  NSArray<NSDictionary *> *primitivesArray =
      [self getRequiredDictArray:jsonDict key:@"primitives" error:error];
  if (*error) {
    [self.context pop];
    return nil;
  }
  NSMutableArray<GLTFMeshPrimitive *> *primitives = [NSMutableArray array];
  for (NSDictionary *primitiveDict in primitivesArray) {
    GLTFMeshPrimitive *primitive = [self decodeMeshPrimitive:primitiveDict
                                                       error:error];
    if (*error) {
      [self.context pop];
      return nil;
    }
    [primitives addObject:primitive];
  }

  GLTFMesh *mesh = [[GLTFMesh alloc] init];
  mesh.primitives = [primitives copy];

  mesh.weights = [jsonDict getNumberArray:@"weights"];
  mesh.name = [jsonDict getName];
  mesh.extensions = [jsonDict getExtensions];
  mesh.extras = [jsonDict getExtras];

  [self.context pop];
  return mesh;
}

#pragma mark - GLTFMeshPrimitiveTarget
- (GLTFMeshPrimitiveTarget *)decodeMeshPrimitiveTarget:
    (NSDictionary *)jsonDict {
  GLTFMeshPrimitiveTarget *target = [[GLTFMeshPrimitiveTarget alloc] init];
  target.position = [jsonDict getNumber:@"POSITION"];
  target.normal = [jsonDict getNumber:@"NORMAL"];
  target.tangent = [jsonDict getNumber:@"TANGENT"];
  return target;
}

#pragma mark - GLTFMeshPrimitive

- (nullable GLTFMeshPrimitive *)decodeMeshPrimitive:(NSDictionary *)jsonDict
                                              error:
                                                  (NSError *_Nullable *)error {
  [self.context push:@"GLTFMeshPrimitive"];

  NSDictionary *attributesDict = [self getRequiredDict:jsonDict
                                                   key:@"attributes"
                                                 error:error];
  if (*error) {
    [self.context pop];
    return nil;
  }
  NSMutableDictionary<NSString *, NSNumber *> *attributes =
      [NSMutableDictionary dictionary];
  for (id key in attributesDict) {
    id value = attributesDict[key];
    if ([key isKindOfClass:[NSString class]] &&
        [value isKindOfClass:[NSNumber class]]) {
      attributes[key] = value;
    }
  }

  NSMutableArray<GLTFMeshPrimitiveTarget *> *targets;
  NSArray<NSDictionary *> *targetsArray = [jsonDict getDictArray:@"targets"];
  if (targetsArray) {
    targets = [NSMutableArray arrayWithCapacity:targetsArray.count];
    for (NSDictionary *targetDict in targetsArray) {
      [targets addObject:[self decodeMeshPrimitiveTarget:targetDict]];
    }
  }

  GLTFMeshPrimitive *meshPrimitive = [[GLTFMeshPrimitive alloc] init];
  meshPrimitive.attributes = [attributesDict copy];
  meshPrimitive.targets = [targets copy];
  meshPrimitive.indices = [jsonDict getNumber:@"indices"];
  meshPrimitive.material = [jsonDict getNumber:@"material"];
  meshPrimitive.mode = [jsonDict getNumber:@"mode"];
  meshPrimitive.extensions = [jsonDict getExtensions];
  meshPrimitive.extras = [jsonDict getExtras];

  [self.context pop];
  return meshPrimitive;
}

#pragma mark - GLTFNode

- (GLTFNode *)decodeNode:(NSDictionary *)jsonDict {
  [self.context push:@"GLTFNode"];

  GLTFNode *node = [[GLTFNode alloc] init];

  node.matrix = [jsonDict getNumberArray:@"matrix"];
  node.rotation = [jsonDict getNumberArray:@"rotation"];
  node.scale = [jsonDict getNumberArray:@"scale"];
  node.translation = [jsonDict getNumberArray:@"translation"];
  node.camera = [jsonDict getNumber:@"camera"];
  node.children = [jsonDict getNumberArray:@"children"];
  node.skin = [jsonDict getNumber:@"skin"];
  node.mesh = [jsonDict getNumber:@"mesh"];
  node.weights = [jsonDict getNumberArray:@"weights"];
  node.name = [jsonDict getName];
  node.extensions = [jsonDict getExtensions];
  node.extras = [jsonDict getExtras];

  [self.context pop];
  return node;
}

#pragma mark - GLTFSampler

- (GLTFSampler *)decodeSampler:(NSDictionary *)jsonDict {
  [self.context push:@"GLTFSampler"];

  GLTFSampler *sampler = [[GLTFSampler alloc] init];
  sampler.magFilter = [jsonDict getNumber:@"magFilter"];
  sampler.minFilter = [jsonDict getNumber:@"minFilter"];
  sampler.wrapS = [jsonDict getNumber:@"wrapS"];
  sampler.wrapT = [jsonDict getNumber:@"wrapT"];
  sampler.name = [jsonDict getName];
  sampler.extensions = [jsonDict getExtensions];
  sampler.extras = [jsonDict getExtras];

  [self.context pop];
  return sampler;
}

#pragma mark - GLTFScene

- (GLTFScene *)decodeScene:(NSDictionary *)jsonDict {
  [self.context push:@"GLTFScene"];

  GLTFScene *scene = [[GLTFScene alloc] init];

  scene.nodes = [jsonDict getNumberArray:@"nodes"];
  scene.name = [jsonDict getName];
  scene.extensions = [jsonDict getExtensions];
  scene.extras = [jsonDict getExtras];

  [self.context pop];
  return scene;
}

#pragma mark - GLTFSkin

- (nullable GLTFSkin *)decodeSkin:(NSDictionary *)jsonDict
                            error:(NSError *_Nullable *)error {
  [self.context push:@"GLTFSkin"];

  NSArray *joints = [self getRequiredNumberArray:jsonDict
                                             key:@"joints"
                                           error:error];
  if (*error) {
    [self.context pop];
    return nil;
  }

  GLTFSkin *skin = [[GLTFSkin alloc] init];
  skin.joints = joints;

  skin.inverseBindMatrices = [jsonDict getNumber:@"inverseBindMatrices"];
  skin.skeleton = [jsonDict getNumber:@"skeleton"];
  skin.name = [jsonDict getName];
  skin.extensions = [jsonDict getExtensions];
  skin.extras = [jsonDict getExtras];

  [self.context pop];
  return skin;
}

@end
