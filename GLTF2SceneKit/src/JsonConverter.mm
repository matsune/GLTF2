#import "JsonConverter.h"

@implementation JsonConverter

+ (GLTFAccessorSparseIndicesComponentType)
    convertGLTFAccessorSparseIndicesComponentType:
        (gltf2::json::AccessorSparseIndices::ComponentType)componentType {
  switch (componentType) {
  case gltf2::json::AccessorSparseIndices::ComponentType::UNSIGNED_BYTE:
    return GLTFAccessorSparseIndicesComponentTypeUnsignedByte;
  case gltf2::json::AccessorSparseIndices::ComponentType::UNSIGNED_SHORT:
    return GLTFAccessorSparseIndicesComponentTypeUnsignedShort;
  case gltf2::json::AccessorSparseIndices::ComponentType::UNSIGNED_INT:
    return GLTFAccessorSparseIndicesComponentTypeUnsignedInt;
  }
}

+ (GLTFAccessorSparse *)convertGLTFAccessorSparse:
    (const gltf2::json::AccessorSparse &)cppSparse {
  GLTFAccessorSparse *objcSparse = [[GLTFAccessorSparse alloc] init];
  objcSparse.count = cppSparse.count;

  GLTFAccessorSparseIndices *objcIndices =
      [[GLTFAccessorSparseIndices alloc] init];
  objcIndices.bufferView = cppSparse.indices.bufferView;
  if (cppSparse.indices.byteOffset.has_value()) {
    objcIndices.byteOffset = @(cppSparse.indices.byteOffset.value());
  }
  objcIndices.componentType =
      [self convertGLTFAccessorSparseIndicesComponentType:cppSparse.indices
                                                              .componentType];
  objcSparse.indices = objcIndices;

  GLTFAccessorSparseValues *objcValues =
      [[GLTFAccessorSparseValues alloc] init];
  objcValues.bufferView = cppSparse.values.bufferView;
  if (cppSparse.values.byteOffset.has_value()) {
    objcValues.byteOffset = @(cppSparse.values.byteOffset.value());
  }
  objcSparse.values = objcValues;

  return objcSparse;
}

+ (GLTFAccessorComponentType)convertGLTFAccessorComponentType:
    (gltf2::json::Accessor::ComponentType)componentType {
  switch (componentType) {
  case gltf2::json::Accessor::ComponentType::BYTE:
    return GLTFAccessorComponentTypeByte;
  case gltf2::json::Accessor::ComponentType::UNSIGNED_BYTE:
    return GLTFAccessorComponentTypeUnsignedByte;
  case gltf2::json::Accessor::ComponentType::SHORT:
    return GLTFAccessorComponentTypeShort;
  case gltf2::json::Accessor::ComponentType::UNSIGNED_SHORT:
    return GLTFAccessorComponentTypeUnsignedShort;
  case gltf2::json::Accessor::ComponentType::UNSIGNED_INT:
    return GLTFAccessorComponentTypeUnsignedInt;
  case gltf2::json::Accessor::ComponentType::FLOAT:
    return GLTFAccessorComponentTypeFloat;
  default:
    return GLTFAccessorComponentTypeByte; // Default case
  }
}

+ (NSString *)convertGLTFAccessorType:(gltf2::json::Accessor::Type)type {
  switch (type) {
  case gltf2::json::Accessor::Type::SCALAR:
    return GLTFAccessorTypeScalar;
  case gltf2::json::Accessor::Type::VEC2:
    return GLTFAccessorTypeVec2;
  case gltf2::json::Accessor::Type::VEC3:
    return GLTFAccessorTypeVec3;
  case gltf2::json::Accessor::Type::VEC4:
    return GLTFAccessorTypeVec4;
  case gltf2::json::Accessor::Type::MAT2:
    return GLTFAccessorTypeMat2;
  case gltf2::json::Accessor::Type::MAT3:
    return GLTFAccessorTypeMat3;
  case gltf2::json::Accessor::Type::MAT4:
    return GLTFAccessorTypeMat4;
  default:
    return GLTFAccessorTypeScalar; // Default case
  }
}

+ (GLTFAccessor *)convertGLTFAccessor:
    (const gltf2::json::Accessor &)cppAccessor {
  GLTFAccessor *objcAccessor = [[GLTFAccessor alloc] init];

  if (cppAccessor.bufferView.has_value()) {
    objcAccessor.bufferView = @(cppAccessor.bufferView.value());
  }
  if (cppAccessor.byteOffset.has_value()) {
    objcAccessor.byteOffset = @(cppAccessor.byteOffset.value());
  }
  objcAccessor.componentType =
      [self convertGLTFAccessorComponentType:cppAccessor.componentType];

  objcAccessor.normalized = cppAccessor.normalized.value_or(false);
  objcAccessor.count = cppAccessor.count;
  objcAccessor.type = [self convertGLTFAccessorType:cppAccessor.type];

  if (cppAccessor.max.has_value()) {
    NSMutableArray<NSNumber *> *maxArray =
        [NSMutableArray arrayWithCapacity:cppAccessor.max->size()];
    for (const auto &value : cppAccessor.max.value()) {
      [maxArray addObject:@(value)];
    }
    objcAccessor.max = [maxArray copy];
  }

  if (cppAccessor.min.has_value()) {
    NSMutableArray<NSNumber *> *minArray =
        [NSMutableArray arrayWithCapacity:cppAccessor.min->size()];
    for (const auto &value : cppAccessor.min.value()) {
      [minArray addObject:@(value)];
    }
    objcAccessor.min = [minArray copy];
  }

  if (cppAccessor.sparse.has_value()) {
    objcAccessor.sparse =
        [self convertGLTFAccessorSparse:cppAccessor.sparse.value()];
  }

  if (cppAccessor.name.has_value()) {
    objcAccessor.name =
        [NSString stringWithUTF8String:cppAccessor.name->c_str()];
  }

  return objcAccessor;
}

+ (NSString *)convertGLTFAnimationChannelTargetPath:
    (gltf2::json::AnimationChannelTarget::Path)path {
  switch (path) {
  case gltf2::json::AnimationChannelTarget::Path::TRANSLATION:
    return GLTFAnimationChannelTargetPathTranslation;
  case gltf2::json::AnimationChannelTarget::Path::ROTATION:
    return GLTFAnimationChannelTargetPathRotation;
  case gltf2::json::AnimationChannelTarget::Path::SCALE:
    return GLTFAnimationChannelTargetPathScale;
  case gltf2::json::AnimationChannelTarget::Path::WEIGHTS:
    return GLTFAnimationChannelTargetPathWeights;
  default:
    return GLTFAnimationChannelTargetPathTranslation;
  }
}

+ (NSString *)convertGLTFAnimationSamplerInterpolation:
    (gltf2::json::AnimationSampler::Interpolation)interpolation {
  switch (interpolation) {
  case gltf2::json::AnimationSampler::Interpolation::LINEAR:
    return GLTFAnimationSamplerInterpolationLinear;
  case gltf2::json::AnimationSampler::Interpolation::STEP:
    return GLTFAnimationSamplerInterpolationStep;
  case gltf2::json::AnimationSampler::Interpolation::CUBICSPLINE:
    return GLTFAnimationSamplerInterpolationCubicSpline;
  default:
    return GLTFAnimationSamplerInterpolationLinear;
  }
}

+ (GLTFAnimationChannelTarget *)convertGLTFAnimationChannelTarget:
    (const gltf2::json::AnimationChannelTarget &)cppTarget {
  GLTFAnimationChannelTarget *objcTarget =
      [[GLTFAnimationChannelTarget alloc] init];
  if (cppTarget.node.has_value()) {
    objcTarget.node = @(cppTarget.node.value());
  }
  objcTarget.path = [self convertGLTFAnimationChannelTargetPath:cppTarget.path];
  return objcTarget;
}

+ (GLTFAnimationChannel *)convertGLTFAnimationChannel:
    (const gltf2::json::AnimationChannel &)cppChannel {
  GLTFAnimationChannel *objcChannel = [[GLTFAnimationChannel alloc] init];
  objcChannel.sampler = cppChannel.sampler;
  objcChannel.target =
      [self convertGLTFAnimationChannelTarget:cppChannel.target];
  return objcChannel;
}

+ (GLTFAnimationSampler *)convertGLTFAnimationSampler:
    (const gltf2::json::AnimationSampler &)cppSampler {
  GLTFAnimationSampler *objcSampler = [[GLTFAnimationSampler alloc] init];
  objcSampler.input = cppSampler.input;
  objcSampler.interpolation = [self
      convertGLTFAnimationSamplerInterpolation:cppSampler.interpolationValue()];
  objcSampler.output = cppSampler.output;
  return objcSampler;
}

+ (GLTFAnimation *)convertGLTFAnimation:
    (const gltf2::json::Animation &)cppAnimation {
  GLTFAnimation *objcAnimation = [[GLTFAnimation alloc] init];

  NSMutableArray<GLTFAnimationChannel *> *objcChannels =
      [NSMutableArray arrayWithCapacity:cppAnimation.channels.size()];
  for (const auto &cppChannel : cppAnimation.channels) {
    [objcChannels addObject:[self convertGLTFAnimationChannel:cppChannel]];
  }
  objcAnimation.channels = [objcChannels copy];

  NSMutableArray<GLTFAnimationSampler *> *objcSamplers =
      [NSMutableArray arrayWithCapacity:cppAnimation.samplers.size()];
  for (const auto &cppSampler : cppAnimation.samplers) {
    [objcSamplers addObject:[self convertGLTFAnimationSampler:cppSampler]];
  }
  objcAnimation.samplers = [objcSamplers copy];

  if (cppAnimation.name.has_value()) {
    objcAnimation.name =
        [NSString stringWithUTF8String:cppAnimation.name->c_str()];
  }

  return objcAnimation;
}

+ (GLTFAsset *)convertGLTFAsset:(const gltf2::json::Asset &)cppAsset {
  GLTFAsset *objcAsset = [[GLTFAsset alloc] init];

  if (cppAsset.copyright.has_value()) {
    objcAsset.copyright =
        [NSString stringWithUTF8String:cppAsset.copyright->c_str()];
  }
  if (cppAsset.generator.has_value()) {
    objcAsset.generator =
        [NSString stringWithUTF8String:cppAsset.generator->c_str()];
  }
  objcAsset.version = [NSString stringWithUTF8String:cppAsset.version.c_str()];
  if (cppAsset.minVersion.has_value()) {
    objcAsset.minVersion =
        [NSString stringWithUTF8String:cppAsset.minVersion->c_str()];
  }

  return objcAsset;
}

+ (GLTFBuffer *)convertGLTFBuffer:(const gltf2::json::Buffer &)cppBuffer {
  GLTFBuffer *objcBuffer = [[GLTFBuffer alloc] init];

  if (cppBuffer.uri.has_value()) {
    objcBuffer.uri = [NSString stringWithUTF8String:cppBuffer.uri->c_str()];
  }
  objcBuffer.byteLength = cppBuffer.byteLength;
  if (cppBuffer.name.has_value()) {
    objcBuffer.name = [NSString stringWithUTF8String:cppBuffer.name->c_str()];
  }

  return objcBuffer;
}

+ (GLTFBufferView *)convertGLTFBufferView:
    (const gltf2::json::BufferView &)cppBufferView {
  GLTFBufferView *objcBufferView = [[GLTFBufferView alloc] init];

  objcBufferView.buffer = cppBufferView.buffer;
  if (cppBufferView.byteOffset.has_value()) {
    objcBufferView.byteOffset = @(cppBufferView.byteOffset.value());
  }
  objcBufferView.byteLength = cppBufferView.byteLength;
  if (cppBufferView.byteStride.has_value()) {
    objcBufferView.byteStride = @(cppBufferView.byteStride.value());
  }
  if (cppBufferView.target.has_value()) {
    objcBufferView.target = @(cppBufferView.target.value());
  }
  if (cppBufferView.name.has_value()) {
    objcBufferView.name =
        [NSString stringWithUTF8String:cppBufferView.name->c_str()];
  }

  return objcBufferView;
}

+ (NSString *)convertGLTFCameraType:(gltf2::json::Camera::Type)type {
  switch (type) {
  case gltf2::json::Camera::Type::PERSPECTIVE:
    return GLTFCameraTypePerspective;
  case gltf2::json::Camera::Type::ORTHOGRAPHIC:
    return GLTFCameraTypeOrthographic;
  default:
    return GLTFCameraTypePerspective; // Default case
  }
}

+ (GLTFCameraOrthographic *)convertGLTFCameraOrthographic:
    (const gltf2::json::CameraOrthographic &)cppOrthographic {
  GLTFCameraOrthographic *objcOrthographic =
      [[GLTFCameraOrthographic alloc] init];
  objcOrthographic.xmag = cppOrthographic.xmag;
  objcOrthographic.ymag = cppOrthographic.ymag;
  objcOrthographic.zfar = cppOrthographic.zfar;
  objcOrthographic.znear = cppOrthographic.znear;
  return objcOrthographic;
}

+ (GLTFCameraPerspective *)convertGLTFCameraPerspective:
    (const gltf2::json::CameraPerspective &)cppPerspective {
  GLTFCameraPerspective *objcPerspective = [[GLTFCameraPerspective alloc] init];
  if (cppPerspective.aspectRatio.has_value()) {
    objcPerspective.aspectRatio = @(cppPerspective.aspectRatio.value());
  }
  objcPerspective.yfov = cppPerspective.yfov;
  if (cppPerspective.zfar.has_value()) {
    objcPerspective.zfar = @(cppPerspective.zfar.value());
  }
  objcPerspective.znear = cppPerspective.znear;
  return objcPerspective;
}

+ (GLTFCamera *)convertGLTFCamera:(const gltf2::json::Camera &)cppCamera {
  GLTFCamera *objcCamera = [[GLTFCamera alloc] init];

  objcCamera.type = [self convertGLTFCameraType:cppCamera.type];
  if (cppCamera.orthographic.has_value()) {
    objcCamera.orthographic =
        [self convertGLTFCameraOrthographic:cppCamera.orthographic.value()];
  }
  if (cppCamera.perspective.has_value()) {
    objcCamera.perspective =
        [self convertGLTFCameraPerspective:cppCamera.perspective.value()];
  }
  if (cppCamera.name.has_value()) {
    objcCamera.name = [NSString stringWithUTF8String:cppCamera.name->c_str()];
  }

  return objcCamera;
}

+ (NSString *)convertGLTFImageMimeType:(gltf2::json::Image::MimeType)mimeType {
  switch (mimeType) {
  case gltf2::json::Image::MimeType::JPEG:
    return GLTFImageMimeTypeJPEG;
  case gltf2::json::Image::MimeType::PNG:
    return GLTFImageMimeTypePNG;
  default:
    return GLTFImageMimeTypeJPEG; // Default case
  }
}

+ (GLTFImage *)convertGLTFImage:(const gltf2::json::Image &)cppImage {
  GLTFImage *objcImage = [[GLTFImage alloc] init];

  if (cppImage.uri.has_value()) {
    objcImage.uri = [NSString stringWithUTF8String:cppImage.uri->c_str()];
  }
  objcImage.mimeType =
      [self convertGLTFImageMimeType:cppImage.mimeType.value_or(
                                         gltf2::json::Image::MimeType::JPEG)];
  if (cppImage.bufferView.has_value()) {
    objcImage.bufferView = @(cppImage.bufferView.value());
  }
  if (cppImage.name.has_value()) {
    objcImage.name = [NSString stringWithUTF8String:cppImage.name->c_str()];
  }

  return objcImage;
}

+ (GLTFTexture *)convertGLTFTexture:(const gltf2::json::Texture &)cppTexture {
  GLTFTexture *objcTexture = [[GLTFTexture alloc] init];

  if (cppTexture.sampler.has_value()) {
    objcTexture.sampler = @(cppTexture.sampler.value());
  }
  if (cppTexture.source.has_value()) {
    objcTexture.source = @(cppTexture.source.value());
  }
  if (cppTexture.name.has_value()) {
    objcTexture.name = [NSString stringWithUTF8String:cppTexture.name->c_str()];
  }

  return objcTexture;
}

+ (KHRTextureTransform *)convertKHRTextureTransform:
    (const gltf2::json::KHRTextureTransform &)cppTextureTransform {
  KHRTextureTransform *objcTextureTransform =
      [[KHRTextureTransform alloc] init];

  if (cppTextureTransform.offset.has_value()) {
    objcTextureTransform.offset = @[
      @(cppTextureTransform.offset->at(0)), @(cppTextureTransform.offset->at(1))
    ];
  }
  if (cppTextureTransform.rotation.has_value()) {
    objcTextureTransform.rotation = @(cppTextureTransform.rotation.value());
  }
  if (cppTextureTransform.scale.has_value()) {
    objcTextureTransform.scale = @[
      @(cppTextureTransform.scale->at(0)), @(cppTextureTransform.scale->at(1))
    ];
  }
  if (cppTextureTransform.texCoord.has_value()) {
    objcTextureTransform.texCoord = @(cppTextureTransform.texCoord.value());
  }

  return objcTextureTransform;
}

