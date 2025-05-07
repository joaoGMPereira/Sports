import SwiftUI
import Zenith
import ZenithCoreInterface
import SFSafeSymbols

struct BlurValoresView: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator
    @ObservedObject var viewModel: BlurSampleViewModel
    
    var body: some View {
        VStack {
            HStack {
                Text("Valores Atuais")
                    .textStyle(.mediumBold(.contentA))
                
                Spacer()
                
                Button(action: {
                    viewModel.isValoresExpandido.toggle()
                }) {
                    Image(systemSymbol: viewModel.isValoresExpandido ? .chevronUp : .chevronDown)
                        .foregroundColor(colors.contentA)
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
                .id("valores-button")
            }
            .padding(.horizontal)
            
            if viewModel.isValoresExpandido {
                VStack(spacing: 10) {
                    HStack(alignment: .top) {
                        blurValueColumn(
                            title: "Blur 3",
                            radius: viewModel.blur3Radius,
                            width: viewModel.blur3Width,
                            height: viewModel.blur3Height,
                            offsetX: viewModel.blur3OffsetX,
                            offsetY: viewModel.blur3OffsetY,
                            opacity: viewModel.blur3Opacity
                        )
                        
                        Spacer()
                        
                        blurValueColumn(
                            title: "Blur 2",
                            radius: viewModel.blur2Radius,
                            width: viewModel.blur2Width,
                            height: viewModel.blur2Height,
                            offsetX: viewModel.blur2OffsetX,
                            offsetY: viewModel.blur2OffsetY,
                            opacity: viewModel.blur2Opacity
                        )
                        
                        Spacer()
                        
                        blurValueColumn(
                            title: "Blur 1",
                            radius: viewModel.blur1Radius,
                            width: viewModel.blur1Width,
                            height: viewModel.blur1Height,
                            offsetX: viewModel.blur1OffsetX,
                            offsetY: viewModel.blur1OffsetY,
                            opacity: viewModel.blur1Opacity
                        )
                    }
                    .padding()
                }
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(UIColor.systemBackground).opacity(0.8))
                )
                .padding(.horizontal)
            }
        }
    }
    
    private func blurValueColumn(
        title: String,
        radius: Double,
        width: Double,
        height: Double,
        offsetX: Double,
        offsetY: Double,
        opacity: Double
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(fonts.smallBold)
                .foregroundColor(colors.contentA)
            Text("R: \(Int(radius)) W: \(Int(width)) H: \(Int(height))")
                .font(fonts.small)
                .foregroundColor(colors.contentA)
            Text("X: \(Int(offsetX)) Y: \(Int(offsetY)) O: \(String(format: "%.2f", opacity))")
                .font(fonts.small)
                .foregroundColor(colors.contentA)
        }
    }
}
