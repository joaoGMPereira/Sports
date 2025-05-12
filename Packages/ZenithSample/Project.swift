import ProjectDescription
import ProjectDescriptionHelpers

// Configuração do projeto usando extension
let zenithSampleConfigurations = Project.makeConfigurations(
    projectName: "ZenithSample", 
    bundleID: "br.com.joao.gabriel.zenithSample"
)

// Definição do projeto
let project = Project(
    name: "ZenithSample",
    organizationName: Project.organizationName,
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
        configurations: zenithSampleConfigurations
    ),
    targets: [
        Target.target(
            name: "ZenithSample",
            destinations: .iOS,
            product: .app,
            bundleId: "br.com.joao.gabriel.zenithSample",
            deploymentTargets: Project.deploymentTarget,
            infoPlist: .file(path: "ZenithSample/Info.plist"),
            sources: ["ZenithSample/**"],
            resources: ["ZenithSample/Assets.xcassets"],
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
                configurations: zenithSampleConfigurations
            )
        ),
    ],
    schemes: [
        Scheme.scheme(
            name: "ZenithSample",
            shared: true,
            buildAction: .buildAction(targets: ["ZenithSample"]),
            runAction: .runAction(configuration: "Debug"),
            archiveAction: .archiveAction(configuration: "Release"),
            profileAction: .profileAction(configuration: "Debug"),
            analyzeAction: .analyzeAction(configuration: "Debug")
        )
    ]
)
