// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "GLTF2",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "GLTF2",
            type: .dynamic,
            targets: ["GLTF2"]
        ),
    ],
    targets: [
        .target(
            name: "GLTF2",
            dependencies: [],
            path: "GLTF2/",
            sources: ["src"],
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("include"),
            ],
            linkerSettings: [
                .linkedFramework("Cocoa"),
                .linkedFramework("Foundation")
            ]
        )
    ]
)
