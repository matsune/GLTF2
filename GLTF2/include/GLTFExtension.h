#ifndef GLTFExtension_h
#define GLTFExtension_h

#include <string>
#include <vector>

namespace gltf2 {

extern const std::string GLTFExtensionKHRDracoMeshCompression;
extern const std::string GLTFExtensionKHRMaterialsAnisotropy;
extern const std::string GLTFExtensionKHRMaterialsClearcoat;
extern const std::string GLTFExtensionKHRMaterialsIor;
extern const std::string GLTFExtensionKHRMaterialsSheen;
extern const std::string GLTFExtensionKHRMaterialsSpecular;
extern const std::string GLTFExtensionKHRMaterialsUnlit;
extern const std::string GLTFExtensionKHRTextureTransform;

extern const std::vector<std::string> SupportedExtensions;

} // namespace gltf2

#endif /* GLTFExtension_h */
