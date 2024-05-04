#import "ViewController.h"
#import "GLTF2.h"
#import "GLTFJson.h"
#import "config.h"
#import <Foundation/Foundation.h>
#import <Metal/Metal.h>

@interface ViewController ()

@end

@implementation ViewController

SCNGeometryPrimitiveType SCNPrimitiveTypeFromMode(NSInteger mode) {
  switch (mode) {
  case GLTFMeshPrimitiveModePoints:
    return SCNGeometryPrimitiveTypePoint;
  case GLTFMeshPrimitiveModeLines:
    return SCNGeometryPrimitiveTypeLine;
  case GLTFMeshPrimitiveModeTriangles:
    return SCNGeometryPrimitiveTypeTriangles;
  case GLTFMeshPrimitiveModeTriangleStrip:
    return SCNGeometryPrimitiveTypeTriangleStrip;

    // TODO:
  case GLTFMeshPrimitiveModeLineLoop:
  case GLTFMeshPrimitiveModeLineStrip:
  case GLTFMeshPrimitiveModeTriangleFan:
  default:
    abort();
  }
}

NSInteger primitiveCountFromMode(NSInteger indexCount, NSInteger mode) {
  switch (mode) {
  case GLTFMeshPrimitiveModePoints:
    return indexCount;
  case GLTFMeshPrimitiveModeLines:
    return indexCount / 2;
  case GLTFMeshPrimitiveModeLineLoop:
    return indexCount;
  case GLTFMeshPrimitiveModeLineStrip:
    return indexCount - 1;
  case GLTFMeshPrimitiveModeTriangles:
    return indexCount / 3;
  case GLTFMeshPrimitiveModeTriangleStrip:
    return indexCount - 2;
  case GLTFMeshPrimitiveModeTriangleFan:
    return indexCount - 2;
  default:
    return indexCount;
  }
}

SCNGeometrySource *
SCNGeometrySourceFromAccessorWithSemantic(GLTFObject *object,
                                          GLTFAccessor *accessor,
                                          SCNGeometrySourceSemantic semantic) {
  NSData *data = [object dataByAccessor:accessor];
  NSInteger componentsPerVector = componentsCountOfAccessorType(accessor.type);
  NSInteger bytesPerComponent = sizeOfComponentType(accessor.componentType);
  NSInteger dataStride = componentsPerVector * bytesPerComponent;

  return
      [SCNGeometrySource geometrySourceWithData:data
                                       semantic:semantic
                                    vectorCount:accessor.count
                                floatComponents:accessor.componentType ==
                                                GLTFAccessorComponentTypeFloat
                            componentsPerVector:componentsPerVector
                              bytesPerComponent:bytesPerComponent
                                     dataOffset:0
                                     dataStride:dataStride];
}

SCNGeometrySourceSemantic
SCNGeometrySourceSemanticFromString(NSString *semantic) {
  if ([semantic isEqualToString:GLTFMeshPrimitiveAttributeSemanticPosition]) {
    return SCNGeometrySourceSemanticVertex;
  } else if ([semantic
                 isEqualToString:GLTFMeshPrimitiveAttributeSemanticNormal]) {
    return SCNGeometrySourceSemanticNormal;
  } else if ([semantic
                 isEqualToString:GLTFMeshPrimitiveAttributeSemanticTangent]) {
    return SCNGeometrySourceSemanticTangent;
  } else if ([semantic
                 isEqualToString:GLTFMeshPrimitiveAttributeSemanticColor]) {
    return SCNGeometrySourceSemanticColor;
  } else if ([semantic
                 isEqualToString:GLTFMeshPrimitiveAttributeSemanticJoints]) {
    abort();
  } else if ([semantic
                 isEqualToString:GLTFMeshPrimitiveAttributeSemanticWeights]) {
    return SCNGeometrySourceSemanticBoneWeights;
  }
}

