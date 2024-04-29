EXECUTE_PROCESS(COMMAND uname -m COMMAND tr -d '\n' OUTPUT_VARIABLE ARCHITECTURE)

# ios_cmake
set(IOS_CMAKE_VERSION "4.4.1")
FetchContent_Declare(
    ios_cmake
    URL https://github.com/leetal/ios-cmake/archive/${IOS_CMAKE_VERSION}.zip
)

FetchContent_GetProperties(ios_cmake)

if(NOT ios_cmake_POPULATED)
    FetchContent_Populate(ios_cmake)

    if(${ARCHITECTURE} STREQUAL "arm64")
        set(PLATFORM "MAC_ARM64")
    else()
        set(PLATFORM "MAC")
    endif()

    include(${ios_cmake_SOURCE_DIR}/ios.toolchain.cmake)
endif()

# Info.plist
set(INFO_PLIST_IN_PATH ${CMAKE_CURRENT_SOURCE_DIR}/Info.plist.in)
set(INFO_PLIST_PATH ${CMAKE_CURRENT_BINARY_DIR}/Info.plist)
configure_file(${INFO_PLIST_IN_PATH} ${INFO_PLIST_PATH})

set(APP_RESOURCES
    Main.storyboard
    ${MODEL_FILES}
)

file(GLOB_RECURSE SOURCES "*.m" "*.mm")
file(GLOB_RECURSE HEADERS "*.h")
add_executable(example MACOSX_BUNDLE
    ${HEADERS}
    ${SOURCES}
    ${APP_RESOURCES}
)

find_library(COCOA_LIBRARY Cocoa)
find_library(FOUNDATION_LIBRARY Foundation)
find_library(SCENEKIT_LIBRARY SceneKit)

target_link_libraries(example ${PROJECT_NAME} ${COCOA_LIBRARY} ${FOUNDATION_LIBRARY} ${SCENEKIT_LIBRARY} gltf2)

target_include_directories(example PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
)

set_target_properties(example PROPERTIES
    RESOURCE "${APP_RESOURCES}"
    BUILD_WITH_INSTALL_RPATH TRUE
    INSTALL_RPATH @executable_path/../Frameworks
    MACOSX_BUNDLE_INFO_PLIST ${INFO_PLIST_PATH}
    XCODE_ATTRIBUTE_CLANG_ENABLE_OBJC_ARC YES
    XCODE_ATTRIBUTE_INFOPLIST_FILE ${INFO_PLIST_PATH}
    XCODE_EMBED_FRAMEWORKS ${PROJECT_NAME}
    XCODE_EMBED_FRAMEWORKS_CODE_SIGN_ON_COPY TRUE
    XCODE_EMBED_FRAMEWORKS_REMOVE_HEADERS_ON_COPY TRUE
)

source_group(TREE ${CMAKE_CURRENT_SOURCE_DIR} FILES
    ${HEADERS}
    ${SOURCES}
    Main.storyboard
)
source_group(TREE ${PROJECT_SOURCE_DIR} FILES ${MODEL_FILES})
