import SwiftUI
import Zenith
import ZenithCoreInterface
import SFSafeSymbols

struct BlurSample: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator
    
    @StateObject private var viewModel = BlurSampleViewModel()
    @State private var isExpanded = false
    @State private var showFixedHeader = false
    
    private let viewOptions = ["Card Básico", "Progress Card", "Estatísticas"]
    
    var body: some View {
        SampleWithFixedHeader(
            showFixedHeader: $showFixedHeader,
            content: {
                Card(action: {
                    showFixedHeader.toggle()
                }) {
                    selectedBlurView
                        .padding()
                }
                .padding()
            },
            config: {
                VStack(spacing: 16) {
                    // Substituindo ColorSelector pelo EnumSelector
                    EnumSelector<ColorName>(
                        title: "Cor do Blur",
                        selection: $viewModel.selectedColor,
                        columnsCount: 4,
                        height: 120
                    )
                    
                    // Seletor de tipo de view
                    BlurViewSelector(
                        options: viewOptions,
                        selectedIndex: $viewModel.selectedViewIndex
                    )
                    
                    // Editor de configuração de blur reutilizável
                    BlurConfigEditor(
                        blur1Width: $viewModel.blur1Width,
                        blur1Height: $viewModel.blur1Height,
                        blur1Radius: $viewModel.blur1Radius,
                        blur1OffsetX: $viewModel.blur1OffsetX,
                        blur1OffsetY: $viewModel.blur1OffsetY,
                        blur1Opacity: $viewModel.blur1Opacity,
                        
                        blur2Width: $viewModel.blur2Width,
                        blur2Height: $viewModel.blur2Height,
                        blur2Radius: $viewModel.blur2Radius,
                        blur2OffsetX: $viewModel.blur2OffsetX,
                        blur2OffsetY: $viewModel.blur2OffsetY,
                        blur2Opacity: $viewModel.blur2Opacity,
                        
                        blur3Width: $viewModel.blur3Width,
                        blur3Height: $viewModel.blur3Height,
                        blur3Radius: $viewModel.blur3Radius,
                        blur3OffsetX: $viewModel.blur3OffsetX,
                        blur3OffsetY: $viewModel.blur3OffsetY,
                        blur3Opacity: $viewModel.blur3Opacity
                    )
                    
                    // Usando o componente reutilizável para visualização e cópia de código
                    CodePreviewSection(generateCode: generateBlurCode, height: 240)
                }
                .padding()
            }
        )
    }
    
    // View selecionada com base no índice
    private var selectedBlurView: some View {
        Group {
            switch viewModel.selectedViewIndex {
            case 0:
                BlurBasicCardView(viewModel: viewModel) {
                    showFixedHeader.toggle()
                }
            case 1:
                BlurProgressCardView(viewModel: viewModel) {
                    showFixedHeader.toggle()
                }
            case 2:
                BlurStatsCardView(viewModel: viewModel) {
                    showFixedHeader.toggle()
                }
            default:
                BlurBasicCardView(viewModel: viewModel) {
                    showFixedHeader.toggle()
                }
            }
        }
    }
    
    // Função para gerar o código do Blur atual
    private func generateBlurCode() -> String {
        return viewModel.generateSwiftCode()
    }
}

struct BlurSample_Previews: PreviewProvider {
    static var previews: some View {
        BlurSample()
    }
}
