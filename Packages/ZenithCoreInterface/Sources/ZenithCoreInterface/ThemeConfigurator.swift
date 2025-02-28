import SwiftUI
@_exported import Dependencies

@MainActor
public protocol ThemeConfiguratorProtocol: Sendable {
    var theme: Theme { get }
    func change(_ theme: ThemeName)
}

public extension DependencyValues {
  var themeConfigurator: any ThemeConfiguratorProtocol {
    get { self[ThemeConfiguratorKey.self] }
    set { self[ThemeConfiguratorKey.self] = newValue }
  }
}

public enum ThemeConfiguratorKey: TestDependencyKey {
    public static let testValue: any ThemeConfiguratorProtocol = ThemeConfiguratorSpy()
}
