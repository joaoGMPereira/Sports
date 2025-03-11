
import SwiftUI
import Zenith
import SFSafeSymbols
import ZenithCoreInterface
import SwiftUIIntrospect

struct ZenithSampleView: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator

    // MARK: - Data Models

    enum TabType: String, CaseIterable, Identifiable {
        case baseElements = "Base Elements"
        case components = "Components"
        case future = "Future"

        var id: String { self.rawValue }

        var icon: SFSymbol {
            switch self {
            case .baseElements: return .squareGrid2x2
            case .components: return .puzzlepieceExtension
            case .future: return .sparkles
            }
        }
    }

    enum ElementCategory: String, CaseIterable, Identifiable {
        case custom = "Custom"
        case native = "Native"
        case other = "Other"

        var id: String { self.rawValue }
    }

    struct ElementType: Identifiable {
        var id = UUID()
        var name: String
        var category: ElementCategory
        var tabType: TabType
        var view: AnyView

        init<V: View>(name: String, category: ElementCategory, tabType: TabType, view: V) {
            self.name = name
            self.category = category
            self.tabType = tabType
            self.view = AnyView(view)
        }
    }

    // MARK: - State Properties

    @State private var selectedTab: TabType = .baseElements
    @State private var selectedCategory: ElementCategory = .custom

    // MARK: - Element Definitions

    private var elementTypes: [ElementType] = [
        // Base Elements - Natives
        ElementType(
            name: "Button",
            category: .native,
            tabType: .baseElements,
            view: ButtonSample()
        ),
        ElementType(
            name: "Text",
            category: .native,
            tabType: .baseElements,
            view: TextSample()
        ),
        ElementType(
            name: "Divider",
            category: .native,
            tabType: .baseElements,
            view: DividerSample()
        ),
        ElementType(
            name: "Toggle",
            category: .native,
            tabType: .baseElements,
            view: ToggleSample()
        ),
        // Base Elements - Customs
        ElementType(
            name: "Dynamic Image",
            category: .custom,
            tabType: .baseElements,
            view: DynamicImageSample()
        ),
        ElementType(
            name: "Tag",
            category: .custom,
            tabType: .baseElements,
            view: TagSample()
        ),
        ElementType(
            name: "RadioButton",
            category: .custom,
            tabType: .baseElements,
            view: RadioButtonSample()
        ),
        ElementType(
            name: "CheckBox",
            category: .custom,
            tabType: .baseElements,
            view: CheckBoxSample()
        ),
        ElementType(
            name: "WeightSelectorView",
            category: .custom,
            tabType: .baseElements,
            view: WeightSelectorView()
        )
    ]

    // MARK: - Filtered Elements

    private func filteredElements() -> [ElementType] {
        return elementTypes.filter {
            $0.tabType == selectedTab &&
            $0.category == selectedCategory
        }
    }

    // MARK: - Body

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(TabType.allCases) { tabType in
                tabContent(for: tabType)
                    .tabItem {
                        Label(tabType.rawValue, systemSymbol: tabType.icon)
                    }
                    .tag(tabType)
            }
        }
        .accentColor(colors.primary)
    }

    // MARK: - Tab Content

    private func tabContent(for tabType: TabType) -> some View {
        NavigationStack {
            List {
                Section {
                    categoryPicker
                        .listRowBackground(Color.clear)
                }
                ForEach(filteredElements()) { element in
                    element.view
                        .listRowBackground(colors.backgroundSecondary)
                }

                if filteredElements().isEmpty {
                    Text("No \(selectedCategory.rawValue.lowercased()) elements available.")
                        .font(fonts.medium.font)
                        .foregroundColor(colors.textPrimary)
                        .listRowBackground(colors.backgroundSecondary)
                }
            }
            .listRowSeparator(.hidden)
            .listSectionSeparator(.hidden)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(tabType.rawValue)
                        .font(fonts.mediumBold.font)
                        .foregroundColor(colors.textPrimary)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .scrollContentBackground(.hidden)
            .background(colors.background)
        }
    }

    // MARK: - Category Picker

    private var categoryPicker: some View {
        Picker("Element Category", selection: $selectedCategory) {
            ForEach(ElementCategory.allCases) { category in
                Text(category.rawValue).font(fonts.mediumBold.font).tag(category)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .introspect(.picker(style: .segmented), on: .iOS(.v17, .v18)) {
            $0.backgroundColor = UIColor.clear
            $0.layer.borderColor = colors.primary.uiColor().cgColor
                  $0.selectedSegmentTintColor = colors.primary.uiColor()
                  $0.layer.borderWidth = 1

            let titleTextAttributes = [
                NSAttributedString.Key.foregroundColor: colors.textPrimary.uiColor(),
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .bold)
            ]
            $0.setTitleTextAttributes(
                titleTextAttributes,
                for:.normal
            )

            let titleTextAttributesSelected = [
                NSAttributedString.Key.foregroundColor: colors.textSecondary.uiColor(),
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .bold)
            ]
            $0.setTitleTextAttributes(
                titleTextAttributesSelected,
                for:.selected
            )
        }
    }
}

