#import "GLTFDecoder.h"
#import "Errors.h"

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
  id value = jsonDict[key];
  if ([value isKindOfClass:[NSNumber class]]) {
    return value;
  } else {
    *error = [self missingDataErrorWithKey:key];
    return nil;
  }
}

- (NSInteger)getRequiredInteger:(const NSDictionary *)jsonDict
                            key:(const NSString *)key
                          error:(NSError *_Nullable *)error {
  id value = jsonDict[key];
  if ([value isKindOfClass:[NSNumber class]]) {
    return [value integerValue];
  } else {
    *error = [self missingDataErrorWithKey:key];
    return 0;
  }
}

- (NSNumber *)getNumber:(const NSDictionary *)jsonDict
                    key:(const NSString *)key {
  id value = jsonDict[key];
  if ([value isKindOfClass:[NSNumber class]]) {
    return value;
  }
  return nil;
}

- (NSString *)getRequiredString:(const NSDictionary *)jsonDict
                            key:(const NSString *)key
                          error:(NSError *_Nullable *)error {
  id value = jsonDict[key];
  if ([value isKindOfClass:[NSString class]]) {
    return value;
  } else {
    *error = [self missingDataErrorWithKey:key];
    return @"";
  }
}

- (nullable NSString *)getString:(const NSDictionary *)jsonDict
                             key:(const NSString *)key {
  id value = jsonDict[key];
  if ([value isKindOfClass:[NSString class]]) {
    return value;
  }
  return nil;
}

- (nullable NSDictionary *)getDict:(const NSDictionary *)jsonDict
                               key:(const NSString *)key {
  id value = jsonDict[key];
  if ([value isKindOfClass:[NSDictionary class]]) {
    return value;
  }
  return nil;
}

- (NSDictionary *)getRequiredDict:(const NSDictionary *)jsonDict
                              key:(const NSString *)key
                            error:(NSError *_Nullable *)error {
  id value = jsonDict[key];
  if ([value isKindOfClass:[NSDictionary class]]) {
    return value;
  } else {
    *error = [self missingDataErrorWithKey:key];
    return nil;
  }
}

- (NSArray *)getRequiredArray:(const NSDictionary *)jsonDict
                          key:(const NSString *)key
                        error:(NSError *_Nullable *)error {
  id value = jsonDict[key];
  if ([value isKindOfClass:[NSArray class]]) {
    return value;
  } else {
    *error = [self missingDataErrorWithKey:key];
    return nil;
  }
}

- (NSArray *)getArray:(const NSDictionary *)jsonDict key:(const NSString *)key {
  id value = jsonDict[key];
  if ([value isKindOfClass:[NSArray class]]) {
    return value;
  } else {
    return nil;
  }
}

- (NSArray<NSNumber *> *)getRequiredNumberArray:(NSDictionary *)jsonDict
                                            key:(const NSString *)key
                                          error:(NSError *_Nullable *)error {
  NSArray *value = [self getArray:jsonDict key:key];
  if (!value) {
    *error = [self missingDataErrorWithKey:key];
    return [NSArray array];
  }

  NSArray *array = (NSArray *)value;
  NSMutableArray<NSNumber *> *numberArray =
      [NSMutableArray arrayWithCapacity:array.count];
  for (id item in array) {
    if ([item isKindOfClass:[NSNumber class]]) {
      [numberArray addObject:item];
    }
  }
  return numberArray;
}

- (nullable NSArray *)getTArray:(NSDictionary *)jsonDict
                            key:(const NSString *)key
                          class:(Class)class {
  NSArray *array = [self getArray:jsonDict key:key];
  if (!array) {
    return nil;
  }

  NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:array.count];
  for (id item in array) {
    if ([item isKindOfClass:class]) {
      [mutableArray addObject:item];
    }
  }
  return mutableArray;
}

- (nullable NSArray<NSNumber *> *)getNumberArray:(NSDictionary *)jsonDict
                                             key:(const NSString *)key {
  return [self getTArray:jsonDict key:key class:[NSNumber class]];
}

