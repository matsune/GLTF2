#import "GLTFSCNAsset.h"
#include "GLTF2.h"
#include "GLTFError.h"
#import "JsonConverter.h"
#import "SurfaceShaderModifierBuilder.h"
#include <memory>
#include <unordered_map>

static NSError *NSErrorFromInputException(gltf2::InputException e) {
  return [NSError errorWithDomain:GLTFErrorDomainInput
                             code:GLTFInputError
                         userInfo:@{
                           NSLocalizedDescriptionKey : [NSString
                               stringWithCString:e.what()
                                        encoding:NSUTF8StringEncoding],
                         }];
}

static NSError *NSErrorFromKeyNotFoundException(gltf2::KeyNotFoundException e) {
  return [NSError errorWithDomain:GLTFErrorDomainKeyNotFound
                             code:GLTFKeyNotFoundError
                         userInfo:@{
                           NSLocalizedDescriptionKey : [NSString
                               stringWithCString:e.what()
                                        encoding:NSUTF8StringEncoding],
                         }];
}

static NSError *
NSErrorFromInvalidFormatException(gltf2::InvalidFormatException e) {
  return [NSError errorWithDomain:GLTFErrorDomainInvalidFormat
                             code:GLTFInvalidFormatError
                         userInfo:@{
                           NSLocalizedDescriptionKey : [NSString
                               stringWithCString:e.what()
                                        encoding:NSUTF8StringEncoding],
                         }];
}

static CGImageRef CGImageRefFromData(NSData *data) {
  CGImageSourceRef source =
      CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
  CGImageRef imageRef = CGImageSourceCreateImageAtIndex(source, 0, NULL);
  CFRelease(source);
  return imageRef;
}

@interface GLTFSCNAsset ()

@property(nonatomic, strong) NSArray<SCNMaterial *> *scnMaterials;

@end

@implementation GLTFSCNAsset

