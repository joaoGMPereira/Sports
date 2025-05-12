import SwiftUI
import Zenith
import ZenithCoreInterface
import SFSafeSymbols

struct HeaderTitleSample: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator
    @State var isExpanded = false
    
    // Estados para interatividade
    @State private var headerText = "Sample HeaderTitle"
    @State private var selectedSymbol = SFSymbol.sliderHorizontal3.rawValue
    @State private var backgroundColor: Color?
    @State private var symbolSearch = ""
    @State private var selectedStyle = HeaderTitleStyleCase.allCases.first!
    
    var filteredSymbols: [String] {
        if symbolSearch.isEmpty {
            return SFSymbol.allSymbols.map{ $0.rawValue }.sorted()
        }
        return SFSymbol.allSymbols
            .filter { $0.rawValue.lowercased().contains(symbolSearch.lowercased()) }
            .map { $0.rawValue }
            .prefix(100)
            .sorted()
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Preview do HeaderTitle com os valores selecionados
            HeaderTitle(headerText, image: SFSymbol(rawValue: selectedSymbol))
                .headerTitleStyle(selectedStyle.style())
                .listRowSeparator(.hidden)
            
            Divider().padding(.top)
            
            configurationSection
        }
    }
    
    var configurationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Campo para editar o texto
            TextField("Texto do cabeçalho", text: $headerText)
                .textFieldStyle(.roundedBorder)
            
            // Seletor de estilo
            Text("Estilo")
                .font(fonts.smallBold)
                .foregroundColor(colors.contentA)
            
            Picker("Estilo", selection: $selectedStyle) {
                ForEach(HeaderTitleStyleCase.allCases, id: \.self) { style in
                    Text(style.rawValue).tag(style)
                }
            }
            .pickerStyle(.segmented)
            
            // Seletor de ícone
            Text("Ícone (SFSymbol)")
                .font(fonts.smallBold)
                .foregroundColor(colors.contentA)
            
            TextField("Buscar símbolo", text: $symbolSearch)
                .textFieldStyle(.roundedBorder)
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 8) {
                    ForEach(filteredSymbols, id: \.self) { symbol in
                        VStack {
                            Image(systemName: symbol)
                                .font(.system(size: 22))
                                .frame(width: 44, height: 44)
                                .background(
                                    Circle()
                                        .fill(symbol == selectedSymbol ?
                                              colors.highlightA : colors.backgroundB)
                                )
                                .foregroundColor(symbol == selectedSymbol ?
                                                 colors.contentC : colors.contentA)
                            
                            Text(symbol)
                                .font(fonts.small)
                                .foregroundColor(colors.contentA)
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                        .frame(width: 80, height: 80)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedSymbol = symbol
                        }
                    }
                }
            }
            .frame(height: 200)
            .background(colors.backgroundB.opacity(0.5))
            .cornerRadius(8)
            .onChange(of: selectedStyle) {
                switch selectedStyle {
                case .contentA:
                    backgroundColor = colors.backgroundB
                case .contentC:
                    backgroundColor = colors.backgroundC
                }
            }
        }
        .padding(.top, 8)
    }
}

// Extensão para obter o valor bruto para o Picker
extension HeaderTitleStyleCase {
    var rawValue: String {
        switch self {
        case .contentA:
            return "Content A"
        case .contentC:
            return "Content B"
        }
    }
}
