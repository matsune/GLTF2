#import "GLTF2Availability.h"
#import "GLTFJson.h"
#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>
#import <Metal/Metal.h>

NS_ASSUME_NONNULL_BEGIN

GLTF_EXPORT @interface GLTFData : NSObject

@property(nonatomic, strong, readonly) GLTFJson *json;
@property(nonatomic, copy, nullable, readonly) NSString *path;
@property(nonatomic, strong, nullable) NSData *binary;
@property(nonatomic, strong) id<MTLDevice> device;

- (instancetype)initWithJson:(GLTFJson *)json
                        path:(nullable NSString *)path
                      binary:(nullable NSData *)binary;

+ (nullable instancetype)dataWithFile:(NSString *)path
                                error:(NSError *_Nullable *_Nullable)error;

+ (nullable instancetype)dataWithGlbData:(NSData *)data
                                   error:(NSError *_Nullable *_Nullable)error;

+ (nullable instancetype)dataWithGltfData:(NSData *)data
                                     path:(nullable NSString *)path
                                    error:(NSError *_Nullable *_Nullable)error;

- (nullable NSData *)dataOfUri:(NSString *)uri;

- (NSData *)dataForBuffer:(GLTFBuffer *)buffer;
- (NSData *)dataForBufferIndex:(NSInteger)bufferIndex;
- (NSData *)dataForBufferView:(GLTFBufferView *)bufferView;
- (NSData *)dataForBufferViewIndex:(NSInteger)bufferViewIndex;

- (id<MTLTexture>)mtlTextureForImage:(GLTFImage *)image;

- (NSData *)dataForAccessor:(GLTFAccessor *)accessor;

@end

NS_ASSUME_NONNULL_END
