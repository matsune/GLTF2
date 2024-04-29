#import "GLTFDecoder.h"

@interface GLTFDecoder ()

@end

@implementation GLTFDecoder

+ (NSError *)missingDataErrorWithKey:(const NSString *)key
                             objName:(const NSString *)objName {
  return [NSError
      errorWithDomain:GLTF2ErrorDomain
                 code:GLTF2ErrorMissingData
             userInfo:@{
               NSLocalizedDescriptionKey : [NSString
                   stringWithFormat:@"Key '%@' not found in %@.", key, objName]
             }];
}

+ (NSError *)invalidFormatErrorWithKey:(const NSString *)key
                               objName:(const NSString *)objName {
  return [NSError
      errorWithDomain:GLTF2ErrorDomain
                 code:GLTF2ErrorInvalidFormat
             userInfo:@{
               NSLocalizedDescriptionKey : [NSString
                   stringWithFormat:@"Unexpected value for key '%@' in %@.",
                                    key, objName]
             }];
}

+ (NSUInteger)getUInt:(const NSDictionary *)jsonDict
                  key:(const NSString *)key
             required:(BOOL)required
              objName:(const NSString *)objName
                error:(NSError **)error {
  NSNumber *value = jsonDict[key];

  if (!value) {
    if (required) {
      *error = [GLTFDecoder missingDataErrorWithKey:key objName:objName];
    }
    return 0;
  }

  if ([value isKindOfClass:[NSNumber class]]) {
    return [value unsignedIntegerValue];
  } else {
    *error = [GLTFDecoder invalidFormatErrorWithKey:key objName:objName];
    return 0;
  }
}

+ (BOOL)getBool:(const NSDictionary *)jsonDict
            key:(const NSString *)key
       required:(BOOL)required
        objName:(const NSString *)objName
          error:(NSError **)error {
  NSNumber *value = jsonDict[key];
  if (!value) {
    if (required) {
      *error = [GLTFDecoder missingDataErrorWithKey:key objName:objName];
    }
    return NO;
  }

  if ([value isKindOfClass:[NSNumber class]]) {
    return [value boolValue];
  } else {
    if (required) {
      *error = [GLTFDecoder invalidFormatErrorWithKey:key objName:objName];
    }
    return NO;
  }
}

+ (NSString *)getString:(const NSDictionary *)jsonDict
                    key:(const NSString *)key
               required:(BOOL)required
                objName:(const NSString *)objName
                  error:(NSError **)error {
  NSString *value = jsonDict[key];
  if (!value) {
    if (required) {
      *error = [GLTFDecoder missingDataErrorWithKey:key objName:objName];
    }
    return nil;
  }

  if ([value isKindOfClass:[NSString class]]) {
    return value;
  } else {
    *error = [GLTFDecoder invalidFormatErrorWithKey:key objName:objName];
    return nil;
  }
}

+ (nullable NSDictionary *)getDict:(const NSDictionary *)jsonDict
                               key:(const NSString *)key {
  id extensions = jsonDict[key];
  if ([extensions isKindOfClass:[NSDictionary class]]) {
    return extensions;
  }
  return nil;
}

+ (nullable NSArray<NSNumber *> *)getUIntegerArray:
                                      (const NSDictionary *)jsonDict
                                               key:(const NSString *)key
                                          required:(BOOL)required
                                           objName:(const NSString *)objName
                                             error:(NSError **)error {
  id value = jsonDict[key];
  if (!value) {
    if (required) {
      *error = [GLTFDecoder missingDataErrorWithKey:key objName:objName];
    }
    return nil;
  }

  if ([value isKindOfClass:[NSArray class]]) {
    NSMutableArray<NSNumber *> *uintArray = [NSMutableArray array];
    for (id item in value) {
      if ([item isKindOfClass:[NSNumber class]]) {
        // Check if the number is an unsigned integer
        NSNumber *number = (NSNumber *)item;
        if ([number unsignedIntegerValue] >= 0) {
          [uintArray addObject:number];
        } else {
          // Found a non-positive integer, return nil
          *error = [GLTFDecoder invalidFormatErrorWithKey:key objName:objName];
          return nil;
        }
      } else {
        // Found a non-NSNumber object in the array, return nil
        *error = [GLTFDecoder invalidFormatErrorWithKey:key objName:objName];
        return nil;
      }
    }
    return [uintArray copy];
  } else {
    *error = [GLTFDecoder invalidFormatErrorWithKey:key objName:objName];
    return nil;
  }
}

