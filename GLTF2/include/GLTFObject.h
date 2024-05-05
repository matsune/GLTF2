#import "GLTF2Availability.h"
#import "GLTFJson.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

GLTF_EXPORT @interface GLTFObject : NSObject

@property(nonatomic, strong, readonly) GLTFJson *json;
@property(nonatomic, strong, readonly) NSArray<NSData *> *bufferDatas;
@property(nonatomic, strong, readonly) NSArray<NSData *> *imageDatas;

- (instancetype)initWithJson:(GLTFJson *)json
                 bufferDatas:(NSArray<NSData *> *)bufferDatas
                  imageDatas:(NSArray<NSData *> *)imageDatas;

+ (nullable instancetype)objectWithFile:(NSString *)path
                                  error:(NSError *_Nullable *_Nullable)error;

+ (nullable instancetype)objectWithGlbFile:(NSString *)path
                                     error:(NSError *_Nullable *_Nullable)error;

+ (nullable instancetype)objectWithGlbData:(NSData *)data
                                     error:(NSError *_Nullable *_Nullable)error;

+ (nullable instancetype)objectWithGltfFile:(NSString *)path
                                      error:
                                          (NSError *_Nullable *_Nullable)error;

+ (nullable instancetype)objectWithGltfData:(NSData *)jsonData
                                      error:
                                          (NSError *_Nullable *_Nullable)error;

- (NSData *)dataByAccessor:(GLTFAccessor *)accessor;

@end

NS_ASSUME_NONNULL_END