+ (GLTFTextureInfo *)convertGLTFTextureInfo:
    (const gltf2::json::TextureInfo &)cppTextureInfo {
  GLTFTextureInfo *objcTextureInfo = [[GLTFTextureInfo alloc] init];

  objcTextureInfo.index = cppTextureInfo.index;
  if (cppTextureInfo.texCoord.has_value()) {
    objcTextureInfo.texCoord = @(cppTextureInfo.texCoord.value());
  }
  if (cppTextureInfo.khrTextureTransform.has_value()) {
    objcTextureInfo.khrTextureTransform = [self
        convertKHRTextureTransform:cppTextureInfo.khrTextureTransform.value()];
  }

  return objcTextureInfo;
}

+ (GLTFMaterialPBRMetallicRoughness *)convertGLTFMaterialPBRMetallicRoughness:
    (const gltf2::json::MaterialPBRMetallicRoughness &)cppMaterial {
  GLTFMaterialPBRMetallicRoughness *objcMaterial =
      [[GLTFMaterialPBRMetallicRoughness alloc] init];

  if (cppMaterial.baseColorFactor.has_value()) {
    objcMaterial.baseColorFactor = @[
      @(cppMaterial.baseColorFactor->at(0)),
      @(cppMaterial.baseColorFactor->at(1)),
      @(cppMaterial.baseColorFactor->at(2)),
      @(cppMaterial.baseColorFactor->at(3))
    ];
  }
  if (cppMaterial.baseColorTexture.has_value()) {
    objcMaterial.baseColorTexture =
        [self convertGLTFTextureInfo:cppMaterial.baseColorTexture.value()];
  }
  if (cppMaterial.metallicFactor.has_value()) {
    objcMaterial.metallicFactor = @(cppMaterial.metallicFactor.value());
  }
  if (cppMaterial.roughnessFactor.has_value()) {
    objcMaterial.roughnessFactor = @(cppMaterial.roughnessFactor.value());
  }
  if (cppMaterial.metallicRoughnessTexture.has_value()) {
    objcMaterial.metallicRoughnessTexture = [self
        convertGLTFTextureInfo:cppMaterial.metallicRoughnessTexture.value()];
  }

  return objcMaterial;
}

+ (GLTFMaterialNormalTextureInfo *)convertGLTFMaterialNormalTextureInfo:
    (const gltf2::json::MaterialNormalTextureInfo &)cppNormalTextureInfo {
  GLTFMaterialNormalTextureInfo *objcNormalTextureInfo =
      [[GLTFMaterialNormalTextureInfo alloc] init];

  objcNormalTextureInfo.index = cppNormalTextureInfo.index;
  if (cppNormalTextureInfo.texCoord.has_value()) {
    objcNormalTextureInfo.texCoord = @(cppNormalTextureInfo.texCoord.value());
  }
  if (cppNormalTextureInfo.scale.has_value()) {
    objcNormalTextureInfo.scale = @(cppNormalTextureInfo.scale.value());
  }

  return objcNormalTextureInfo;
}

+ (GLTFMaterialOcclusionTextureInfo *)convertGLTFMaterialOcclusionTextureInfo:
    (const gltf2::json::MaterialOcclusionTextureInfo &)cppOcclusionTextureInfo {
  GLTFMaterialOcclusionTextureInfo *objcOcclusionTextureInfo =
      [[GLTFMaterialOcclusionTextureInfo alloc] init];

  objcOcclusionTextureInfo.index = cppOcclusionTextureInfo.index;
  if (cppOcclusionTextureInfo.texCoord.has_value()) {
    objcOcclusionTextureInfo.texCoord =
        @(cppOcclusionTextureInfo.texCoord.value());
  }
  if (cppOcclusionTextureInfo.strength.has_value()) {
    objcOcclusionTextureInfo.strength =
        @(cppOcclusionTextureInfo.strength.value());
  }

  return objcOcclusionTextureInfo;
}

+ (KHRMaterialAnisotropy *)convertKHRMaterialAnisotropy:
    (const gltf2::json::KHRMaterialAnisotropy &)cppAnisotropy {
  KHRMaterialAnisotropy *objcAnisotropy = [[KHRMaterialAnisotropy alloc] init];

  if (cppAnisotropy.anisotropyStrength.has_value()) {
    objcAnisotropy.anisotropyStrength =
        @(cppAnisotropy.anisotropyStrength.value());
  }
  if (cppAnisotropy.anisotropyRotation.has_value()) {
    objcAnisotropy.anisotropyRotation =
        @(cppAnisotropy.anisotropyRotation.value());
  }
  if (cppAnisotropy.anisotropyTexture.has_value()) {
    objcAnisotropy.anisotropyTexture =
        [self convertGLTFTextureInfo:cppAnisotropy.anisotropyTexture.value()];
  }

  return objcAnisotropy;
}

+ (KHRMaterialSheen *)convertKHRMaterialSheen:
    (const gltf2::json::KHRMaterialSheen &)cppSheen {
  KHRMaterialSheen *objcSheen = [[KHRMaterialSheen alloc] init];

  if (cppSheen.sheenColorFactor.has_value()) {
    objcSheen.sheenColorFactor = @[
      @(cppSheen.sheenColorFactor->at(0)), @(cppSheen.sheenColorFactor->at(1)),
      @(cppSheen.sheenColorFactor->at(2))
    ];
  }
  if (cppSheen.sheenColorTexture.has_value()) {
    objcSheen.sheenColorTexture =
        [self convertGLTFTextureInfo:cppSheen.sheenColorTexture.value()];
  }
  if (cppSheen.sheenRoughnessFactor.has_value()) {
    objcSheen.sheenRoughnessFactor = @(cppSheen.sheenRoughnessFactor.value());
  }
  if (cppSheen.sheenRoughnessTexture.has_value()) {
    objcSheen.sheenRoughnessTexture =
        [self convertGLTFTextureInfo:cppSheen.sheenRoughnessTexture.value()];
  }

  return objcSheen;
}

+ (KHRMaterialSpecular *)convertKHRMaterialSpecular:
    (const gltf2::json::KHRMaterialSpecular &)cppSpecular {
  KHRMaterialSpecular *objcSpecular = [[KHRMaterialSpecular alloc] init];

  if (cppSpecular.specularFactor.has_value()) {
    objcSpecular.specularFactor = @(cppSpecular.specularFactor.value());
  }
  if (cppSpecular.specularTexture.has_value()) {
    objcSpecular.specularTexture =
        [self convertGLTFTextureInfo:cppSpecular.specularTexture.value()];
  }
  if (cppSpecular.specularColorFactor.has_value()) {
    objcSpecular.specularColorFactor = @[
      @(cppSpecular.specularColorFactor->at(0)),
      @(cppSpecular.specularColorFactor->at(1)),
      @(cppSpecular.specularColorFactor->at(2))
    ];
  }
  if (cppSpecular.specularColorTexture.has_value()) {
    objcSpecular.specularColorTexture =
        [self convertGLTFTextureInfo:cppSpecular.specularColorTexture.value()];
  }

  return objcSpecular;
}

+ (KHRMaterialIor *)convertKHRMaterialIor:
    (const gltf2::json::KHRMaterialIor &)cppIor {
  KHRMaterialIor *objcIor = [[KHRMaterialIor alloc] init];

  if (cppIor.ior.has_value()) {
    objcIor.ior = @(cppIor.ior.value());
  }

  return objcIor;
}

+ (KHRMaterialClearcoat *)convertKHRMaterialClearcoat:
    (const gltf2::json::KHRMaterialClearcoat &)cppClearcoat {
  KHRMaterialClearcoat *objcClearcoat = [[KHRMaterialClearcoat alloc] init];

  if (cppClearcoat.clearcoatFactor.has_value()) {
    objcClearcoat.clearcoatFactor = @(cppClearcoat.clearcoatFactor.value());
  }
  if (cppClearcoat.clearcoatTexture.has_value()) {
    objcClearcoat.clearcoatTexture =
        [self convertGLTFTextureInfo:cppClearcoat.clearcoatTexture.value()];
  }
  if (cppClearcoat.clearcoatRoughnessFactor.has_value()) {
    objcClearcoat.clearcoatRoughnessFactor =
        @(cppClearcoat.clearcoatRoughnessFactor.value());
  }
  if (cppClearcoat.clearcoatRoughnessTexture.has_value()) {
    objcClearcoat.clearcoatRoughnessTexture = [self
        convertGLTFTextureInfo:cppClearcoat.clearcoatRoughnessTexture.value()];
  }
  if (cppClearcoat.clearcoatNormalTexture.has_value()) {
    objcClearcoat.clearcoatNormalTexture = [self
        convertGLTFMaterialNormalTextureInfo:cppClearcoat.clearcoatNormalTexture
                                                 .value()];
  }

  return objcClearcoat;
}

+ (KHRMaterialDispersion *)convertKHRMaterialDispersion:
    (const gltf2::json::KHRMaterialDispersion &)cppDispersion {
  KHRMaterialDispersion *objcDispersion = [[KHRMaterialDispersion alloc] init];

  if (cppDispersion.dispersion.has_value()) {
    objcDispersion.dispersion = @(cppDispersion.dispersion.value());
  }

  return objcDispersion;
}

+ (KHRMaterialEmissiveStrength *)convertKHRMaterialEmissiveStrength:
    (const gltf2::json::KHRMaterialEmissiveStrength &)cppEmissiveStrength {
  KHRMaterialEmissiveStrength *objcEmissiveStrength =
      [[KHRMaterialEmissiveStrength alloc] init];

  if (cppEmissiveStrength.emissiveStrength.has_value()) {
    objcEmissiveStrength.emissiveStrength =
        @(cppEmissiveStrength.emissiveStrength.value());
  }

  return objcEmissiveStrength;
}

+ (KHRMaterialIridescence *)convertKHRMaterialIridescence:
    (const gltf2::json::KHRMaterialIridescence &)cppIridescence {
  KHRMaterialIridescence *objcIridescence =
      [[KHRMaterialIridescence alloc] init];

  if (cppIridescence.iridescenceFactor.has_value()) {
    objcIridescence.iridescenceFactor =
        @(cppIridescence.iridescenceFactor.value());
  }
  if (cppIridescence.iridescenceTexture.has_value()) {
    objcIridescence.iridescenceTexture =
        [self convertGLTFTextureInfo:cppIridescence.iridescenceTexture.value()];
  }
  if (cppIridescence.iridescenceIor.has_value()) {
    objcIridescence.iridescenceIor = @(cppIridescence.iridescenceIor.value());
  }
  if (cppIridescence.iridescenceThicknessMinimum.has_value()) {
    objcIridescence.iridescenceThicknessMinimum =
        @(cppIridescence.iridescenceThicknessMinimum.value());
  }
  if (cppIridescence.iridescenceThicknessMaximum.has_value()) {
    objcIridescence.iridescenceThicknessMaximum =
        @(cppIridescence.iridescenceThicknessMaximum.value());
  }
  if (cppIridescence.iridescenceThicknessTexture.has_value()) {
    objcIridescence.iridescenceThicknessTexture =
        [self convertGLTFTextureInfo:cppIridescence.iridescenceThicknessTexture
                                         .value()];
  }

  return objcIridescence;
}

+ (KHRMaterialVolume *)convertKHRMaterialVolume:
    (const gltf2::json::KHRMaterialVolume &)cppVolume {
  KHRMaterialVolume *objcVolume = [[KHRMaterialVolume alloc] init];

  if (cppVolume.thicknessFactor.has_value()) {
    objcVolume.thicknessFactor = @(cppVolume.thicknessFactor.value());
  }
  if (cppVolume.thicknessTexture.has_value()) {
    objcVolume.thicknessTexture =
        [self convertGLTFTextureInfo:cppVolume.thicknessTexture.value()];
  }
  if (cppVolume.attenuationDistance.has_value()) {
    objcVolume.attenuationDistance = @(cppVolume.attenuationDistance.value());
  }
  if (cppVolume.attenuationColor.has_value()) {
    objcVolume.attenuationColor = @[
      @(cppVolume.attenuationColor->at(0)),
      @(cppVolume.attenuationColor->at(1)), @(cppVolume.attenuationColor->at(2))
    ];
  }

  return objcVolume;
}

+ (KHRMaterialTransmission *)convertKHRMaterialTransmission:
    (const gltf2::json::KHRMaterialTransmission &)cppTransmission {
  KHRMaterialTransmission *objcTransmission =
      [[KHRMaterialTransmission alloc] init];

  if (cppTransmission.transmissionFactor.has_value()) {
    objcTransmission.transmissionFactor =
        @(cppTransmission.transmissionFactor.value());
  }
  if (cppTransmission.transmissionTexture.has_value()) {
    objcTransmission.transmissionTexture = [self
        convertGLTFTextureInfo:cppTransmission.transmissionTexture.value()];
  }

  return objcTransmission;
}

+ (NSString *)convertGLTFMaterialAlphaMode:
    (gltf2::json::Material::AlphaMode)alphaMode {
  switch (alphaMode) {
  case gltf2::json::Material::AlphaMode::OPAQUE:
    return GLTFMaterialAlphaModeOpaque;
  case gltf2::json::Material::AlphaMode::MASK:
    return GLTFMaterialAlphaModeMask;
  case gltf2::json::Material::AlphaMode::BLEND:
    return GLTFMaterialAlphaModeBlend;
  default:
    return GLTFMaterialAlphaModeOpaque; // Default case
  }
}

+ (GLTFMaterial *)convertGLTFMaterial:
    (const gltf2::json::Material &)cppMaterial {
  GLTFMaterial *objcMaterial = [[GLTFMaterial alloc] init];

  if (cppMaterial.name.has_value()) {
    objcMaterial.name =
        [NSString stringWithUTF8String:cppMaterial.name->c_str()];
  }
  if (cppMaterial.pbrMetallicRoughness.has_value()) {
    objcMaterial.pbrMetallicRoughness = [self
        convertGLTFMaterialPBRMetallicRoughness:cppMaterial.pbrMetallicRoughness
                                                    .value()];
  }
  if (cppMaterial.normalTexture.has_value()) {
    objcMaterial.normalTexture = [self
        convertGLTFMaterialNormalTextureInfo:cppMaterial.normalTexture.value()];
  }
  if (cppMaterial.occlusionTexture.has_value()) {
    objcMaterial.occlusionTexture = [self
        convertGLTFMaterialOcclusionTextureInfo:cppMaterial.occlusionTexture
                                                    .value()];
  }
  if (cppMaterial.emissiveTexture.has_value()) {
    objcMaterial.emissiveTexture =
        [self convertGLTFTextureInfo:cppMaterial.emissiveTexture.value()];
  }
  if (cppMaterial.emissiveFactor.has_value()) {
    objcMaterial.emissiveFactor = @[
      @(cppMaterial.emissiveFactor->at(0)),
      @(cppMaterial.emissiveFactor->at(1)), @(cppMaterial.emissiveFactor->at(2))
    ];
  }
  objcMaterial.alphaMode =
      [self convertGLTFMaterialAlphaMode:cppMaterial.alphaModeValue()];
  if (cppMaterial.alphaCutoff.has_value()) {
    objcMaterial.alphaCutoff = @(cppMaterial.alphaCutoff.value());
  }
  if (cppMaterial.doubleSided.has_value()) {
    objcMaterial.doubleSided = @(cppMaterial.doubleSided.value());
  }
  if (cppMaterial.anisotropy.has_value()) {
    objcMaterial.anisotropy =
        [self convertKHRMaterialAnisotropy:cppMaterial.anisotropy.value()];
  }
  if (cppMaterial.clearcoat.has_value()) {
    objcMaterial.clearcoat =
        [self convertKHRMaterialClearcoat:cppMaterial.clearcoat.value()];
  }
  if (cppMaterial.dispersion.has_value()) {
    objcMaterial.dispersion =
        [self convertKHRMaterialDispersion:cppMaterial.dispersion.value()];
  }
  if (cppMaterial.emissiveStrength.has_value()) {
    objcMaterial.emissiveStrength =
        [self convertKHRMaterialEmissiveStrength:cppMaterial.emissiveStrength
                                                     .value()];
  }
  if (cppMaterial.ior.has_value()) {
    objcMaterial.ior = [self convertKHRMaterialIor:cppMaterial.ior.value()];
  }
  if (cppMaterial.iridescence.has_value()) {
    objcMaterial.iridescence =
        [self convertKHRMaterialIridescence:cppMaterial.iridescence.value()];
  }
  if (cppMaterial.sheen.has_value()) {
    objcMaterial.sheen =
        [self convertKHRMaterialSheen:cppMaterial.sheen.value()];
  }
  if (cppMaterial.specular.has_value()) {
    objcMaterial.specular =
        [self convertKHRMaterialSpecular:cppMaterial.specular.value()];
  }
  if (cppMaterial.transmission.has_value()) {
    objcMaterial.transmission =
        [self convertKHRMaterialTransmission:cppMaterial.transmission.value()];
  }
  if (cppMaterial.unlit.has_value()) {
    objcMaterial.unlit = @(cppMaterial.unlit.value());
  }
  if (cppMaterial.volume.has_value()) {
    objcMaterial.volume =
        [self convertKHRMaterialVolume:cppMaterial.volume.value()];
  }

  return objcMaterial;
}