+ (nullable NSArray<NSNumber *> *)getNumberArray:(const NSDictionary *)jsonDict
                                             key:(const NSString *)key
                                        required:(BOOL)required
                                         objName:(const NSString *)objName
                                           error:(NSError **)error {
  id value = jsonDict[key];
  if (!value) {
    if (required) {
      *error = [GLTFDecoder missingDataErrorWithKey:key objName:objName];
    }
    return nil;
  }

  if ([value isKindOfClass:[NSArray class]]) {
    NSMutableArray<NSNumber *> *numArray = [NSMutableArray array];
    for (id item in value) {
      if ([item isKindOfClass:[NSNumber class]]) {
        [numArray addObject:item];
      } else {
        // Found a non-NSNumber object in the array, return nil
        *error = [GLTFDecoder invalidFormatErrorWithKey:key objName:objName];
        return nil;
      }
    }
    return [numArray copy];
  } else {
    *error = [GLTFDecoder invalidFormatErrorWithKey:key objName:objName];
    return nil;
  }
}

+ (simd_float4x4)getMatrix4x4:(const NSDictionary *)jsonDict
                          key:(const NSString *)key
                 defaultValue:(simd_float4x4)defaultValue
                      objName:(const NSString *)objName
                        error:(NSError **)error {
  id value = jsonDict[key];
  if (!value) {
    return defaultValue;
  }

  if ([value isKindOfClass:[NSArray class]]) {
    NSArray<NSNumber *> *matrixValues = (NSArray<NSNumber *> *)value;
    if (matrixValues.count != 16) {
      *error = [GLTFDecoder invalidFormatErrorWithKey:key objName:objName];
      return matrix_identity_float4x4;
    }

    float values[16];
    for (NSUInteger i = 0; i < 16; i++) {
      NSNumber *number = matrixValues[i];
      if (![number isKindOfClass:[NSNumber class]]) {
        *error = [GLTFDecoder invalidFormatErrorWithKey:key objName:objName];
        return matrix_identity_float4x4;
      }
      values[i] = [number floatValue];
    }

    return (simd_float4x4){
        (simd_float4){values[0], values[1], values[2], values[3]},
        (simd_float4){values[4], values[5], values[6], values[7]},
        (simd_float4){values[8], values[9], values[10], values[11]},
        (simd_float4){values[12], values[13], values[14], values[15]}};

  } else {
    *error = [GLTFDecoder invalidFormatErrorWithKey:key objName:objName];
    return matrix_identity_float4x4;
  }
}

+ (nullable NSDictionary *)getExtensions:(const NSDictionary *)jsonDict {
  return [GLTFDecoder getDict:jsonDict key:@"extensions"];
}

+ (nullable NSDictionary *)getExtras:(const NSDictionary *)jsonDict {
  return [GLTFDecoder getDict:jsonDict key:@"extras"];
}

#pragma mark - GLTFAccessor

