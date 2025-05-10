import ProjectDescription
import ProjectDescriptionHelpers

// Configuração do projeto usando extension
let zenithCoreSampleConfigurations = Project.makeConfigurations(
    projectName: "ZenithCoreSample", 
    bundleID: "br.com.joao.gabriel.zenithCoreSample"
)

// Definição do projeto
let project = Project(
    name: "ZenithCoreSample",
    organizationName: Project.organizationName,
    options: .options(
        automaticSchemesOptions: .disabled
    ),
    packages: [
        .package(path: "../ZenithCore"),
        .package(path: "../ZenithCoreInterface")
    ],
    settings: .settings(
        configurations: zenithCoreSampleConfigurations
    ),
    targets: [
        Target.target(
            name: "ZenithCoreSample",
            destinations: .iOS,
            product: .app,
            bundleId: "br.com.joao.gabriel.zenithCoreSample",
            deploymentTargets: Project.deploymentTarget,
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
                configurations: zenithCoreSampleConfigurations
            )
        )
    ],
    schemes: [
        Scheme.scheme(
            name: "ZenithCoreSample",
            shared: true,
            buildAction: .buildAction(targets: ["ZenithCoreSample"]),
            runAction: .runAction(configuration: "Debug"),
            archiveAction: .archiveAction(configuration: "Release"),
            profileAction: .profileAction(configuration: "Debug"),
            analyzeAction: .analyzeAction(configuration: "Debug")
        )
    ]
)
