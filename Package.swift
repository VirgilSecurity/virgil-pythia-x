// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "VirgilSDKPythia",
    platforms: [
        .macOS(.v10_11), .iOS(.v9), .tvOS(.v9), .watchOS(.v2)
    ],
    products: [
        .library(
            name: "VirgilSDKPythia",
            targets: ["VirgilSDKPythia"]),
    ],

    dependencies: [
        .package(url: "https://github.com/VirgilSecurity/virgil-sdk-x.git", branch: "develop")
    ],

    targets: [
        .target(
            name: "VirgilSDKPythia",
            dependencies: [
                .product(name: "VirgilSDK", package: "virgil-sdk-x"),
            ],
            path: "Source"
        ),
        .testTarget(
            name: "VirgilSDKPythiaTests",
            dependencies: ["VirgilSDKPythia"],
            path: "Tests",
            resources: [
                .process("Data/TestConfig.plist")
            ],
            swiftSettings: [
                .define("SPM_BUILD")
            ]
        )
    ]
)
