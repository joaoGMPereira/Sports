import SwiftUI
import Zenith
import ZenithCoreInterface

struct BlurBasicCardView: View, @preconcurrency BaseThemeDependencies {
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
                VStack(alignment: .leading, spacing: .zero) {
                    HStack(spacing: spacings.medium) {
                        Text("Card Básico")
                            .textStyle(.largeBold(.contentA))
                        Spacer()
                        Button {
                            
                        } label: {
                            Text("25%")
                                .textStyle(.small(.highlightA))
                                .padding(spacings.extraSmall)
                        }
                        .buttonStyle(.highlightA(shape: .circle))
                        .allowsHitTesting(false)
                    }
                    .padding(spacings.medium)
                    
                    VStack(alignment: .leading, spacing: spacings.small) {
                        Text("Dias")
                            .font(fonts.smallBold)
                            .foregroundStyle(colors.backgroundC)
                        Text("3x")
                            .textStyle(.small(.contentA))
                    }.padding(spacings.medium)
                }
            }
            .blurStyle(.default(colorName: viewModel.selectedColor))
        }
    }
}
