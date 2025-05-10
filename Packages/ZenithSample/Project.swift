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
            "INFOPLIST_FILE": "ZenithSample/Info.plist",
            "PRODUCT_BUNDLE_IDENTIFIER": "br.com.joao.gabriel.zenithSample",
            "PRODUCT_NAME": "ZenithSample",
            "CODE_SIGN_IDENTITY": "iPhone Developer",
            "DEVELOPMENT_TEAM": "G77MYT7HW8",
            "CODE_SIGN_STYLE": "Manual",
            "PROVISIONING_PROFILE_SPECIFIER": "match Development br.com.joao.gabriel.zenithSample",
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
            "INFOPLIST_FILE": "ZenithSample/Info.plist",
            "PRODUCT_BUNDLE_IDENTIFIER": "br.com.joao.gabriel.zenithSample",
            "PRODUCT_NAME": "ZenithSample",
            "CODE_SIGN_IDENTITY": "iPhone Distribution",
            "DEVELOPMENT_TEAM": "G77MYT7HW8",
            "CODE_SIGN_STYLE": "Manual",
            "PROVISIONING_PROFILE_SPECIFIER": "match AppStore br.com.joao.gabriel.zenithSample",
            "GCC_PREPROCESSOR_DEFINITIONS": "$(inherited) DEBUG=0",
            "VALIDATE_WORKSPACE": "YES"
        ]
    )
]

// Definição do projeto
let project = Project(
    name: "ZenithSample",
    organizationName: organizationName,
    options: .options(
        automaticSchemesOptions: .disabled
    ),
    packages: [
        .package(path: "../ZenithCore"),
        .package(path: "../ZenithCoreInterface"),
        .package(path: "../Zenith"),
        .remote(url: "https://github.com/siteline/swiftui-introspect.git", requirement: .exact("1.3.0"))
    ],
    settings: .settings(
        configurations: configurations
    ),
    targets: [
        Target.target(
            name: "ZenithSample",
            destinations: .iOS,
            product: .app,
            bundleId: "br.com.joao.gabriel.zenithSample",
            deploymentTargets: deploymentTarget,
            infoPlist: .file(path: "ZenithSample/Info.plist"),
            sources: ["ZenithSample/**"],
            scripts: [
                .pre(script: "$SRCROOT/../../Scripts/SwiftGen.sh", name: "SwiftGen")
            ],
            dependencies: [
                .package(product: "ZenithCore"),
                .package(product: "ZenithCoreInterface"),
                .package(product: "Zenith"),
                .package(product: "SwiftUIIntrospect")
            ],
            settings: .settings(
                configurations: configurations
            )
        )
    ],
    schemes: [
        Scheme.scheme(
            name: "ZenithSample",
            shared: true,
            buildAction: .buildAction(targets: ["ZenithSample"]),
            runAction: .runAction(configuration: "Debug"),
            archiveAction: .archiveAction(configuration: "Debug"),
            profileAction: .profileAction(configuration: "Debug"),
            analyzeAction: .analyzeAction(configuration: "Debug")
        )
    ]
)
