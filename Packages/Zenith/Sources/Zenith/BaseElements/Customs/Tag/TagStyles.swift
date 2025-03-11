import SwiftUI
import ZenithCoreInterface

public extension View {
    func tagStyle(_ style: some TagStyle) -> some View {
        environment(\.tagStyle, style)
    }
}

public struct SmallTagStyle: @preconcurrency TagStyle, BaseThemeDependencies {
    public var id = String(describing: Self.self)
    
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    let color: TagColor
    
    public init(color: TagColor) {
        self.color = color
    }
    
    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        BaseTag(configuration: configuration)
            .foregroundColor(colors.color(by: color.foregroundColor))
            .smallSize()
            .background(colors.color(by: color.backgroundColor))
            .cornerRadius(.infinity)
            .overlay(
                RoundedRectangle(cornerRadius: .infinity)
                    .stroke(colors.color(by: color.backgroundColor)?.darker() ?? .clear, lineWidth: 1)
            )
    }
}

public struct DefaultTagStyle: @preconcurrency TagStyle, BaseThemeDependencies {
    public var id = String(describing: Self.self)
    
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    let color: TagColor
    
    public init(color: TagColor) {
        self.color = color
    }
    
    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        BaseTag(configuration: configuration)
            .foregroundColor(colors.color(by: color.foregroundColor))
            .mediumSize()
            .background(colors.color(by: color.backgroundColor))
            .cornerRadius(.infinity)
            .overlay(
                RoundedRectangle(cornerRadius: .infinity)
                    .stroke(colors.color(by: color.backgroundColor)?.darker() ?? .clear, lineWidth: 1)
            )
    }
}

public extension TagStyle where Self == SmallTagStyle {
    static func small(_ color: TagColor) -> Self { .init(color: color) }
}

public extension TagStyle where Self == DefaultTagStyle {
    static func `default`(_ color: TagColor) -> Self { .init(color: color) }
}

public enum TagColor: CaseIterable, Identifiable, Sendable {
    case primary
    case secondary
    
    public var id: Self { self }
    
    var foregroundColor: ColorName {
        switch self {
        case .primary:
            .textSecondary
        case .secondary:
            .textPrimary
        }
    }
    
    var backgroundColor: ColorName {
        switch self {
        case .primary:
            .primary
        case .secondary:
            .backgroundTertiary
        }
    }
}

public enum TagStyleCase: CaseIterable, Identifiable {
    case smallPrimary
    case mediumPrimary
    case smallSecondary
    case mediumSecondary
    
    public var id: Self { self }
    
    public func style() -> AnyTagStyle {
        switch self {
        case .smallPrimary:
            .init(.small(.primary))
        case .mediumPrimary:
            .init(.default(.primary))
        case .smallSecondary:
            .init(.small(.secondary))
        case .mediumSecondary:
            .init(.default(.secondary))
        }
    }
}


fileprivate extension View {
    func smallSize() -> some View {
        self
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
    }
    func mediumSize() -> some View {
        self
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
    }
}

private struct BaseTag: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    
    let configuration: TagStyleConfiguration
    
    init(configuration: TagStyleConfiguration) {
        self.configuration = configuration
    }
    
    var body: some View {
        Text(configuration.text)
            .font(fonts.small.font)
    }
}
