import SwiftUI
import Zenith
import ZenithCoreInterface

struct BlurBasicCardView: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator
    @ObservedObject var viewModel: BlurSampleViewModel
    
    let action: () -> Void
    
    var body: some View {
        Card(alignment: .leading, type: .fill, action: action) {
            Blur(
                blurConfig: viewModel.createBlurConfig()
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
            .blurStyle(.default(viewModel.selectedColor))
        }
    }
}
