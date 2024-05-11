#import "GLTFSCNAsset.h"

@implementation GLTFSCNAsset

- (instancetype)initWithGLTFData:(GLTFData *)data {
  self = [super init];
  if (self) {
    _data = data;
    _scenes = [NSArray array];
  }
  return self;
}

+ (instancetype)assetWithGLTFData:(GLTFData *)data {
  return [[GLTFSCNAsset alloc] initWithGLTFData:data];
}

- (nullable SCNScene *)defaultScene {
  if (self.data.json.scene) {
    return self.scenes[self.data.json.scene.integerValue];
  } else {
    return self.scenes.firstObject;
  }
}

- (void)loadScenes {
  NSArray<NSData *> *accessorDataArray;
  if (self.data.json.accessors) {
    accessorDataArray = [self loadAccessorDatas];
  }

  NSArray<SCNMaterial *> *materials;
  if (self.data.json.materials) {
    materials = [self loadMaterials];
  }

  NSArray<SCNNode *> *meshNodes;
  if (self.data.json.meshes) {
    meshNodes = [self loadMeshNodesWithAccessorDataArray:accessorDataArray
                                               materials:materials];
  }

  NSArray<SCNCamera *> *cameras;
  if (self.data.json.cameras) {
    cameras = [self loadCameras];
  }

  NSMutableArray<SCNNode *> *scnNodes;
  if (self.data.json.nodes) {
    scnNodes = [NSMutableArray arrayWithCapacity:self.data.json.nodes.count];

    for (GLTFNode *node in self.data.json.nodes) {
      SCNNode *scnNode = [SCNNode node];
      scnNode.name = node.name;

      if (node.camera) {
        scnNode.camera = cameras[node.camera.integerValue];
      }

      if (node.matrix) {
        scnNode.simdTransform = node.matrixValue;
      } else {
        scnNode.simdRotation = simdRotationFromQuaternion(node.rotationValue);
        scnNode.simdScale = node.scaleValue;
        scnNode.simdPosition = node.translationValue;
      }

      if (node.mesh) {
        SCNNode *meshNode = meshNodes[node.mesh.integerValue];
        if (node.weights && meshNode.morpher) {
          meshNode.morpher.weights = node.weights;
        }
        [scnNode addChildNode:meshNode];
      }

      [scnNodes addObject:scnNode];
    }

    for (int i = 0; i < self.data.json.nodes.count; i++) {
      GLTFNode *node = self.data.json.nodes[i];
      SCNNode *scnNode = scnNodes[i];

      if (node.children) {
        for (NSNumber *childIndex in node.children) {
          SCNNode *childNode = scnNodes[childIndex.integerValue];
          [scnNode addChildNode:childNode];
        }
      }

      if (node.skin) {
        GLTFSkin *skin = self.data.json.skins[node.skin.integerValue];
        SCNGeometry *geometry = meshNodes[node.mesh.integerValue].geometry;

        NSMutableArray<SCNNode *> *bones =
            [NSMutableArray arrayWithCapacity:skin.joints.count];
        for (NSNumber *joint in skin.joints) {
          SCNNode *bone = scnNodes[joint.integerValue];
          [bones addObject:bone];
        }

        NSMutableArray<NSValue *> *boneInverseBindTransforms =
            [NSMutableArray arrayWithCapacity:skin.joints.count];
        if (skin.inverseBindMatrices) {
          GLTFAccessor *accessor =
              self.data.json.accessors[skin.inverseBindMatrices.integerValue];
          NSData *data = [self.data dataForAccessor:accessor];
          for (int j = 0; j < skin.joints.count; j++) {
            float matrixData[16];
            [data getBytes:&matrixData
                     range:NSMakeRange(j * sizeof(matrixData),
                                       sizeof(matrixData))];
            SCNMatrix4 matrix;
            matrix.m11 = matrixData[0];
            matrix.m12 = matrixData[1];
            matrix.m13 = matrixData[2];
            matrix.m14 = matrixData[3];
            matrix.m21 = matrixData[4];
            matrix.m22 = matrixData[5];
            matrix.m23 = matrixData[6];
            matrix.m24 = matrixData[7];
            matrix.m31 = matrixData[8];
            matrix.m32 = matrixData[9];
            matrix.m33 = matrixData[10];
            matrix.m34 = matrixData[11];
            matrix.m41 = matrixData[12];
            matrix.m42 = matrixData[13];
            matrix.m43 = matrixData[14];
            matrix.m44 = matrixData[15];
            [boneInverseBindTransforms
                addObject:[NSValue valueWithSCNMatrix4:matrix]];
          }
        } else {
          for (int j = 0; j < skin.joints.count; j++) {
            SCNMatrix4 identity = SCNMatrix4Identity;
            [boneInverseBindTransforms
                addObject:[NSValue valueWithSCNMatrix4:identity]];
          }
        }

        SCNGeometrySource *boneWeights;
        SCNGeometrySource *boneIndices;
        for (SCNGeometrySource *source in geometry.geometrySources) {
          if ([source.semantic
                  isEqualToString:SCNGeometrySourceSemanticBoneWeights]) {
            boneWeights = source;
          } else if ([source.semantic
                         isEqualToString:
                             SCNGeometrySourceSemanticBoneIndices]) {
            boneIndices = source;
          }
        }

        SCNSkinner *skinner =
            [SCNSkinner skinnerWithBaseGeometry:geometry
                                          bones:[bones copy]
                      boneInverseBindTransforms:[boneInverseBindTransforms copy]
                                    boneWeights:boneWeights
                                    boneIndices:boneIndices];
        scnNode.skinner = skinner;
      }
    }
  }

  NSMutableArray<SCNScene *> *scnScenes = [NSMutableArray array];
  if (self.data.json.scenes) {
    for (GLTFScene *scene in self.data.json.scenes) {
      SCNScene *scnScene = [SCNScene scene];
      for (NSNumber *nodeIndex in scene.nodes) {
        SCNNode *node = scnNodes[nodeIndex.integerValue];
        [scnScene.rootNode addChildNode:node];
      }
      [scnScenes addObject:scnScene];
    }
  }
  self.scenes = [scnScenes copy];
}

