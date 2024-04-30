#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GLTFObject : NSObject

@property(nonatomic, strong, nullable) NSData *buffer;

+ (nullable instancetype)objectWithGlbFile:(NSString *)path
                                     error:(NSError *_Nullable *_Nullable)error;

@end

NS_ASSUME_NONNULL_END
