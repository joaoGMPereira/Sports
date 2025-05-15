// swift-tools-version:5.9
import PackageDescription

let name = "GenerateComponents"
let package = Package(
    name: name,
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: name, targets: [name])
    ],
    dependencies: [
        // Adicione aqui quaisquer dependências externas que você precise
        // Por exemplo: .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
    ],
    targets: [
        .executableTarget(
            name: name,
            dependencies: [
                // Liste aqui as dependências do target, se houver
            ],
            path: "",
            swiftSettings: [
                .unsafeFlags(["-enable-bare-slash-regex"]),
                .define("DEBUG", .when(configuration: .debug))
            ]
        ),
        // Opcional: Adicione um target de teste se precisar
        // .testTarget(
        //     name: "\(name)Tests",
        //     dependencies: [.target(name: name)],
        //     path: "Tests"
        // ),
    ],
    swiftLanguageVersions: [.v5]
)
