import ProjectDescription

let deploymentTarget = DeploymentTargets.iOS("17.0")
let organizationName = "KettleGym"

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
        configurations: [
            .debug(name: "Debug", xcconfig: "Configs/BaseDebug.xcconfig"),
            .release(name: "Release", xcconfig: "Configs/BaseRelease.xcconfig")
        ]
    ),
    targets: [
        Target.target(
            name: "ZenithCoreSample",
            destinations: .iOS,
            product: .app,
            bundleId: "com.\(organizationName).ZenithCoreSample",
            deploymentTargets: deploymentTarget,
            infoPlist: .file(path: "ZenithCoreSample/Info.plist"),
            sources: ["ZenithCoreSample/**"],
            scripts: [
                .pre(script: "$SRCROOT/../../Scripts/SwiftGen.sh", name: "SwiftGen")
            ],
            dependencies: [
                .package(product: "ZenithCore"),
                .package(product: "ZenithCoreInterface")
            ]
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
