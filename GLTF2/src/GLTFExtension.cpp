#include "GLTFExtension.h"

namespace gltf2 {

const std::string GLTFExtensionKHRDracoMeshCompression =
    "KHR_draco_mesh_compression";
const std::string GLTFExtensionKHRMaterialsAnisotropy =
    "KHR_materials_anisotropy";
const std::string GLTFExtensionKHRMaterialsIor = "KHR_materials_ior";
const std::string GLTFExtensionKHRMaterialsSheen = "KHR_materials_sheen";
const std::string GLTFExtensionKHRMaterialsSpecular = "KHR_materials_specular";
const std::string GLTFExtensionKHRMaterialsUnlit = "KHR_materials_unlit";
const std::string GLTFExtensionKHRTextureTransform = "KHR_texture_transform";

const std::vector<std::string> SupportedExtensions = {
    GLTFExtensionKHRDracoMeshCompression, GLTFExtensionKHRMaterialsAnisotropy,
    GLTFExtensionKHRMaterialsIor,         GLTFExtensionKHRMaterialsSheen,
    GLTFExtensionKHRMaterialsSpecular,    GLTFExtensionKHRMaterialsUnlit,
    GLTFExtensionKHRTextureTransform,
};

} // namespace gltf2