+ (GLTFMeshPrimitiveMode)convertGLTFMeshPrimitiveMode:
    (gltf2::json::MeshPrimitive::Mode)mode {
  switch (mode) {
  case gltf2::json::MeshPrimitive::Mode::POINTS:
    return GLTFMeshPrimitiveModePoints;
  case gltf2::json::MeshPrimitive::Mode::LINES:
    return GLTFMeshPrimitiveModeLines;
  case gltf2::json::MeshPrimitive::Mode::LINE_LOOP:
    return GLTFMeshPrimitiveModeLineLoop;
  case gltf2::json::MeshPrimitive::Mode::LINE_STRIP:
    return GLTFMeshPrimitiveModeLineStrip;
  case gltf2::json::MeshPrimitive::Mode::TRIANGLES:
    return GLTFMeshPrimitiveModeTriangles;
  case gltf2::json::MeshPrimitive::Mode::TRIANGLE_STRIP:
    return GLTFMeshPrimitiveModeTriangleStrip;
  case gltf2::json::MeshPrimitive::Mode::TRIANGLE_FAN:
    return GLTFMeshPrimitiveModeTriangleFan;
  default:
    return GLTFMeshPrimitiveModeTriangles; // Default case
  }
}

+ (GLTFMeshPrimitiveTarget *)convertGLTFMeshPrimitiveTarget:
    (const gltf2::json::MeshPrimitiveTarget &)cppTarget {
  GLTFMeshPrimitiveTarget *objcTarget = [[GLTFMeshPrimitiveTarget alloc] init];

  if (cppTarget.position.has_value()) {
    objcTarget.position = @(cppTarget.position.value());
  }
  if (cppTarget.normal.has_value()) {
    objcTarget.normal = @(cppTarget.normal.value());
  }
  if (cppTarget.tangent.has_value()) {
    objcTarget.tangent = @(cppTarget.tangent.value());
  }

  return objcTarget;
}

+ (GLTFMeshPrimitiveAttributes *)convertGLTFMeshPrimitiveAttributes:
    (const gltf2::json::MeshPrimitiveAttributes &)cppAttributes {
  GLTFMeshPrimitiveAttributes *objcAttributes =
      [[GLTFMeshPrimitiveAttributes alloc] init];

  if (cppAttributes.position.has_value()) {
    objcAttributes.position = @(cppAttributes.position.value());
  }
  if (cppAttributes.normal.has_value()) {
    objcAttributes.normal = @(cppAttributes.normal.value());
  }
  if (cppAttributes.tangent.has_value()) {
    objcAttributes.tangent = @(cppAttributes.tangent.value());
  }
  if (cppAttributes.texcoords.has_value()) {
    NSMutableArray *texcoords =
        [NSMutableArray arrayWithCapacity:cppAttributes.texcoords->size()];
    for (const auto &texcoord : cppAttributes.texcoords.value()) {
      [texcoords addObject:@(texcoord)];
    }
    objcAttributes.texcoords = [texcoords copy];
  }
  if (cppAttributes.colors.has_value()) {
    NSMutableArray *colors =
        [NSMutableArray arrayWithCapacity:cppAttributes.colors->size()];
    for (const auto &color : cppAttributes.colors.value()) {
      [colors addObject:@(color)];
    }
    objcAttributes.colors = [colors copy];
  }
  if (cppAttributes.joints.has_value()) {
    NSMutableArray *joints =
        [NSMutableArray arrayWithCapacity:cppAttributes.joints->size()];
    for (const auto &joint : cppAttributes.joints.value()) {
      [joints addObject:@(joint)];
    }
    objcAttributes.joints = [joints copy];
  }
  if (cppAttributes.weights.has_value()) {
    NSMutableArray *weights =
        [NSMutableArray arrayWithCapacity:cppAttributes.weights->size()];
    for (const auto &weight : cppAttributes.weights.value()) {
      [weights addObject:@(weight)];
    }
    objcAttributes.weights = [weights copy];
  }

  return objcAttributes;
}

+ (GLTFMeshPrimitiveDracoExtension *)convertGLTFMeshPrimitiveDracoExtension:
    (const gltf2::json::MeshPrimitiveDracoExtension &)cppDracoExtension {
  GLTFMeshPrimitiveDracoExtension *objcDracoExtension =
      [[GLTFMeshPrimitiveDracoExtension alloc] init];

  objcDracoExtension.bufferView = cppDracoExtension.bufferView;
  objcDracoExtension.attributes =
      [self convertGLTFMeshPrimitiveAttributes:cppDracoExtension.attributes];

  return objcDracoExtension;
}

+ (GLTFMeshPrimitive *)convertGLTFMeshPrimitive:
    (const gltf2::json::MeshPrimitive &)cppPrimitive {
  GLTFMeshPrimitive *objcPrimitive = [[GLTFMeshPrimitive alloc] init];

  objcPrimitive.attributes =
      [self convertGLTFMeshPrimitiveAttributes:cppPrimitive.attributes];
  if (cppPrimitive.indices.has_value()) {
    objcPrimitive.indices = @(cppPrimitive.indices.value());
  }
  if (cppPrimitive.material.has_value()) {
    objcPrimitive.material = @(cppPrimitive.material.value());
  }
  objcPrimitive.mode =
      [self convertGLTFMeshPrimitiveMode:cppPrimitive.modeValue()];
  if (cppPrimitive.targets.has_value()) {
    NSMutableArray<GLTFMeshPrimitiveTarget *> *targetsArray =
        [NSMutableArray arrayWithCapacity:cppPrimitive.targets->size()];
    for (const auto &target : cppPrimitive.targets.value()) {
      [targetsArray addObject:[self convertGLTFMeshPrimitiveTarget:target]];
    }
    objcPrimitive.targets = [targetsArray copy];
  }
  if (cppPrimitive.dracoExtension.has_value()) {
    objcPrimitive.dracoExtension =
        [self convertGLTFMeshPrimitiveDracoExtension:cppPrimitive.dracoExtension
                                                         .value()];
  }

  return objcPrimitive;
}

+ (GLTFMesh *)convertGLTFMesh:(const gltf2::json::Mesh &)cppMesh {
  GLTFMesh *objcMesh = [[GLTFMesh alloc] init];

  NSMutableArray<GLTFMeshPrimitive *> *primitivesArray = [NSMutableArray array];
  for (const auto &primitive : cppMesh.primitives) {
    [primitivesArray addObject:[self convertGLTFMeshPrimitive:primitive]];
  }
  objcMesh.primitives = primitivesArray;

  if (cppMesh.weights.has_value()) {
    NSMutableArray *weights =
        [NSMutableArray arrayWithCapacity:cppMesh.weights->size()];
    for (const auto &weight : cppMesh.weights.value()) {
      [weights addObject:@(weight)];
    }
    objcMesh.weights = [weights copy];
  }
  if (cppMesh.name.has_value()) {
    objcMesh.name = [NSString stringWithUTF8String:cppMesh.name->c_str()];
  }

  return objcMesh;
}

+ (GLTFNode *)convertGLTFNode:(const gltf2::json::Node &)cppNode {
  GLTFNode *objcNode = [[GLTFNode alloc] init];

  if (cppNode.camera.has_value()) {
    objcNode.camera = @(cppNode.camera.value());
  }
  if (cppNode.children.has_value()) {
    NSMutableArray<NSNumber *> *childrenArray =
        [NSMutableArray arrayWithCapacity:cppNode.children->size()];
    for (const auto &child : cppNode.children.value()) {
      [childrenArray addObject:@(child)];
    }
    objcNode.children = [childrenArray copy];
  }
  if (cppNode.skin.has_value()) {
    objcNode.skin = @(cppNode.skin.value());
  }
  if (cppNode.matrix.has_value()) {
    NSMutableArray<NSNumber *> *matrixArray =
        [NSMutableArray arrayWithCapacity:cppNode.matrix->size()];
    for (const auto &value : cppNode.matrix.value()) {
      [matrixArray addObject:@(value)];
    }
    objcNode.matrix = [matrixArray copy];
  }
  if (cppNode.mesh.has_value()) {
    objcNode.mesh = @(cppNode.mesh.value());
  }
  if (cppNode.rotation.has_value()) {
    objcNode.rotation = @[
      @(cppNode.rotation->at(0)), @(cppNode.rotation->at(1)),
      @(cppNode.rotation->at(2)), @(cppNode.rotation->at(3))
    ];
  }
  if (cppNode.scale.has_value()) {
    objcNode.scale = @[
      @(cppNode.scale->at(0)), @(cppNode.scale->at(1)), @(cppNode.scale->at(2))
    ];
  }
  if (cppNode.translation.has_value()) {
    objcNode.translation = @[
      @(cppNode.translation->at(0)), @(cppNode.translation->at(1)),
      @(cppNode.translation->at(2))
    ];
  }
  if (cppNode.weights.has_value()) {
    NSMutableArray<NSNumber *> *weightsArray =
        [NSMutableArray arrayWithCapacity:cppNode.weights->size()];
    for (const auto &weight : cppNode.weights.value()) {
      [weightsArray addObject:@(weight)];
    }
    objcNode.weights = [weightsArray copy];
  }
  if (cppNode.name.has_value()) {
    objcNode.name = [NSString stringWithUTF8String:cppNode.name->c_str()];
  }

  return objcNode;
}

+ (GLTFSamplerMagFilter)convertGLTFSamplerMagFilter:
    (gltf2::json::Sampler::MagFilter)magFilter {
  switch (magFilter) {
  case gltf2::json::Sampler::MagFilter::NEAREST:
    return GLTFSamplerMagFilterNearest;
  case gltf2::json::Sampler::MagFilter::LINEAR:
    return GLTFSamplerMagFilterLinear;
  default:
    return GLTFSamplerMagFilterNearest; // Default case
  }
}

+ (GLTFSamplerMinFilter)convertGLTFSamplerMinFilter:
    (gltf2::json::Sampler::MinFilter)minFilter {
  switch (minFilter) {
  case gltf2::json::Sampler::MinFilter::NEAREST:
    return GLTFSamplerMinFilterNearest;
  case gltf2::json::Sampler::MinFilter::LINEAR:
    return GLTFSamplerMinFilterLinear;
  case gltf2::json::Sampler::MinFilter::NEAREST_MIPMAP_NEAREST:
    return GLTFSamplerMinFilterNearestMipmapNearest;
  case gltf2::json::Sampler::MinFilter::LINEAR_MIPMAP_NEAREST:
    return GLTFSamplerMinFilterLinearMipmapNearest;
  case gltf2::json::Sampler::MinFilter::NEAREST_MIPMAP_LINEAR:
    return GLTFSamplerMinFilterNearestMipmapLinear;
  case gltf2::json::Sampler::MinFilter::LINEAR_MIPMAP_LINEAR:
    return GLTFSamplerMinFilterLinearMipmapLinear;
  default:
    return GLTFSamplerMinFilterNearest; // Default case
  }
}

+ (GLTFSamplerWrapMode)convertGLTFSamplerWrapMode:
    (gltf2::json::Sampler::WrapMode)wrapMode {
  switch (wrapMode) {
  case gltf2::json::Sampler::WrapMode::CLAMP_TO_EDGE:
    return GLTFSamplerWrapModeClampToEdge;
  case gltf2::json::Sampler::WrapMode::MIRRORED_REPEAT:
    return GLTFSamplerWrapModeMirroredRepeat;
  case gltf2::json::Sampler::WrapMode::REPEAT:
    return GLTFSamplerWrapModeRepeat;
  default:
    return GLTFSamplerWrapModeRepeat; // Default case
  }
}

+ (GLTFSampler *)convertGLTFSampler:(const gltf2::json::Sampler &)cppSampler {
  GLTFSampler *objcSampler = [[GLTFSampler alloc] init];

  if (cppSampler.magFilter.has_value()) {
    objcSampler.magFilter =
        @([self convertGLTFSamplerMagFilter:cppSampler.magFilter.value()]);
  }
  if (cppSampler.minFilter.has_value()) {
    objcSampler.minFilter =
        @([self convertGLTFSamplerMinFilter:cppSampler.minFilter.value()]);
  }
  objcSampler.wrapS = [self convertGLTFSamplerWrapMode:cppSampler.wrapSValue()];
  objcSampler.wrapT = [self convertGLTFSamplerWrapMode:cppSampler.wrapTValue()];
  if (cppSampler.name.has_value()) {
    objcSampler.name = [NSString stringWithUTF8String:cppSampler.name->c_str()];
  }

  return objcSampler;
}

+ (GLTFScene *)convertGLTFScene:(const gltf2::json::Scene &)cppScene {
  GLTFScene *objcScene = [[GLTFScene alloc] init];

  if (cppScene.nodes.has_value()) {
    NSMutableArray<NSNumber *> *nodesArray =
        [NSMutableArray arrayWithCapacity:cppScene.nodes->size()];
    for (const auto &node : cppScene.nodes.value()) {
      [nodesArray addObject:@(node)];
    }
    objcScene.nodes = [nodesArray copy];
  }
  if (cppScene.name.has_value()) {
    objcScene.name = [NSString stringWithUTF8String:cppScene.name->c_str()];
  }

  return objcScene;
}

+ (GLTFSkin *)convertGLTFSkin:(const gltf2::json::Skin &)cppSkin {
  GLTFSkin *objcSkin = [[GLTFSkin alloc] init];

  if (cppSkin.inverseBindMatrices.has_value()) {
    objcSkin.inverseBindMatrices = @(cppSkin.inverseBindMatrices.value());
  }
  if (cppSkin.skeleton.has_value()) {
    objcSkin.skeleton = @(cppSkin.skeleton.value());
  }
  NSMutableArray<NSNumber *> *jointsArray =
      [NSMutableArray arrayWithCapacity:cppSkin.joints.size()];
  for (const auto &joint : cppSkin.joints) {
    [jointsArray addObject:@(joint)];
  }
  objcSkin.joints = [jointsArray copy];
  if (cppSkin.name.has_value()) {
    objcSkin.name = [NSString stringWithUTF8String:cppSkin.name->c_str()];
  }

  return objcSkin;
}

+ (KHRLightSpot *)convertKHRLightSpot:
    (const gltf2::json::KHRLightSpot &)cppLightSpot {
  KHRLightSpot *objcLightSpot = [[KHRLightSpot alloc] init];

  if (cppLightSpot.innerConeAngle.has_value()) {
    objcLightSpot.innerConeAngle = @(cppLightSpot.innerConeAngle.value());
  }
  if (cppLightSpot.outerConeAngle.has_value()) {
    objcLightSpot.outerConeAngle = @(cppLightSpot.outerConeAngle.value());
  }

  return objcLightSpot;
}

+ (NSString *)convertKHRLightType:(gltf2::json::KHRLight::Type)type {
  switch (type) {
  case gltf2::json::KHRLight::Type::POINT:
    return KHRLightTypePoint;
  case gltf2::json::KHRLight::Type::SPOT:
    return KHRLightTypeSpot;
  case gltf2::json::KHRLight::Type::DIRECTIONAL:
    return KHRLightTypeDirectional;
  default:
    return KHRLightTypePoint; // Default case
  }
}

+ (KHRLight *)convertKHRLight:(const gltf2::json::KHRLight &)cppLight {
  KHRLight *objcLight = [[KHRLight alloc] init];

  if (cppLight.name.has_value()) {
    objcLight.name = [NSString stringWithUTF8String:cppLight.name->c_str()];
  }
  if (cppLight.color.has_value()) {
    objcLight.color = @[
      @(cppLight.color->at(0)), @(cppLight.color->at(1)),
      @(cppLight.color->at(2))
    ];
  }
  if (cppLight.intensity.has_value()) {
    objcLight.intensity = @(cppLight.intensity.value());
  }
  objcLight.type = [self convertKHRLightType:cppLight.type];
  if (cppLight.spot.has_value()) {
    objcLight.spot = [self convertKHRLightSpot:cppLight.spot.value()];
  }

  return objcLight;
}

+ (NSString *)convertVRM1MetaAvatarPermission:
    (gltf2::json::vrmc::Meta::AvatarPermission)permission {
  switch (permission) {
  case gltf2::json::vrmc::Meta::AvatarPermission::ONLY_AUTHOR:
    return VRM1MetaAvatarPermissionOnlyAuthor;
  case gltf2::json::vrmc::Meta::AvatarPermission::
      ONLY_SEPARATELY_LICENSED_PERSON:
    return VRM1MetaAvatarPermissionOnlySeparatelyLicensedPerson;
  case gltf2::json::vrmc::Meta::AvatarPermission::EVERYONE:
    return VRM1MetaAvatarPermissionEveryone;
  default:
    return VRM1MetaAvatarPermissionOnlyAuthor; // Default case
  }
}

+ (NSString *)convertVRM1MetaCommercialUsage:
    (gltf2::json::vrmc::Meta::CommercialUsage)usage {
  switch (usage) {
  case gltf2::json::vrmc::Meta::CommercialUsage::PERSONAL_NON_PROFIT:
    return VRM1MetaCommercialUsagePersonalNonProfit;
  case gltf2::json::vrmc::Meta::CommercialUsage::PERSONAL_PROFIT:
    return VRM1MetaCommercialUsagePersonalProfit;
  case gltf2::json::vrmc::Meta::CommercialUsage::CORPORATION:
    return VRM1MetaCommercialUsageCorporation;
  default:
    return VRM1MetaCommercialUsagePersonalNonProfit; // Default case
  }
}

+ (NSString *)convertVRM1MetaCreditNotation:
    (gltf2::json::vrmc::Meta::CreditNotation)notation {
  switch (notation) {
  case gltf2::json::vrmc::Meta::CreditNotation::REQUIRED:
    return VRM1MetaCreditNotationRequired;
  case gltf2::json::vrmc::Meta::CreditNotation::UNNECESSARY:
    return VRM1MetaCreditNotationUnnecessary;
  default:
    return VRM1MetaCreditNotationRequired; // Default case
  }
}

