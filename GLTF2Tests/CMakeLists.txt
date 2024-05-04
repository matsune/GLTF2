find_package(XCTest REQUIRED)


file(GLOB SOURCES "*.m")
xctest_add_bundle(GLTF2Tests GLTF2 ${SOURCES} ${CONFIG_H})
target_include_directories(GLTF2Tests PRIVATE ${CMAKE_CURRENT_BINARY_DIR})
xctest_add_test(XCTest.GLTF2 GLTF2Tests)
enable_testing()

source_group(TREE ${CMAKE_CURRENT_SOURCE_DIR} FILES
    ${SOURCES}
)