+ (nullable GLTFAccessor *)decodeAccessorFromJson:(NSDictionary *)jsonDict
                                            error:(NSError **)error {
  NSString *const objName = @"GLTFAccessor";
  GLTFAccessor *accessor = [[GLTFAccessor alloc] init];

  accessor.bufferView = [self getUInt:jsonDict
                                  key:@"bufferView"
                             required:YES
                              objName:objName
                                error:error];
  if (*error)
    return nil;

  accessor.byteOffset = [self getUInt:jsonDict
                                  key:@"byteOffset"
                             required:NO
                              objName:objName
                                error:error];
  if (*error)
    return nil;

  NSUInteger componentType = [GLTFDecoder getUInt:jsonDict
                                              key:@"componentType"
                                         required:YES
                                          objName:objName
                                            error:error];
  if (*error)
    return nil;
  if (!isValidGLTFAccessorComponentType(componentType)) {
    *error = [GLTFDecoder invalidFormatErrorWithKey:@"componentType"
                                            objName:objName];
    return nil;
  }
  accessor.componentType = componentType;

  accessor.normalized = [self getBool:jsonDict
                                  key:@"normalized"
                             required:NO
                              objName:objName
                                error:error];
  if (*error)
    return nil;

  accessor.count = [self getUInt:jsonDict
                             key:@"count"
                        required:YES
                         objName:objName
                           error:error];
  if (*error)
    return nil;

  NSString *typeString = [self getString:jsonDict
                                     key:@"type"
                                required:YES
                                 objName:objName
                                   error:error];
  if (*error)
    return nil;
  GLTFAccessorType type = GLTFAccessorTypeFromString(typeString);
  if (type == NSNotFound) {
    *error = [GLTFDecoder invalidFormatErrorWithKey:@"type" objName:objName];
    return nil;
  }
  accessor.type = type;

  accessor.max = [self getUIntegerArray:jsonDict
                                    key:@"max"
                               required:NO
                                objName:objName
                                  error:error];
  if (*error)
    return nil;

  accessor.min = [self getUIntegerArray:jsonDict
                                    key:@"min"
                               required:NO
                                objName:objName
                                  error:error];
  if (*error)
    return nil;

  NSDictionary *sparseDict = [GLTFDecoder getDict:jsonDict key:@"sparse"];
  if (!sparseDict) {
    *error = [GLTFDecoder invalidFormatErrorWithKey:@"sparse" objName:objName];
    return nil;
  }
  GLTFAccessorSparse *sparse =
      [GLTFDecoder decodeAccessorSparseFromJson:sparseDict error:error];
  if (*error)
    return nil;
  accessor.sparse = sparse;

  accessor.name = [self getString:jsonDict
                              key:@"name"
                         required:NO
                          objName:objName
                            error:error];
  if (*error)
    return nil;

  accessor.extensions = [self getExtensions:jsonDict];
  accessor.extras = [self getExtras:jsonDict];

  return accessor;
}

#pragma mark - GLTFAccessorSparse

+ (nullable GLTFAccessorSparse *)
    decodeAccessorSparseFromJson:(NSDictionary *)jsonDict
                           error:(NSError **)error {
  NSString *const objName = @"GLTFAccessorSparse";
  GLTFAccessorSparse *sparse = [[GLTFAccessorSparse alloc] init];

  sparse.count = [GLTFDecoder getUInt:jsonDict
                                  key:@"count"
                             required:YES
                              objName:objName
                                error:error];
  if (*error)
    return nil;

  NSDictionary *indicesDict = [GLTFDecoder getDict:jsonDict key:@"indices"];
  if (!indicesDict) {
    *error = [GLTFDecoder invalidFormatErrorWithKey:@"indices" objName:objName];
    return nil;
  }
  GLTFAccessorSparseIndices *indices =
      [GLTFDecoder decodeAccessorSparseIndicesFromJson:indicesDict error:error];
  if (*error)
    return nil;
  sparse.indices = indices;

  NSDictionary *valuesDict = [GLTFDecoder getDict:jsonDict key:@"values"];
  if (!valuesDict) {
    *error = [GLTFDecoder invalidFormatErrorWithKey:@"values" objName:objName];
    return nil;
  }
  GLTFAccessorSparseValues *values =
      [GLTFDecoder decodeAccessorSparseValuesFromJson:valuesDict error:error];
  if (*error)
    return nil;
  sparse.values = values;

  sparse.extensions = [GLTFDecoder getExtensions:jsonDict];
  sparse.extras = [GLTFDecoder getExtras:jsonDict];

  return sparse;
}

#pragma mark - GLTFAccessorSparseIndices

+ (nullable GLTFAccessorSparseIndices *)
    decodeAccessorSparseIndicesFromJson:(NSDictionary *)jsonDict
                                  error:(NSError **)error {
  NSString *const objName = @"GLTFAccessorSparseIndices";
  GLTFAccessorSparseIndices *obj = [[GLTFAccessorSparseIndices alloc] init];

  obj.bufferView = [GLTFDecoder getUInt:jsonDict
                                    key:@"bufferView"
                               required:YES
                                objName:objName
                                  error:error];
  if (*error)
    return nil;

  obj.byteOffset = [GLTFDecoder getUInt:jsonDict
                                    key:@"byteOffset"
                               required:NO
                                objName:objName
                                  error:error];
  if (*error)
    return nil;

  NSUInteger componentType = [GLTFDecoder getUInt:jsonDict
                                              key:@"componentType"
                                         required:YES
                                          objName:objName
                                            error:error];
  if (*error)
    return nil;
  if (!isValidGLTFAccessorComponentType(componentType)) {
    *error = [GLTFDecoder invalidFormatErrorWithKey:@"componentType"
                                            objName:objName];
    return nil;
  }
  obj.componentType = componentType;

  obj.extensions = [GLTFDecoder getExtensions:jsonDict];
  obj.extras = [GLTFDecoder getExtras:jsonDict];

  return obj;
}

