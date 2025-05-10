import ProjectDescription

// Definição de constantes para uso em todo o projeto
let deploymentTarget = DeploymentTargets.iOS("17.0")
let organizationName = "KettleGym"
let configurations: [Configuration] = [
    .debug(
        name: "Debug",
        settings: [
            "SWIFT_VERSION": "6.0",
            "MARKETING_VERSION": "1.0.0",
            "CURRENT_PROJECT_VERSION": "001",
            "INFOPLIST_FILE": "kettleGym/Info.plist",
            "PRODUCT_BUNDLE_IDENTIFIER": "br.com.joao.gabriel.kettleGym-Dev",
            "PRODUCT_NAME": "KettleGym",
            "CODE_SIGN_IDENTITY": "iPhone Developer",
            "CODE_SIGN_STYLE": "Manual",
            "DEVELOPMENT_TEAM": "G77MYT7HW8",
            "PROVISIONING_PROFILE_SPECIFIER": "match Development br.com.joao.gabriel.kettleGym-Dev",
            "GCC_PREPROCESSOR_DEFINITIONS": "$(inherited) DEBUG=1",
            "VALIDATE_WORKSPACE": "YES",
            "OTHER_LDFLAGS[sdk=iphonesimulator*]": "$(inherited) -Xlinker -interposable"
        ]
    ),
    .release(
        name: "Release",
        settings: [
            "SWIFT_VERSION": "6.0",
            "MARKETING_VERSION": "1.0.0",
            "CURRENT_PROJECT_VERSION": "001",
            "BUNDLE_ID": "br.com.joao.gabriel.kettleGym",
            "INFOPLIST_FILE": "kettleGym/Info.plist",
            "PRODUCT_BUNDLE_IDENTIFIER": "br.com.joao.gabriel.kettleGym",
            "PRODUCT_NAME": "KettleGym",
            "CODE_SIGN_IDENTITY": "iPhone Distribution",
            "CODE_SIGN_STYLE": "Manual",
            "DEVELOPMENT_TEAM": "G77MYT7HW8",
            "PROVISIONING_PROFILE_SPECIFIER": "match AppStore br.com.joao.gabriel.kettleGym",
            "GCC_PREPROCESSOR_DEFINITIONS": "$(inherited) DEBUG=0",
            "VALIDATE_WORKSPACE": "YES"
        ]
    )
]

// Definição do projeto principal
let project = Project(
    name: "KettleGym",
    organizationName: organizationName,
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
        configurations: configurations
    ),
    targets: [
        Target.target(
            name: "KettleGym",
            destinations: .iOS,
            product: .app,
            bundleId: "",
            deploymentTargets: deploymentTarget,
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
                configurations: configurations
            )
        ),
        Target.target(
            name: "KettleGymTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "br.com.joao.gabriel.KettleGymTests",
            deploymentTargets: deploymentTarget,
            sources: ["KettleGymTests/**"],
            dependencies: [
                .target(name: "KettleGym")
            ],
            settings: .settings(
                configurations: configurations
            )
        )
    ],
    schemes: [
        Scheme.scheme(
            name: "KettleGym-Dev",
            shared: true,
            buildAction: .buildAction(targets: ["KettleGym"]),
            testAction: .targets(["KettleGymTests"]),
            runAction: .runAction(configuration: "Debug"),
            archiveAction: .archiveAction(configuration: "Debug"),
            profileAction: .profileAction(configuration: "Debug"),
            analyzeAction: .analyzeAction(configuration: "Debug")
        ),
        Scheme.scheme(
            name: "KettleGym",
            shared: true,
            buildAction: .buildAction(targets: ["KettleGym"]),
            testAction: .targets(["KettleGymTests"]),
            runAction: .runAction(configuration: "Release"),
            archiveAction: .archiveAction(configuration: "Release"),
            profileAction: .profileAction(configuration: "Release"),
            analyzeAction: .analyzeAction(configuration: "Release")
        )
    ]
)
