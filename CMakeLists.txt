cmake_minimum_required(VERSION 3.18)
project(GLTF2 VERSION 1.0)

option(BUILD_EXAMPLE "Build example" OFF)

include(FetchContent)

find_program(CLANG_FORMAT "clang-format")

file(GLOB_RECURSE GLB_FILES "${PROJECT_SOURCE_DIR}/gltf-sample-models/*.glb")
file(GLOB_RECURSE BIN_FILES "${PROJECT_SOURCE_DIR}/gltf-sample-models/*.bin")
file(GLOB_RECURSE GLTF_FILES "${PROJECT_SOURCE_DIR}/gltf-sample-models/*.gltf")
set(MODEL_FILES ${GLB_FILES} ${BIN_FILES} ${GLTF_FILES})

add_subdirectory(GLTF2)
add_subdirectory(VRM)

if(BUILD_EXAMPLE)
    add_subdirectory(example)
endif()

if(CLANG_FORMAT)
    add_custom_target(format-all
        COMMENT "Run format for all targets"
    )
    add_dependencies(format-all format-GLTF2)
    add_dependencies(format-all format-VRM)

    if(BUILD_EXAMPLE)
        add_dependencies(format-all format-example)
    endif()
endif()