#pragma mark - GLTFAccessorSparseValues

+ (nullable GLTFAccessorSparseValues *)
    decodeAccessorSparseValuesFromJson:(NSDictionary *)jsonDict
                                 error:(NSError **)error {
  NSString *const objName = @"GLTFAccessorSparseValues";
  GLTFAccessorSparseValues *obj = [[GLTFAccessorSparseValues alloc] init];

  obj.bufferView = [GLTFDecoder getUInt:jsonDict
                                    key:@"bufferView"
                               required:YES
                                objName:objName
                                  error:error];
  if (*error)
    return nil;

  obj.byteOffset = [GLTFDecoder getUInt:jsonDict
                                    key:@"byteOffset"
                               required:NO
                                objName:objName
                                  error:error];
  if (*error)
    return nil;

  obj.extensions = [GLTFDecoder getExtensions:jsonDict];
  obj.extras = [GLTFDecoder getExtras:jsonDict];

  return obj;
}

#pragma mark - GLTFMeshPrimitive

+ (nullable GLTFMeshPrimitive *)decodeMeshPrimitiveFromJson:
                                    (NSDictionary *)jsonDict
                                                      error:(NSError **)error {
  NSString *const objName = @"Mesh Primitive";
  GLTFMeshPrimitive *primitive = [[GLTFMeshPrimitive alloc] init];

  // Decode attributes
  NSDictionary *attributesDict = jsonDict[@"attributes"];
  if (!attributesDict) {
    *error = [GLTFDecoder missingDataErrorWithKey:@"attributes"
                                          objName:objName];
    return nil;
  }
  if (![attributesDict isKindOfClass:[NSDictionary class]]) {
    *error = [GLTFDecoder invalidFormatErrorWithKey:@"attributes"
                                            objName:objName];
    return nil;
  }
  NSMutableDictionary<NSString *, NSNumber *> *attributes =
      [NSMutableDictionary dictionary];
  for (NSString *key in attributesDict) {
    id value = attributesDict[key];
    if (![key isKindOfClass:[NSString class]] ||
        ![value isKindOfClass:[NSNumber class]]) {
      *error = [GLTFDecoder invalidFormatErrorWithKey:@"attributes"
                                              objName:objName];
      return nil;
    }
    attributes[key] = value;
  }
  primitive.attributes = [attributes copy];

  primitive.indices = [GLTFDecoder getUInt:jsonDict
                                       key:@"indices"
                                  required:NO
                                   objName:objName
                                     error:error];
  if (*error) {
    return nil;
  }

  primitive.material = [GLTFDecoder getUInt:jsonDict
                                        key:@"material"
                                   required:NO
                                    objName:objName
                                      error:error];
  if (*error) {
    return nil;
  }

  NSString *modeString = [GLTFDecoder getString:jsonDict
                                            key:@"mode"
                                       required:NO
                                        objName:objName
                                          error:error];
  if (*error) {
    return nil;
  }
  NSUInteger modeValue = modeString ? GLTFPrimitiveModeFromString(modeString)
                                    : GLTFPrimitiveModeTriangles;
  if (modeValue == NSNotFound) {
    *error = [GLTFDecoder invalidFormatErrorWithKey:@"mode" objName:objName];
    return nil;
  }
  primitive.mode = modeValue;

  primitive.targets = [GLTFDecoder getUIntegerArray:jsonDict
                                                key:@"targets"
                                           required:NO
                                            objName:objName
                                              error:error];
  if (*error) {
    return nil;
  }

  primitive.extensions = [GLTFDecoder getExtensions:jsonDict];
  primitive.extras = [GLTFDecoder getExtras:jsonDict];

  return primitive;
}

#pragma mark - GLTFNode