- (BOOL)loadFile:(const NSString *)path
           error:(NSError *_Nullable *_Nullable)error {
  try {
    const auto file = gltf2::GLTFFile::parseFile([path UTF8String]);
    const auto data = gltf2::GLTFData::load(std::move(file));
    [self loadScenesWithData:data];
    const auto json = data.moveJson();
    _json = [JsonConverter convertGLTFJson:json];
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

  return YES;
}

- (SCNScene *)defaultScene {
  if (self.json.scene) {
    return self.scenes[self.json.scene.integerValue];
  } else {
    return self.scenes.firstObject;
  }
}

- (NSArray<SCNNode *> *)cameraNodes {
  if (!self.json.cameras)
    return [NSArray array];
  NSMutableArray<SCNNode *> *nodes = [NSMutableArray array];
  for (GLTFNode *node in self.json.nodes) {
    if (node.camera) {
      SCNNode *scnNode = self.scnNodes[node.camera.unsignedIntegerValue];
      [nodes addObject:scnNode];
    }
  }
  return [nodes copy];
}

+ (simd_float4x4)simdTransformOfNode:(const gltf2::json::Node &)node {
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

- (void)loadScenesWithData:(const gltf2::GLTFData &)data {
  // load materials
  _scnMaterials = [GLTFSCNAsset loadSCNMaterialsWithData:data];

  // load cameras
  NSArray<SCNCamera *> *scnCameras = [GLTFSCNAsset loadSCNCamerasWithData:data];

  // load mesh nodes
  _meshNodes = [GLTFSCNAsset loadMeshSCNNodesWithData:data
                                         scnMaterials:self.scnMaterials];

  // load nodes
  if (data.json().nodes.has_value()) {
    const auto &nodes = *data.json().nodes;

    NSMutableArray<SCNNode *> *scnNodes =
        [NSMutableArray arrayWithCapacity:nodes.size()];
    for (NSInteger i = 0; i < nodes.size(); ++i) {
      const auto &node = nodes[i];
      SCNNode *scnNode = [SCNNode node];
      scnNode.name = [[NSUUID UUID] UUIDString];
      scnNode.simdTransform = [GLTFSCNAsset simdTransformOfNode:node];
      if (node.camera.has_value()) {
        scnNode.camera = scnCameras[*node.camera];
      }
      if (node.mesh.has_value()) {
        [scnNode addChildNode:self.meshNodes[*node.mesh]];
      }
      [scnNodes addObject:scnNode];
    }
    _scnNodes = [scnNodes copy];

    for (NSInteger i = 0; i < nodes.size(); i++) {
      const auto &node = nodes[i];
      SCNNode *scnNode = scnNodes[i];

      if (node.children.has_value()) {
        for (const auto childIndex : *node.children) {
          [scnNode addChildNode:scnNodes[childIndex]];
        }
      }

      if (node.skin.has_value()) {
        const auto &skin = data.json().skins->at(*node.skin);

        NSMutableArray<SCNNode *> *bones =
            [NSMutableArray arrayWithCapacity:skin.joints.size()];
        for (auto joint : skin.joints) {
          [bones addObject:scnNodes[joint]];
        }

        NSArray<NSValue *> *boneInverseBindTransforms;
        if (skin.inverseBindMatrices.has_value()) {
          const auto accessorIndex = *skin.inverseBindMatrices;
          const auto &accessor = data.json().accessors->at(accessorIndex);
          const auto &buffer = data.accessorBufferAt(accessorIndex).buffer;
          assert(accessor.type == gltf2::json::Accessor::Type::MAT4 &&
                 accessor.componentType ==
                     gltf2::json::Accessor::ComponentType::FLOAT);
          boneInverseBindTransforms = SCNMat4ArrayFromPackedFloatData(buffer);
        } else {
          NSMutableArray<NSValue *> *arr =
              [NSMutableArray arrayWithCapacity:skin.joints.size()];
          for (int j = 0; j < skin.joints.size(); j++) {
            [arr addObject:[NSValue valueWithSCNMatrix4:SCNMatrix4Identity]];
          }
          boneInverseBindTransforms = [arr copy];
        }

        const uint32_t meshIndex = *node.mesh;
        const auto &mesh = data.json().meshes->at(meshIndex);
        SCNNode *meshNode = self.meshNodes[meshIndex];
        for (uint32_t primitiveIndex = 0;
             primitiveIndex < mesh.primitives.size(); primitiveIndex++) {
          const auto &primitive = mesh.primitives[primitiveIndex];
          const auto &meshPrimitive =
              data.meshPrimitiveAt(meshIndex, primitiveIndex);

          SCNNode *geometryNode = meshNode.childNodes[primitiveIndex];
          SCNGeometry *geometry = geometryNode.geometry;

          SCNGeometrySource *boneWeights;
          if (meshPrimitive.sources.weights.size() > 0) {
            boneWeights = [GLTFSCNAsset
                scnGeometrySourceFromMeshPrimitiveSource:meshPrimitive.sources
                                                             .weights[0]
                                                semantic:
                                                    SCNGeometrySourceSemanticBoneWeights];
          }
          SCNGeometrySource *boneIndices;
          if (meshPrimitive.sources.joints.size() > 0) {
            boneIndices = [GLTFSCNAsset
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

  // animations
  NSMutableArray<SCNAnimationPlayer *> *animationPlayers =
      [NSMutableArray array];
  if (data.json().animations.has_value()) {
    for (const auto &animation : *data.json().animations) {
      NSMutableArray *channelAnimations = [NSMutableArray array];
      float maxDuration = 1.0f;

      for (const auto &channel : animation.channels) {
        if (!channel.target.node.has_value())
          continue;

        const auto &node = data.json().nodes->at(*channel.target.node);
        SCNNode *scnNode = self.scnNodes[*channel.target.node];

        const auto &sampler = animation.samplers[channel.sampler];

        float maxKeyTime = 1.0f;
        NSArray<NSNumber *> *keyTimes =
            [GLTFSCNAsset keyTimesFromAnimationSampler:sampler
                                            maxKeyTime:&maxKeyTime
                                                  data:data];
        maxDuration = MAX(maxDuration, maxKeyTime);

        const auto &outputAccessor = data.json().accessors->at(sampler.output);
        const auto &accessorBuffer = data.accessorBufferAt(sampler.output);
        bool normalized = accessorBuffer.normalized;
        const auto &outputData = accessorBuffer.buffer;

        if (channel.target.path ==
            gltf2::json::AnimationChannelTarget::Path::WEIGHTS) {
          // Weights animation
          NSArray<NSNumber *> *numbers = NSArrayFromPackedFloatData(outputData);

          const auto &mesh = data.json().meshes->at(*node.mesh);

          for (NSInteger i = 0; i < mesh.primitives.size(); i++) {
            const auto &primitive = mesh.primitives[i];

            SCNNode *geometryNode = scnNode.childNodes[i];

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
                  gltf2::json::Accessor::ComponentType::FLOAT &&
              !normalized)
            continue;
          // only supports vec types
          if (outputAccessor.type != gltf2::json::Accessor::Type::VEC2 &&
              outputAccessor.type != gltf2::json::Accessor::Type::VEC3 &&
              outputAccessor.type != gltf2::json::Accessor::Type::VEC4)
            continue;

          CAAnimationCalculationMode calculationMode =
              CAAnimationCalculationModeFromGLTFAnimationSamplerInterpolation(
                  sampler.interpolationValue());
          BOOL isCubisSpline = calculationMode == kCAAnimationCubic;

          NSArray<NSValue *> *values;
          NSString *keyPath;
          if (channel.target.path ==
              gltf2::json::AnimationChannelTarget::Path::TRANSLATION) {
            values = SCNVec3ArrayFromPackedFloatDataWithAccessor(
                outputData, outputAccessor, isCubisSpline);
            keyPath = [NSString stringWithFormat:@"/%@.position", scnNode.name];
          } else if (channel.target.path ==
                     gltf2::json::AnimationChannelTarget::Path::ROTATION) {
            values = SCNVec4ArrayFromPackedFloatDataWithAccessor(
                outputData, outputAccessor, isCubisSpline);
            keyPath =
                [NSString stringWithFormat:@"/%@.orientation", scnNode.name];
          } else if (channel.target.path ==
                     gltf2::json::AnimationChannelTarget::Path::SCALE) {
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
  if (data.json().scenes.has_value()) {
    for (const auto &scene : *data.json().scenes) {
      SCNScene *scnScene = [SCNScene scene];
      if (scene.nodes.has_value()) {
        for (auto nodeIndex : *scene.nodes) {
          [scnScene.rootNode addChildNode:self.scnNodes[nodeIndex]];
        }
      }
      [scnScenes addObject:scnScene];
    }
  }
  self.scenes = [scnScenes copy];
}

#pragma mark SCNMaterial

+ (nullable NSArray<SCNMaterial *> *)loadSCNMaterialsWithData:
    (const gltf2::GLTFData &)data {
  if (!data.json().materials)
    return nil;

  NSUInteger materialsSize = data.json().materials->size();
  NSMutableArray<SCNMaterial *> *scnMaterials =
      [NSMutableArray arrayWithCapacity:materialsSize];
  for (NSUInteger index = 0; index < materialsSize; ++index) {
    [scnMaterials addObject:[GLTFSCNAsset loadSCNMaterialWithData:data
                                                          atIndex:index]];
  }
  return [scnMaterials copy];
}

+ (SCNMaterial *)loadSCNMaterialWithData:(const gltf2::GLTFData &)data
                                 atIndex:(NSUInteger)index {
  const auto &material = data.json().materials->at(index);
  SCNMaterial *scnMaterial = [SCNMaterial material];
  scnMaterial.locksAmbientWithDiffuse = YES;
  if (material.isUnlit()) {
    scnMaterial.lightingModelName = SCNLightingModelConstant;
  } else if (material.pbrMetallicRoughness.has_value()) {
    scnMaterial.lightingModelName = SCNLightingModelPhysicallyBased;
  } else {
    scnMaterial.lightingModelName = SCNLightingModelBlinn;
  }

  SurfaceShaderModifierBuilder *builder =
      [[SurfaceShaderModifierBuilder alloc] init];

  SCNVector4 diffuseBaseColorFactor = SCNVector4Make(1.0, 1.0, 1.0, 1.0);
  float diffuseAlphaCutoff = 0.0f;

  float anisotropyStrength = 1.0f;
  float anisotropyRotation = 0.0f;
  SCNMaterialProperty *anisotropyTexture;

  SCNVector3 sheenColorFactor = SCNVector3Make(1.0, 1.0, 1.0);
  SCNMaterialProperty *sheenColorTexture;
  float sheenRoughnessFactor = 1.0;
  SCNMaterialProperty *sheenRoughnessTexture;

  float emissiveStrength = 1.0f;

  float ior = 1.5f;

  auto pbrMetallicRoughness = material.pbrMetallicRoughness.value_or(
      gltf2::json::MaterialPBRMetallicRoughness());

  // baseColor
  if (pbrMetallicRoughness.baseColorTexture.has_value()) {
    // set contents to texture
    [self applyTextureInfo:*pbrMetallicRoughness.baseColorTexture
             withIntensity:1.0f
                toProperty:scnMaterial.diffuse
                      data:data];
    builder.hasBaseColorTexture = true;

    if (pbrMetallicRoughness.baseColorFactor.has_value()) {
      auto factor = *pbrMetallicRoughness.baseColorFactor;
      diffuseBaseColorFactor =
          SCNVector4Make(factor[0], factor[1], factor[2], factor[3]);
      builder.transparent = diffuseBaseColorFactor.w < 1.0f;
    }
  } else {
    auto value = pbrMetallicRoughness.baseColorFactorValue();
    [self applyColorR:value[0]
                    G:value[1]
                    B:value[2]
                    A:value[3]
           toProperty:scnMaterial.diffuse];
  }

  // metallic & roughness
  if (pbrMetallicRoughness.metallicRoughnessTexture.has_value()) {
    [GLTFSCNAsset
        applyTextureInfo:*pbrMetallicRoughness.metallicRoughnessTexture
           withIntensity:pbrMetallicRoughness.metallicFactorValue()
              toProperty:scnMaterial.metalness
                    data:data];
    scnMaterial.metalness.textureComponents = SCNColorMaskBlue;

    [GLTFSCNAsset
        applyTextureInfo:*pbrMetallicRoughness.metallicRoughnessTexture
           withIntensity:pbrMetallicRoughness.roughnessFactorValue()
              toProperty:scnMaterial.roughness
                    data:data];
    scnMaterial.roughness.textureComponents = SCNColorMaskGreen;
  } else {
    scnMaterial.metalness.contents =
        @(pbrMetallicRoughness.metallicFactorValue());
    scnMaterial.roughness.contents =
        @(pbrMetallicRoughness.roughnessFactorValue());
  }

  // normal
  if (material.normalTexture.has_value()) {
    [self applyTextureInfo:*material.normalTexture
             withIntensity:material.normalTexture->scaleValue()
                toProperty:scnMaterial.normal
                      data:data];
  }

  // occlusion
  if (material.occlusionTexture.has_value()) {
    [self applyTextureInfo:*material.occlusionTexture
             withIntensity:material.occlusionTexture->strengthValue()
                toProperty:scnMaterial.ambientOcclusion
                      data:data];
    scnMaterial.ambientOcclusion.textureComponents = SCNColorMaskRed;
  }

  // emissive
  if (material.emissiveTexture.has_value()) {
    [self applyTextureInfo:*material.emissiveTexture
             withIntensity:1.0f
                toProperty:scnMaterial.emission
                      data:data];
  } else {
    auto value = material.emissiveFactorValue();
    [self applyColorR:value[0]
                    G:value[1]
                    B:value[2]
                    A:1.0
           toProperty:scnMaterial.emission];
  }
  if (material.emissiveStrength.has_value()) {
    emissiveStrength = material.emissiveStrength->emissiveStrengthValue();
  }

  // blend mode
  if (material.alphaModeValue() == gltf2::json::Material::AlphaMode::OPAQUE) {
    scnMaterial.blendMode = SCNBlendModeReplace;
    builder.isDiffuseOpaque = true;
  } else if (material.alphaModeValue() ==
             gltf2::json::Material::AlphaMode::MASK) {
    scnMaterial.blendMode = SCNBlendModeReplace;
    diffuseAlphaCutoff = material.alphaCutoffValue();
    builder.enableDiffuseAlphaCutoff = true;
  } else if (material.alphaModeValue() ==
             gltf2::json::Material::AlphaMode::BLEND) {
    scnMaterial.blendMode = SCNBlendModeAlpha;
    scnMaterial.transparencyMode = SCNTransparencyModeDualLayer;
  }

  scnMaterial.doubleSided = material.isDoubleSided();

  // anisotropy
  if (material.anisotropy.has_value()) {
    if (material.anisotropy->anisotropyTexture.has_value()) {
      anisotropyTexture = [SCNMaterialProperty new];
      [self applyTextureInfo:*material.anisotropy->anisotropyTexture
               withIntensity:1.0
                  toProperty:anisotropyTexture
                        data:data];
      builder.hasAnisotropyTexture = true;
    }
    anisotropyStrength = material.anisotropy->anisotropyStrengthValue();
    anisotropyRotation = material.anisotropy->anisotropyRotationValue();
    builder.enableAnisotropy = true;
  }

  // sheen
  if (material.sheen.has_value()) {
    std::array<float, 3> colorFactor = material.sheen->sheenColorFactorValue();
    sheenColorFactor =
        SCNVector3Make(colorFactor[0], colorFactor[1], colorFactor[2]);
    sheenRoughnessFactor = material.sheen->sheenRoughnessFactorValue();
    if (material.sheen->sheenColorTexture.has_value()) {
      sheenColorTexture = [SCNMaterialProperty new];
      [self applyTextureInfo:*material.sheen->sheenColorTexture
               withIntensity:1.0
                  toProperty:sheenColorTexture
                        data:data];
      builder.hasSheenColorTexture = true;
    }
    if (material.sheen->sheenRoughnessTexture.has_value()) {
      sheenRoughnessTexture = [SCNMaterialProperty new];
      [self applyTextureInfo:*material.sheen->sheenRoughnessTexture
               withIntensity:1.0
                  toProperty:sheenRoughnessTexture
                        data:data];
      builder.hasSheenRoughnessTexture = true;
    }
    builder.enableSheen = true;
  }

  // TODO: specular
  if (material.specular.has_value()) {
  }

  // ior
  if (material.ior.has_value()) {
    ior = material.ior->iorValue();
  }

  // clearcoat
  if (material.clearcoat.has_value()) {
    if (material.clearcoat->clearcoatTexture.has_value()) {
      [self applyTextureInfo:*material.clearcoat->clearcoatTexture
               withIntensity:material.clearcoat->clearcoatFactorValue()
                  toProperty:scnMaterial.clearCoat
                        data:data];
      scnMaterial.clearCoat.textureComponents = SCNColorMaskRed;
    } else {
      scnMaterial.clearCoat.contents =
          @(material.clearcoat->clearcoatFactorValue());
    }
    if (material.clearcoat->clearcoatRoughnessTexture.has_value()) {
      [self applyTextureInfo:*material.clearcoat->clearcoatRoughnessTexture
               withIntensity:material.clearcoat->clearcoatRoughnessFactorValue()
                  toProperty:scnMaterial.clearCoatRoughness
                        data:data];
      scnMaterial.clearCoatRoughness.textureComponents = SCNColorMaskGreen;
    } else {
      scnMaterial.clearCoatRoughness.contents =
          @(material.clearcoat->clearcoatRoughnessFactorValue());
    }
    if (material.clearcoat->clearcoatNormalTexture.has_value()) {
      [self applyTextureInfo:*material.clearcoat->clearcoatNormalTexture
               withIntensity:1.0
                  toProperty:scnMaterial.clearCoatNormal
                        data:data];
    }
  }

  // transmission
  if (material.transmission.has_value()) {
    if (material.transmission->transmissionTexture.has_value()) {
      [GLTFSCNAsset
          applyTextureInfo:*material.transmission->transmissionTexture
             withIntensity:material.transmission->transmissionFactorValue()
                toProperty:scnMaterial.transparent
                      data:data];
      scnMaterial.transparent.textureComponents = SCNColorMaskRed;
    } else {
      scnMaterial.transparent.contents =
          @(material.transmission->transmissionFactorValue());
    }
  }

  [scnMaterial setValue:[NSValue valueWithSCNVector4:diffuseBaseColorFactor]
             forKeyPath:@"diffuseBaseColorFactor"];
  [scnMaterial setValue:[NSNumber numberWithFloat:diffuseAlphaCutoff]
             forKeyPath:@"diffuseAlphaCutoff"];

  [scnMaterial setValue:[NSNumber numberWithFloat:anisotropyStrength]
             forKeyPath:@"anisotropyStrength"];
  [scnMaterial setValue:[NSNumber numberWithFloat:anisotropyRotation]
             forKeyPath:@"anisotropyRotation"];
  [scnMaterial setValue:anisotropyTexture forKeyPath:@"anisotropyTexture"];

  [scnMaterial setValue:[NSValue valueWithSCNVector3:sheenColorFactor]
             forKeyPath:@"sheenColorFactor"];
  [scnMaterial setValue:sheenColorTexture forKeyPath:@"sheenColorTexture"];
  [scnMaterial setValue:[NSNumber numberWithFloat:sheenRoughnessFactor]
             forKeyPath:@"sheenRoughnessFactor"];
  [scnMaterial setValue:sheenRoughnessTexture
             forKeyPath:@"sheenRoughnessTexture"];

  [scnMaterial setValue:[NSNumber numberWithFloat:emissiveStrength]
                 forKey:@"emissiveStrength"];

  [scnMaterial setValue:[NSNumber numberWithFloat:ior] forKey:@"ior"];

  scnMaterial.shaderModifiers = @{
    SCNShaderModifierEntryPointSurface : [builder buildShader],
  };
  return scnMaterial;
}

+ (void)applyColorR:(float)r
                  G:(float)g
                  B:(float)b
                  A:(float)a
         toProperty:(SCNMaterialProperty *)property {
  CGColorSpaceRef colorSpace =
      CGColorSpaceCreateWithName(kCGColorSpaceLinearSRGB);
  CGFloat components[] = {r, g, b, a};
  CGColorRef color = CGColorCreate(colorSpace, components);
  property.contents = (__bridge id)(color);
  CGColorRelease(color);
  CGColorSpaceRelease(colorSpace);
}

+ (void)applyTextureInfo:(const gltf2::json::TextureInfo &)textureInfo
           withIntensity:(CGFloat)intensity
              toProperty:(SCNMaterialProperty *)property
                    data:(const gltf2::GLTFData &)data {
  auto &texture = data.json().textures->at(textureInfo.index);
  [self applyTexture:texture toProperty:property data:data];
  property.mappingChannel = textureInfo.texCoordValue();
  property.intensity = intensity;

  if (textureInfo.khrTextureTransform.has_value()) {
    [self applyKHRTextureTransform:*textureInfo.khrTextureTransform
                        toProperty:property];
  }
}

+ (void)applyImageBuffer:(const gltf2::Buffer &)buffer
              toProperty:(SCNMaterialProperty *)property {
  NSData *nsData = [NSData dataWithBytes:buffer.data() length:buffer.size()];
  property.contents = (__bridge id)CGImageRefFromData(nsData);
}

+ (void)applyTexture:(const gltf2::json::Texture &)texture
          toProperty:(SCNMaterialProperty *)property
                data:(const gltf2::GLTFData &)data {
  property.wrapS = SCNWrapModeRepeat;
  property.wrapT = SCNWrapModeRepeat;
  property.magnificationFilter = SCNFilterModeNone;
  property.minificationFilter = SCNFilterModeNone;
  property.mipFilter = SCNFilterModeNone;

  if (texture.source.has_value()) {
    const auto &buffer = data.imageBufferAt(*texture.source);
    [self applyImageBuffer:buffer toProperty:property];
  }

  if (texture.sampler.has_value()) {
    auto &sampler = data.json().samplers->at(*texture.sampler);
    [self applyTextureSampler:sampler toProperty:property];
  }
}

+ (void)applyTextureSampler:(const gltf2::json::Sampler &)sampler
                 toProperty:(SCNMaterialProperty *)property {
  if (sampler.magFilter.has_value()) {
    switch (*sampler.magFilter) {
    case gltf2::json::Sampler::MagFilter::NEAREST:
      property.magnificationFilter = SCNFilterModeNearest;
      break;
    case gltf2::json::Sampler::MagFilter::LINEAR:
      property.magnificationFilter = SCNFilterModeLinear;
      break;
    default:
      break;
    }
  }
  if (sampler.minFilter.has_value()) {
    switch (*sampler.minFilter) {
    case gltf2::json::Sampler::MinFilter::LINEAR:
      property.minificationFilter = SCNFilterModeLinear;
      break;
    case gltf2::json::Sampler::MinFilter::LINEAR_MIPMAP_NEAREST:
      property.minificationFilter = SCNFilterModeLinear;
      property.mipFilter = SCNFilterModeNearest;
      break;
    case gltf2::json::Sampler::MinFilter::LINEAR_MIPMAP_LINEAR:
      property.minificationFilter = SCNFilterModeLinear;
      property.mipFilter = SCNFilterModeLinear;
      break;
    case gltf2::json::Sampler::MinFilter::NEAREST:
      property.minificationFilter = SCNFilterModeNearest;
      break;
    case gltf2::json::Sampler::MinFilter::NEAREST_MIPMAP_NEAREST:
      property.minificationFilter = SCNFilterModeNearest;
      property.mipFilter = SCNFilterModeNearest;
      break;
    case gltf2::json::Sampler::MinFilter::NEAREST_MIPMAP_LINEAR:
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
SCNWrapModeFromGLTFSamplerWrapMode(gltf2::json::Sampler::WrapMode mode) {
  switch (mode) {
  case gltf2::json::Sampler::WrapMode::CLAMP_TO_EDGE:
    return SCNWrapModeClamp;
  case gltf2::json::Sampler::WrapMode::MIRRORED_REPEAT:
    return SCNWrapModeMirror;
  case gltf2::json::Sampler::WrapMode::REPEAT:
    return SCNWrapModeRepeat;
  }
}

+ (SCNMatrix4)contentsTransformFromKHRTextureTransform:
    (const gltf2::json::KHRTextureTransform &)transform {
  auto scale = transform.scaleValue();
  auto rotation = transform.rotationValue();
  auto offset = transform.offsetValue();
  SCNMatrix4 t = SCNMatrix4MakeTranslation(offset[0], offset[1], 0);
  SCNMatrix4 r = SCNMatrix4MakeRotation(-rotation, 0, 0, 1);
  SCNMatrix4 s = SCNMatrix4MakeScale(scale[0], scale[1], 1);
  return SCNMatrix4Mult(SCNMatrix4Mult(s, r), t);
}

+ (void)applyKHRTextureTransform:
            (const gltf2::json::KHRTextureTransform &)transform
                      toProperty:(SCNMaterialProperty *)property {
  if (transform.texCoord.has_value()) {
    property.mappingChannel = *transform.texCoord;
  }
  property.contentsTransform =
      [self contentsTransformFromKHRTextureTransform:transform];
}

#pragma mark SCNCamera

+ (nullable NSArray<SCNCamera *> *)loadSCNCamerasWithData:
    (const gltf2::GLTFData &)data {
  if (!data.json().cameras.has_value())
    return nil;

  NSUInteger camerasSize = data.json().cameras->size();
  NSMutableArray<SCNCamera *> *scnCameras =
      [NSMutableArray arrayWithCapacity:camerasSize];
  for (NSUInteger index = 0; index < camerasSize; ++index) {
    [scnCameras addObject:[self loadSCNCameraWithData:data atIndex:index]];
  }
  return [scnCameras copy];
}

+ (SCNCamera *)loadSCNCameraWithData:(const gltf2::GLTFData &)data
                             atIndex:(NSUInteger)index {
  const auto &camera = data.json().cameras->at(index);
  SCNCamera *scnCamera = [SCNCamera camera];

  if (camera.orthographic.has_value()) {
    [self applyOrthographicCamera:*camera.orthographic toSCNCamera:scnCamera];
  } else if (camera.perspective.has_value()) {
    [self applyPerspectiveCamera:*camera.perspective toSCNCamera:scnCamera];
  }
  return scnCamera;
}

+ (void)applyOrthographicCamera:
            (const gltf2::json::CameraOrthographic &)orthographic
                    toSCNCamera:(SCNCamera *)scnCamera {
  scnCamera.usesOrthographicProjection = YES;
  scnCamera.orthographicScale = MAX(orthographic.xmag, orthographic.ymag);
  scnCamera.zFar = orthographic.zfar;
  scnCamera.zNear = orthographic.znear;
}

+ (void)applyPerspectiveCamera:
            (const gltf2::json::CameraPerspective &)perspective
                   toSCNCamera:(SCNCamera *)scnCamera {
  scnCamera.usesOrthographicProjection = NO;
  scnCamera.zFar = perspective.zfar.value_or(scnCamera.zFar);
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

+ (NSArray<SCNNode *> *)loadMeshSCNNodesWithData:(const gltf2::GLTFData &)data
                                    scnMaterials:
                                        (NSArray<SCNMaterial *> *)scnMaterials {
  if (!data.json().meshes)
    return nil;

  NSUInteger meshesSize = data.json().meshes->size();
  NSMutableArray<SCNNode *> *scnNodes =
      [NSMutableArray arrayWithCapacity:meshesSize];
  for (uint32_t index = 0; index < meshesSize; ++index) {
    [scnNodes addObject:[GLTFSCNAsset loadMeshSCNNodeWithData:data
                                                      atIndex:index
                                                 scnMaterials:scnMaterials]];
  }
  return [scnNodes copy];
}

+ (SCNNode *)loadMeshSCNNodeWithData:(const gltf2::GLTFData &)data
                             atIndex:(uint32_t)index
                        scnMaterials:(NSArray<SCNMaterial *> *)scnMaterials {
  const auto &mesh = data.json().meshes->at(index);
  SCNNode *meshNode = [SCNNode node];

  for (uint32_t primitiveIndex = 0; primitiveIndex < mesh.primitives.size();
       primitiveIndex++) {
    const auto &primitive = mesh.primitives[primitiveIndex];
    const auto &meshPrimitive = data.meshPrimitiveAt(index, primitiveIndex);

    SCNGeometry *geometry = [self scnGeometryFromMeshPrimitive:meshPrimitive];
    if (primitive.modeValue() == gltf2::json::MeshPrimitive::Mode::POINTS &&
        geometry.geometryElementCount > 0) {
      geometry.geometryElements.firstObject.minimumPointScreenSpaceRadius = 1.0;
      geometry.geometryElements.firstObject.maximumPointScreenSpaceRadius = 1.0;
    }

    if (primitive.material.has_value()) {
      geometry.firstMaterial = scnMaterials[*primitive.material];
    }

    SCNMorpher *morpher;
    if (primitive.targets.has_value()) {
      morpher = [SCNMorpher new];

      NSMutableArray<SCNGeometry *> *morphTargets =
          [NSMutableArray arrayWithCapacity:primitive.targets->size()];
      for (uint32_t targetIndex = 0; targetIndex < primitive.targets->size();
           targetIndex++) {
        const auto primitiveSources = meshPrimitive.targets[targetIndex];
        NSArray<SCNGeometrySource *> *sources =
            [self scnGeometrySourcesFromMeshPrimitiveSources:primitiveSources];
        SCNGeometry *morphTarget =
            [SCNGeometry geometryWithSources:sources
                                    elements:geometry.geometryElements];
        [morphTargets addObject:morphTarget];
      }

      morpher.targets = [morphTargets copy];
      morpher.unifiesNormals = YES;
      morpher.calculationMode = SCNMorpherCalculationModeAdditive;
      if (mesh.weights.has_value()) {
        NSMutableArray<NSNumber *> *values =
            [NSMutableArray arrayWithCapacity:mesh.weights->size()];
        for (auto weight : *mesh.weights) {
          [values addObject:[NSNumber numberWithFloat:weight]];
        }
        morpher.weights = [values copy];
      }
    }

    SCNNode *geometryNode = [SCNNode nodeWithGeometry:geometry];
    geometryNode.name = [[NSUUID UUID] UUIDString];
    geometryNode.morpher = morpher;
    [meshNode addChildNode:geometryNode];
  }

  return meshNode;
}

+ (NSArray<SCNGeometrySource *> *)scnGeometrySourcesFromMeshPrimitiveSources:
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

+ (SCNGeometry *)scnGeometryFromMeshPrimitive:
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

+ (SCNGeometrySource *)
    scnGeometrySourceFromMeshPrimitiveSource:
        (const gltf2::MeshPrimitiveSource &)source
                                    semantic:
                                        (SCNGeometrySourceSemantic)semantic {
  auto bytesPerComponent =
      gltf2::json::Accessor::sizeOfComponentType(source.componentType);
  NSData *data = [NSData dataWithBytes:source.buffer.data()
                                length:source.buffer.size()];
  return [SCNGeometrySource
      geometrySourceWithData:data
                    semantic:semantic
                 vectorCount:source.vectorCount
             floatComponents:source.componentType ==
                             gltf2::json::Accessor::ComponentType::FLOAT
         componentsPerVector:source.componentsPerVector
           bytesPerComponent:bytesPerComponent
                  dataOffset:0
                  dataStride:bytesPerComponent * source.componentsPerVector];
}

+ (SCNGeometryElement *)scnGeometryElementFromMeshPrimitiveElement:
    (const gltf2::MeshPrimitiveElement &)element {
  SCNGeometryPrimitiveType primitiveType = SCNGeometryPrimitiveTypeTriangles;
  NSUInteger sizeOfComponent =
      gltf2::json::Accessor::sizeOfComponentType(element.componentType);
  NSUInteger primitiveCount = element.primitiveCount;
  NSData *data = convertDataToSCNGeometryPrimitiveType(
      element.buffer, sizeOfComponent, &primitiveCount, element.primitiveMode,
      &primitiveType);
  return [SCNGeometryElement geometryElementWithData:data
                                       primitiveType:primitiveType
                                      primitiveCount:primitiveCount
                                       bytesPerIndex:sizeOfComponent];
}

// convert indices data with SceneKit compatible primitive type
static NSData *convertDataToSCNGeometryPrimitiveType(
    const gltf2::Buffer &bufferData, NSUInteger sizeOfComponent,
    NSUInteger *primitiveCount, gltf2::json::MeshPrimitive::Mode mode,
    SCNGeometryPrimitiveType *primitiveType) {
  switch (mode) {
  case gltf2::json::MeshPrimitive::Mode::POINTS:
    *primitiveType = SCNGeometryPrimitiveTypePoint;
    return [NSData dataWithBytes:bufferData.data() length:bufferData.size()];
  case gltf2::json::MeshPrimitive::Mode::LINES:
    *primitiveType = SCNGeometryPrimitiveTypeLine;
    return [NSData dataWithBytes:bufferData.data() length:bufferData.size()];
  case gltf2::json::MeshPrimitive::Mode::LINE_LOOP: {
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
  case gltf2::json::MeshPrimitive::Mode::LINE_STRIP: {
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
  case gltf2::json::MeshPrimitive::Mode::TRIANGLES:
    *primitiveType = SCNGeometryPrimitiveTypeTriangles;
    return [NSData dataWithBytes:bufferData.data() length:bufferData.size()];
  case gltf2::json::MeshPrimitive::Mode::TRIANGLE_STRIP:
    *primitiveType = SCNGeometryPrimitiveTypeTriangleStrip;
    return [NSData dataWithBytes:bufferData.data() length:bufferData.size()];
  case gltf2::json::MeshPrimitive::Mode::TRIANGLE_FAN: {
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

#pragma mark animation

CAAnimationCalculationMode
CAAnimationCalculationModeFromGLTFAnimationSamplerInterpolation(
    gltf2::json::AnimationSampler::Interpolation interpolation) {
  if (interpolation == gltf2::json::AnimationSampler::Interpolation::LINEAR) {
    return kCAAnimationLinear;
  } else if (interpolation ==
             gltf2::json::AnimationSampler::Interpolation::STEP) {
    return kCAAnimationDiscrete;
  } else if (interpolation ==
             gltf2::json::AnimationSampler::Interpolation::CUBICSPLINE) {
    // TODO: tangent
    return kCAAnimationCubic;
  }
  return kCAAnimationLinear;
}

+ (NSArray<NSNumber *> *)
    keyTimesFromAnimationSampler:(const gltf2::json::AnimationSampler &)sampler
                      maxKeyTime:(float *)maxKeyTime
                            data:(const gltf2::GLTFData &)data {
  const auto &inputAccessor = data.json().accessors->at(sampler.input);
  // input must be scalar type with float
  assert(inputAccessor.type == gltf2::json::Accessor::Type::SCALAR &&
         inputAccessor.componentType ==
             gltf2::json::Accessor::ComponentType::FLOAT);
  const auto &inputData = data.accessorBufferAt(sampler.input).buffer;
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

NSArray<NSNumber *> *NSArrayFromPackedFloatData(const gltf2::Buffer &buffer) {
  NSUInteger count = buffer.size() / sizeof(float);
  NSMutableArray<NSNumber *> *array = [NSMutableArray arrayWithCapacity:count];
  const float *bytes = (const float *)buffer.data();
  for (NSUInteger i = 0; i < count; i++) {
    [array addObject:@(bytes[i])];
  }
  return [array copy];
}

NSArray<NSValue *> *
SCNMat4ArrayFromPackedFloatData(const gltf2::Buffer &buffer) {
  NSUInteger count = buffer.size() / sizeof(float) / 16;
  NSMutableArray<NSValue *> *arr = [NSMutableArray arrayWithCapacity:count];
  const float *base = (float *)buffer.data();
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
    const gltf2::Buffer &buffer, const gltf2::json::Accessor &accessor,
    BOOL isCubisSpline) {
  NSInteger count = isCubisSpline ? accessor.count / 3 : accessor.count;
  NSMutableArray<NSValue *> *values = [NSMutableArray arrayWithCapacity:count];
  float *bytes = (float *)buffer.data();
  for (int i = 0; i < count; i++) {
    SCNVector4 vec = SCNVector4Zero;
    if (accessor.type == gltf2::json::Accessor::Type::VEC2) {
      if (isCubisSpline)
        bytes += 2; // skip in-tangent
      vec.x = bytes[0];
      vec.y = bytes[1];
      bytes += 2;
      if (isCubisSpline)
        bytes += 2; // skip out-tangent
    } else if (accessor.type == gltf2::json::Accessor::Type::VEC3) {
      if (isCubisSpline)
        bytes += 3; // skip in-tangent
      vec.x = bytes[0];
      vec.y = bytes[1];
      vec.z = bytes[2];
      bytes += 3;
      if (isCubisSpline)
        bytes += 3; // skip out-tangent
    } else if (accessor.type == gltf2::json::Accessor::Type::VEC4) {
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
    const gltf2::Buffer &buffer, const gltf2::json::Accessor &accessor,
    BOOL isCubisSpline) {
  NSInteger count = isCubisSpline ? accessor.count / 3 : accessor.count;
  NSMutableArray<NSValue *> *values = [NSMutableArray arrayWithCapacity:count];
  float *bytes = (float *)buffer.data();
  for (int i = 0; i < count; i++) {
    SCNVector3 vec = SCNVector3Zero;
    if (accessor.type == gltf2::json::Accessor::Type::VEC2) {
      if (isCubisSpline)
        bytes += 2; // skip in-tangent
      vec.x = bytes[0];
      vec.y = bytes[1];
      bytes += 2;
      if (isCubisSpline)
        bytes += 2; // skip out-tangent
    } else if (accessor.type == gltf2::json::Accessor::Type::VEC3) {
      if (isCubisSpline)
        bytes += 3; // skip in-tangent
      vec.x = bytes[0];
      vec.y = bytes[1];
      vec.z = bytes[2];
      bytes += 3;
      if (isCubisSpline)
        bytes += 3; // skip out-tangent
    } else if (accessor.type == gltf2::json::Accessor::Type::VEC4) {
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