// MARK: - Preview
struct ZenithSampleView_Previews: PreviewProvider {
    static var previews: some View {
        ZenithSampleView()
    }
}
import SwiftUI

struct WeightPreferenceKey: PreferenceKey {
    static let defaultValue: [CGFloat: Double] = [:]

    static func reduce(value: inout [CGFloat: Double], nextValue: () -> [CGFloat: Double]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

struct WeightSelectorView: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator

    @State private var selectedWeight: Double = 70.0 // Peso inicial em kg
    private let minWeight: Double = 40.0
    private let maxWeight: Double = 150.0
    private let step: Double = 0.1 // 100g

    @State private var itemPositions: [CGFloat: Double] = [:]
    @State private var manualSelection: Bool = false

    private var weights: [Double] {
        stride(from: minWeight, through: maxWeight, by: step).map { $0 }
    }

    var body: some View {
        VStack {
            Text(String(format: "%.1f kg", selectedWeight))
                .textStyle(.mediumBold(.primary))
                .padding(.bottom, 20)

            GeometryReader { geometry in
                ZStack {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(weights, id: \.self) { weight in
                                Rectangle()
                                    .fill(weight == selectedWeight ? colors.primary : colors.primary.opacity(0.8))
                                    .frame(
                                        width: weight == selectedWeight ? 3 : 2,
                                        height: weight.truncatingRemainder(dividingBy: 1.0) == 0 ? 40 : 20
                                    )
                                    .background(
                                        GeometryReader { itemGeometry in
                                            Color.clear
                                                .preference(key: WeightPreferenceKey.self, value: [itemGeometry.frame(in: .global).midX: weight])
                                        }
                                    )
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        manualSelection = true
                                        withAnimation {
                                            selectedWeight = weight
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            manualSelection = false
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal, geometry.size.width / 2 - 10)
                    }
                    .onPreferenceChange(WeightPreferenceKey.self) { preferences in
                        guard !manualSelection else { return }
                        let center = geometry.size.width / 2
                        let closest = preferences.min(by: { abs($0.key - center) < abs($1.key - center) })
                        if let closestWeight = closest?.value {
                            selectedWeight = closestWeight
                        }
                    }

                    HStack {
                        LinearGradient(
                            gradient: Gradient(colors: [colors.backgroundSecondary.opacity(0.8), colors.backgroundSecondary.opacity(0.1)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: 60)
                        .allowsHitTesting(false)

                        Spacer()

                        LinearGradient(
                            gradient: Gradient(colors: [colors.backgroundSecondary.opacity(0.1), colors.backgroundSecondary.opacity(0.8)]),
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

#Preview {
    WeightSelectorView()
}
