#import "GLTF2Availability.h"
#include "GLTF2.h"
#import "GLTFJson.h"
#import "MeshPrimitive.h"
#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>
#include <memory>

NS_ASSUME_NONNULL_BEGIN

GLTF_EXPORT @interface GLTFData : NSObject {
  std::unique_ptr<gltf2::GLTFData> _data;
}

//@property(nonatomic, strong, readonly) GLTFJson *json;
//@property(nonatomic, copy, nullable, readonly) NSString *path;
//@property(nonatomic, strong, nullable) NSData *binary;
//
- (instancetype)initWithData:(std::unique_ptr<gltf2::GLTFData>)data;
//- (instancetype)initWithJson:(GLTFJson *)json
//                        path:(nullable NSString *)path
//                      binary:(nullable NSData *)binary;
//
+ (nullable instancetype)dataWithFile:(NSString *)path
                                error:(NSError *_Nullable *_Nullable)error;

//+ (nullable instancetype)dataWithGlbData:(NSData *)data
//                                   error:(NSError *_Nullable *_Nullable)error;
//
+ (nullable instancetype)dataWithData:(NSData *)data
                                 path:(nullable NSString *)path
                                error:(NSError *_Nullable *_Nullable)error;

//+ (NSArray<NSString *> *)supportedExtensions;
//+ (BOOL)isSupportedExtension:(NSString *)extension;
//- (nullable NSData *)dataOfUri:(NSString *)uri;
//
//- (NSData *)dataForBuffer:(GLTFBuffer *)buffer;
//- (NSData *)dataForBufferIndex:(NSInteger)bufferIndex;
//- (NSData *)dataForBufferView:(GLTFBufferView *)bufferView;
//- (NSData *)dataForBufferViewIndex:(NSInteger)bufferViewIndex;
//
//- (CGImageRef)cgImageForImage:(GLTFImage *)image;
//
//- (NSData *)dataForAccessor:(GLTFAccessor *)accessor
//                 normalized:(nullable BOOL *)normalized;
//
//- (MeshPrimitive *)meshPrimitive:(GLTFMeshPrimitive *)primitive;
//- (MeshPrimitiveSource *)meshPrimitiveSourceFromAccessor:
//    (GLTFAccessor *)accessor;
//- (MeshPrimitiveSources *)meshPrimitiveSourcesFromTarget:
//    (GLTFMeshPrimitiveTarget *)target;

@end

NS_ASSUME_NONNULL_END
