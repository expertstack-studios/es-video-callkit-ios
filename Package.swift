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
            url: "https://github.com/expertstack-studios/es-video-callkit-ios/releases/download/1.0.0-rc.8/VideoCallKit.xcframework.zip",
            checksum: "dddb4cfaece9a0ab86260893f074eb37e5458d4b321f533944bd01875e15d1c2"
        )
    ]
)