+ (NSString *)convertVRM1MetaModification:
    (gltf2::json::vrmc::Meta::Modification)modification {
  switch (modification) {
  case gltf2::json::vrmc::Meta::Modification::PROHIBITED:
    return VRM1MetaModificationProhibited;
  case gltf2::json::vrmc::Meta::Modification::ALLOW_MODIFICATION:
    return VRM1MetaModificationAllowModification;
  case gltf2::json::vrmc::Meta::Modification::ALLOW_MODIFICATION_REDISTRIBUTION:
    return VRM1MetaModificationAllowModificationRedistribution;
  default:
    return VRM1MetaModificationProhibited; // Default case
  }
}

+ (VRM1Meta *)convertVRM1Meta:(const gltf2::json::vrmc::Meta &)cppMeta {
  VRM1Meta *objcMeta = [[VRM1Meta alloc] init];

  objcMeta.name = [NSString stringWithUTF8String:cppMeta.name.c_str()];
  if (cppMeta.version.has_value()) {
    objcMeta.version = [NSString stringWithUTF8String:cppMeta.version->c_str()];
  }
  NSMutableArray<NSString *> *authorsArray = [NSMutableArray array];
  for (const auto &author : cppMeta.authors) {
    [authorsArray addObject:[NSString stringWithUTF8String:author.c_str()]];
  }
  objcMeta.authors = authorsArray;
  if (cppMeta.copyrightInformation.has_value()) {
    objcMeta.copyrightInformation =
        [NSString stringWithUTF8String:cppMeta.copyrightInformation->c_str()];
  }
  if (cppMeta.contactInformation.has_value()) {
    objcMeta.contactInformation =
        [NSString stringWithUTF8String:cppMeta.contactInformation->c_str()];
  }
  if (cppMeta.references.has_value()) {
    NSMutableArray<NSString *> *referencesArray =
        [NSMutableArray arrayWithCapacity:cppMeta.references->size()];
    for (const auto &reference : cppMeta.references.value()) {
      [referencesArray
          addObject:[NSString stringWithUTF8String:reference.c_str()]];
    }
    objcMeta.references = [referencesArray copy];
  }
  if (cppMeta.thirdPartyLicenses.has_value()) {
    objcMeta.thirdPartyLicenses =
        [NSString stringWithUTF8String:cppMeta.thirdPartyLicenses->c_str()];
  }
  if (cppMeta.thumbnailImage.has_value()) {
    objcMeta.thumbnailImage = @(cppMeta.thumbnailImage.value());
  }
  objcMeta.licenseUrl =
      [NSString stringWithUTF8String:cppMeta.licenseUrl.c_str()];
  if (cppMeta.avatarPermission.has_value()) {
    objcMeta.avatarPermission =
        [self convertVRM1MetaAvatarPermission:cppMeta.avatarPermission.value()];
  }
  if (cppMeta.allowExcessivelyViolentUsage.has_value()) {
    objcMeta.allowExcessivelyViolentUsage =
        @(cppMeta.allowExcessivelyViolentUsage.value());
  }
  if (cppMeta.allowExcessivelySexualUsage.has_value()) {
    objcMeta.allowExcessivelySexualUsage =
        @(cppMeta.allowExcessivelySexualUsage.value());
  }
  if (cppMeta.commercialUsage.has_value()) {
    objcMeta.commercialUsage =
        [self convertVRM1MetaCommercialUsage:cppMeta.commercialUsage.value()];
  }
  if (cppMeta.allowPoliticalOrReligiousUsage.has_value()) {
    objcMeta.allowPoliticalOrReligiousUsage =
        @(cppMeta.allowPoliticalOrReligiousUsage.value());
  }
  if (cppMeta.allowAntisocialOrHateUsage.has_value()) {
    objcMeta.allowAntisocialOrHateUsage =
        @(cppMeta.allowAntisocialOrHateUsage.value());
  }
  if (cppMeta.creditNotation.has_value()) {
    objcMeta.creditNotation =
        [self convertVRM1MetaCreditNotation:cppMeta.creditNotation.value()];
  }
  if (cppMeta.allowRedistribution.has_value()) {
    objcMeta.allowRedistribution = @(cppMeta.allowRedistribution.value());
  }
  if (cppMeta.modification.has_value()) {
    objcMeta.modification =
        [self convertVRM1MetaModification:cppMeta.modification.value()];
  }
  if (cppMeta.otherLicenseUrl.has_value()) {
    objcMeta.otherLicenseUrl =
        [NSString stringWithUTF8String:cppMeta.otherLicenseUrl->c_str()];
  }

  return objcMeta;
}

+ (VRM1HumanBone *)convertVRM1HumanoidHumanBone:
    (const gltf2::json::vrmc::HumanoidHumanBone &)cppBone {
  VRM1HumanBone *objcBone = [[VRM1HumanBone alloc] init];
  objcBone.node = @(cppBone.node);
  return objcBone;
}

+ (VRM1HumanBones *)convertVRM1HumanoidHumanBones:
    (const gltf2::json::vrmc::HumanoidHumanBones &)cppBones {
  VRM1HumanBones *objcBones = [[VRM1HumanBones alloc] init];

  objcBones.hips = [self convertVRM1HumanoidHumanBone:cppBones.hips];
  objcBones.spine = [self convertVRM1HumanoidHumanBone:cppBones.spine];
  if (cppBones.chest.has_value()) {
    objcBones.chest =
        [self convertVRM1HumanoidHumanBone:cppBones.chest.value()];
  }
  if (cppBones.upperChest.has_value()) {
    objcBones.upperChest =
        [self convertVRM1HumanoidHumanBone:cppBones.upperChest.value()];
  }
  if (cppBones.neck.has_value()) {
    objcBones.neck = [self convertVRM1HumanoidHumanBone:cppBones.neck.value()];
  }
  objcBones.head = [self convertVRM1HumanoidHumanBone:cppBones.head];
  if (cppBones.leftEye.has_value()) {
    objcBones.leftEye =
        [self convertVRM1HumanoidHumanBone:cppBones.leftEye.value()];
  }
  if (cppBones.rightEye.has_value()) {
    objcBones.rightEye =
        [self convertVRM1HumanoidHumanBone:cppBones.rightEye.value()];
  }
  if (cppBones.jaw.has_value()) {
    objcBones.jaw = [self convertVRM1HumanoidHumanBone:cppBones.jaw.value()];
  }
  objcBones.leftUpperLeg =
      [self convertVRM1HumanoidHumanBone:cppBones.leftUpperLeg];
  objcBones.leftLowerLeg =
      [self convertVRM1HumanoidHumanBone:cppBones.leftLowerLeg];
  objcBones.leftFoot = [self convertVRM1HumanoidHumanBone:cppBones.leftFoot];
  if (cppBones.leftToes.has_value()) {
    objcBones.leftToes =
        [self convertVRM1HumanoidHumanBone:cppBones.leftToes.value()];
  }
  objcBones.rightUpperLeg =
      [self convertVRM1HumanoidHumanBone:cppBones.rightUpperLeg];
  objcBones.rightLowerLeg =
      [self convertVRM1HumanoidHumanBone:cppBones.rightLowerLeg];
  objcBones.rightFoot = [self convertVRM1HumanoidHumanBone:cppBones.rightFoot];
  if (cppBones.rightToes.has_value()) {
    objcBones.rightToes =
        [self convertVRM1HumanoidHumanBone:cppBones.rightToes.value()];
  }
  if (cppBones.leftShoulder.has_value()) {
    objcBones.leftShoulder =
        [self convertVRM1HumanoidHumanBone:cppBones.leftShoulder.value()];
  }
  objcBones.leftUpperArm =
      [self convertVRM1HumanoidHumanBone:cppBones.leftUpperArm];
  objcBones.leftLowerArm =
      [self convertVRM1HumanoidHumanBone:cppBones.leftLowerArm];
  objcBones.leftHand = [self convertVRM1HumanoidHumanBone:cppBones.leftHand];
  if (cppBones.rightShoulder.has_value()) {
    objcBones.rightShoulder =
        [self convertVRM1HumanoidHumanBone:cppBones.rightShoulder.value()];
  }
  objcBones.rightUpperArm =
      [self convertVRM1HumanoidHumanBone:cppBones.rightUpperArm];
  objcBones.rightLowerArm =
      [self convertVRM1HumanoidHumanBone:cppBones.rightLowerArm];
  objcBones.rightHand = [self convertVRM1HumanoidHumanBone:cppBones.rightHand];
  if (cppBones.leftThumbMetacarpal.has_value()) {
    objcBones.leftThumbMetacarpal = [self
        convertVRM1HumanoidHumanBone:cppBones.leftThumbMetacarpal.value()];
  }
  if (cppBones.leftThumbProximal.has_value()) {
    objcBones.leftThumbProximal =
        [self convertVRM1HumanoidHumanBone:cppBones.leftThumbProximal.value()];
  }
  if (cppBones.leftThumbDistal.has_value()) {
    objcBones.leftThumbDistal =
        [self convertVRM1HumanoidHumanBone:cppBones.leftThumbDistal.value()];
  }
  if (cppBones.leftIndexProximal.has_value()) {
    objcBones.leftIndexProximal =
        [self convertVRM1HumanoidHumanBone:cppBones.leftIndexProximal.value()];
  }
  if (cppBones.leftIndexIntermediate.has_value()) {
    objcBones.leftIndexIntermediate = [self
        convertVRM1HumanoidHumanBone:cppBones.leftIndexIntermediate.value()];
  }
  if (cppBones.leftIndexDistal.has_value()) {
    objcBones.leftIndexDistal =
        [self convertVRM1HumanoidHumanBone:cppBones.leftIndexDistal.value()];
  }
  if (cppBones.leftMiddleProximal.has_value()) {
    objcBones.leftMiddleProximal =
        [self convertVRM1HumanoidHumanBone:cppBones.leftMiddleProximal.value()];
  }
  if (cppBones.leftMiddleIntermediate.has_value()) {
    objcBones.leftMiddleIntermediate = [self
        convertVRM1HumanoidHumanBone:cppBones.leftMiddleIntermediate.value()];
  }
  if (cppBones.leftMiddleDistal.has_value()) {
    objcBones.leftMiddleDistal =
        [self convertVRM1HumanoidHumanBone:cppBones.leftMiddleDistal.value()];
  }
  if (cppBones.leftRingProximal.has_value()) {
    objcBones.leftRingProximal =
        [self convertVRM1HumanoidHumanBone:cppBones.leftRingProximal.value()];
  }
  if (cppBones.leftRingIntermediate.has_value()) {
    objcBones.leftRingIntermediate = [self
        convertVRM1HumanoidHumanBone:cppBones.leftRingIntermediate.value()];
  }
  if (cppBones.leftRingDistal.has_value()) {
    objcBones.leftRingDistal =
        [self convertVRM1HumanoidHumanBone:cppBones.leftRingDistal.value()];
  }
  if (cppBones.leftLittleProximal.has_value()) {
    objcBones.leftLittleProximal =
        [self convertVRM1HumanoidHumanBone:cppBones.leftLittleProximal.value()];
  }
  if (cppBones.leftLittleIntermediate.has_value()) {
    objcBones.leftLittleIntermediate = [self
        convertVRM1HumanoidHumanBone:cppBones.leftLittleIntermediate.value()];
  }
  if (cppBones.leftLittleDistal.has_value()) {
    objcBones.leftLittleDistal =
        [self convertVRM1HumanoidHumanBone:cppBones.leftLittleDistal.value()];
  }
  if (cppBones.rightThumbMetacarpal.has_value()) {
    objcBones.rightThumbMetacarpal = [self
        convertVRM1HumanoidHumanBone:cppBones.rightThumbMetacarpal.value()];
  }
  if (cppBones.rightThumbProximal.has_value()) {
    objcBones.rightThumbProximal =
        [self convertVRM1HumanoidHumanBone:cppBones.rightThumbProximal.value()];
  }
  if (cppBones.rightThumbDistal.has_value()) {
    objcBones.rightThumbDistal =
        [self convertVRM1HumanoidHumanBone:cppBones.rightThumbDistal.value()];
  }
  if (cppBones.rightIndexProximal.has_value()) {
    objcBones.rightIndexProximal =
        [self convertVRM1HumanoidHumanBone:cppBones.rightIndexProximal.value()];
  }
  if (cppBones.rightIndexIntermediate.has_value()) {
    objcBones.rightIndexIntermediate = [self
        convertVRM1HumanoidHumanBone:cppBones.rightIndexIntermediate.value()];
  }
  if (cppBones.rightIndexDistal.has_value()) {
    objcBones.rightIndexDistal =
        [self convertVRM1HumanoidHumanBone:cppBones.rightIndexDistal.value()];
  }
  if (cppBones.rightMiddleProximal.has_value()) {
    objcBones.rightMiddleProximal = [self
        convertVRM1HumanoidHumanBone:cppBones.rightMiddleProximal.value()];
  }
  if (cppBones.rightMiddleIntermediate.has_value()) {
    objcBones.rightMiddleIntermediate = [self
        convertVRM1HumanoidHumanBone:cppBones.rightMiddleIntermediate.value()];
  }
  if (cppBones.rightMiddleDistal.has_value()) {
    objcBones.rightMiddleDistal =
        [self convertVRM1HumanoidHumanBone:cppBones.rightMiddleDistal.value()];
  }
  if (cppBones.rightRingProximal.has_value()) {
    objcBones.rightRingProximal =
        [self convertVRM1HumanoidHumanBone:cppBones.rightRingProximal.value()];
  }
  if (cppBones.rightRingIntermediate.has_value()) {
    objcBones.rightRingIntermediate = [self
        convertVRM1HumanoidHumanBone:cppBones.rightRingIntermediate.value()];
  }
  if (cppBones.rightRingDistal.has_value()) {
    objcBones.rightRingDistal =
        [self convertVRM1HumanoidHumanBone:cppBones.rightRingDistal.value()];
  }
  if (cppBones.rightLittleProximal.has_value()) {
    objcBones.rightLittleProximal = [self
        convertVRM1HumanoidHumanBone:cppBones.rightLittleProximal.value()];
  }
  if (cppBones.rightLittleIntermediate.has_value()) {
    objcBones.rightLittleIntermediate = [self
        convertVRM1HumanoidHumanBone:cppBones.rightLittleIntermediate.value()];
  }
  if (cppBones.rightLittleDistal.has_value()) {
    objcBones.rightLittleDistal =
        [self convertVRM1HumanoidHumanBone:cppBones.rightLittleDistal.value()];
  }

  return objcBones;
}

+ (VRM1Humanoid *)convertVRM1Humanoid:
    (const gltf2::json::vrmc::Humanoid &)cppHumanoid {
  VRM1Humanoid *objcHumanoid = [[VRM1Humanoid alloc] init];
  objcHumanoid.humanBones =
      [self convertVRM1HumanoidHumanBones:cppHumanoid.humanBones];
  return objcHumanoid;
}

+ (NSString *)convertVRM1FirstPersonMeshAnnotationType:
    (gltf2::json::vrmc::FirstPersonMeshAnnotation::Type)type {
  switch (type) {
  case gltf2::json::vrmc::FirstPersonMeshAnnotation::Type::AUTO:
    return VRM1FirstPersonMeshAnnotationTypeAuto;
  case gltf2::json::vrmc::FirstPersonMeshAnnotation::Type::BOTH:
    return VRM1FirstPersonMeshAnnotationTypeBoth;
  case gltf2::json::vrmc::FirstPersonMeshAnnotation::Type::THIRD_PERSON_ONLY:
    return VRM1FirstPersonMeshAnnotationTypeThirdPersonOnly;
  case gltf2::json::vrmc::FirstPersonMeshAnnotation::Type::FIRST_PERSON_ONLY:
    return VRM1FirstPersonMeshAnnotationTypeFirstPersonOnly;
  default:
    return VRM1FirstPersonMeshAnnotationTypeAuto; // Default case
  }
}

+ (VRM1FirstPersonMeshAnnotation *)convertVRM1FirstPersonMeshAnnotation:
    (const gltf2::json::vrmc::FirstPersonMeshAnnotation &)cppAnnotation {
  VRM1FirstPersonMeshAnnotation *objcAnnotation =
      [[VRM1FirstPersonMeshAnnotation alloc] init];
  objcAnnotation.node = cppAnnotation.node;
  objcAnnotation.type =
      [self convertVRM1FirstPersonMeshAnnotationType:cppAnnotation.type];
  return objcAnnotation;
}

+ (VRM1FirstPerson *)convertVRM1FirstPerson:
    (const gltf2::json::vrmc::FirstPerson &)cppFirstPerson {
  VRM1FirstPerson *objcFirstPerson = [[VRM1FirstPerson alloc] init];

  if (cppFirstPerson.meshAnnotations.has_value()) {
    NSMutableArray<VRM1FirstPersonMeshAnnotation *> *annotationsArray =
        [NSMutableArray
            arrayWithCapacity:cppFirstPerson.meshAnnotations->size()];
    for (const auto &annotation : cppFirstPerson.meshAnnotations.value()) {
      [annotationsArray
          addObject:[self convertVRM1FirstPersonMeshAnnotation:annotation]];
    }
    objcFirstPerson.meshAnnotations = [annotationsArray copy];
  }

  return objcFirstPerson;
}

