#import "GLTFData+SceneKit.h"

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
    return SCNGeometrySourceSemanticBoneIndices;
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
  case GLTFMeshPrimitiveModeLineLoop:
  case GLTFMeshPrimitiveModeLineStrip:
    return SCNGeometryPrimitiveTypeLine;
  case GLTFMeshPrimitiveModeTriangles:
  case GLTFMeshPrimitiveModeTriangleFan:
    return SCNGeometryPrimitiveTypeTriangles;
  case GLTFMeshPrimitiveModeTriangleStrip:
    return SCNGeometryPrimitiveTypeTriangleStrip;
  default:
    return SCNGeometryPrimitiveTypeTriangles;
  }
}

@implementation GLTFData (SceneKitExtension)

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

  scnNode.simdTransform = node.matrixValue;

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

#pragma mark MeshPrimitive

- (NSArray<SCNGeometrySource *> *)scnGeometrySourcesFromPrimitive:
    (GLTFMeshPrimitive *)primitive {
  NSMutableArray<SCNGeometrySource *> *sources = [NSMutableArray array];
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
  [self
      addSCNGeometrySourceListToArray:sources
                        fromPrimitive:primitive
                             semantic:GLTFMeshPrimitiveAttributeSemanticJoints];
  [self addSCNGeometrySourceListToArray:sources
                          fromPrimitive:primitive
                               semantic:
                                   GLTFMeshPrimitiveAttributeSemanticWeights];
  return [sources copy];
}

