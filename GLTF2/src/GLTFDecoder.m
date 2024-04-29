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
             required:(BOOL)required
              objName:(const NSString *)objName
                error:(NSError **)error {
  NSNumber *value = jsonDict[key];

  if (!value) {
    if (required) {
      *error = [GLTFDecoder missingDataErrorWithKey:key objName:objName];
      return 0;
    } else {
      // default value
      return 0;
    }
  }

  if ([value isKindOfClass:[NSNumber class]]) {
    return [value unsignedIntegerValue];
  } else {
    *error = [GLTFDecoder invalidFormatErrorWithKey:key objName:objName];
    return 0;
  }
}

+ (nullable NSDictionary *)getExtensions:(const NSDictionary *)jsonDict {
  id extensions = jsonDict[@"extensions"];
  if ([extensions isKindOfClass:[NSDictionary class]]) {
    return extensions;
  }
  return nil;
}

+ (nullable NSDictionary *)getExtras:(const NSDictionary *)jsonDict {
  id extras = jsonDict[@"extras"];
  if ([extras isKindOfClass:[NSDictionary class]]) {
    return extras;
  }
  return nil;
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

@end
