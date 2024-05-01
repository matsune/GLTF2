#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GLTFBuffer : NSObject

@property(nonatomic, strong) NSData *data;
@property(nonatomic, copy, nullable) NSString *name;

- (instancetype)initWithData:(NSData *)data name:(nullable NSString *)name;

+ (instancetype)data:(NSData *)data name:(nullable NSString *)name;

@end

NS_ASSUME_NONNULL_END