- (SCNGeometry *)scnGeometryFromGLTFMeshPrimitive:
    (GLTFMeshPrimitive *)primitive {
  NSArray<SCNGeometrySource *> *sources =
      [self scnGeometrySourcesFromPrimitive:primitive];
  NSArray<SCNGeometryElement *> *elements =
      [self scnGeometryElementsFromPrimitive:primitive];
  SCNGeometry *geometry = [SCNGeometry geometryWithSources:sources
                                                  elements:elements];

  // material
  if (primitive.material) {
    GLTFMaterial *material =
        self.json.materials[primitive.material.integerValue];
    SCNMaterial *scnMaterial = [self scnMaterialFromGLTFMaterial:material];
    geometry.materials = @[ scnMaterial ];
  }

  // TODO: targets

  return geometry;
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

- (SCNGeometrySource *)scnGeometrySourceFromGLTFAccessor:
                           (GLTFAccessor *)accessor
                                            withSemantic:(NSString *)semantic {
  NSData *data = [self dataForAccessor:accessor];
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

- (NSArray<SCNGeometryElement *> *)scnGeometryElementsFromPrimitive:
    (GLTFMeshPrimitive *)primitive {
  NSMutableArray<SCNGeometryElement *> *elements = [NSMutableArray array];
  if (primitive.indices) {
    GLTFAccessor *accessor =
        self.json.accessors[primitive.indices.integerValue];
    NSData *bufferData = [self dataForAccessor:accessor];

    bufferData = [self convertBufferData:bufferData
                           primitiveMode:primitive.modeValue];
    SCNGeometryElement *element = [SCNGeometryElement
        geometryElementWithData:bufferData
                  primitiveType:SCNPrimitiveTypeFromGLTFMeshPrimitiveMode(
                                    primitive.modeValue)
                 primitiveCount:primitiveCountFromGLTFMeshPrimitiveMode(
                                    accessor.count, primitive.modeValue)
                  bytesPerIndex:sizeOfComponentType(accessor.componentType)];
    if (primitive.modeValue == GLTFMeshPrimitiveModePoints) {
      // TODO: make variable
      element.pointSize = 4.0;
      element.minimumPointScreenSpaceRadius = 3;
      element.maximumPointScreenSpaceRadius = 5;
    }
    [elements addObject:element];
  }
  return [elements copy];
}

- (NSData *)convertBufferData:(NSData *)bufferData
                primitiveMode:(NSInteger)mode {
  switch (mode) {
  case GLTFMeshPrimitiveModeTriangleFan: {
    // convert triangles
    NSUInteger dataSize = bufferData.length;
    NSUInteger indicesCount = dataSize / sizeof(uint16_t);
    uint16_t *bytes = (uint16_t *)bufferData.bytes;
    NSMutableData *data = [NSMutableData data];
    for (NSUInteger i = 1; i < indicesCount - 1; i++) {
      uint16_t v0 = bytes[0];
      uint16_t v1 = bytes[i];
      uint16_t v2 = bytes[i + 1];
      [data appendBytes:&v0 length:sizeof(uint16_t)];
      [data appendBytes:&v1 length:sizeof(uint16_t)];
      [data appendBytes:&v2 length:sizeof(uint16_t)];
    }
    return [data copy];
  }

  case GLTFMeshPrimitiveModeLineLoop: {
    // convert line
    NSUInteger dataSize = bufferData.length;
    NSUInteger indicesCount = dataSize / sizeof(uint16_t);
    uint16_t *bytes = (uint16_t *)bufferData.bytes;
    NSMutableData *data = [NSMutableData data];
    for (NSUInteger i = 0; i < indicesCount; i++) {
      uint16_t v1 = bytes[i];
      uint16_t v2 = bytes[(i + 1) % indicesCount];
      [data appendBytes:&v1 length:sizeof(uint16_t)];
      [data appendBytes:&v2 length:sizeof(uint16_t)];
    }
    return [data copy];
  }

  case GLTFMeshPrimitiveModeLineStrip: {
    // convert line
    NSUInteger dataSize = bufferData.length;
    NSUInteger indicesCount = dataSize / sizeof(uint16_t);
    uint16_t *bytes = (uint16_t *)bufferData.bytes;
    NSMutableData *data = [NSMutableData data];
    for (NSUInteger i = 0; i < indicesCount - 1; i++) {
      uint16_t v1 = bytes[i];
      uint16_t v2 = bytes[i + 1];
      [data appendBytes:&v1 length:sizeof(uint16_t)];
      [data appendBytes:&v2 length:sizeof(uint16_t)];
    }
    return [data copy];
  }
  default:
    break;
  }
  return bufferData;
}

#pragma mark - Material

- (SCNMaterial *)scnMaterialFromGLTFMaterial:(GLTFMaterial *)material {
  SCNMaterial *scnMaterial = [SCNMaterial material];
  scnMaterial.name = material.name;
  scnMaterial.locksAmbientWithDiffuse = YES;

  if (material.pbrMetallicRoughness) {
    scnMaterial.lightingModelName = SCNLightingModelPhysicallyBased;
  } else {
    scnMaterial.lightingModelName = SCNLightingModelBlinn;
  }

  GLTFMaterialPBRMetallicRoughness *pbrMetallicRoughness =
      material.pbrMetallicRoughness
          ?: [[GLTFMaterialPBRMetallicRoughness alloc] init];
  [self applyPBRMetallicRoughness:pbrMetallicRoughness toMaterial:scnMaterial];

  if (material.normalTexture) {
    [self applyNormalTextureInfo:material.normalTexture toMaterial:scnMaterial];
  }

  if (material.occlusionTexture) {
    [self applyOcclusionTextureInfo:material.occlusionTexture
                         toMaterial:scnMaterial];
    scnMaterial.ambientOcclusion.textureComponents = SCNColorMaskRed;
  }

  if (material.emissiveTexture) {
    [self applyTextureInfo:material.emissiveTexture
                toProperty:scnMaterial.emission];
  } else if (material.emissiveFactor) {
    CGFloat rgba[] = {material.emissiveFactorValue[0],
                      material.emissiveFactorValue[1],
                      material.emissiveFactorValue[2], 1.0};
    CGColorSpaceRef colorSpaceLinearSRGB =
        CGColorSpaceCreateWithName(kCGColorSpaceLinearSRGB);
    scnMaterial.emission.contents =
        (__bridge_transfer id)CGColorCreate(colorSpaceLinearSRGB, &rgba[0]);
  }

  if (material.alphaModeValue) {
    if ([material.alphaModeValue isEqualToString:GLTFMaterialAlphaModeOpaque]) {
      scnMaterial.transparency = 1.0;
    } else if ([material.alphaModeValue
                   isEqualToString:GLTFMaterialAlphaModeMask]) {
      scnMaterial.writesToDepthBuffer = YES;
      scnMaterial.colorBufferWriteMask = SCNColorMaskNone;
    } else if ([material.alphaModeValue
                   isEqualToString:GLTFMaterialAlphaModeMask]) {
      scnMaterial.blendMode = SCNBlendModeAlpha;
    }
  }

  // TODO: alphaCutoff

  scnMaterial.doubleSided = material.isDoubleSided;

  return scnMaterial;
}

#pragma mark diffuse

- (void)applyPBRMetallicRoughness:
            (GLTFMaterialPBRMetallicRoughness *)pbrMetallicRoughness
                       toMaterial:(SCNMaterial *)scnMaterial {

  // baseColorFactor
  scnMaterial.diffuse.contents =
      [NSColor colorWithSRGBRed:pbrMetallicRoughness.baseColorFactorValue[0]
                          green:pbrMetallicRoughness.baseColorFactorValue[1]
                           blue:pbrMetallicRoughness.baseColorFactorValue[2]
                          alpha:pbrMetallicRoughness.baseColorFactorValue[3]];

  // baseColorTexture
  if (pbrMetallicRoughness.baseColorTexture) {
    [self applyTextureInfo:pbrMetallicRoughness.baseColorTexture
                toProperty:scnMaterial.diffuse];
  }

  // metallicRoughnessTexture
  if (pbrMetallicRoughness.metallicRoughnessTexture) {
    [self applyTextureInfo:pbrMetallicRoughness.metallicRoughnessTexture
                toProperty:scnMaterial.metalness];
    scnMaterial.metalness.textureComponents = SCNColorMaskBlue;
    scnMaterial.metalness.intensity = pbrMetallicRoughness.metallicFactorValue;

    [self applyTextureInfo:pbrMetallicRoughness.metallicRoughnessTexture
                toProperty:scnMaterial.roughness];
    scnMaterial.roughness.textureComponents = SCNColorMaskGreen;
    scnMaterial.roughness.intensity = pbrMetallicRoughness.roughnessFactorValue;
  } else {
    scnMaterial.metalness.contents =
        @(pbrMetallicRoughness.metallicFactorValue);
    scnMaterial.roughness.contents =
        @(pbrMetallicRoughness.roughnessFactorValue);
  }
}

#pragma mark normal

- (void)applyNormalTextureInfo:(GLTFMaterialNormalTextureInfo *)textureInfo
                    toMaterial:(SCNMaterial *)material {
  // index
  GLTFTexture *texture = self.json.textures[textureInfo.index];
  [self applyTexture:texture toProperty:material.normal];
  // texcoord
  material.normal.mappingChannel = textureInfo.texCoordValue;
  // scale
  material.normal.contentsTransform =
      SCNMatrix4MakeScale(textureInfo.scaleValue, textureInfo.scaleValue, 1.0);
}

#pragma mark occlusion

- (void)applyOcclusionTextureInfo:
            (GLTFMaterialOcclusionTextureInfo *)textureInfo
                       toMaterial:(SCNMaterial *)material {
  // index
  GLTFTexture *texture = self.json.textures[textureInfo.index];
  [self applyTexture:texture toProperty:material.ambientOcclusion];
  // texcoord
  material.normal.mappingChannel = textureInfo.texCoordValue;
  // TODO: strength
}

#pragma mark texture

- (void)applyTextureInfo:(GLTFTextureInfo *)textureInfo
              toProperty:(SCNMaterialProperty *)property {
  // index
  GLTFTexture *texture = self.json.textures[textureInfo.index];
  [self applyTexture:texture toProperty:property];
  // texcoord
  property.mappingChannel = textureInfo.texCoordValue;
}

- (void)applyTexture:(GLTFTexture *)texture
          toProperty:(SCNMaterialProperty *)property {
  if (texture.source) {
    //    NSData *imageData = self.imageDatas[texture.source.integerValue];
    //    NSImage *image = [[NSImage alloc] initWithData:imageData];
    GLTFImage *image = self.json.images[texture.source.integerValue];
    property.contents = [self mtlTextureForImage:image];

    if (texture.sampler) {
      GLTFSampler *sampler = self.json.samplers[texture.sampler.integerValue];
      [self applyTextureSampler:sampler toProperty:property];
    }
  }
}

- (void)applyTextureSampler:(GLTFSampler *)sampler
                 toProperty:(SCNMaterialProperty *)property {
  SCNFilterMode mipFilter = SCNFilterModeLinear;
  SCNFilterMode magFilter = SCNFilterModeLinear;
  SCNFilterMode minFilter = SCNFilterModeLinear;
  if (sampler.magFilter) {
    switch ([sampler.magFilter integerValue]) {
    case GLTFSamplerMagFilterNearest:
      magFilter = SCNFilterModeNearest;
      break;
    case GLTFSamplerMagFilterLinear:
      magFilter = SCNFilterModeLinear;
      break;
    default:
      break;
    }
  }
  if (sampler.minFilter) {
    switch ([sampler.minFilter integerValue]) {
    case GLTFSamplerMinFilterLinear:
      minFilter = SCNFilterModeLinear;
      break;
    case GLTFSamplerMinFilterLinearMipmapNearest:
      minFilter = SCNFilterModeLinear;
      mipFilter = SCNFilterModeNearest;
      break;
    case GLTFSamplerMinFilterLinearMipmapLinear:
      minFilter = SCNFilterModeLinear;
      mipFilter = SCNFilterModeLinear;
      break;
    case GLTFSamplerMinFilterNearest:
      minFilter = SCNFilterModeNearest;
      break;
    case GLTFSamplerMinFilterNearestMipmapNearest:
      minFilter = SCNFilterModeNearest;
      mipFilter = SCNFilterModeNearest;
      break;
    case GLTFSamplerMinFilterNearestMipmapLinear:
      minFilter = SCNFilterModeNearest;
      mipFilter = SCNFilterModeLinear;
      break;
    default:
      break;
    }
  }
  property.wrapS = SCNWrapModeFromGLTFSamplerWrapMode(sampler.wrapSValue);
  property.wrapT = SCNWrapModeFromGLTFSamplerWrapMode(sampler.wrapTValue);
  property.mipFilter = mipFilter;
  property.magnificationFilter = magFilter;
  property.minificationFilter = minFilter;
}

@end
