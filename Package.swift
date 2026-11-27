// swift-tools-version:6.1
import PackageDescription

let package = Package(
    name: "VideoCallKit",
    platforms: [
        .iOS("17.6")
    ],
    products: [
        .library(
            name: "VideoCallKit",
            targets: ["VideoCallKit"]
        )
    ],
    targets: [
        .binaryTarget(
            name: "VideoCallKit",
            url: "https://github.com/expertstack-studios/es-video-callkit-ios/releases/download/1.0.0-rc.7/VideoCallKit.xcframework.zip",
            checksum: "0b32840db6c4f75cbeff3232eea8c67376f1e242ff3d60ad696222f840d1104e"
        )
    ]
)
