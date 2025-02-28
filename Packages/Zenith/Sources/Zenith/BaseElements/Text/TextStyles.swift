import SwiftUI
import ZenithCoreInterface

public struct AnyViewModifier: ViewModifier {
    private let modifier: (AnyView) -> AnyView

    public init<M: ViewModifier>(_ modifier: M) {
        self.modifier = { AnyView($0.modifier(modifier)) }
    }

    public func body(content: Content) -> some View {
        modifier(AnyView(content))
    }
}

public protocol TextStyle: ViewModifier, Identifiable where ID == String {
    var name: String { get }
}

public extension Text {
    func textStyle<T: TextStyle>(_ style: T) -> some View {
        modifier(style)
    }
}

public struct SmallPrimaryTextStyle: TextStyle, ViewModifier {
    public let id: String
    public var name = String(describing:Self.self)
    
    @Dependency(\.themeConfigurator) public var themeConfigurator
    var fonts: any FontsProtocol {
        themeConfigurator.theme.fonts
    }
    
    var colors: any ColorsProtocol {
        themeConfigurator.theme.colors
    }
    
    var spacings: any SpacingsProtocol {
        themeConfigurator.theme.spacings
    }
    
    public init() {
        self.id = name
    }
    
    public func body(content: Content) -> some View {
        print(fonts.small.lineHeight - fonts.small.fontLineHeight)
        print((fonts.small.lineHeight - fonts.small.fontLineHeight) / 2)
        return content
            .font(fonts.small.font)
            .lineSpacing(fonts.small.lineHeight - fonts.small.fontLineHeight)
            .padding(.vertical, (fonts.small.lineHeight - fonts.small.fontLineHeight) / 2)
            .foregroundStyle(colors.textPrimary)
    }
}

public extension TextStyle where Self == SmallPrimaryTextStyle {
    static var smallPrimary: Self { Self() }
}

public struct SmallSecondaryTextStyle: TextStyle, ViewModifier {
    public let id: String
    public var name = String(describing:Self.self)
    
    @Dependency(\.themeConfigurator) public var themeConfigurator
    var fonts: any FontsProtocol {
        themeConfigurator.theme.fonts
    }
    
    var colors: any ColorsProtocol {
        themeConfigurator.theme.colors
    }
    
    var spacings: any SpacingsProtocol {
        themeConfigurator.theme.spacings
    }
    
    public init() {
        self.id = name
    }
    
    public func body(content: Content) -> some View {
        print(fonts.small.lineHeight - fonts.small.fontLineHeight)
        print((fonts.small.lineHeight - fonts.small.fontLineHeight) / 2)
        return content
            .font(fonts.small.font)
            .lineSpacing(fonts.small.lineHeight - fonts.small.fontLineHeight)
            .padding(.vertical, (fonts.small.lineHeight - fonts.small.fontLineHeight) / 2)
            .foregroundStyle(colors.textSecondary)
    }
}

public extension TextStyle where Self == SmallSecondaryTextStyle {
    static var smallSecondary: Self { Self() }
}
