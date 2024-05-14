#import "GLTFSCNAsset.h"

@implementation GLTFSCNAsset

- (instancetype)initWithGLTFData:(GLTFData *)data {
  self = [super init];
  if (self) {
    _data = data;
    _scenes = [NSArray array];
    _animationPlayers = [NSArray array];
  }
  return self;
}

+ (instancetype)assetWithGLTFData:(GLTFData *)data {
  return [[GLTFSCNAsset alloc] initWithGLTFData:data];
}

#pragma mark SCNScene

- (nullable SCNScene *)defaultScene {
  if (self.data.json.scene) {
    return self.scenes[self.data.json.scene.integerValue];
  } else {
    return self.scenes.firstObject;
  }
}

- (void)loadScenes {
  // load materials
  NSArray<SCNMaterial *> *scnMaterials = [self loadSCNMaterials];

  // load cameras
  NSArray<SCNCamera *> *scnCameras = [self loadSCNCameras];

  // load nodes
  NSMutableArray<SCNNode *> *scnNodes;
  NSMutableDictionary<SCNNode *, SCNNode *> *nodeMeshDict =
      [NSMutableDictionary dictionary];
  NSMutableArray<SCNNode *> *cameraNodes = [NSMutableArray array];

  if (self.data.json.nodes) {
    scnNodes = [NSMutableArray arrayWithCapacity:self.data.json.nodes.count];

    for (GLTFNode *node in self.data.json.nodes) {
      SCNNode *scnNode = [SCNNode node];
      scnNode.name = [[NSUUID UUID] UUIDString];

      if (node.camera) {
        scnNode.camera = scnCameras[node.camera.integerValue];
        [cameraNodes addObject:scnNode];
      }

      if (node.matrix) {
        scnNode.simdTransform = node.matrixValue;
      } else {
        scnNode.simdRotation = simdRotationFromQuaternion(node.rotationValue);
        scnNode.simdScale = node.scaleValue;
        scnNode.simdPosition = node.translationValue;
      }

      if (node.mesh) {
        GLTFMesh *mesh = self.data.json.meshes[node.mesh.integerValue];
        SCNNode *meshNode = [self scnNodeForMesh:mesh
                                    scnMaterials:scnMaterials];
        if (node.weights) {
          for (SCNNode *childNode in meshNode.childNodes) {
            if (childNode.morpher) {
              childNode.morpher.weights = node.weights;
            }
          }
        }
        [scnNode addChildNode:meshNode];
        nodeMeshDict[scnNode] = meshNode;
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

        NSMutableArray<SCNNode *> *bones =
            [NSMutableArray arrayWithCapacity:skin.joints.count];
        for (NSNumber *joint in skin.joints) {
          SCNNode *bone = scnNodes[joint.integerValue];
          [bones addObject:bone];
        }

        NSArray<NSValue *> *boneInverseBindTransforms;
        if (skin.inverseBindMatrices) {
          GLTFAccessor *accessor =
              self.data.json.accessors[skin.inverseBindMatrices.integerValue];
          NSData *data = [self.data dataForAccessor:accessor normalized:nil];
          // inverseBindMatrices must be mat4 type with float
          assert([accessor.type isEqualToString:GLTFAccessorTypeMat4] &&
                 accessor.componentType == GLTFAccessorComponentTypeFloat);
          boneInverseBindTransforms = SCNMat4ArrayFromPackedFloatData(data);
        } else {
          NSMutableArray<NSValue *> *arr =
              [NSMutableArray arrayWithCapacity:skin.joints.count];
          for (int j = 0; j < skin.joints.count; j++) {
            [arr addObject:[NSValue valueWithSCNMatrix4:SCNMatrix4Identity]];
          }
          boneInverseBindTransforms = [arr copy];
        }

        GLTFMesh *mesh = self.data.json.meshes[node.mesh.integerValue];
        SCNNode *meshNode = nodeMeshDict[scnNode];
        for (int j = 0; j < mesh.primitives.count; j++) {
          GLTFMeshPrimitive *primitive = mesh.primitives[j];
          SCNNode *primitiveNode = meshNode.childNodes[j];
          SCNGeometry *geometry = primitiveNode.geometry;

          NSArray<NSNumber *> *weights =
              [primitive valuesOfAttributeSemantic:
                             GLTFMeshPrimitiveAttributeSemanticWeights];
          NSArray<NSNumber *> *joints =
              [primitive valuesOfAttributeSemantic:
                             GLTFMeshPrimitiveAttributeSemanticJoints];
          if (weights.count == 0 || joints.count == 0)
            continue;

          GLTFAccessor *weightsAccessor =
              self.data.json.accessors[weights[0].integerValue];
          SCNGeometrySource *boneWeights = [self
              scnGeometrySourceFromAccessor:weightsAccessor
                               withSemantic:
                                   GLTFMeshPrimitiveAttributeSemanticWeights];

          GLTFAccessor *jointsAccessor =
              self.data.json.accessors[joints[0].integerValue];
          SCNGeometrySource *boneIndices = [self
              scnGeometrySourceFromAccessor:jointsAccessor
                               withSemantic:
                                   GLTFMeshPrimitiveAttributeSemanticJoints];

          SCNSkinner *skinner =
              [SCNSkinner skinnerWithBaseGeometry:geometry
                                            bones:[bones copy]
                        boneInverseBindTransforms:boneInverseBindTransforms
                                      boneWeights:boneWeights
                                      boneIndices:boneIndices];
          if (skin.skeleton) {
            skinner.skeleton = scnNodes[skin.skeleton.integerValue];
          }
          primitiveNode.skinner = skinner;
        }
      }
    }
  }
  _cameraNodes = [cameraNodes copy];

  // animations
  NSMutableArray<SCNAnimationPlayer *> *animationPlayers =
      [NSMutableArray array];

  if (self.data.json.animations) {
    for (GLTFAnimation *animation in self.data.json.animations) {
      NSMutableArray *channelAnimations = [NSMutableArray array];
      float maxDuration = 1.0f;

      for (GLTFAnimationChannel *channel in animation.channels) {
        if (channel.target.node == nil)
          continue;

        GLTFNode *node = self.data.json.nodes[channel.target.node.integerValue];
        SCNNode *scnNode = scnNodes[channel.target.node.integerValue];

        GLTFAnimationSampler *sampler = animation.samplers[channel.sampler];

        float maxKeyTime = 1.0f;
        NSArray<NSNumber *> *keyTimes =
            [self keyTimesFromAnimationSampler:sampler maxKeyTime:&maxKeyTime];
        maxDuration = MAX(maxDuration, maxKeyTime);

        GLTFAccessor *outputAccessor = self.data.json.accessors[sampler.output];
        BOOL normalized;
        NSData *outputData = [self.data dataForAccessor:outputAccessor
                                             normalized:&normalized];

        if (channel.target.isPathWeights) {
          // Weights animation
          NSArray<NSNumber *> *numbers = NSArrayFromPackedFloatData(outputData);

          GLTFMesh *mesh = self.data.json.meshes[node.mesh.integerValue];
          SCNNode *meshNode = nodeMeshDict[scnNode];

          for (NSInteger i = 0; i < mesh.primitives.count; i++) {
            GLTFMeshPrimitive *primitive = mesh.primitives[i];
            SCNNode *primitiveNode = meshNode.childNodes[i];
            if (primitive.targets == nil || primitiveNode.morpher == nil)
              continue;

            NSInteger targetsCount = primitive.targets.count;
            NSInteger keyTimesCount = keyTimes.count;

            NSMutableArray<CAKeyframeAnimation *> *weightAnimations =
                [NSMutableArray arrayWithCapacity:targetsCount];
            for (NSInteger t = 0; t < targetsCount; t++) {
              NSMutableArray<NSNumber *> *values =
                  [NSMutableArray arrayWithCapacity:keyTimesCount];
              for (NSInteger k = 0; k < keyTimesCount; k++) {
                [values addObject:numbers[k * targetsCount + t]];
              }

              CAKeyframeAnimation *weightAnimation =
                  [CAKeyframeAnimation animation];
              weightAnimation.keyPath =
                  [NSString stringWithFormat:@"/%@.morpher.weights[%ld]",
                                             primitiveNode.name, t];
              weightAnimation.keyTimes = keyTimes;
              weightAnimation.values = values;
              weightAnimation.repeatDuration = FLT_MAX;
              weightAnimation.calculationMode = kCAAnimationLinear;
              weightAnimation.duration = maxKeyTime;
              [weightAnimations addObject:weightAnimation];
            }

            CAAnimationGroup *group = [CAAnimationGroup animation];
            group.animations = weightAnimations;
            group.duration = maxKeyTime;
            [channelAnimations addObject:group];
          }
        } else {
          // Translation, Rotation, Scale

          // component type should be float
          if (outputAccessor.componentType != GLTFAccessorComponentTypeFloat &&
              !normalized)
            continue;
          // only supports vec types
          if ([outputAccessor.type isNotEqualTo:GLTFAccessorTypeVec2] &&
              [outputAccessor.type isNotEqualTo:GLTFAccessorTypeVec3] &&
              [outputAccessor.type isNotEqualTo:GLTFAccessorTypeVec4])
            continue;

          CAAnimationCalculationMode calculationMode =
              CAAnimationCalculationModeFromGLTFAnimationSamplerInterpolation(
                  sampler.interpolationValue);
          BOOL isCubisSpline = calculationMode == kCAAnimationCubic;

          NSArray<NSValue *> *values;
          NSString *keyPath;
          if (channel.target.isPathTranslation) {
            values = SCNVec3ArrayFromPackedFloatDataWithAccessor(
                outputData, outputAccessor, isCubisSpline);
            keyPath = [NSString stringWithFormat:@"/%@.position", scnNode.name];
          } else if (channel.target.isPathRotation) {
            values = SCNVec4ArrayFromPackedFloatDataWithAccessor(
                outputData, outputAccessor, isCubisSpline);
            keyPath =
                [NSString stringWithFormat:@"/%@.orientation", scnNode.name];
          } else if (channel.target.isPathScale) {
            values = SCNVec3ArrayFromPackedFloatDataWithAccessor(
                outputData, outputAccessor, isCubisSpline);
            keyPath = [NSString stringWithFormat:@"/%@.scale", scnNode.name];
          }

          CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
          animation.values = values;
          animation.keyPath = keyPath;
          animation.calculationMode = calculationMode;
          animation.keyTimes = keyTimes;
          animation.duration = maxKeyTime;
          animation.repeatDuration = FLT_MAX;

          [channelAnimations addObject:animation];
        }
      }

      CAAnimationGroup *caGroup = [CAAnimationGroup animation];
      caGroup.animations = channelAnimations;
      caGroup.duration = maxDuration;
      caGroup.repeatDuration = FLT_MAX;

      SCNAnimationPlayer *scnAnimationPlayer = [SCNAnimationPlayer
          animationPlayerWithAnimation:[SCNAnimation
                                           animationWithCAAnimation:caGroup]];
      [animationPlayers addObject:scnAnimationPlayer];
    }
  }
  self.animationPlayers = [animationPlayers copy];

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

#pragma mark mesh

- (SCNNode *)scnNodeForMesh:(GLTFMesh *)mesh
               scnMaterials:(NSArray<SCNMaterial *> *)scnMaterials {
  SCNNode *meshNode = [SCNNode node];
  meshNode.name = [[NSUUID UUID] UUIDString];

  for (GLTFMeshPrimitive *primitive in mesh.primitives) {
    NSArray<SCNGeometrySource *> *sources =
        [self scnGeometrySourcesFromMeshPrimitive:primitive];
    NSArray<SCNGeometryElement *> *elements =
        [self scnGeometryElementsFromPrimitive:primitive];
    SCNGeometry *geometry = [SCNGeometry geometryWithSources:sources
                                                    elements:elements];
    SCNNode *geometryNode = [SCNNode nodeWithGeometry:geometry];
    geometryNode.name = [[NSUUID UUID] UUIDString];

    if (primitive.material) {
      SCNMaterial *scnMaterial = scnMaterials[primitive.material.integerValue];
      geometry.materials = @[ scnMaterial ];
    }

    SCNMorpher *morpher = [self scnMorpherFromMeshPrimitive:primitive
                                               withElements:elements
                                                    weights:mesh.weights];
    geometryNode.morpher = morpher;

    [meshNode addChildNode:geometryNode];
  }
  return meshNode;
}

#pragma mark SCNMaterial

- (nullable NSArray<SCNMaterial *> *)loadSCNMaterials {
  if (!self.data.json.materials)
    return nil;
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

    if (material.isAlphaModeOpaque) {
      scnMaterial.blendMode = SCNBlendModeReplace;
      [surfaceShaderModifier appendString:@"_surface.diffuse.a = 1.0;"];
    } else if (material.isAlphaModeMask) {
      scnMaterial.blendMode = SCNBlendModeReplace;
      [surfaceShaderModifier
          appendFormat:
              @"_surface.diffuse.a = _surface.diffuse.a < %f ? 0.0 : 1.0;",
              material.alphaCutoffValue];
    } else if (material.isAlphaModeBlend) {
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

#pragma mark SCNCamera

- (nullable NSArray<SCNCamera *> *)loadSCNCameras {
  if (!self.data.json.cameras)
    return nil;

  NSMutableArray<SCNCamera *> *scnCameras =
      [NSMutableArray arrayWithCapacity:self.data.json.cameras.count];
  for (GLTFCamera *camera in self.data.json.cameras) {
    SCNCamera *scnCamera = [SCNCamera camera];
    scnCamera.name = camera.name;

    if (camera.orthographic) {
      [self applyOrthographicCamera:camera.orthographic toSCNCamera:scnCamera];
    } else if (camera.perspective) {
      [self applyPerspectiveCamera:camera.perspective toSCNCamera:scnCamera];
    }
    [scnCameras addObject:scnCamera];
  }
  return [scnCameras copy];
}

- (void)applyOrthographicCamera:(GLTFCameraOrthographic *)orthographic
                    toSCNCamera:(SCNCamera *)scnCamera {
  scnCamera.usesOrthographicProjection = YES;
  scnCamera.orthographicScale = MAX(orthographic.xmag, orthographic.ymag);
  scnCamera.zFar = orthographic.zfar;
  scnCamera.zNear = orthographic.znear;
}

- (void)applyPerspectiveCamera:(GLTFCameraPerspective *)perspective
                   toSCNCamera:(SCNCamera *)scnCamera {
  scnCamera.usesOrthographicProjection = NO;
  if (perspective.zfar) {
    scnCamera.zFar = perspective.zfar.floatValue;
  }
  scnCamera.zNear = perspective.znear;
  scnCamera.fieldOfView = perspective.yfov * (180.0 / M_PI); // radian to degree
  if (perspective.aspectRatio) {
    // w / h
    float aspectRatio = perspective.aspectRatio.floatValue;
    float yFovRadians = scnCamera.fieldOfView * (M_PI / 180.0);

    SCNMatrix4 projectionTransform = {
        // m11: Scale along the X-axis. Calculated using the aspect ratio and
        // the field of view.
        //      A higher aspect ratio leads to more stretch along the X-axis.
        .m11 = 1.0 / (aspectRatio * tan(yFovRadians * 0.5)),

        // m22: Scale along the Y-axis. Directly dependent on the field of view.
        //      Adjusts the Y-axis to maintain proper image proportions.
        .m22 = 1.0 / tan(yFovRadians * 0.5),

        // m33: Configures the depth (Z-axis) scaling. Affects how depth is
        // perceived,
        //      ensuring objects farther away appear smaller and provide a depth
        //      cue.
        .m33 = -(scnCamera.zFar + scnCamera.zNear) /
               (scnCamera.zFar - scnCamera.zNear),

        // m34: Enables perspective division, a key component for creating a
        // perspective effect.
        .m34 = -1.0,

        // m43: Adjusts the translation along the Z-axis based on the near and
        // far clipping planes.
        //      This term helps manage how different depths are rendered within
        //      the view frustum.
        .m43 = -(2.0 * scnCamera.zFar * scnCamera.zNear) /
               (scnCamera.zFar - scnCamera.zNear)};
    scnCamera.projectionTransform = projectionTransform;
  }
}

#pragma mark SCNGeometry

- (void)addGeometrySourceByAccessorIndex:(nullable NSNumber *)accessorIndex
                                semantic:(SCNGeometrySourceSemantic)semantic
                                 toArray:(NSMutableArray<SCNGeometrySource *> *)
                                             array {
  if (accessorIndex) {
    GLTFAccessor *accessor =
        self.data.json.accessors[accessorIndex.integerValue];
    SCNGeometrySource *source = [self scnGeometrySourceFromAccessor:accessor
                                                       withSemantic:semantic];
    [array addObject:source];
  }
}

- (NSArray<SCNGeometrySource *> *)scnGeometrySourcesFromMeshPrimitive:
    (GLTFMeshPrimitive *)primitive {
  NSMutableArray<SCNGeometrySource *> *sources = [NSMutableArray array];
  [self addGeometrySourceByAccessorIndex:
            [primitive valueOfAttributeSemantic:
                           GLTFMeshPrimitiveAttributeSemanticPosition]
                                semantic:SCNGeometrySourceSemanticVertex
                                 toArray:sources];
  [self
      addGeometrySourceByAccessorIndex:
          [primitive
              valueOfAttributeSemantic:GLTFMeshPrimitiveAttributeSemanticNormal]
                              semantic:SCNGeometrySourceSemanticNormal
                               toArray:sources];
  [self addGeometrySourceByAccessorIndex:
            [primitive valueOfAttributeSemantic:
                           GLTFMeshPrimitiveAttributeSemanticTangent]
                                semantic:SCNGeometrySourceSemanticTangent
                                 toArray:sources];

  NSArray<NSNumber *> *texcoords = [primitive
      valuesOfAttributeSemantic:GLTFMeshPrimitiveAttributeSemanticTexcoord];
  for (NSNumber *texcoord in texcoords) {
    [self addGeometrySourceByAccessorIndex:texcoord
                                  semantic:SCNGeometrySourceSemanticTexcoord
                                   toArray:sources];
  }
  NSArray<NSNumber *> *colors = [primitive
      valuesOfAttributeSemantic:GLTFMeshPrimitiveAttributeSemanticColor];
  for (NSNumber *color in colors) {
    [self addGeometrySourceByAccessorIndex:color
                                  semantic:SCNGeometrySourceSemanticColor
                                   toArray:sources];
  }
  return [sources copy];
}

- (SCNGeometrySource *)scnGeometrySourceFromAccessor:(GLTFAccessor *)accessor
                                        withSemantic:(SCNGeometrySourceSemantic)
                                                         semantic {
  NSInteger componentsPerVector = componentsCountOfAccessorType(accessor.type);
  BOOL normalized;
  NSData *data = [self.data dataForAccessor:accessor normalized:&normalized];
  BOOL isFloat =
      accessor.componentType == GLTFAccessorComponentTypeFloat || normalized;
  NSInteger bytesPerComponent =
      isFloat ? sizeof(float) : sizeOfComponentType(accessor.componentType);
  NSInteger dataStride = componentsPerVector * bytesPerComponent;
  return [SCNGeometrySource geometrySourceWithData:data
                                          semantic:semantic
                                       vectorCount:accessor.count
                                   floatComponents:isFloat
                               componentsPerVector:componentsPerVector
                                 bytesPerComponent:bytesPerComponent
                                        dataOffset:0
                                        dataStride:dataStride];
}

- (nullable NSArray<SCNGeometryElement *> *)scnGeometryElementsFromPrimitive:
    (GLTFMeshPrimitive *)primitive {
  if (!primitive.indices)
    return nil;

  GLTFAccessor *accessor =
      self.data.json.accessors[primitive.indices.integerValue];
  NSData *data = [self.data dataForAccessor:accessor normalized:nil];

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
    element.minimumPointScreenSpaceRadius = 1.0;
    element.maximumPointScreenSpaceRadius = 1.0;
  }
  return @[ element ];
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

- (nullable SCNMorpher *)
    scnMorpherFromMeshPrimitive:(GLTFMeshPrimitive *)primitive
                   withElements:(NSArray<SCNGeometryElement *> *)elements
                        weights:(nullable NSArray<NSNumber *> *)weights {
  if (!primitive.targets)
    return nil;

  SCNMorpher *morpher = [SCNMorpher new];

  NSMutableArray<SCNGeometry *> *morphTargets =
      [NSMutableArray arrayWithCapacity:primitive.targets.count];
  for (int i = 0; i < primitive.targets.count; i++) {
    GLTFMeshPrimitiveTarget *target = primitive.targets[i];
    NSArray<SCNGeometrySource *> *sources =
        [self scnGeometrySourcesFromMeshPrimitiveTarget:target];
    SCNGeometry *morphTarget = [SCNGeometry geometryWithSources:sources
                                                       elements:elements];
    [morphTargets addObject:morphTarget];
  }

  morpher.targets = [morphTargets copy];
  morpher.unifiesNormals = YES;
  morpher.calculationMode = SCNMorpherCalculationModeAdditive;
  if (weights)
    morpher.weights = weights;
  return morpher;
}

- (NSArray<SCNGeometrySource *> *)scnGeometrySourcesFromMeshPrimitiveTarget:
    (GLTFMeshPrimitiveTarget *)primitiveTarget {
  NSMutableArray<SCNGeometrySource *> *sources = [NSMutableArray array];
  [self addGeometrySourceByAccessorIndex:primitiveTarget.position
                                semantic:SCNGeometrySourceSemanticVertex
                                 toArray:sources];
  [self addGeometrySourceByAccessorIndex:primitiveTarget.normal
                                semantic:SCNGeometrySourceSemanticNormal
                                 toArray:sources];
  [self addGeometrySourceByAccessorIndex:primitiveTarget.tangent
                                semantic:SCNGeometrySourceSemanticTangent
                                 toArray:sources];
  return [sources copy];
}

#pragma mark animation

CAAnimationCalculationMode
CAAnimationCalculationModeFromGLTFAnimationSamplerInterpolation(
    NSString *interpolation) {
  if ([interpolation isEqualToString:GLTFAnimationSamplerInterpolationLinear]) {
    return kCAAnimationLinear;
  } else if ([interpolation
                 isEqualToString:GLTFAnimationSamplerInterpolationStep]) {
    return kCAAnimationDiscrete;
  } else if ([interpolation isEqualToString:
                                GLTFAnimationSamplerInterpolationCubicSpline]) {
    // TODO: tangent
    return kCAAnimationCubic;
  }
  return kCAAnimationLinear;
}

- (NSArray<NSNumber *> *)keyTimesFromAnimationSampler:
                             (GLTFAnimationSampler *)sampler
                                           maxKeyTime:(float *)maxKeyTime {
  GLTFAccessor *inputAccessor = self.data.json.accessors[sampler.input];
  // input must be scalar type with float
  assert([inputAccessor.type isEqualToString:GLTFAccessorTypeScalar] &&
         inputAccessor.componentType == GLTFAccessorComponentTypeFloat);
  NSData *inputData = [self.data dataForAccessor:inputAccessor normalized:nil];
  NSArray<NSNumber *> *array = NSArrayFromPackedFloatData(inputData);
  float max = inputAccessor.max != nil
                  ? inputAccessor.max.firstObject.floatValue
                  : array.lastObject.floatValue;
  // normalize [0,1]
  NSMutableArray<NSNumber *> *normalized =
      [NSMutableArray arrayWithCapacity:array.count];
  for (NSNumber *value in array) {
    [normalized addObject:@(value.floatValue / max)];
  }
  *maxKeyTime = max;
  return [normalized copy];
}

#pragma mark -

NSArray<NSNumber *> *NSArrayFromPackedFloatData(NSData *data) {
  NSUInteger count = data.length / sizeof(float);
  NSMutableArray<NSNumber *> *array = [NSMutableArray arrayWithCapacity:count];
  const float *bytes = (const float *)data.bytes;
  for (NSUInteger i = 0; i < count; i++) {
    [array addObject:@(bytes[i])];
  }
  return [array copy];
}

NSArray<NSValue *> *SCNMat4ArrayFromPackedFloatData(NSData *data) {
  NSUInteger count = data.length / sizeof(float) / 16;
  NSMutableArray<NSValue *> *arr = [NSMutableArray arrayWithCapacity:count];
  const float *base = (float *)data.bytes;
  for (NSUInteger i = 0; i < count; i++) {
    const float *bytes = base + i * 16;
    SCNMatrix4 matrix;
    matrix.m11 = bytes[0];
    matrix.m12 = bytes[1];
    matrix.m13 = bytes[2];
    matrix.m14 = bytes[3];
    matrix.m21 = bytes[4];
    matrix.m22 = bytes[5];
    matrix.m23 = bytes[6];
    matrix.m24 = bytes[7];
    matrix.m31 = bytes[8];
    matrix.m32 = bytes[9];
    matrix.m33 = bytes[10];
    matrix.m34 = bytes[11];
    matrix.m41 = bytes[12];
    matrix.m42 = bytes[13];
    matrix.m43 = bytes[14];
    matrix.m44 = bytes[15];
    [arr addObject:[NSValue valueWithSCNMatrix4:matrix]];
  }
  return [arr copy];
}

NSArray<NSValue *> *SCNVec4ArrayFromPackedFloatDataWithAccessor(
    NSData *data, GLTFAccessor *accessor, BOOL isCubisSpline) {
  NSInteger count = isCubisSpline ? accessor.count / 3 : accessor.count;
  NSMutableArray<NSValue *> *values = [NSMutableArray arrayWithCapacity:count];
  float *bytes = (float *)data.bytes;
  for (int i = 0; i < count; i++) {
    SCNVector4 vec = SCNVector4Zero;
    if ([accessor.type isEqualTo:GLTFAccessorTypeVec2]) {
      if (isCubisSpline)
        bytes += 2; // skip in-tangent
      vec.x = bytes[0];
      vec.y = bytes[1];
      bytes += 2;
      if (isCubisSpline)
        bytes += 2; // skip out-tangent
    } else if ([accessor.type isEqualTo:GLTFAccessorTypeVec3]) {
      if (isCubisSpline)
        bytes += 3; // skip in-tangent
      vec.x = bytes[0];
      vec.y = bytes[1];
      vec.z = bytes[2];
      bytes += 3;
      if (isCubisSpline)
        bytes += 3; // skip out-tangent
    } else if ([accessor.type isEqualTo:GLTFAccessorTypeVec4]) {
      if (isCubisSpline)
        bytes += 4; // skip in-tangent
      vec.x = bytes[0];
      vec.y = bytes[1];
      vec.z = bytes[2];
      vec.w = bytes[3];
      bytes += 4;
      if (isCubisSpline)
        bytes += 4; // skip out-tangent
    }
    [values addObject:[NSValue valueWithSCNVector4:vec]];
  }
  return [values copy];
}

NSArray<NSValue *> *SCNVec3ArrayFromPackedFloatDataWithAccessor(
    NSData *data, GLTFAccessor *accessor, BOOL isCubisSpline) {
  NSInteger count = isCubisSpline ? accessor.count / 3 : accessor.count;
  NSMutableArray<NSValue *> *values = [NSMutableArray arrayWithCapacity:count];
  float *bytes = (float *)data.bytes;
  for (int i = 0; i < count; i++) {
    SCNVector3 vec = SCNVector3Zero;
    if ([accessor.type isEqualTo:GLTFAccessorTypeVec2]) {
      if (isCubisSpline)
        bytes += 2; // skip in-tangent
      vec.x = bytes[0];
      vec.y = bytes[1];
      bytes += 2;
      if (isCubisSpline)
        bytes += 2; // skip out-tangent
    } else if ([accessor.type isEqualTo:GLTFAccessorTypeVec3]) {
      if (isCubisSpline)
        bytes += 3; // skip in-tangent
      vec.x = bytes[0];
      vec.y = bytes[1];
      vec.z = bytes[2];
      bytes += 3;
      if (isCubisSpline)
        bytes += 3; // skip out-tangent
    } else if ([accessor.type isEqualTo:GLTFAccessorTypeVec4]) {
      if (isCubisSpline)
        bytes += 4; // skip in-tangent
      vec.x = bytes[0];
      vec.y = bytes[1];
      vec.z = bytes[2];
      bytes += 4;
      if (isCubisSpline)
        bytes += 4; // skip out-tangent
    }
    [values addObject:[NSValue valueWithSCNVector3:vec]];
  }
  return [values copy];
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
