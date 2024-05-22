set(LIB_NAME GLTF2Core)
add_library(${LIB_NAME} SHARED)

file(GLOB HEADERS "include/*.h")
file(GLOB SOURCES "src/*.cpp")
target_sources(${LIB_NAME} PRIVATE ${HEADERS} ${SOURCES})
target_include_directories(${LIB_NAME} PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include/${LIB_NAME}>
)
target_include_directories(${LIB_NAME} PRIVATE ${json_SOURCE_DIR}/include ${cppcodec_SOURCE_DIR} ${CMAKE_BINARY_DIR} ${draco_SOURCE_DIR}/src)

target_link_libraries(${LIB_NAME} PUBLIC ${COCOA_LIBRARY} ${FOUNDATION_LIBRARY} PRIVATE Boost::url draco::draco)

set(PUBLIC_HEADER include/GLTF2Core.h include/GLTFJson.h include/GLTFData.h)
set_target_properties(${LIB_NAME} PROPERTIES
    VERSION 1.0
    PUBLIC_HEADER "${PUBLIC_HEADER}"
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