- (void)addSCNGeometrySourceToSources:(NSMutableArray *)sources
                               object:(GLTFObject *)object
                        fromPrimitive:(GLTFMeshPrimitive *)primitive
                             semantic:(NSString *)semantic {
  NSNumber *index = [primitive valueOfSemantic:semantic];
  if (index) {
    GLTFAccessor *accessor = object.json.accessors[index.integerValue];
    [sources addObject:SCNGeometrySourceFromAccessorWithSemantic(
                           object, accessor,
                           SCNGeometrySourceSemanticFromString(semantic))];
  }
}

- (void)addSCNGeometrySourcesToSources:(NSMutableArray *)sources
                                object:(GLTFObject *)object
                         fromPrimitive:(GLTFMeshPrimitive *)primitive
                              semantic:(NSString *)semantic {
  NSArray<NSNumber *> *indices = [primitive valuesOfSemantic:semantic];
  for (NSNumber *index in indices) {
    GLTFAccessor *accessor = object.json.accessors[index.integerValue];
    [sources addObject:SCNGeometrySourceFromAccessorWithSemantic(
                           object, accessor,
                           SCNGeometrySourceSemanticFromString(semantic))];
  }
}

- (SCNGeometry *)scnGeometryFromMeshPrimitive:(GLTFMeshPrimitive *)primitive
                                       object:(GLTFObject *)object {
  NSMutableArray<SCNGeometrySource *> *sources = [NSMutableArray array];
  NSMutableArray<SCNGeometryElement *> *elements = [NSMutableArray array];

  [self
      addSCNGeometrySourceToSources:sources
                             object:object
                      fromPrimitive:primitive
                           semantic:GLTFMeshPrimitiveAttributeSemanticPosition];
  [self addSCNGeometrySourceToSources:sources
                               object:object
                        fromPrimitive:primitive
                             semantic:GLTFMeshPrimitiveAttributeSemanticNormal];
  [self
      addSCNGeometrySourceToSources:sources
                             object:object
                      fromPrimitive:primitive
                           semantic:GLTFMeshPrimitiveAttributeSemanticTangent];
  [self addSCNGeometrySourcesToSources:sources
                                object:object
                         fromPrimitive:primitive
                              semantic:
                                  GLTFMeshPrimitiveAttributeSemanticTexcoord];
  [self addSCNGeometrySourcesToSources:sources
                                object:object
                         fromPrimitive:primitive
                              semantic:GLTFMeshPrimitiveAttributeSemanticColor];
  //          [self addSCNGeometrySourcesToSources:sources object:object
  //          fromPrimitive:primitive
  //          semantic:GLTFMeshPrimitiveAttributeSemanticJoints];
  [self
      addSCNGeometrySourcesToSources:sources
                              object:object
                       fromPrimitive:primitive
                            semantic:GLTFMeshPrimitiveAttributeSemanticWeights];

  if (primitive.indices) {
    GLTFAccessor *accessor =
        object.json.accessors[primitive.indices.integerValue];
    if (accessor.bufferView) {
      NSData *bufferData = [object dataByAccessor:accessor];

      SCNGeometryElement *element = [SCNGeometryElement
          geometryElementWithData:bufferData
                    primitiveType:SCNPrimitiveTypeFromMode(primitive.mode)
                   primitiveCount:primitiveCountFromMode(accessor.count,
                                                         primitive.mode)
                    bytesPerIndex:sizeOfComponentType(accessor.componentType)];
      [elements addObject:element];
    }
  }

  SCNGeometry *geometry = [SCNGeometry geometryWithSources:sources
                                                  elements:elements];

  if (primitive.material) {
    // TODO:
    GLTFMaterial *material =
        object.json.materials[primitive.material.integerValue];
    SCNMaterial *scnMaterial = [SCNMaterial material];

    GLTFMaterialPBRMetallicRoughness *pbrMetallicRoughness =
        material.pbrMetallicRoughness
            ?: [[GLTFMaterialPBRMetallicRoughness alloc] init];
    scnMaterial.diffuse.contents = [NSColor
        colorWithSRGBRed:[pbrMetallicRoughness.baseColorFactor[0] floatValue]
                   green:[pbrMetallicRoughness.baseColorFactor[1] floatValue]
                    blue:[pbrMetallicRoughness.baseColorFactor[2] floatValue]
                   alpha:[pbrMetallicRoughness.baseColorFactor[3] floatValue]];
    scnMaterial.metalness.intensity = pbrMetallicRoughness.metallicFactor;
    scnMaterial.roughness.intensity = pbrMetallicRoughness.roughnessFactor;

    geometry.materials = @[ scnMaterial ];
  }

  return geometry;
}

