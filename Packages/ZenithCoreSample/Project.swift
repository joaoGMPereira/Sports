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
            "INFOPLIST_FILE": "ZenithCoreSample/Info.plist",
            "PRODUCT_BUNDLE_IDENTIFIER": "br.com.joao.gabriel.zenithCoreSample",
            "PRODUCT_NAME": "ZenithCoreSample",
            "CODE_SIGN_IDENTITY": "iPhone Developer",
            "DEVELOPMENT_TEAM": "G77MYT7HW8",
            "CODE_SIGN_STYLE": "Manual",
            "PROVISIONING_PROFILE_SPECIFIER": "match Development br.com.joao.gabriel.zenithCoreSample",
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
            "INFOPLIST_FILE": "ZenithCoreSample/Info.plist",
            "PRODUCT_BUNDLE_IDENTIFIER": "br.com.joao.gabriel.zenithCoreSample",
            "PRODUCT_NAME": "ZenithCoreSample",
            "CODE_SIGN_IDENTITY": "iPhone Distribution",
            "DEVELOPMENT_TEAM": "G77MYT7HW8",
            "PROVISIONING_PROFILE_SPECIFIER": "match AppStore br.com.joao.gabriel.zenithCoreSample",
            "CODE_SIGN_STYLE": "Manual",
            "GCC_PREPROCESSOR_DEFINITIONS": "$(inherited) DEBUG=0",
            "VALIDATE_WORKSPACE": "YES"
        ]
    )
]

// Definição do projeto
let project = Project(
    name: "ZenithCoreSample",
    organizationName: organizationName,
    options: .options(
        automaticSchemesOptions: .disabled
    ),
    packages: [
        .package(path: "../ZenithCore"),
        .package(path: "../ZenithCoreInterface")
    ],
    settings: .settings(
        configurations: configurations
    ),
    targets: [
        Target.target(
            name: "ZenithCoreSample",
            destinations: .iOS,
            product: .app,
            bundleId: "br.com.joao.gabriel.zenithCoreSample",
            deploymentTargets: deploymentTarget,
            infoPlist: .file(path: "ZenithCoreSample/Info.plist"),
            sources: ["ZenithCoreSample/**"],
            scripts: [
                .pre(script: "$SRCROOT/../../Scripts/SwiftGen.sh", name: "SwiftGen")
            ],
            dependencies: [
                .package(product: "ZenithCore"),
                .package(product: "ZenithCoreInterface")
            ],
            settings: .settings(
                configurations: configurations
            )
        )
    ],
    schemes: [
        Scheme.scheme(
            name: "ZenithCoreSample",
            shared: true,
            buildAction: .buildAction(targets: ["ZenithCoreSample"]),
            runAction: .runAction(configuration: "Debug"),
            archiveAction: .archiveAction(configuration: "Debug"),
            profileAction: .profileAction(configuration: "Debug"),
            analyzeAction: .analyzeAction(configuration: "Debug")
        )
    ]
)
