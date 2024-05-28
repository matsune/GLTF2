include(FetchContent)
FetchContent_Declare(
  googletest
  URL https://github.com/google/googletest/archive/03597a01ee50ed33e9dfd640b249b4be3799d395.zip
)

# For Windows: Prevent overriding the parent project's compiler/linker settings
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(googletest)

enable_testing()

file(GLOB_RECURSE SOURCES "*.cpp")
add_executable(GLTF2Tests ${CONFIG_H} ${SOURCES})
target_include_directories(GLTF2Tests PRIVATE ${CMAKE_BINARY_DIR} ${cppcodec_SOURCE_DIR})

target_link_libraries(GLTF2Tests GLTF2 GTest::gtest_main)

set_target_properties(GLTF2Tests PROPERTIES
  XCODE_ATTRIBUTE_MACOSX_DEPLOYMENT_TARGET 11.0
)

include(GoogleTest)
gtest_discover_tests(GLTF2Tests)

source_group(TREE ${CMAKE_CURRENT_SOURCE_DIR} FILES
  ${SOURCES}
)