+ (VRM1LookAtRangeMap *)convertVRM1LookAtRangeMap:
    (const gltf2::json::vrmc::LookAtRangeMap &)cppLookAtRangeMap {
  VRM1LookAtRangeMap *objcLookAtRangeMap = [[VRM1LookAtRangeMap alloc] init];

  if (cppLookAtRangeMap.inputMaxValue.has_value()) {
    objcLookAtRangeMap.inputMaxValue =
        @(cppLookAtRangeMap.inputMaxValue.value());
  }
  if (cppLookAtRangeMap.outputScale.has_value()) {
    objcLookAtRangeMap.outputScale = @(cppLookAtRangeMap.outputScale.value());
  }

  return objcLookAtRangeMap;
}

+ (NSString *)convertVRM1LookAtType:(gltf2::json::vrmc::LookAt::Type)type {
  switch (type) {
  case gltf2::json::vrmc::LookAt::Type::BONE:
    return VRM1LookAtTypeBone;
  case gltf2::json::vrmc::LookAt::Type::EXPRESSION:
    return VRM1LookAtTypeExpression;
  default:
    return VRM1LookAtTypeBone; // Default case
  }
}

+ (VRM1LookAt *)convertVRM1LookAt:(const gltf2::json::vrmc::LookAt &)cppLookAt {
  VRM1LookAt *objcLookAt = [[VRM1LookAt alloc] init];

  if (cppLookAt.offsetFromHeadBone.has_value()) {
    objcLookAt.offsetFromHeadBone =
        [[Vec3 alloc] initWithX:cppLookAt.offsetFromHeadBone->at(0)
                              Y:cppLookAt.offsetFromHeadBone->at(1)
                              Z:cppLookAt.offsetFromHeadBone->at(2)];
  }
  if (cppLookAt.type.has_value()) {
    objcLookAt.type = [self convertVRM1LookAtType:cppLookAt.type.value()];
  }
  if (cppLookAt.rangeMapHorizontalInner.has_value()) {
    objcLookAt.rangeMapHorizontalInner = [self
        convertVRM1LookAtRangeMap:cppLookAt.rangeMapHorizontalInner.value()];
  }
  if (cppLookAt.rangeMapHorizontalOuter.has_value()) {
    objcLookAt.rangeMapHorizontalOuter = [self
        convertVRM1LookAtRangeMap:cppLookAt.rangeMapHorizontalOuter.value()];
  }
  if (cppLookAt.rangeMapVerticalDown.has_value()) {
    objcLookAt.rangeMapVerticalDown =
        [self convertVRM1LookAtRangeMap:cppLookAt.rangeMapVerticalDown.value()];
  }
  if (cppLookAt.rangeMapVerticalUp.has_value()) {
    objcLookAt.rangeMapVerticalUp =
        [self convertVRM1LookAtRangeMap:cppLookAt.rangeMapVerticalUp.value()];
  }

  return objcLookAt;
}

+ (NSString *)convertVRM1ExpressionMaterialColorBindType:
    (gltf2::json::vrmc::ExpressionMaterialColorBind::Type)type {
  switch (type) {
  case gltf2::json::vrmc::ExpressionMaterialColorBind::Type::COLOR:
    return VRM1ExpressionMaterialColorBindTypeColor;
  case gltf2::json::vrmc::ExpressionMaterialColorBind::Type::EMISSION_COLOR:
    return VRM1ExpressionMaterialColorBindTypeEmissionColor;
  case gltf2::json::vrmc::ExpressionMaterialColorBind::Type::SHADE_COLOR:
    return VRM1ExpressionMaterialColorBindTypeShadeColor;
  case gltf2::json::vrmc::ExpressionMaterialColorBind::Type::MATCAP_COLOR:
    return VRM1ExpressionMaterialColorBindTypeMatcapColor;
  case gltf2::json::vrmc::ExpressionMaterialColorBind::Type::RIM_COLOR:
    return VRM1ExpressionMaterialColorBindTypeRimColor;
  case gltf2::json::vrmc::ExpressionMaterialColorBind::Type::OUTLINE_COLOR:
    return VRM1ExpressionMaterialColorBindTypeOutlineColor;
  default:
    return VRM1ExpressionMaterialColorBindTypeColor; // Default case
  }
}

+ (VRM1ExpressionMaterialColorBind *)convertVRM1ExpressionMaterialColorBind:
    (const gltf2::json::vrmc::ExpressionMaterialColorBind &)cppBind {
  VRM1ExpressionMaterialColorBind *objcBind =
      [[VRM1ExpressionMaterialColorBind alloc] init];
  objcBind.material = cppBind.material;
  objcBind.type =
      [self convertVRM1ExpressionMaterialColorBindType:cppBind.type];
  objcBind.targetValue = @[
    @(cppBind.targetValue[0]), @(cppBind.targetValue[1]),
    @(cppBind.targetValue[2]), @(cppBind.targetValue[3])
  ];
  return objcBind;
}

+ (VRM1ExpressionMorphTargetBind *)convertVRM1ExpressionMorphTargetBind:
    (const gltf2::json::vrmc::ExpressionMorphTargetBind &)cppBind {
  VRM1ExpressionMorphTargetBind *objcBind =
      [[VRM1ExpressionMorphTargetBind alloc] init];
  objcBind.node = cppBind.node;
  objcBind.index = cppBind.index;
  objcBind.weight = cppBind.weight;
  return objcBind;
}

+ (VRM1ExpressionTextureTransformBind *)
    convertVRM1ExpressionTextureTransformBind:
        (const gltf2::json::vrmc::ExpressionTextureTransformBind &)cppBind {
  VRM1ExpressionTextureTransformBind *objcBind =
      [[VRM1ExpressionTextureTransformBind alloc] init];
  objcBind.material = cppBind.material;
  if (cppBind.scale.has_value()) {
    objcBind.scale = @[ @(cppBind.scale->at(0)), @(cppBind.scale->at(1)) ];
  }
  if (cppBind.offset.has_value()) {
    objcBind.offset = @[ @(cppBind.offset->at(0)), @(cppBind.offset->at(1)) ];
  }
  return objcBind;
}

+ (NSString *)convertVRM1ExpressionOverride:
    (gltf2::json::vrmc::Expression::Override)override {
  switch (override) {
  case gltf2::json::vrmc::Expression::Override::NONE:
    return VRM1ExpressionOverrideNone;
  case gltf2::json::vrmc::Expression::Override::BLOCK:
    return VRM1ExpressionOverrideBlock;
  case gltf2::json::vrmc::Expression::Override::BLEND:
    return VRM1ExpressionOverrideBlend;
  default:
    return VRM1ExpressionOverrideNone; // Default case
  }
}

+ (VRM1Expression *)convertVRM1Expression:
    (const gltf2::json::vrmc::Expression &)cppExpression {
  VRM1Expression *objcExpression = [[VRM1Expression alloc] init];

  if (cppExpression.morphTargetBinds.has_value()) {
    NSMutableArray<VRM1ExpressionMorphTargetBind *> *morphTargetBindsArray =
        [NSMutableArray array];
    for (const auto &bind : cppExpression.morphTargetBinds.value()) {
      [morphTargetBindsArray
          addObject:[self convertVRM1ExpressionMorphTargetBind:bind]];
    }
    objcExpression.morphTargetBinds = morphTargetBindsArray;
  }
  if (cppExpression.materialColorBinds.has_value()) {
    NSMutableArray<VRM1ExpressionMaterialColorBind *> *materialColorBindsArray =
        [NSMutableArray array];
    for (const auto &bind : cppExpression.materialColorBinds.value()) {
      [materialColorBindsArray
          addObject:[self convertVRM1ExpressionMaterialColorBind:bind]];
    }
    objcExpression.materialColorBinds = materialColorBindsArray;
  }
  if (cppExpression.textureTransformBinds.has_value()) {
    NSMutableArray<VRM1ExpressionTextureTransformBind *>
        *textureTransformBindsArray = [NSMutableArray array];
    for (const auto &bind : cppExpression.textureTransformBinds.value()) {
      [textureTransformBindsArray
          addObject:[self convertVRM1ExpressionTextureTransformBind:bind]];
    }
    objcExpression.textureTransformBinds = textureTransformBindsArray;
  }
  objcExpression.isBinary = cppExpression.isBinaryValue();
  if (cppExpression.overrideBlink.has_value()) {
    objcExpression.overrideBlink = [self
        convertVRM1ExpressionOverride:cppExpression.overrideBlink.value()];
  }
  if (cppExpression.overrideLookAt.has_value()) {
    objcExpression.overrideLookAt = [self
        convertVRM1ExpressionOverride:cppExpression.overrideLookAt.value()];
  }
  if (cppExpression.overrideMouth.has_value()) {
    objcExpression.overrideMouth = [self
        convertVRM1ExpressionOverride:cppExpression.overrideMouth.value()];
  }

  return objcExpression;
}

+ (VRM1ExpressionsPreset *)convertVRM1ExpressionsPreset:
    (const gltf2::json::vrmc::ExpressionsPreset &)cppPreset {
  VRM1ExpressionsPreset *objcPreset = [[VRM1ExpressionsPreset alloc] init];

  if (cppPreset.happy.has_value()) {
    objcPreset.happy = [self convertVRM1Expression:cppPreset.happy.value()];
  }
  if (cppPreset.angry.has_value()) {
    objcPreset.angry = [self convertVRM1Expression:cppPreset.angry.value()];
  }
  if (cppPreset.sad.has_value()) {
    objcPreset.sad = [self convertVRM1Expression:cppPreset.sad.value()];
  }
  if (cppPreset.relaxed.has_value()) {
    objcPreset.relaxed = [self convertVRM1Expression:cppPreset.relaxed.value()];
  }
  if (cppPreset.surprised.has_value()) {
    objcPreset.surprised =
        [self convertVRM1Expression:cppPreset.surprised.value()];
  }
  if (cppPreset.aa.has_value()) {
    objcPreset.aa = [self convertVRM1Expression:cppPreset.aa.value()];
  }
  if (cppPreset.ih.has_value()) {
    objcPreset.ih = [self convertVRM1Expression:cppPreset.ih.value()];
  }
  if (cppPreset.ou.has_value()) {
    objcPreset.ou = [self convertVRM1Expression:cppPreset.ou.value()];
  }
  if (cppPreset.ee.has_value()) {
    objcPreset.ee = [self convertVRM1Expression:cppPreset.ee.value()];
  }
  if (cppPreset.oh.has_value()) {
    objcPreset.oh = [self convertVRM1Expression:cppPreset.oh.value()];
  }
  if (cppPreset.blink.has_value()) {
    objcPreset.blink = [self convertVRM1Expression:cppPreset.blink.value()];
  }
  if (cppPreset.blinkLeft.has_value()) {
    objcPreset.blinkLeft =
        [self convertVRM1Expression:cppPreset.blinkLeft.value()];
  }
  if (cppPreset.blinkRight.has_value()) {
    objcPreset.blinkRight =
        [self convertVRM1Expression:cppPreset.blinkRight.value()];
  }
  if (cppPreset.lookUp.has_value()) {
    objcPreset.lookUp = [self convertVRM1Expression:cppPreset.lookUp.value()];
  }
  if (cppPreset.lookDown.has_value()) {
    objcPreset.lookDown =
        [self convertVRM1Expression:cppPreset.lookDown.value()];
  }
  if (cppPreset.lookLeft.has_value()) {
    objcPreset.lookLeft =
        [self convertVRM1Expression:cppPreset.lookLeft.value()];
  }
  if (cppPreset.lookRight.has_value()) {
    objcPreset.lookRight =
        [self convertVRM1Expression:cppPreset.lookRight.value()];
  }
  if (cppPreset.neutral.has_value()) {
    objcPreset.neutral = [self convertVRM1Expression:cppPreset.neutral.value()];
  }

  return objcPreset;
}

+ (VRM1Expressions *)convertVRM1Expressions:
    (const gltf2::json::vrmc::Expressions &)cppExpressions {
  VRM1Expressions *objcExpressions = [[VRM1Expressions alloc] init];

  if (cppExpressions.preset.has_value()) {
    objcExpressions.preset =
        [self convertVRM1ExpressionsPreset:cppExpressions.preset.value()];
  }
  if (cppExpressions.custom.has_value()) {
    NSMutableDictionary<NSString *, VRM1Expression *> *customDict =
        [NSMutableDictionary dictionary];
    for (const auto &pair : cppExpressions.custom.value()) {
      NSString *key = [NSString stringWithUTF8String:pair.first.c_str()];
      VRM1Expression *value = [self convertVRM1Expression:pair.second];
      [customDict setObject:value forKey:key];
    }
    objcExpressions.custom = customDict;
  }

  return objcExpressions;
}

+ (VRM1VRM *)convertVRM1VRM:(const gltf2::json::vrmc::VRM &)cppVRM {
  VRM1VRM *objcVRM = [[VRM1VRM alloc] init];

  objcVRM.specVersion =
      [NSString stringWithUTF8String:cppVRM.specVersion.c_str()];
  objcVRM.meta = [self convertVRM1Meta:cppVRM.meta];
  objcVRM.humanoid = [self convertVRM1Humanoid:cppVRM.humanoid];
  if (cppVRM.firstPerson.has_value()) {
    objcVRM.firstPerson =
        [self convertVRM1FirstPerson:cppVRM.firstPerson.value()];
  }
  if (cppVRM.lookAt.has_value()) {
    objcVRM.lookAt = [self convertVRM1LookAt:cppVRM.lookAt.value()];
  }
  if (cppVRM.expressions.has_value()) {
    objcVRM.expressions =
        [self convertVRM1Expressions:cppVRM.expressions.value()];
  }

  return objcVRM;
}

+ (Vec3 *)convertVRM0Vec3:(const gltf2::json::vrm0::Vec3 &)cppVec3 {
  return [[Vec3 alloc] initWithX:cppVec3.x.value_or(0)
                               Y:cppVec3.y.value_or(0)
                               Z:cppVec3.z.value_or(0)];
}

