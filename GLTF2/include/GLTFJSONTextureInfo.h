#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GLTFJSONTextureInfo : NSObject

@property(nonatomic, assign) NSInteger index;
@property(nonatomic, assign) NSInteger texCoord;
@property(nonatomic, strong, nullable) NSDictionary *extensions;
@property(nonatomic, strong, nullable) NSDictionary *extras;

@end

NS_ASSUME_NONNULL_END
