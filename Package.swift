// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LycheeSDK",
    defaultLocalization: "en",
    platforms: [ .macOS(.v13), .iOS(.v15), .custom("xros", versionString: "1.0") ],

    products: [
        .library(
            name: "LycheeSDK",
            targets: ["LycheeSDK"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "LycheeSDK",
            dependencies: [],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "LycheeSDKTests",
            dependencies: ["LycheeSDK"]
        )
    ]
)
