import ProjectDescription

let config = Config(
    compatibleXcodeVersions: .all,
    plugins: [],
    generationOptions: .options(
        resolveDependenciesWithSystemScm: false,
        disablePackageVersionLocking: false,
        staticSideEffectsWarningTargets: .all,
        defaultConfiguration: nil
    )
)