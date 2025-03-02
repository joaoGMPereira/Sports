import SwiftUI
import ZenithCoreInterface

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
            .smallSize()
    }
}

public struct MediumTagStyle: @preconcurrency TagStyle, BaseThemeDependencies {
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

public extension TagStyle where Self == MediumTagStyle {
    static func medium(_ color: TagColor) -> Self { .init(color: color) }
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
