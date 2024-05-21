set(LIB_NAME GLTF2)
add_library(${LIB_NAME} SHARED)

if(BUILD_FRAMEWORK)
    set_target_properties(${LIB_NAME} PROPERTIES
        FRAMEWORK TRUE
    )
endif()

file(GLOB HEADERS "include/*.h")
file(GLOB SOURCES "src/*.m" "src/*.mm")
target_sources(${LIB_NAME} PRIVATE ${HEADERS} ${SOURCES})
target_include_directories(${LIB_NAME} PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include/${LIB_NAME}>
)

if(draco_FOUND)
    target_compile_definitions(${LIB_NAME} PUBLIC DRACO_SUPPORT)
    target_include_directories(${LIB_NAME} PRIVATE "${draco_DIR}" "${draco_DIR}/../src")
endif()

find_library(COCOA_LIBRARY Cocoa)
find_library(FOUNDATION_LIBRARY Foundation)

target_link_libraries(${LIB_NAME} GLTF2Core ${COCOA_LIBRARY} ${FOUNDATION_LIBRARY})

if(draco_FOUND)
    target_link_libraries(${LIB_NAME} draco::draco)
endif()

set_target_properties(${LIB_NAME} PROPERTIES
    VERSION 1.0
    PUBLIC_HEADER "${HEADERS}"
    XCODE_ATTRIBUTE_CLANG_ENABLE_OBJC_ARC "YES"
    XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH "NO"
    XCODE_ATTRIBUTE_MACOSX_DEPLOYMENT_TARGET 11.0
)

source_group(TREE ${CMAKE_CURRENT_SOURCE_DIR} FILES
    ${HEADERS}
    ${SOURCES}
)

if(NOT CMAKE_INSTALL_LIBDIR)
    set(CMAKE_INSTALL_LIBDIR "lib" CACHE STRING "Installation directory")
endif()

install(TARGETS ${LIB_NAME}
    EXPORT ${LIB_NAME}-export
    FRAMEWORK DESTINATION ${CMAKE_INSTALL_LIBDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    INCLUDES DESTINATION include
    PUBLIC_HEADER DESTINATION include/${LIB_NAME}
)

install(EXPORT ${LIB_NAME}-export
    FILE ${LIB_NAME}-config.cmake
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${LIB_NAME}/
    EXPORT_LINK_INTERFACE_LIBRARIES
)