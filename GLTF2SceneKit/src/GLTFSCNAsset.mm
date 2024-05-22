#import "GLTFSCNAsset.h"
#include "GLTF2.h"
#include "GLTFError.h"
#include <memory>

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

+ (instancetype)assetWithFile:(NSString *)path
                        error:(NSError *_Nullable *_Nullable)error {
  GLTFSCNAsset *asset = [[GLTFSCNAsset alloc] init];
  if (self) {
    if (![asset loadFile:path error:error]) {
      return nil;
    }
  }
  return asset;
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

  return NO;
}

//- (instancetype)initWithGLTFData:(GLTFData *)data {
//  self = [super init];
//  if (self) {
//    _data = data;
//    _scenes = [NSArray array];
//    _animationPlayers = [NSArray array];
//  }
//  return self;
//}
//
//+ (instancetype)assetWithGLTFData:(GLTFData *)data {
//  return [[GLTFSCNAsset alloc] initWithGLTFData:data];
//}
//
// #pragma mark SCNScene
//
//- (nullable SCNScene *)defaultScene {
//  if (_data->json.scene) {
//    return self.scenes[_data->json.scene.integerValue];
//  } else {
//    return self.scenes.firstObject;
//  }
//}
//
//- (void)loadScenes {
//  // load materials
//  NSArray<SCNMaterial *> *scnMaterials = [self loadSCNMaterials];
//
//  // load cameras
//  NSArray<SCNCamera *> *scnCameras = [self loadSCNCameras];
//
//  // load nodes
//  NSMutableArray<SCNNode *> *scnNodes;
//  NSMutableArray<SCNNode *> *cameraNodes = [NSMutableArray array];
//
//  NSMutableDictionary<NSNumber *, NSArray<MeshPrimitive *> *>
//      *meshPrimitiveCache = [NSMutableDictionary dictionary];
//
//  if (_data->json.nodes) {
//    scnNodes = [NSMutableArray arrayWithCapacity:_data->json.nodes.count];
//
//    for (GLTFNode *node in _data->json.nodes) {
//      SCNNode *scnNode = [SCNNode node];
//      scnNode.name = [[NSUUID UUID] UUIDString];
//      scnNode.simdTransform = node.simdTransform;
//
//      if (node.camera) {
//        scnNode.camera = scnCameras[node.camera.integerValue];
//        [cameraNodes addObject:scnNode];
//      }
//
//      if (node.mesh) {
//        GLTFMesh *mesh = _data->json.meshes[node.mesh.integerValue];
//
//        NSMutableArray<MeshPrimitive *> *meshPrimitives =
//            [NSMutableArray array];
//        for (GLTFMeshPrimitive *primitive in mesh.primitives) {
//          MeshPrimitive *meshPrimitive = [_data meshPrimitive:primitive];
//          [meshPrimitives addObject:meshPrimitive];
//
//          SCNGeometry *geometry =
//              [self scnGeometryFromMeshPrimitive:meshPrimitive];
//          if (primitive.modeValue == GLTFMeshPrimitiveModePoints &&
//              geometry.geometryElementCount > 0) {
//            geometry.geometryElements.firstObject
//                .minimumPointScreenSpaceRadius = 1.0;
//            geometry.geometryElements.firstObject
//                .maximumPointScreenSpaceRadius = 1.0;
//          }
//
//          if (primitive.material) {
//            SCNMaterial *scnMaterial =
//                scnMaterials[primitive.material.integerValue];
//            geometry.materials = @[ scnMaterial ];
//          }
//
//          SCNMorpher *morpher =
//              [self scnMorpherFromMeshPrimitive:primitive
//                                   withElements:geometry.geometryElements
//                                        weights:mesh.weights];
//
//          if (mesh.primitives.count > 1) {
//            SCNNode *geometryNode = [SCNNode nodeWithGeometry:geometry];
//            geometryNode.name = [[NSUUID UUID] UUIDString];
//            geometryNode.morpher = morpher;
//            [scnNode addChildNode:geometryNode];
//          } else {
//            scnNode.geometry = geometry;
//            scnNode.morpher = morpher;
//          }
//        }
//        meshPrimitiveCache[node.mesh] = [meshPrimitives copy];
//      }
//
//      [scnNodes addObject:scnNode];
//    }
//
//    for (int i = 0; i < _data->json.nodes.count; i++) {
//      GLTFNode *node = _data->json.nodes[i];
//      SCNNode *scnNode = scnNodes[i];
//
//      if (node.children) {
//        for (NSNumber *childIndex in node.children) {
//          SCNNode *childNode = scnNodes[childIndex.integerValue];
//          [scnNode addChildNode:childNode];
//        }
//      }
//
//      if (node.skin) {
//        GLTFSkin *skin = _data->json.skins[node.skin.integerValue];
//
//        NSMutableArray<SCNNode *> *bones =
//            [NSMutableArray arrayWithCapacity:skin.joints.count];
//        for (NSNumber *joint in skin.joints) {
//          SCNNode *bone = scnNodes[joint.integerValue];
//          [bones addObject:bone];
//        }
//
//        NSArray<NSValue *> *boneInverseBindTransforms;
//        if (skin.inverseBindMatrices) {
//          GLTFAccessor *accessor =
//              _data->json.accessors[skin.inverseBindMatrices.integerValue];
//          NSData *data = [_data dataForAccessor:accessor normalized:nil];
//          // inverseBindMatrices must be mat4 type with float
//          assert([accessor.type isEqualToString:GLTFAccessorTypeMat4] &&
//                 accessor.componentType == GLTFAccessorComponentTypeFloat);
//          boneInverseBindTransforms = SCNMat4ArrayFromPackedFloatData(data);
//        } else {
//          NSMutableArray<NSValue *> *arr =
//              [NSMutableArray arrayWithCapacity:skin.joints.count];
//          for (int j = 0; j < skin.joints.count; j++) {
//            [arr addObject:[NSValue valueWithSCNMatrix4:SCNMatrix4Identity]];
//          }
//          boneInverseBindTransforms = [arr copy];
//        }
//
//        GLTFMesh *mesh = _data->json.meshes[node.mesh.integerValue];
//        NSArray<MeshPrimitive *> *meshPrimitives =
//            meshPrimitiveCache[node.mesh];
//        for (int j = 0; j < mesh.primitives.count; j++) {
//          GLTFMeshPrimitive *primitive = mesh.primitives[j];
//          MeshPrimitive *meshPrimitive = meshPrimitives[j];
//
//          SCNNode *geometryNode;
//          if (mesh.primitives.count > 1) {
//            geometryNode = scnNode.childNodes[j];
//          } else {
//            geometryNode = scnNode;
//          }
//          SCNGeometry *geometry = geometryNode.geometry;
//
//          SCNGeometrySource *boneWeights;
//          if (meshPrimitive.sources.weights &&
//              meshPrimitive.sources.weights.count > 0) {
//            boneWeights = [self
//                scnGeometrySourceFromMeshPrimitiveSource:meshPrimitive.sources
//                                                             .weights
//                                                             .firstObject
//                                                semantic:
//                                                    SCNGeometrySourceSemanticBoneWeights];
//          }
//          SCNGeometrySource *boneIndices;
//          if (meshPrimitive.sources.joints &&
//              meshPrimitive.sources.joints.count > 0) {
//            boneIndices = [self
//                scnGeometrySourceFromMeshPrimitiveSource:meshPrimitive.sources
//                                                             .joints.firstObject
//                                                semantic:
//                                                    SCNGeometrySourceSemanticBoneIndices];
//          }
//          if (!boneWeights || !boneIndices)
//            continue;
//
//          SCNSkinner *skinner =
//              [SCNSkinner skinnerWithBaseGeometry:geometry
//                                            bones:[bones copy]
//                        boneInverseBindTransforms:boneInverseBindTransforms
//                                      boneWeights:boneWeights
//                                      boneIndices:boneIndices];
//          if (skin.skeleton) {
//            skinner.skeleton = scnNodes[skin.skeleton.integerValue];
//          }
//          geometryNode.skinner = skinner;
//        }
//      }
//    }
//  }
//  _cameraNodes = [cameraNodes copy];
//
//  // animations
//  NSMutableArray<SCNAnimationPlayer *> *animationPlayers =
//      [NSMutableArray array];
//
//  if (_data->json.animations) {
//    for (GLTFAnimation *animation in _data->json.animations) {
//      NSMutableArray *channelAnimations = [NSMutableArray array];
//      float maxDuration = 1.0f;
//
//      for (GLTFAnimationChannel *channel in animation.channels) {
//        if (channel.target.node == nil)
//          continue;
//
//        GLTFNode *node = _data->json.nodes[channel.target.node.integerValue];
//        SCNNode *scnNode = scnNodes[channel.target.node.integerValue];
//
//        GLTFAnimationSampler *sampler = animation.samplers[channel.sampler];
//
//        float maxKeyTime = 1.0f;
//        NSArray<NSNumber *> *keyTimes =
//            [self keyTimesFromAnimationSampler:sampler
//            maxKeyTime:&maxKeyTime];
//        maxDuration = MAX(maxDuration, maxKeyTime);
//
//        GLTFAccessor *outputAccessor = _data->json.accessors[sampler.output];
//        BOOL normalized;
//        NSData *outputData = [_data dataForAccessor:outputAccessor
//                                             normalized:&normalized];
//
//        if (channel.target.isPathWeights) {
//          // Weights animation
//          NSArray<NSNumber *> *numbers =
//          NSArrayFromPackedFloatData(outputData);
//
//          GLTFMesh *mesh = _data->json.meshes[node.mesh.integerValue];
//
//          for (NSInteger i = 0; i < mesh.primitives.count; i++) {
//            GLTFMeshPrimitive *primitive = mesh.primitives[i];
//
//            SCNNode *geometryNode;
//            if (mesh.primitives.count > 1) {
//              geometryNode = scnNode.childNodes[i];
//            } else {
//              geometryNode = scnNode;
//            }
//
//            if (primitive.targets == nil || geometryNode.morpher == nil)
//              continue;
//
//            NSInteger targetsCount = primitive.targets.count;
//            NSInteger keyTimesCount = keyTimes.count;
//
//            NSMutableArray<CAKeyframeAnimation *> *weightAnimations =
//                [NSMutableArray arrayWithCapacity:targetsCount];
//            for (NSInteger t = 0; t < targetsCount; t++) {
//              NSMutableArray<NSNumber *> *values =
//                  [NSMutableArray arrayWithCapacity:keyTimesCount];
//              for (NSInteger k = 0; k < keyTimesCount; k++) {
//                [values addObject:numbers[k * targetsCount + t]];
//              }
//
//              CAKeyframeAnimation *weightAnimation =
//                  [CAKeyframeAnimation animation];
//              weightAnimation.keyPath =
//                  [NSString stringWithFormat:@"/%@.morpher.weights[%ld]",
//                                             geometryNode.name, t];
//              weightAnimation.keyTimes = keyTimes;
//              weightAnimation.values = values;
//              weightAnimation.repeatDuration = FLT_MAX;
//              weightAnimation.calculationMode = kCAAnimationLinear;
//              weightAnimation.duration = maxKeyTime;
//              [weightAnimations addObject:weightAnimation];
//            }
//
//            CAAnimationGroup *group = [CAAnimationGroup animation];
//            group.animations = weightAnimations;
//            group.duration = maxKeyTime;
//            [channelAnimations addObject:group];
//          }
//        } else {
//          // Translation, Rotation, Scale
//
//          // component type should be float
//          if (outputAccessor.componentType != GLTFAccessorComponentTypeFloat
//          &&
//              !normalized)
//            continue;
//          // only supports vec types
//          if ([outputAccessor.type isNotEqualTo:GLTFAccessorTypeVec2] &&
//              [outputAccessor.type isNotEqualTo:GLTFAccessorTypeVec3] &&
//              [outputAccessor.type isNotEqualTo:GLTFAccessorTypeVec4])
//            continue;
//
//          CAAnimationCalculationMode calculationMode =
//              CAAnimationCalculationModeFromGLTFAnimationSamplerInterpolation(
//                  sampler.interpolationValue);
//          BOOL isCubisSpline = calculationMode == kCAAnimationCubic;
//
//          NSArray<NSValue *> *values;
//          NSString *keyPath;
//          if (channel.target.isPathTranslation) {
//            values = SCNVec3ArrayFromPackedFloatDataWithAccessor(
//                outputData, outputAccessor, isCubisSpline);
//            keyPath = [NSString stringWithFormat:@"/%@.position",
//            scnNode.name];
//          } else if (channel.target.isPathRotation) {
//            values = SCNVec4ArrayFromPackedFloatDataWithAccessor(
//                outputData, outputAccessor, isCubisSpline);
//            keyPath =
//                [NSString stringWithFormat:@"/%@.orientation", scnNode.name];
//          } else if (channel.target.isPathScale) {
//            values = SCNVec3ArrayFromPackedFloatDataWithAccessor(
//                outputData, outputAccessor, isCubisSpline);
//            keyPath = [NSString stringWithFormat:@"/%@.scale", scnNode.name];
//          }
//
//          CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
//          animation.values = values;
//          animation.keyPath = keyPath;
//          animation.calculationMode = calculationMode;
//          animation.keyTimes = keyTimes;
//          animation.duration = maxKeyTime;
//          animation.repeatDuration = FLT_MAX;
//
//          [channelAnimations addObject:animation];
//        }
//      }
//
//      CAAnimationGroup *caGroup = [CAAnimationGroup animation];
//      caGroup.animations = channelAnimations;
//      caGroup.duration = maxDuration;
//      caGroup.repeatDuration = FLT_MAX;
//
//      SCNAnimationPlayer *scnAnimationPlayer = [SCNAnimationPlayer
//          animationPlayerWithAnimation:[SCNAnimation
//                                           animationWithCAAnimation:caGroup]];
//      [animationPlayers addObject:scnAnimationPlayer];
//    }
//  }
//  self.animationPlayers = [animationPlayers copy];
//
//  // scenes
//  NSMutableArray<SCNScene *> *scnScenes = [NSMutableArray array];
//  if (_data->json.scenes) {
//    for (GLTFScene *scene in _data->json.scenes) {
//      SCNScene *scnScene = [SCNScene scene];
//      for (NSNumber *nodeIndex in scene.nodes) {
//        SCNNode *node = scnNodes[nodeIndex.integerValue];
//        [scnScene.rootNode addChildNode:node];
//      }
//      [scnScenes addObject:scnScene];
//    }
//  }
//  self.scenes = [scnScenes copy];
//}
//
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

