import SwiftUI
import Zenith
import ZenithCoreInterface
import SFSafeSymbols

struct BlurProgressCardView: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator
    @ObservedObject var viewModel: BlurSampleViewModel
    
    let action: () -> Void
    
    var body: some View {
        Card(alignment: .leading, type: .fill, action: action) {
            Blur(
                blurConfig: viewModel.createBlurConfig()
            ) {
                VStack(alignment: .leading, spacing: spacings.medium) {
                    HStack {
                        Text("Progresso do Treino")
                            .textStyle(.largeBold(.contentA))
                        Spacer()
                        Image(systemSymbol: .chartBarXaxis)
                            .foregroundColor(colors.highlightA)
                    }
                    
                    ProgressView(value: 0.75)
                        .progressViewStyle(LinearProgressViewStyle(tint: colors.highlightA))
                        .scaleEffect(x: 1, y: 1.5, anchor: .center)
                    
                    HStack {
                        Text("75% Concluído")
                            .textStyle(.small(.contentA))
                        Spacer()
                        Text("7 dias restantes")
                            .textStyle(.small(.contentB))
                    }
                }
                .padding(spacings.medium)
            }
            .blurStyle(.default(viewModel.selectedColor))
        }
    }
}
