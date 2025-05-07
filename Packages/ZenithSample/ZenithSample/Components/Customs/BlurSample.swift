import SwiftUI
import Zenith
import ZenithCoreInterface
import SFSafeSymbols

struct BlurSample: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator
    
    @State private var isExpanded = false
    
    // Estados para controlar o colapso das seções
    @State private var isBlur3Expanded = false
    @State private var isBlur2Expanded = false
    @State private var isBlur1Expanded = false
    @State private var isValoresExpandido = true
    
    // Controles para o terceiro blur (maior e mais suave)
    @State private var blur3Radius: Double = 50
    @State private var blur3Width: Double = 100
    @State private var blur3Height: Double = 50
    @State private var blur3OffsetX: Double = -20
    @State private var blur3OffsetY: Double = 20
    @State private var blur3Opacity: Double = 1.0
    
    // Controles para o segundo blur (médio)
    @State private var blur2Radius: Double = 40
    @State private var blur2Width: Double = 80
    @State private var blur2Height: Double = 40
    @State private var blur2OffsetX: Double = -20
    @State private var blur2OffsetY: Double = 20
    @State private var blur2Opacity: Double = 1.0
    
    // Controles para o primeiro blur (menor e mais próximo)
    @State private var blur1Radius: Double = 20
    @State private var blur1Width: Double = 42
    @State private var blur1Height: Double = 24
    @State private var blur1OffsetX: Double = -25
    @State private var blur1OffsetY: Double = 25
    @State private var blur1Opacity: Double = 0.9
    
    var body: some View {
        SectionView(
            title: "Blur",
            isExpanded: $isExpanded,
            backgroundColor: .clear
        ) {
            VStack(spacing: 16) {
                
                Card(alignment: .leading, type: .fill, action: {
                    
                }) {
                    ZStack(alignment: .topTrailing) {
                        // Terceira camada de blur (maior e mais suave)
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(hex: "#80B6FB2D"))
                            .frame(width: blur3Width, height: blur3Height)
                            .blur(radius: blur3Radius)
                            .offset(x: blur3OffsetX, y: blur3OffsetY)
                            .opacity(blur3Opacity)
                        
                        // Segunda camada de blur (média)
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(hex: "#80B6FB2D"))
                            .frame(width: blur2Width, height: blur2Height)
                            .blur(radius: blur2Radius)
                            .offset(x: blur2OffsetX, y: blur2OffsetY)
                            .opacity(blur2Opacity)
                        
                        // Primeira camada de blur (menor e mais próxima)
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(hex: "#A6ADFF09").opacity(blur1Opacity))
                            .frame(width: blur1Width, height: blur1Height)
                            .blur(radius: blur1Radius)
                            .offset(x: blur1OffsetX, y: blur1OffsetY)
                        
                        // Conteúdo original
                        VStack(alignment: .leading, spacing: .zero) {
                            
                            HStack(spacing: spacings.medium) {
                                Text("Teste")
                                    .textStyle(.mediumBold(.contentA))
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
                    .mask(
                        // Esta máscara garante que o blur respeite as bordas arredondadas
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                    )
                }
                
                // Resumo dos valores atuais
                resumoValoresView
                
                // Controles para ajustar os blurs
                VStack(spacing: 16) {
                    colapsableBlurControlSection(
                        title: "Blur 3 (Grande)",
                        isExpanded: $isBlur3Expanded,
                        radius: $blur3Radius,
                        width: $blur3Width,
                        height: $blur3Height,
                        offsetX: $blur3OffsetX,
                        offsetY: $blur3OffsetY,
                        opacity: $blur3Opacity
                    )
                    
                    colapsableBlurControlSection(
                        title: "Blur 2 (Médio)",
                        isExpanded: $isBlur2Expanded,
                        radius: $blur2Radius,
                        width: $blur2Width,
                        height: $blur2Height,
                        offsetX: $blur2OffsetX,
                        offsetY: $blur2OffsetY,
                        opacity: $blur2Opacity
                    )
                    
                    colapsableBlurControlSection(
                        title: "Blur 1 (Pequeno)",
                        isExpanded: $isBlur1Expanded,
                        radius: $blur1Radius,
                        width: $blur1Width,
                        height: $blur1Height,
                        offsetX: $blur1OffsetX,
                        offsetY: $blur1OffsetY,
                        opacity: $blur1Opacity
                    )
                    
                    // Botão para copiar os valores atuais para a área de transferência
                    Button("Copiar Configurações") {
                        let config = """
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
                        """
                        
                        UIPasteboard.general.string = config
                    }
                    .buttonStyle(.highlightA())
                    .padding(.vertical)
                }
            }
        }
    }
    
    // View de resumo dos valores atuais
    private var resumoValoresView: some View {
        VStack {
            HStack {
                Text("Valores Atuais")
                    .textStyle(.mediumBold(.contentA))
                
                Spacer()
                
                Button(action: {
                    isValoresExpandido.toggle()
                }) {
                    Image(systemSymbol: isValoresExpandido ? .chevronUp : .chevronDown)
                        .foregroundColor(colors.contentA)
                }
                .buttonStyle(.plain) // Garantindo que o estilo do botão não se propague
                .contentShape(Rectangle()) // Definindo a área de toque
                .id("valores-button") // Identificador único
            }
            .padding(.horizontal)
            
            if isValoresExpandido {
                VStack(spacing: 10) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Blur 3")
                                .font(fonts.smallBold)
                                .foregroundColor(colors.contentA)
                            Text("R: \(Int(blur3Radius)) W: \(Int(blur3Width)) H: \(Int(blur3Height))")
                                .font(fonts.small)
                                .foregroundColor(colors.contentA)
                            Text("X: \(Int(blur3OffsetX)) Y: \(Int(blur3OffsetY)) O: \(String(format: "%.2f", blur3Opacity))")
                                .font(fonts.small)
                                .foregroundColor(colors.contentA)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Blur 2")
                                .font(fonts.smallBold)
                                .foregroundColor(colors.contentA)
                            Text("R: \(Int(blur2Radius)) W: \(Int(blur2Width)) H: \(Int(blur2Height))")
                                .font(fonts.small)
                                .foregroundColor(colors.contentA)
                            Text("X: \(Int(blur2OffsetX)) Y: \(Int(blur2OffsetY)) O: \(String(format: "%.2f", blur2Opacity))")
                                .font(fonts.small)
                                .foregroundColor(colors.contentA)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Blur 1")
                                .font(fonts.smallBold)
                                .foregroundColor(colors.contentA)
                            Text("R: \(Int(blur1Radius)) W: \(Int(blur1Width)) H: \(Int(blur1Height))")
                                .font(fonts.small)
                                .foregroundColor(colors.contentA)
                            Text("X: \(Int(blur1OffsetX)) Y: \(Int(blur1OffsetY)) O: \(String(format: "%.2f", blur1Opacity))")
                                .font(fonts.small)
                                .foregroundColor(colors.contentA)
                        }
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
    
    // Componente colapsável para controles de blur
    private func colapsableBlurControlSection(
        title: String,
        isExpanded: Binding<Bool>,
        radius: Binding<Double>,
        width: Binding<Double>,
        height: Binding<Double>,
        offsetX: Binding<Double>,
        offsetY: Binding<Double>,
        opacity: Binding<Double>
    ) -> some View {
        VStack {
            HStack {
                Text(title)
                    .textStyle(.mediumBold(.contentA))
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        isExpanded.wrappedValue.toggle()
                    }
                }) {
                    Image(systemSymbol: isExpanded.wrappedValue ? .chevronUp : .chevronDown)
                        .foregroundColor(colors.contentA)
                }
                .buttonStyle(.plain) // Usar estilo plano para evitar interferência
                .contentShape(Rectangle()) // Definir área de toque explícita
                .id("\(title)-toggle-button") // Identificador único baseado no título
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.systemBackground).opacity(0.8))
            )
            
            if isExpanded.wrappedValue {
                VStack(alignment: .leading, spacing: 10) {
                    sliderRow(title: "Radius", value: radius, range: 0...100, step: 1)
                    sliderRow(title: "Width", value: width, range: 10...200, step: 1)
                    sliderRow(title: "Height", value: height, range: 10...200, step: 1)
                    sliderRow(title: "Offset X", value: offsetX, range: -100...100, step: 1)
                    sliderRow(title: "Offset Y", value: offsetY, range: -100...100, step: 1)
                    sliderRow(title: "Opacity", value: opacity, range: 0...1, step: 0.05)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(UIColor.systemBackground).opacity(0.8))
                )
            }
        }
        .padding(.horizontal, 1) // Pequeno ajuste para garantir que os componentes não se sobreponham
    }
    
    // Componente para linha de slider
    private func sliderRow(title: String, value: Binding<Double>, range: ClosedRange<Double>, step: Double) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(fonts.small)
                    .foregroundColor(colors.contentA)
                
                Spacer()
                
                Text("\(value.wrappedValue, specifier: "%.2f")")
                    .font(fonts.small)
                    .foregroundColor(colors.contentC)
            }
            
            Slider(value: value, in: range, step: step)
                .accentColor(colors.highlightA)
        }
    }
}
