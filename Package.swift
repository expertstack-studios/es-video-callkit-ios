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
            url: "https://github.com/expertstack-studios/es-video-callkit-ios/releases/download/1.0.0-rc.1/VideoCallKit.xcframework.zip",
            checksum: "1609aab1b97ed2e668db32b733188b4bf616fc15e7f4cfe0ef07a119ca659ea5"
        )
    ]
)
