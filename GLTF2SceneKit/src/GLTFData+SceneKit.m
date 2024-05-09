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

// convert indices data with SceneKit compatible primitive type
static NSData *
convertDataToSCNGeometryPrimitiveType(NSData *bufferData, NSInteger mode,
                                      SCNGeometryPrimitiveType *primitiveType) {
  switch (mode) {
  case GLTFMeshPrimitiveModePoints:
    *primitiveType = SCNGeometryPrimitiveTypePoint;
    return bufferData;
  case GLTFMeshPrimitiveModeLines:
    *primitiveType = SCNGeometryPrimitiveTypeLine;
    return bufferData;
  case GLTFMeshPrimitiveModeLineLoop: {
    *primitiveType = SCNGeometryPrimitiveTypeLine;
    // convert to line
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
    *primitiveType = SCNGeometryPrimitiveTypeLine;
    // convert to line
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
  case GLTFMeshPrimitiveModeTriangles:
    *primitiveType = SCNGeometryPrimitiveTypeTriangles;
    return bufferData;
  case GLTFMeshPrimitiveModeTriangleStrip:
    *primitiveType = SCNGeometryPrimitiveTypeTriangleStrip;
    return bufferData;
  case GLTFMeshPrimitiveModeTriangleFan: {
    *primitiveType = SCNGeometryPrimitiveTypeTriangles;
    // convert to triangles
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
  default:
    return bufferData;
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
  if (scene.nodes) {
    for (NSNumber *nodeIndex in scene.nodes) {
      GLTFNode *node = self.json.nodes[nodeIndex.integerValue];
      SCNNode *scnNode = [self scnNodeFromGLTFNode:node];
      [scnScene.rootNode addChildNode:scnNode];
    }
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

  if (node.matrix) {
    scnNode.simdTransform = node.matrixValue;
  } else {
    scnNode.simdRotation = simdRotationFromQuaternion(node.rotationValue);
    scnNode.simdScale = node.scaleValue;
    scnNode.simdPosition = node.translationValue;
  }

  if (node.mesh) {
    GLTFMesh *mesh = self.json.meshes[node.mesh.integerValue];
    SCNNode *meshNode = [self scnNodeFromGLTFMesh:mesh];
    [scnNode addChildNode:meshNode];
  }

  if (node.weights) {
    // TODO:
  }

  return scnNode;
}

simd_float4 simdRotationFromQuaternion(simd_quatf rotation) {
  float x = rotation.vector[0];
  float y = rotation.vector[1];
  float z = rotation.vector[2];
  float w = rotation.vector[3];

  float angle;
  simd_float3 axis;

  if (fabs(w - 1.0) < FLT_EPSILON) {
    angle = 0.0;
    axis = simd_make_float3(1, 0, 0);
  } else {
    angle = 2.0 * acos(w);
    axis = simd_normalize(simd_make_float3(x, y, z));
  }
  return simd_make_float4(axis.x, axis.y, axis.z, angle);
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
    NSData *data = [self dataForAccessor:accessor];

    SCNGeometryPrimitiveType primitiveType = SCNGeometryPrimitiveTypeTriangles;
    data = convertDataToSCNGeometryPrimitiveType(data, primitive.modeValue,
                                                 &primitiveType);

    SCNGeometryElement *element = [SCNGeometryElement
        geometryElementWithData:data
                  primitiveType:primitiveType
                 primitiveCount:primitiveCountFromGLTFMeshPrimitiveMode(
                                    accessor.count, primitive.modeValue)
                  bytesPerIndex:sizeOfComponentType(accessor.componentType)];

    if (primitive.modeValue == GLTFMeshPrimitiveModePoints) {
      element.pointSize = 4.0;
      element.minimumPointScreenSpaceRadius = 3;
      element.maximumPointScreenSpaceRadius = 5;
    }

    [elements addObject:element];
  }
  return [elements copy];
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

  NSMutableString *surfaceShaderModifier = [NSMutableString string];

  GLTFMaterialPBRMetallicRoughness *pbrMetallicRoughness =
      material.pbrMetallicRoughness
          ?: [[GLTFMaterialPBRMetallicRoughness alloc] init];

  if (pbrMetallicRoughness.baseColorTexture) {
    // set contents to texture
    [self applyTextureInfo:pbrMetallicRoughness.baseColorTexture
                toProperty:scnMaterial.diffuse];

    if (pbrMetallicRoughness.baseColorFactor) {
      simd_float4 factor = pbrMetallicRoughness.baseColorFactorValue;

      if (factor[3] < 1.0f) {
        [surfaceShaderModifier
            appendString:@"#pragma transparent\n#pragma body\n"];
      }
      [surfaceShaderModifier
          appendFormat:@"_surface.diffuse *= float4(%ff, %ff, %ff, %ff);\n",
                       factor[0], factor[1], factor[2], factor[3]];
    }
  } else {
    simd_float4 value = pbrMetallicRoughness.baseColorFactorValue;
    applyColorContentsToProperty(value[0], value[1], value[2], value[3],
                                 scnMaterial.diffuse);
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
  } else {
    simd_float3 value = material.emissiveFactorValue;
    applyColorContentsToProperty(value[0], value[1], value[2], 1.0,
                                 scnMaterial.emission);
  }

  if ([material.alphaModeValue isEqualToString:GLTFMaterialAlphaModeOpaque]) {
    scnMaterial.blendMode = SCNBlendModeReplace;
    [surfaceShaderModifier appendString:@"_surface.diffuse.a = 1.0;"];
  } else if ([material.alphaModeValue
                 isEqualToString:GLTFMaterialAlphaModeMask]) {
    scnMaterial.blendMode = SCNBlendModeReplace;
    [surfaceShaderModifier
        appendFormat:
            @"_surface.diffuse.a = _surface.diffuse.a < %f ? 0.0 : 1.0;",
            material.alphaCutoffValue];
  } else if ([material.alphaModeValue
                 isEqualToString:GLTFMaterialAlphaModeBlend]) {
    scnMaterial.blendMode = SCNBlendModeAlpha;
    scnMaterial.transparencyMode = SCNTransparencyModeDualLayer;
  }

  scnMaterial.doubleSided = material.isDoubleSided;

  scnMaterial.shaderModifiers = @{
    SCNShaderModifierEntryPointSurface : surfaceShaderModifier,
  };
  return scnMaterial;
}

#pragma mark diffuse

void applyColorContentsToProperty(float r, float g, float b, float a,
                                  SCNMaterialProperty *property) {
  CGColorSpaceRef colorSpace =
      CGColorSpaceCreateWithName(kCGColorSpaceLinearSRGB);
  CGFloat components[] = {r, g, b, a};
  CGColorRef color = CGColorCreate(colorSpace, components);
  property.contents = (__bridge id)(color);
  CGColorRelease(color);
  CGColorSpaceRelease(colorSpace);
}

#pragma mark normal

- (void)applyNormalTextureInfo:(GLTFMaterialNormalTextureInfo *)textureInfo
                    toMaterial:(SCNMaterial *)material {
  GLTFTexture *texture = self.json.textures[textureInfo.index];
  [self applyTexture:texture toProperty:material.normal];
  material.normal.mappingChannel = textureInfo.texCoordValue;
  material.normal.intensity = textureInfo.scaleValue;
}

#pragma mark occlusion

- (void)applyOcclusionTextureInfo:
            (GLTFMaterialOcclusionTextureInfo *)textureInfo
                       toMaterial:(SCNMaterial *)material {
  GLTFTexture *texture = self.json.textures[textureInfo.index];
  [self applyTexture:texture toProperty:material.ambientOcclusion];
  material.ambientOcclusion.mappingChannel = textureInfo.texCoordValue;
  material.ambientOcclusion.intensity = textureInfo.strengthValue;
}

#pragma mark texture

- (void)applyTextureInfo:(GLTFTextureInfo *)textureInfo
              toProperty:(SCNMaterialProperty *)property {
  GLTFTexture *texture = self.json.textures[textureInfo.index];
  [self applyTexture:texture toProperty:property];
  property.mappingChannel = textureInfo.texCoordValue;
}

- (void)applyTexture:(GLTFTexture *)texture
          toProperty:(SCNMaterialProperty *)property {
  property.wrapS = SCNWrapModeRepeat;
  property.wrapT = SCNWrapModeRepeat;
  property.magnificationFilter = SCNFilterModeNone;
  property.minificationFilter = SCNFilterModeNone;
  property.mipFilter = SCNFilterModeNone;

  if (texture.source) {
    GLTFImage *image = self.json.images[texture.source.integerValue];
    property.contents = [self mtlTextureForImage:image];
  }

  if (texture.sampler) {
    GLTFSampler *sampler = self.json.samplers[texture.sampler.integerValue];
    [self applyTextureSampler:sampler toProperty:property];
  }
}

- (void)applyTextureSampler:(GLTFSampler *)sampler
                 toProperty:(SCNMaterialProperty *)property {
  if (sampler.magFilter) {
    switch ([sampler.magFilter integerValue]) {
    case GLTFSamplerMagFilterNearest:
      property.magnificationFilter = SCNFilterModeNearest;
      break;
    case GLTFSamplerMagFilterLinear:
      property.magnificationFilter = SCNFilterModeLinear;
      break;
    default:
      break;
    }
  }
  if (sampler.minFilter) {
    switch ([sampler.minFilter integerValue]) {
    case GLTFSamplerMinFilterLinear:
      property.minificationFilter = SCNFilterModeLinear;
      break;
    case GLTFSamplerMinFilterLinearMipmapNearest:
      property.minificationFilter = SCNFilterModeLinear;
      property.mipFilter = SCNFilterModeNearest;
      break;
    case GLTFSamplerMinFilterLinearMipmapLinear:
      property.minificationFilter = SCNFilterModeLinear;
      property.mipFilter = SCNFilterModeLinear;
      break;
    case GLTFSamplerMinFilterNearest:
      property.minificationFilter = SCNFilterModeNearest;
      break;
    case GLTFSamplerMinFilterNearestMipmapNearest:
      property.minificationFilter = SCNFilterModeNearest;
      property.mipFilter = SCNFilterModeNearest;
      break;
    case GLTFSamplerMinFilterNearestMipmapLinear:
      property.minificationFilter = SCNFilterModeNearest;
      property.mipFilter = SCNFilterModeLinear;
      break;
    default:
      break;
    }
  }
  property.wrapS = SCNWrapModeFromGLTFSamplerWrapMode(sampler.wrapSValue);
  property.wrapT = SCNWrapModeFromGLTFSamplerWrapMode(sampler.wrapTValue);
}

@end
