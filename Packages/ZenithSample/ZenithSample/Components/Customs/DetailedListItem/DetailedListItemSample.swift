import SwiftUI
import Zenith
import ZenithCoreInterface

struct DetailedListItemSample: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator
    @State var isExpanded = false
    @State private var selectedColor: ColorName = .highlightA
    
    var body: some View {
        SectionView(title: "DetailedListItem", isExpanded: $isExpanded, backgroundColor: .clear) {
            // Seletor de cor para o blur
            ColorSelector(selectedColor: $selectedColor)
            
            // Lista de cards
            ForEach(DetailedListItemStyleCase.allCases, id: \.self) { style in
                DetailedListItem(
                    title: "Treino de Adaptação",
                    description: "Frequência: 5 vezes na semana",
                    leftInfo: .init(
                        title: "Dias",
                        description: "3x"
                    ),
                    rightInfo: .init(
                        title: "Exercícios",
                        description: "5x"
                    ),
                    action: {
                        print("caiu aqui")
                    },
                    blurStyle: .default(selectedColor)
                ) {
                    Button {
                        
                    } label: {
                        Text("25%")
                            .textStyle(.small(.highlightA))
                            .padding(spacings.extraSmall)
                    }
                    .buttonStyle(.highlightA(shape: .circle))
                    .allowsHitTesting(false)
                }
                .detailedListItemStyle(style.style())
            }
        }
    }
}
