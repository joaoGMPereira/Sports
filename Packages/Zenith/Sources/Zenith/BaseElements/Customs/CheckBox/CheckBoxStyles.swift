import SwiftUI
import ZenithCoreInterface


public extension View {
    func checkboxStyle(_ style: some CheckBoxStyle) -> some View {
        environment(\.checkboxStyle, style)
    }
}

public struct DefaultCheckBoxStyle: @preconcurrency CheckBoxStyle, BaseThemeDependencies {
    public var id = String(describing: Self.self)
    
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    
    public init() {}
    
    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        BaseCheckBox(configuration: configuration)
    }
}

public extension CheckBoxStyle where Self == DefaultCheckBoxStyle {
    static func `default`() -> Self { .init() }
}

public enum CheckBoxStyleCase: CaseIterable, Identifiable {
    case `default`
    
    public var id: Self { self }
    
    public func style() -> AnyCheckBoxStyle {
        switch self {
        case .default:
                .init(.default())
        }
    }
}

fileprivate struct AnimationProperties {
    var scaleValue: CGFloat = 1.0
}

struct BaseCheckBox: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    
    let configuration: CheckBoxStyleConfiguration
    @State private var animate: Bool = false
    
    init(
        configuration: CheckBoxStyleConfiguration
    ) {
        self.configuration = configuration
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            circleView
            labelView
        }
        .contentShape(Rectangle())
        .onTapGesture { configuration.isSelected.toggle() }
        .disabled(isDisabled)
    }
}

private extension BaseCheckBox {
    @ViewBuilder var labelView: some View {
        if !configuration.text.isEmpty { // Show label if label is not empty
            Text(configuration.text)
                .foregroundColor(labelColor)
        }
    }
    
    @ViewBuilder var circleView: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(innerCircleColor)
            .frame(width: 14, height: 14)
            .keyframeAnimator(
                initialValue: AnimationProperties(), trigger: animate,
                content: { content, value in
                    content
                        .scaleEffect(value.scaleValue)
                },
                keyframes: { _ in
                    KeyframeTrack(\.scaleValue) {
                        CubicKeyframe(0.9, duration: 0.05)
                        CubicKeyframe(1.10, duration: 0.15)
                        CubicKeyframe(1, duration: 0.25)
                    }
                })
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(outlineColor, lineWidth: 6)
                    .animation(.bouncy, value: outlineColor)
            ) // Circle outline
            .frame(width: 20, height: 20)
            .keyframeAnimator(
                initialValue: AnimationProperties(), trigger: animate,
                content: { content, value in
                    content
                        .scaleEffect(value.scaleValue)
                },
                keyframes: { _ in
                    KeyframeTrack(\.scaleValue) {
                        CubicKeyframe(0.9, duration: 0.05)
                        CubicKeyframe(1.10, duration: 0.15)
                        CubicKeyframe(1, duration: 0.25)
                    }
                })
            .onChange(of: configuration.isSelected) { _, newValue in
                animate.toggle()
            }
    }
}

private extension BaseCheckBox {
    var isDisabled: Bool {
        configuration.isDisabled
    }
    var innerCircleColor: Color {
        if isDisabled {
            return colors.contentB.opacity(0.6)
        }
        return colors.contentB
    }
    
    var outlineColor: Color {
        if isDisabled {
            return colors.backgroundC.opacity(0.6)
        }
        return configuration.isSelected ? colors.highlightA : colors.backgroundC
    }
    
    var labelColor: Color {
        return isDisabled ? colors.backgroundC.opacity(0.6) : colors.contentA
    }
}
