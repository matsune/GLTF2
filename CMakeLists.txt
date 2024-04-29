cmake_minimum_required(VERSION 3.18)
project(GLTF2 VERSION 1.0)

option(BUILD_TESTS "Build tests" OFF)
option(BUILD_EXAMPLE "Build example" OFF)

include(FetchContent)

file(GLOB_RECURSE GLB_FILES "${PROJECT_SOURCE_DIR}/gltf-sample-models/*.glb")
file(GLOB_RECURSE BIN_FILES "${PROJECT_SOURCE_DIR}/gltf-sample-models/*.bin")
file(GLOB_RECURSE GLTF_FILES "${PROJECT_SOURCE_DIR}/gltf-sample-models/*.gltf")
set(MODEL_FILES ${GLB_FILES} ${BIN_FILES} ${GLTF_FILES})

add_subdirectory(GLTF2)
add_subdirectory(VRM)

if(BUILD_TESTS)
    add_subdirectory(GLTF2Tests)
endif()

if(BUILD_EXAMPLE)
    add_subdirectory(example)
endif()

find_program(CLANG_FORMAT "clang-format")

if(CLANG_FORMAT)
    set(DIRECTORIES "GLTF2" "VRM" "GLTF2Tests" "example")

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