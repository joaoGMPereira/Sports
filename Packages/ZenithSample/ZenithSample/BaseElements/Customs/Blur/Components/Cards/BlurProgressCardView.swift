import SwiftUI
import Zenith
import ZenithCoreInterface
import SFSafeSymbols

struct BlurProgressCardView: View, @preconcurrency BaseThemeDependencies {
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
            .blurStyle(.default(colorName: viewModel.selectedColor))
        }
    }
}
