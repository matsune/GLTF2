#import "GLTF2Object+SceneKit.h"

static SCNGeometrySourceSemantic
SCNGeometrySourceSemanticFromGLTFMeshPrimitiveAttributeSemantic(
    NSString *semantic) {
  if ([semantic isEqualToString:GLTFMeshPrimitiveAttributeSemanticPosition]) {
    return SCNGeometrySourceSemanticVertex;
  } else if ([semantic
                 isEqualToString:GLTFMeshPrimitiveAttributeSemanticNormal]) {
    return SCNGeometrySourceSemanticNormal;
  } else if ([semantic
                 isEqualToString:GLTFMeshPrimitiveAttributeSemanticTangent]) {
    return SCNGeometrySourceSemanticTangent;
  } else if ([semantic
                 isEqualToString:GLTFMeshPrimitiveAttributeSemanticTexcoord]) {
    return SCNGeometrySourceSemanticTexcoord;
  } else if ([semantic
                 isEqualToString:GLTFMeshPrimitiveAttributeSemanticColor]) {
    return SCNGeometrySourceSemanticColor;
  } else if ([semantic
                 isEqualToString:GLTFMeshPrimitiveAttributeSemanticJoints]) {
    abort();
  } else if ([semantic
                 isEqualToString:GLTFMeshPrimitiveAttributeSemanticWeights]) {
    return SCNGeometrySourceSemanticBoneWeights;
  } else {
    abort();
  }
}

static SCNWrapMode
SCNWrapModeFromGLTFSamplerWrapMode(GLTFSamplerWrapMode mode) {
  switch (mode) {
  case GLTFSamplerWrapModeClampToEdge:
    return SCNWrapModeClamp;
  case GLTFSamplerWrapModeMirroredRepeat:
    return SCNWrapModeMirror;
  case GLTFSamplerWrapModeRepeat:
    return SCNWrapModeRepeat;
  default:
    return SCNWrapModeRepeat;
  }
}

