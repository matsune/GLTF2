cmake_minimum_required(VERSION 3.18)
project(GLTF2 VERSION 1.0)

option(BUILD_TESTS "Build tests" OFF)
option(BUILD_EXAMPLE "Build example" OFF)

include(FetchContent)

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

file(GLOB_RECURSE GLB_FILES "${PROJECT_SOURCE_DIR}/gltf-sample-models/*.glb")
file(GLOB_RECURSE BIN_FILES "${PROJECT_SOURCE_DIR}/gltf-sample-models/*.bin")
file(GLOB_RECURSE GLTF_FILES "${PROJECT_SOURCE_DIR}/gltf-sample-models/*.gltf")
set(MODEL_FILES ${GLB_FILES} ${BIN_FILES} ${GLTF_FILES})

add_subdirectory(GLTF2)

if(BUILD_TESTS)
    add_subdirectory(GLTF2Tests)
endif()

if(BUILD_EXAMPLE)
    add_subdirectory(example)
endif()

find_program(CLANG_FORMAT "clang-format")

if(CLANG_FORMAT)
    set(DIRECTORIES "GLTF2")

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