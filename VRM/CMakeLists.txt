set(LIB_NAME VRM)
add_library(${LIB_NAME} SHARED)

file(GLOB HEADERS "include/*.h")
file(GLOB SOURCES "src/*.m")
target_sources(${LIB_NAME} PRIVATE ${HEADERS} ${SOURCES})
target_include_directories(${LIB_NAME} PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include)

find_library(COCOA_LIBRARY Cocoa)
find_library(FOUNDATION_LIBRARY Foundation)
find_library(METAL_LIBRARY Metal)
find_library(METALKIT_LIBRARY MetalKit)
target_link_libraries(${LIB_NAME} ${COCOA_LIBRARY} ${FOUNDATION_LIBRARY} ${METAL_LIBRARY} ${METALKIT_LIBRARY})

set_target_properties(${LIB_NAME} PROPERTIES
    FRAMEWORK TRUE
    VERSION 1.0.0
    PUBLIC_HEADER ${HEADERS}
    XCODE_ATTRIBUTE_CLANG_ENABLE_OBJC_ARC "YES"
    XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH "NO"
)

source_group(TREE ${CMAKE_CURRENT_SOURCE_DIR} FILES
    ${HEADERS}
    ${SOURCES}
)