- (nullable NSArray<NSString *> *)getStringArray:(NSDictionary *)jsonDict
                                             key:(const NSString *)key {
  return [self getTArray:jsonDict key:key class:[NSString class]];
}

- (nullable NSArray<NSDictionary *> *)getDictArray:(NSDictionary *)jsonDict
                                               key:(const NSString *)key {
  return [self getTArray:jsonDict key:key class:[NSDictionary class]];
}

- (nullable NSDictionary *)getExtensions:(const NSDictionary *)jsonDict {
  return [self getDict:jsonDict key:@"extensions"];
}

- (nullable NSDictionary *)getExtras:(const NSDictionary *)jsonDict {
  return [self getDict:jsonDict key:@"extras"];
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
  [self.context push:@"GLTFAccessor"];

  GLTFJson *decodedJson = [[GLTFJson alloc] init];

  // Decode 'extensionsUsed'
  decodedJson.extensionsUsed = [self getStringArray:jsonDict
                                                key:@"extensionsUsed"];

  // Decode 'extensionsRequired'
  decodedJson.extensionsRequired = [self getStringArray:jsonDict
                                                    key:@"extensionsRequired"];

  // Decode 'accessors'
  NSArray<NSDictionary *> *accessorsArray = [self getDictArray:jsonDict
                                                           key:@"accessors"];
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

  // Decode 'animations'
  NSArray<NSDictionary *> *animationsArray = [self getDictArray:jsonDict
                                                            key:@"animations"];
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
  NSArray<NSDictionary *> *buffersArray = [self getDictArray:jsonDict
                                                         key:@"buffers"];
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
      [self getDictArray:jsonDict key:@"bufferViews"];
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
  NSArray<NSDictionary *> *camerasArray = [self getDictArray:jsonDict
                                                         key:@"cameras"];
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
  NSArray<NSDictionary *> *imagesArray = [self getDictArray:jsonDict
                                                        key:@"images"];
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
  NSArray<NSDictionary *> *materialsArray = [self getDictArray:jsonDict
                                                           key:@"materials"];
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
  NSArray<NSDictionary *> *meshesArray = [self getDictArray:jsonDict
                                                        key:@"meshes"];
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
  NSArray<NSDictionary *> *nodesArray = [self getDictArray:jsonDict
                                                       key:@"nodes"];
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
  NSArray<NSDictionary *> *samplersArray = [self getDictArray:jsonDict
                                                          key:@"samplers"];
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
  decodedJson.scene = [self getNumber:jsonDict key:@"scene"];

  // Decode 'scenes'
  NSArray<NSDictionary *> *scenesArray = [self getDictArray:jsonDict
                                                        key:@"scenes"];
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
  NSArray<NSDictionary *> *skinsArray = [self getDictArray:jsonDict
                                                       key:@"skins"];
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
  NSArray<NSDictionary *> *texturesArray = [self getDictArray:jsonDict
                                                          key:@"textures"];
  if (texturesArray) {
    NSMutableArray<GLTFTexture *> *textures =
        [NSMutableArray arrayWithCapacity:texturesArray.count];
    for (NSDictionary *textureDict in texturesArray) {
      GLTFTexture *texture = [self decodeTexture:textureDict];
      [textures addObject:texture];
    }
    decodedJson.textures = [textures copy];
  }

  // Decode 'extensions'
  decodedJson.extensions = [self getExtensions:jsonDict];

  // Decode 'extras'
  decodedJson.extras = [self getExtras:jsonDict];

  [self.context pop];
  return decodedJson;
}

#pragma mark - GLTFAccessor

