find_package(XCTest REQUIRED)
set(TARGET_NAME GLTF2KitTests)

file(GLOB SOURCES "*.mm")
xctest_add_bundle(${TARGET_NAME} GLTF2Kit ${SOURCES})
target_include_directories(${TARGET_NAME} PRIVATE ${CMAKE_BINARY_DIR} ${CMAKE_CURRENT_BINARY_DIR})
xctest_add_test(XCTest.GLTF2Kit ${TARGET_NAME})
enable_testing()

set_target_properties(${TARGET_NAME} PROPERTIES
    XCODE_ATTRIBUTE_MACOSX_DEPLOYMENT_TARGET 11.0
)

source_group(TREE ${CMAKE_CURRENT_SOURCE_DIR} FILES
    ${SOURCES}
)
