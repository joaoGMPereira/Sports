import SwiftUI
import Zenith
import ZenithCoreInterface
import SFSafeSymbols

struct BlurSample: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator
    
    @StateObject private var viewModel = BlurSampleViewModel()
    @State private var isExpanded = false
    
    private let viewOptions = ["Card Básico", "Progress Card", "Estatísticas"]
    
    var body: some View {
        SectionView(
            title: "Blur",
            isExpanded: $isExpanded,
            backgroundColor: .clear
        ) {
            VStack(spacing: 16) {
                // Seletor de cor para o blur
                ColorSelector(selectedColor: $viewModel.selectedColor)
                
                // Seletor de tipo de view
                BlurViewSelector(
                    options: viewOptions,
                    selectedIndex: $viewModel.selectedViewIndex
                )
                
                // Exemplos de Views com Blur
                selectedBlurView
                
                // Resumo e controles
                BlurValoresView(viewModel: viewModel)
                
                // Controles para ajustar os blurs
                BlurControlsView(viewModel: viewModel)
                
                // Botões para copiar configurações
                BlurCopyButtonsView(viewModel: viewModel)
            }
        }
    }
    
    // View selecionada com base no índice
    private var selectedBlurView: some View {
        Group {
            switch viewModel.selectedViewIndex {
            case 0:
                BlurBasicCardView(viewModel: viewModel)
            case 1:
                BlurProgressCardView(viewModel: viewModel)
            case 2:
                BlurStatsCardView(viewModel: viewModel)
            default:
                BlurBasicCardView(viewModel: viewModel)
            }
        }
    }
}

struct BlurSample_Previews: PreviewProvider {
    static var previews: some View {
        BlurSample()
    }
}