+ (NSString *)convertVRM0HumanoidBoneName:
    (gltf2::json::vrm0::HumanoidBone::BoneName)type {
  switch (type) {
  case gltf2::json::vrm0::HumanoidBone::BoneName::HIPS:
    return VRM0HumanoidBoneNameHips;
  case gltf2::json::vrm0::HumanoidBone::BoneName::LEFT_UPPER_LEG:
    return VRM0HumanoidBoneNameLeftUpperLeg;
  case gltf2::json::vrm0::HumanoidBone::BoneName::RIGHT_UPPER_LEG:
    return VRM0HumanoidBoneNameRightUpperLeg;
  case gltf2::json::vrm0::HumanoidBone::BoneName::LEFT_LOWER_LEG:
    return VRM0HumanoidBoneNameLeftLowerLeg;
  case gltf2::json::vrm0::HumanoidBone::BoneName::RIGHT_LOWER_LEG:
    return VRM0HumanoidBoneNameRightLowerLeg;
  case gltf2::json::vrm0::HumanoidBone::BoneName::LEFT_FOOT:
    return VRM0HumanoidBoneNameLeftFoot;
  case gltf2::json::vrm0::HumanoidBone::BoneName::RIGHT_FOOT:
    return VRM0HumanoidBoneNameRightFoot;
  case gltf2::json::vrm0::HumanoidBone::BoneName::SPINE:
    return VRM0HumanoidBoneNameSpine;
  case gltf2::json::vrm0::HumanoidBone::BoneName::CHEST:
    return VRM0HumanoidBoneNameChest;
  case gltf2::json::vrm0::HumanoidBone::BoneName::NECK:
    return VRM0HumanoidBoneNameNeck;
  case gltf2::json::vrm0::HumanoidBone::BoneName::HEAD:
    return VRM0HumanoidBoneNameHead;
  case gltf2::json::vrm0::HumanoidBone::BoneName::LEFT_SHOULDER:
    return VRM0HumanoidBoneNameLeftShoulder;
  case gltf2::json::vrm0::HumanoidBone::BoneName::RIGHT_SHOULDER:
    return VRM0HumanoidBoneNameRightShoulder;
  case gltf2::json::vrm0::HumanoidBone::BoneName::LEFT_UPPER_ARM:
    return VRM0HumanoidBoneNameLeftUpperArm;
  case gltf2::json::vrm0::HumanoidBone::BoneName::RIGHT_UPPER_ARM:
    return VRM0HumanoidBoneNameRightUpperArm;
  case gltf2::json::vrm0::HumanoidBone::BoneName::LEFT_LOWER_ARM:
    return VRM0HumanoidBoneNameLeftLowerArm;
  case gltf2::json::vrm0::HumanoidBone::BoneName::RIGHT_LOWER_ARM:
    return VRM0HumanoidBoneNameRightLowerArm;
  case gltf2::json::vrm0::HumanoidBone::BoneName::LEFT_HAND:
    return VRM0HumanoidBoneNameLeftHand;
  case gltf2::json::vrm0::HumanoidBone::BoneName::RIGHT_HAND:
    return VRM0HumanoidBoneNameRightHand;
  case gltf2::json::vrm0::HumanoidBone::BoneName::LEFT_TOES:
    return VRM0HumanoidBoneNameLeftToes;
  case gltf2::json::vrm0::HumanoidBone::BoneName::RIGHT_TOES:
    return VRM0HumanoidBoneNameRightToes;
  case gltf2::json::vrm0::HumanoidBone::BoneName::LEFT_EYE:
    return VRM0HumanoidBoneNameLeftEye;
  case gltf2::json::vrm0::HumanoidBone::BoneName::RIGHT_EYE:
    return VRM0HumanoidBoneNameRightEye;
  case gltf2::json::vrm0::HumanoidBone::BoneName::JAW:
    return VRM0HumanoidBoneNameJaw;
  case gltf2::json::vrm0::HumanoidBone::BoneName::LEFT_THUMB_PROXIMAL:
    return VRM0HumanoidBoneNameLeftThumbProximal;
  case gltf2::json::vrm0::HumanoidBone::BoneName::LEFT_THUMB_INTERMEDIATE:
    return VRM0HumanoidBoneNameLeftThumbIntermediate;
  case gltf2::json::vrm0::HumanoidBone::BoneName::LEFT_THUMB_DISTAL:
    return VRM0HumanoidBoneNameLeftThumbDistal;
  case gltf2::json::vrm0::HumanoidBone::BoneName::LEFT_INDEX_PROXIMAL:
    return VRM0HumanoidBoneNameLeftIndexProximal;
  case gltf2::json::vrm0::HumanoidBone::BoneName::LEFT_INDEX_INTERMEDIATE:
    return VRM0HumanoidBoneNameLeftIndexIntermediate;
  case gltf2::json::vrm0::HumanoidBone::BoneName::LEFT_INDEX_DISTAL:
    return VRM0HumanoidBoneNameLeftIndexDistal;
  case gltf2::json::vrm0::HumanoidBone::BoneName::LEFT_MIDDLE_PROXIMAL:
    return VRM0HumanoidBoneNameLeftMiddleProximal;
  case gltf2::json::vrm0::HumanoidBone::BoneName::LEFT_MIDDLE_INTERMEDIATE:
    return VRM0HumanoidBoneNameLeftMiddleIntermediate;
  case gltf2::json::vrm0::HumanoidBone::BoneName::LEFT_MIDDLE_DISTAL:
    return VRM0HumanoidBoneNameLeftMiddleDistal;
  case gltf2::json::vrm0::HumanoidBone::BoneName::LEFT_RING_PROXIMAL:
    return VRM0HumanoidBoneNameLeftRingProximal;
  case gltf2::json::vrm0::HumanoidBone::BoneName::LEFT_RING_INTERMEDIATE:
    return VRM0HumanoidBoneNameLeftRingIntermediate;
  case gltf2::json::vrm0::HumanoidBone::BoneName::LEFT_RING_DISTAL:
    return VRM0HumanoidBoneNameLeftRingDistal;
  case gltf2::json::vrm0::HumanoidBone::BoneName::LEFT_LITTLE_PROXIMAL:
    return VRM0HumanoidBoneNameLeftLittleProximal;
  case gltf2::json::vrm0::HumanoidBone::BoneName::LEFT_LITTLE_INTERMEDIATE:
    return VRM0HumanoidBoneNameLeftLittleIntermediate;
  case gltf2::json::vrm0::HumanoidBone::BoneName::LEFT_LITTLE_DISTAL:
    return VRM0HumanoidBoneNameLeftLittleDistal;
  case gltf2::json::vrm0::HumanoidBone::BoneName::RIGHT_THUMB_PROXIMAL:
    return VRM0HumanoidBoneNameRightThumbProximal;
  case gltf2::json::vrm0::HumanoidBone::BoneName::RIGHT_THUMB_INTERMEDIATE:
    return VRM0HumanoidBoneNameRightThumbIntermediate;
  case gltf2::json::vrm0::HumanoidBone::BoneName::RIGHT_THUMB_DISTAL:
    return VRM0HumanoidBoneNameRightThumbDistal;
  case gltf2::json::vrm0::HumanoidBone::BoneName::RIGHT_INDEX_PROXIMAL:
    return VRM0HumanoidBoneNameRightIndexProximal;
  case gltf2::json::vrm0::HumanoidBone::BoneName::RIGHT_INDEX_INTERMEDIATE:
    return VRM0HumanoidBoneNameRightIndexIntermediate;
  case gltf2::json::vrm0::HumanoidBone::BoneName::RIGHT_INDEX_DISTAL:
    return VRM0HumanoidBoneNameRightIndexDistal;
  case gltf2::json::vrm0::HumanoidBone::BoneName::RIGHT_MIDDLE_PROXIMAL:
    return VRM0HumanoidBoneNameRightMiddleProximal;
  case gltf2::json::vrm0::HumanoidBone::BoneName::RIGHT_MIDDLE_INTERMEDIATE:
    return VRM0HumanoidBoneNameRightMiddleIntermediate;
  case gltf2::json::vrm0::HumanoidBone::BoneName::RIGHT_MIDDLE_DISTAL:
    return VRM0HumanoidBoneNameRightMiddleDistal;
  case gltf2::json::vrm0::HumanoidBone::BoneName::RIGHT_RING_PROXIMAL:
    return VRM0HumanoidBoneNameRightRingProximal;
  case gltf2::json::vrm0::HumanoidBone::BoneName::RIGHT_RING_INTERMEDIATE:
    return VRM0HumanoidBoneNameRightRingIntermediate;
  case gltf2::json::vrm0::HumanoidBone::BoneName::RIGHT_RING_DISTAL:
    return VRM0HumanoidBoneNameRightRingDistal;
  case gltf2::json::vrm0::HumanoidBone::BoneName::RIGHT_LITTLE_PROXIMAL:
    return VRM0HumanoidBoneNameRightLittleProximal;
  case gltf2::json::vrm0::HumanoidBone::BoneName::RIGHT_LITTLE_INTERMEDIATE:
    return VRM0HumanoidBoneNameRightLittleIntermediate;
  case gltf2::json::vrm0::HumanoidBone::BoneName::RIGHT_LITTLE_DISTAL:
    return VRM0HumanoidBoneNameRightLittleDistal;
  case gltf2::json::vrm0::HumanoidBone::BoneName::UPPER_CHEST:
    return VRM0HumanoidBoneNameUpperChest;
  default:
    return VRM0HumanoidBoneNameHips; // Default case
  }
}

+ (VRM0HumanoidBone *)convertVRM0HumanoidBone:
    (const gltf2::json::vrm0::HumanoidBone &)cppBone {
  VRM0HumanoidBone *objcBone = [[VRM0HumanoidBone alloc] init];

  if (cppBone.bone.has_value()) {
    objcBone.bone = [self convertVRM0HumanoidBoneName:cppBone.bone.value()];
  }
  if (cppBone.node.has_value()) {
    objcBone.node = @(cppBone.node.value());
  }
  if (cppBone.useDefaultValues.has_value()) {
    objcBone.useDefaultValues = @(cppBone.useDefaultValues.value());
  }
  if (cppBone.min.has_value()) {
    objcBone.min = [self convertVRM0Vec3:cppBone.min.value()];
  }
  if (cppBone.max.has_value()) {
    objcBone.max = [self convertVRM0Vec3:cppBone.max.value()];
  }
  if (cppBone.center.has_value()) {
    objcBone.center = [self convertVRM0Vec3:cppBone.center.value()];
  }
  if (cppBone.axisLength.has_value()) {
    objcBone.axisLength = @(cppBone.axisLength.value());
  }

  return objcBone;
}

+ (VRM0Humanoid *)convertVRM0Humanoid:
    (const gltf2::json::vrm0::Humanoid &)cppHumanoid {
  VRM0Humanoid *objcHumanoid = [[VRM0Humanoid alloc] init];

  if (cppHumanoid.humanBones.has_value()) {
    NSMutableArray<VRM0HumanoidBone *> *humanBonesArray =
        [NSMutableArray arrayWithCapacity:cppHumanoid.humanBones->size()];
    for (const auto &bone : cppHumanoid.humanBones.value()) {
      [humanBonesArray addObject:[self convertVRM0HumanoidBone:bone]];
    }
    objcHumanoid.humanBones = [humanBonesArray copy];
  }
  if (cppHumanoid.armStretch.has_value()) {
    objcHumanoid.armStretch = @(cppHumanoid.armStretch.value());
  }
  if (cppHumanoid.legStretch.has_value()) {
    objcHumanoid.legStretch = @(cppHumanoid.legStretch.value());
  }
  if (cppHumanoid.upperArmTwist.has_value()) {
    objcHumanoid.upperArmTwist = @(cppHumanoid.upperArmTwist.value());
  }
  if (cppHumanoid.lowerArmTwist.has_value()) {
    objcHumanoid.lowerArmTwist = @(cppHumanoid.lowerArmTwist.value());
  }
  if (cppHumanoid.upperLegTwist.has_value()) {
    objcHumanoid.upperLegTwist = @(cppHumanoid.upperLegTwist.value());
  }
  if (cppHumanoid.lowerLegTwist.has_value()) {
    objcHumanoid.lowerLegTwist = @(cppHumanoid.lowerLegTwist.value());
  }
  if (cppHumanoid.feetSpacing.has_value()) {
    objcHumanoid.feetSpacing = @(cppHumanoid.feetSpacing.value());
  }
  if (cppHumanoid.hasTranslationDoF.has_value()) {
    objcHumanoid.hasTranslationDoF = @(cppHumanoid.hasTranslationDoF.value());
  }

  return objcHumanoid;
}

+ (NSString *)convertVRM0MetaAllowedUserName:
    (gltf2::json::vrm0::Meta::AllowedUserName)allowedUserName {
  switch (allowedUserName) {
  case gltf2::json::vrm0::Meta::AllowedUserName::ONLY_AUTHOR:
    return VRM0MetaAllowedUserNameOnlyAuthor;
  case gltf2::json::vrm0::Meta::AllowedUserName::EXPLICITLY_LICENSED_PERSON:
    return VRM0MetaAllowedUserNameExplicitlyLicensedPerson;
  case gltf2::json::vrm0::Meta::AllowedUserName::EVERYONE:
    return VRM0MetaAllowedUserNameEveryone;
  default:
    return VRM0MetaAllowedUserNameOnlyAuthor; // Default case
  }
}

+ (NSString *)convertVRM0MetaUsagePermission:
    (gltf2::json::vrm0::Meta::UsagePermission)usagePermission {
  switch (usagePermission) {
  case gltf2::json::vrm0::Meta::UsagePermission::DISALLOW:
    return VRM0MetaUsagePermissionDisallow;
  case gltf2::json::vrm0::Meta::UsagePermission::ALLOW:
    return VRM0MetaUsagePermissionAllow;
  default:
    return VRM0MetaUsagePermissionDisallow; // Default case
  }
}

+ (NSString *)convertVRM0MetaLicenseName:
    (gltf2::json::vrm0::Meta::LicenseName)licenseName {
  switch (licenseName) {
  case gltf2::json::vrm0::Meta::LicenseName::REDISTRIBUTION_PROHIBITED:
    return VRM0MetaLicenseNameRedistributionProhibited;
  case gltf2::json::vrm0::Meta::LicenseName::CC0:
    return VRM0MetaLicenseNameCC0;
  case gltf2::json::vrm0::Meta::LicenseName::CC_BY:
    return VRM0MetaLicenseNameCCBY;
  case gltf2::json::vrm0::Meta::LicenseName::CC_BY_NC:
    return VRM0MetaLicenseNameCCBYNC;
  case gltf2::json::vrm0::Meta::LicenseName::CC_BY_SA:
    return VRM0MetaLicenseNameCCBYSA;
  case gltf2::json::vrm0::Meta::LicenseName::CC_BY_NC_SA:
    return VRM0MetaLicenseNameCCBYNCSA;
  case gltf2::json::vrm0::Meta::LicenseName::CC_BY_ND:
    return VRM0MetaLicenseNameCCBYND;
  case gltf2::json::vrm0::Meta::LicenseName::CC_BY_NC_ND:
    return VRM0MetaLicenseNameCCBYNCND;
  case gltf2::json::vrm0::Meta::LicenseName::OTHER:
    return VRM0MetaLicenseNameOther;
  default:
    return VRM0MetaLicenseNameRedistributionProhibited; // Default case
  }
}

+ (VRM0Meta *)convertVRM0Meta:(const gltf2::json::vrm0::Meta &)cppMeta {
  VRM0Meta *objcMeta = [[VRM0Meta alloc] init];

  if (cppMeta.title.has_value()) {
    objcMeta.title = [NSString stringWithUTF8String:cppMeta.title->c_str()];
  }
  if (cppMeta.version.has_value()) {
    objcMeta.version = [NSString stringWithUTF8String:cppMeta.version->c_str()];
  }
  if (cppMeta.author.has_value()) {
    objcMeta.author = [NSString stringWithUTF8String:cppMeta.author->c_str()];
  }
  if (cppMeta.contactInformation.has_value()) {
    objcMeta.contactInformation =
        [NSString stringWithUTF8String:cppMeta.contactInformation->c_str()];
  }
  if (cppMeta.reference.has_value()) {
    objcMeta.reference =
        [NSString stringWithUTF8String:cppMeta.reference->c_str()];
  }
  if (cppMeta.texture.has_value()) {
    objcMeta.texture = @(cppMeta.texture.value());
  }
  if (cppMeta.allowedUserName.has_value()) {
    objcMeta.allowedUserName =
        [self convertVRM0MetaAllowedUserName:cppMeta.allowedUserName.value()];
  }
  if (cppMeta.violentUsage.has_value()) {
    objcMeta.violentUsage =
        [self convertVRM0MetaUsagePermission:cppMeta.violentUsage.value()];
  }
  if (cppMeta.sexualUsage.has_value()) {
    objcMeta.sexualUsage =
        [self convertVRM0MetaUsagePermission:cppMeta.sexualUsage.value()];
  }
  if (cppMeta.commercialUsage.has_value()) {
    objcMeta.commercialUsage =
        [self convertVRM0MetaUsagePermission:cppMeta.commercialUsage.value()];
  }
  if (cppMeta.otherPermissionUrl.has_value()) {
    objcMeta.otherPermissionUrl =
        [NSString stringWithUTF8String:cppMeta.otherPermissionUrl->c_str()];
  }
  if (cppMeta.licenseName.has_value()) {
    objcMeta.licenseName =
        [self convertVRM0MetaLicenseName:cppMeta.licenseName.value()];
  }
  if (cppMeta.otherLicenseUrl.has_value()) {
    objcMeta.otherLicenseUrl =
        [NSString stringWithUTF8String:cppMeta.otherLicenseUrl->c_str()];
  }

  return objcMeta;
}

+ (VRM0FirstPersonMeshAnnotation *)convertVRM0FirstPersonMeshAnnotation:
    (const gltf2::json::vrm0::FirstPersonMeshAnnotation &)cppAnnotation {
  VRM0FirstPersonMeshAnnotation *objcAnnotation =
      [[VRM0FirstPersonMeshAnnotation alloc] init];

  if (cppAnnotation.mesh.has_value()) {
    objcAnnotation.mesh = @(cppAnnotation.mesh.value());
  }
  if (cppAnnotation.firstPersonFlag.has_value()) {
    objcAnnotation.firstPersonFlag =
        [NSString stringWithUTF8String:cppAnnotation.firstPersonFlag->c_str()];
  }

  return objcAnnotation;
}

+ (VRM0FirstPersonDegreeMapCurve *)convertVRM0FirstPersonDegreeMapCurve:
    (const gltf2::json::vrm0::FirstPersonDegreeMapCurve &)cppMapping {
  VRM0FirstPersonDegreeMapCurve *objcMapping =
      [[VRM0FirstPersonDegreeMapCurve alloc] init];
  objcMapping.time = cppMapping.time;
  objcMapping.value = cppMapping.value;
  objcMapping.inTangent = cppMapping.inTangent;
  objcMapping.outTangent = cppMapping.outTangent;
  return objcMapping;
}

+ (VRM0FirstPersonDegreeMap *)convertVRM0FirstPersonDegreeMap:
    (const gltf2::json::vrm0::FirstPersonDegreeMap &)cppDegreeMap {
  VRM0FirstPersonDegreeMap *objcDegreeMap =
      [[VRM0FirstPersonDegreeMap alloc] init];

  if (cppDegreeMap.curve.has_value()) {
    NSMutableArray<VRM0FirstPersonDegreeMapCurve *> *curves =
        [NSMutableArray array];
    for (const auto &cppMapping : *cppDegreeMap.curve) {
      [curves addObject:[self convertVRM0FirstPersonDegreeMapCurve:cppMapping]];
    }
    objcDegreeMap.curve = [curves copy];
  }
  if (cppDegreeMap.xRange.has_value()) {
    objcDegreeMap.xRange = @(cppDegreeMap.xRange.value());
  }
  if (cppDegreeMap.yRange.has_value()) {
    objcDegreeMap.yRange = @(cppDegreeMap.yRange.value());
  }

  return objcDegreeMap;
}

+ (NSString *)convertVRM0FirstPersonLookAtType:
    (gltf2::json::vrm0::FirstPerson::LookAtType)lookAtType {
  switch (lookAtType) {
  case gltf2::json::vrm0::FirstPerson::LookAtType::BONE:
    return VRM0FirstPersonLookAtTypeBone;
  case gltf2::json::vrm0::FirstPerson::LookAtType::BLEND_SHAPE:
    return VRM0FirstPersonLookAtTypeBlendShape;
  default:
    return @"";
  }
}

