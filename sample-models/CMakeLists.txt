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
    "AntiqueCamera/glTF-Binary/AntiqueCamera.glb"
    "AntiqueCamera/glTF/AntiqueCamera.bin"
    "AntiqueCamera/glTF/AntiqueCamera.gltf"
    "AntiqueCamera/glTF/camera_camera_BaseColor.png"
    "AntiqueCamera/glTF/camera_camera_Normal.png"
    "AntiqueCamera/glTF/camera_camera_Roughness.png"
    "AntiqueCamera/glTF/camera_tripod_BaseColor.png"
    "AntiqueCamera/glTF/camera_tripod_Normal.png"
    "AntiqueCamera/glTF/camera_tripod_Roughness.png"

    "Box/glTF-Binary/Box.glb"
    "Box/glTF-Draco/Box.gltf"
    "Box/glTF-Draco/Box.bin"
    "Box/glTF-Embedded/Box.gltf"
    "Box/glTF/Box.gltf"
    "Box/glTF/Box0.bin"

    "BoxTextured/glTF-Binary/BoxTextured.glb"
    "BoxTextured/glTF-Embedded/BoxTextured.gltf"
    "BoxTextured/glTF/BoxTextured.gltf"
    "BoxTextured/glTF/BoxTextured0.bin"
    "BoxTextured/glTF/CesiumLogoFlat.png"
)

foreach(path IN LISTS DOWNLOAD_PATHS)
    download_file_if_not_exists(${DOWNLOAD_URL_BASE}${path} ${CMAKE_CURRENT_SOURCE_DIR}/${path})
endforeach()