- (NSArray<NSData *> *)loadAccessorDatas {
  NSMutableArray<NSData *> *bufDataArray =
      [NSMutableArray arrayWithCapacity:self.data.json.accessors.count];
  for (GLTFAccessor *accessor in self.data.json.accessors) {
    NSData *bufData = [self.data dataForAccessor:accessor];
    [bufDataArray addObject:bufData];
  }
  return [bufDataArray copy];
}

- (NSArray<SCNMaterial *> *)loadMaterials {
  NSMutableArray<SCNMaterial *> *scnMaterials =
      [NSMutableArray arrayWithCapacity:self.data.json.materials.count];
  for (GLTFMaterial *material in self.data.json.materials) {
    SCNMaterial *scnMaterial = [SCNMaterial material];
    scnMaterial.name = material.name;
    scnMaterial.locksAmbientWithDiffuse = YES;
    scnMaterial.lightingModelName = material.pbrMetallicRoughness != nil
                                        ? SCNLightingModelPhysicallyBased
                                        : SCNLightingModelBlinn;

    NSMutableString *surfaceShaderModifier = [NSMutableString string];

    GLTFMaterialPBRMetallicRoughness *pbrMetallicRoughness =
        material.pbrMetallicRoughness
            ?: [[GLTFMaterialPBRMetallicRoughness alloc] init];

    if (pbrMetallicRoughness.baseColorTexture) {
      // set contents to texture
      [self applyTextureInfo:pbrMetallicRoughness.baseColorTexture
               withIntensity:1.0f
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
               withIntensity:pbrMetallicRoughness.metallicFactorValue
                  toProperty:scnMaterial.metalness];
      scnMaterial.metalness.textureComponents = SCNColorMaskBlue;

      [self applyTextureInfo:pbrMetallicRoughness.metallicRoughnessTexture
               withIntensity:pbrMetallicRoughness.roughnessFactorValue
                  toProperty:scnMaterial.roughness];
      scnMaterial.roughness.textureComponents = SCNColorMaskGreen;
    } else {
      scnMaterial.metalness.contents =
          @(pbrMetallicRoughness.metallicFactorValue);
      scnMaterial.roughness.contents =
          @(pbrMetallicRoughness.roughnessFactorValue);
    }

    if (material.normalTexture) {
      [self applyTextureInfo:material.normalTexture
               withIntensity:material.normalTexture.scaleValue
                  toProperty:scnMaterial.normal];
    }

    if (material.occlusionTexture) {
      [self applyTextureInfo:material.occlusionTexture
               withIntensity:material.occlusionTexture.strengthValue
                  toProperty:scnMaterial.ambientOcclusion];
      scnMaterial.ambientOcclusion.textureComponents = SCNColorMaskRed;
    }

    if (material.emissiveTexture) {
      [self applyTextureInfo:material.emissiveTexture
               withIntensity:1.0f
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

    [scnMaterials addObject:scnMaterial];
  }
  return [scnMaterials copy];
}

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

- (void)applyTextureInfo:(GLTFTextureInfo *)textureInfo
           withIntensity:(CGFloat)intensity
              toProperty:(SCNMaterialProperty *)property {
  GLTFTexture *texture = self.data.json.textures[textureInfo.index];
  [self applyTexture:texture toProperty:property];
  property.mappingChannel = textureInfo.texCoordValue;
  property.intensity = intensity;
}

- (void)applyTexture:(GLTFTexture *)texture
          toProperty:(SCNMaterialProperty *)property {
  property.wrapS = SCNWrapModeRepeat;
  property.wrapT = SCNWrapModeRepeat;
  property.magnificationFilter = SCNFilterModeNone;
  property.minificationFilter = SCNFilterModeNone;
  property.mipFilter = SCNFilterModeNone;

  if (texture.source) {
    GLTFImage *image = self.data.json.images[texture.source.integerValue];
    property.contents = (__bridge id)[self.data cgImageForImage:image];
  }

  if (texture.sampler) {
    GLTFSampler *sampler =
        self.data.json.samplers[texture.sampler.integerValue];
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

- (NSArray<SCNNode *> *)
    loadMeshNodesWithAccessorDataArray:(NSArray<NSData *> *)accessorDataArray
                             materials:(NSArray<SCNMaterial *> *)materials {
  NSMutableArray<SCNNode *> *meshNodes =
      [NSMutableArray arrayWithCapacity:self.data.json.meshes.count];

  for (GLTFMesh *mesh in self.data.json.meshes) {
    SCNNode *meshNode = [self scnNodeFromMesh:mesh
                            accessorDataArray:accessorDataArray
                                    materials:materials];
    [meshNodes addObject:meshNode];
  }
  return [meshNodes copy];
}

- (SCNNode *)scnNodeFromMesh:(GLTFMesh *)mesh
           accessorDataArray:(NSArray<NSData *> *)accessorDataArray
                   materials:(NSArray<SCNMaterial *> *)materials {
  SCNNode *node = [SCNNode node];
  node.name = mesh.name;

  for (GLTFMeshPrimitive *primitive in mesh.primitives) {
    NSArray<SCNGeometrySource *> *sources =
        [self scnGeometrySourcesFromPrimitive:primitive
                            accessorDataArray:accessorDataArray];
    NSArray<SCNGeometryElement *> *elements =
        [self scnGeometryElementsFromPrimitive:primitive
                             accessorDataArray:accessorDataArray];
    SCNGeometry *geometry = [SCNGeometry geometryWithSources:sources
                                                    elements:elements];
    SCNNode *geometryNode = [SCNNode nodeWithGeometry:geometry];

    // material
    if (primitive.material) {
      SCNMaterial *scnMaterial = materials[primitive.material.integerValue];
      geometry.materials = @[ scnMaterial ];
    }

    if (primitive.targets) {
      SCNMorpher *morpher = [SCNMorpher new];
      NSMutableArray<SCNGeometry *> *morphTargets =
          [NSMutableArray arrayWithCapacity:primitive.targets.count];
      for (int i = 0; i < primitive.targets.count; i++) {
        GLTFMeshPrimitiveTarget *target = primitive.targets[i];
        NSArray<SCNGeometrySource *> *sources =
            [self scnGeometrySourcesFromMorphTarget:target
                                  accessorDataArray:accessorDataArray];
        SCNGeometry *morphTarget = [SCNGeometry geometryWithSources:sources
                                                           elements:elements];
        [morphTargets addObject:morphTarget];
      }
      morpher.targets = [morphTargets copy];
      if (mesh.weights)
        morpher.weights = mesh.weights;
      morpher.unifiesNormals = YES;
      morpher.calculationMode = SCNMorpherCalculationModeAdditive;
      geometryNode.morpher = morpher;
    }

    [node addChildNode:geometryNode];
  }

  return node;
}

- (NSArray<SCNGeometrySource *> *)
    scnGeometrySourcesFromPrimitive:(GLTFMeshPrimitive *)primitive
                  accessorDataArray:(NSArray<NSData *> *)accessorDataArray {
  NSMutableArray<SCNGeometrySource *> *sources = [NSMutableArray array];
  [self addSCNGeometrySourceToArray:sources
                      fromPrimitive:primitive
                           semantic:GLTFMeshPrimitiveAttributeSemanticPosition
                  accessorDataArray:accessorDataArray];
  [self addSCNGeometrySourceToArray:sources
                      fromPrimitive:primitive
                           semantic:GLTFMeshPrimitiveAttributeSemanticNormal
                  accessorDataArray:accessorDataArray];
  [self addSCNGeometrySourceToArray:sources
                      fromPrimitive:primitive
                           semantic:GLTFMeshPrimitiveAttributeSemanticTangent
                  accessorDataArray:accessorDataArray];
  [self
      addSCNGeometrySourceListToArray:sources
                        fromPrimitive:primitive
                             semantic:GLTFMeshPrimitiveAttributeSemanticTexcoord
                    accessorDataArray:accessorDataArray];
  [self addSCNGeometrySourceListToArray:sources
                          fromPrimitive:primitive
                               semantic:GLTFMeshPrimitiveAttributeSemanticColor
                      accessorDataArray:accessorDataArray];
  [self addSCNGeometrySourceListToArray:sources
                          fromPrimitive:primitive
                               semantic:GLTFMeshPrimitiveAttributeSemanticJoints
                      accessorDataArray:accessorDataArray];
  [self
      addSCNGeometrySourceListToArray:sources
                        fromPrimitive:primitive
                             semantic:GLTFMeshPrimitiveAttributeSemanticWeights
                    accessorDataArray:accessorDataArray];
  return [sources copy];
}

- (void)addSCNGeometrySourceToArray:
            (NSMutableArray<SCNGeometrySource *> *)sources
                      fromPrimitive:(GLTFMeshPrimitive *)primitive
                           semantic:(NSString *)semantic
                  accessorDataArray:(NSArray<NSData *> *)accessorDataArray {
  NSNumber *index = [primitive valueOfAttributeSemantic:semantic];
  if (index) {
    GLTFAccessor *accessor = self.data.json.accessors[index.integerValue];
    NSData *data = accessorDataArray[index.integerValue];
    SCNGeometrySource *source = [self scnGeometrySourceFromGLTFAccessor:accessor
                                                           withSemantic:semantic
                                                                   data:data];
    [sources addObject:source];
  }
}

- (void)addSCNGeometrySourceListToArray:
            (NSMutableArray<SCNGeometrySource *> *)sources
                          fromPrimitive:(GLTFMeshPrimitive *)primitive
                               semantic:(NSString *)semantic
                      accessorDataArray:(NSArray<NSData *> *)accessorDataArray {
  NSArray<NSNumber *> *indices = [primitive valuesOfAttributeSemantic:semantic];
  for (NSNumber *index in indices) {
    GLTFAccessor *accessor = self.data.json.accessors[index.integerValue];
    NSData *data = accessorDataArray[index.integerValue];
    SCNGeometrySource *source = [self scnGeometrySourceFromGLTFAccessor:accessor
                                                           withSemantic:semantic
                                                                   data:data];
    [sources addObject:source];
  }
}

- (SCNGeometrySource *)scnGeometrySourceFromGLTFAccessor:
                           (GLTFAccessor *)accessor
                                            withSemantic:(NSString *)semantic
                                                    data:(NSData *)data {
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

- (NSArray<SCNGeometryElement *> *)
    scnGeometryElementsFromPrimitive:(GLTFMeshPrimitive *)primitive
                   accessorDataArray:(NSArray<NSData *> *)accessorDataArray {
  NSMutableArray<SCNGeometryElement *> *elements = [NSMutableArray array];
  if (primitive.indices) {
    GLTFAccessor *accessor =
        self.data.json.accessors[primitive.indices.integerValue];
    NSData *data = accessorDataArray[primitive.indices.integerValue];

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

- (NSArray<SCNGeometrySource *> *)
    scnGeometrySourcesFromMorphTarget:(GLTFMeshPrimitiveTarget *)primitiveTarget
                    accessorDataArray:(NSArray<NSData *> *)accessorDataArray {
  NSMutableArray<SCNGeometrySource *> *sources = [NSMutableArray array];
  if (primitiveTarget.position) {
    GLTFAccessor *accessor =
        self.data.json.accessors[primitiveTarget.position.integerValue];
    NSData *data = accessorDataArray[primitiveTarget.position.integerValue];
    [sources
        addObject:
            [self
                scnGeometrySourceFromGLTFAccessor:accessor
                                     withSemantic:
                                         GLTFMeshPrimitiveAttributeSemanticPosition
                                             data:data]];
  }
  if (primitiveTarget.normal) {
    GLTFAccessor *accessor =
        self.data.json.accessors[primitiveTarget.normal.integerValue];
    NSData *data = accessorDataArray[primitiveTarget.normal.integerValue];
    [sources
        addObject:
            [self
                scnGeometrySourceFromGLTFAccessor:accessor
                                     withSemantic:
                                         GLTFMeshPrimitiveAttributeSemanticNormal
                                             data:data]];
  }
  if (primitiveTarget.tangent) {
    GLTFAccessor *accessor =
        self.data.json.accessors[primitiveTarget.tangent.integerValue];
    NSData *data = accessorDataArray[primitiveTarget.tangent.integerValue];
    [sources
        addObject:
            [self
                scnGeometrySourceFromGLTFAccessor:accessor
                                     withSemantic:
                                         GLTFMeshPrimitiveAttributeSemanticTangent
                                             data:data]];
  }
  return [sources copy];
}

- (NSArray<SCNCamera *> *)loadCameras {
  NSMutableArray<SCNCamera *> *scnCameras =
      [NSMutableArray arrayWithCapacity:self.data.json.cameras.count];
  for (GLTFCamera *camera in self.data.json.cameras) {
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
      scnCamera.fieldOfView =
          camera.perspective.yfov * (180.0 / M_PI); // degree
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
    [scnCameras addObject:scnCamera];
  }
  return [scnCameras copy];
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

@end
