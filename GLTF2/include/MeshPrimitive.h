#import "GLTFJson.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MeshPrimitiveSource : NSObject

@property(nonatomic, strong) NSData *data;
@property(nonatomic, assign) NSInteger vectorCount;
@property(nonatomic, assign) NSInteger componentsPerVector;
@property(nonatomic, assign) GLTFAccessorComponentType componentType;

+ (instancetype)sourceWithData:(NSData *)data
                   vectorCount:(NSInteger)vectorCount
           componentsPerVector:(NSInteger)componentsPerVector
                 componentType:(GLTFAccessorComponentType)componentType;

@end

@interface MeshPrimitiveElement : NSObject

@property(nonatomic, strong) NSData *data;
@property(nonatomic, assign) GLTFMeshPrimitiveMode primitiveMode;
@property(nonatomic, assign) NSInteger primitiveCount;
@property(nonatomic, assign) GLTFAccessorComponentType componentType;

+ (instancetype)elementWithData:(NSData *)data
                  primitiveMode:(GLTFMeshPrimitiveMode)primitiveMode
                 primitiveCount:(NSInteger)primitiveCount
                  componentType:(GLTFAccessorComponentType)componentType;

@end

@interface MeshPrimitiveSources : NSObject

@property(nonatomic, strong, nullable) MeshPrimitiveSource *position;
@property(nonatomic, strong, nullable) MeshPrimitiveSource *normal;
@property(nonatomic, strong, nullable) MeshPrimitiveSource *tangent;
@property(nonatomic, strong, nullable)
    NSArray<MeshPrimitiveSource *> *texcoords;
@property(nonatomic, strong, nullable) NSArray<MeshPrimitiveSource *> *colors;
@property(nonatomic, strong, nullable) NSArray<MeshPrimitiveSource *> *joints;
@property(nonatomic, strong, nullable) NSArray<MeshPrimitiveSource *> *weights;

@end

@interface MeshPrimitive : NSObject

@property(nonatomic, strong) MeshPrimitiveSources *sources;
@property(nonatomic, strong, nullable) MeshPrimitiveElement *element;

- (instancetype)initWithSources:(MeshPrimitiveSources *)sources;
- (instancetype)initWithSources:(MeshPrimitiveSources *)sources
                        element:(MeshPrimitiveElement *)element;

@end

NS_ASSUME_NONNULL_END
