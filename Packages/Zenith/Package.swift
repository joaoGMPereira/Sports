// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Zenith",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Zenith",
            targets: ["Zenith"]),
    ],
    dependencies: [
        .package(url: "https://github.com/exyte/PopupView.git", revision: "c82f68dd56d9359e144ab0446f5866208e4a02e8"),
        .package(url: "https://github.com/SFSafeSymbols/SFSafeSymbols.git", from: "5.2.0"),
        .package(path: "../ZenithCore")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Zenith",
            dependencies: [
                .product(name: "PopupView", package: "PopupView"),
                .product(name: "SFSafeSymbols", package: "SFSafeSymbols"),
                .product(name: "ZenithCore", package: "ZenithCore")
            ]
        ),
        
        .testTarget(
            name: "ZenithTests",
            dependencies: ["Zenith"]
        ),
    ]
)
