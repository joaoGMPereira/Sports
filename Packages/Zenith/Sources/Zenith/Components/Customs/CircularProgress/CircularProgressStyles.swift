import SwiftUI
import ZenithCoreInterface


public extension View {
    func circularProgressStyle(_ style: some CircularProgressStyle) -> some View {
        environment(\.circularProgressStyle, style)
    }
}

public struct ContentACircularProgressStyle: @preconcurrency CircularProgressStyle, BaseThemeDependencies {
    public var id = String(describing: Self.self)
    
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    
    public init() {}
    
    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        BaseCircularProgress(configuration: configuration)
            .foregroundColor(colors.contentA)
    }
}

public struct ContentBCircularProgressStyle: @preconcurrency CircularProgressStyle, BaseThemeDependencies {
    public var id = String(describing: Self.self)
    
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    
    public init() {}
    
    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        BaseCircularProgress(configuration: configuration)
            .foregroundColor(colors.contentB)
    }
}

public struct HighlightACircularProgressStyle: @preconcurrency CircularProgressStyle, BaseThemeDependencies {
    public var id = String(describing: Self.self)
    
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    
    public init() {}
    
    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        BaseCircularProgress(configuration: configuration)
            .foregroundColor(colors.highlightA)
    }
}

public extension CircularProgressStyle where Self == ContentACircularProgressStyle {
    static func contentA() -> Self { .init() }
}

public extension CircularProgressStyle where Self == ContentBCircularProgressStyle {
    static func contentB() -> Self { .init() }
}

public extension CircularProgressStyle where Self == HighlightACircularProgressStyle {
    static func highlightA() -> Self { .init() }
}

public enum CircularProgressStyleCase: CaseIterable, Identifiable {
    case contentA
    case contentB
    case highlightA
    
    public var id: Self { self }
    
    public func style() -> AnyCircularProgressStyle {
        switch self {
        case .contentA:
            .init(.contentA())
        case .contentB:
            .init(.contentB())
        case .highlightA:
            .init(.highlightA())
        }
    }
}

private struct BaseCircularProgress: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    
    let configuration: CircularProgressStyleConfiguration
    
    init(configuration: CircularProgressStyleConfiguration) {
        self.configuration = configuration
    }
    
    var body: some View {
        ZStack {
            // Círculo de fundo
            Circle()
                .stroke(colors.backgroundC, lineWidth: 1)
                .frame(width: configuration.size, height: configuration.size)
            
            // Círculo de progresso
            Circle()
                .trim(from: 0, to: CGFloat(configuration.progress))
                .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .frame(width: configuration.size, height: configuration.size)
                .animation(configuration.animated ? .easeInOut(duration: 0.1) : nil, value: configuration.progress)
            
            // Valor de progresso como texto (opcional)
            if configuration.showText {
                textView
            }
        }
    }
    
    @ViewBuilder
    private var textView: some View {
        if configuration.animated {
            Text(String(format: "%.0f%%", configuration.progress * 100))
                .font(fonts.small)
                .fontWeight(.semibold)
                .contentTransition(.numericText(value: configuration.progress * 100))
                .animation(.easeIn(duration: 0.3), value: configuration.progress)
        } else {
            Text(String(format: "%.0f%%", configuration.progress * 100))
                .font(fonts.small)
                .fontWeight(.semibold)
        }
    }
}
