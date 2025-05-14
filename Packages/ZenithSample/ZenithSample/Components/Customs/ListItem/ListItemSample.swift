import SwiftUI
import Zenith
import ZenithCoreInterface

struct ListItemSample: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator
    @State private var showFixedHeader = false
    
    var body: some View {
        SampleWithFixedHeader(
            showFixedHeader: $showFixedHeader,
            content: {
                Card(action: {
                    showFixedHeader.toggle()
                }) {
                    VStack(spacing: 16) {
                        ForEach(ListItemStyleCase.allCases, id: \.self) { style in
                            ListItem("Sample ListItem")
                                .listitemStyle(style.style())
                        }
                    }
                    .padding()
                }
                .padding()
            },
            config: {
                VStack(spacing: 16) {
                    Text("Configurações do ListItem")
                        .font(fonts.mediumBold)
                        .foregroundColor(colors.contentA)
                    
                    // Área de configuração pode ser expandida conforme necessário
                    
                    CodePreviewSection(generateCode: generateCode)
                }
                .padding()
            }
        )
    }
    
    private func generateCode() -> String {
        """
        ListItem("Sample ListItem")
            .listitemStyle(.default())
        """
    }
}
