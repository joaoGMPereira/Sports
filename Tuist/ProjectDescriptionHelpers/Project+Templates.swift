import ProjectDescription

public extension Project {
    // MARK: - Deployment e Organization
    static var deploymentTarget: DeploymentTargets {
        DeploymentTargets.iOS("17.0")
    }
    
    static var organizationName: String {
        "KettleGym"
    }
    
    // MARK: - Configurações Comuns
    static var commonSettings: SettingsDictionary {
        [
            "SWIFT_VERSION": "6.0",
            "MARKETING_VERSION": "1.0.0",
            "CURRENT_PROJECT_VERSION": "007",
            "VALIDATE_WORKSPACE": "YES"
        ]
    }
    
    // MARK: - Configurações por Modo
    static var debugCommonSettings: SettingsDictionary {
        commonSettings.merging([
            "GCC_PREPROCESSOR_DEFINITIONS": "$(inherited) DEBUG=1",
            "OTHER_LDFLAGS[sdk=iphonesimulator*]": "$(inherited) -Xlinker -interposable",
            "CODE_SIGN_IDENTITY": "iPhone Developer",
            "CODE_SIGN_STYLE": "Manual",
            "DEVELOPMENT_TEAM": "G77MYT7HW8"
        ])
    }
    
    static var releaseCommonSettings: SettingsDictionary {
        commonSettings.merging([
            "GCC_PREPROCESSOR_DEFINITIONS": "$(inherited) DEBUG=0",
            "CODE_SIGN_IDENTITY": "iPhone Distribution",
            "CODE_SIGN_STYLE": "Manual",
            "DEVELOPMENT_TEAM": "G77MYT7HW8"
        ])
    }
    
    // MARK: - Funções Auxiliares
    static func makeProjectSettings(projectName: String, bundleID: String, isDev: Bool) -> SettingsDictionary {
        return [
            "INFOPLIST_FILE": "\(projectName)/Info.plist",
            "PRODUCT_NAME": "\(projectName)\(isDev ? "-Dev" : "")",
            "PRODUCT_BUNDLE_IDENTIFIER": "\(bundleID)\(isDev ? "-Dev" : "")"
        ]
    }
    
    static func makeDebugSettings(projectName: String, bundleID: String, isDev: Bool) -> SettingsDictionary {
        if isDev {
            makeDevDebugSettings(
                projectName: projectName,
                bundleID: bundleID
            )
        } else {
            makeProjectSettings(
                projectName: projectName,
                bundleID: bundleID,
                isDev: false
            )
            .merging([
                "PROVISIONING_PROFILE_SPECIFIER": "match Development \(bundleID)"
            ])
        }
    }
    
    static func makeDevDebugSettings(projectName: String, bundleID: String) -> SettingsDictionary {
        return makeProjectSettings(
            projectName: projectName,
            bundleID: bundleID,
            isDev: true
        )
        .merging([
            "PROVISIONING_PROFILE_SPECIFIER": "match Development \(bundleID)-Dev"
        ])
    }
    
    static func makeReleaseSettings(projectName: String, bundleID: String, isDev: Bool) -> SettingsDictionary {
        if isDev {
            makeDevReleaseSettings(
                projectName: projectName,
                bundleID: bundleID
            )
        } else {
            makeProjectSettings(
                projectName: projectName,
                bundleID: bundleID,
                isDev: false
            )
            .merging([
                "PROVISIONING_PROFILE_SPECIFIER": "match AppStore \(bundleID)"
            ])
        }
    }
    
    static func makeDevReleaseSettings(projectName: String, bundleID: String) -> SettingsDictionary {
        return makeProjectSettings(
            projectName: projectName,
            bundleID: bundleID,
            isDev: true
        )
        .merging([
            "PROVISIONING_PROFILE_SPECIFIER": "match AppStore \(bundleID)-Dev"
        ])
    }
    
    // MARK: - Gerador de Configurações
    static func makeConfigurations(projectName: String, bundleID: String) -> [Configuration] {
        return [
            .debug(
                name: "Debug",
                settings: debugCommonSettings.merging(
                    makeDebugSettings(
                        projectName: projectName,
                        bundleID: bundleID,
                        isDev: false
                    )
                )
            ),
            .release(
                name: "Release",
                settings: releaseCommonSettings.merging(
                    makeReleaseSettings(
                        projectName: projectName,
                        bundleID: bundleID,
                        isDev: false
                    )
                )
            )
        ]
    }
    
    static func makeKettleGymConfigurations(projectName: String, bundleID: String) -> [Configuration] {
        return [
            .debug(
                name: "Debug",
                settings: debugCommonSettings.merging(
                    makeDebugSettings(
                        projectName: projectName,
                        bundleID: bundleID,
                        isDev: false
                    )
                )
            ),
            .release(
                name: "Release",
                settings: releaseCommonSettings.merging(
                    makeReleaseSettings(
                        projectName: projectName,
                        bundleID: bundleID,
                        isDev: false
                    )
                )
            ),
            .debug(
                name: "Debug-Dev",
                settings: debugCommonSettings.merging(
                    makeDebugSettings(
                        projectName: projectName,
                        bundleID: bundleID,
                        isDev: true
                    )
                )
            ),
            .release(
                name: "Release-Dev",
                settings: releaseCommonSettings.merging(
                    makeReleaseSettings(
                        projectName: projectName,
                        bundleID: bundleID,
                        isDev: true
                    )
                )
            )
        ]
    }
}
