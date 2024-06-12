cmake_minimum_required(VERSION 3.18)
project(GLTF2 VERSION 1.0)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

option(BUILD_TESTS "Build tests" OFF)
option(BUILD_EXAMPLE "Build example" OFF)
option(BUILD_FRAMEWORK "Build as a framework instead of a dynamic library" OFF)

include(FetchContent)

# json
FetchContent_Declare(
    json
    URL https://github.com/nlohmann/json/releases/download/v3.11.3/json.tar.xz
)
FetchContent_MakeAvailable(json)

# cppcodec
FetchContent_Declare(
    cppcodec
    GIT_REPOSITORY https://github.com/tplgy/cppcodec.git
    GIT_TAG 302dc28
)
FetchContent_GetProperties(cppcodec)

if(NOT cppcodec_POPULATED)
    FetchContent_Populate(cppcodec)
endif()

# boost
set(BOOST_INCLUDE_LIBRARIES url)
FetchContent_Declare(
    Boost
    URL https://github.com/boostorg/boost/releases/download/boost-1.85.0/boost-1.85.0-cmake.tar.xz
)
FetchContent_MakeAvailable(Boost)

# draco
FetchContent_Declare(
    draco
    GIT_REPOSITORY https://github.com/google/draco.git
    GIT_TAG 8786740
)
FetchContent_MakeAvailable(draco)

set(TARGET_DIRS GLTF2 GLTF2SceneKit)

if(BUILD_TESTS)
    list(APPEND TARGET_DIRS GLTF2Tests)
endif()

if(BUILD_EXAMPLE)
    list(APPEND TARGET_DIRS example)
endif()

foreach(DIR IN LISTS TARGET_DIRS)
    add_subdirectory(${DIR})
endforeach()

find_program(CLANG_FORMAT "clang-format")

if(CLANG_FORMAT)
    set(EXTENSIONS "*.m" "*.mm" "*.h" "*.cpp")

    foreach(DIR IN LISTS TARGET_DIRS)
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