import SwiftUI
import ZenithCoreInterface


public extension View {
    func indicatorSelectorStyle(_ style: some IndicatorSelectorStyle) -> some View {
        environment(\.selectorStyle, style)
    }
}

public struct DefaultIndicatorSelectorStyle: @preconcurrency IndicatorSelectorStyle, BaseThemeDependencies {
    public var id = String(describing: Self.self)
    
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    
    public init() {}
    
    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        BaseIndicatorSelector(
            configuration: configuration,
            textStyle: .largeBold(.contentA),
            contentColor: colors.highlightA
        )
    }
}

public struct HighlightAIndicatorSelectorStyle: @preconcurrency IndicatorSelectorStyle, BaseThemeDependencies {
    public var id = String(describing: Self.self)
    
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    
    public init() {}
    
    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        BaseIndicatorSelector(
            configuration: configuration,
            textStyle: .largeBold(.highlightA),
            contentColor: colors.contentA
        )
    }
}

public extension IndicatorSelectorStyle where Self == DefaultIndicatorSelectorStyle {
    static func `default`() -> Self { .init() }
}

public extension IndicatorSelectorStyle where Self == HighlightAIndicatorSelectorStyle {
    static func highlightA() -> Self { .init() }
}

public enum IndicatorSelectorStyleCase: String, Decodable, CaseIterable, Identifiable {
    case `default`
    case highlightA
    
    public var id: Self { self }
    
    public func style() -> AnyIndicatorSelectorStyle {
        switch self {
        case .default:
            .init(.default())
        case .highlightA:
            .init(.highlightA())
        }
    }
}

struct IndicatorSelectorPreferenceKey: PreferenceKey {
    static let defaultValue: [CGFloat: Double] = [:]
    
    static func reduce(value: inout [CGFloat: Double], nextValue: () -> [CGFloat: Double]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

struct BaseIndicatorSelector<T: TextStyle>: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator
    
    let configuration: IndicatorSelectorStyleConfiguration
    let textStyle: T
    let contentColor: Color
    @State private var selectedValue: Double
    private let minValue: Double
    private let maxValue: Double
    private let step: Double
    
    @State private var itemPositions: [CGFloat: Double] = [:]
    @State private var manualSelection: Bool
    
    private var values: [Double] {
        stride(from: minValue, through: maxValue, by: step).map { $0 }
    }
    
    
    init(
        configuration: IndicatorSelectorStyleConfiguration,
        textStyle: T,
        contentColor: Color
    ) {
        self.configuration = configuration
        self.textStyle = textStyle
        self.contentColor = contentColor
        self.selectedValue = configuration.selectedValue
        self.minValue = configuration.minValue
        self.maxValue = configuration.maxValue
        self.step = configuration.step
        self.manualSelection = true
    }
    
    var body: some View {
        VStack {
            Text(String(format: configuration.text, selectedValue))
                .textStyle(textStyle)
                .padding(.bottom, 20)
            
            GeometryReader { geometry in
                ZStack {
                    ScrollViewReader { proxy in
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 8) {
                                ForEach(values, id: \.self) { value in
                                    Rectangle()
                                        .fill(value == selectedValue ? contentColor : contentColor.opacity(0.8))
                                        .frame(
                                            width: value == selectedValue ? 3 : 2,
                                            height: value.truncatingRemainder(dividingBy: 1.0) == 0 ? 40 : 20
                                        )
                                        .background(
                                            GeometryReader { itemGeometry in
                                                Color.clear
                                                    .preference(key: IndicatorSelectorPreferenceKey.self, value: [itemGeometry.frame(in: .global).midX: value])
                                            }
                                        )
                                        .contentShape(Rectangle())
                                        .id(value)
                                        .onTapGesture {
                                            manualSelection = true
                                            withAnimation {
                                                selectedValue = value
                                                proxy.scrollTo(value, anchor: .center)
                                            }
                                            Task {
                                                try? await Task.sleep(for: .milliseconds(300))
                                                manualSelection = false
                                            }
                                        }
                                }
                            }
                            .padding(.horizontal, geometry.size.width / 2 - 10)
                        }
                        .onAppear {
                            withAnimation {
                                proxy.scrollTo(selectedValue, anchor: .center)
                            }
                            Task {
                                try? await Task.sleep(for: .seconds(1))
                                manualSelection = false
                            }
                        }
                        .onPreferenceChange(IndicatorSelectorPreferenceKey.self) { preferences in
                            guard !manualSelection else { return }
                            let center = geometry.size.width / 2
                            let closest = preferences.min(by: { abs($0.key - center) < abs($1.key - center) })
                            if let closestValue = closest?.value {
                                selectedValue = closestValue
                            }
                        }
                    }
                    
                    HStack {
                        LinearGradient(
                            gradient: Gradient(colors: [colors.backgroundB.opacity(0.8), colors.backgroundB.opacity(0.1)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: 60)
                        .allowsHitTesting(false)
                        
                        Spacer()
                        
                        LinearGradient(
                            gradient: Gradient(colors: [colors.backgroundB.opacity(0.1), colors.backgroundB.opacity(0.8)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: 60)
                        .allowsHitTesting(false)
                    }
                }
            }
            .frame(height: 60)
        }
    }
}
