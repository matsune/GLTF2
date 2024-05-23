#import "GLTFSCNAsset.h"
#include "GLTF2.h"
#include "GLTFError.h"
#include <memory>
#include <unordered_map>

NSError *NSErrorFromInputException(gltf2::InputException e) {
  return [NSError errorWithDomain:GLTFErrorDomainInput
                             code:GLTFInputError
                         userInfo:@{
                           NSLocalizedDescriptionKey : [NSString
                               stringWithCString:e.what()
                                        encoding:NSUTF8StringEncoding],
                         }];
}

NSError *NSErrorFromKeyNotFoundException(gltf2::KeyNotFoundException e) {
  return [NSError errorWithDomain:GLTFErrorDomainKeyNotFound
                             code:GLTFKeyNotFoundError
                         userInfo:@{
                           NSLocalizedDescriptionKey : [NSString
                               stringWithCString:e.what()
                                        encoding:NSUTF8StringEncoding],
                         }];
}

NSError *NSErrorFromInvalidFormatException(gltf2::InvalidFormatException e) {
  return [NSError errorWithDomain:GLTFErrorDomainInvalidFormat
                             code:GLTFInvalidFormatError
                         userInfo:@{
                           NSLocalizedDescriptionKey : [NSString
                               stringWithCString:e.what()
                                        encoding:NSUTF8StringEncoding],
                         }];
}

@interface GLTFSCNAsset () {
  std::unique_ptr<gltf2::GLTFData> _data;
}

@end

@implementation GLTFSCNAsset

- (instancetype)init {
  self = [super init];
  if (self) {
    _scenes = [NSArray array];
    _cameraNodes = [NSArray array];
    _animationPlayers = [NSArray array];
  }
  return self;
}

- (BOOL)loadFile:(const NSString *)path
           error:(NSError *_Nullable *_Nullable)error {
  try {
    _data = std::make_unique<gltf2::GLTFData>(
        std::move(gltf2::GLTFData::parseFile([path UTF8String])));
  } catch (gltf2::InputException e) {
    if (error)
      *error = NSErrorFromInputException(e);
    return NO;
  } catch (gltf2::KeyNotFoundException e) {
    if (error)
      *error = NSErrorFromKeyNotFoundException(e);
    return NO;
  } catch (gltf2::InvalidFormatException e) {
    if (error)
      *error = NSErrorFromInvalidFormatException(e);
    return NO;
  }

  [self loadScenes];

  return YES;
}

#pragma mark SCNScene

- (nullable SCNScene *)defaultScene {
  if (_data->json.scene.has_value()) {
    return self.scenes[*_data->json.scene];
  } else {
    return self.scenes.firstObject;
  }
}

- (simd_float4x4)simdTransformOfNode:(const gltf2::GLTFNode &)node {
  if (node.matrix.has_value()) {
    auto matrixValue = node.matrixValue();
    simd_float4x4 matrix;
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        int index = i * 4 + j;
        matrix.columns[i][j] = matrixValue.at(index);
      }
    }
    return matrix;
  } else if (node.rotation.has_value() || node.translation.has_value() ||
             node.scale.has_value()) {
    std::array<float, 4> rotationValues = node.rotationValue();
    simd_quatf q = simd_quaternion(rotationValues[0], rotationValues[1],
                                   rotationValues[2], rotationValues[3]);

    std::array<float, 3> translationValues = node.translationValue();
    simd_float3 t = {translationValues[0], translationValues[1],
                     translationValues[2]};

    std::array<float, 3> scaleValues = node.scaleValue();
    simd_float3 s = {scaleValues[0], scaleValues[1], scaleValues[2]};

    simd_float4x4 rMat = simd_matrix4x4(q);
    simd_float4x4 tMat = matrix_identity_float4x4;
    tMat.columns[3].x = t[0];
    tMat.columns[3].y = t[1];
    tMat.columns[3].z = t[2];
    simd_float4x4 sMat = matrix_identity_float4x4;
    sMat.columns[0].x = s[0];
    sMat.columns[1].y = s[1];
    sMat.columns[2].z = s[2];

    return simd_mul(tMat, simd_mul(rMat, sMat));
  }
  return matrix_identity_float4x4;
}

