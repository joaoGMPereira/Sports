import SwiftUI
import Zenith
import ZenithCoreInterface
import SFSafeSymbols

struct CardSample: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator

    @State private var isExpanded = false
    @State private var title = "Sample Card"
    @State private var selectedSymbol = "figure.run"
    @State private var symbolSearch = ""

    @State private var selectedStyle = BasicCardStyleCase.allCases.first!
    @State private var selectedArrangement = StackArrangementCase.allCases.first!
    @State private var selectedContentLayout = CardLayoutCase.allCases.first!

    var filteredSymbols: Set<SFSymbol> {
        if symbolSearch.isEmpty {
            return SFSymbol.allSymbols
        }
        return SFSymbol.allSymbols.filter { $0.rawValue.lowercased().contains(symbolSearch.lowercased()) }
    }

    var body: some View {
        SectionView(
            title: "Basic Card",
            isExpanded: $isExpanded
        ) {
            VStack(spacing: 16) {
                BasicCard(
                    image: SFSymbol(rawValue: selectedSymbol),
                    title: title,
                    arrangement: selectedArrangement,
                    contentLayout: selectedContentLayout
                ) {
                    // ação de toque
                }
                .cardStyle(selectedStyle.style())
                .listRowSeparator(.hidden)

                Divider().padding(.top)

                configurationSection
            }
        }
    }

    var configurationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("Título", text: $title)
                .textFieldStyle(.roundedBorder)

            Text("Estilo")
            Picker("Estilo", selection: $selectedStyle) {
                ForEach(BasicCardStyleCase.allCases, id: \.self) { style in
                    Text(style.rawValue)
                }
            }.pickerStyle(.segmented)

            Text("Arranjo")
            Picker("Arranjo", selection: $selectedArrangement) {
                ForEach(StackArrangementCase.allCases, id: \.self) { arrangement in
                    Text(arrangement.rawValue)
                }
            }.pickerStyle(.segmented)

            Text("Layout de Conteúdo")
            Picker("Layout", selection: $selectedContentLayout) {
                ForEach(CardLayoutCase.allCases, id: \.self) { layout in
                    Text(layout.rawValue)
                }
            }.pickerStyle(.segmented)

            Text("Ícone (SFSymbol)")
            TextField("Buscar símbolo", text: $symbolSearch)
                .textFieldStyle(.roundedBorder)

            ScrollView {
                LazyVStack(alignment: .leading) {
                    ForEach(Array(filteredSymbols), id: \.self) { symbol in
                        HStack {
                            Image.init(systemSymbol: symbol)
                            Text(symbol.rawValue)
                            Spacer()
                            if symbol.rawValue == selectedSymbol {
                                Image(systemName: "checkmark")
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedSymbol = symbol.rawValue
                            symbolSearch = symbol.rawValue
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .frame(height: 200)
        }
        .padding(.top, 8)
    }
}
