// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "fledge-plugin-apple-music",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "fledge-music",
            path: "Sources/fledge-music"
        )
    ]
)
