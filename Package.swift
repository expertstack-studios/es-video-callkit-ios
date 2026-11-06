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
            url: "https://github.com/expertstack-studios/es-video-callkit-ios/releases/download/1.0.0-rc.3/VideoCallKit.xcframework.zip",
            checksum: "ac3c40b6bd2413851d4fe3f148fd2ac3494b2bdfed96803a778881335ff9d976"
        )
    ]
)
