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
                blur1Width: viewModel.blur1Width,
                blur1Height: viewModel.blur1Height,
                blur1Radius: viewModel.blur1Radius,
                blur1OffsetX: viewModel.blur1OffsetX,
                blur1OffsetY: viewModel.blur1OffsetY,
                blur1Opacity: viewModel.blur1Opacity,
                
                blur2Width: viewModel.blur2Width,
                blur2Height: viewModel.blur2Height,
                blur2Radius: viewModel.blur2Radius,
                blur2OffsetX: viewModel.blur2OffsetX,
                blur2OffsetY: viewModel.blur2OffsetY,
                blur2Opacity: viewModel.blur2Opacity,
                
                blur3Width: viewModel.blur3Width,
                blur3Height: viewModel.blur3Height,
                blur3Radius: viewModel.blur3Radius,
                blur3OffsetX: viewModel.blur3OffsetX,
                blur3OffsetY: viewModel.blur3OffsetY,
                blur3Opacity: viewModel.blur3Opacity
            ) {
                VStack(spacing: spacings.medium) {
                    Text("Estatísticas do Mês")
                        .textStyle(.mediumBold(.contentA))
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
            .blurStyle(.default(colorName: viewModel.selectedColor))
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
                .textStyle(.mediumBold(.contentA))
        }
        .frame(maxWidth: .infinity)
    }
}
