import SwiftUI
import Zenith
import ZenithCoreInterface

class BlurSampleViewModel: ObservableObject {
    // Estado para controlar o estilo selecionado
    @Published var selectedColor: ColorName = .highlightA
    
    // Estado para controlar a view selecionada
    @Published var selectedViewIndex = 0
    
    // Controles para o terceiro blur (maior e mais suave)
    @Published var blur3Radius: Double = 50
    @Published var blur3Width: Double = 100
    @Published var blur3Height: Double = 50
    @Published var blur3OffsetX: Double = -20
    @Published var blur3OffsetY: Double = 20
    @Published var blur3Opacity: Double = 1.0
    
    // Controles para o segundo blur (médio)
    @Published var blur2Radius: Double = 40
    @Published var blur2Width: Double = 80
    @Published var blur2Height: Double = 40
    @Published var blur2OffsetX: Double = -20
    @Published var blur2OffsetY: Double = 20
    @Published var blur2Opacity: Double = 1.0
    
    // Controles para o primeiro blur (menor e mais próximo)
    @Published var blur1Radius: Double = 20
    @Published var blur1Width: Double = 42
    @Published var blur1Height: Double = 24
    @Published var blur1OffsetX: Double = -25
    @Published var blur1OffsetY: Double = 25
    @Published var blur1Opacity: Double = 0.9
    
    // Cria um BlurConfig com os valores atuais
    func createBlurConfig() -> BlurConfig {
        return BlurConfig(
            blur1Width: blur1Width,
            blur1Height: blur1Height,
            blur1Radius: blur1Radius,
            blur1OffsetX: blur1OffsetX,
            blur1OffsetY: blur1OffsetY,
            blur1Opacity: blur1Opacity,
            
            blur2Width: blur2Width,
            blur2Height: blur2Height,
            blur2Radius: blur2Radius,
            blur2OffsetX: blur2OffsetX,
            blur2OffsetY: blur2OffsetY,
            blur2Opacity: blur2Opacity,
            
            blur3Width: blur3Width,
            blur3Height: blur3Height,
            blur3Radius: blur3Radius,
            blur3OffsetX: blur3OffsetX,
            blur3OffsetY: blur3OffsetY,
            blur3Opacity: blur3Opacity
        )
    }
    
    // Gera configuração em texto para copiar
    func generateConfigText() -> String {
        return """
        Blur 3:
        - Radius: \(Int(blur3Radius))
        - Width: \(Int(blur3Width)), Height: \(Int(blur3Height))
        - Offset X: \(Int(blur3OffsetX)), Y: \(Int(blur3OffsetY))
        - Opacity: \(String(format: "%.2f", blur3Opacity))
        
        Blur 2:
        - Radius: \(Int(blur2Radius))
        - Width: \(Int(blur2Width)), Height: \(Int(blur2Height))
        - Offset X: \(Int(blur2OffsetX)), Y: \(Int(blur2OffsetY))
        - Opacity: \(String(format: "%.2f", blur2Opacity))
        
        Blur 1:
        - Radius: \(Int(blur1Radius))
        - Width: \(Int(blur1Width)), Height: \(Int(blur1Height))
        - Offset X: \(Int(blur1OffsetX)), Y: \(Int(blur1OffsetY))
        - Opacity: \(String(format: "%.2f", blur1Opacity))
        
        Cor: \(selectedColor.rawValue)
        """
    }
    
    // Gera código Swift para copiar
    func generateSwiftCode() -> String {
        return """
        Blur(
            blur1Width: \(Int(blur1Width)),
            blur1Height: \(Int(blur1Height)),
            blur1Radius: \(Int(blur1Radius)),
            blur1OffsetX: \(Int(blur1OffsetX)),
            blur1OffsetY: \(Int(blur1OffsetY)),
            blur1Opacity: \(String(format: "%.2f", blur1Opacity)),
            
            blur2Width: \(Int(blur2Width)),
            blur2Height: \(Int(blur2Height)),
            blur2Radius: \(Int(blur2Radius)),
            blur2OffsetX: \(Int(blur2OffsetX)),
            blur2OffsetY: \(Int(blur2OffsetY)),
            blur2Opacity: \(String(format: "%.2f", blur2Opacity)),
            
            blur3Width: \(Int(blur3Width)),
            blur3Height: \(Int(blur3Height)),
            blur3Radius: \(Int(blur3Radius)),
            blur3OffsetX: \(Int(blur3OffsetX)),
            blur3OffsetY: \(Int(blur3OffsetY)),
            blur3Opacity: \(String(format: "%.2f", blur3Opacity))
        ) {
            // Seu conteúdo aqui
        }
        .blurStyle(.default(colorName: .\(selectedColor.rawValue)))
        """
    }
}