- (nullable GLTFAccessor *)decodeAccessor:(NSDictionary *)jsonDict
                                    error:(NSError *_Nullable *)error {
  [self.context push:@"GLTFAccessor"];

  GLTFAccessor *accessor = [[GLTFAccessor alloc] init];

  accessor.bufferView = [self getNumber:jsonDict key:@"bufferView"];

  NSNumber *byteOffset = [self getNumber:jsonDict key:@"byteOffset"];
  if (byteOffset)
    accessor.byteOffset = [byteOffset integerValue];

  accessor.componentType = [self getRequiredInteger:jsonDict
                                                key:@"componentType"
                                              error:error];
  if (*error) {
    [self.context pop];
    return nil;
  }

  NSNumber *normalized = [self getNumber:jsonDict key:@"normalized"];
  if (normalized)
    accessor.normalized = [normalized boolValue];

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

  NSArray *max = [self getNumberArray:jsonDict key:@"max"];
  if (max)
    accessor.max = max;

  NSArray *min = [self getNumberArray:jsonDict key:@"min"];
  if (min)
    accessor.min = min;

  NSDictionary *sparseDict = [self getDict:jsonDict key:@"sparse"];
  if (sparseDict) {
    accessor.sparse = [self decodeAccessorSparse:sparseDict error:error];
    if (*error) {
      [self.context pop];
      return nil;
    }
  }

  accessor.name = [self getString:jsonDict key:@"name"];
  accessor.extensions = [self getExtensions:jsonDict];
  accessor.extras = [self getExtras:jsonDict];

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

  sparse.extensions = [self getExtensions:jsonDict];
  sparse.extras = [self getExtras:jsonDict];

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

  NSNumber *byteOffset = [self getNumber:jsonDict key:@"byteOffset"];
  if (byteOffset)
    obj.byteOffset = [byteOffset integerValue];

  obj.componentType = [[self getRequiredNumber:jsonDict
                                           key:@"componentType"
                                         error:error] integerValue];
  if (*error) {
    [self.context pop];
    return nil;
  }

  obj.extensions = [self getExtensions:jsonDict];
  obj.extras = [self getExtras:jsonDict];

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

  NSNumber *byteOffset = [self getNumber:jsonDict key:@"byteOffset"];
  if (byteOffset)
    obj.byteOffset = [byteOffset integerValue];

  obj.extensions = [self getExtensions:jsonDict];
  obj.extras = [self getExtras:jsonDict];

  [self.context pop];
  return obj;
}

#pragma mark - GLTFAnimation

- (nullable GLTFAnimation *)decodeAnimation:(NSDictionary *)jsonDict
                                      error:(NSError *_Nullable *)error {
  [self.context push:@"GLTFAnimation"];

  GLTFAnimation *animation = [[GLTFAnimation alloc] init];

  NSArray *channelsArray = [self getRequiredArray:jsonDict
                                              key:@"channels"
                                            error:error];
  if (*error) {
    [self.context pop];
    return nil;
  }
  NSMutableArray<GLTFAnimationChannel *> *channels = [NSMutableArray array];
  for (id channelDict in channelsArray) {
    if ([channelDict isKindOfClass:[NSDictionary class]]) {
      GLTFAnimationChannel *channel = [self decodeAnimationChannel:channelDict
                                                             error:error];
      if (*error) {
        [self.context pop];
        return nil;
      }
      [channels addObject:channel];
    }
  }
  animation.channels = channels;

  NSArray *samplersArray = [self getRequiredArray:jsonDict
                                              key:@"samplers"
                                            error:error];
  if (*error) {
    [self.context pop];
    return nil;
  }
  NSMutableArray<GLTFAnimationSampler *> *samplers = [NSMutableArray array];
  for (id samplerDict in samplersArray) {
    if ([samplerDict isKindOfClass:[NSDictionary class]]) {
      GLTFAnimationSampler *sampler = [self decodeAnimationSampler:samplerDict
                                                             error:error];
      if (*error) {
        [self.context pop];
        return nil;
      }
      [samplers addObject:sampler];
    }
  }
  animation.samplers = samplers;

  animation.name = [self getString:jsonDict key:@"name"];
  animation.extensions = [self getExtensions:jsonDict];
  animation.extras = [self getExtras:jsonDict];

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

  // Decode the 'target' property, which is required.
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

  channel.extensions = [self getExtensions:jsonDict];
  channel.extras = [self getExtras:jsonDict];

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

  target.node = [self getNumber:jsonDict key:@"node"];

  NSString *path = [self getRequiredString:jsonDict key:@"path" error:error];
  if (*error) {
    [self.context pop];
    return nil;
  }
  target.path = path;

  target.extensions = [self getExtensions:jsonDict];
  target.extras = [self getExtras:jsonDict];

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

  NSString *interpolation = [self getString:jsonDict key:@"interpolation"];
  if (interpolation)
    sampler.interpolation = interpolation;

  sampler.extensions = [self getExtensions:jsonDict];
  sampler.extras = [self getExtras:jsonDict];

  [self.context pop];
  return sampler;
}

