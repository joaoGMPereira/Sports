import SwiftUI
import Zenith
import ZenithCoreInterface

struct CodeGenerationButtonView: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator
    
    let generateCode: () -> String
    @State private var copySuccess = false
    
    var body: some View {
        VStack(spacing: 12) {
            Button(copySuccess ? "Código Copiado!" : "Copiar Código") {
                UIPasteboard.general.string = generateCode()
                withAnimation {
                    copySuccess = true
                }
                
                // Reset após 2 segundos
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        copySuccess = false
                    }
                }
            }
            .buttonStyle(copySuccess ? ButtonStyleCase.highlightA.style() : ButtonStyleCase.contentA.style())
            .padding(.vertical, 4)
        }
    }
}

struct CodePreviewSection: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator
    
    let generateCode: () -> String
    var height: CGFloat = 200
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Código Swift:")
                .font(fonts.mediumBold)
                .foregroundColor(colors.contentA)
            
            ScrollView {
                Text(generateCode())
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(colors.contentA)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(height: height)
            .background(colors.backgroundA.opacity(0.5))
            .cornerRadius(8)
            
            CodeGenerationButtonView(generateCode: generateCode)
        }
        .transition(.opacity)
        .padding()
        .background(colors.backgroundC.opacity(0.5))
        .cornerRadius(10)
    }
}
