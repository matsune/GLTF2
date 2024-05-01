#import "GLTFBuffer.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GLTFObject : NSObject

@property(nonatomic, strong) NSArray<GLTFBuffer *> *buffers;

+ (nullable instancetype)objectWithGlbFile:(NSString *)path
                                     error:(NSError *_Nullable *_Nullable)error;

+ (nullable instancetype)objectWithGlbData:(NSData *)data
                                     error:(NSError *_Nullable *_Nullable)error;

+ (nullable instancetype)objectWithGltfFile:(NSString *)path
                                      error:
                                          (NSError *_Nullable *_Nullable)error;

@end

NS_ASSUME_NONNULL_END
