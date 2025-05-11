import SwiftUI
import Zenith
import ZenithCoreInterface

struct BlurConfigEditor: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator
    
    // Bind para o BlurConfig que será modificado
    @Binding var blur1Width: Double
    @Binding var blur1Height: Double
    @Binding var blur1Radius: Double
    @Binding var blur1OffsetX: Double
    @Binding var blur1OffsetY: Double
    @Binding var blur1Opacity: Double
    
    @Binding var blur2Width: Double
    @Binding var blur2Height: Double
    @Binding var blur2Radius: Double
    @Binding var blur2OffsetX: Double
    @Binding var blur2OffsetY: Double
    @Binding var blur2Opacity: Double
    
    @Binding var blur3Width: Double
    @Binding var blur3Height: Double
    @Binding var blur3Radius: Double
    @Binding var blur3OffsetX: Double
    @Binding var blur3OffsetY: Double
    @Binding var blur3Opacity: Double
    
    // Estados para controlar a expansão de cada seção
    @State private var isBlur1Expanded = false
    @State private var isBlur2Expanded = false
    @State private var isBlur3Expanded = false
    @State private var showSummary = true
    
    var body: some View {
        VStack(spacing: spacings.medium) {
            // Resumo dos valores atuais
            if showSummary {
                summaryView
                    .padding(.bottom, spacings.small)
            }
            
            // Controles para cada camada de blur
            blurControlSection(
                title: "Blur 3 (Grande)",
                isExpanded: $isBlur3Expanded,
                radius: $blur3Radius,
                width: $blur3Width, 
                height: $blur3Height,
                offsetX: $blur3OffsetX,
                offsetY: $blur3OffsetY,
                opacity: $blur3Opacity
            )
            
            blurControlSection(
                title: "Blur 2 (Médio)",
                isExpanded: $isBlur2Expanded,
                radius: $blur2Radius,
                width: $blur2Width,
                height: $blur2Height,
                offsetX: $blur2OffsetX,
                offsetY: $blur2OffsetY,
                opacity: $blur2Opacity
            )
            
            blurControlSection(
                title: "Blur 1 (Pequeno)",
                isExpanded: $isBlur1Expanded,
                radius: $blur1Radius,
                width: $blur1Width,
                height: $blur1Height,
                offsetX: $blur1OffsetX,
                offsetY: $blur1OffsetY,
                opacity: $blur1Opacity
            )
        }
    }
    
    // Resumo visual dos valores atuais
    private var summaryView: some View {
        VStack {
            HStack {
                Text("Resumo dos Valores")
                    .textStyle(.mediumBold(.contentA))
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        showSummary.toggle()
                    }
                }) {
                    Image(systemSymbol: showSummary ? .chevronUp : .chevronDown)
                        .foregroundColor(colors.contentA)
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
            }
            .padding(.horizontal)
            
            if showSummary {
                HStack(alignment: .top) {
                    blurValueColumn(
                        title: "Blur 3",
                        radius: blur3Radius,
                        width: blur3Width,
                        height: blur3Height,
                        offsetX: blur3OffsetX,
                        offsetY: blur3OffsetY,
                        opacity: blur3Opacity
                    )
                    
                    Spacer()
                    
                    blurValueColumn(
                        title: "Blur 2",
                        radius: blur2Radius,
                        width: blur2Width,
                        height: blur2Height,
                        offsetX: blur2OffsetX,
                        offsetY: blur2OffsetY,
                        opacity: blur2Opacity
                    )
                    
                    Spacer()
                    
                    blurValueColumn(
                        title: "Blur 1",
                        radius: blur1Radius,
                        width: blur1Width,
                        height: blur1Height,
                        offsetX: blur1OffsetX,
                        offsetY: blur1OffsetY,
                        opacity: blur1Opacity
                    )
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(UIColor.systemBackground).opacity(0.8))
                )
                .padding(.horizontal)
            }
        }
    }
    
    // Seção de controle para cada camada de blur
    private func blurControlSection(
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
                .buttonStyle(.plain)
                .contentShape(Rectangle())
            }
            .padding([.horizontal, .top])
            
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
                .padding(.horizontal)
            }
        }
    }
    
    // Linha de slider para ajuste de valores
    private func sliderRow(
        title: String,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        step: Double
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(fonts.small)
                    .foregroundColor(colors.contentA)
                
                Spacer()
                
                if title == "Opacity" {
                    Text(String(format: "%.2f", value.wrappedValue))
                        .font(fonts.small)
                        .foregroundColor(colors.contentC)
                } else {
                    Text("\(Int(value.wrappedValue))")
                        .font(fonts.small)
                        .foregroundColor(colors.contentC)
                }
            }
            
            Slider(value: value, in: range, step: step)
                .accentColor(colors.highlightA)
        }
    }
    
    // Coluna com resumo dos valores
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
}