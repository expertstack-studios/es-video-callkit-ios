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
            url: "https://github.com/expertstack-studios/es-video-callkit-ios/releases/download/1.0.0-rc.2/VideoCallKit.xcframework.zip",
            checksum: "8de01cbcd38fddef8242bd25b3811d91ed11db547a1049b14824048979e0ee4b"
        )
    ]
)
