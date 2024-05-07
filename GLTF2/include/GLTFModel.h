#import "GLTF2Availability.h"
#import "GLTFJson.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

GLTF_EXPORT @interface GLTFModel : NSObject

@property(nonatomic, strong, readonly) GLTFJson *json;
@property(nonatomic, copy, nullable, readonly) NSString *path;
@property(nonatomic, strong) NSArray<NSData *> *bufferDatas;
@property(nonatomic, strong) NSArray<NSData *> *imageDatas;

- (instancetype)initWithJson:(GLTFJson *)json path:(nullable NSString *)path;

+ (nullable instancetype)objectWithFile:(NSString *)path
                                  error:(NSError *_Nullable *_Nullable)error;

+ (nullable instancetype)objectWithGlbData:(NSData *)data
                                     error:(NSError *_Nullable *_Nullable)error;

+ (nullable instancetype)objectWithGltfData:(NSData *)data
                                       path:(nullable NSString *)path
                                      error:
                                          (NSError *_Nullable *_Nullable)error;

- (NSData *)dataForBuffer:(GLTFBuffer *)buffer;

- (NSData *)dataForImage:(GLTFImage *)image;

- (NSData *)dataOfUri:(NSString *)uri;

- (NSData *)dataFromBufferViewIndex:(NSInteger)bufferViewIndex
                         byteOffset:(NSInteger)byteOffset;

- (NSData *)dataFromBufferView:(GLTFBufferView *)bufferView
                    byteOffset:(NSInteger)byteOffset;

- (NSData *)dataByAccessor:(GLTFAccessor *)accessor;

@end

NS_ASSUME_NONNULL_END
