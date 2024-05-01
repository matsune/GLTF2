function(download_file_if_not_exists url destination)
    if(NOT EXISTS "${destination}")
        message(STATUS "Downloading file: ${url} to ${destination}")
        file(DOWNLOAD ${url} ${destination}
            TIMEOUT 60
            STATUS status
            LOG log)

        list(GET status 0 status_code)
        list(GET status 1 status_string)

        if(NOT status_code EQUAL 0)
            message(FATAL_ERROR "Error downloading file: ${status_string}
                    \nLog: ${log}")
        endif()
    else()
        message(STATUS "File already exists: ${destination}, skipping download.")
    endif()
endfunction()

set(DOWNLOAD_URL_BASE "https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/main/2.0/")
set(DOWNLOAD_PATHS
    "2CylinderEngine/glTF-Binary/2CylinderEngine.glb"
    "2CylinderEngine/glTF-Draco/2CylinderEngine.gltf"
    "2CylinderEngine/glTF-Draco/2CylinderEngine.bin"
    "2CylinderEngine/glTF-Embedded/2CylinderEngine.gltf"
    "2CylinderEngine/glTF/2CylinderEngine.gltf"
    "2CylinderEngine/glTF/2CylinderEngine0.bin"
)

foreach(path IN LISTS DOWNLOAD_PATHS)
    download_file_if_not_exists(${DOWNLOAD_URL_BASE}${path} ${CMAKE_CURRENT_SOURCE_DIR}/${path})
endforeach()