- (SCNNode *)scnNodeFromGLTFMesh:(GLTFMesh *)mesh object:(GLTFObject *)object {
  SCNNode *node = [SCNNode node];

  NSMutableArray<SCNNode *> *childNodes = [NSMutableArray array];
  for (GLTFMeshPrimitive *primitive in mesh.primitives) {
    SCNGeometry *geometry = [self scnGeometryFromMeshPrimitive:primitive
                                                        object:object];
    SCNNode *geometryNode = [SCNNode nodeWithGeometry:geometry];
    [node addChildNode:geometryNode];
  }
  if (mesh.weights) {
  }

  return node;
}

- (SCNNode *)scnNodeFromGLTFNode:(GLTFNode *)node object:(GLTFObject *)object {
  SCNNode *scnNode = [SCNNode node];

  if (node.mesh) {
    GLTFMesh *mesh = object.json.meshes[node.mesh.integerValue];
    SCNNode *meshNode = [self scnNodeFromGLTFMesh:mesh object:object];
    [scnNode addChildNode:meshNode];
  }

  scnNode.simdTransform = node.matrix;

  if (node.rotation) {
  }
  if (node.scale) {
  }
  if (node.translation) {
  }

  if (node.children) {
    for (NSNumber *childIndex in node.children) {
      GLTFNode *childNode = object.json.nodes[childIndex.integerValue];
      SCNNode *childScnNode = [self scnNodeFromGLTFNode:childNode
                                                 object:object];
      [scnNode addChildNode:childScnNode];
    }
  }

  return scnNode;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  NSURL *url = [[NSURL fileURLWithPath:SAMPLE_MODELS_DIR]
      URLByAppendingPathComponent:@"Box/glTF-Embedded/Box.gltf"];
  NSError *err;
  GLTFObject *object = [GLTFObject objectWithGltfFile:[url path] error:&err];
  if (err) {
    NSLog(@"%@", err);
    abort();
  }

  self.scnView.autoenablesDefaultLighting = YES;
  self.scnView.allowsCameraControl = YES;

  NSMutableArray<SCNScene *> *scnScenes = [NSMutableArray array];
  if (object.json.scenes) {
    for (GLTFScene *scene in object.json.scenes) {
      SCNScene *scnScene = [SCNScene scene];
      for (NSNumber *nodeIndex in scene.nodes) {
        GLTFNode *node = object.json.nodes[nodeIndex.integerValue];
        SCNNode *scnNode = [self scnNodeFromGLTFNode:node object:object];
        [scnScene.rootNode addChildNode:scnNode];
      }

      //            // default camera
      //            SCNCamera *camera = [SCNCamera camera];
      //            SCNNode *cameraNode = [SCNNode node];
      //            cameraNode.camera = camera;
      //            cameraNode.position = SCNVector3Make(0, 0, 5);
      //            [scnScene.rootNode addChildNode:cameraNode];

      [scnScenes addObject:scnScene];
    }
  }

  if (object.json.scene) {
    SCNScene *scene = scnScenes[object.json.scene.integerValue];
    self.scnView.scene = scene;
  } else {
    if (scnScenes.count > 0) {
      self.scnView.scene = scnScenes.firstObject;
    }
  }

}

@end
