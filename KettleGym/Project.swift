import ProjectDescription
import ProjectDescriptionHelpers


// Configuração do projeto usando extension
let kettleGymConfigurations = Project.makeKettleGymConfigurations(
    projectName: "KettleGym",
    bundleID: "br.com.joao.gabriel.kettleGym"
)

// Definição do projeto principal
let project = Project(
    name: "KettleGym",
    organizationName: Project.organizationName,
    options: .options(
        automaticSchemesOptions: .disabled
    ),
    packages: [
        .remote(url: "https://github.com/SFSafeSymbols/SFSafeSymbols.git", requirement: .upToNextMajor(from: "5.2.0")),
        .remote(url: "https://github.com/johnno1962/HotSwiftUI.git", requirement: .upToNextMajor(from: "1.1.0")),
        .remote(url: "https://github.com/DebugSwift/DebugSwift.git", requirement: .upToNextMajor(from: "0.3.6")),
        .remote(url: "https://github.com/exyte/PopupView.git", requirement: .revision("c82f68dd56d9359e144ab0446f5866208e4a02e8")),
        .remote(url: "https://github.com/siteline/swiftui-introspect.git", requirement: .exact("1.3.0")),
        .package(path: "../Packages/Zenith"),
        .package(path: "../Packages/ZenithCore"),
        .package(path: "../Packages/ZenithCoreInterface")
    ],
    settings: .settings(
        configurations: kettleGymConfigurations
    ),
    targets: [
        Target.target(
            name: "KettleGym",
            destinations: .iOS,
            product: .app,
            bundleId: "br.com.joao.gabriel.kettleGym",
            deploymentTargets: Project.deploymentTarget,
            infoPlist: .file(path: "KettleGym/Info.plist"),
            sources: ["KettleGym/**"],
            resources: ["KettleGym/Assets.xcassets", "KettleGym/Localizable.xcstrings"],
            entitlements: "KettleGym/Sports.entitlements",
            scripts: [
                .pre(script: "$SRCROOT/../Scripts/SwiftGen.sh", name: "SwiftGen")
            ],
            dependencies: [
                .package(product: "SFSafeSymbols"),
                .package(product: "HotSwiftUI"),
                .package(product: "DebugSwift"),
                .package(product: "PopupView"),
                .package(product: "ZenithCore"),
                .package(product: "ZenithCoreInterface"),
                .package(product: "Zenith"),
                .package(product: "SwiftUIIntrospect")
            ],
            settings: .settings(
                configurations: kettleGymConfigurations
            )
        ),
        Target.target(
            name: "KettleGymTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "br.com.joao.gabriel.KettleGymTests",
            deploymentTargets: Project.deploymentTarget,
            sources: ["KettleGymTests/**"],
            dependencies: [
                .target(name: "KettleGym")
            ],
            settings: .settings(
                configurations: Project.makeConfigurations(
                    projectName: "KettleGymTests", 
                    bundleID: "br.com.joao.gabriel.KettleGymTests"
                )
            )
        )
    ],
    schemes: [
        .scheme(
            name: "KettleGym-Dev",
            buildAction: .buildAction(targets: ["KettleGym"]),
            testAction: .targets(["KettleGymTests"]),
            runAction: .runAction(configuration: "Debug-Dev"),
            archiveAction: .archiveAction(configuration: "Release-Dev"),
            profileAction: .profileAction(configuration: "Debug-Dev"),
            analyzeAction: .analyzeAction(configuration: "Debug-Dev")
        ),
        .scheme(
            name: "KettleGym",
            buildAction: .buildAction(targets: ["KettleGym"]),
            testAction: .targets(["KettleGymTests"]),
            runAction: .runAction(configuration: "Debug"),
            archiveAction: .archiveAction(configuration: "Release"),
            profileAction: .profileAction(configuration: "Debug"),
            analyzeAction: .analyzeAction(configuration: "Debug")
        )
    ]
)