- (void)applyTexture:(const gltf2::GLTFTexture &)texture
          toProperty:(SCNMaterialProperty *)property {
  property.wrapS = SCNWrapModeRepeat;
  property.wrapT = SCNWrapModeRepeat;
  property.magnificationFilter = SCNFilterModeNone;
  property.minificationFilter = SCNFilterModeNone;
  property.mipFilter = SCNFilterModeNone;

  if (texture.source.has_value()) {
    auto &image = _data->json.images->at(*texture.source);
    // TODO:
    //    property.contents = (__bridge id)[_data cgImageForImage:image];
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

// #pragma mark SCNCamera
//
//- (nullable NSArray<SCNCamera *> *)loadSCNCameras {
//   if (!_data->json.cameras)
//     return nil;
//
//   NSMutableArray<SCNCamera *> *scnCameras =
//       [NSMutableArray arrayWithCapacity:_data->json.cameras.count];
//   for (GLTFCamera *camera in _data->json.cameras) {
//     SCNCamera *scnCamera = [SCNCamera camera];
//     scnCamera.name = camera.name;
//
//     if (camera.orthographic) {
//       [self applyOrthographicCamera:camera.orthographic
//       toSCNCamera:scnCamera];
//     } else if (camera.perspective) {
//       [self applyPerspectiveCamera:camera.perspective toSCNCamera:scnCamera];
//     }
//     [scnCameras addObject:scnCamera];
//   }
//   return [scnCameras copy];
// }
//
//- (void)applyOrthographicCamera:(GLTFCameraOrthographic *)orthographic
//                     toSCNCamera:(SCNCamera *)scnCamera {
//   scnCamera.usesOrthographicProjection = YES;
//   scnCamera.orthographicScale = MAX(orthographic.xmag, orthographic.ymag);
//   scnCamera.zFar = orthographic.zfar;
//   scnCamera.zNear = orthographic.znear;
// }
//
//- (void)applyPerspectiveCamera:(GLTFCameraPerspective *)perspective
//                    toSCNCamera:(SCNCamera *)scnCamera {
//   scnCamera.usesOrthographicProjection = NO;
//   if (perspective.zfar) {
//     scnCamera.zFar = perspective.zfar.floatValue;
//   }
//   scnCamera.zNear = perspective.znear;
//   scnCamera.fieldOfView = perspective.yfov * (180.0 / M_PI); // radian to
//   degree if (perspective.aspectRatio) {
//     // w / h
//     float aspectRatio = perspective.aspectRatio.floatValue;
//     float yFovRadians = scnCamera.fieldOfView * (M_PI / 180.0);
//
//     SCNMatrix4 projectionTransform = {
//         // m11: Scale along the X-axis. Calculated using the aspect ratio and
//         // the field of view.
//         //      A higher aspect ratio leads to more stretch along the X-axis.
//         .m11 = 1.0 / (aspectRatio * tan(yFovRadians * 0.5)),
//
//         // m22: Scale along the Y-axis. Directly dependent on the field of
//         view.
//         //      Adjusts the Y-axis to maintain proper image proportions.
//         .m22 = 1.0 / tan(yFovRadians * 0.5),
//
//         // m33: Configures the depth (Z-axis) scaling. Affects how depth is
//         // perceived,
//         //      ensuring objects farther away appear smaller and provide a
//         depth
//         //      cue.
//         .m33 = -(scnCamera.zFar + scnCamera.zNear) /
//                (scnCamera.zFar - scnCamera.zNear),
//
//         // m34: Enables perspective division, a key component for creating a
//         // perspective effect.
//         .m34 = -1.0,
//
//         // m43: Adjusts the translation along the Z-axis based on the near
//         and
//         // far clipping planes.
//         //      This term helps manage how different depths are rendered
//         within
//         //      the view frustum.
//         .m43 = -(2.0 * scnCamera.zFar * scnCamera.zNear) /
//                (scnCamera.zFar - scnCamera.zNear)};
//     scnCamera.projectionTransform = projectionTransform;
//   }
// }
//
// #pragma mark SCNGeometry
//
//- (NSArray<SCNGeometrySource *> *)scnGeometrySourcesFromMeshPrimitiveSources:
//     (MeshPrimitiveSources *)sources {
//   NSMutableArray<SCNGeometrySource *> *geometrySources = [NSMutableArray
//   array]; if (sources.position) {
//     [geometrySources
//         addObject:
//             [self
//                 scnGeometrySourceFromMeshPrimitiveSource:sources.position
//                                                 semantic:
//                                                     SCNGeometrySourceSemanticVertex]];
//   }
//   if (sources.normal) {
//     [geometrySources
//         addObject:
//             [self
//                 scnGeometrySourceFromMeshPrimitiveSource:sources.normal
//                                                 semantic:
//                                                     SCNGeometrySourceSemanticNormal]];
//   }
//   if (sources.tangent) {
//     [geometrySources
//         addObject:
//             [self
//                 scnGeometrySourceFromMeshPrimitiveSource:sources.tangent
//                                                 semantic:
//                                                     SCNGeometrySourceSemanticTangent]];
//   }
//   if (sources.texcoords) {
//     for (MeshPrimitiveSource *source in sources.texcoords) {
//       [geometrySources
//           addObject:
//               [self
//                   scnGeometrySourceFromMeshPrimitiveSource:source
//                                                   semantic:
//                                                       SCNGeometrySourceSemanticTexcoord]];
//     }
//   }
//   if (sources.colors) {
//     for (MeshPrimitiveSource *source in sources.colors) {
//       [geometrySources
//           addObject:
//               [self
//                   scnGeometrySourceFromMeshPrimitiveSource:source
//                                                   semantic:
//                                                       SCNGeometrySourceSemanticColor]];
//     }
//   }
//   return [geometrySources copy];
// }
//
//- (SCNGeometry *)scnGeometryFromMeshPrimitive:(MeshPrimitive *)meshPrimitive {
//   NSArray<SCNGeometrySource *> *geometrySources =
//       [self
//       scnGeometrySourcesFromMeshPrimitiveSources:meshPrimitive.sources];
//   NSArray<SCNGeometryElement *> *geometryElements;
//   if (meshPrimitive.element) {
//     geometryElements = @[ [self
//         scnGeometryElementFromMeshPrimitiveElement:meshPrimitive.element] ];
//   }
//
//   return [SCNGeometry geometryWithSources:[geometrySources copy]
//                                  elements:geometryElements];
// }
//
//- (SCNGeometrySource *)
//     scnGeometrySourceFromMeshPrimitiveSource:(MeshPrimitiveSource *)source
//                                     semantic:
//                                         (SCNGeometrySourceSemantic)semantic {
//   NSInteger bytesPerComponent = sizeOfComponentType(source.componentType);
//   return [SCNGeometrySource
//       geometrySourceWithData:source.data
//                     semantic:semantic
//                  vectorCount:source.vectorCount
//              floatComponents:source.componentType ==
//                              GLTFAccessorComponentTypeFloat
//          componentsPerVector:source.componentsPerVector
//            bytesPerComponent:bytesPerComponent
//                   dataOffset:0
//                   dataStride:bytesPerComponent * source.componentsPerVector];
// }
//
//- (SCNGeometryElement *)scnGeometryElementFromMeshPrimitiveElement:
//     (MeshPrimitiveElement *)element {
//   SCNGeometryPrimitiveType primitiveType = SCNGeometryPrimitiveTypeTriangles;
//   NSData *data = convertDataToSCNGeometryPrimitiveType(
//       element.data, element.primitiveMode, &primitiveType);
//   NSInteger primitiveCount = primitiveCountFromGLTFMeshPrimitiveMode(
//       element.primitiveCount, element.primitiveMode);
//   return [SCNGeometryElement
//       geometryElementWithData:data
//                 primitiveType:primitiveType
//                primitiveCount:primitiveCount
//                 bytesPerIndex:sizeOfComponentType(element.componentType)];
// }
//
//// convert indices data with SceneKit compatible primitive type
// static NSData *
// convertDataToSCNGeometryPrimitiveType(NSData *bufferData, NSInteger mode,
//                                       SCNGeometryPrimitiveType
//                                       *primitiveType) {
//   switch (mode) {
//   case GLTFMeshPrimitiveModePoints:
//     *primitiveType = SCNGeometryPrimitiveTypePoint;
//     return bufferData;
//   case GLTFMeshPrimitiveModeLines:
//     *primitiveType = SCNGeometryPrimitiveTypeLine;
//     return bufferData;
//   case GLTFMeshPrimitiveModeLineLoop: {
//     *primitiveType = SCNGeometryPrimitiveTypeLine;
//     // convert to line
//     NSUInteger dataSize = bufferData.length;
//     NSUInteger indicesCount = dataSize / sizeof(uint16_t);
//     uint16_t *bytes = (uint16_t *)bufferData.bytes;
//     NSMutableData *data = [NSMutableData data];
//     for (NSUInteger i = 0; i < indicesCount; i++) {
//       uint16_t v1 = bytes[i];
//       uint16_t v2 = bytes[(i + 1) % indicesCount];
//       [data appendBytes:&v1 length:sizeof(uint16_t)];
//       [data appendBytes:&v2 length:sizeof(uint16_t)];
//     }
//     return [data copy];
//   }
//   case GLTFMeshPrimitiveModeLineStrip: {
//     *primitiveType = SCNGeometryPrimitiveTypeLine;
//     // convert to line
//     NSUInteger dataSize = bufferData.length;
//     NSUInteger indicesCount = dataSize / sizeof(uint16_t);
//     uint16_t *bytes = (uint16_t *)bufferData.bytes;
//     NSMutableData *data = [NSMutableData data];
//     for (NSUInteger i = 0; i < indicesCount - 1; i++) {
//       uint16_t v1 = bytes[i];
//       uint16_t v2 = bytes[i + 1];
//       [data appendBytes:&v1 length:sizeof(uint16_t)];
//       [data appendBytes:&v2 length:sizeof(uint16_t)];
//     }
//     return [data copy];
//   }
//   case GLTFMeshPrimitiveModeTriangles:
//     *primitiveType = SCNGeometryPrimitiveTypeTriangles;
//     return bufferData;
//   case GLTFMeshPrimitiveModeTriangleStrip:
//     *primitiveType = SCNGeometryPrimitiveTypeTriangleStrip;
//     return bufferData;
//   case GLTFMeshPrimitiveModeTriangleFan: {
//     *primitiveType = SCNGeometryPrimitiveTypeTriangles;
//     // convert to triangles
//     NSUInteger dataSize = bufferData.length;
//     NSUInteger indicesCount = dataSize / sizeof(uint16_t);
//     uint16_t *bytes = (uint16_t *)bufferData.bytes;
//     NSMutableData *data = [NSMutableData data];
//     for (NSUInteger i = 1; i < indicesCount - 1; i++) {
//       uint16_t v0 = bytes[0];
//       uint16_t v1 = bytes[i];
//       uint16_t v2 = bytes[i + 1];
//       [data appendBytes:&v0 length:sizeof(uint16_t)];
//       [data appendBytes:&v1 length:sizeof(uint16_t)];
//       [data appendBytes:&v2 length:sizeof(uint16_t)];
//     }
//     return [data copy];
//   }
//   default:
//     return bufferData;
//   }
// }
//
// static NSInteger primitiveCountFromGLTFMeshPrimitiveMode(NSInteger
// indexCount,
//                                                          NSInteger mode) {
//   switch (mode) {
//   case GLTFMeshPrimitiveModePoints:
//     return indexCount;
//   case GLTFMeshPrimitiveModeLines:
//     return indexCount / 2;
//   case GLTFMeshPrimitiveModeLineLoop:
//     return indexCount;
//   case GLTFMeshPrimitiveModeLineStrip:
//     return indexCount - 1;
//   case GLTFMeshPrimitiveModeTriangles:
//     return indexCount / 3;
//   case GLTFMeshPrimitiveModeTriangleStrip:
//     return indexCount - 2;
//   case GLTFMeshPrimitiveModeTriangleFan:
//     return indexCount - 2;
//   default:
//     return indexCount;
//   }
// }
//
//- (nullable SCNMorpher *)
//     scnMorpherFromMeshPrimitive:(GLTFMeshPrimitive *)primitive
//                    withElements:(NSArray<SCNGeometryElement *> *)elements
//                         weights:(nullable NSArray<NSNumber *> *)weights {
//   if (!primitive.targets)
//     return nil;
//
//   SCNMorpher *morpher = [SCNMorpher new];
//
//   NSMutableArray<SCNGeometry *> *morphTargets =
//       [NSMutableArray arrayWithCapacity:primitive.targets.count];
//   for (int i = 0; i < primitive.targets.count; i++) {
//     GLTFMeshPrimitiveTarget *target = primitive.targets[i];
//
//     NSArray<SCNGeometrySource *> *sources =
//         [self scnGeometrySourcesFromMeshPrimitiveSources:
//                   [_data meshPrimitiveSourcesFromTarget:target]];
//     SCNGeometry *morphTarget = [SCNGeometry geometryWithSources:sources
//                                                        elements:elements];
//     [morphTargets addObject:morphTarget];
//   }
//
//   morpher.targets = [morphTargets copy];
//   morpher.unifiesNormals = YES;
//   morpher.calculationMode = SCNMorpherCalculationModeAdditive;
//   if (weights)
//     morpher.weights = weights;
//   return morpher;
// }
//
// #pragma mark animation
//
// CAAnimationCalculationMode
// CAAnimationCalculationModeFromGLTFAnimationSamplerInterpolation(
//     NSString *interpolation) {
//   if ([interpolation
//   isEqualToString:GLTFAnimationSamplerInterpolationLinear]) {
//     return kCAAnimationLinear;
//   } else if ([interpolation
//                  isEqualToString:GLTFAnimationSamplerInterpolationStep]) {
//     return kCAAnimationDiscrete;
//   } else if ([interpolation isEqualToString:
//                                 GLTFAnimationSamplerInterpolationCubicSpline])
//                                 {
//     // TODO: tangent
//     return kCAAnimationCubic;
//   }
//   return kCAAnimationLinear;
// }
//
//- (NSArray<NSNumber *> *)keyTimesFromAnimationSampler:
//                              (GLTFAnimationSampler *)sampler
//                                            maxKeyTime:(float *)maxKeyTime {
//   GLTFAccessor *inputAccessor = _data->json.accessors[sampler.input];
//   // input must be scalar type with float
//   assert([inputAccessor.type isEqualToString:GLTFAccessorTypeScalar] &&
//          inputAccessor.componentType == GLTFAccessorComponentTypeFloat);
//   NSData *inputData = [_data dataForAccessor:inputAccessor normalized:nil];
//   NSArray<NSNumber *> *array = NSArrayFromPackedFloatData(inputData);
//   float max = inputAccessor.max != nil
//                   ? inputAccessor.max.firstObject.floatValue
//                   : array.lastObject.floatValue;
//   // normalize [0,1]
//   NSMutableArray<NSNumber *> *normalized =
//       [NSMutableArray arrayWithCapacity:array.count];
//   for (NSNumber *value in array) {
//     [normalized addObject:@(value.floatValue / max)];
//   }
//   *maxKeyTime = max;
//   return [normalized copy];
// }
//
// #pragma mark -
//
// NSArray<NSNumber *> *NSArrayFromPackedFloatData(NSData *data) {
//   NSUInteger count = data.length / sizeof(float);
//   NSMutableArray<NSNumber *> *array = [NSMutableArray
//   arrayWithCapacity:count]; const float *bytes = (const float *)data.bytes;
//   for (NSUInteger i = 0; i < count; i++) {
//     [array addObject:@(bytes[i])];
//   }
//   return [array copy];
// }
//
// NSArray<NSValue *> *SCNMat4ArrayFromPackedFloatData(NSData *data) {
//   NSUInteger count = data.length / sizeof(float) / 16;
//   NSMutableArray<NSValue *> *arr = [NSMutableArray arrayWithCapacity:count];
//   const float *base = (float *)data.bytes;
//   for (NSUInteger i = 0; i < count; i++) {
//     const float *bytes = base + i * 16;
//     SCNMatrix4 matrix;
//     matrix.m11 = bytes[0];
//     matrix.m12 = bytes[1];
//     matrix.m13 = bytes[2];
//     matrix.m14 = bytes[3];
//     matrix.m21 = bytes[4];
//     matrix.m22 = bytes[5];
//     matrix.m23 = bytes[6];
//     matrix.m24 = bytes[7];
//     matrix.m31 = bytes[8];
//     matrix.m32 = bytes[9];
//     matrix.m33 = bytes[10];
//     matrix.m34 = bytes[11];
//     matrix.m41 = bytes[12];
//     matrix.m42 = bytes[13];
//     matrix.m43 = bytes[14];
//     matrix.m44 = bytes[15];
//     [arr addObject:[NSValue valueWithSCNMatrix4:matrix]];
//   }
//   return [arr copy];
// }
//
// NSArray<NSValue *> *SCNVec4ArrayFromPackedFloatDataWithAccessor(
//     NSData *data, GLTFAccessor *accessor, BOOL isCubisSpline) {
//   NSInteger count = isCubisSpline ? accessor.count / 3 : accessor.count;
//   NSMutableArray<NSValue *> *values = [NSMutableArray
//   arrayWithCapacity:count]; float *bytes = (float *)data.bytes; for (int i =
//   0; i < count; i++) {
//     SCNVector4 vec = SCNVector4Zero;
//     if ([accessor.type isEqualTo:GLTFAccessorTypeVec2]) {
//       if (isCubisSpline)
//         bytes += 2; // skip in-tangent
//       vec.x = bytes[0];
//       vec.y = bytes[1];
//       bytes += 2;
//       if (isCubisSpline)
//         bytes += 2; // skip out-tangent
//     } else if ([accessor.type isEqualTo:GLTFAccessorTypeVec3]) {
//       if (isCubisSpline)
//         bytes += 3; // skip in-tangent
//       vec.x = bytes[0];
//       vec.y = bytes[1];
//       vec.z = bytes[2];
//       bytes += 3;
//       if (isCubisSpline)
//         bytes += 3; // skip out-tangent
//     } else if ([accessor.type isEqualTo:GLTFAccessorTypeVec4]) {
//       if (isCubisSpline)
//         bytes += 4; // skip in-tangent
//       vec.x = bytes[0];
//       vec.y = bytes[1];
//       vec.z = bytes[2];
//       vec.w = bytes[3];
//       bytes += 4;
//       if (isCubisSpline)
//         bytes += 4; // skip out-tangent
//     }
//     [values addObject:[NSValue valueWithSCNVector4:vec]];
//   }
//   return [values copy];
// }
//
// NSArray<NSValue *> *SCNVec3ArrayFromPackedFloatDataWithAccessor(
//     NSData *data, GLTFAccessor *accessor, BOOL isCubisSpline) {
//   NSInteger count = isCubisSpline ? accessor.count / 3 : accessor.count;
//   NSMutableArray<NSValue *> *values = [NSMutableArray
//   arrayWithCapacity:count]; float *bytes = (float *)data.bytes; for (int i =
//   0; i < count; i++) {
//     SCNVector3 vec = SCNVector3Zero;
//     if ([accessor.type isEqualTo:GLTFAccessorTypeVec2]) {
//       if (isCubisSpline)
//         bytes += 2; // skip in-tangent
//       vec.x = bytes[0];
//       vec.y = bytes[1];
//       bytes += 2;
//       if (isCubisSpline)
//         bytes += 2; // skip out-tangent
//     } else if ([accessor.type isEqualTo:GLTFAccessorTypeVec3]) {
//       if (isCubisSpline)
//         bytes += 3; // skip in-tangent
//       vec.x = bytes[0];
//       vec.y = bytes[1];
//       vec.z = bytes[2];
//       bytes += 3;
//       if (isCubisSpline)
//         bytes += 3; // skip out-tangent
//     } else if ([accessor.type isEqualTo:GLTFAccessorTypeVec4]) {
//       if (isCubisSpline)
//         bytes += 4; // skip in-tangent
//       vec.x = bytes[0];
//       vec.y = bytes[1];
//       vec.z = bytes[2];
//       bytes += 4;
//       if (isCubisSpline)
//         bytes += 4; // skip out-tangent
//     }
//     [values addObject:[NSValue valueWithSCNVector3:vec]];
//   }
//   return [values copy];
// }

@end
