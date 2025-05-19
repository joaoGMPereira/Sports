import SwiftUI
import Zenith
import ZenithCoreInterface

/// Um componente genérico para seleção de valores de enum em um grid
/// `T` deve ser um tipo que implementa Hashable
struct EnumSelector<T: Hashable>: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator
    
    @Binding var selectedItem: T
    let options: [T]
    let title: String
    let columnsCount: Int
    let height: CGFloat
    let itemLabel: ((T) -> String)
    
    /// Inicializador do EnumSelector
    /// - Parameters:
    ///   - title: Título do seletor
    ///   - options: Array de opções disponíveis para seleção
    ///   - selection: Binding para o item selecionado
    ///   - columnsCount: Número de colunas no grid (padrão: 2)
    ///   - height: Altura do componente (padrão: 120)
    ///   - itemLabel: Closure para obter o texto de exibição para cada item (padrão: String(describing:))
    init(
        title: String,
        options: [T],
        selection: Binding<T>,
        columnsCount: Int = 2,
        height: CGFloat = 120,
        itemLabel: @escaping ((T) -> String) = { String(describing: $0) }
    ) {
        self.title = title
        self.options = options
        self._selectedItem = selection
        self.columnsCount = columnsCount
        self.height = height
        self.itemLabel = itemLabel
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .textStyle(.largeBold(.contentA))
                .padding(.horizontal)
            
            ScrollView(.vertical, showsIndicators: false) {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: columnsCount), spacing: 8) {
                    ForEach(options, id: \.self) { item in
                        itemButton(for: item)
                    }
                }
                .padding(.horizontal, 4)
            }
            .frame(minHeight: 40, maxHeight: height)
        }
    }
    
    private func itemButton(for item: T) -> some View {
        let label = itemLabel(item)
        
        return Button(action: {
            selectedItem = item
        }) {
            Text(label)
                .font(fonts.small)
                .foregroundColor(selectedItem == item ? colors.highlightA : colors.contentA)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(selectedItem == item ? colors.highlightA.opacity(0.2) : colors.backgroundB)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(selectedItem == item ? colors.highlightA : colors.backgroundC, lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.vertical, 2)
    }
}

/// Extensão para simplificar o uso com enums que implementam CaseIterable
extension EnumSelector where T: CaseIterable {
    /// Inicializador simplificado para enums que implementam CaseIterable
    init(
        title: String,
        selection: Binding<T>,
        columnsCount: Int = 2,
        height: CGFloat = 120,
        itemLabel: @escaping ((T) -> String) = { String(describing: $0) }
    ) {
        self.init(
            title: title,
            options: Array(T.allCases),
            selection: selection,
            columnsCount: columnsCount,
            height: height,
            itemLabel: itemLabel
        )
    }
}
