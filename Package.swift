// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "VideoCallKit",
    platforms: [
        .iOS("15.6")
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
            url: "https://github.com/expertstack-studios/es-video-callkit-ios/releases/download/1.0.0-rc.4/VideoCallKit.xcframework.zip",
            checksum: "81cf4a849256a508af54a7f4f4ffdfd7a9664fcd0b3b974e998f05e639968f13"
        )
    ]
)