+ (nullable GLTFNode *)decodeNodeFromJson:(NSDictionary *)jsonDict
                                    error:(NSError **)error {
  NSString *const objName = @"GLTFNode";
  GLTFNode *node = [[GLTFNode alloc] init];

  node.camera = [GLTFDecoder getUInt:jsonDict
                                 key:@"camera"
                            required:NO
                             objName:objName
                               error:error];
  if (*error)
    return nil;

  node.children = [GLTFDecoder getUIntegerArray:jsonDict
                                            key:@"children"
                                       required:NO
                                        objName:objName
                                          error:error];
  if (*error)
    return nil;

  node.skin = [GLTFDecoder getUInt:jsonDict
                               key:@"skin"
                          required:NO
                           objName:objName
                             error:error];
  if (*error)
    return nil;

  simd_float4x4 defaultMatrix =
      (simd_float4x4){(simd_float4){1, 0, 0, 0}, (simd_float4){0, 1, 0, 0},
                      (simd_float4){0, 0, 1, 0}, (simd_float4){0, 0, 0, 1}};
  node.matrix = [GLTFDecoder getMatrix4x4:jsonDict
                                      key:@"matrix"
                             defaultValue:defaultMatrix
                                  objName:objName
                                    error:error];
  if (*error)
    return nil;

  node.mesh = [GLTFDecoder getUInt:jsonDict
                               key:@"mesh"
                          required:NO
                           objName:objName
                             error:error];
  if (*error)
    return nil;

  NSArray *defaultRotation = @[ @0, @0, @0, @1 ];
  node.rotation = [GLTFDecoder getNumberArray:jsonDict
                                          key:@"rotation"
                                     required:NO
                                      objName:objName
                                        error:error];
  if (*error)
    return nil;
  if (!node.rotation)
    node.rotation = defaultRotation;

  NSArray *defaultScale = @[ @1, @1, @1 ];
  node.scale = [GLTFDecoder getNumberArray:jsonDict
                                       key:@"scale"
                                  required:NO
                                   objName:objName
                                     error:error];
  if (*error)
    return nil;
  if (!node.scale)
    node.scale = defaultScale;

  NSArray *defaultTranslation = @[ @0, @0, @0 ];
  node.translation = [GLTFDecoder getNumberArray:jsonDict
                                             key:@"translation"
                                        required:NO
                                         objName:objName
                                           error:error];
  if (*error)
    return nil;
  if (!node.translation)
    node.translation = defaultTranslation;

  node.weights = [GLTFDecoder getNumberArray:jsonDict
                                         key:@"weights"
                                    required:NO
                                     objName:objName
                                       error:error];
  if (*error)
    return nil;

  node.name = [GLTFDecoder getString:jsonDict
                                 key:@"name"
                            required:NO
                             objName:objName
                               error:error];
  if (*error)
    return nil;

  node.extensions = [GLTFDecoder getExtensions:jsonDict];
  node.extras = [GLTFDecoder getExtras:jsonDict];

  return node;
}

#pragma mark - GLTFSampler

+ (nullable GLTFSampler *)decodeSamplerFromJson:(NSDictionary *)jsonDict
                                          error:(NSError **)error {
  NSString *const objName = @"GLTFSampler";
  GLTFSampler *sampler = [[GLTFSampler alloc] init];

  sampler.magFilter = [self getUInt:jsonDict
                                key:@"magFilter"
                           required:NO
                            objName:objName
                              error:error];
  if (*error)
    return nil;
  if (sampler.magFilter > 0 &&
      !isValidGLTFSamplerMagFilter(sampler.magFilter)) {
    *error = [GLTFDecoder invalidFormatErrorWithKey:@"magFilter"
                                            objName:objName];
    return nil;
  }

  sampler.minFilter = [self getUInt:jsonDict
                                key:@"minFilter"
                           required:NO
                            objName:objName
                              error:error];
  if (*error)
    return nil;
  if (sampler.minFilter > 0 &&
      !isValidGLTFSamplerMinFilter(sampler.minFilter)) {
    *error = [GLTFDecoder invalidFormatErrorWithKey:@"minFilter"
                                            objName:objName];
    return nil;
  }

  sampler.wrapS = [self getUInt:jsonDict
                            key:@"wrapS"
                       required:NO
                        objName:objName
                          error:error];
  if (*error)
    return nil;
  if (sampler.wrapS == 0)
    sampler.wrapS = GLTFSamplerWrapModeRepeat;
  if (!isValidGLTFSamplerWrapMode(sampler.wrapS)) {
    *error = [GLTFDecoder invalidFormatErrorWithKey:@"wrapS" objName:objName];
    return nil;
  }

  sampler.wrapT = [self getUInt:jsonDict
                            key:@"wrapT"
                       required:NO
                        objName:objName
                          error:error];
  if (*error)
    return nil;
  if (sampler.wrapT == 0)
    sampler.wrapT = GLTFSamplerWrapModeRepeat;

  if (!isValidGLTFSamplerWrapMode(sampler.wrapT)) {
    *error = [GLTFDecoder invalidFormatErrorWithKey:@"wrapT" objName:objName];
    return nil;
  }

  sampler.name = [self getString:jsonDict
                             key:@"name"
                        required:NO
                         objName:objName
                           error:error];
  if (*error)
    return nil;

  sampler.extensions = [self getExtensions:jsonDict];
  sampler.extras = [self getExtras:jsonDict];

  return sampler;
}

