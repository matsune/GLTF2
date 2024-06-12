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

+ (NSString *)convertVRMCMetaAvatarPermission:
    (gltf2::json::VRMCMeta::AvatarPermission)permission {
  switch (permission) {
  case gltf2::json::VRMCMeta::AvatarPermission::ONLY_AUTHOR:
    return VRMCMetaAvatarPermissionOnlyAuthor;
  case gltf2::json::VRMCMeta::AvatarPermission::ONLY_SEPARATELY_LICENSED_PERSON:
    return VRMCMetaAvatarPermissionOnlySeparatelyLicensedPerson;
  case gltf2::json::VRMCMeta::AvatarPermission::EVERYONE:
    return VRMCMetaAvatarPermissionEveryone;
  default:
    return VRMCMetaAvatarPermissionOnlyAuthor; // Default case
  }
}

+ (NSString *)convertVRMCMetaCommercialUsage:
    (gltf2::json::VRMCMeta::CommercialUsage)usage {
  switch (usage) {
  case gltf2::json::VRMCMeta::CommercialUsage::PERSONAL_NON_PROFIT:
    return VRMCMetaCommercialUsagePersonalNonProfit;
  case gltf2::json::VRMCMeta::CommercialUsage::PERSONAL_PROFIT:
    return VRMCMetaCommercialUsagePersonalProfit;
  case gltf2::json::VRMCMeta::CommercialUsage::CORPORATION:
    return VRMCMetaCommercialUsageCorporation;
  default:
    return VRMCMetaCommercialUsagePersonalNonProfit; // Default case
  }
}

+ (NSString *)convertVRMCMetaCreditNotation:
    (gltf2::json::VRMCMeta::CreditNotation)notation {
  switch (notation) {
  case gltf2::json::VRMCMeta::CreditNotation::REQUIRED:
    return VRMCMetaCreditNotationRequired;
  case gltf2::json::VRMCMeta::CreditNotation::UNNECESSARY:
    return VRMCMetaCreditNotationUnnecessary;
  default:
    return VRMCMetaCreditNotationRequired; // Default case
  }
}

+ (NSString *)convertVRMCMetaModification:
    (gltf2::json::VRMCMeta::Modification)modification {
  switch (modification) {
  case gltf2::json::VRMCMeta::Modification::PROHIBITED:
    return VRMCMetaModificationProhibited;
  case gltf2::json::VRMCMeta::Modification::ALLOW_MODIFICATION:
    return VRMCMetaModificationAllowModification;
  case gltf2::json::VRMCMeta::Modification::ALLOW_MODIFICATION_REDISTRIBUTION:
    return VRMCMetaModificationAllowModificationRedistribution;
  default:
    return VRMCMetaModificationProhibited; // Default case
  }
}

+ (VRMCMeta *)convertVRMCMeta:(const gltf2::json::VRMCMeta &)cppMeta {
  VRMCMeta *objcMeta = [[VRMCMeta alloc] init];

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
        [self convertVRMCMetaAvatarPermission:cppMeta.avatarPermission.value()];
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
        [self convertVRMCMetaCommercialUsage:cppMeta.commercialUsage.value()];
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
        [self convertVRMCMetaCreditNotation:cppMeta.creditNotation.value()];
  }
  if (cppMeta.allowRedistribution.has_value()) {
    objcMeta.allowRedistribution = @(cppMeta.allowRedistribution.value());
  }
  if (cppMeta.modification.has_value()) {
    objcMeta.modification =
        [self convertVRMCMetaModification:cppMeta.modification.value()];
  }
  if (cppMeta.otherLicenseUrl.has_value()) {
    objcMeta.otherLicenseUrl =
        [NSString stringWithUTF8String:cppMeta.otherLicenseUrl->c_str()];
  }

  return objcMeta;
}

+ (VRMCHumanBone *)convertVRMCHumanBone:
    (const gltf2::json::VRMCHumanBone &)cppBone {
  VRMCHumanBone *objcBone = [[VRMCHumanBone alloc] init];
  objcBone.node = cppBone.node;
  return objcBone;
}

