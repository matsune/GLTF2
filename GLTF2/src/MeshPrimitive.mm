#import "MeshPrimitive.h"

@implementation MeshPrimitiveSource

+ (instancetype)sourceWithData:(NSData *)data
                   vectorCount:(NSInteger)vectorCount
           componentsPerVector:(NSInteger)componentsPerVector
                 componentType:(GLTFAccessorComponentType)componentType {
  MeshPrimitiveSource *instance = [[super alloc] init];
  if (instance) {
    instance.data = data;
    instance.vectorCount = vectorCount;
    instance.componentsPerVector = componentsPerVector;
    instance.componentType = componentType;
  }
  return instance;
}

@end

@implementation MeshPrimitiveElement

+ (instancetype)elementWithData:(NSData *)data
                  primitiveMode:(GLTFMeshPrimitiveMode)primitiveMode
                 primitiveCount:(NSInteger)primitiveCount
                  componentType:(GLTFAccessorComponentType)componentType {
  MeshPrimitiveElement *instance = [[super alloc] init];
  if (instance) {
    instance.data = data;
    instance.primitiveMode = primitiveMode;
    instance.primitiveCount = primitiveCount;
    instance.componentType = componentType;
  }
  return instance;
}

@end

@implementation MeshPrimitiveSources

@end

@implementation MeshPrimitive

@end