#pragma mark - GLTFAsset

- (nullable GLTFAsset *)decodeAsset:(NSDictionary *)jsonDict
                              error:(NSError *_Nullable *)error {
  [self.context push:@"GLTFAsset"];

  // Required 'version' property
  NSString *version = [self getRequiredString:jsonDict
                                          key:@"version"
                                        error:error];
  if (*error) {
    [self.context pop];
    return nil;
  }

  GLTFAsset *asset = [[GLTFAsset alloc] init];
  asset.version = version;

  asset.copyright = [self getString:jsonDict key:@"copyright"];
  asset.generator = [self getString:jsonDict key:@"generator"];
  asset.minVersion = [self getString:jsonDict key:@"minVersion"];
  asset.extensions = [self getExtensions:jsonDict];
  asset.extras = [self getExtras:jsonDict];

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

  buffer.uri = [self getString:jsonDict key:@"uri"];
  buffer.name = [self getString:jsonDict key:@"name"];
  buffer.extensions = [self getExtensions:jsonDict];
  buffer.extras = [self getExtras:jsonDict];

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

  NSNumber *byteOffset = [self getNumber:jsonDict key:@"byteOffset"];
  if (byteOffset)
    bufferView.byteOffset = [byteOffset integerValue];

  bufferView.byteStride = [self getNumber:jsonDict key:@"byteStride"];
  bufferView.target = [self getNumber:jsonDict key:@"target"];
  bufferView.name = [self getString:jsonDict key:@"name"];
  bufferView.extensions = [self getExtensions:jsonDict];
  bufferView.extras = [self getExtras:jsonDict];

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

  NSDictionary *orthographicDict = [self getDict:jsonDict key:@"orthographic"];
  if (orthographicDict) {
    camera.orthographic = [self decodeCameraOrthographic:orthographicDict
                                                   error:error];
    if (*error) {
      [self.context pop];
      return nil;
    }
  }

  NSDictionary *perspectiveDict = [self getDict:jsonDict key:@"perspective"];
  if (perspectiveDict) {
    camera.perspective = [self decodeCameraPerspective:perspectiveDict
                                                 error:error];
    if (*error) {
      [self.context pop];
      return nil;
    }
  }

  camera.name = [self getString:jsonDict key:@"name"];
  camera.extensions = [self getExtensions:jsonDict];
  camera.extras = [self getExtras:jsonDict];

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

  camera.extensions = [self getExtensions:jsonDict];
  camera.extras = [self getExtras:jsonDict];

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

  camera.aspectRatio = [self getNumber:jsonDict key:@"aspectRatio"];
  camera.zfar = [self getNumber:jsonDict key:@"zfar"];
  camera.extensions = [self getExtensions:jsonDict];
  camera.extras = [self getExtras:jsonDict];

  [self.context pop];
  return camera;
}

#pragma mark - GLTFImage

- (GLTFImage *)decodeImage:(NSDictionary *)jsonDict {
  [self.context push:@"GLTFImage"];

  GLTFImage *image = [[GLTFImage alloc] init];

  image.uri = [self getString:jsonDict key:@"uri"];
  image.mimeType = [self getString:jsonDict key:@"mimeType"];
  image.bufferView = [self getNumber:jsonDict key:@"bufferView"];
  image.name = [self getString:jsonDict key:@"name"];
  image.extensions = [self getExtensions:jsonDict];
  image.extras = [self getExtras:jsonDict];

  [self.context pop];
  return image;
}

#pragma mark - GLTFMaterial

