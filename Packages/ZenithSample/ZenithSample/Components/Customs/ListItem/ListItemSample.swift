import SwiftUI
import Zenith
import ZenithCoreInterface

struct ListItemSample: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator
    @State var isExpanded = false
    
    var body: some View {
        SectionView(title: "ListItem", isExpanded: $isExpanded, backgroundColor: .clear) {
            ForEach(ListItemStyleCase.allCases, id: \.self) { style in
                ListItem(
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
                    }
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
                .actionCardStyle(style.style())
            }
        }
    }
}
