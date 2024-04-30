#import <Foundation/Foundation.h>

extern NSString *const GLTF2BinaryErrorDomain;
extern NSString *const GLTF2DecodeErrorDomain;

typedef NS_ENUM(NSInteger, GLTF2ErrorCode) {
  GLTF2BinaryErrorInvalidFormat = 1001,
  GLTF2DecodeErrorMissingData = 2001,
};
