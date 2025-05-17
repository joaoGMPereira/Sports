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
    let color: ColorName
    
    public init(color: ColorName) {
        self.color = color
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            BaseToggle(
                onColor: colors.color(by: color) ?? .primary,
                offColor: colors.backgroundC,
                width: 40,
                height: 20,
                isOn: configuration.$isOn
            )
        }
    }
}

public extension ToggleStyle where Self == SmallToggleStyle {
    static func small(_ color: ColorName = .highlightA) -> Self { .init(color: color) }
}

public struct DefaultToggleStyle: ToggleStyle, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) public var themeConfigurator
    let color: ColorName
    
    public init(color: ColorName) {
        self.color = color
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            BaseToggle(
                onColor: colors.color(by: color) ?? .primary,
                offColor: colors.backgroundC,
                width: 50,
                height: 30,
                isOn: configuration.$isOn
            )
        }
    }
}

public extension ToggleStyle where Self == DefaultToggleStyle {
    static func `default`(_ color: ColorName = .highlightA) -> Self { .init(color: color) }
}

private struct BaseToggle: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator
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
                        .stroke(colors.contentA, lineWidth: 1)
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

public enum ToggleStyleCase: String, Decodable, CaseIterable, Identifiable {
    case smallHighlightA
    case mediumHighlightA
    case smallContentA
    case mediumContentA
    
    public var id: Self { self }
    
    @MainActor
    public func style() -> AnyToggleStyle {
        switch self {
        case .smallHighlightA:
            .init(.small(.highlightA))
        case .mediumHighlightA:
            .init(.default(.highlightA))
        case .smallContentA:
            .init(.small(.contentA))
        case .mediumContentA:
            .init(.default(.contentA))
        }
    }
}
