import SwiftUI
import Zenith
import ZenithCoreInterface
import SFSafeSymbols

struct BlurControlsView: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator
    @ObservedObject var viewModel: BlurSampleViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            BlurControlSection(
                title: "Blur 3 (Grande)",
                isExpanded: $viewModel.isBlur3Expanded,
                radius: $viewModel.blur3Radius,
                width: $viewModel.blur3Width,
                height: $viewModel.blur3Height,
                offsetX: $viewModel.blur3OffsetX,
                offsetY: $viewModel.blur3OffsetY,
                opacity: $viewModel.blur3Opacity
            )
            
            BlurControlSection(
                title: "Blur 2 (Médio)",
                isExpanded: $viewModel.isBlur2Expanded,
                radius: $viewModel.blur2Radius,
                width: $viewModel.blur2Width,
                height: $viewModel.blur2Height,
                offsetX: $viewModel.blur2OffsetX,
                offsetY: $viewModel.blur2OffsetY,
                opacity: $viewModel.blur2Opacity
            )
            
            BlurControlSection(
                title: "Blur 1 (Pequeno)",
                isExpanded: $viewModel.isBlur1Expanded,
                radius: $viewModel.blur1Radius,
                width: $viewModel.blur1Width,
                height: $viewModel.blur1Height,
                offsetX: $viewModel.blur1OffsetX,
                offsetY: $viewModel.blur1OffsetY,
                opacity: $viewModel.blur1Opacity
            )
        }
    }
}