static NSInteger primitiveCountFromGLTFMeshPrimitiveMode(NSInteger indexCount,
                                                         NSInteger mode) {
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

static SCNGeometryPrimitiveType
SCNPrimitiveTypeFromGLTFMeshPrimitiveMode(NSInteger mode) {
  switch (mode) {
  case GLTFMeshPrimitiveModePoints:
    return SCNGeometryPrimitiveTypePoint;
  case GLTFMeshPrimitiveModeLines:
    return SCNGeometryPrimitiveTypeLine;
  case GLTFMeshPrimitiveModeTriangles:
  case GLTFMeshPrimitiveModeTriangleFan:
    return SCNGeometryPrimitiveTypeTriangles;
  case GLTFMeshPrimitiveModeTriangleStrip:
    return SCNGeometryPrimitiveTypeTriangleStrip;

    // TODO:
  case GLTFMeshPrimitiveModeLineLoop:
  case GLTFMeshPrimitiveModeLineStrip:
  default:
    abort();
  }
}

@implementation GLTFObject (SceneKitExtension)

#pragma mark - Scene

- (nullable SCNScene *)defaultScene {
  NSArray<SCNScene *> *scnScenes = [self scnScenes];
  if (self.json.scene) {
    return scnScenes[self.json.scene.integerValue];
  } else {
    return scnScenes.firstObject;
  }
}

- (NSArray<SCNScene *> *)scnScenes {
  NSMutableArray<SCNScene *> *scnScenes = [NSMutableArray array];
  if (self.json.scenes) {
    for (GLTFScene *scene in self.json.scenes) {
      SCNScene *scnScene = [self scnSceneFromGLTFScene:scene];
      [scnScenes addObject:scnScene];
    }
  }
  return [scnScenes copy];
}

- (SCNScene *)scnSceneFromGLTFScene:(GLTFScene *)scene {
  SCNScene *scnScene = [SCNScene scene];
  for (NSNumber *nodeIndex in scene.nodes) {
    GLTFNode *node = self.json.nodes[nodeIndex.integerValue];
    SCNNode *scnNode = [self scnNodeFromGLTFNode:node];
    [scnScene.rootNode addChildNode:scnNode];
  }
  return scnScene;
}

#pragma mark - Node

- (SCNNode *)scnNodeFromGLTFNode:(GLTFNode *)node {
  SCNNode *scnNode = [SCNNode node];
  scnNode.name = node.name;

  if (node.camera) {
    GLTFCamera *camera = self.json.cameras[node.camera.integerValue];
    scnNode.camera = [self scnCameraFromGLTFCamera:camera];
  }

  if (node.children) {
    for (NSNumber *childIndex in node.children) {
      GLTFNode *childNode = self.json.nodes[childIndex.integerValue];
      SCNNode *childScnNode = [self scnNodeFromGLTFNode:childNode];
      [scnNode addChildNode:childScnNode];
    }
  }

  if (node.skin) {
    // TODO:
  }

  scnNode.simdTransform = node.matrix;

  if (node.mesh) {
    GLTFMesh *mesh = self.json.meshes[node.mesh.integerValue];
    SCNNode *meshNode = [self scnNodeFromGLTFMesh:mesh];
    [scnNode addChildNode:meshNode];
  }

  // TODO: rotation, scale, translation

  if (node.weights) {
    // TODO:
  }

  return scnNode;
}

#pragma mark - Camera

- (SCNCamera *)scnCameraFromGLTFCamera:(GLTFCamera *)camera {
  NSAssert(camera.orthographic != nil || camera.perspective != nil,
           @"orthographic or perspective must be not nil");
  SCNCamera *scnCamera = [SCNCamera camera];
  scnCamera.name = camera.name;
  scnCamera.usesOrthographicProjection =
      camera.type == GLTFCameraTypeOrthographic;
  if (camera.orthographic) {
    scnCamera.orthographicScale =
        MAX(camera.orthographic.xmag, camera.orthographic.ymag);
    scnCamera.zFar = camera.orthographic.zfar;
    scnCamera.zNear = camera.orthographic.znear;
  } else if (camera.perspective) {
    if (camera.perspective.zfar) {
      scnCamera.zFar = camera.perspective.zfar.floatValue;
    }
    scnCamera.zNear = camera.perspective.znear;
    scnCamera.fieldOfView = camera.perspective.yfov * (180.0 / M_PI); // degree
    if (camera.perspective.aspectRatio) {
      float aspectRatio = camera.perspective.aspectRatio.floatValue;
      float yFovRadians = scnCamera.fieldOfView * (M_PI / 180.0);
      SCNMatrix4 projectionTransform = {
          .m11 = 1.0 / (aspectRatio * tan(yFovRadians * 0.5)),
          .m22 = 1.0 / tan(yFovRadians * 0.5),
          .m33 = -(scnCamera.zFar + scnCamera.zNear) /
                 (scnCamera.zFar - scnCamera.zNear),
          .m34 = -1.0,
          .m43 = -(2.0 * scnCamera.zFar * scnCamera.zNear) /
                 (scnCamera.zFar - scnCamera.zNear)};
      scnCamera.projectionTransform = projectionTransform;
    }
  }
  return scnCamera;
}

#pragma mark - Mesh

- (SCNNode *)scnNodeFromGLTFMesh:(GLTFMesh *)mesh {
  SCNNode *node = [SCNNode node];
  node.name = mesh.name;

  for (GLTFMeshPrimitive *primitive in mesh.primitives) {
    SCNGeometry *geometry = [self scnGeometryFromGLTFMeshPrimitive:primitive];
    [node addChildNode:[SCNNode nodeWithGeometry:geometry]];
  }

  if (mesh.weights) {
    // TODO:
  }

  return node;
}

- (SCNGeometry *)scnGeometryFromGLTFMeshPrimitive:
    (GLTFMeshPrimitive *)primitive {
  NSMutableArray<SCNGeometrySource *> *sources = [NSMutableArray array];
  NSMutableArray<SCNGeometryElement *> *elements = [NSMutableArray array];

  // sources
  [self addSCNGeometrySourceToArray:sources
                      fromPrimitive:primitive
                           semantic:GLTFMeshPrimitiveAttributeSemanticPosition];
  [self addSCNGeometrySourceToArray:sources
                      fromPrimitive:primitive
                           semantic:GLTFMeshPrimitiveAttributeSemanticNormal];
  [self addSCNGeometrySourceToArray:sources
                      fromPrimitive:primitive
                           semantic:GLTFMeshPrimitiveAttributeSemanticTangent];
  [self addSCNGeometrySourceListToArray:sources
                          fromPrimitive:primitive
                               semantic:
                                   GLTFMeshPrimitiveAttributeSemanticTexcoord];
  [self
      addSCNGeometrySourceListToArray:sources
                        fromPrimitive:primitive
                             semantic:GLTFMeshPrimitiveAttributeSemanticColor];
  //          [self addSCNGeometrySourcesToSources:sources object:object
  //          fromPrimitive:primitive
  //          semantic:GLTFMeshPrimitiveAttributeSemanticJoints];
  [self addSCNGeometrySourceListToArray:sources
                          fromPrimitive:primitive
                               semantic:
                                   GLTFMeshPrimitiveAttributeSemanticWeights];

  // elements
  [self addSCNGeometryElementToArray:elements fromPrimitive:primitive];

  SCNGeometry *geometry = [SCNGeometry geometryWithSources:sources
                                                  elements:elements];

  if (primitive.material) {
    GLTFMaterial *material =
        self.json.materials[primitive.material.integerValue];
    SCNMaterial *scnMaterial = [SCNMaterial material];

    GLTFMaterialPBRMetallicRoughness *pbrMetallicRoughness =
        material.pbrMetallicRoughness
            ?: [[GLTFMaterialPBRMetallicRoughness alloc] init];
    scnMaterial.diffuse.contents = [NSColor
        colorWithSRGBRed:[pbrMetallicRoughness.baseColorFactor[0] floatValue]
                   green:[pbrMetallicRoughness.baseColorFactor[1] floatValue]
                    blue:[pbrMetallicRoughness.baseColorFactor[2] floatValue]
                   alpha:[pbrMetallicRoughness.baseColorFactor[3] floatValue]];
    if (pbrMetallicRoughness.baseColorTexture) {
      GLTFTexture *texture =
          self.json.textures[pbrMetallicRoughness.baseColorTexture.index];
      if (texture.source) {
        NSData *imageData = self.imageDatas[texture.source.integerValue];
        NSImage *image = [[NSImage alloc] initWithData:imageData];
        scnMaterial.diffuse.contents = image;

        if (texture.sampler) {
          GLTFSampler *sampler =
              self.json.samplers[texture.sampler.integerValue];
          scnMaterial.diffuse.wrapS =
              SCNWrapModeFromGLTFSamplerWrapMode(sampler.wrapS);
          scnMaterial.diffuse.wrapT =
              SCNWrapModeFromGLTFSamplerWrapMode(sampler.wrapT);
          scnMaterial.diffuse.mipFilter = SCNFilterModeLinear;
          if (sampler.magFilter) {
            switch ([sampler.magFilter integerValue]) {
            case GLTFSamplerMagFilterLinear:
              scnMaterial.diffuse.magnificationFilter = SCNFilterModeLinear;
              break;
            case GLTFSamplerMagFilterNearest:
              scnMaterial.diffuse.magnificationFilter = SCNFilterModeNearest;
              break;
            default:
              break;
            }
          }
          if (sampler.minFilter) {
            switch ([sampler.minFilter integerValue]) {
            case GLTFSamplerMinFilterLinear:
            case GLTFSamplerMinFilterLinearMipmapNearest:
            case GLTFSamplerMinFilterLinearMipmapLinear:
              scnMaterial.diffuse.minificationFilter = SCNFilterModeLinear;
              break;
            case GLTFSamplerMinFilterNearest:
            case GLTFSamplerMinFilterNearestMipmapNearest:
            case GLTFSamplerMinFilterNearestMipmapLinear:
              scnMaterial.diffuse.minificationFilter = SCNFilterModeNearest;
              break;
            default:
              break;
            }
          }
        }
      }
    }
    if (pbrMetallicRoughness.metallicRoughnessTexture) {
      // TODO
    }
    scnMaterial.metalness.intensity = pbrMetallicRoughness.metallicFactor;
    scnMaterial.roughness.intensity = pbrMetallicRoughness.roughnessFactor;

    geometry.materials = @[ scnMaterial ];
  }

  return geometry;
}

- (SCNGeometrySource *)scnGeometrySourceFromGLTFAccessor:
                           (GLTFAccessor *)accessor
                                            withSemantic:(NSString *)semantic {
  NSData *data = [self dataByAccessor:accessor];
  NSInteger componentsPerVector = componentsCountOfAccessorType(accessor.type);
  NSInteger bytesPerComponent = sizeOfComponentType(accessor.componentType);
  NSInteger dataStride = componentsPerVector * bytesPerComponent;
  return [SCNGeometrySource
      geometrySourceWithData:data
                    semantic:
                        SCNGeometrySourceSemanticFromGLTFMeshPrimitiveAttributeSemantic(
                            semantic)
                 vectorCount:accessor.count
             floatComponents:accessor.componentType ==
                             GLTFAccessorComponentTypeFloat
         componentsPerVector:componentsPerVector
           bytesPerComponent:bytesPerComponent
                  dataOffset:0
                  dataStride:dataStride];
}

- (void)addSCNGeometrySourceToArray:
            (NSMutableArray<SCNGeometrySource *> *)sources
                      fromPrimitive:(GLTFMeshPrimitive *)primitive
                           semantic:(NSString *)semantic {
  NSNumber *index = [primitive valueOfSemantic:semantic];
  if (index) {
    GLTFAccessor *accessor = self.json.accessors[index.integerValue];
    [sources addObject:[self scnGeometrySourceFromGLTFAccessor:accessor
                                                  withSemantic:semantic]];
  }
}

- (void)addSCNGeometrySourceListToArray:
            (NSMutableArray<SCNGeometrySource *> *)sources
                          fromPrimitive:(GLTFMeshPrimitive *)primitive
                               semantic:(NSString *)semantic {
  NSArray<NSNumber *> *indices = [primitive valuesOfSemantic:semantic];
  for (NSNumber *index in indices) {
    GLTFAccessor *accessor = self.json.accessors[index.integerValue];
    [sources addObject:[self scnGeometrySourceFromGLTFAccessor:accessor
                                                  withSemantic:semantic]];
  }
}

- (void)addSCNGeometryElementToArray:
            (NSMutableArray<SCNGeometryElement *> *)elements
                       fromPrimitive:(GLTFMeshPrimitive *)primitive {
  if (primitive.indices) {
    GLTFAccessor *accessor =
        self.json.accessors[primitive.indices.integerValue];
    NSData *bufferData = [self dataByAccessor:accessor];

    bufferData =
        [self convertBufferData:bufferData
                  primitiveMode:primitive.mode
                  indexTypeSize:sizeOfComponentType(accessor.componentType)];
    SCNGeometryElement *element = [SCNGeometryElement
        geometryElementWithData:bufferData
                  primitiveType:SCNPrimitiveTypeFromGLTFMeshPrimitiveMode(
                                    primitive.mode)
                 primitiveCount:primitiveCountFromGLTFMeshPrimitiveMode(
                                    accessor.count, primitive.mode)
                  bytesPerIndex:sizeOfComponentType(accessor.componentType)];
    [elements addObject:element];
  }
}

- (NSData *)convertBufferData:(NSData *)bufferData
                primitiveMode:(NSInteger)mode
                indexTypeSize:(NSUInteger)indexTypeSize {
  switch (mode) {
  case GLTFMeshPrimitiveModeTriangleFan: {
    // convert triangles
    NSUInteger dataSize = bufferData.length;
    NSUInteger count = dataSize / indexTypeSize;
    uint16_t *bytes = (uint16_t *)bufferData.bytes;
    NSMutableData *data = [NSMutableData data];
    for (NSUInteger i = 1; i < count - 1; i++) {
      uint16_t v0 = bytes[0];
      uint16_t v1 = bytes[i];
      uint16_t v2 = bytes[i + 1];
      [data appendBytes:&v0 length:sizeof(uint16_t)];
      [data appendBytes:&v1 length:sizeof(uint16_t)];
      [data appendBytes:&v2 length:sizeof(uint16_t)];
    }
    return [data copy];
  }

  case GLTFMeshPrimitiveModeLineLoop:
  case GLTFMeshPrimitiveModeLineStrip:
    abort();
  default:
    break;
  }
  return bufferData;
}

@end
