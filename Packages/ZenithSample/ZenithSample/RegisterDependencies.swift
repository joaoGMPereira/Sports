import ZenithCore
import ZenithCoreInterface

@MainActor
extension ThemeConfiguratorKey: @preconcurrency @retroactive DependencyKey {
    public static let liveValue: ThemeConfiguratorProtocol = ThemeConfigurator(theme: .dark)
}