+ (VRM0FirstPerson *)convertVRM0FirstPerson:
    (const gltf2::json::vrm0::FirstPerson &)cppFirstPerson {
  VRM0FirstPerson *objcFirstPerson = [[VRM0FirstPerson alloc] init];

  if (cppFirstPerson.firstPersonBone.has_value()) {
    objcFirstPerson.firstPersonBone = @(cppFirstPerson.firstPersonBone.value());
  }
  if (cppFirstPerson.firstPersonBoneOffset.has_value()) {
    objcFirstPerson.firstPersonBoneOffset =
        [self convertVRM0Vec3:cppFirstPerson.firstPersonBoneOffset.value()];
  }
  if (cppFirstPerson.meshAnnotations.has_value()) {
    NSMutableArray<VRM0FirstPersonMeshAnnotation *> *annotationsArray =
        [NSMutableArray
            arrayWithCapacity:cppFirstPerson.meshAnnotations->size()];
    for (const auto &annotation : cppFirstPerson.meshAnnotations.value()) {
      [annotationsArray
          addObject:[self convertVRM0FirstPersonMeshAnnotation:annotation]];
    }
    objcFirstPerson.meshAnnotations = [annotationsArray copy];
  }
  if (cppFirstPerson.lookAtTypeName.has_value()) {
    objcFirstPerson.lookAtTypeName =
        [self convertVRM0FirstPersonLookAtType:*cppFirstPerson.lookAtTypeName];
  }
  if (cppFirstPerson.lookAtHorizontalInner.has_value()) {
    objcFirstPerson.lookAtHorizontalInner = [self
        convertVRM0FirstPersonDegreeMap:cppFirstPerson.lookAtHorizontalInner
                                            .value()];
  }
  if (cppFirstPerson.lookAtHorizontalOuter.has_value()) {
    objcFirstPerson.lookAtHorizontalOuter = [self
        convertVRM0FirstPersonDegreeMap:cppFirstPerson.lookAtHorizontalOuter
                                            .value()];
  }
  if (cppFirstPerson.lookAtVerticalDown.has_value()) {
    objcFirstPerson.lookAtVerticalDown =
        [self convertVRM0FirstPersonDegreeMap:cppFirstPerson.lookAtVerticalDown
                                                  .value()];
  }
  if (cppFirstPerson.lookAtVerticalUp.has_value()) {
    objcFirstPerson.lookAtVerticalUp =
        [self convertVRM0FirstPersonDegreeMap:cppFirstPerson.lookAtVerticalUp
                                                  .value()];
  }

  return objcFirstPerson;
}

+ (VRM0BlendShapeBind *)convertVRM0BlendShapeBind:
    (const gltf2::json::vrm0::BlendShapeBind &)cppBind {
  VRM0BlendShapeBind *objcBind = [[VRM0BlendShapeBind alloc] init];

  if (cppBind.mesh.has_value()) {
    objcBind.mesh = @(cppBind.mesh.value());
  }
  if (cppBind.index.has_value()) {
    objcBind.index = @(cppBind.index.value());
  }
  if (cppBind.weight.has_value()) {
    objcBind.weight = @(cppBind.weight.value());
  }

  return objcBind;
}

+ (VRM0BlendShapeMaterialBind *)convertVRM0BlendShapeMaterialBind:
    (const gltf2::json::vrm0::BlendShapeMaterialBind &)cppBind {
  VRM0BlendShapeMaterialBind *objcBind =
      [[VRM0BlendShapeMaterialBind alloc] init];

  if (cppBind.materialName.has_value()) {
    objcBind.materialName =
        [NSString stringWithUTF8String:cppBind.materialName->c_str()];
  }
  if (cppBind.propertyName.has_value()) {
    objcBind.propertyName =
        [NSString stringWithUTF8String:cppBind.propertyName->c_str()];
  }
  if (cppBind.targetValue.has_value()) {
    NSMutableArray<NSNumber *> *targetValueArray =
        [NSMutableArray arrayWithCapacity:cppBind.targetValue->size()];
    for (const auto &value : cppBind.targetValue.value()) {
      [targetValueArray addObject:@(value)];
    }
    objcBind.targetValue = [targetValueArray copy];
  }

  return objcBind;
}

+ (NSString *)convertVRM0BlendShapeGroupPresetName:
    (gltf2::json::vrm0::BlendShapeGroup::PresetName)presetName {
  switch (presetName) {
  case gltf2::json::vrm0::BlendShapeGroup::PresetName::UNKNOWN:
    return VRM0BlendShapeGroupPresetNameUnknown;
  case gltf2::json::vrm0::BlendShapeGroup::PresetName::NEUTRAL:
    return VRM0BlendShapeGroupPresetNameNeutral;
  case gltf2::json::vrm0::BlendShapeGroup::PresetName::A:
    return VRM0BlendShapeGroupPresetNameA;
  case gltf2::json::vrm0::BlendShapeGroup::PresetName::I:
    return VRM0BlendShapeGroupPresetNameI;
  case gltf2::json::vrm0::BlendShapeGroup::PresetName::U:
    return VRM0BlendShapeGroupPresetNameU;
  case gltf2::json::vrm0::BlendShapeGroup::PresetName::E:
    return VRM0BlendShapeGroupPresetNameE;
  case gltf2::json::vrm0::BlendShapeGroup::PresetName::O:
    return VRM0BlendShapeGroupPresetNameO;
  case gltf2::json::vrm0::BlendShapeGroup::PresetName::BLINK:
    return VRM0BlendShapeGroupPresetNameBlink;
  case gltf2::json::vrm0::BlendShapeGroup::PresetName::JOY:
    return VRM0BlendShapeGroupPresetNameJoy;
  case gltf2::json::vrm0::BlendShapeGroup::PresetName::ANGRY:
    return VRM0BlendShapeGroupPresetNameAngry;
  case gltf2::json::vrm0::BlendShapeGroup::PresetName::SORROW:
    return VRM0BlendShapeGroupPresetNameSorrow;
  case gltf2::json::vrm0::BlendShapeGroup::PresetName::FUN:
    return VRM0BlendShapeGroupPresetNameFun;
  case gltf2::json::vrm0::BlendShapeGroup::PresetName::LOOKUP:
    return VRM0BlendShapeGroupPresetNameLookUp;
  case gltf2::json::vrm0::BlendShapeGroup::PresetName::LOOKDOWN:
    return VRM0BlendShapeGroupPresetNameLookDown;
  case gltf2::json::vrm0::BlendShapeGroup::PresetName::LOOKLEFT:
    return VRM0BlendShapeGroupPresetNameLookLeft;
  case gltf2::json::vrm0::BlendShapeGroup::PresetName::LOOKRIGHT:
    return VRM0BlendShapeGroupPresetNameLookRight;
  case gltf2::json::vrm0::BlendShapeGroup::PresetName::BLINK_L:
    return VRM0BlendShapeGroupPresetNameBlinkL;
  case gltf2::json::vrm0::BlendShapeGroup::PresetName::BLINK_R:
    return VRM0BlendShapeGroupPresetNameBlinkR;
  default:
    return VRM0BlendShapeGroupPresetNameUnknown; // Default case
  }
}

+ (VRM0BlendShapeGroup *)convertVRM0BlendShapeGroup:
    (const gltf2::json::vrm0::BlendShapeGroup &)cppGroup {
  VRM0BlendShapeGroup *objcGroup = [[VRM0BlendShapeGroup alloc] init];

  if (cppGroup.name.has_value()) {
    objcGroup.name = [NSString stringWithUTF8String:cppGroup.name->c_str()];
  }
  if (cppGroup.presetName.has_value()) {
    objcGroup.presetName =
        [self convertVRM0BlendShapeGroupPresetName:cppGroup.presetName.value()];
  }
  if (cppGroup.binds.has_value()) {
    NSMutableArray<VRM0BlendShapeBind *> *bindsArray =
        [NSMutableArray arrayWithCapacity:cppGroup.binds->size()];
    for (const auto &bind : cppGroup.binds.value()) {
      [bindsArray addObject:[self convertVRM0BlendShapeBind:bind]];
    }
    objcGroup.binds = [bindsArray copy];
  }
  if (cppGroup.materialValues.has_value()) {
    NSMutableArray<VRM0BlendShapeMaterialBind *> *materialValuesArray =
        [NSMutableArray arrayWithCapacity:cppGroup.materialValues->size()];
    for (const auto &materialValue : cppGroup.materialValues.value()) {
      [materialValuesArray
          addObject:[self convertVRM0BlendShapeMaterialBind:materialValue]];
    }
    objcGroup.materialValues = [materialValuesArray copy];
  }
  objcGroup.isBinary = cppGroup.isBinaryValue();

  return objcGroup;
}

+ (VRM0BlendShape *)convertVRM0BlendShape:
    (const gltf2::json::vrm0::BlendShape &)cppBlendShape {
  VRM0BlendShape *objcBlendShape = [[VRM0BlendShape alloc] init];

  if (cppBlendShape.blendShapeGroups.has_value()) {
    NSMutableArray<VRM0BlendShapeGroup *> *blendShapeGroupsArray =
        [NSMutableArray
            arrayWithCapacity:cppBlendShape.blendShapeGroups->size()];
    for (const auto &blendShapeGroup : cppBlendShape.blendShapeGroups.value()) {
      [blendShapeGroupsArray
          addObject:[self convertVRM0BlendShapeGroup:blendShapeGroup]];
    }
    objcBlendShape.blendShapeGroups = [blendShapeGroupsArray copy];
  }

  return objcBlendShape;
}

+ (VRM0SecondaryAnimationCollider *)convertVRM0SecondaryAnimationCollider:
    (const gltf2::json::vrm0::SecondaryAnimationCollider &)cppCollider {
  VRM0SecondaryAnimationCollider *objcCollider =
      [[VRM0SecondaryAnimationCollider alloc] init];

  if (cppCollider.offset.has_value()) {
    objcCollider.offset = [self convertVRM0Vec3:cppCollider.offset.value()];
  }
  if (cppCollider.radius.has_value()) {
    objcCollider.radius = @(cppCollider.radius.value());
  }

  return objcCollider;
}

+ (VRM0SecondaryAnimationColliderGroup *)
    convertVRM0SecondaryAnimationColliderGroup:
        (const gltf2::json::vrm0::SecondaryAnimationColliderGroup &)
            cppColliderGroup {
  VRM0SecondaryAnimationColliderGroup *objcColliderGroup =
      [[VRM0SecondaryAnimationColliderGroup alloc] init];

  if (cppColliderGroup.node.has_value()) {
    objcColliderGroup.node = @(cppColliderGroup.node.value());
  }
  if (cppColliderGroup.colliders.has_value()) {
    NSMutableArray<VRM0SecondaryAnimationCollider *> *collidersArray =
        [NSMutableArray arrayWithCapacity:cppColliderGroup.colliders->size()];
    for (const auto &collider : cppColliderGroup.colliders.value()) {
      [collidersArray
          addObject:[self convertVRM0SecondaryAnimationCollider:collider]];
    }
    objcColliderGroup.colliders = [collidersArray copy];
  }

  return objcColliderGroup;
}

+ (VRM0SecondaryAnimationSpring *)convertVRM0SecondaryAnimationSpring:
    (const gltf2::json::vrm0::SecondaryAnimationSpring &)cppSpring {
  VRM0SecondaryAnimationSpring *objcSpring =
      [[VRM0SecondaryAnimationSpring alloc] init];

  if (cppSpring.comment.has_value()) {
    objcSpring.comment =
        [NSString stringWithUTF8String:cppSpring.comment->c_str()];
  }
  if (cppSpring.stiffiness.has_value()) {
    objcSpring.stiffiness = @(cppSpring.stiffiness.value());
  }
  if (cppSpring.gravityPower.has_value()) {
    objcSpring.gravityPower = @(cppSpring.gravityPower.value());
  }
  if (cppSpring.gravityDir.has_value()) {
    objcSpring.gravityDir = [self convertVRM0Vec3:cppSpring.gravityDir.value()];
  }
  if (cppSpring.dragForce.has_value()) {
    objcSpring.dragForce = @(cppSpring.dragForce.value());
  }
  if (cppSpring.center.has_value()) {
    objcSpring.center = @(cppSpring.center.value());
  }
  if (cppSpring.hitRadius.has_value()) {
    objcSpring.hitRadius = @(cppSpring.hitRadius.value());
  }
  if (cppSpring.bones.has_value()) {
    NSMutableArray<NSNumber *> *bones =
        [NSMutableArray arrayWithCapacity:cppSpring.bones->size()];
    for (const auto bone : *cppSpring.bones) {
      [bones addObject:@(bone)];
    }
    objcSpring.bones = [bones copy];
  }
  if (cppSpring.colliderGroups.has_value()) {
    NSMutableArray<NSNumber *> *colliderGroups =
        [NSMutableArray arrayWithCapacity:cppSpring.colliderGroups->size()];
    for (const auto colliderGroup : *cppSpring.colliderGroups) {
      [colliderGroups addObject:@(colliderGroup)];
    }
    objcSpring.colliderGroups = [colliderGroups copy];
  }

  return objcSpring;
}

+ (VRM0SecondaryAnimation *)convertVRM0SecondaryAnimation:
    (const gltf2::json::vrm0::SecondaryAnimation &)cppSecondaryAnimation {
  VRM0SecondaryAnimation *objcSecondaryAnimation =
      [[VRM0SecondaryAnimation alloc] init];

  if (cppSecondaryAnimation.boneGroups.has_value()) {
    NSMutableArray<VRM0SecondaryAnimationSpring *> *boneGroupsArray =
        [NSMutableArray array];
    for (const auto &boneGroup : cppSecondaryAnimation.boneGroups.value()) {
      [boneGroupsArray
          addObject:[self convertVRM0SecondaryAnimationSpring:boneGroup]];
    }
    objcSecondaryAnimation.boneGroups = boneGroupsArray;
  }
  if (cppSecondaryAnimation.colliderGroups.has_value()) {
    NSMutableArray<VRM0SecondaryAnimationColliderGroup *> *colliderGroupsArray =
        [NSMutableArray array];
    for (const auto &colliderGroup :
         cppSecondaryAnimation.colliderGroups.value()) {
      [colliderGroupsArray
          addObject:
              [self convertVRM0SecondaryAnimationColliderGroup:colliderGroup]];
    }
    objcSecondaryAnimation.colliderGroups = colliderGroupsArray;
  }

  return objcSecondaryAnimation;
}

+ (VRM0Material *)convertVRM0Material:
    (const gltf2::json::vrm0::Material &)cppMaterial {
  VRM0Material *objcMaterial = [[VRM0Material alloc] init];

  if (cppMaterial.name.has_value()) {
    objcMaterial.name =
        [NSString stringWithUTF8String:cppMaterial.name->c_str()];
  }
  if (cppMaterial.shader.has_value()) {
    objcMaterial.shader =
        [NSString stringWithUTF8String:cppMaterial.shader->c_str()];
  }
  if (cppMaterial.renderQueue.has_value()) {
    objcMaterial.renderQueue = @(cppMaterial.renderQueue.value());
  }
  if (cppMaterial.floatProperties.has_value()) {
    NSMutableDictionary<NSString *, NSNumber *> *floatPropertiesDict =
        [NSMutableDictionary dictionary];
    for (const auto &pair : cppMaterial.floatProperties.value()) {
      NSString *key = [NSString stringWithUTF8String:pair.first.c_str()];
      NSNumber *value = @(pair.second);
      [floatPropertiesDict setObject:value forKey:key];
    }
    objcMaterial.floatProperties = floatPropertiesDict;
  }
  if (cppMaterial.vectorProperties.has_value()) {
    NSMutableDictionary<NSString *, NSArray<NSNumber *> *>
        *vectorPropertiesDict = [NSMutableDictionary dictionary];
    for (const auto &pair : cppMaterial.vectorProperties.value()) {
      NSString *key = [NSString stringWithUTF8String:pair.first.c_str()];
      NSMutableArray<NSNumber *> *valueArray = [NSMutableArray array];
      for (const auto &value : pair.second) {
        [valueArray addObject:@(value)];
      }
      [vectorPropertiesDict setObject:valueArray forKey:key];
    }
    objcMaterial.vectorProperties = vectorPropertiesDict;
  }
  if (cppMaterial.textureProperties.has_value()) {
    NSMutableDictionary<NSString *, NSNumber *> *texturePropertiesDict =
        [NSMutableDictionary dictionary];
    for (const auto &pair : cppMaterial.textureProperties.value()) {
      NSString *key = [NSString stringWithUTF8String:pair.first.c_str()];
      NSNumber *value = @(pair.second);
      [texturePropertiesDict setObject:value forKey:key];
    }
    objcMaterial.textureProperties = texturePropertiesDict;
  }
  if (cppMaterial.keywordMap.has_value()) {
    NSMutableDictionary<NSString *, NSNumber *> *keywordMapDict =
        [NSMutableDictionary dictionary];
    for (const auto &pair : cppMaterial.keywordMap.value()) {
      NSString *key = [NSString stringWithUTF8String:pair.first.c_str()];
      NSNumber *value = @(pair.second);
      [keywordMapDict setObject:value forKey:key];
    }
    objcMaterial.keywordMap = keywordMapDict;
  }
  if (cppMaterial.tagMap.has_value()) {
    NSMutableDictionary<NSString *, NSString *> *tagMapDict =
        [NSMutableDictionary dictionary];
    for (const auto &pair : cppMaterial.tagMap.value()) {
      NSString *key = [NSString stringWithUTF8String:pair.first.c_str()];
      NSString *value = [NSString stringWithUTF8String:pair.second.c_str()];
      [tagMapDict setObject:value forKey:key];
    }
    objcMaterial.tagMap = tagMapDict;
  }

  return objcMaterial;
}

