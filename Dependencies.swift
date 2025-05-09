import ProjectDescription

let dependencies = Dependencies(
    swiftPackageManager: SwiftPackageManagerDependencies(
        [
            .remote(url: "https://github.com/SFSafeSymbols/SFSafeSymbols.git", requirement: .upToNextMajor(from: "5.2.0")),
            .remote(url: "https://github.com/johnno1962/HotSwiftUI.git", requirement: .upToNextMajor(from: "1.1.0")),
            .remote(url: "https://github.com/DebugSwift/DebugSwift.git", requirement: .upToNextMajor(from: "0.3.6")),
            .remote(url: "https://github.com/exyte/PopupView.git", requirement: .revision("c82f68dd56d9359e144ab0446f5866208e4a02e8")),
            .remote(url: "https://github.com/siteline/swiftui-introspect.git", requirement: .exact("1.3.0")),
            .remote(url: "https://github.com/pointfreeco/swift-dependencies.git", requirement: .upToNextMajor(from: "1.7.0"))
        ],
        baseSettings: .settings(
            configurations: [
                .debug(name: "Debug"),
                .release(name: "Release")
            ]
        )
    ),
    platforms: [.iOS]
)