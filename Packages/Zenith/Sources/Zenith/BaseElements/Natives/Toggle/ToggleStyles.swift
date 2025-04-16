import SwiftUI
import ZenithCoreInterface

public struct AnyToggleStyle: ToggleStyle {
    public let id: UUID = .init()
    
    private let _makeBody: (ToggleStyleConfiguration) -> AnyView
    
    public init<S: ToggleStyle>(_ style: S) {
        _makeBody = { configuration in
            AnyView(style.makeBody(configuration: configuration))
        }
    }
    
    public func makeBody(configuration: ToggleStyleConfiguration) -> some View {
        _makeBody(configuration)
    }
}

public struct SmallToggleStyle: ToggleStyle, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) public var themeConfigurator
    let color: ToggleColor
    
    public init(color: ToggleColor) {
        self.color = color
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            BaseToggle(
                onColor: colors.color(by: color.onColor) ?? .primary,
                offColor: colors.backgroundTertiary,
                width: 40,
                height: 20,
                isOn: configuration.$isOn
            )
        }
    }
}

public extension ToggleStyle where Self == SmallToggleStyle {
    static func small(_ color: ToggleColor) -> Self { .init(color: color) }
}

public struct DefaultToggleStyle: ToggleStyle, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) public var themeConfigurator
    let color: ToggleColor
    
    public init(color: ToggleColor) {
        self.color = color
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            BaseToggle(
                onColor: colors.color(by: color.onColor) ?? .primary,
                offColor: colors.backgroundTertiary,
                width: 50,
                height: 30,
                isOn: configuration.$isOn
            )
        }
    }
}

public extension ToggleStyle where Self == DefaultToggleStyle {
    static func `default`(_ color: ToggleColor) -> Self { .init(color: color) }
}

private struct BaseToggle: View {
    var onColor: Color
    var offColor: Color
    var width: CGFloat
    var height: CGFloat
    var thumbDiameter: CGFloat?
    @Binding var isOn: Bool
    
    // Calcula o diâmetro do polegar (thumb) proporcionalmente se não for especificado
    private func calculateThumbDiameter() -> CGFloat {
        return thumbDiameter ?? (height - 4)
    }
    
    // Calcula o deslocamento do polegar baseado no tamanho da trilha
    private func calculateThumbOffset(isOn: Bool) -> CGFloat {
        let thumbSize = calculateThumbDiameter()
        let availableSpace = width - thumbSize
        return isOn ? availableSpace/2 - 2 : -availableSpace/2 + 2
    }
    
    var body: some View {
        let thumbSize = calculateThumbDiameter()
        
        return ZStack {
            // Trilha
            RoundedRectangle(cornerRadius: height / 2)
                .fill(.clear)
                .frame(width: width, height: height)
                .overlay(
                    RoundedRectangle(cornerRadius: .infinity)
                        .stroke(offColor, lineWidth: 1)
                )
            
            // Polegar (thumb)
            Circle()
                .fill(isOn ? onColor : offColor)
                .shadow(radius: 1)
                .frame(width: thumbSize, height: thumbSize)
                .offset(x: calculateThumbOffset(isOn: isOn))
        }
        .onTapGesture {
            withAnimation(.spring()) {
                isOn.toggle()
            }
        }
    }
}

public enum ToggleColor: CaseIterable, Identifiable, Sendable {
    case highlightA
    case secondary
    
    public var id: Self { self }

    var onColor: ColorName {
        switch self {
        case .highlightA:
            .highlightA
        case .secondary:
            .textPrimary
        }
    }
}

public enum ToggleStyleCase: String, Decodable, CaseIterable, Identifiable {
    case smallHighlightA
    case mediumHighlightA
    case smallSecondary
    case mediumSecondary
    
    public var id: Self { self }
    
    @MainActor
    public func style() -> AnyToggleStyle {
        switch self {
        case .smallHighlightA:
            .init(.small(.highlightA))
        case .mediumHighlightA:
            .init(.default(.highlightA))
        case .smallSecondary:
            .init(.small(.secondary))
        case .mediumSecondary:
            .init(.default(.secondary))
        }
    }
}
