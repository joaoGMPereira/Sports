import ProjectDescription

let deploymentTarget = DeploymentTargets.iOS("17.0")
let organizationName = "KettleGym"

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
        configurations: [
            .debug(name: "Debug", xcconfig: "Configs/BaseDebug.xcconfig"),
            .release(name: "Release", xcconfig: "Configs/BaseRelease.xcconfig")
        ]
    ),
    targets: [
        Target.target(
            name: "ZenithSample",
            destinations: .iOS,
            product: .app,
            bundleId: "com.\(organizationName).ZenithSample",
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
            ]
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
