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
  return [NSError errorWithDomain:GLTF2ErrorDomain
                             code:GLTF2ErrorInvalidFormat
                         userInfo:@{
                           NSLocalizedDescriptionKey : [NSString
                               stringWithFormat:
                                   @"Unexpected value type for key '%@' in %@.",
                                   key, objName]
                         }];
}

+ (NSUInteger)getUInt:(const NSDictionary *)jsonDict
                  key:(const NSString *)key
              objName:(const NSString *)objName
                error:(NSError **)error {
  NSNumber *value = jsonDict[key];

  if (!value) {
    *error = [GLTFDecoder missingDataErrorWithKey:key objName:objName];
    return NSNotFound;
  }

  if ([value isKindOfClass:[NSNumber class]]) {
    return [value unsignedIntegerValue];
  } else {
    *error = [GLTFDecoder invalidFormatErrorWithKey:key objName:objName];
    return NSNotFound;
  }
}

+ (NSUInteger)getUInt:(const NSDictionary *)jsonDict
                  key:(const NSString *)key
         defaultValue:(NSUInteger)defaultValue
              objName:(const NSString *)objName
                error:(NSError **)error {
  NSNumber *value = jsonDict[key];

  if (!value) {
    return defaultValue;
  }

  if ([value isKindOfClass:[NSNumber class]]) {
    return [value unsignedIntegerValue];
  } else {
    *error = [GLTFDecoder invalidFormatErrorWithKey:key objName:objName];
    return NSNotFound;
  }
}

+ (NSString *)getString:(const NSDictionary *)jsonDict
                    key:(const NSString *)key
                objName:(const NSString *)objName
                  error:(NSError **)error {
  NSString *value = jsonDict[key];
  if (!value) {
    *error = [GLTFDecoder missingDataErrorWithKey:key objName:objName];
    return nil;
  }

  if ([value isKindOfClass:[NSString class]]) {
    return value;
  } else {
    *error = [GLTFDecoder invalidFormatErrorWithKey:key objName:objName];
    return nil;
  }
}

+ (NSString *)getString:(const NSDictionary *)jsonDict
                    key:(const NSString *)key
           defaultValue:(NSString *)defaultValue
                objName:(const NSString *)objName
                  error:(NSError **)error {
  NSString *value = jsonDict[key];
  if (!value) {
    return defaultValue;
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

+ (nullable NSDictionary *)getExtensions:(const NSDictionary *)jsonDict {
  return [GLTFDecoder getDict:jsonDict key:@"extensions"];
}

+ (nullable NSDictionary *)getExtras:(const NSDictionary *)jsonDict {
  return [GLTFDecoder getDict:jsonDict key:@"extras"];
}

#pragma mark - GLTFAccessorSparse

+ (nullable GLTFAccessorSparse *)
    decodeAccessorSparseFromJson:(NSDictionary *)jsonDict
                           error:(NSError **)error {
  NSString *const objName = @"GLTFAccessorSparse";
  GLTFAccessorSparse *sparse = [[GLTFAccessorSparse alloc] init];

  sparse.count = [GLTFDecoder getUInt:jsonDict
                                  key:@"count"
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
                                objName:objName
                                  error:error];
  if (*error)
    return nil;

  obj.byteOffset = [GLTFDecoder getUInt:jsonDict
                                    key:@"byteOffset"
                           defaultValue:0
                                objName:objName
                                  error:error];
  if (*error)
    return nil;

  NSUInteger componentType = [GLTFDecoder getUInt:jsonDict
                                              key:@"componentType"
                                          objName:objName
                                            error:error];
  if (*error)
    return nil;
  switch (componentType) {
  case GLTFAccessorSparseIndicesComponentTypeUnsignedByte:
    obj.componentType = GLTFAccessorSparseIndicesComponentTypeUnsignedByte;
    break;
  case GLTFAccessorSparseIndicesComponentTypeUnsignedShort:
    obj.componentType = GLTFAccessorSparseIndicesComponentTypeUnsignedShort;
    break;
  case GLTFAccessorSparseIndicesComponentTypeUnsignedInt:
    obj.componentType = GLTFAccessorSparseIndicesComponentTypeUnsignedInt;
    break;
  default:
    *error = [GLTFDecoder invalidFormatErrorWithKey:@"componentType"
                                            objName:objName];
    return nil;
  }

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
                                objName:objName
                                  error:error];
  if (*error)
    return nil;

  obj.byteOffset = [GLTFDecoder getUInt:jsonDict
                                    key:@"byteOffset"
                           defaultValue:0
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
                     defaultValue:NSNotFound
                          objName:objName
                            error:error];
  if (*error)
    return nil;

  texture.source = [self getUInt:jsonDict
                             key:@"source"
                    defaultValue:NSNotFound
                         objName:objName
                           error:error];
  if (*error)
    return nil;

  texture.name = [self getString:jsonDict
                             key:@"name"
                    defaultValue:nil
                         objName:objName
                           error:error];
  if (*error)
    return nil;

  texture.extensions = [self getExtensions:jsonDict];
  texture.extras = [self getExtras:jsonDict];

  return texture;
}

@end
