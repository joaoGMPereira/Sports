import SwiftUI
import Zenith
import ZenithCoreInterface
import SFSafeSymbols

struct BlurStatsCardView: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator
    @ObservedObject var viewModel: BlurSampleViewModel
    
    var body: some View {
        Card(alignment: .leading, type: .fill, action: {}) {
            Blur(
                blurConfig: viewModel.createBlurConfig()
            ) {
                VStack(spacing: spacings.medium) {
                    Text("Estatísticas do Mês")
                        .textStyle(.largeBold(.contentA))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: spacings.large) {
                        statItem(title: "Treinos", value: "18", icon: .figure)
                        Divider().background(colors.contentB)
                        statItem(title: "Calorias", value: "8.6k", icon: .flame)
                        Divider().background(colors.contentB)
                        statItem(title: "Tempo", value: "24h", icon: .clock)
                    }
                    
                    HStack {
                        Image(systemSymbol: .trophyFill)
                            .foregroundColor(colors.highlightA)
                        Text("3 recordes pessoais batidos")
                            .textStyle(.small(.contentA))
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding(spacings.medium)
            }
            .blurStyle(.default(viewModel.selectedColor))
        }
    }
    
    // Helper para itens de estatística
    private func statItem(title: String, value: String, icon: SFSymbol) -> some View {
        VStack(spacing: spacings.extraSmall) {
            HStack(spacing: spacings.extraSmall) {
                Image(systemSymbol: icon)
                    .foregroundColor(colors.contentB)
                Text(title)
                    .textStyle(.small(.contentB))
            }
            Text(value)
                .textStyle(.largeBold(.contentA))
        }
        .frame(maxWidth: .infinity)
    }
}
