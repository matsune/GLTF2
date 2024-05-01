cmake_minimum_required(VERSION 3.18)
project(GLTF2 VERSION 1.0)

option(BUILD_TESTS "Build tests" OFF)
option(BUILD_EXAMPLE "Build example" OFF)

include(FetchContent)

option(BUILD_FRAMEWORK "Build as a framework instead of a dynamic library" OFF)

# ios_cmake
set(IOS_CMAKE_VERSION "4.4.1")
FetchContent_Declare(
    ios_cmake
    URL https://github.com/leetal/ios-cmake/archive/${IOS_CMAKE_VERSION}.zip
)

FetchContent_GetProperties(ios_cmake)

if(NOT ios_cmake_POPULATED)
    FetchContent_Populate(ios_cmake)
endif()

if(BUILD_TESTS OR BUILD_EXAMPLE)
    file(GLOB_RECURSE GLB_FILES "${PROJECT_SOURCE_DIR}/sample-models/*.glb")
    file(GLOB_RECURSE BIN_FILES "${PROJECT_SOURCE_DIR}/sample-models/*.bin")
    file(GLOB_RECURSE GLTF_FILES "${PROJECT_SOURCE_DIR}/sample-models/*.gltf")
    set(MODEL_FILES ${GLB_FILES} ${BIN_FILES} ${GLTF_FILES})
    add_subdirectory(sample-models)
endif()

add_subdirectory(GLTF2)
add_subdirectory(GLTF2SceneKit)

if(BUILD_FRAMEWORK AND BUILD_TESTS)
    add_subdirectory(GLTF2Tests)
endif()

if(BUILD_EXAMPLE)
    add_subdirectory(example)
endif()

find_program(CLANG_FORMAT "clang-format")

if(CLANG_FORMAT)
    set(DIRECTORIES "GLTF2" "GLTF2SceneKit")

    if(BUILD_TESTS)
        list(APPEND DIRECTORIES "GLTF2Tests")
    endif()

    if(BUILD_EXAMPLE)
        list(APPEND DIRECTORIES "example")
    endif()

    set(EXTENSIONS "*.m" "*.mm" "*.h")

    foreach(DIR IN LISTS DIRECTORIES)
        foreach(EXT IN LISTS EXTENSIONS)
            file(GLOB_RECURSE FOUND_FILES "${DIR}/${EXT}")
            list(APPEND ALL_SOURCES ${FOUND_FILES})
        endforeach()
    endforeach()

    add_custom_target(
        clang-format ALL
        COMMAND ${CLANG_FORMAT}
        -i
        -style=file
        ${ALL_SOURCES}
    )
endif()