#include "GLTFExtension.h"

namespace gltf2 {

const std::string GLTFExtensionKHRDracoMeshCompression =
    "KHR_draco_mesh_compression";
const std::string GLTFExtensionKHRMaterialsUnlit = "KHR_materials_unlit";
const std::string GLTFExtensionKHRTextureTransform = "KHR_texture_transform";
const std::string GLTFExtensionKHRMaterialsSheen = "KHR_materials_sheen";

const std::vector<std::string> SupportedExtensions = {
    GLTFExtensionKHRDracoMeshCompression,
    GLTFExtensionKHRMaterialsUnlit,
    GLTFExtensionKHRTextureTransform,
    GLTFExtensionKHRMaterialsSheen,
};

} // namespace gltf2
