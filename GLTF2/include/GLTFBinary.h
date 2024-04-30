#import "GLTFJson.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GLTFBinary : NSObject

@property(nonatomic, assign) NSInteger version;
@property(nonatomic, strong) GLTFJson *json;
@property(nonatomic, strong, nullable) NSData *binary;

+ (nullable instancetype)binaryWithData:(NSData *)data
                                  error:(NSError *_Nullable *_Nullable)error;

@end

NS_ASSUME_NONNULL_END
