find_package(XCTest REQUIRED)

configure_file(config.h.in ${CMAKE_CURRENT_BINARY_DIR}/config.h)

file(GLOB SOURCES "*.m")
xctest_add_bundle(GLTF2Tests GLTF2 ${SOURCES} ${MODEL_FILES} ${CMAKE_CURRENT_BINARY_DIR}/config.h)
target_include_directories(GLTF2Tests PRIVATE ${CMAKE_CURRENT_BINARY_DIR})
xctest_add_test(XCTest.GLTF2 GLTF2Tests)
enable_testing()

source_group(TREE ${CMAKE_CURRENT_SOURCE_DIR} FILES
    ${SOURCES}
)
source_group(TREE ${PROJECT_SOURCE_DIR} FILES ${MODEL_FILES})
