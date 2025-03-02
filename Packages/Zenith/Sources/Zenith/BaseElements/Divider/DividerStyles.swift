import SwiftUI
import ZenithCoreInterface

public protocol DividerStyle: ViewModifier, Identifiable where ID == String {
}

public extension Divider {
    func dividerStyle<T: DividerStyle>(_ style: T) -> some View {
        modifier(style)
    }
}

public struct PrimaryDividerStyle: DividerStyle, @preconcurrency BaseThemeDependencies {
    public let id = String(describing: Self.self)
    
    @Dependency(\.themeConfigurator) public var themeConfigurator
    
    public func body(content: Content) -> some View {
        content.overlay(colors.textPrimary)
    }
}

public extension DividerStyle where Self == PrimaryDividerStyle {
    static var primary: Self { Self() }
}

public struct SecondaryDividerStyle: DividerStyle, @preconcurrency BaseThemeDependencies {
    public let id = String(describing: Self.self)
    
    @Dependency(\.themeConfigurator) public var themeConfigurator
    
    public func body(content: Content) -> some View {
        content.overlay(colors.textSecondary)
    }
}

public extension DividerStyle where Self == SecondaryDividerStyle {
    static var secondary: Self { Self() }
}

public struct TertiaryDividerStyle: DividerStyle, @preconcurrency BaseThemeDependencies {
    public let id = String(describing: Self.self)
    
    @Dependency(\.themeConfigurator) public var themeConfigurator
    
    public func body(content: Content) -> some View {
        content.overlay(colors.primary)
    }
}

public extension DividerStyle where Self == TertiaryDividerStyle {
    static var tertiary: Self { Self() }
}

public enum DividerStyleCase: CaseIterable, Identifiable {
    case primary
    case secondary
    case tertiary
    
    public var id: Self { self }
    
    var color: ColorName {
        switch self {
        case .primary:
            .textPrimary
        case .secondary:
            .textSecondary
        case .tertiary:
            .primary
        }
    }
    
    @MainActor
    public func style() -> AnyViewModifier {
        switch self {
        case .primary:
            return AnyViewModifier(PrimaryDividerStyle())
        case .secondary:
            return AnyViewModifier(SecondaryDividerStyle())
        case .tertiary:
            return AnyViewModifier(TertiaryDividerStyle())
        }
    }
}
