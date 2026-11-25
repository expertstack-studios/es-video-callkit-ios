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
            url: "https://github.com/expertstack-studios/es-video-callkit-ios/releases/download/1.0.0-rc.5/VideoCallKit.xcframework.zip",
            checksum: "630cb967f75ac08248d7e6fd707430bc7491ee896531ae8feb80ea72e15dffe0"
        )
    ]
)