+ (VRMCHumanBones *)convertVRMCHumanBones:
    (const gltf2::json::VRMCHumanBones &)cppBones {
  VRMCHumanBones *objcBones = [[VRMCHumanBones alloc] init];

  objcBones.hips = [self convertVRMCHumanBone:cppBones.hips];
  objcBones.spine = [self convertVRMCHumanBone:cppBones.spine];
  if (cppBones.chest.has_value()) {
    objcBones.chest = [self convertVRMCHumanBone:cppBones.chest.value()];
  }
  if (cppBones.upperChest.has_value()) {
    objcBones.upperChest =
        [self convertVRMCHumanBone:cppBones.upperChest.value()];
  }
  if (cppBones.neck.has_value()) {
    objcBones.neck = [self convertVRMCHumanBone:cppBones.neck.value()];
  }
  objcBones.head = [self convertVRMCHumanBone:cppBones.head];
  if (cppBones.leftEye.has_value()) {
    objcBones.leftEye = [self convertVRMCHumanBone:cppBones.leftEye.value()];
  }
  if (cppBones.rightEye.has_value()) {
    objcBones.rightEye = [self convertVRMCHumanBone:cppBones.rightEye.value()];
  }
  if (cppBones.jaw.has_value()) {
    objcBones.jaw = [self convertVRMCHumanBone:cppBones.jaw.value()];
  }
  objcBones.leftUpperLeg = [self convertVRMCHumanBone:cppBones.leftUpperLeg];
  objcBones.leftLowerLeg = [self convertVRMCHumanBone:cppBones.leftLowerLeg];
  objcBones.leftFoot = [self convertVRMCHumanBone:cppBones.leftFoot];
  if (cppBones.leftToes.has_value()) {
    objcBones.leftToes = [self convertVRMCHumanBone:cppBones.leftToes.value()];
  }
  objcBones.rightUpperLeg = [self convertVRMCHumanBone:cppBones.rightUpperLeg];
  objcBones.rightLowerLeg = [self convertVRMCHumanBone:cppBones.rightLowerLeg];
  objcBones.rightFoot = [self convertVRMCHumanBone:cppBones.rightFoot];
  if (cppBones.rightToes.has_value()) {
    objcBones.rightToes =
        [self convertVRMCHumanBone:cppBones.rightToes.value()];
  }
  if (cppBones.leftShoulder.has_value()) {
    objcBones.leftShoulder =
        [self convertVRMCHumanBone:cppBones.leftShoulder.value()];
  }
  objcBones.leftUpperArm = [self convertVRMCHumanBone:cppBones.leftUpperArm];
  objcBones.leftLowerArm = [self convertVRMCHumanBone:cppBones.leftLowerArm];
  objcBones.leftHand = [self convertVRMCHumanBone:cppBones.leftHand];
  if (cppBones.rightShoulder.has_value()) {
    objcBones.rightShoulder =
        [self convertVRMCHumanBone:cppBones.rightShoulder.value()];
  }
  objcBones.rightUpperArm = [self convertVRMCHumanBone:cppBones.rightUpperArm];
  objcBones.rightLowerArm = [self convertVRMCHumanBone:cppBones.rightLowerArm];
  objcBones.rightHand = [self convertVRMCHumanBone:cppBones.rightHand];
  if (cppBones.leftThumbMetacarpal.has_value()) {
    objcBones.leftThumbMetacarpal =
        [self convertVRMCHumanBone:cppBones.leftThumbMetacarpal.value()];
  }
  if (cppBones.leftThumbProximal.has_value()) {
    objcBones.leftThumbProximal =
        [self convertVRMCHumanBone:cppBones.leftThumbProximal.value()];
  }
  if (cppBones.leftThumbDistal.has_value()) {
    objcBones.leftThumbDistal =
        [self convertVRMCHumanBone:cppBones.leftThumbDistal.value()];
  }
  if (cppBones.leftIndexProximal.has_value()) {
    objcBones.leftIndexProximal =
        [self convertVRMCHumanBone:cppBones.leftIndexProximal.value()];
  }
  if (cppBones.leftIndexIntermediate.has_value()) {
    objcBones.leftIndexIntermediate =
        [self convertVRMCHumanBone:cppBones.leftIndexIntermediate.value()];
  }
  if (cppBones.leftIndexDistal.has_value()) {
    objcBones.leftIndexDistal =
        [self convertVRMCHumanBone:cppBones.leftIndexDistal.value()];
  }
  if (cppBones.leftMiddleProximal.has_value()) {
    objcBones.leftMiddleProximal =
        [self convertVRMCHumanBone:cppBones.leftMiddleProximal.value()];
  }
  if (cppBones.leftMiddleIntermediate.has_value()) {
    objcBones.leftMiddleIntermediate =
        [self convertVRMCHumanBone:cppBones.leftMiddleIntermediate.value()];
  }
  if (cppBones.leftMiddleDistal.has_value()) {
    objcBones.leftMiddleDistal =
        [self convertVRMCHumanBone:cppBones.leftMiddleDistal.value()];
  }
  if (cppBones.leftRingProximal.has_value()) {
    objcBones.leftRingProximal =
        [self convertVRMCHumanBone:cppBones.leftRingProximal.value()];
  }
  if (cppBones.leftRingIntermediate.has_value()) {
    objcBones.leftRingIntermediate =
        [self convertVRMCHumanBone:cppBones.leftRingIntermediate.value()];
  }
  if (cppBones.leftRingDistal.has_value()) {
    objcBones.leftRingDistal =
        [self convertVRMCHumanBone:cppBones.leftRingDistal.value()];
  }
  if (cppBones.leftLittleProximal.has_value()) {
    objcBones.leftLittleProximal =
        [self convertVRMCHumanBone:cppBones.leftLittleProximal.value()];
  }
  if (cppBones.leftLittleIntermediate.has_value()) {
    objcBones.leftLittleIntermediate =
        [self convertVRMCHumanBone:cppBones.leftLittleIntermediate.value()];
  }
  if (cppBones.leftLittleDistal.has_value()) {
    objcBones.leftLittleDistal =
        [self convertVRMCHumanBone:cppBones.leftLittleDistal.value()];
  }
  if (cppBones.rightThumbMetacarpal.has_value()) {
    objcBones.rightThumbMetacarpal =
        [self convertVRMCHumanBone:cppBones.rightThumbMetacarpal.value()];
  }
  if (cppBones.rightThumbProximal.has_value()) {
    objcBones.rightThumbProximal =
        [self convertVRMCHumanBone:cppBones.rightThumbProximal.value()];
  }
  if (cppBones.rightThumbDistal.has_value()) {
    objcBones.rightThumbDistal =
        [self convertVRMCHumanBone:cppBones.rightThumbDistal.value()];
  }
  if (cppBones.rightIndexProximal.has_value()) {
    objcBones.rightIndexProximal =
        [self convertVRMCHumanBone:cppBones.rightIndexProximal.value()];
  }
  if (cppBones.rightIndexIntermediate.has_value()) {
    objcBones.rightIndexIntermediate =
        [self convertVRMCHumanBone:cppBones.rightIndexIntermediate.value()];
  }
  if (cppBones.rightIndexDistal.has_value()) {
    objcBones.rightIndexDistal =
        [self convertVRMCHumanBone:cppBones.rightIndexDistal.value()];
  }
  if (cppBones.rightMiddleProximal.has_value()) {
    objcBones.rightMiddleProximal =
        [self convertVRMCHumanBone:cppBones.rightMiddleProximal.value()];
  }
  if (cppBones.rightMiddleIntermediate.has_value()) {
    objcBones.rightMiddleIntermediate =
        [self convertVRMCHumanBone:cppBones.rightMiddleIntermediate.value()];
  }
  if (cppBones.rightMiddleDistal.has_value()) {
    objcBones.rightMiddleDistal =
        [self convertVRMCHumanBone:cppBones.rightMiddleDistal.value()];
  }
  if (cppBones.rightRingProximal.has_value()) {
    objcBones.rightRingProximal =
        [self convertVRMCHumanBone:cppBones.rightRingProximal.value()];
  }
  if (cppBones.rightRingIntermediate.has_value()) {
    objcBones.rightRingIntermediate =
        [self convertVRMCHumanBone:cppBones.rightRingIntermediate.value()];
  }
  if (cppBones.rightRingDistal.has_value()) {
    objcBones.rightRingDistal =
        [self convertVRMCHumanBone:cppBones.rightRingDistal.value()];
  }
  if (cppBones.rightLittleProximal.has_value()) {
    objcBones.rightLittleProximal =
        [self convertVRMCHumanBone:cppBones.rightLittleProximal.value()];
  }
  if (cppBones.rightLittleIntermediate.has_value()) {
    objcBones.rightLittleIntermediate =
        [self convertVRMCHumanBone:cppBones.rightLittleIntermediate.value()];
  }
  if (cppBones.rightLittleDistal.has_value()) {
    objcBones.rightLittleDistal =
        [self convertVRMCHumanBone:cppBones.rightLittleDistal.value()];
  }

  return objcBones;
}

+ (VRMCHumanoid *)convertVRMCHumanoid:
    (const gltf2::json::VRMCHumanoid &)cppHumanoid {
  VRMCHumanoid *objcHumanoid = [[VRMCHumanoid alloc] init];
  objcHumanoid.humanBones = [self convertVRMCHumanBones:cppHumanoid.humanBones];
  return objcHumanoid;
}

+ (NSString *)convertVRMCFirstPersonMeshAnnotationType:
    (gltf2::json::VRMCFirstPersonMeshAnnotation::Type)type {
  switch (type) {
  case gltf2::json::VRMCFirstPersonMeshAnnotation::Type::AUTO:
    return VRMCFirstPersonMeshAnnotationTypeAuto;
  case gltf2::json::VRMCFirstPersonMeshAnnotation::Type::BOTH:
    return VRMCFirstPersonMeshAnnotationTypeBoth;
  case gltf2::json::VRMCFirstPersonMeshAnnotation::Type::THIRD_PERSON_ONLY:
    return VRMCFirstPersonMeshAnnotationTypeThirdPersonOnly;
  case gltf2::json::VRMCFirstPersonMeshAnnotation::Type::FIRST_PERSON_ONLY:
    return VRMCFirstPersonMeshAnnotationTypeFirstPersonOnly;
  default:
    return VRMCFirstPersonMeshAnnotationTypeAuto; // Default case
  }
}

+ (VRMCFirstPersonMeshAnnotation *)convertVRMCFirstPersonMeshAnnotation:
    (const gltf2::json::VRMCFirstPersonMeshAnnotation &)cppAnnotation {
  VRMCFirstPersonMeshAnnotation *objcAnnotation =
      [[VRMCFirstPersonMeshAnnotation alloc] init];
  objcAnnotation.node = cppAnnotation.node;
  objcAnnotation.type =
      [self convertVRMCFirstPersonMeshAnnotationType:cppAnnotation.type];
  return objcAnnotation;
}

