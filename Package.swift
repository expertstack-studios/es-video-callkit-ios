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
            url: "https://github.com/expertstack-studios/es-video-callkit-ios/releases/download/1.0.0-rc.6/VideoCallKit.xcframework.zip",
            checksum: "73f8314bfb55bb6d9be5dc4be7110a81eb4ae7ebea32d2df8137eb19d2386bbc"
        )
    ]
)
