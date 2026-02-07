// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MoldLine",
    platforms: [
        .iOS(.v17)
    ],
    targets: [
        .executableTarget(
            name: "MoldLine",
            path: "Sources/MoldLine",
            resources: [
                .process("Assets.xcassets")
            ]
        )
    ]
)
