import SwiftUI
import ZenithCoreInterface

@MainActor
@Observable
public final class ThemeConfigurator: ThemeConfiguratorProtocol {
    @MainActor public private(set) var theme: Theme = .dark()
    
    @MainActor var themes: [ThemeName: Theme] = [
        .light: .light(),
        .dark: .dark()
    ]
    
    public init(theme: Theme) {
        self.theme = theme
    }
    
    public init(theme: ThemeName) {
        self.theme = themes[theme] ?? .dark()
    }
    
    @MainActor
    public func change(_ theme: ThemeName) {
        self.theme = themes[theme] ?? .dark()
    }
}

