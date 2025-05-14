import SwiftUI
import Zenith
import ZenithCoreInterface

struct DividerSample: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator
    @State private var showFixedHeader = false
    
    var body: some View {
        SampleWithFixedHeader(
            showFixedHeader: $showFixedHeader,
            content: {
                Card(action: {
                    showFixedHeader.toggle()
                }) {
                    VStack(spacing: 20) {
                        ForEach(DividerStyleCase.allCases, id: \.self) { style in
                            VStack {
                                Text(String(describing: style))
                                    .font(fonts.small)
                                    .foregroundColor(colors.contentA)
                                
                                Divider()
                                    .dividerStyle(style.style())
                            }
                        }
                    }
                    .padding()
                }
                .padding()
            },
            config: {
                VStack(spacing: 16) {
                    Text("Exemplos de Divider")
                        .font(fonts.mediumBold)
                        .foregroundColor(colors.contentA)
                    
                    CodePreviewSection(generateCode: generateCode)
                }
                .padding()
            }
        )
    }
    
    private func generateCode() -> String {
        """
        Divider()
            .dividerStyle(.default())
        """
    }
}
