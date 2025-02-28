import ZenithCoreInterface

public protocol BaseThemeDependencies {
    var themeConfigurator: any ThemeConfiguratorProtocol { get }
}

public extension BaseThemeDependencies {
    @MainActor
    var fonts: any FontsProtocol {
        themeConfigurator.theme.fonts
    }
    
    @MainActor
    var colors: any ColorsProtocol {
        themeConfigurator.theme.colors
    }
    
    @MainActor
    var spacings: any SpacingsProtocol {
        themeConfigurator.theme.spacings
    }
}