- (nullable GLTFMaterial *)decodeMaterial:(NSDictionary *)jsonDict
                                    error:(NSError *_Nullable *)error {
  [self.context push:@"GLTFMaterial"];

  GLTFMaterial *material = [[GLTFMaterial alloc] init];

  material.name = [self getString:jsonDict key:@"name"];
  material.extensions = [self getExtensions:jsonDict];
  material.extras = [self getExtras:jsonDict];

  NSDictionary *pbrMetallicRoughnessDict =
      [self getDict:jsonDict key:@"pbrMetallicRoughness"];
  if (pbrMetallicRoughnessDict) {
    material.pbrMetallicRoughness =
        [self decodeMaterialPBRMetallicRoughness:pbrMetallicRoughnessDict
                                           error:error];
    if (*error) {
      [self.context pop];
      return nil;
    }
  }

  NSDictionary *normalTextureDict = [self getDict:jsonDict
                                              key:@"normalTexture"];
  if (normalTextureDict) {
    material.normalTexture =
        [self decodeMaterialNormalTextureInfo:normalTextureDict error:error];
    if (*error) {
      [self.context pop];
      return nil;
    }
  }

  NSDictionary *occlusionTextureDict = [self getDict:jsonDict
                                                 key:@"occlusionTexture"];
  if (occlusionTextureDict) {
    material.occlusionTexture =
        [self decodeMaterialOcclusionTextureInfo:occlusionTextureDict
                                           error:error];
    if (*error) {
      [self.context pop];
      return nil;
    }
  }

  NSDictionary *emissiveTextureDict = [self getDict:jsonDict
                                                key:@"emissiveTexture"];
  if (emissiveTextureDict) {
    material.emissiveTexture = [self decodeTextureInfo:emissiveTextureDict
                                                 error:error];
    if (*error) {
      [self.context pop];
      return nil;
    }
  }

  NSArray<NSNumber *> *emissiveFactor = [self getNumberArray:jsonDict
                                                         key:@"emissiveFactor"];
  if (emissiveFactor && emissiveFactor.count == 3) {
    material.emissiveFactor = emissiveFactor;
  }

  NSString *alphaMode = [self getString:jsonDict key:@"alphaMode"];
  if (alphaMode)
    material.alphaMode = alphaMode;

  NSNumber *alphaCutoff = [self getNumber:jsonDict key:@"alphaCutoff"];
  if (alphaCutoff)
    material.alphaCutoff = [alphaCutoff floatValue];

  NSNumber *doubleSided = [self getNumber:jsonDict key:@"doubleSided"];
  if (doubleSided)
    material.doubleSided = [doubleSided boolValue];

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

  NSNumber *texCoord = [self getNumber:jsonDict key:@"texCoord"];
  if (texCoord) {
    textureInfo.texCoord = [texCoord integerValue];
  }

  NSNumber *scale = [self getNumber:jsonDict key:@"scale"];
  if (scale) {
    textureInfo.scale = [scale floatValue];
  }

  textureInfo.extensions = [self getExtensions:jsonDict];
  textureInfo.extras = [self getExtras:jsonDict];

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

  NSNumber *texCoord = [self getNumber:jsonDict key:@"texCoord"];
  if (texCoord) {
    textureInfo.texCoord = [texCoord integerValue];
  }

  NSNumber *strength = [self getNumber:jsonDict key:@"strength"];
  if (strength) {
    textureInfo.strength = [strength floatValue];
  }

  textureInfo.extensions = [self getExtensions:jsonDict];
  textureInfo.extras = [self getExtras:jsonDict];

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

  NSArray<NSNumber *> *baseColorFactor =
      [self getNumberArray:jsonDict key:@"baseColorFactor"];
  if (baseColorFactor && baseColorFactor.count == 4) {
    roughness.baseColorFactor = baseColorFactor;
  }

  NSDictionary *baseColorTextureDict = [self getDict:jsonDict
                                                 key:@"baseColorTexture"];
  if (baseColorTextureDict) {
    roughness.baseColorTexture = [self decodeTextureInfo:baseColorTextureDict
                                                   error:error];
    if (*error) {
      [self.context pop];
      return nil;
    }
  }

  NSNumber *metallicFactor = [self getNumber:jsonDict key:@"metallicFactor"];
  if (metallicFactor)
    roughness.metallicFactor = [metallicFactor floatValue];

  NSNumber *roughnessFactor = [self getNumber:jsonDict key:@"roughnessFactor"];
  if (roughnessFactor)
    roughness.roughnessFactor = [roughnessFactor floatValue];

  NSDictionary *metallicRoughnessTextureDict =
      [self getDict:jsonDict key:@"metallicRoughnessTexture"];
  if (metallicRoughnessTextureDict) {
    roughness.metallicRoughnessTexture =
        [self decodeTextureInfo:metallicRoughnessTextureDict error:error];
    if (*error) {
      [self.context pop];
      return nil;
    }
  }

  roughness.extensions = [self getExtensions:jsonDict];
  roughness.extras = [self getExtras:jsonDict];

  [self.context pop];
  return roughness;
}

