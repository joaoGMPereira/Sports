import SwiftUI
import Zenith
import ZenithCoreInterface

struct CardSample: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator
    @State var isExpanded = false
    
    var body: some View {
        SectionView(
            title: "CARD",
            isExpanded: $isExpanded,
            backgroundColor: .clear
        ) {
            Card.emptyState(
                image: .figureRun,
                title: "Sample Card"
            )
            .cardStyle(.bordered())
            ForEach(CardStyleCase.allCases, id: \.self) { style in
                ForEach(StackArrangementCase.allCases, id: \.self) { arrangementStyle in
                    Card(
                        image: .figureRun,
                        title: "Sample Card",
                        arrangement: arrangementStyle
                    )
                    .cardStyle(style.style())
                }
            }
        }
    }
}
