file(GLOB_RECURSE SOURCES "*.cpp")
add_executable(core_test ${SOURCES})

target_link_libraries(core_test GLTF2Core)

set_target_properties(core_test PROPERTIES
    XCODE_ATTRIBUTE_MACOSX_DEPLOYMENT_TARGET 11.0
)

source_group(TREE ${CMAKE_CURRENT_SOURCE_DIR} FILES
    ${SOURCES}
)
