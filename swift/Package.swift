// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PostureTimer",
    platforms: [
        .macOS(.v13),
    ],
    targets: [
        .executableTarget(
            name: "PostureTimer",
            path: "Sources/PostureTimer",
            resources: [
                .copy("Resources/AppIcon.icns"),
            ]
        ),
    ]
)