#pragma mark - GLTFMesh

- (nullable GLTFMesh *)decodeMesh:(NSDictionary *)jsonDict
                            error:(NSError *_Nullable *)error {
  [self.context push:@"GLTFMesh"];

  NSArray *primitivesArray = [self getRequiredArray:jsonDict
                                                key:@"primitives"
                                              error:error];
  if (*error) {
    [self.context pop];
    return nil;
  }
  NSMutableArray<GLTFMeshPrimitive *> *primitives = [NSMutableArray array];
  for (id primitiveDict in primitivesArray) {
    if ([primitiveDict isKindOfClass:[NSDictionary class]]) {
      GLTFMeshPrimitive *primitive = [self decodeMeshPrimitive:primitiveDict
                                                         error:error];
      if (*error) {
        [self.context pop];
        return nil;
      }
      [primitives addObject:primitive];
    }
  }

  GLTFMesh *mesh = [[GLTFMesh alloc] init];
  mesh.primitives = [primitives copy];

  mesh.weights = [self getNumberArray:jsonDict key:@"weights"];
  mesh.name = [self getString:jsonDict key:@"name"];
  mesh.extensions = [self getExtensions:jsonDict];
  mesh.extras = [self getExtras:jsonDict];

  [self.context pop];
  return mesh;
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

  GLTFMeshPrimitive *meshPrimitive = [[GLTFMeshPrimitive alloc] init];
  meshPrimitive.attributes = [attributesDict copy];

  meshPrimitive.indices = [self getNumber:jsonDict key:@"indices"];
  meshPrimitive.material = [self getNumber:jsonDict key:@"material"];
  NSNumber *mode = [self getNumber:jsonDict key:@"mode"];
  if (mode)
    meshPrimitive.mode = [mode integerValue];
  meshPrimitive.targets = [self getNumberArray:jsonDict key:@"targets"];
  meshPrimitive.extensions = [self getExtensions:jsonDict];
  meshPrimitive.extras = [self getExtras:jsonDict];

  [self.context pop];
  return meshPrimitive;
}

#pragma mark - GLTFNode