+ (VRMCFirstPerson *)convertVRMCFirstPerson:
    (const gltf2::json::VRMCFirstPerson &)cppFirstPerson {
  VRMCFirstPerson *objcFirstPerson = [[VRMCFirstPerson alloc] init];

  if (cppFirstPerson.meshAnnotations.has_value()) {
    NSMutableArray<VRMCFirstPersonMeshAnnotation *> *annotationsArray =
        [NSMutableArray
            arrayWithCapacity:cppFirstPerson.meshAnnotations->size()];
    for (const auto &annotation : cppFirstPerson.meshAnnotations.value()) {
      [annotationsArray
          addObject:[self convertVRMCFirstPersonMeshAnnotation:annotation]];
    }
    objcFirstPerson.meshAnnotations = [annotationsArray copy];
  }

  return objcFirstPerson;
}

+ (VRMCLookAtRangeMap *)convertVRMCLookAtRangeMap:
    (const gltf2::json::VRMCLookAtRangeMap &)cppLookAtRangeMap {
  VRMCLookAtRangeMap *objcLookAtRangeMap = [[VRMCLookAtRangeMap alloc] init];

  if (cppLookAtRangeMap.inputMaxValue.has_value()) {
    objcLookAtRangeMap.inputMaxValue =
        @(cppLookAtRangeMap.inputMaxValue.value());
  }
  if (cppLookAtRangeMap.outputScale.has_value()) {
    objcLookAtRangeMap.outputScale = @(cppLookAtRangeMap.outputScale.value());
  }

  return objcLookAtRangeMap;
}

+ (NSString *)convertVRMCLookAtType:(gltf2::json::VRMCLookAt::Type)type {
  switch (type) {
  case gltf2::json::VRMCLookAt::Type::BONE:
    return VRMCLookAtTypeBone;
  case gltf2::json::VRMCLookAt::Type::EXPRESSION:
    return VRMCLookAtTypeExpression;
  default:
    return VRMCLookAtTypeBone; // Default case
  }
}

+ (VRMCLookAt *)convertVRMCLookAt:(const gltf2::json::VRMCLookAt &)cppLookAt {
  VRMCLookAt *objcLookAt = [[VRMCLookAt alloc] init];

  if (cppLookAt.offsetFromHeadBone.has_value()) {
    objcLookAt.offsetFromHeadBone = @[
      @(cppLookAt.offsetFromHeadBone->at(0)),
      @(cppLookAt.offsetFromHeadBone->at(1)),
      @(cppLookAt.offsetFromHeadBone->at(2))
    ];
  }
  if (cppLookAt.type.has_value()) {
    objcLookAt.type = [self convertVRMCLookAtType:cppLookAt.type.value()];
  }
  if (cppLookAt.rangeMapHorizontalInner.has_value()) {
    objcLookAt.rangeMapHorizontalInner = [self
        convertVRMCLookAtRangeMap:cppLookAt.rangeMapHorizontalInner.value()];
  }
  if (cppLookAt.rangeMapHorizontalOuter.has_value()) {
    objcLookAt.rangeMapHorizontalOuter = [self
        convertVRMCLookAtRangeMap:cppLookAt.rangeMapHorizontalOuter.value()];
  }
  if (cppLookAt.rangeMapVerticalDown.has_value()) {
    objcLookAt.rangeMapVerticalDown =
        [self convertVRMCLookAtRangeMap:cppLookAt.rangeMapVerticalDown.value()];
  }
  if (cppLookAt.rangeMapVerticalUp.has_value()) {
    objcLookAt.rangeMapVerticalUp =
        [self convertVRMCLookAtRangeMap:cppLookAt.rangeMapVerticalUp.value()];
  }

  return objcLookAt;
}

+ (NSString *)convertVRMCExpressionMaterialColorBindType:
    (gltf2::json::VRMCExpressionMaterialColorBind::Type)type {
  switch (type) {
  case gltf2::json::VRMCExpressionMaterialColorBind::Type::COLOR:
    return VRMCExpressionMaterialColorBindTypeColor;
  case gltf2::json::VRMCExpressionMaterialColorBind::Type::EMISSION_COLOR:
    return VRMCExpressionMaterialColorBindTypeEmissionColor;
  case gltf2::json::VRMCExpressionMaterialColorBind::Type::SHADE_COLOR:
    return VRMCExpressionMaterialColorBindTypeShadeColor;
  case gltf2::json::VRMCExpressionMaterialColorBind::Type::MATCAP_COLOR:
    return VRMCExpressionMaterialColorBindTypeMatcapColor;
  case gltf2::json::VRMCExpressionMaterialColorBind::Type::RIM_COLOR:
    return VRMCExpressionMaterialColorBindTypeRimColor;
  case gltf2::json::VRMCExpressionMaterialColorBind::Type::OUTLINE_COLOR:
    return VRMCExpressionMaterialColorBindTypeOutlineColor;
  default:
    return VRMCExpressionMaterialColorBindTypeColor; // Default case
  }
}

+ (VRMCExpressionMaterialColorBind *)convertVRMCExpressionMaterialColorBind:
    (const gltf2::json::VRMCExpressionMaterialColorBind &)cppBind {
  VRMCExpressionMaterialColorBind *objcBind =
      [[VRMCExpressionMaterialColorBind alloc] init];
  objcBind.material = cppBind.material;
  objcBind.type =
      [self convertVRMCExpressionMaterialColorBindType:cppBind.type];
  objcBind.targetValue = @[
    @(cppBind.targetValue[0]), @(cppBind.targetValue[1]),
    @(cppBind.targetValue[2]), @(cppBind.targetValue[3])
  ];
  return objcBind;
}

+ (VRMCExpressionMorphTargetBind *)convertVRMCExpressionMorphTargetBind:
    (const gltf2::json::VRMCExpressionMorphTargetBind &)cppBind {
  VRMCExpressionMorphTargetBind *objcBind =
      [[VRMCExpressionMorphTargetBind alloc] init];
  objcBind.node = cppBind.node;
  objcBind.index = cppBind.index;
  objcBind.weight = cppBind.weight;
  return objcBind;
}

+ (VRMCExpressionTextureTransformBind *)
    convertVRMCExpressionTextureTransformBind:
        (const gltf2::json::VRMCExpressionTextureTransformBind &)cppBind {
  VRMCExpressionTextureTransformBind *objcBind =
      [[VRMCExpressionTextureTransformBind alloc] init];
  objcBind.material = cppBind.material;
  if (cppBind.scale.has_value()) {
    objcBind.scale = @[ @(cppBind.scale->at(0)), @(cppBind.scale->at(1)) ];
  }
  if (cppBind.offset.has_value()) {
    objcBind.offset = @[ @(cppBind.offset->at(0)), @(cppBind.offset->at(1)) ];
  }
  return objcBind;
}

+ (NSString *)convertVRMCExpressionOverride:
    (gltf2::json::VRMCExpression::Override)override {
  switch (override) {
  case gltf2::json::VRMCExpression::Override::NONE:
    return VRMCExpressionOverrideNone;
  case gltf2::json::VRMCExpression::Override::BLOCK:
    return VRMCExpressionOverrideBlock;
  case gltf2::json::VRMCExpression::Override::BLEND:
    return VRMCExpressionOverrideBlend;
  default:
    return VRMCExpressionOverrideNone; // Default case
  }
}

