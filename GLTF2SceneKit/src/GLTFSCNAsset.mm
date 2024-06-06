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
  gltf2::GLTFJson _json;
}

@property(nonatomic, strong) NSArray<SCNMaterial *> *scnMaterials;

@end

@implementation GLTFSCNAsset

- (instancetype)init {
  self = [super init];
  if (self) {
    _scenes = [NSArray array];
    _cameraNodes = [NSArray array];
    _animationPlayers = [NSArray array];
    _scnMaterials = [NSArray array];
  }
  return self;
}

- (BOOL)loadFile:(const NSString *)path
           error:(NSError *_Nullable *_Nullable)error {
  try {
    const auto file = gltf2::GLTFFile::parseFile([path UTF8String]);
    const auto data = gltf2::GLTFData::load(std::move(file));
    [self loadScenesWithData:data];
    _json = data.moveJson();
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

#pragma mark SCNScene

- (nullable SCNScene *)defaultScene {
  if (_json.scene.has_value()) {
    return self.scenes[*_json.scene];
  } else {
    return self.scenes.firstObject;
  }
}

static simd_float4x4 simdTransformOfNode(const gltf2::GLTFNode &node) {
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
  self.scnMaterials = [self loadSCNMaterialsWithData:data];

  // load cameras
  NSArray<SCNCamera *> *scnCameras = [self loadSCNCamerasWithData:data];

  // load nodes
  NSMutableArray<SCNNode *> *scnNodes;
  NSMutableArray<SCNNode *> *cameraNodes = [NSMutableArray array];

  if (data.json().nodes.has_value()) {
    scnNodes = [NSMutableArray arrayWithCapacity:data.json().nodes->size()];

    for (const auto &node : *data.json().nodes) {
      SCNNode *scnNode = [SCNNode node];
      scnNode.name = [[NSUUID UUID] UUIDString];
      scnNode.simdTransform = simdTransformOfNode(node);

      if (node.camera.has_value()) {
        scnNode.camera = scnCameras[*node.camera];
        [cameraNodes addObject:scnNode];
      }

      if (node.mesh.has_value()) {
        const auto meshIndex = *node.mesh;
        const auto &mesh = data.json().meshes->at(meshIndex);

        for (uint32_t primitiveIndex = 0;
             primitiveIndex < mesh.primitives.size(); primitiveIndex++) {
          const auto &primitive = mesh.primitives[primitiveIndex];
          const auto &meshPrimitive =
              data.meshPrimitiveAt(meshIndex, primitiveIndex);

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
            SCNMaterial *scnMaterial = self.scnMaterials[*primitive.material];
            geometry.materials = @[ scnMaterial ];
          }

          SCNMorpher *morpher;
          if (primitive.targets.has_value()) {
            morpher = [SCNMorpher new];

            NSMutableArray<SCNGeometry *> *morphTargets =
                [NSMutableArray arrayWithCapacity:primitive.targets->size()];
            //            for (const auto &target : *primitive.targets) {
            for (uint32_t targetIndex = 0;
                 targetIndex < primitive.targets->size(); targetIndex++) {
              const auto primitiveSources = meshPrimitive.targets[targetIndex];
              NSArray<SCNGeometrySource *> *sources = [self
                  scnGeometrySourcesFromMeshPrimitiveSources:primitiveSources];
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
      }

      [scnNodes addObject:scnNode];
    }

    for (int i = 0; i < data.json().nodes->size(); i++) {
      const auto &node = data.json().nodes->at(i);
      SCNNode *scnNode = scnNodes[i];

      if (node.children.has_value()) {
        for (auto childIndex : *node.children) {
          SCNNode *childNode = scnNodes[childIndex];
          [scnNode addChildNode:childNode];
        }
      }

      if (node.skin.has_value()) {
        const auto &skin = data.json().skins->at(*node.skin);

        NSMutableArray<SCNNode *> *bones =
            [NSMutableArray arrayWithCapacity:skin.joints.size()];
        for (auto joint : skin.joints) {
          SCNNode *bone = scnNodes[joint];
          [bones addObject:bone];
        }

        NSArray<NSValue *> *boneInverseBindTransforms;
        if (skin.inverseBindMatrices.has_value()) {
          const auto accessorIndex = *skin.inverseBindMatrices;
          const auto &accessor = data.json().accessors->at(accessorIndex);
          const auto &buffer = data.accessorBufferAt(accessorIndex).buffer;
          assert(accessor.type == gltf2::GLTFAccessor::Type::MAT4 &&
                 accessor.componentType ==
                     gltf2::GLTFAccessor::ComponentType::FLOAT);
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
        for (uint32_t primitiveIndex = 0;
             primitiveIndex < mesh.primitives.size(); primitiveIndex++) {
          const auto &primitive = mesh.primitives[primitiveIndex];
          const auto &meshPrimitive =
              data.meshPrimitiveAt(meshIndex, primitiveIndex);

          SCNNode *geometryNode;
          if (mesh.primitives.size() > 1) {
            geometryNode = scnNode.childNodes[primitiveIndex];
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

  if (data.json().animations.has_value()) {
    for (const auto &animation : *data.json().animations) {
      NSMutableArray *channelAnimations = [NSMutableArray array];
      float maxDuration = 1.0f;

      for (const auto &channel : animation.channels) {
        if (!channel.target.node.has_value())
          continue;

        const auto &node = data.json().nodes->at(*channel.target.node);
        SCNNode *scnNode = scnNodes[*channel.target.node];

        const auto &sampler = animation.samplers[channel.sampler];

        float maxKeyTime = 1.0f;
        NSArray<NSNumber *> *keyTimes =
            [self keyTimesFromAnimationSampler:sampler
                                    maxKeyTime:&maxKeyTime
                                          data:data];
        maxDuration = MAX(maxDuration, maxKeyTime);

        const auto &outputAccessor = data.json().accessors->at(sampler.output);
        const auto &accessorBuffer = data.accessorBufferAt(sampler.output);
        bool normalized = accessorBuffer.normalized;
        const auto &outputData = accessorBuffer.buffer;

        if (channel.target.path ==
            gltf2::GLTFAnimationChannelTarget::Path::WEIGHTS) {
          // Weights animation
          NSArray<NSNumber *> *numbers = NSArrayFromPackedFloatData(outputData);

          const auto &mesh = data.json().meshes->at(*node.mesh);

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
  if (data.json().scenes.has_value()) {
    for (const auto &scene : *data.json().scenes) {
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

class SurfaceShaderModifierBuilder {
public:
  bool transparent;
  bool hasBaseColorTexture;
  bool enableDiffuseAlphaCutoff;
  bool isDiffuseOpaque;
  bool enableAnisotropy;
  bool hasAnisotropyTexture;
  bool enableSheen;
  bool hasSheenColorTexture;
  bool hasSheenRoughnessTexture;

  SurfaceShaderModifierBuilder()
      : transparent(false), hasBaseColorTexture(false),
        enableDiffuseAlphaCutoff(false), isDiffuseOpaque(false),
        enableAnisotropy(false), hasAnisotropyTexture(false),
        enableSheen(false), hasSheenColorTexture(false),
        hasSheenRoughnessTexture(false) {}

  NSString *buildShader() {
    NSMutableString *shader = [NSMutableString string];

    if (transparent) {
      [shader appendString:@"#pragma transparent\n"];
    }

    NSArray<NSString *> *uniforms = @[
      @"vec4  diffuseBaseColorFactor",
      @"float diffuseAlphaCutoff",

      @"float anisotropyStrength",
      @"float anisotropyRotation",
      @"sampler2D anisotropyTexture",

      @"vec3  sheenColorFactor",
      @"float sheenRoughnessFactor",
      @"sampler2D sheenColorTexture",
      @"sampler2D sheenRoughnessTexture",

      @"float emissiveStrength",

      @"float ior",
    ];
    for (NSString *uniform in uniforms) {
      [shader appendString:[@[ @"uniform ", uniform, @";" ]
                               componentsJoinedByString:@""]];
    }

    [shader appendString:@"\n"
                          "vec3 F_Schlick(vec3 f0, vec3 f90, float VdotH) {"
                          "  return f0 + (f90 - f0) * pow("
                          "    clamp(1.0 - VdotH, 0.0, 1.0), 5.0"
                          "  );"
                          "}"
                          "\n"];

    // anisotropy
    [shader
        appendFormat:
            @"\n"
             "float D_GGX_anisotropic("
             "  float NdotH, float TdotH, float BdotH,"
             "  float at, float ab"
             ") {"
             "  float a2 = at * ab;"
             "  vec3 f = vec3(ab * TdotH, at * BdotH, a2 * NdotH);"
             "  float w2 = a2 / dot(f, f);"
             "  return a2 * w2 * w2 / %f;"
             "}"
             "\n"
             "float V_GGX_anisotropic("
             "  float NdotL, float NdotV, float BdotV, "
             "  float TdotV, float TdotL, float BdotL, float at, float ab"
             ") {"
             "  float GGXV = NdotL * length("
             "    vec3(at * TdotV, ab * BdotV, NdotV)"
             "  );"
             "  float GGXL = NdotV * length("
             "    vec3(at * TdotL, ab * BdotL, NdotL)"
             "  );"
             "  float v = 0.5 / (GGXV + GGXL);"
             "  return clamp(v, 0.0, 1.0);"
             "}"
             "\n"
             "vec3 BRDF_specularAnisotropicGGX("
             "  vec3 f0, vec3 f90, float alphaRoughness,"
             "  float VdotH, float NdotL, float NdotV, "
             "  float NdotH, float BdotV, float TdotV,"
             "  float TdotL, float BdotL, float TdotH, "
             "  float BdotH, float anisotropy"
             ") {"
             "  float at = mix(alphaRoughness, 1.0, anisotropy * anisotropy);"
             "  float ab = alphaRoughness;"
             "  vec3 F = F_Schlick(f0, f90, VdotH);"
             "  float V = V_GGX_anisotropic("
             "    NdotL, NdotV, BdotV, TdotV,"
             "    TdotL, BdotL, at, ab"
             "  );"
             "  float D = D_GGX_anisotropic(NdotH, TdotH, BdotH, at, ab);"
             "  return F * V * D * %f * NdotL;"
             "}"
             "\n",
            M_PI, M_PI];

    // sheen
    // Charlie distribution and Ashikhmin visibility
    [shader
        appendFormat:
            @"\n"
             "float D_Sheen(float alphaG, float NdotH) {"
             "  float invR = 1. / alphaG;"
             "  float cos2h = NdotH * NdotH;"
             "  float sin2h = 1. - cos2h;"
             "  return (2. + invR) * pow(sin2h, invR * .5) / (2. * %f);"
             "}"
             "\n"
             "float l(float x, float alphaG) {"
             "  float oneMinusAlphaSq = (1.0 - alphaG) * (1.0 - alphaG);"
             "  float a = mix(21.5473, 25.3245, oneMinusAlphaSq);"
             "  float b = mix(3.82987, 3.32435, oneMinusAlphaSq);"
             "  float c = mix(0.19823, 0.16801, oneMinusAlphaSq);"
             "  float d = mix(-1.97760, -1.27393, oneMinusAlphaSq);"
             "  float e = mix(-4.32054, -4.85967, oneMinusAlphaSq);"
             "  return a / (1.0 + b * pow(x, c)) + d * x + e;"
             "}"
             "\n"
             "float lambdaSheen(float cosTheta, float alphaG) {"
             "  if (abs(cosTheta) < 0.5) {"
             "    return exp(l(cosTheta, alphaG));"
             "  } else {"
             "    return exp(2.0 * l(0.5, alphaG) - "
             "l(1.0 - cosTheta, alphaG));"
             "  }"
             "}"
             "\n"
             "float V_Sheen(float alphaG, float NdotV, float NdotL) {"
             "  return clamp(1.0 / ((1.0 + lambdaSheen(NdotV, alphaG) + "
             "lambdaSheen(NdotL, alphaG)) * (4.0 * NdotV * NdotL)), 0.0, 1.0);"
             "}"
             "\n"
             "\n"
             "vec3 BRDF_specularSheen("
             "  float sheenRoughness, "
             "  float NdotL, float NdotV, float NdotH "
             ") {"
             "  float roughness = max(sheenRoughness, 0.000001);"
             "  float alphaG = roughness * roughness;"
             "  float D = D_Sheen(alphaG, NdotH);"
             "  float V = V_Sheen(alphaG, NdotV, NdotL);"
             "  return D * V * %f * NdotL;"
             "}"
             "\n",
            M_PI, M_PI];

    // Body
    [shader appendString:@"#pragma body\n"];

    [shader appendString:@"vec3 f0 = vec3(pow((ior - 1)/(ior + 1), 2));"
                          "vec3 f90 = vec3(1.0);"
                          "float metalness = _surface.metalness;"
                          "float roughness = _surface.roughness;"
                          "float alphaRoughness = 0.0;"
                          "vec4 baseColor = _surface.diffuse;"
                          "_surface.emission *= emissiveStrength;"];

    if (hasBaseColorTexture) {
      [shader appendString:@"baseColor *= diffuseBaseColorFactor;"];
    }

    [shader appendString:@"alphaRoughness = roughness * roughness;"
                          "f0 = mix(f0, baseColor.rgb, metalness);"];

    if (enableAnisotropy) {
      [shader appendString:@"if (true) {"
                            "  vec2 u_AnisotropyRotation = vec2("
                            "    cos(anisotropyRotation),"
                            "    sin(anisotropyRotation)"
                            "  );"
                            "  vec2 direction = u_AnisotropyRotation;"
                            "  float anisotropy = anisotropyStrength;"];
      if (hasAnisotropyTexture) {
        [shader
            appendString:@"  vec3 anisotropyTex = texture2D("
                          "    anisotropyTexture, "
                          "    _surface.diffuseTexcoord" // surface modifier
                                                         // cannot
                          // get texcoords. so we use
                          // diffuseTexcoord instead
                          "  ).rgb;"
                          "  direction = anisotropyTex.rg * 2.0 - vec2(1.0);"
                          "  direction = mat2(u_AnisotropyRotation.x,"
                          "                   u_AnisotropyRotation.y,"
                          "                   -u_AnisotropyRotation.y,"
                          "                   u_AnisotropyRotation.x"
                          "  ) * normalize(direction);"
                          "  anisotropy = anisotropyTex.b;"];
      }
      [shader
          appendString:
              @"  vec3 N = normalize(_surface.normal);"
               "  vec3 V = normalize(_surface.view);"
               "  vec3 L = normalize(scn_lights[0].pos - _surface.position);"
               "  vec3 H = normalize(V + L);"
               "  vec3 T = normalize(_surface.tangent);"
               "  vec3 B = normalize(cross(N, T));"
               "  mat3 TBN = mat3(T, B, N);"
               "  vec3 anisotropicT = normalize(TBN * vec3(direction, 0.0));"
               "  vec3 anisotropicB = normalize(cross(N, anisotropicT));"
               "  float VdotH = max(dot(V, H), 0.0);\n"
               "  float NdotL = max(dot(N, L), 0.0);\n"
               "  float NdotV = max(dot(N, V), 0.0);\n"
               "  float NdotH = max(dot(N, H), 0.0);\n"
               "  float BdotV = max(dot(anisotropicB, V), 0.0);\n"
               "  float TdotV = max(dot(anisotropicT, V), 0.0);\n"
               "  float TdotL = max(dot(anisotropicT, L), 0.0);\n"
               "  float BdotL = max(dot(anisotropicB, L), 0.0);\n"
               "  float TdotH = max(dot(anisotropicT, H), 0.0);\n"
               "  float BdotH = max(dot(anisotropicB, H), 0.0);\n"
               "  vec3 brdf = BRDF_specularAnisotropicGGX("
               "    f0, f90, alphaRoughness,"
               "    VdotH, NdotL, NdotV, "
               "    NdotH, BdotV, TdotV, "
               "    TdotL, BdotL, TdotH, "
               "    BdotH, anisotropy"
               "  );\n"
               "  baseColor.rgb += brdf;"
               "}"
               "\n"];
    }

    if (enableSheen) {
      [shader
          appendString:
              @"if (true) {"
               "  vec3 N = normalize(_surface.normal);"
               "  vec3 V = normalize(_surface.view);"
               "  vec3 L = normalize(scn_lights[0].pos - _surface.position);"
               "  vec3 H = normalize(V + L);"
               "  float NdotL = max(dot(N, L), 0.0);"
               "  float NdotV = max(dot(N, V), 0.0);"
               "  float NdotH = max(dot(N, H), 0.0);"
               "  float VdotH = max(dot(V, H), 0.0);"
               "  vec3 sheenColor = sheenColorFactor;"
               "  float sheenRoughness = sheenRoughnessFactor;\n"];

      if (hasSheenColorTexture) {
        [shader appendString:
                    @"  sheenColor = texture2D("
                     "    sheenColorTexture, "
                     "    _surface.diffuseTexcoord" // surface modifier cannot
                                                    // get texcoords. so we use
                                                    // diffuseTexcoord instead
                     "  ).rgb;"
                     "  sheenColor *= sheenColorFactor;"];
      }
      if (hasSheenRoughnessTexture) {
        [shader appendString:
                    @"  sheenRoughness = texture2D("
                     "    sheenRoughnessTexture, "
                     "    _surface.diffuseTexcoord" // surface modifier cannot
                                                    // get texcoords. so we use
                                                    // diffuseTexcoord instead
                     "  ).a;"
                     "  sheenRoughness *= sheenRoughnessFactor;"];
      }

      [shader appendString:@"\n"
                            "  vec3 sheen_brdf = BRDF_specularSheen("
                            "    sheenRoughness,"
                            "    NdotL, NdotV, NdotH"
                            "  );"
                            "  baseColor.rgb += sheenColor * sheen_brdf;"
                            "}\n"];
    }
    [shader appendString:@"_surface.diffuse = baseColor;"
                          "_surface.metalness = metalness;"
                          "_surface.roughness = roughness;"];

    if (isDiffuseOpaque) {
      [shader appendString:@"_surface.diffuse.a = 1.0;"];
    } else if (enableDiffuseAlphaCutoff) {
      [shader appendString:@"_surface.diffuse.a = _surface.diffuse.a < "
                            "diffuseAlphaCutoff ? 0.0 : 1.0;"];
    }
    return shader;
  }
};

- (SCNMatrix4)contentsTransformFromKHRTextureTransform:
    (const gltf2::KHRTextureTransform &)transform {
  auto scale = transform.scaleValue();
  auto rotation = transform.rotationValue();
  auto offset = transform.offsetValue();
  SCNMatrix4 t = SCNMatrix4MakeTranslation(offset[0], offset[1], 0);
  SCNMatrix4 r = SCNMatrix4MakeRotation(-rotation, 0, 0, 1);
  SCNMatrix4 s = SCNMatrix4MakeScale(scale[0], scale[1], 1);
  return SCNMatrix4Mult(SCNMatrix4Mult(s, r), t);
}

- (void)applyKHRTextureTransform:(const gltf2::KHRTextureTransform &)transform
                      toProperty:(SCNMaterialProperty *)property {
  if (transform.texCoord.has_value()) {
    property.mappingChannel = *transform.texCoord;
  }
  property.contentsTransform =
      [self contentsTransformFromKHRTextureTransform:transform];
}

- (nullable NSArray<SCNMaterial *> *)loadSCNMaterialsWithData:
    (const gltf2::GLTFData &)data {
  if (!data.json().materials)
    return nil;
  NSMutableArray<SCNMaterial *> *scnMaterials =
      [NSMutableArray arrayWithCapacity:data.json().materials->size()];

  for (auto &material : data.json().materials.value()) {
    SCNMaterial *scnMaterial = [SCNMaterial material];
    //    scnMaterial.name = material.name;
    scnMaterial.locksAmbientWithDiffuse = YES;
    if (material.isUnlit()) {
      scnMaterial.lightingModelName = SCNLightingModelConstant;
    } else if (material.pbrMetallicRoughness.has_value()) {
      scnMaterial.lightingModelName = SCNLightingModelPhysicallyBased;
    } else {
      scnMaterial.lightingModelName = SCNLightingModelBlinn;
    }

    SurfaceShaderModifierBuilder builder;

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
        gltf2::GLTFMaterialPBRMetallicRoughness());

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
      applyColorContentsToProperty(value[0], value[1], value[2], value[3],
                                   scnMaterial.diffuse);
    }

    // metallic & roughness
    if (pbrMetallicRoughness.metallicRoughnessTexture.has_value()) {
      [self applyTextureInfo:*pbrMetallicRoughness.metallicRoughnessTexture
               withIntensity:pbrMetallicRoughness.metallicFactorValue()
                  toProperty:scnMaterial.metalness
                        data:data];
      scnMaterial.metalness.textureComponents = SCNColorMaskBlue;

      [self applyTextureInfo:*pbrMetallicRoughness.metallicRoughnessTexture
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

    if (material.normalTexture.has_value()) {
      [self applyTextureInfo:*material.normalTexture
               withIntensity:material.normalTexture->scaleValue()
                  toProperty:scnMaterial.normal
                        data:data];
    }

    if (material.occlusionTexture.has_value()) {
      [self applyTextureInfo:*material.occlusionTexture
               withIntensity:material.occlusionTexture->strengthValue()
                  toProperty:scnMaterial.ambientOcclusion
                        data:data];
      scnMaterial.ambientOcclusion.textureComponents = SCNColorMaskRed;
    }

    if (material.emissiveTexture.has_value()) {
      [self applyTextureInfo:*material.emissiveTexture
               withIntensity:1.0f
                  toProperty:scnMaterial.emission
                        data:data];
    } else {
      auto value = material.emissiveFactorValue();
      applyColorContentsToProperty(value[0], value[1], value[2], 1.0,
                                   scnMaterial.emission);
    }
    if (material.emissiveStrength.has_value()) {
      emissiveStrength = material.emissiveStrength->emissiveStrengthValue();
    }

    if (material.alphaModeValue() == gltf2::GLTFMaterial::AlphaMode::OPAQUE) {
      scnMaterial.blendMode = SCNBlendModeReplace;
      builder.isDiffuseOpaque = true;
    } else if (material.alphaModeValue() ==
               gltf2::GLTFMaterial::AlphaMode::MASK) {
      scnMaterial.blendMode = SCNBlendModeReplace;
      diffuseAlphaCutoff = material.alphaCutoffValue();
      builder.enableDiffuseAlphaCutoff = true;
    } else if (material.alphaModeValue() ==
               gltf2::GLTFMaterial::AlphaMode::BLEND) {
      scnMaterial.blendMode = SCNBlendModeAlpha;
      scnMaterial.transparencyMode = SCNTransparencyModeDualLayer;
    }

    scnMaterial.doubleSided = material.isDoubleSided();

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

    if (material.sheen.has_value()) {
      std::array<float, 3> colorFactor =
          material.sheen->sheenColorFactorValue();
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

    if (material.specular.has_value()) {
      // TODO: specular
    }

    if (material.ior.has_value()) {
      ior = material.ior->iorValue();
    }

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
        [self
            applyTextureInfo:*material.clearcoat->clearcoatRoughnessTexture
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

    if (material.transmission.has_value()) {
      if (material.transmission->transmissionTexture.has_value()) {
        [self applyTextureInfo:*material.transmission->transmissionTexture
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
      SCNShaderModifierEntryPointSurface : builder.buildShader(),
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

- (CGImageRef)createCGImageFromData:(NSData *)data {
  CGImageSourceRef source =
      CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
  CGImageRef imageRef = CGImageSourceCreateImageAtIndex(source, 0, NULL);
  CFRelease(source);
  return imageRef;
}

- (CGImageRef)cgImageForImage:(uint32_t)index
                         data:(const gltf2::GLTFData &)data {
  const auto &buffer = data.imageBufferAt(index);
  return [self createCGImageFromData:[NSData dataWithBytes:buffer.data()
                                                    length:buffer.size()]];
}

- (void)applyTexture:(const gltf2::GLTFTexture &)texture
          toProperty:(SCNMaterialProperty *)property
                data:(const gltf2::GLTFData &)data {
  property.wrapS = SCNWrapModeRepeat;
  property.wrapT = SCNWrapModeRepeat;
  property.magnificationFilter = SCNFilterModeNone;
  property.minificationFilter = SCNFilterModeNone;
  property.mipFilter = SCNFilterModeNone;

  if (texture.source.has_value()) {
    property.contents =
        (__bridge id)[self cgImageForImage:*texture.source data:data];
  }

  if (texture.sampler.has_value()) {
    auto &sampler = data.json().samplers->at(*texture.sampler);
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

- (nullable NSArray<SCNCamera *> *)loadSCNCamerasWithData:
    (const gltf2::GLTFData &)data {
  if (!data.json().cameras.has_value())
    return nil;

  NSMutableArray<SCNCamera *> *scnCameras =
      [NSMutableArray arrayWithCapacity:data.json().cameras->size()];
  for (const auto &camera : *data.json().cameras) {
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
  NSData *data = [NSData dataWithBytes:source.buffer.data()
                                length:source.buffer.size()];
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

- (NSArray<NSNumber *> *)
    keyTimesFromAnimationSampler:(const gltf2::GLTFAnimationSampler &)sampler
                      maxKeyTime:(float *)maxKeyTime
                            data:(const gltf2::GLTFData &)data {
  const auto &inputAccessor = data.json().accessors->at(sampler.input);
  // input must be scalar type with float
  assert(inputAccessor.type == gltf2::GLTFAccessor::Type::SCALAR &&
         inputAccessor.componentType ==
             gltf2::GLTFAccessor::ComponentType::FLOAT);
  const auto &inputData =
      data.accessorBufferAt(sampler.input)
          .buffer; // data.binaryForAccessor(inputAccessor, nil);
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

NSArray<NSValue *> *
SCNVec4ArrayFromPackedFloatDataWithAccessor(const gltf2::Buffer &buffer,
                                            const gltf2::GLTFAccessor &accessor,
                                            BOOL isCubisSpline) {
  NSInteger count = isCubisSpline ? accessor.count / 3 : accessor.count;
  NSMutableArray<NSValue *> *values = [NSMutableArray arrayWithCapacity:count];
  float *bytes = (float *)buffer.data();
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
SCNVec3ArrayFromPackedFloatDataWithAccessor(const gltf2::Buffer &buffer,
                                            const gltf2::GLTFAccessor &accessor,
                                            BOOL isCubisSpline) {
  NSInteger count = isCubisSpline ? accessor.count / 3 : accessor.count;
  NSMutableArray<NSValue *> *values = [NSMutableArray arrayWithCapacity:count];
  float *bytes = (float *)buffer.data();
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
