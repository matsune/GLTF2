find_package(XCTest REQUIRED)

file(GLOB SOURCES "*.m")
xctest_add_bundle(GLTF2Tests GLTF2 ${SOURCES} ${CONFIG_H})
target_include_directories(GLTF2Tests PRIVATE ${CMAKE_CURRENT_BINARY_DIR})
xctest_add_test(XCTest.GLTF2 GLTF2Tests)
enable_testing()

set_target_properties(GLTF2Tests PROPERTIES
    XCODE_ATTRIBUTE_MACOSX_DEPLOYMENT_TARGET 11.0
)

source_group(TREE ${CMAKE_CURRENT_SOURCE_DIR} FILES
    ${SOURCES}
)