#pragma mark - GLTFScene

+ (nullable GLTFScene *)decodeSceneFromJson:(NSDictionary *)jsonDict
                                      error:(NSError **)error {
  NSString *const objName = @"GLTFScene";
  GLTFScene *scene = [[GLTFScene alloc] init];

  scene.nodes = [self getUIntegerArray:jsonDict
                                   key:@"nodes"
                              required:NO
                               objName:objName
                                 error:error];
  if (*error)
    return nil;

  scene.name = [self getString:jsonDict
                           key:@"name"
                      required:NO
                       objName:objName
                         error:error];
  if (*error)
    return nil;

  scene.extensions = [self getExtensions:jsonDict];
  scene.extras = [self getExtras:jsonDict];

  return scene;
}

#pragma mark - GLTFSkin

+ (nullable GLTFSkin *)decodeSkinFromJson:(NSDictionary *)jsonDict
                                    error:(NSError **)error {
  NSString *const objName = @"GLTFSkin";
  GLTFSkin *skin = [[GLTFSkin alloc] init];

  skin.inverseBindMatrices = [self getUInt:jsonDict
                                       key:@"inverseBindMatrices"
                                  required:NO
                                   objName:objName
                                     error:error];
  if (*error)
    return nil;

  skin.skeleton = [self getUInt:jsonDict
                            key:@"skeleton"
                       required:NO
                        objName:objName
                          error:error];
  if (*error)
    return nil;

  skin.joints = [self getUIntegerArray:jsonDict
                                   key:@"joints"
                              required:YES
                               objName:objName
                                 error:error];
  if (*error)
    return nil;

  skin.name = [self getString:jsonDict
                          key:@"name"
                     required:NO
                      objName:objName
                        error:error];
  if (*error)
    return nil;

  skin.extensions = [self getExtensions:jsonDict];
  skin.extras = [self getExtras:jsonDict];

  return skin;
}

#pragma mark - GLTFTexture

+ (nullable GLTFTexture *)decodeTextureFromJson:(NSDictionary *)jsonDict
                                          error:(NSError **)error {
  NSString *const objName = @"GLTFTexture";
  GLTFTexture *texture = [[GLTFTexture alloc] init];

  texture.sampler = [self getUInt:jsonDict
                              key:@"sampler"
                         required:NO
                          objName:objName
                            error:error];
  if (*error)
    return nil;

  texture.source = [self getUInt:jsonDict
                             key:@"source"
                        required:NO
                         objName:objName
                           error:error];
  if (*error)
    return nil;

  texture.name = [self getString:jsonDict
                             key:@"name"
                        required:NO
                         objName:objName
                           error:error];
  if (*error)
    return nil;

  texture.extensions = [self getExtensions:jsonDict];
  texture.extras = [self getExtras:jsonDict];

  return texture;
}

#pragma mark - GLTFTextureInfo

+ (nullable GLTFTextureInfo *)decodeTextureInfoFromJson:(NSDictionary *)jsonDict
                                                  error:(NSError **)error {
  NSString *const objName = @"GLTFTextureInfo";
  GLTFTextureInfo *textureInfo = [[GLTFTextureInfo alloc] init];

  textureInfo.index = [self getUInt:jsonDict
                                key:@"index"
                           required:YES
                            objName:objName
                              error:error];
  if (*error)
    return nil;

  textureInfo.texCoord = [self getUInt:jsonDict
                                   key:@"texCoord"
                              required:NO
                               objName:objName
                                 error:error];
  if (*error)
    return nil;

  textureInfo.extensions = [self getExtensions:jsonDict];
  textureInfo.extras = [self getExtras:jsonDict];

  return textureInfo;
}

@end
