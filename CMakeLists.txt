cmake_minimum_required(VERSION 3.18)
project(GLTF2 VERSION 1.0)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

option(BUILD_TESTS "Build tests" OFF)
option(BUILD_EXAMPLE "Build example" OFF)

include(FetchContent)

option(BUILD_FRAMEWORK "Build as a framework instead of a dynamic library" OFF)
option(DRACO_DIR "Path to the Draco library" "")

if(NOT DRACO_DIR AND EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/draco/build")
    set(DRACO_DIR "${CMAKE_CURRENT_SOURCE_DIR}/draco/build")
endif()

find_package(draco QUIET PATHS ${DRACO_DIR})

if(NOT draco_FOUND)
    message(STATUS "draco not found.")
endif()

if(BUILD_TESTS OR BUILD_EXAMPLE)
    set(CONFIG_H ${CMAKE_BINARY_DIR}/config.h)
    configure_file(config.h.in ${CONFIG_H})
endif()

add_subdirectory(GLTF2Core)
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
    set(DIRECTORIES "GLTF2Core" "GLTF2" "GLTF2SceneKit")

    if(BUILD_TESTS)
        list(APPEND DIRECTORIES "GLTF2Tests")
    endif()

    if(BUILD_EXAMPLE)
        list(APPEND DIRECTORIES "example")
    endif()

    set(EXTENSIONS "*.m" "*.mm" "*.h" "*.cpp")

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