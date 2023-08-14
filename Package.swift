// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "VirgilSDKPythia",
    platforms: [
        .macOS(.v10_13), .iOS(.v11), .tvOS(.v11), .watchOS(.v4)
    ],
    products: [
        .library(
            name: "VirgilSDKPythia",
            targets: ["VirgilSDKPythia"]),
    ],

    dependencies: [
        .package(url: "https://github.com/VirgilSecurity/virgil-sdk-x.git", exact: .init(9, 0, 1)),
        .package(url: "https://github.com/VirgilSecurity/virgil-crypto-c.git", exact: .init(0, 17, 1))
    ],

    targets: [
        .target(
            name: "VirgilSDKPythia",
            dependencies: [
                .product(name: "VirgilSDK", package: "virgil-sdk-x"),
                .product(name: "VirgilCryptoPythia", package: "virgil-crypto-c")
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