+ (VRMCExpression *)convertVRMCExpression:
    (const gltf2::json::VRMCExpression &)cppExpression {
  VRMCExpression *objcExpression = [[VRMCExpression alloc] init];

  if (cppExpression.morphTargetBinds.has_value()) {
    NSMutableArray<VRMCExpressionMorphTargetBind *> *morphTargetBindsArray =
        [NSMutableArray array];
    for (const auto &bind : cppExpression.morphTargetBinds.value()) {
      [morphTargetBindsArray
          addObject:[self convertVRMCExpressionMorphTargetBind:bind]];
    }
    objcExpression.morphTargetBinds = morphTargetBindsArray;
  }
  if (cppExpression.materialColorBinds.has_value()) {
    NSMutableArray<VRMCExpressionMaterialColorBind *> *materialColorBindsArray =
        [NSMutableArray array];
    for (const auto &bind : cppExpression.materialColorBinds.value()) {
      [materialColorBindsArray
          addObject:[self convertVRMCExpressionMaterialColorBind:bind]];
    }
    objcExpression.materialColorBinds = materialColorBindsArray;
  }
  if (cppExpression.textureTransformBinds.has_value()) {
    NSMutableArray<VRMCExpressionTextureTransformBind *>
        *textureTransformBindsArray = [NSMutableArray array];
    for (const auto &bind : cppExpression.textureTransformBinds.value()) {
      [textureTransformBindsArray
          addObject:[self convertVRMCExpressionTextureTransformBind:bind]];
    }
    objcExpression.textureTransformBinds = textureTransformBindsArray;
  }
  objcExpression.isBinary = cppExpression.isBinaryValue();
  if (cppExpression.overrideBlink.has_value()) {
    objcExpression.overrideBlink = [self
        convertVRMCExpressionOverride:cppExpression.overrideBlink.value()];
  }
  if (cppExpression.overrideLookAt.has_value()) {
    objcExpression.overrideLookAt = [self
        convertVRMCExpressionOverride:cppExpression.overrideLookAt.value()];
  }
  if (cppExpression.overrideMouth.has_value()) {
    objcExpression.overrideMouth = [self
        convertVRMCExpressionOverride:cppExpression.overrideMouth.value()];
  }

  return objcExpression;
}

+ (VRMCExpressionsPreset *)convertVRMCExpressionsPreset:
    (const gltf2::json::VRMCExpressionsPreset &)cppPreset {
  VRMCExpressionsPreset *objcPreset = [[VRMCExpressionsPreset alloc] init];

  if (cppPreset.happy.has_value()) {
    objcPreset.happy = [self convertVRMCExpression:cppPreset.happy.value()];
  }
  if (cppPreset.angry.has_value()) {
    objcPreset.angry = [self convertVRMCExpression:cppPreset.angry.value()];
  }
  if (cppPreset.sad.has_value()) {
    objcPreset.sad = [self convertVRMCExpression:cppPreset.sad.value()];
  }
  if (cppPreset.relaxed.has_value()) {
    objcPreset.relaxed = [self convertVRMCExpression:cppPreset.relaxed.value()];
  }
  if (cppPreset.surprised.has_value()) {
    objcPreset.surprised =
        [self convertVRMCExpression:cppPreset.surprised.value()];
  }
  if (cppPreset.aa.has_value()) {
    objcPreset.aa = [self convertVRMCExpression:cppPreset.aa.value()];
  }
  if (cppPreset.ih.has_value()) {
    objcPreset.ih = [self convertVRMCExpression:cppPreset.ih.value()];
  }
  if (cppPreset.ou.has_value()) {
    objcPreset.ou = [self convertVRMCExpression:cppPreset.ou.value()];
  }
  if (cppPreset.ee.has_value()) {
    objcPreset.ee = [self convertVRMCExpression:cppPreset.ee.value()];
  }
  if (cppPreset.oh.has_value()) {
    objcPreset.oh = [self convertVRMCExpression:cppPreset.oh.value()];
  }
  if (cppPreset.blink.has_value()) {
    objcPreset.blink = [self convertVRMCExpression:cppPreset.blink.value()];
  }
  if (cppPreset.blinkLeft.has_value()) {
    objcPreset.blinkLeft =
        [self convertVRMCExpression:cppPreset.blinkLeft.value()];
  }
  if (cppPreset.blinkRight.has_value()) {
    objcPreset.blinkRight =
        [self convertVRMCExpression:cppPreset.blinkRight.value()];
  }
  if (cppPreset.lookUp.has_value()) {
    objcPreset.lookUp = [self convertVRMCExpression:cppPreset.lookUp.value()];
  }
  if (cppPreset.lookDown.has_value()) {
    objcPreset.lookDown =
        [self convertVRMCExpression:cppPreset.lookDown.value()];
  }
  if (cppPreset.lookLeft.has_value()) {
    objcPreset.lookLeft =
        [self convertVRMCExpression:cppPreset.lookLeft.value()];
  }
  if (cppPreset.lookRight.has_value()) {
    objcPreset.lookRight =
        [self convertVRMCExpression:cppPreset.lookRight.value()];
  }
  if (cppPreset.neutral.has_value()) {
    objcPreset.neutral = [self convertVRMCExpression:cppPreset.neutral.value()];
  }

  return objcPreset;
}

+ (VRMCExpressions *)convertVRMCExpressions:
    (const gltf2::json::VRMCExpressions &)cppExpressions {
  VRMCExpressions *objcExpressions = [[VRMCExpressions alloc] init];

  if (cppExpressions.preset.has_value()) {
    objcExpressions.preset =
        [self convertVRMCExpressionsPreset:cppExpressions.preset.value()];
  }
  if (cppExpressions.custom.has_value()) {
    NSMutableDictionary<NSString *, VRMCExpression *> *customDict =
        [NSMutableDictionary dictionary];
    for (const auto &pair : cppExpressions.custom.value()) {
      NSString *key = [NSString stringWithUTF8String:pair.first.c_str()];
      VRMCExpression *value = [self convertVRMCExpression:pair.second];
      [customDict setObject:value forKey:key];
    }
    objcExpressions.custom = customDict;
  }

  return objcExpressions;
}

+ (VRMCVrm *)convertVRMCVrm:(const gltf2::json::VRMCVrm &)cppVrm {
  VRMCVrm *objcVrm = [[VRMCVrm alloc] init];

  objcVrm.specVersion =
      [NSString stringWithUTF8String:cppVrm.specVersion.c_str()];
  objcVrm.meta = [self convertVRMCMeta:cppVrm.meta];
  objcVrm.humanoid = [self convertVRMCHumanoid:cppVrm.humanoid];
  if (cppVrm.firstPerson.has_value()) {
    objcVrm.firstPerson =
        [self convertVRMCFirstPerson:cppVrm.firstPerson.value()];
  }
  if (cppVrm.lookAt.has_value()) {
    objcVrm.lookAt = [self convertVRMCLookAt:cppVrm.lookAt.value()];
  }
  if (cppVrm.expressions.has_value()) {
    objcVrm.expressions =
        [self convertVRMCExpressions:cppVrm.expressions.value()];
  }

  return objcVrm;
}

+ (VRMVec3 *)convertVRMVec3:(const gltf2::json::VRMVec3 &)cppVec3 {
  VRMVec3 *objcVec3 = [[VRMVec3 alloc] init];

  if (cppVec3.x.has_value()) {
    objcVec3.x = @(cppVec3.x.value());
  }
  if (cppVec3.y.has_value()) {
    objcVec3.y = @(cppVec3.y.value());
  }
  if (cppVec3.z.has_value()) {
    objcVec3.z = @(cppVec3.z.value());
  }

  return objcVec3;
}

