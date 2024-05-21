#import "GLTF2Availability.h"
#import <Foundation/Foundation.h>

GLTF_EXPORT NSString *const GLTFErrorDomainInput;
GLTF_EXPORT NSString *const GLTFErrorDomainKeyNotFound;
GLTF_EXPORT NSString *const GLTFErrorDomainInvalidFormat;

typedef NS_ENUM(NSInteger, GLTFErrorCode) {
  GLTFInputError = 1000,
  GLTFKeyNotFoundError = 1001,
  GLTFInvalidFormatError = 1002,
};