- (void)loadScenes {
  // load materials
  NSArray<SCNMaterial *> *scnMaterials = [self loadSCNMaterials];

  // load cameras
  NSArray<SCNCamera *> *scnCameras = [self loadSCNCameras];

  // load nodes
  NSMutableArray<SCNNode *> *scnNodes;
  NSMutableArray<SCNNode *> *cameraNodes = [NSMutableArray array];

  std::unordered_map<uint32_t, std::vector<gltf2::MeshPrimitive>>
      meshPrimitiveCache;

  if (_data->json.nodes.has_value()) {
    scnNodes = [NSMutableArray arrayWithCapacity:_data->json.nodes->size()];

    for (const auto &node : *_data->json.nodes) {
      SCNNode *scnNode = [SCNNode node];
      scnNode.name = [[NSUUID UUID] UUIDString];
      scnNode.simdTransform = [self simdTransformOfNode:node];

      if (node.camera.has_value()) {
        scnNode.camera = scnCameras[*node.camera];
        [cameraNodes addObject:scnNode];
      }

      if (node.mesh.has_value()) {
        const auto &mesh = _data->json.meshes->at(*node.mesh);

        std::vector<gltf2::MeshPrimitive> meshPrimitives;
        for (const auto &primitive : mesh.primitives) {
          auto meshPrimitive = _data->meshPrimitiveFromPrimitive(primitive);
          meshPrimitives.push_back(meshPrimitive);

          SCNGeometry *geometry =
              [self scnGeometryFromMeshPrimitive:meshPrimitive];
          if (primitive.modeValue() == gltf2::GLTFMeshPrimitive::Mode::POINTS &&
              geometry.geometryElementCount > 0) {
            geometry.geometryElements.firstObject
                .minimumPointScreenSpaceRadius = 1.0;
            geometry.geometryElements.firstObject
                .maximumPointScreenSpaceRadius = 1.0;
          }

          if (primitive.material.has_value()) {
            SCNMaterial *scnMaterial = scnMaterials[*primitive.material];
            geometry.materials = @[ scnMaterial ];
          }

          SCNMorpher *morpher =
              [self scnMorpherFromMeshPrimitive:primitive
                                   withElements:geometry.geometryElements
                                        weights:mesh.weights];

          if (mesh.primitives.size() > 1) {
            SCNNode *geometryNode = [SCNNode nodeWithGeometry:geometry];
            geometryNode.name = [[NSUUID UUID] UUIDString];
            geometryNode.morpher = morpher;
            [scnNode addChildNode:geometryNode];
          } else {
            scnNode.geometry = geometry;
            scnNode.morpher = morpher;
          }
        }
        meshPrimitiveCache[*node.mesh] = meshPrimitives;
      }

      [scnNodes addObject:scnNode];
    }

    for (int i = 0; i < _data->json.nodes->size(); i++) {
      const auto &node = _data->json.nodes->at(i);
      SCNNode *scnNode = scnNodes[i];

      if (node.children.has_value()) {
        for (auto childIndex : *node.children) {
          SCNNode *childNode = scnNodes[childIndex];
          [scnNode addChildNode:childNode];
        }
      }

      if (node.skin.has_value()) {
        const auto &skin = _data->json.skins->at(*node.skin);

        NSMutableArray<SCNNode *> *bones =
            [NSMutableArray arrayWithCapacity:skin.joints.size()];
        for (auto joint : skin.joints) {
          SCNNode *bone = scnNodes[joint];
          [bones addObject:bone];
        }

        NSArray<NSValue *> *boneInverseBindTransforms;
        if (skin.inverseBindMatrices.has_value()) {
          const auto &accessor =
              _data->json.accessors->at(*skin.inverseBindMatrices);
          auto data = _data->dataForAccessor(accessor, nil);
          // inverseBindMatrices must be mat4 type with float
          assert(accessor.type == gltf2::GLTFAccessor::Type::MAT4 &&
                 accessor.componentType ==
                     gltf2::GLTFAccessor::ComponentType::FLOAT);
          boneInverseBindTransforms = SCNMat4ArrayFromPackedFloatData(data);
        } else {
          NSMutableArray<NSValue *> *arr =
              [NSMutableArray arrayWithCapacity:skin.joints.size()];
          for (int j = 0; j < skin.joints.size(); j++) {
            [arr addObject:[NSValue valueWithSCNMatrix4:SCNMatrix4Identity]];
          }
          boneInverseBindTransforms = [arr copy];
        }

        const auto &mesh = _data->json.meshes->at(*node.mesh);
        const auto &meshPrimitives = meshPrimitiveCache[*node.mesh];
        for (int j = 0; j < mesh.primitives.size(); j++) {
          const auto &primitive = mesh.primitives[j];
          const auto &meshPrimitive = meshPrimitives[j];

          SCNNode *geometryNode;
          if (mesh.primitives.size() > 1) {
            geometryNode = scnNode.childNodes[j];
          } else {
            geometryNode = scnNode;
          }
          SCNGeometry *geometry = geometryNode.geometry;

          SCNGeometrySource *boneWeights;
          if (meshPrimitive.sources.weights.size() > 0) {
            boneWeights = [self
                scnGeometrySourceFromMeshPrimitiveSource:meshPrimitive.sources
                                                             .weights[0]
                                                semantic:
                                                    SCNGeometrySourceSemanticBoneWeights];
          }
          SCNGeometrySource *boneIndices;
          if (meshPrimitive.sources.joints.size() > 0) {
            boneIndices = [self
                scnGeometrySourceFromMeshPrimitiveSource:meshPrimitive.sources
                                                             .joints[0]
                                                semantic:
                                                    SCNGeometrySourceSemanticBoneIndices];
          }
          if (!boneWeights || !boneIndices)
            continue;

          SCNSkinner *skinner =
              [SCNSkinner skinnerWithBaseGeometry:geometry
                                            bones:[bones copy]
                        boneInverseBindTransforms:boneInverseBindTransforms
                                      boneWeights:boneWeights
                                      boneIndices:boneIndices];
          if (skin.skeleton.has_value()) {
            skinner.skeleton = scnNodes[*skin.skeleton];
          }
          geometryNode.skinner = skinner;
        }
      }
    }
  }
  _cameraNodes = [cameraNodes copy];

  // animations
  NSMutableArray<SCNAnimationPlayer *> *animationPlayers =
      [NSMutableArray array];

  if (_data->json.animations.has_value()) {
    for (const auto &animation : *_data->json.animations) {
      NSMutableArray *channelAnimations = [NSMutableArray array];
      float maxDuration = 1.0f;

      for (const auto &channel : animation.channels) {
        if (!channel.target.node.has_value())
          continue;

        const auto &node = _data->json.nodes->at(*channel.target.node);
        SCNNode *scnNode = scnNodes[*channel.target.node];

        const auto &sampler = animation.samplers[channel.sampler];

        float maxKeyTime = 1.0f;
        NSArray<NSNumber *> *keyTimes =
            [self keyTimesFromAnimationSampler:sampler maxKeyTime:&maxKeyTime];
        maxDuration = MAX(maxDuration, maxKeyTime);

        const auto &outputAccessor = _data->json.accessors->at(sampler.output);
        bool normalized = false;
        const auto &outputData =
            _data->dataForAccessor(outputAccessor, &normalized);

        if (channel.target.path ==
            gltf2::GLTFAnimationChannelTarget::Path::WEIGHTS) {
          // Weights animation
          NSArray<NSNumber *> *numbers = NSArrayFromPackedFloatData(outputData);

          const auto &mesh = _data->json.meshes->at(*node.mesh);

          for (NSInteger i = 0; i < mesh.primitives.size(); i++) {
            const auto &primitive = mesh.primitives[i];

            SCNNode *geometryNode;
            if (mesh.primitives.size() > 1) {
              geometryNode = scnNode.childNodes[i];
            } else {
              geometryNode = scnNode;
            }

            if (!primitive.targets.has_value() || geometryNode.morpher == nil)
              continue;

            NSInteger targetsCount = primitive.targets->size();
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
                                             geometryNode.name, t];
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
          if (outputAccessor.componentType !=
                  gltf2::GLTFAccessor::ComponentType::FLOAT &&
              !normalized)
            continue;
          // only supports vec types
          if (outputAccessor.type != gltf2::GLTFAccessor::Type::VEC2 &&
              outputAccessor.type != gltf2::GLTFAccessor::Type::VEC3 &&
              outputAccessor.type != gltf2::GLTFAccessor::Type::VEC4)
            continue;

          CAAnimationCalculationMode calculationMode =
              CAAnimationCalculationModeFromGLTFAnimationSamplerInterpolation(
                  sampler.interpolationValue());
          BOOL isCubisSpline = calculationMode == kCAAnimationCubic;

          NSArray<NSValue *> *values;
          NSString *keyPath;
          if (channel.target.path ==
              gltf2::GLTFAnimationChannelTarget::Path::TRANSLATION) {
            values = SCNVec3ArrayFromPackedFloatDataWithAccessor(
                outputData, outputAccessor, isCubisSpline);
            keyPath = [NSString stringWithFormat:@"/%@.position", scnNode.name];
          } else if (channel.target.path ==
                     gltf2::GLTFAnimationChannelTarget::Path::ROTATION) {
            values = SCNVec4ArrayFromPackedFloatDataWithAccessor(
                outputData, outputAccessor, isCubisSpline);
            keyPath =
                [NSString stringWithFormat:@"/%@.orientation", scnNode.name];
          } else if (channel.target.path ==
                     gltf2::GLTFAnimationChannelTarget::Path::SCALE) {
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

  // scenes
  NSMutableArray<SCNScene *> *scnScenes = [NSMutableArray array];
  if (_data->json.scenes.has_value()) {
    for (const auto &scene : *_data->json.scenes) {
      SCNScene *scnScene = [SCNScene scene];
      if (scene.nodes.has_value()) {
        for (auto nodeIndex : *scene.nodes) {
          SCNNode *node = scnNodes[nodeIndex];
          [scnScene.rootNode addChildNode:node];
        }
      }
      [scnScenes addObject:scnScene];
    }
  }
  self.scenes = [scnScenes copy];
}

#pragma mark SCNMaterial

- (nullable NSArray<SCNMaterial *> *)loadSCNMaterials {
  if (!_data->json.materials)
    return nil;
  NSMutableArray<SCNMaterial *> *scnMaterials =
      [NSMutableArray arrayWithCapacity:_data->json.materials->size()];

  for (auto &material : _data->json.materials.value()) {
    SCNMaterial *scnMaterial = [SCNMaterial material];
    //    scnMaterial.name = material.name;
    scnMaterial.locksAmbientWithDiffuse = YES;
    scnMaterial.lightingModelName = material.pbrMetallicRoughness.has_value()
                                        ? SCNLightingModelPhysicallyBased
                                        : SCNLightingModelBlinn;

    NSMutableString *surfaceShaderModifier = [NSMutableString string];

    auto pbrMetallicRoughness = material.pbrMetallicRoughness.value_or(
        gltf2::GLTFMaterialPBRMetallicRoughness());

    if (pbrMetallicRoughness.baseColorTexture.has_value()) {
      // set contents to texture
      [self applyTextureInfo:*pbrMetallicRoughness.baseColorTexture
               withIntensity:1.0f
                  toProperty:scnMaterial.diffuse];

      if (pbrMetallicRoughness.baseColorFactor.has_value()) {
        auto factor = *pbrMetallicRoughness.baseColorFactor;
        if (factor[3] < 1.0f) {
          [surfaceShaderModifier
              appendString:@"#pragma transparent\n#pragma body\n"];
        }
        [surfaceShaderModifier
            appendFormat:@"_surface.diffuse *= float4(%ff, %ff, %ff, %ff);\n",
                         factor[0], factor[1], factor[2], factor[3]];
      }
    } else {
      auto value = pbrMetallicRoughness.baseColorFactorValue();
      applyColorContentsToProperty(value[0], value[1], value[2], value[3],
                                   scnMaterial.diffuse);
    }

    // metallicRoughnessTexture
    if (pbrMetallicRoughness.metallicRoughnessTexture.has_value()) {
      [self applyTextureInfo:*pbrMetallicRoughness.metallicRoughnessTexture
               withIntensity:pbrMetallicRoughness.metallicFactorValue()
                  toProperty:scnMaterial.metalness];
      scnMaterial.metalness.textureComponents = SCNColorMaskBlue;

      [self applyTextureInfo:*pbrMetallicRoughness.metallicRoughnessTexture
               withIntensity:pbrMetallicRoughness.roughnessFactorValue()
                  toProperty:scnMaterial.roughness];
      scnMaterial.roughness.textureComponents = SCNColorMaskGreen;
    } else {
      scnMaterial.metalness.contents =
          @(pbrMetallicRoughness.metallicFactorValue());
      scnMaterial.roughness.contents =
          @(pbrMetallicRoughness.roughnessFactorValue());
    }

    if (material.normalTexture.has_value()) {
      [self applyTextureInfo:*material.normalTexture
               withIntensity:material.normalTexture->scaleValue()
                  toProperty:scnMaterial.normal];
    }

    if (material.occlusionTexture.has_value()) {
      [self applyTextureInfo:*material.occlusionTexture
               withIntensity:material.occlusionTexture->strengthValue()
                  toProperty:scnMaterial.ambientOcclusion];
      scnMaterial.ambientOcclusion.textureComponents = SCNColorMaskRed;
    }

    if (material.emissiveTexture.has_value()) {
      [self applyTextureInfo:*material.emissiveTexture
               withIntensity:1.0f
                  toProperty:scnMaterial.emission];
    } else {
      auto value = material.emissiveFactorValue();
      applyColorContentsToProperty(value[0], value[1], value[2], 1.0,
                                   scnMaterial.emission);
    }

    if (material.alphaModeValue() == gltf2::GLTFMaterial::AlphaMode::OPAQUE) {
      scnMaterial.blendMode = SCNBlendModeReplace;
      [surfaceShaderModifier appendString:@"_surface.diffuse.a = 1.0;"];
    } else if (material.alphaModeValue() ==
               gltf2::GLTFMaterial::AlphaMode::MASK) {
      scnMaterial.blendMode = SCNBlendModeReplace;
      [surfaceShaderModifier
          appendFormat:
              @"_surface.diffuse.a = _surface.diffuse.a < %f ? 0.0 : 1.0;",
              material.alphaCutoffValue()];
    } else if (material.alphaModeValue() ==
               gltf2::GLTFMaterial::AlphaMode::BLEND) {
      scnMaterial.blendMode = SCNBlendModeAlpha;
      scnMaterial.transparencyMode = SCNTransparencyModeDualLayer;
    }

    scnMaterial.doubleSided = material.isDoubleSided();

    scnMaterial.shaderModifiers = @{
      SCNShaderModifierEntryPointSurface : surfaceShaderModifier,
    };

    [scnMaterials addObject:scnMaterial];
  }

  return [scnMaterials copy];
}

static void applyColorContentsToProperty(float r, float g, float b, float a,
                                         SCNMaterialProperty *property) {
  CGColorSpaceRef colorSpace =
      CGColorSpaceCreateWithName(kCGColorSpaceLinearSRGB);
  CGFloat components[] = {r, g, b, a};
  CGColorRef color = CGColorCreate(colorSpace, components);
  property.contents = (__bridge id)(color);
  CGColorRelease(color);
  CGColorSpaceRelease(colorSpace);
}

- (void)applyTextureInfo:(const gltf2::GLTFTextureInfo &)textureInfo
           withIntensity:(CGFloat)intensity
              toProperty:(SCNMaterialProperty *)property {
  auto &texture = _data->json.textures->at(textureInfo.index);
  [self applyTexture:texture toProperty:property];
  property.mappingChannel = textureInfo.texCoordValue();
  property.intensity = intensity;
}

- (CGImageRef)createCGImageFromData:(NSData *)data {
  CGImageSourceRef source =
      CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
  CGImageRef imageRef = CGImageSourceCreateImageAtIndex(source, 0, NULL);
  CFRelease(source);
  return imageRef;
}

- (CGImageRef)cgImageForImage:(const gltf2::GLTFImage &)image {
  gltf2::Data data;
  if (image.uri.has_value()) {
    data = _data->dataOfUri(*image.uri);
  } else {
    assert(image.bufferView.has_value());
    data = _data->dataForBufferView(*image.bufferView);
  }
  return [self createCGImageFromData:[NSData dataWithBytes:data.data()
                                                    length:data.size()]];
}

- (void)applyTexture:(const gltf2::GLTFTexture &)texture
          toProperty:(SCNMaterialProperty *)property {
  property.wrapS = SCNWrapModeRepeat;
  property.wrapT = SCNWrapModeRepeat;
  property.magnificationFilter = SCNFilterModeNone;
  property.minificationFilter = SCNFilterModeNone;
  property.mipFilter = SCNFilterModeNone;

  if (texture.source.has_value()) {
    auto &image = _data->json.images->at(*texture.source);
    property.contents = (__bridge id)[self cgImageForImage:image];
  }

  if (texture.sampler.has_value()) {
    auto &sampler = _data->json.samplers->at(*texture.sampler);
    [self applyTextureSampler:sampler toProperty:property];
  }
}

- (void)applyTextureSampler:(const gltf2::GLTFSampler &)sampler
                 toProperty:(SCNMaterialProperty *)property {
  if (sampler.magFilter.has_value()) {
    switch (*sampler.magFilter) {
    case gltf2::GLTFSampler::MagFilter::NEAREST:
      property.magnificationFilter = SCNFilterModeNearest;
      break;
    case gltf2::GLTFSampler::MagFilter::LINEAR:
      property.magnificationFilter = SCNFilterModeLinear;
      break;
    default:
      break;
    }
  }
  if (sampler.minFilter.has_value()) {
    switch (*sampler.minFilter) {
    case gltf2::GLTFSampler::MinFilter::LINEAR:
      property.minificationFilter = SCNFilterModeLinear;
      break;
    case gltf2::GLTFSampler::MinFilter::LINEAR_MIPMAP_NEAREST:
      property.minificationFilter = SCNFilterModeLinear;
      property.mipFilter = SCNFilterModeNearest;
      break;
    case gltf2::GLTFSampler::MinFilter::LINEAR_MIPMAP_LINEAR:
      property.minificationFilter = SCNFilterModeLinear;
      property.mipFilter = SCNFilterModeLinear;
      break;
    case gltf2::GLTFSampler::MinFilter::NEAREST:
      property.minificationFilter = SCNFilterModeNearest;
      break;
    case gltf2::GLTFSampler::MinFilter::NEAREST_MIPMAP_NEAREST:
      property.minificationFilter = SCNFilterModeNearest;
      property.mipFilter = SCNFilterModeNearest;
      break;
    case gltf2::GLTFSampler::MinFilter::NEAREST_MIPMAP_LINEAR:
      property.minificationFilter = SCNFilterModeNearest;
      property.mipFilter = SCNFilterModeLinear;
      break;
    default:
      break;
    }
  }
  property.wrapS = SCNWrapModeFromGLTFSamplerWrapMode(sampler.wrapSValue());
  property.wrapT = SCNWrapModeFromGLTFSamplerWrapMode(sampler.wrapTValue());
}

static SCNWrapMode
SCNWrapModeFromGLTFSamplerWrapMode(gltf2::GLTFSampler::WrapMode mode) {
  switch (mode) {
  case gltf2::GLTFSampler::WrapMode::CLAMP_TO_EDGE:
    return SCNWrapModeClamp;
  case gltf2::GLTFSampler::WrapMode::MIRRORED_REPEAT:
    return SCNWrapModeMirror;
  case gltf2::GLTFSampler::WrapMode::REPEAT:
    return SCNWrapModeRepeat;
  }
}

#pragma mark SCNCamera

- (nullable NSArray<SCNCamera *> *)loadSCNCameras {
  if (!_data->json.cameras.has_value())
    return nil;

  NSMutableArray<SCNCamera *> *scnCameras =
      [NSMutableArray arrayWithCapacity:_data->json.cameras->size()];
  for (const auto &camera : *_data->json.cameras) {
    SCNCamera *scnCamera = [SCNCamera camera];
    //     scnCamera.name = camera.name;

    if (camera.orthographic.has_value()) {
      [self applyOrthographicCamera:*camera.orthographic toSCNCamera:scnCamera];
    } else if (camera.perspective.has_value()) {
      [self applyPerspectiveCamera:*camera.perspective toSCNCamera:scnCamera];
    }
    [scnCameras addObject:scnCamera];
  }
  return [scnCameras copy];
}

- (void)applyOrthographicCamera:
            (const gltf2::GLTFCameraOrthographic &)orthographic
                    toSCNCamera:(SCNCamera *)scnCamera {
  scnCamera.usesOrthographicProjection = YES;
  scnCamera.orthographicScale = MAX(orthographic.xmag, orthographic.ymag);
  scnCamera.zFar = orthographic.zfar;
  scnCamera.zNear = orthographic.znear;
}

- (void)applyPerspectiveCamera:(const gltf2::GLTFCameraPerspective &)perspective
                   toSCNCamera:(SCNCamera *)scnCamera {
  scnCamera.usesOrthographicProjection = NO;
  if (perspective.zfar.has_value()) {
    scnCamera.zFar = *perspective.zfar;
  }
  scnCamera.zNear = perspective.znear;
  scnCamera.fieldOfView = perspective.yfov * (180.0 / M_PI); // radian to degree
  if (perspective.aspectRatio.has_value()) {
    // w / h
    float aspectRatio = *perspective.aspectRatio;
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
        //      perspective effect.
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

- (NSArray<SCNGeometrySource *> *)scnGeometrySourcesFromMeshPrimitiveSources:
    (const gltf2::MeshPrimitiveSources &)sources {
  NSMutableArray<SCNGeometrySource *> *geometrySources = [NSMutableArray array];
  if (sources.position.has_value()) {
    [geometrySources
        addObject:
            [self
                scnGeometrySourceFromMeshPrimitiveSource:*sources.position
                                                semantic:
                                                    SCNGeometrySourceSemanticVertex]];
  }
  if (sources.normal.has_value()) {
    [geometrySources
        addObject:
            [self
                scnGeometrySourceFromMeshPrimitiveSource:*sources.normal
                                                semantic:
                                                    SCNGeometrySourceSemanticNormal]];
  }
  if (sources.tangent.has_value()) {
    [geometrySources
        addObject:
            [self
                scnGeometrySourceFromMeshPrimitiveSource:*sources.tangent
                                                semantic:
                                                    SCNGeometrySourceSemanticTangent]];
  }
  for (const auto &source : sources.texcoords) {
    [geometrySources
        addObject:
            [self
                scnGeometrySourceFromMeshPrimitiveSource:source
                                                semantic:
                                                    SCNGeometrySourceSemanticTexcoord]];
  }
  for (const auto &source : sources.colors) {
    [geometrySources
        addObject:
            [self
                scnGeometrySourceFromMeshPrimitiveSource:source
                                                semantic:
                                                    SCNGeometrySourceSemanticColor]];
  }
  return [geometrySources copy];
}

- (SCNGeometry *)scnGeometryFromMeshPrimitive:
    (const gltf2::MeshPrimitive &)meshPrimitive {
  NSArray<SCNGeometrySource *> *geometrySources =
      [self scnGeometrySourcesFromMeshPrimitiveSources:meshPrimitive.sources];
  NSArray<SCNGeometryElement *> *geometryElements;
  if (meshPrimitive.element.has_value()) {
    geometryElements = @[ [self
        scnGeometryElementFromMeshPrimitiveElement:*meshPrimitive.element] ];
  }

  return [SCNGeometry geometryWithSources:[geometrySources copy]
                                 elements:geometryElements];
}

- (SCNGeometrySource *)
    scnGeometrySourceFromMeshPrimitiveSource:
        (const gltf2::MeshPrimitiveSource &)source
                                    semantic:
                                        (SCNGeometrySourceSemantic)semantic {
  auto bytesPerComponent =
      gltf2::GLTFAccessor::sizeOfComponentType(source.componentType);
  NSData *data = [NSData dataWithBytes:source.data.data()
                                length:source.data.size()];
  return [SCNGeometrySource
      geometrySourceWithData:data
                    semantic:semantic
                 vectorCount:source.vectorCount
             floatComponents:source.componentType ==
                             gltf2::GLTFAccessor::ComponentType::FLOAT
         componentsPerVector:source.componentsPerVector
           bytesPerComponent:bytesPerComponent
                  dataOffset:0
                  dataStride:bytesPerComponent * source.componentsPerVector];
}

- (SCNGeometryElement *)scnGeometryElementFromMeshPrimitiveElement:
    (const gltf2::MeshPrimitiveElement &)element {
  SCNGeometryPrimitiveType primitiveType = SCNGeometryPrimitiveTypeTriangles;
  NSUInteger sizeOfComponent =
      gltf2::GLTFAccessor::sizeOfComponentType(element.componentType);
  NSUInteger primitiveCount = element.primitiveCount;
  NSData *data = convertDataToSCNGeometryPrimitiveType(
      element.data, sizeOfComponent, &primitiveCount, element.primitiveMode,
      &primitiveType);
  return [SCNGeometryElement geometryElementWithData:data
                                       primitiveType:primitiveType
                                      primitiveCount:primitiveCount
                                       bytesPerIndex:sizeOfComponent];
}

// convert indices data with SceneKit compatible primitive type
static NSData *convertDataToSCNGeometryPrimitiveType(
    const gltf2::Data &bufferData, NSUInteger sizeOfComponent,
    NSUInteger *primitiveCount, gltf2::GLTFMeshPrimitive::Mode mode,
    SCNGeometryPrimitiveType *primitiveType) {
  switch (mode) {
  case gltf2::GLTFMeshPrimitive::Mode::POINTS:
    *primitiveType = SCNGeometryPrimitiveTypePoint;
    return [NSData dataWithBytes:bufferData.data() length:bufferData.size()];
  case gltf2::GLTFMeshPrimitive::Mode::LINES:
    *primitiveType = SCNGeometryPrimitiveTypeLine;
    return [NSData dataWithBytes:bufferData.data() length:bufferData.size()];
  case gltf2::GLTFMeshPrimitive::Mode::LINE_LOOP: {
    *primitiveType = SCNGeometryPrimitiveTypeLine;
    // convert to line
    NSUInteger indicesCount = bufferData.size() / sizeOfComponent;
    NSMutableData *data = [NSMutableData dataWithLength:bufferData.size() * 2];
    uint8_t *dstBase = (uint8_t *)data.mutableBytes;
    uint8_t *srcBase = (uint8_t *)bufferData.data();
    for (NSUInteger i = 0; i < indicesCount; i++) {
      std::memcpy(dstBase + i * sizeOfComponent * 2,
                  srcBase + i * sizeOfComponent, sizeOfComponent);
      std::memcpy(dstBase + i * sizeOfComponent * 2 + sizeOfComponent,
                  srcBase + ((i + 1) % indicesCount) * sizeOfComponent,
                  sizeOfComponent);
    }
    *primitiveCount = indicesCount;
    return [data copy];
  }
  case gltf2::GLTFMeshPrimitive::Mode::LINE_STRIP: {
    *primitiveType = SCNGeometryPrimitiveTypeLine;
    // convert to line
    NSUInteger indicesCount = bufferData.size() / sizeOfComponent;
    NSMutableData *data = [NSMutableData
        dataWithLength:bufferData.size() * 2 - sizeOfComponent * 2];
    uint8_t *dstBase = (uint8_t *)data.mutableBytes;
    uint8_t *srcBase = (uint8_t *)bufferData.data();
    for (NSUInteger i = 0; i < indicesCount - 1; i++) {
      std::memcpy(dstBase + i * sizeOfComponent * 2,
                  srcBase + i * sizeOfComponent, sizeOfComponent);
      std::memcpy(dstBase + i * sizeOfComponent * 2 + sizeOfComponent,
                  srcBase + (i + 1) * sizeOfComponent, sizeOfComponent);
    }
    *primitiveCount = indicesCount - 1;
    return [data copy];
  }
  case gltf2::GLTFMeshPrimitive::Mode::TRIANGLES:
    *primitiveType = SCNGeometryPrimitiveTypeTriangles;
    return [NSData dataWithBytes:bufferData.data() length:bufferData.size()];
  case gltf2::GLTFMeshPrimitive::Mode::TRIANGLE_STRIP:
    *primitiveType = SCNGeometryPrimitiveTypeTriangleStrip;
    return [NSData dataWithBytes:bufferData.data() length:bufferData.size()];
  case gltf2::GLTFMeshPrimitive::Mode::TRIANGLE_FAN: {
    *primitiveType = SCNGeometryPrimitiveTypeTriangles;
    // convert to triangles
    NSUInteger indicesCount = bufferData.size() / sizeOfComponent;
    NSMutableData *data =
        [NSMutableData dataWithLength:(indicesCount - 2) * 3 * sizeOfComponent];
    uint8_t *dstBase = (uint8_t *)data.mutableBytes;
    uint8_t *srcBase = (uint8_t *)bufferData.data();
    for (NSUInteger i = 0; i < indicesCount - 2; i++) {
      std::memcpy(dstBase + i * 3 * sizeOfComponent, srcBase, sizeOfComponent);
      std::memcpy(dstBase + (i * 3 * sizeOfComponent + sizeOfComponent),
                  srcBase + (i + 1) * sizeOfComponent, sizeOfComponent);
      std::memcpy(dstBase + (i * 3 * sizeOfComponent + 2 * sizeOfComponent),
                  srcBase + (i + 2) * sizeOfComponent, sizeOfComponent);
    }
    *primitiveCount = indicesCount - 2;
    return [data copy];
  }
  default:
    return [NSData dataWithBytes:bufferData.data() length:bufferData.size()];
  }
}

- (nullable SCNMorpher *)
    scnMorpherFromMeshPrimitive:(const gltf2::GLTFMeshPrimitive &)primitive
                   withElements:(NSArray<SCNGeometryElement *> *)elements
                        weights:
                            (const std::optional<std::vector<float>> &)weights {
  if (!primitive.targets.has_value())
    return nil;

  SCNMorpher *morpher = [SCNMorpher new];

  NSMutableArray<SCNGeometry *> *morphTargets =
      [NSMutableArray arrayWithCapacity:primitive.targets->size()];
  for (const auto &target : *primitive.targets) {
    NSArray<SCNGeometrySource *> *sources =
        [self scnGeometrySourcesFromMeshPrimitiveSources:
                  _data->meshPrimitiveSourcesFromTarget(target)];
    SCNGeometry *morphTarget = [SCNGeometry geometryWithSources:sources
                                                       elements:elements];
    [morphTargets addObject:morphTarget];
  }

  morpher.targets = [morphTargets copy];
  morpher.unifiesNormals = YES;
  morpher.calculationMode = SCNMorpherCalculationModeAdditive;
  if (weights.has_value()) {
    NSMutableArray<NSNumber *> *values =
        [NSMutableArray arrayWithCapacity:weights->size()];
    for (auto weight : *weights) {
      [values addObject:[NSNumber numberWithFloat:weight]];
    }
    morpher.weights = [values copy];
  }
  return morpher;
}

#pragma mark animation

CAAnimationCalculationMode
CAAnimationCalculationModeFromGLTFAnimationSamplerInterpolation(
    gltf2::GLTFAnimationSampler::Interpolation interpolation) {
  if (interpolation == gltf2::GLTFAnimationSampler::Interpolation::LINEAR) {
    return kCAAnimationLinear;
  } else if (interpolation ==
             gltf2::GLTFAnimationSampler::Interpolation::STEP) {
    return kCAAnimationDiscrete;
  } else if (interpolation ==
             gltf2::GLTFAnimationSampler::Interpolation::CUBICSPLINE) {
    // TODO: tangent
    return kCAAnimationCubic;
  }
  return kCAAnimationLinear;
}

- (NSArray<NSNumber *> *)keyTimesFromAnimationSampler:
                             (const gltf2::GLTFAnimationSampler &)sampler
                                           maxKeyTime:(float *)maxKeyTime {
  const auto &inputAccessor = _data->json.accessors->at(sampler.input);
  // input must be scalar type with float
  assert(inputAccessor.type == gltf2::GLTFAccessor::Type::SCALAR &&
         inputAccessor.componentType ==
             gltf2::GLTFAccessor::ComponentType::FLOAT);
  const auto inputData = _data->dataForAccessor(inputAccessor, nil);
  NSArray<NSNumber *> *array = NSArrayFromPackedFloatData(inputData);
  float max = inputAccessor.max.has_value() ? inputAccessor.max.value()[0]
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

NSArray<NSNumber *> *NSArrayFromPackedFloatData(const gltf2::Data &data) {
  NSUInteger count = data.size() / sizeof(float);
  NSMutableArray<NSNumber *> *array = [NSMutableArray arrayWithCapacity:count];
  const float *bytes = (const float *)data.data();
  for (NSUInteger i = 0; i < count; i++) {
    [array addObject:@(bytes[i])];
  }
  return [array copy];
}

NSArray<NSValue *> *SCNMat4ArrayFromPackedFloatData(const gltf2::Data &data) {
  NSUInteger count = data.size() / sizeof(float) / 16;
  NSMutableArray<NSValue *> *arr = [NSMutableArray arrayWithCapacity:count];
  const float *base = (float *)data.data();
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

NSArray<NSValue *> *
SCNVec4ArrayFromPackedFloatDataWithAccessor(const gltf2::Data &data,
                                            const gltf2::GLTFAccessor &accessor,
                                            BOOL isCubisSpline) {
  NSInteger count = isCubisSpline ? accessor.count / 3 : accessor.count;
  NSMutableArray<NSValue *> *values = [NSMutableArray arrayWithCapacity:count];
  float *bytes = (float *)data.data();
  for (int i = 0; i < count; i++) {
    SCNVector4 vec = SCNVector4Zero;
    if (accessor.type == gltf2::GLTFAccessor::Type::VEC2) {
      if (isCubisSpline)
        bytes += 2; // skip in-tangent
      vec.x = bytes[0];
      vec.y = bytes[1];
      bytes += 2;
      if (isCubisSpline)
        bytes += 2; // skip out-tangent
    } else if (accessor.type == gltf2::GLTFAccessor::Type::VEC3) {
      if (isCubisSpline)
        bytes += 3; // skip in-tangent
      vec.x = bytes[0];
      vec.y = bytes[1];
      vec.z = bytes[2];
      bytes += 3;
      if (isCubisSpline)
        bytes += 3; // skip out-tangent
    } else if (accessor.type == gltf2::GLTFAccessor::Type::VEC4) {
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

NSArray<NSValue *> *
SCNVec3ArrayFromPackedFloatDataWithAccessor(const gltf2::Data &data,
                                            const gltf2::GLTFAccessor &accessor,
                                            BOOL isCubisSpline) {
  NSInteger count = isCubisSpline ? accessor.count / 3 : accessor.count;
  NSMutableArray<NSValue *> *values = [NSMutableArray arrayWithCapacity:count];
  float *bytes = (float *)data.data();
  for (int i = 0; i < count; i++) {
    SCNVector3 vec = SCNVector3Zero;
    if (accessor.type == gltf2::GLTFAccessor::Type::VEC2) {
      if (isCubisSpline)
        bytes += 2; // skip in-tangent
      vec.x = bytes[0];
      vec.y = bytes[1];
      bytes += 2;
      if (isCubisSpline)
        bytes += 2; // skip out-tangent
    } else if (accessor.type == gltf2::GLTFAccessor::Type::VEC3) {
      if (isCubisSpline)
        bytes += 3; // skip in-tangent
      vec.x = bytes[0];
      vec.y = bytes[1];
      vec.z = bytes[2];
      bytes += 3;
      if (isCubisSpline)
        bytes += 3; // skip out-tangent
    } else if (accessor.type == gltf2::GLTFAccessor::Type::VEC4) {
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

@end
