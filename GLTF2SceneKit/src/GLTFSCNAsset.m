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

- (nullable SCNScene *)defaultScene {
  if (self.data.json.scene) {
    return self.scenes[self.data.json.scene.integerValue];
  } else {
    return self.scenes.firstObject;
  }
}

- (void)loadScenes {
  // load materials
  NSMutableArray<SCNMaterial *> *scnMaterials;

  if (self.data.json.materials) {
    scnMaterials =
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

      if ([material.alphaModeValue
              isEqualToString:GLTFMaterialAlphaModeOpaque]) {
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
  }

  // load cameras
  NSMutableArray<SCNCamera *> *scnCameras;

  if (self.data.json.cameras) {
    scnCameras =
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
  }

  // load meshes
  NSMutableArray<SCNNode *> *meshNodes;

  if (self.data.json.meshes) {
    meshNodes = [NSMutableArray arrayWithCapacity:self.data.json.meshes.count];

    for (GLTFMesh *mesh in self.data.json.meshes) {
      SCNNode *meshNode = [SCNNode node];
      //      meshNode.name = mesh.name;
      meshNode.name = [[NSUUID UUID] UUIDString];

      for (GLTFMeshPrimitive *primitive in mesh.primitives) {
        NSMutableArray<SCNGeometrySource *> *sources = [NSMutableArray array];
        NSNumber *position =
            [primitive valueOfAttributeSemantic:
                           GLTFMeshPrimitiveAttributeSemanticPosition];
        if (position) {
          GLTFAccessor *accessor =
              self.data.json.accessors[position.integerValue];
          SCNGeometrySource *source = [self
              scnGeometrySourceFromGLTFAccessor:accessor
                                   withSemantic:
                                       GLTFMeshPrimitiveAttributeSemanticPosition];
          [sources addObject:source];
        }
        NSNumber *normal = [primitive
            valueOfAttributeSemantic:GLTFMeshPrimitiveAttributeSemanticNormal];
        if (normal) {
          GLTFAccessor *accessor =
              self.data.json.accessors[normal.integerValue];
          SCNGeometrySource *source = [self
              scnGeometrySourceFromGLTFAccessor:accessor
                                   withSemantic:
                                       GLTFMeshPrimitiveAttributeSemanticNormal];
          [sources addObject:source];
        }
        NSNumber *tangent = [primitive
            valueOfAttributeSemantic:GLTFMeshPrimitiveAttributeSemanticTangent];
        if (tangent) {
          GLTFAccessor *accessor =
              self.data.json.accessors[tangent.integerValue];
          SCNGeometrySource *source = [self
              scnGeometrySourceFromGLTFAccessor:accessor
                                   withSemantic:
                                       GLTFMeshPrimitiveAttributeSemanticTangent];
          [sources addObject:source];
        }

        NSArray<SCNGeometryElement *> *elements =
            [self scnGeometryElementsFromPrimitive:primitive];

        SCNGeometry *geometry = [SCNGeometry geometryWithSources:sources
                                                        elements:elements];
        SCNNode *geometryNode = [SCNNode nodeWithGeometry:geometry];
        geometryNode.name = [[NSUUID UUID] UUIDString];

        if (primitive.material) {
          SCNMaterial *scnMaterial =
              scnMaterials[primitive.material.integerValue];
          geometry.materials = @[ scnMaterial ];
        }

        if (primitive.targets) {
          SCNMorpher *morpher = [SCNMorpher new];
          NSMutableArray<SCNGeometry *> *morphTargets =
              [NSMutableArray arrayWithCapacity:primitive.targets.count];
          for (int i = 0; i < primitive.targets.count; i++) {
            GLTFMeshPrimitiveTarget *target = primitive.targets[i];
            NSArray<SCNGeometrySource *> *sources =
                [self scnGeometrySourcesFromMorphTarget:target];
            SCNGeometry *morphTarget =
                [SCNGeometry geometryWithSources:sources elements:elements];
            [morphTargets addObject:morphTarget];
          }
          morpher.targets = [morphTargets copy];
          if (mesh.weights)
            morpher.weights = mesh.weights;
          morpher.unifiesNormals = YES;
          morpher.calculationMode = SCNMorpherCalculationModeAdditive;
          geometryNode.morpher = morpher;
        }

        [meshNode addChildNode:geometryNode];
      }

      [meshNodes addObject:meshNode];
    }
  }

  // load nodes
  NSMutableArray<SCNNode *> *scnNodes;

  if (self.data.json.nodes) {
    scnNodes = [NSMutableArray arrayWithCapacity:self.data.json.nodes.count];

    for (GLTFNode *node in self.data.json.nodes) {
      SCNNode *scnNode = [SCNNode node];
      //      scnNode.name = node.name;
      scnNode.name = [[NSUUID UUID] UUIDString];

      if (node.camera) {
        scnNode.camera = scnCameras[node.camera.integerValue];
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
        if (node.weights) {
          for (SCNNode *childNode in meshNode.childNodes) {
            if (childNode.morpher) {
              childNode.morpher.weights = node.weights;
            }
          }
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
          NSData *data = [self.data dataForAccessor:accessor];
          // inverseBindMatrices must be mat4 type with float
          assert([accessor.type isEqualToString:GLTFAccessorTypeMat4] &&
                 accessor.componentType == GLTFAccessorComponentTypeFloat);
          // float[16][skin.joints.count]
          NSArray<NSArray<NSNumber *> *> *values =
              [GLTFData unpackGLTFAccessorDataToArray:accessor data:data];
          assert(skin.joints.count == values.count);
          boneInverseBindTransforms = SCNMat4ArrayFromNumbers(values);
        } else {
          NSMutableArray<NSValue *> *arr =
              [NSMutableArray arrayWithCapacity:skin.joints.count];
          for (int j = 0; j < skin.joints.count; j++) {
            SCNMatrix4 identity = SCNMatrix4Identity;
            [arr addObject:[NSValue valueWithSCNMatrix4:identity]];
          }
          boneInverseBindTransforms = [arr copy];
        }

        GLTFMesh *mesh = self.data.json.meshes[node.mesh.integerValue];
        SCNNode *meshNode = meshNodes[node.mesh.integerValue];
        for (int j = 0; j < mesh.primitives.count; j++) {
          GLTFMeshPrimitive *primitive = mesh.primitives[j];
          SCNNode *primitiveNode = meshNode.childNodes[j];
          SCNGeometry *geometry = primitiveNode.geometry;

          NSArray<NSNumber *> *weights =
              [primitive valuesOfAttributeSemantic:
                             GLTFMeshPrimitiveAttributeSemanticWeights];
          GLTFAccessor *weightsAccessor =
              self.data.json.accessors[weights[0].integerValue];
          SCNGeometrySource *boneWeights = [self
              scnGeometrySourceFromGLTFAccessor:weightsAccessor
                                   withSemantic:
                                       GLTFMeshPrimitiveAttributeSemanticWeights];

          NSArray<NSNumber *> *joints =
              [primitive valuesOfAttributeSemantic:
                             GLTFMeshPrimitiveAttributeSemanticJoints];
          GLTFAccessor *jointsAccessor =
              self.data.json.accessors[joints[0].integerValue];
          SCNGeometrySource *boneIndices = [self
              scnGeometrySourceFromGLTFAccessor:jointsAccessor
                                   withSemantic:
                                       GLTFMeshPrimitiveAttributeSemanticJoints];

          SCNSkinner *skinner =
              [SCNSkinner skinnerWithBaseGeometry:geometry
                                            bones:[bones copy]
                        boneInverseBindTransforms:boneInverseBindTransforms
                                      boneWeights:boneWeights
                                      boneIndices:boneIndices];
          primitiveNode.skinner = skinner;
        }
      }
    }
  }

  // animations
  NSMutableArray<SCNAnimationPlayer *> *animationPlayers =
      [NSMutableArray array];

  if (self.data.json.animations) {
    for (GLTFAnimation *animation in self.data.json.animations) {
      NSMutableArray *caChannels = [NSMutableArray array];

      float channelMaxDuration = 0.0f;
      for (GLTFAnimationChannel *channel in animation.channels) {
        if (channel.target.node == nil)
          continue;

        SCNNode *target = scnNodes[channel.target.node.integerValue];

        GLTFAnimationSampler *sampler = animation.samplers[channel.sampler];

        GLTFAccessor *inputAccessor = self.data.json.accessors[sampler.input];
        NSData *inputData = [self.data dataForAccessor:inputAccessor];
        // input must be scalar type with float
        assert([inputAccessor.type isEqualToString:GLTFAccessorTypeScalar] &&
               inputAccessor.componentType == GLTFAccessorComponentTypeFloat);
        NSArray<NSNumber *> *keyTimes =
            [GLTFData unpackGLTFAccessorDataToArray:inputAccessor
                                               data:inputData];
        assert(inputAccessor.count == keyTimes.count);

        for (NSNumber *keyTime in keyTimes) {
          channelMaxDuration = MAX(keyTime.floatValue, channelMaxDuration);
        }

        GLTFAccessor *outputAccessor = self.data.json.accessors[sampler.output];
        NSData *outputData = [self.data dataForAccessor:outputAccessor];

        if ([channel.target.path
                isEqualToString:GLTFAnimationChannelTargetPathTranslation]) {
          // TODO:
        } else if ([channel.target.path
                       isEqualToString:
                           GLTFAnimationChannelTargetPathRotation]) {
          NSArray *values =
              [GLTFData unpackGLTFAccessorDataToArray:outputAccessor
                                                 data:outputData];

          CAKeyframeAnimation *caAnimation = [CAKeyframeAnimation animation];
          NSString *keyPath =
              [NSString stringWithFormat:@"/%@.orientation", target.name];
          caAnimation.keyPath = keyPath;
          caAnimation.values = SCNVec4ArrayFromNumbers(values);
          caAnimation.calculationMode =
              CAAnimationCalculationModeFromGLTFAnimationSamplerInterpolation(
                  sampler.interpolationValue);
          caAnimation.keyTimes = keyTimes;
          caAnimation.duration = keyTimes.lastObject.floatValue;

          [caChannels addObject:caAnimation];
        } else if ([channel.target.path
                       isEqualToString:GLTFAnimationChannelTargetPathScale]) {
          // TODO:
        } else if ([channel.target.path
                       isEqualToString:GLTFAnimationChannelTargetPathWeights]) {
          NSArray<NSNumber *> *numbers = dataToFloatArray(outputData);

          GLTFMesh *mesh =
              self.data.json
                  .meshes[self.data.json.nodes[channel.target.node.integerValue]
                              .mesh.integerValue];
          SCNNode *meshNode = target.childNodes.firstObject;
          for (int i = 0; i < mesh.primitives.count; i++) {
            GLTFMeshPrimitive *primitive = mesh.primitives[i];
            SCNNode *primitiveNode = meshNode.childNodes[i];
            if (primitive.targets && primitiveNode.morpher) {
              NSInteger targetsCount = primitive.targets.count;
              NSMutableArray<NSMutableArray<NSNumber *> *> *values =
                  [NSMutableArray arrayWithCapacity:targetsCount];
              for (int t = 0; t < targetsCount; t++) {
                NSMutableArray<NSNumber *> *targetValues =
                    [NSMutableArray arrayWithCapacity:keyTimes.count];
                [values addObject:targetValues];
              }
              for (int j = 0; j < targetsCount * keyTimes.count; j++) {
                int keyframe = j / targetsCount;
                int target = j % targetsCount;
                NSNumber *value = numbers[j];
                [values[target] addObject:value];
              }

              NSMutableArray<CAKeyframeAnimation *> *weightAnimations =
                  [NSMutableArray arrayWithCapacity:targetsCount];
              for (int t = 0; t < targetsCount; t++) {
                CAKeyframeAnimation *animation =
                    [CAKeyframeAnimation animation];
                NSString *keyPath =
                    [NSString stringWithFormat:@"/%@.morpher.weights[%d]",
                                               primitiveNode.name, t];
                animation.keyPath = keyPath;
                animation.keyTimes = keyTimes;
                animation.values = values[t];
                animation.repeatDuration = FLT_MAX;
                animation.calculationMode = kCAAnimationLinear;
                animation.duration = keyTimes.lastObject.floatValue;
                [weightAnimations addObject:animation];
              }
              CAAnimationGroup *group = [CAAnimationGroup animation];
              group.animations = weightAnimations;
              group.duration = keyTimes.lastObject.floatValue;
              [caChannels addObject:group];
            }
          }
        }
      }

      CAAnimationGroup *caGroup = [CAAnimationGroup animation];
      caGroup.animations = caChannels;
      caGroup.duration = channelMaxDuration;
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

NSArray<NSNumber *> *dataToFloatArray(NSData *data) {
  if (data == nil || (data.length % sizeof(float)) != 0) {
    NSLog(@"Invalid data: Data is nil or not a multiple of sizeof(float).");
    return nil;
  }

  NSUInteger numFloats = data.length / sizeof(float);
  NSMutableArray<NSNumber *> *floatArray =
      [NSMutableArray arrayWithCapacity:numFloats];
  const float *floats = (const float *)data.bytes;
  for (NSUInteger i = 0; i < numFloats; i++) {
    [floatArray addObject:@(floats[i])];
  }
  return [floatArray copy];
}

NSArray<NSValue *> *SCNVec4ArrayFromNumbers(NSArray<NSNumber *> *array) {
  NSMutableArray<NSValue *> *arr =
      [NSMutableArray arrayWithCapacity:array.count];
  for (NSArray<NSNumber *> *values in array) {
    [arr addObject:[NSValue valueWithSCNVector4:SCNVector4Make(
                                                    values[0].floatValue,
                                                    values[1].floatValue,
                                                    values[2].floatValue,
                                                    values[3].floatValue)]];
  }
  return [arr copy];
}

NSArray<NSValue *> *
SCNMat4ArrayFromNumbers(NSArray<NSArray<NSNumber *> *> *array) {
  NSMutableArray<NSValue *> *arr =
      [NSMutableArray arrayWithCapacity:array.count];
  for (NSArray<NSNumber *> *values in array) {
    SCNMatrix4 matrix;
    matrix.m11 = values[0].floatValue;
    matrix.m12 = values[1].floatValue;
    matrix.m13 = values[2].floatValue;
    matrix.m14 = values[3].floatValue;
    matrix.m21 = values[4].floatValue;
    matrix.m22 = values[5].floatValue;
    matrix.m23 = values[6].floatValue;
    matrix.m24 = values[7].floatValue;
    matrix.m31 = values[8].floatValue;
    matrix.m32 = values[9].floatValue;
    matrix.m33 = values[10].floatValue;
    matrix.m34 = values[11].floatValue;
    matrix.m41 = values[12].floatValue;
    matrix.m42 = values[13].floatValue;
    matrix.m43 = values[14].floatValue;
    matrix.m44 = values[15].floatValue;
    [arr addObject:[NSValue valueWithSCNMatrix4:matrix]];
  }
  return [arr copy];
}

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
    // TODO:
    return kCAAnimationPaced;
  }
  return kCAAnimationLinear;
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

- (SCNGeometrySource *)scnGeometrySourceFromGLTFAccessor:
                           (GLTFAccessor *)accessor
                                            withSemantic:(NSString *)semantic {
  NSInteger componentsPerVector = componentsCountOfAccessorType(accessor.type);
  NSInteger bytesPerComponent = sizeOfComponentType(accessor.componentType);
  NSInteger dataStride = componentsPerVector * bytesPerComponent;
  NSData *data = [self.data dataForAccessor:accessor];
  SCNGeometrySourceSemantic sourceSemantic =
      SCNGeometrySourceSemanticFromGLTFMeshPrimitiveAttributeSemantic(semantic);
  return
      [SCNGeometrySource geometrySourceWithData:data
                                       semantic:sourceSemantic
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
        self.data.json.accessors[primitive.indices.integerValue];
    NSData *data = [self.data dataForAccessor:accessor];

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

- (NSArray<SCNGeometrySource *> *)scnGeometrySourcesFromMorphTarget:
    (GLTFMeshPrimitiveTarget *)primitiveTarget {
  NSMutableArray<SCNGeometrySource *> *sources = [NSMutableArray array];
  if (primitiveTarget.position) {
    GLTFAccessor *accessor =
        self.data.json.accessors[primitiveTarget.position.integerValue];
    SCNGeometrySource *source = [self
        scnGeometrySourceFromGLTFAccessor:accessor
                             withSemantic:
                                 GLTFMeshPrimitiveAttributeSemanticPosition];
    [sources addObject:source];
  }
  if (primitiveTarget.normal) {
    GLTFAccessor *accessor =
        self.data.json.accessors[primitiveTarget.normal.integerValue];
    SCNGeometrySource *source = [self
        scnGeometrySourceFromGLTFAccessor:accessor
                             withSemantic:
                                 GLTFMeshPrimitiveAttributeSemanticNormal];
    [sources addObject:source];
  }
  if (primitiveTarget.tangent) {
    GLTFAccessor *accessor =
        self.data.json.accessors[primitiveTarget.tangent.integerValue];
    SCNGeometrySource *source = [self
        scnGeometrySourceFromGLTFAccessor:accessor
                             withSemantic:
                                 GLTFMeshPrimitiveAttributeSemanticTangent];
    [sources addObject:source];
  }
  return [sources copy];
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
