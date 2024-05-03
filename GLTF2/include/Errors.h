#import "GLTF2Availability.h"
#import <Foundation/Foundation.h>

GLTF_EXPORT NSString *const GLTF2BinaryErrorDomain;
GLTF_EXPORT NSString *const GLTF2DecodeErrorDomain;

typedef NS_ENUM(NSInteger, GLTF2ErrorCode) {
  GLTF2BinaryErrorInvalidFormat = 1001,
  GLTF2DecodeErrorMissingData = 2001,
};