+ (VRM0VRM *)convertVRM0VRM:(const gltf2::json::vrm0::VRM &)cppVRM0 {
  VRM0VRM *objcVRM0 = [[VRM0VRM alloc] init];

  if (cppVRM0.exporterVersion.has_value()) {
    objcVRM0.exporterVersion =
        [NSString stringWithUTF8String:cppVRM0.exporterVersion->c_str()];
  }
  if (cppVRM0.specVersion.has_value()) {
    objcVRM0.specVersion =
        [NSString stringWithUTF8String:cppVRM0.specVersion->c_str()];
  }
  if (cppVRM0.meta.has_value()) {
    objcVRM0.meta = [JsonConverter convertVRM0Meta:cppVRM0.meta.value()];
  }
  if (cppVRM0.humanoid.has_value()) {
    objcVRM0.humanoid =
        [JsonConverter convertVRM0Humanoid:cppVRM0.humanoid.value()];
  }
  if (cppVRM0.firstPerson.has_value()) {
    objcVRM0.firstPerson =
        [JsonConverter convertVRM0FirstPerson:cppVRM0.firstPerson.value()];
  }
  if (cppVRM0.blendShapeMaster.has_value()) {
    objcVRM0.blendShapeMaster =
        [JsonConverter convertVRM0BlendShape:cppVRM0.blendShapeMaster.value()];
  }
  if (cppVRM0.secondaryAnimation.has_value()) {
    objcVRM0.secondaryAnimation = [JsonConverter
        convertVRM0SecondaryAnimation:cppVRM0.secondaryAnimation.value()];
  }
  if (cppVRM0.materialProperties.has_value()) {
    NSMutableArray<VRM0Material *> *materialsArray = [NSMutableArray array];
    for (const auto &material : cppVRM0.materialProperties.value()) {
      [materialsArray addObject:[JsonConverter convertVRM0Material:material]];
    }
    objcVRM0.materialProperties = materialsArray;
  }

  return objcVRM0;
}

+ (VRMSpringBone *)convertSpringBone:
    (const gltf2::json::vrmc::SpringBone &)cppSpringBone {
  VRMSpringBone *objcSpringBone = [[VRMSpringBone alloc] init];
  objcSpringBone.specVersion =
      [NSString stringWithUTF8String:cppSpringBone.specVersion.c_str()];

  // Convert colliders if present
  if (cppSpringBone.colliders.has_value()) {
    NSMutableArray<VRMSpringBoneCollider *> *collidersArray =
        [NSMutableArray array];
    for (const auto &collider : cppSpringBone.colliders.value()) {
      VRMSpringBoneCollider *objcCollider =
          [JsonConverter convertSpringBoneCollider:collider];
      [collidersArray addObject:objcCollider];
    }
    objcSpringBone.colliders = collidersArray;
  }

  if (cppSpringBone.colliderGroups.has_value()) {
    NSMutableArray<VRMSpringBoneColliderGroup *> *colliderGroupsArray =
        [NSMutableArray array];
    for (const auto &colliderGroup : cppSpringBone.colliderGroups.value()) {
      VRMSpringBoneColliderGroup *objcColliderGroup =
          [JsonConverter convertSpringBoneColliderGroup:colliderGroup];
      [colliderGroupsArray addObject:objcColliderGroup];
    }
    objcSpringBone.colliderGroups = colliderGroupsArray;
  }

  if (cppSpringBone.springs.has_value()) {
    NSMutableArray<VRMSpringBoneSpring *> *springsArray =
        [NSMutableArray array];
    for (const auto &spring : cppSpringBone.springs.value()) {
      VRMSpringBoneSpring *objcSpring =
          [JsonConverter convertSpringBoneSpring:spring];
      [springsArray addObject:objcSpring];
    }
    objcSpringBone.springs = springsArray;
  }

  return objcSpringBone;
}

+ (VRMSpringBoneCollider *)convertSpringBoneCollider:
    (const gltf2::json::vrmc::SpringBoneCollider &)cppCollider {
  VRMSpringBoneCollider *objcCollider = [[VRMSpringBoneCollider alloc] init];
  objcCollider.node = cppCollider.node;
  objcCollider.shape = [JsonConverter convertSpringBoneShape:cppCollider.shape];
  return objcCollider;
}

+ (VRMSpringBoneShape *)convertSpringBoneShape:
    (const gltf2::json::vrmc::SpringBoneShape &)cppShape {
  VRMSpringBoneShape *objcShape = [[VRMSpringBoneShape alloc] init];
  if (cppShape.sphere.has_value()) {
    objcShape.sphere =
        [JsonConverter convertSpringBoneShapeSphere:cppShape.sphere.value()];
  }
  if (cppShape.capsule.has_value()) {
    objcShape.capsule =
        [JsonConverter convertSpringBoneShapeCapsule:cppShape.capsule.value()];
  }
  return objcShape;
}

+ (VRMSpringBoneShapeSphere *)convertSpringBoneShapeSphere:
    (const gltf2::json::vrmc::SpringBoneShapeSphere &)cppSphere {
  VRMSpringBoneShapeSphere *objcSphere =
      [[VRMSpringBoneShapeSphere alloc] init];
  if (cppSphere.offset.has_value()) {
    objcSphere.offset = [[Vec3 alloc] initWithX:cppSphere.offset->at(0)
                                              Y:cppSphere.offset->at(1)
                                              Z:cppSphere.offset->at(2)];
  }
  if (cppSphere.radius.has_value()) {
    objcSphere.radius = @(cppSphere.radius.value());
  }
  return objcSphere;
}

+ (VRMSpringBoneShapeCapsule *)convertSpringBoneShapeCapsule:
    (const gltf2::json::vrmc::SpringBoneShapeCapsule &)cppCapsule {
  VRMSpringBoneShapeCapsule *objcCapsule =
      [[VRMSpringBoneShapeCapsule alloc] init];
  if (cppCapsule.offset.has_value()) {
    objcCapsule.offset = [[Vec3 alloc] initWithX:cppCapsule.offset->at(0)
                                               Y:cppCapsule.offset->at(1)
                                               Z:cppCapsule.offset->at(2)];
  }
  if (cppCapsule.radius.has_value()) {
    objcCapsule.radius = @(cppCapsule.radius.value());
  }
  if (cppCapsule.tail.has_value()) {
    objcCapsule.tail = [[Vec3 alloc] initWithX:cppCapsule.tail->at(0)
                                             Y:cppCapsule.tail->at(1)
                                             Z:cppCapsule.tail->at(2)];
  }
  return objcCapsule;
}

+ (VRMSpringBoneColliderGroup *)convertSpringBoneColliderGroup:
    (const gltf2::json::vrmc::SpringBoneColliderGroup &)cppColliderGroup {
  VRMSpringBoneColliderGroup *objcColliderGroup =
      [[VRMSpringBoneColliderGroup alloc] init];
  if (cppColliderGroup.name.has_value()) {
    objcColliderGroup.name =
        [NSString stringWithUTF8String:cppColliderGroup.name->c_str()];
  }
  NSMutableArray<NSNumber *> *colliders = [NSMutableArray array];
  for (auto collider : cppColliderGroup.colliders) {
    [colliders addObject:@(collider)];
  }
  objcColliderGroup.colliders = colliders;
  return objcColliderGroup;
}

+ (VRMSpringBoneSpring *)convertSpringBoneSpring:
    (const gltf2::json::vrmc::SpringBoneSpring &)cppSpring {
  VRMSpringBoneSpring *objcSpring = [[VRMSpringBoneSpring alloc] init];
  if (cppSpring.name.has_value()) {
    objcSpring.name = [NSString stringWithUTF8String:cppSpring.name->c_str()];
  }
  NSMutableArray<VRMSpringBoneJoint *> *joints = [NSMutableArray array];
  for (const auto &joint : cppSpring.joints) {
    [joints addObject:[JsonConverter convertSpringBoneJoint:joint]];
  }
  objcSpring.joints = joints;

  if (cppSpring.colliderGroups.has_value()) {
    NSMutableArray<NSNumber *> *colliderGroups = [NSMutableArray array];
    for (auto group : *cppSpring.colliderGroups) {
      [colliderGroups addObject:@(group)];
    }
    objcSpring.colliderGroups = colliderGroups;
  }

  if (cppSpring.center.has_value()) {
    objcSpring.center = @(cppSpring.center.value());
  }
  return objcSpring;
}

+ (VRMSpringBoneJoint *)convertSpringBoneJoint:
    (const gltf2::json::vrmc::SpringBoneJoint &)cppJoint {
  VRMSpringBoneJoint *objcJoint = [[VRMSpringBoneJoint alloc] init];
  objcJoint.node = cppJoint.node;
  if (cppJoint.hitRadius.has_value()) {
    objcJoint.hitRadius = @(cppJoint.hitRadius.value());
  }
  if (cppJoint.stiffness.has_value()) {
    objcJoint.stiffness = @(cppJoint.stiffness.value());
  }
  if (cppJoint.gravityPower.has_value()) {
    objcJoint.gravityPower = @(cppJoint.gravityPower.value());
  }
  if (cppJoint.gravityDir.has_value()) {
    objcJoint.gravityDir = [[Vec3 alloc] initWithX:cppJoint.gravityDir->at(0)
                                                 Y:cppJoint.gravityDir->at(1)
                                                 Z:cppJoint.gravityDir->at(2)];
  }
  if (cppJoint.dragForce.has_value()) {
    objcJoint.dragForce = @(cppJoint.dragForce.value());
  }
  return objcJoint;
}

+ (GLTFJson *)convertGLTFJson:(const gltf2::json::Json &)cppJson {
  GLTFJson *objcJson = [[GLTFJson alloc] init];

  if (cppJson.extensionsUsed.has_value()) {
    NSMutableArray<NSString *> *extensionsUsed =
        [NSMutableArray arrayWithCapacity:cppJson.extensionsUsed->size()];
    for (const auto &value : *cppJson.extensionsUsed) {
      [extensionsUsed
          addObject:[NSString
                        stringWithCString:value.c_str()
                                 encoding:[NSString defaultCStringEncoding]]];
    }
    objcJson.extensionsUsed = [extensionsUsed copy];
  }
  if (cppJson.extensionsRequired.has_value()) {
    NSMutableArray<NSString *> *extensionsRequired =
        [NSMutableArray arrayWithCapacity:cppJson.extensionsRequired->size()];
    for (const auto &value : *cppJson.extensionsRequired) {
      [extensionsRequired
          addObject:[NSString
                        stringWithCString:value.c_str()
                                 encoding:[NSString defaultCStringEncoding]]];
    }
    objcJson.extensionsRequired = [extensionsRequired copy];
  }
  if (cppJson.accessors.has_value()) {
    NSMutableArray<GLTFAccessor *> *accessorsArray =
        [NSMutableArray arrayWithCapacity:cppJson.accessors->size()];
    for (const auto &accessor : cppJson.accessors.value()) {
      [accessorsArray addObject:[JsonConverter convertGLTFAccessor:accessor]];
    }
    objcJson.accessors = [accessorsArray copy];
  }
  if (cppJson.animations.has_value()) {
    NSMutableArray<GLTFAnimation *> *animationsArray =
        [NSMutableArray arrayWithCapacity:cppJson.animations->size()];
    for (const auto &animation : cppJson.animations.value()) {
      [animationsArray
          addObject:[JsonConverter convertGLTFAnimation:animation]];
    }
    objcJson.animations = [animationsArray copy];
  }
  objcJson.asset = [JsonConverter convertGLTFAsset:cppJson.asset];
  if (cppJson.buffers.has_value()) {
    NSMutableArray<GLTFBuffer *> *buffersArray =
        [NSMutableArray arrayWithCapacity:cppJson.buffers->size()];
    for (const auto &buffer : cppJson.buffers.value()) {
      [buffersArray addObject:[JsonConverter convertGLTFBuffer:buffer]];
    }
    objcJson.buffers = [buffersArray copy];
  }
  if (cppJson.bufferViews.has_value()) {
    NSMutableArray<GLTFBufferView *> *bufferViewsArray =
        [NSMutableArray arrayWithCapacity:cppJson.bufferViews->size()];
    for (const auto &bufferView : cppJson.bufferViews.value()) {
      [bufferViewsArray
          addObject:[JsonConverter convertGLTFBufferView:bufferView]];
    }
    objcJson.bufferViews = [bufferViewsArray copy];
  }
  if (cppJson.cameras.has_value()) {
    NSMutableArray<GLTFCamera *> *camerasArray =
        [NSMutableArray arrayWithCapacity:cppJson.cameras->size()];
    for (const auto &camera : cppJson.cameras.value()) {
      [camerasArray addObject:[JsonConverter convertGLTFCamera:camera]];
    }
    objcJson.cameras = [camerasArray copy];
  }
  if (cppJson.images.has_value()) {
    NSMutableArray<GLTFImage *> *imagesArray =
        [NSMutableArray arrayWithCapacity:cppJson.images->size()];
    for (const auto &image : cppJson.images.value()) {
      [imagesArray addObject:[JsonConverter convertGLTFImage:image]];
    }
    objcJson.images = [imagesArray copy];
  }
  if (cppJson.materials.has_value()) {
    NSMutableArray<GLTFMaterial *> *materialsArray =
        [NSMutableArray arrayWithCapacity:cppJson.materials->size()];
    for (const auto &material : cppJson.materials.value()) {
      [materialsArray addObject:[JsonConverter convertGLTFMaterial:material]];
    }
    objcJson.materials = [materialsArray copy];
  }
  if (cppJson.meshes.has_value()) {
    NSMutableArray<GLTFMesh *> *meshesArray =
        [NSMutableArray arrayWithCapacity:cppJson.meshes->size()];
    for (const auto &mesh : cppJson.meshes.value()) {
      [meshesArray addObject:[JsonConverter convertGLTFMesh:mesh]];
    }
    objcJson.meshes = [meshesArray copy];
  }
  if (cppJson.nodes.has_value()) {
    NSMutableArray<GLTFNode *> *nodesArray =
        [NSMutableArray arrayWithCapacity:cppJson.nodes->size()];
    for (const auto &node : cppJson.nodes.value()) {
      [nodesArray addObject:[JsonConverter convertGLTFNode:node]];
    }
    objcJson.nodes = [nodesArray copy];
  }
  if (cppJson.samplers.has_value()) {
    NSMutableArray<GLTFSampler *> *samplersArray =
        [NSMutableArray arrayWithCapacity:cppJson.samplers->size()];
    for (const auto &sampler : cppJson.samplers.value()) {
      [samplersArray addObject:[JsonConverter convertGLTFSampler:sampler]];
    }
    objcJson.samplers = [samplersArray copy];
  }
  if (cppJson.scene.has_value()) {
    objcJson.scene = @(cppJson.scene.value());
  }
  if (cppJson.scenes.has_value()) {
    NSMutableArray<GLTFScene *> *scenesArray =
        [NSMutableArray arrayWithCapacity:cppJson.scenes->size()];
    for (const auto &scene : cppJson.scenes.value()) {
      [scenesArray addObject:[JsonConverter convertGLTFScene:scene]];
    }
    objcJson.scenes = [scenesArray copy];
  }
  if (cppJson.skins.has_value()) {
    NSMutableArray<GLTFSkin *> *skinsArray =
        [NSMutableArray arrayWithCapacity:cppJson.skins->size()];
    for (const auto &skin : cppJson.skins.value()) {
      [skinsArray addObject:[JsonConverter convertGLTFSkin:skin]];
    }
    objcJson.skins = [skinsArray copy];
  }
  if (cppJson.textures.has_value()) {
    NSMutableArray<GLTFTexture *> *texturesArray =
        [NSMutableArray arrayWithCapacity:cppJson.textures->size()];
    for (const auto &texture : cppJson.textures.value()) {
      [texturesArray addObject:[JsonConverter convertGLTFTexture:texture]];
    }
    objcJson.textures = [texturesArray copy];
  }
  if (cppJson.lights.has_value()) {
    NSMutableArray<KHRLight *> *lightsArray =
        [NSMutableArray arrayWithCapacity:cppJson.lights->size()];
    for (const auto &light : cppJson.lights.value()) {
      [lightsArray addObject:[JsonConverter convertKHRLight:light]];
    }
    objcJson.lights = [lightsArray copy];
  }
  if (cppJson.vrm0.has_value()) {
    objcJson.vrm0 = [JsonConverter convertVRM0VRM:cppJson.vrm0.value()];
  }
  if (cppJson.vrm1.has_value()) {
    objcJson.vrm1 = [JsonConverter convertVRM1VRM:cppJson.vrm1.value()];
  }
  if (cppJson.springBone.has_value()) {
    objcJson.springBone =
        [JsonConverter convertSpringBone:cppJson.springBone.value()];
  }

  return objcJson;
}

@end
