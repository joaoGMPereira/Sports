// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ZenithCore",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ZenithCore",
            targets: ["ZenithCore"]),
    ],
    dependencies: [
        .package(path: "../ZenithCoreInterface")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ZenithCore",
            dependencies: [
                .product(name: "ZenithCoreInterface", package: "ZenithCoreInterface"),
            ],
            resources: [
             .process("Resources")
            ]
        ),
        .testTarget(
            name: "ZenithCoreTests",
            dependencies: ["ZenithCore"]
        ),
    ]
)
