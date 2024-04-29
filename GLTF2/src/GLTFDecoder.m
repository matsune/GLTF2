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

@end