+ (NSString *)convertVRMHumanoidBoneType:
    (gltf2::json::VRMHumanoidBone::Bone)type {
  switch (type) {
  case gltf2::json::VRMHumanoidBone::Bone::HIPS:
    return VRMHumanoidBoneTypeHips;
  case gltf2::json::VRMHumanoidBone::Bone::LEFT_UPPER_LEG:
    return VRMHumanoidBoneTypeLeftUpperLeg;
  case gltf2::json::VRMHumanoidBone::Bone::RIGHT_UPPER_LEG:
    return VRMHumanoidBoneTypeRightUpperLeg;
  case gltf2::json::VRMHumanoidBone::Bone::LEFT_LOWER_LEG:
    return VRMHumanoidBoneTypeLeftLowerLeg;
  case gltf2::json::VRMHumanoidBone::Bone::RIGHT_LOWER_LEG:
    return VRMHumanoidBoneTypeRightLowerLeg;
  case gltf2::json::VRMHumanoidBone::Bone::LEFT_FOOT:
    return VRMHumanoidBoneTypeLeftFoot;
  case gltf2::json::VRMHumanoidBone::Bone::RIGHT_FOOT:
    return VRMHumanoidBoneTypeRightFoot;
  case gltf2::json::VRMHumanoidBone::Bone::SPINE:
    return VRMHumanoidBoneTypeSpine;
  case gltf2::json::VRMHumanoidBone::Bone::CHEST:
    return VRMHumanoidBoneTypeChest;
  case gltf2::json::VRMHumanoidBone::Bone::NECK:
    return VRMHumanoidBoneTypeNeck;
  case gltf2::json::VRMHumanoidBone::Bone::HEAD:
    return VRMHumanoidBoneTypeHead;
  case gltf2::json::VRMHumanoidBone::Bone::LEFT_SHOULDER:
    return VRMHumanoidBoneTypeLeftShoulder;
  case gltf2::json::VRMHumanoidBone::Bone::RIGHT_SHOULDER:
    return VRMHumanoidBoneTypeRightShoulder;
  case gltf2::json::VRMHumanoidBone::Bone::LEFT_UPPER_ARM:
    return VRMHumanoidBoneTypeLeftUpperArm;
  case gltf2::json::VRMHumanoidBone::Bone::RIGHT_UPPER_ARM:
    return VRMHumanoidBoneTypeRightUpperArm;
  case gltf2::json::VRMHumanoidBone::Bone::LEFT_LOWER_ARM:
    return VRMHumanoidBoneTypeLeftLowerArm;
  case gltf2::json::VRMHumanoidBone::Bone::RIGHT_LOWER_ARM:
    return VRMHumanoidBoneTypeRightLowerArm;
  case gltf2::json::VRMHumanoidBone::Bone::LEFT_HAND:
    return VRMHumanoidBoneTypeLeftHand;
  case gltf2::json::VRMHumanoidBone::Bone::RIGHT_HAND:
    return VRMHumanoidBoneTypeRightHand;
  case gltf2::json::VRMHumanoidBone::Bone::LEFT_TOES:
    return VRMHumanoidBoneTypeLeftToes;
  case gltf2::json::VRMHumanoidBone::Bone::RIGHT_TOES:
    return VRMHumanoidBoneTypeRightToes;
  case gltf2::json::VRMHumanoidBone::Bone::LEFT_EYE:
    return VRMHumanoidBoneTypeLeftEye;
  case gltf2::json::VRMHumanoidBone::Bone::RIGHT_EYE:
    return VRMHumanoidBoneTypeRightEye;
  case gltf2::json::VRMHumanoidBone::Bone::JAW:
    return VRMHumanoidBoneTypeJaw;
  case gltf2::json::VRMHumanoidBone::Bone::LEFT_THUMB_PROXIMAL:
    return VRMHumanoidBoneTypeLeftThumbProximal;
  case gltf2::json::VRMHumanoidBone::Bone::LEFT_THUMB_INTERMEDIATE:
    return VRMHumanoidBoneTypeLeftThumbIntermediate;
  case gltf2::json::VRMHumanoidBone::Bone::LEFT_THUMB_DISTAL:
    return VRMHumanoidBoneTypeLeftThumbDistal;
  case gltf2::json::VRMHumanoidBone::Bone::LEFT_INDEX_PROXIMAL:
    return VRMHumanoidBoneTypeLeftIndexProximal;
  case gltf2::json::VRMHumanoidBone::Bone::LEFT_INDEX_INTERMEDIATE:
    return VRMHumanoidBoneTypeLeftIndexIntermediate;
  case gltf2::json::VRMHumanoidBone::Bone::LEFT_INDEX_DISTAL:
    return VRMHumanoidBoneTypeLeftIndexDistal;
  case gltf2::json::VRMHumanoidBone::Bone::LEFT_MIDDLE_PROXIMAL:
    return VRMHumanoidBoneTypeLeftMiddleProximal;
  case gltf2::json::VRMHumanoidBone::Bone::LEFT_MIDDLE_INTERMEDIATE:
    return VRMHumanoidBoneTypeLeftMiddleIntermediate;
  case gltf2::json::VRMHumanoidBone::Bone::LEFT_MIDDLE_DISTAL:
    return VRMHumanoidBoneTypeLeftMiddleDistal;
  case gltf2::json::VRMHumanoidBone::Bone::LEFT_RING_PROXIMAL:
    return VRMHumanoidBoneTypeLeftRingProximal;
  case gltf2::json::VRMHumanoidBone::Bone::LEFT_RING_INTERMEDIATE:
    return VRMHumanoidBoneTypeLeftRingIntermediate;
  case gltf2::json::VRMHumanoidBone::Bone::LEFT_RING_DISTAL:
    return VRMHumanoidBoneTypeLeftRingDistal;
  case gltf2::json::VRMHumanoidBone::Bone::LEFT_LITTLE_PROXIMAL:
    return VRMHumanoidBoneTypeLeftLittleProximal;
  case gltf2::json::VRMHumanoidBone::Bone::LEFT_LITTLE_INTERMEDIATE:
    return VRMHumanoidBoneTypeLeftLittleIntermediate;
  case gltf2::json::VRMHumanoidBone::Bone::LEFT_LITTLE_DISTAL:
    return VRMHumanoidBoneTypeLeftLittleDistal;
  case gltf2::json::VRMHumanoidBone::Bone::RIGHT_THUMB_PROXIMAL:
    return VRMHumanoidBoneTypeRightThumbProximal;
  case gltf2::json::VRMHumanoidBone::Bone::RIGHT_THUMB_INTERMEDIATE:
    return VRMHumanoidBoneTypeRightThumbIntermediate;
  case gltf2::json::VRMHumanoidBone::Bone::RIGHT_THUMB_DISTAL:
    return VRMHumanoidBoneTypeRightThumbDistal;
  case gltf2::json::VRMHumanoidBone::Bone::RIGHT_INDEX_PROXIMAL:
    return VRMHumanoidBoneTypeRightIndexProximal;
  case gltf2::json::VRMHumanoidBone::Bone::RIGHT_INDEX_INTERMEDIATE:
    return VRMHumanoidBoneTypeRightIndexIntermediate;
  case gltf2::json::VRMHumanoidBone::Bone::RIGHT_INDEX_DISTAL:
    return VRMHumanoidBoneTypeRightIndexDistal;
  case gltf2::json::VRMHumanoidBone::Bone::RIGHT_MIDDLE_PROXIMAL:
    return VRMHumanoidBoneTypeRightMiddleProximal;
  case gltf2::json::VRMHumanoidBone::Bone::RIGHT_MIDDLE_INTERMEDIATE:
    return VRMHumanoidBoneTypeRightMiddleIntermediate;
  case gltf2::json::VRMHumanoidBone::Bone::RIGHT_MIDDLE_DISTAL:
    return VRMHumanoidBoneTypeRightMiddleDistal;
  case gltf2::json::VRMHumanoidBone::Bone::RIGHT_RING_PROXIMAL:
    return VRMHumanoidBoneTypeRightRingProximal;
  case gltf2::json::VRMHumanoidBone::Bone::RIGHT_RING_INTERMEDIATE:
    return VRMHumanoidBoneTypeRightRingIntermediate;
  case gltf2::json::VRMHumanoidBone::Bone::RIGHT_RING_DISTAL:
    return VRMHumanoidBoneTypeRightRingDistal;
  case gltf2::json::VRMHumanoidBone::Bone::RIGHT_LITTLE_PROXIMAL:
    return VRMHumanoidBoneTypeRightLittleProximal;
  case gltf2::json::VRMHumanoidBone::Bone::RIGHT_LITTLE_INTERMEDIATE:
    return VRMHumanoidBoneTypeRightLittleIntermediate;
  case gltf2::json::VRMHumanoidBone::Bone::RIGHT_LITTLE_DISTAL:
    return VRMHumanoidBoneTypeRightLittleDistal;
  case gltf2::json::VRMHumanoidBone::Bone::UPPER_CHEST:
    return VRMHumanoidBoneTypeUpperChest;
  default:
    return VRMHumanoidBoneTypeHips; // Default case
  }
}

