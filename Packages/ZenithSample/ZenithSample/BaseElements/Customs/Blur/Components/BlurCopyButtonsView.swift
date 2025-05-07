import SwiftUI
import Zenith
import ZenithCoreInterface

struct BlurCopyButtonsView: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator
    @ObservedObject var viewModel: BlurSampleViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            Button("Copiar Configurações") {
                UIPasteboard.general.string = viewModel.generateConfigText()
            }
            .buttonStyle(.highlightA())
            .padding(.vertical)
            
            Button("Copiar Código Swift") {
                UIPasteboard.general.string = viewModel.generateSwiftCode()
            }
            .buttonStyle(.contentA())
            .padding(.vertical, 8)
        }
    }
}
