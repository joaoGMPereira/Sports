import SwiftUI
import Zenith

struct ActionCardSample: View {
    @State var isExpanded = false
    
    var body: some View {
        SectionView(title: "ACTIONCARD", isExpanded: $isExpanded, backgroundColor: .clear) {
            ForEach(ActionCardStyleCase.allCases, id: \.self) { style in
                ActionCard(
                    title: "Treino de Adaptação",
                    description: "Frequência: 5 vezes na semana",
                    image: .play,
                    tags: ["Quadríceps", "Costas", "Peito", "Posterior", "Ombro", "Corrida"]
                ) {
                    print("caiu aqui")
                }
                .actionCardStyle(style.style())
            }
        }
    }
}