- (GLTFNode *)decodeNode:(NSDictionary *)jsonDict {
  [self.context push:@"GLTFNode"];

  GLTFNode *node = [[GLTFNode alloc] init];

  // Optional properties with default values
  node.camera = [self getNumber:jsonDict key:@"camera"];
  node.children = [self getNumberArray:jsonDict key:@"children"];
  node.skin = [self getNumber:jsonDict key:@"skin"];
  node.mesh = [self getNumber:jsonDict key:@"mesh"];
  node.weights = [self getNumberArray:jsonDict key:@"weights"];
  node.name = [self getString:jsonDict key:@"name"];
  node.extensions = [self getExtensions:jsonDict];
  node.extras = [self getExtras:jsonDict];

  // Handle transformation properties with defaults
  NSArray<NSNumber *> *matrixArray = [self getNumberArray:jsonDict
                                                      key:@"matrix"];
  if (matrixArray && matrixArray.count == 16) {
    node.matrix = simd_matrix(
        (vector_float4){matrixArray[0].floatValue, matrixArray[1].floatValue,
                        matrixArray[2].floatValue, matrixArray[3].floatValue},
        (vector_float4){matrixArray[4].floatValue, matrixArray[5].floatValue,
                        matrixArray[6].floatValue, matrixArray[7].floatValue},
        (vector_float4){matrixArray[8].floatValue, matrixArray[9].floatValue,
                        matrixArray[10].floatValue, matrixArray[11].floatValue},
        (vector_float4){matrixArray[12].floatValue, matrixArray[13].floatValue,
                        matrixArray[14].floatValue,
                        matrixArray[15].floatValue});
  }

  NSArray<NSNumber *> *rotation = [self getNumberArray:jsonDict
                                                   key:@"rotation"];
  if (rotation && rotation.count == 4) {
    node.rotation = rotation;
  }

  NSArray<NSNumber *> *scale = [self getNumberArray:jsonDict key:@"scale"];
  if (scale && scale.count == 3) {
    node.scale = scale;
  }

  NSArray<NSNumber *> *translation = [self getNumberArray:jsonDict
                                                      key:@"translation"];
  if (translation && translation.count == 3) {
    node.translation = translation;
  }

  [self.context pop];
  return node;
}

#pragma mark - GLTFSampler

- (GLTFSampler *)decodeSampler:(NSDictionary *)jsonDict {
  [self.context push:@"GLTFSampler"];

  GLTFSampler *sampler = [[GLTFSampler alloc] init];

  // Optional properties with default values
  sampler.magFilter = [self getNumber:jsonDict key:@"magFilter"];
  sampler.minFilter = [self getNumber:jsonDict key:@"minFilter"];
  NSNumber *wrapS = [self getNumber:jsonDict key:@"wrapS"];
  if (wrapS) {
    sampler.wrapS = [wrapS integerValue];
  }
  NSNumber *wrapT = [self getNumber:jsonDict key:@"wrapT"];
  if (wrapT) {
    sampler.wrapT = [wrapT integerValue];
  }
  sampler.name = [self getString:jsonDict key:@"name"];
  sampler.extensions = [self getExtensions:jsonDict];
  sampler.extras = [self getExtras:jsonDict];

  [self.context pop];
  return sampler;
}

#pragma mark - GLTFScene

- (GLTFScene *)decodeScene:(NSDictionary *)jsonDict {
  [self.context push:@"GLTFScene"];

  GLTFScene *scene = [[GLTFScene alloc] init];

  scene.nodes = [self getNumberArray:jsonDict key:@"nodes"];
  scene.name = [self getString:jsonDict key:@"name"];
  scene.extensions = [self getExtensions:jsonDict];
  scene.extras = [self getExtras:jsonDict];

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

  skin.inverseBindMatrices = [self getNumber:jsonDict
                                         key:@"inverseBindMatrices"];
  skin.skeleton = [self getNumber:jsonDict key:@"skeleton"];
  skin.name = [self getString:jsonDict key:@"name"];
  skin.extensions = [self getExtensions:jsonDict];
  skin.extras = [self getExtras:jsonDict];

  [self.context pop];
  return skin;
}

#pragma mark - GLTFTexture

- (GLTFTexture *)decodeTexture:(NSDictionary *)jsonDict {
  [self.context push:@"GLTFTexture"];

  GLTFTexture *texture = [[GLTFTexture alloc] init];

  texture.sampler = [self getNumber:jsonDict key:@"sampler"];
  texture.source = [self getNumber:jsonDict key:@"source"];
  texture.name = [self getString:jsonDict key:@"name"];
  texture.extensions = [self getExtensions:jsonDict];
  texture.extras = [self getExtras:jsonDict];

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

  NSNumber *texCoord = [self getNumber:jsonDict key:@"texCoord"];
  if (texCoord) {
    textureInfo.texCoord = [texCoord integerValue];
  }

  textureInfo.extensions = [self getExtensions:jsonDict];
  textureInfo.extras = [self getExtras:jsonDict];

  [self.context pop];
  return textureInfo;
}

@end