+ (VRMHumanoidBone *)convertVRMHumanoidBone:
    (const gltf2::json::VRMHumanoidBone &)cppBone {
  VRMHumanoidBone *objcBone = [[VRMHumanoidBone alloc] init];

  if (cppBone.bone.has_value()) {
    objcBone.bone = [self convertVRMHumanoidBoneType:cppBone.bone.value()];
  }
  if (cppBone.node.has_value()) {
    objcBone.node = @(cppBone.node.value());
  }
  if (cppBone.useDefaultValues.has_value()) {
    objcBone.useDefaultValues = @(cppBone.useDefaultValues.value());
  }
  if (cppBone.min.has_value()) {
    objcBone.min = [self convertVRMVec3:cppBone.min.value()];
  }
  if (cppBone.max.has_value()) {
    objcBone.max = [self convertVRMVec3:cppBone.max.value()];
  }
  if (cppBone.center.has_value()) {
    objcBone.center = [self convertVRMVec3:cppBone.center.value()];
  }
  if (cppBone.axisLength.has_value()) {
    objcBone.axisLength = @(cppBone.axisLength.value());
  }

  return objcBone;
}

+ (VRMHumanoid *)convertVRMHumanoid:
    (const gltf2::json::VRMHumanoid &)cppHumanoid {
  VRMHumanoid *objcHumanoid = [[VRMHumanoid alloc] init];

  if (cppHumanoid.humanBones.has_value()) {
    NSMutableArray<VRMHumanoidBone *> *humanBonesArray =
        [NSMutableArray arrayWithCapacity:cppHumanoid.humanBones->size()];
    for (const auto &bone : cppHumanoid.humanBones.value()) {
      [humanBonesArray addObject:[self convertVRMHumanoidBone:bone]];
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

+ (NSString *)convertVRMMetaAllowedUserName:
    (gltf2::json::VRMMeta::AllowedUserName)allowedUserName {
  switch (allowedUserName) {
  case gltf2::json::VRMMeta::AllowedUserName::ONLY_AUTHOR:
    return VRMMetaAllowedUserNameOnlyAuthor;
  case gltf2::json::VRMMeta::AllowedUserName::EXPLICITLY_LICENSED_PERSON:
    return VRMMetaAllowedUserNameExplicitlyLicensedPerson;
  case gltf2::json::VRMMeta::AllowedUserName::EVERYONE:
    return VRMMetaAllowedUserNameEveryone;
  default:
    return VRMMetaAllowedUserNameOnlyAuthor; // Default case
  }
}

+ (NSString *)convertVRMMetaUsagePermission:
    (gltf2::json::VRMMeta::UsagePermission)usagePermission {
  switch (usagePermission) {
  case gltf2::json::VRMMeta::UsagePermission::DISALLOW:
    return VRMMetaUsagePermissionDisallow;
  case gltf2::json::VRMMeta::UsagePermission::ALLOW:
    return VRMMetaUsagePermissionAllow;
  default:
    return VRMMetaUsagePermissionDisallow; // Default case
  }
}

+ (NSString *)convertVRMMetaLicenseName:
    (gltf2::json::VRMMeta::LicenseName)licenseName {
  switch (licenseName) {
  case gltf2::json::VRMMeta::LicenseName::REDISTRIBUTION_PROHIBITED:
    return VRMMetaLicenseNameRedistributionProhibited;
  case gltf2::json::VRMMeta::LicenseName::CC0:
    return VRMMetaLicenseNameCC0;
  case gltf2::json::VRMMeta::LicenseName::CC_BY:
    return VRMMetaLicenseNameCCBY;
  case gltf2::json::VRMMeta::LicenseName::CC_BY_NC:
    return VRMMetaLicenseNameCCBYNC;
  case gltf2::json::VRMMeta::LicenseName::CC_BY_SA:
    return VRMMetaLicenseNameCCBYSA;
  case gltf2::json::VRMMeta::LicenseName::CC_BY_NC_SA:
    return VRMMetaLicenseNameCCBYNCSA;
  case gltf2::json::VRMMeta::LicenseName::CC_BY_ND:
    return VRMMetaLicenseNameCCBYND;
  case gltf2::json::VRMMeta::LicenseName::CC_BY_NC_ND:
    return VRMMetaLicenseNameCCBYNCND;
  case gltf2::json::VRMMeta::LicenseName::OTHER:
    return VRMMetaLicenseNameOther;
  default:
    return VRMMetaLicenseNameRedistributionProhibited; // Default case
  }
}

+ (VRMMeta *)convertVRMMeta:(const gltf2::json::VRMMeta &)cppMeta {
  VRMMeta *objcMeta = [[VRMMeta alloc] init];

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
        [self convertVRMMetaAllowedUserName:cppMeta.allowedUserName.value()];
  }
  if (cppMeta.violentUsage.has_value()) {
    objcMeta.violentUsage =
        [self convertVRMMetaUsagePermission:cppMeta.violentUsage.value()];
  }
  if (cppMeta.sexualUsage.has_value()) {
    objcMeta.sexualUsage =
        [self convertVRMMetaUsagePermission:cppMeta.sexualUsage.value()];
  }
  if (cppMeta.commercialUsage.has_value()) {
    objcMeta.commercialUsage =
        [self convertVRMMetaUsagePermission:cppMeta.commercialUsage.value()];
  }
  if (cppMeta.otherPermissionUrl.has_value()) {
    objcMeta.otherPermissionUrl =
        [NSString stringWithUTF8String:cppMeta.otherPermissionUrl->c_str()];
  }
  if (cppMeta.licenseName.has_value()) {
    objcMeta.licenseName =
        [self convertVRMMetaLicenseName:cppMeta.licenseName.value()];
  }
  if (cppMeta.otherLicenseUrl.has_value()) {
    objcMeta.otherLicenseUrl =
        [NSString stringWithUTF8String:cppMeta.otherLicenseUrl->c_str()];
  }

  return objcMeta;
}

+ (VRMMeshAnnotation *)convertVRMMeshAnnotation:
    (const gltf2::json::VRMMeshAnnotation &)cppAnnotation {
  VRMMeshAnnotation *objcAnnotation = [[VRMMeshAnnotation alloc] init];

  if (cppAnnotation.mesh.has_value()) {
    objcAnnotation.mesh = @(cppAnnotation.mesh.value());
  }
  if (cppAnnotation.firstPersonFlag.has_value()) {
    objcAnnotation.firstPersonFlag =
        [NSString stringWithUTF8String:cppAnnotation.firstPersonFlag->c_str()];
  }

  return objcAnnotation;
}

+ (VRMDegreeMap *)convertVRMDegreeMap:
    (const gltf2::json::VRMDegreeMap &)cppDegreeMap {
  VRMDegreeMap *objcDegreeMap = [[VRMDegreeMap alloc] init];

  if (cppDegreeMap.curve.has_value()) {
    NSMutableArray<NSNumber *> *curveArray =
        [NSMutableArray arrayWithCapacity:cppDegreeMap.curve->size()];
    for (const auto &value : cppDegreeMap.curve.value()) {
      [curveArray addObject:@(value)];
    }
    objcDegreeMap.curve = [curveArray copy];
  }
  if (cppDegreeMap.xRange.has_value()) {
    objcDegreeMap.xRange = @(cppDegreeMap.xRange.value());
  }
  if (cppDegreeMap.yRange.has_value()) {
    objcDegreeMap.yRange = @(cppDegreeMap.yRange.value());
  }

  return objcDegreeMap;
}

+ (VRMFirstPerson *)convertVRMFirstPerson:
    (const gltf2::json::VRMFirstPerson &)cppFirstPerson {
  VRMFirstPerson *objcFirstPerson = [[VRMFirstPerson alloc] init];

  if (cppFirstPerson.firstPersonBone.has_value()) {
    objcFirstPerson.firstPersonBone = @(cppFirstPerson.firstPersonBone.value());
  }
  if (cppFirstPerson.firstPersonBoneOffset.has_value()) {
    objcFirstPerson.firstPersonBoneOffset =
        [self convertVRMVec3:cppFirstPerson.firstPersonBoneOffset.value()];
  }
  if (cppFirstPerson.meshAnnotations.has_value()) {
    NSMutableArray<VRMMeshAnnotation *> *annotationsArray = [NSMutableArray
        arrayWithCapacity:cppFirstPerson.meshAnnotations->size()];
    for (const auto &annotation : cppFirstPerson.meshAnnotations.value()) {
      [annotationsArray addObject:[self convertVRMMeshAnnotation:annotation]];
    }
    objcFirstPerson.meshAnnotations = [annotationsArray copy];
  }
  if (cppFirstPerson.lookAtTypeName.has_value()) {
    objcFirstPerson.lookAtTypeName =
        [NSString stringWithUTF8String:cppFirstPerson.lookAtTypeName->c_str()];
  }
  if (cppFirstPerson.lookAtHorizontalInner.has_value()) {
    objcFirstPerson.lookAtHorizontalInner =
        [self convertVRMDegreeMap:cppFirstPerson.lookAtHorizontalInner.value()];
  }
  if (cppFirstPerson.lookAtHorizontalOuter.has_value()) {
    objcFirstPerson.lookAtHorizontalOuter =
        [self convertVRMDegreeMap:cppFirstPerson.lookAtHorizontalOuter.value()];
  }
  if (cppFirstPerson.lookAtVerticalDown.has_value()) {
    objcFirstPerson.lookAtVerticalDown =
        [self convertVRMDegreeMap:cppFirstPerson.lookAtVerticalDown.value()];
  }
  if (cppFirstPerson.lookAtVerticalUp.has_value()) {
    objcFirstPerson.lookAtVerticalUp =
        [self convertVRMDegreeMap:cppFirstPerson.lookAtVerticalUp.value()];
  }

  return objcFirstPerson;
}

+ (VRMBlendShapeBind *)convertVRMBlendShapeBind:
    (const gltf2::json::VRMBlendShapeBind &)cppBind {
  VRMBlendShapeBind *objcBind = [[VRMBlendShapeBind alloc] init];

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

+ (VRMBlendShapeMaterialBind *)convertVRMBlendShapeMaterialBind:
    (const gltf2::json::VRMBlendShapeMaterialBind &)cppBind {
  VRMBlendShapeMaterialBind *objcBind =
      [[VRMBlendShapeMaterialBind alloc] init];

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

+ (NSString *)convertVRMBlendShapeGroupPresetName:
    (gltf2::json::VRMBlendShapeGroup::PresetName)presetName {
  switch (presetName) {
  case gltf2::json::VRMBlendShapeGroup::PresetName::UNKNOWN:
    return VRMBlendShapeGroupPresetNameUnknown;
  case gltf2::json::VRMBlendShapeGroup::PresetName::NEUTRAL:
    return VRMBlendShapeGroupPresetNameNeutral;
  case gltf2::json::VRMBlendShapeGroup::PresetName::A:
    return VRMBlendShapeGroupPresetNameA;
  case gltf2::json::VRMBlendShapeGroup::PresetName::I:
    return VRMBlendShapeGroupPresetNameI;
  case gltf2::json::VRMBlendShapeGroup::PresetName::U:
    return VRMBlendShapeGroupPresetNameU;
  case gltf2::json::VRMBlendShapeGroup::PresetName::E:
    return VRMBlendShapeGroupPresetNameE;
  case gltf2::json::VRMBlendShapeGroup::PresetName::O:
    return VRMBlendShapeGroupPresetNameO;
  case gltf2::json::VRMBlendShapeGroup::PresetName::BLINK:
    return VRMBlendShapeGroupPresetNameBlink;
  case gltf2::json::VRMBlendShapeGroup::PresetName::JOY:
    return VRMBlendShapeGroupPresetNameJoy;
  case gltf2::json::VRMBlendShapeGroup::PresetName::ANGRY:
    return VRMBlendShapeGroupPresetNameAngry;
  case gltf2::json::VRMBlendShapeGroup::PresetName::SORROW:
    return VRMBlendShapeGroupPresetNameSorrow;
  case gltf2::json::VRMBlendShapeGroup::PresetName::FUN:
    return VRMBlendShapeGroupPresetNameFun;
  case gltf2::json::VRMBlendShapeGroup::PresetName::LOOKUP:
    return VRMBlendShapeGroupPresetNameLookUp;
  case gltf2::json::VRMBlendShapeGroup::PresetName::LOOKDOWN:
    return VRMBlendShapeGroupPresetNameLookDown;
  case gltf2::json::VRMBlendShapeGroup::PresetName::LOOKLEFT:
    return VRMBlendShapeGroupPresetNameLookLeft;
  case gltf2::json::VRMBlendShapeGroup::PresetName::LOOKRIGHT:
    return VRMBlendShapeGroupPresetNameLookRight;
  case gltf2::json::VRMBlendShapeGroup::PresetName::BLINK_L:
    return VRMBlendShapeGroupPresetNameBlinkL;
  case gltf2::json::VRMBlendShapeGroup::PresetName::BLINK_R:
    return VRMBlendShapeGroupPresetNameBlinkR;
  default:
    return VRMBlendShapeGroupPresetNameUnknown; // Default case
  }
}

+ (VRMBlendShapeGroup *)convertVRMBlendShapeGroup:
    (const gltf2::json::VRMBlendShapeGroup &)cppGroup {
  VRMBlendShapeGroup *objcGroup = [[VRMBlendShapeGroup alloc] init];

  if (cppGroup.name.has_value()) {
    objcGroup.name = [NSString stringWithUTF8String:cppGroup.name->c_str()];
  }
  if (cppGroup.presetName.has_value()) {
    objcGroup.presetName =
        [self convertVRMBlendShapeGroupPresetName:cppGroup.presetName.value()];
  }
  if (cppGroup.binds.has_value()) {
    NSMutableArray<VRMBlendShapeBind *> *bindsArray =
        [NSMutableArray arrayWithCapacity:cppGroup.binds->size()];
    for (const auto &bind : cppGroup.binds.value()) {
      [bindsArray addObject:[self convertVRMBlendShapeBind:bind]];
    }
    objcGroup.binds = [bindsArray copy];
  }
  if (cppGroup.materialValues.has_value()) {
    NSMutableArray<VRMBlendShapeMaterialBind *> *materialValuesArray =
        [NSMutableArray arrayWithCapacity:cppGroup.materialValues->size()];
    for (const auto &materialValue : cppGroup.materialValues.value()) {
      [materialValuesArray
          addObject:[self convertVRMBlendShapeMaterialBind:materialValue]];
    }
    objcGroup.materialValues = [materialValuesArray copy];
  }
  objcGroup.isBinary = cppGroup.isBinaryValue();

  return objcGroup;
}

+ (VRMBlendShape *)convertVRMBlendShape:
    (const gltf2::json::VRMBlendShape &)cppBlendShape {
  VRMBlendShape *objcBlendShape = [[VRMBlendShape alloc] init];

  if (cppBlendShape.blendShapeGroups.has_value()) {
    NSMutableArray<VRMBlendShapeGroup *> *blendShapeGroupsArray =
        [NSMutableArray
            arrayWithCapacity:cppBlendShape.blendShapeGroups->size()];
    for (const auto &blendShapeGroup : cppBlendShape.blendShapeGroups.value()) {
      [blendShapeGroupsArray
          addObject:[self convertVRMBlendShapeGroup:blendShapeGroup]];
    }
    objcBlendShape.blendShapeGroups = [blendShapeGroupsArray copy];
  }

  return objcBlendShape;
}

+ (VRMSecondaryAnimationCollider *)convertVRMSecondaryAnimationCollider:
    (const gltf2::json::VRMSecondaryAnimationCollider &)cppCollider {
  VRMSecondaryAnimationCollider *objcCollider =
      [[VRMSecondaryAnimationCollider alloc] init];

  if (cppCollider.offset.has_value()) {
    objcCollider.offset = [self convertVRMVec3:cppCollider.offset.value()];
  }
  if (cppCollider.radius.has_value()) {
    objcCollider.radius = @(cppCollider.radius.value());
  }

  return objcCollider;
}

+ (VRMSecondaryAnimationColliderGroup *)
    convertVRMSecondaryAnimationColliderGroup:
        (const gltf2::json::VRMSecondaryAnimationColliderGroup &)
            cppColliderGroup {
  VRMSecondaryAnimationColliderGroup *objcColliderGroup =
      [[VRMSecondaryAnimationColliderGroup alloc] init];

  if (cppColliderGroup.node.has_value()) {
    objcColliderGroup.node = @(cppColliderGroup.node.value());
  }
  if (cppColliderGroup.colliders.has_value()) {
    NSMutableArray<VRMSecondaryAnimationCollider *> *collidersArray =
        [NSMutableArray arrayWithCapacity:cppColliderGroup.colliders->size()];
    for (const auto &collider : cppColliderGroup.colliders.value()) {
      [collidersArray
          addObject:[self convertVRMSecondaryAnimationCollider:collider]];
    }
    objcColliderGroup.colliders = [collidersArray copy];
  }

  return objcColliderGroup;
}

+ (VRMSecondaryAnimationSpring *)convertVRMSecondaryAnimationSpring:
    (const gltf2::json::VRMSecondaryAnimationSpring &)cppSpring {
  VRMSecondaryAnimationSpring *objcSpring =
      [[VRMSecondaryAnimationSpring alloc] init];

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
    objcSpring.gravityDir = [self convertVRMVec3:cppSpring.gravityDir.value()];
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

+ (VRMSecondaryAnimation *)convertVRMSecondaryAnimation:
    (const gltf2::json::VRMSecondaryAnimation &)cppSecondaryAnimation {
  VRMSecondaryAnimation *objcSecondaryAnimation =
      [[VRMSecondaryAnimation alloc] init];

  if (cppSecondaryAnimation.boneGroups.has_value()) {
    NSMutableArray<VRMSecondaryAnimationSpring *> *boneGroupsArray =
        [NSMutableArray array];
    for (const auto &boneGroup : cppSecondaryAnimation.boneGroups.value()) {
      [boneGroupsArray
          addObject:[self convertVRMSecondaryAnimationSpring:boneGroup]];
    }
    objcSecondaryAnimation.boneGroups = boneGroupsArray;
  }
  if (cppSecondaryAnimation.colliderGroups.has_value()) {
    NSMutableArray<VRMSecondaryAnimationColliderGroup *> *colliderGroupsArray =
        [NSMutableArray array];
    for (const auto &colliderGroup :
         cppSecondaryAnimation.colliderGroups.value()) {
      [colliderGroupsArray
          addObject:
              [self convertVRMSecondaryAnimationColliderGroup:colliderGroup]];
    }
    objcSecondaryAnimation.colliderGroups = colliderGroupsArray;
  }

  return objcSecondaryAnimation;
}

+ (VRMMaterial *)convertVRMMaterial:
    (const gltf2::json::VRMMaterial &)cppMaterial {
  VRMMaterial *objcMaterial = [[VRMMaterial alloc] init];

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

+ (VRMVrm *)convertVRMVrm:(const gltf2::json::VRMVrm &)cppVrm {
  VRMVrm *objcVrm = [[VRMVrm alloc] init];

  if (cppVrm.exporterVersion.has_value()) {
    objcVrm.exporterVersion =
        [NSString stringWithUTF8String:cppVrm.exporterVersion->c_str()];
  }
  if (cppVrm.specVersion.has_value()) {
    objcVrm.specVersion =
        [NSString stringWithUTF8String:cppVrm.specVersion->c_str()];
  }
  if (cppVrm.meta.has_value()) {
    objcVrm.meta = [JsonConverter convertVRMMeta:cppVrm.meta.value()];
  }
  if (cppVrm.humanoid.has_value()) {
    objcVrm.humanoid =
        [JsonConverter convertVRMHumanoid:cppVrm.humanoid.value()];
  }
  if (cppVrm.firstPerson.has_value()) {
    objcVrm.firstPerson =
        [JsonConverter convertVRMFirstPerson:cppVrm.firstPerson.value()];
  }
  if (cppVrm.blendShapeMaster.has_value()) {
    objcVrm.blendShapeMaster =
        [JsonConverter convertVRMBlendShape:cppVrm.blendShapeMaster.value()];
  }
  if (cppVrm.secondaryAnimation.has_value()) {
    objcVrm.secondaryAnimation = [JsonConverter
        convertVRMSecondaryAnimation:cppVrm.secondaryAnimation.value()];
  }
  if (cppVrm.materialProperties.has_value()) {
    NSMutableArray<VRMMaterial *> *materialsArray = [NSMutableArray array];
    for (const auto &material : cppVrm.materialProperties.value()) {
      [materialsArray addObject:[JsonConverter convertVRMMaterial:material]];
    }
    objcVrm.materialProperties = materialsArray;
  }

  return objcVrm;
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
    objcJson.vrm0 = [JsonConverter convertVRMVrm:cppJson.vrm0.value()];
  }
  if (cppJson.vrm1.has_value()) {
    objcJson.vrm1 = [JsonConverter convertVRMCVrm:cppJson.vrm1.value()];
  }

  return objcJson;
}

@end
