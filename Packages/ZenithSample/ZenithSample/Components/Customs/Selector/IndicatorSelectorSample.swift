import SwiftUI
import Zenith
import ZenithCoreInterface

struct IndicatorSelectorSample: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator
    @State private var showFixedHeader = false
    @State private var selectorValue1: Float = 65
    @State private var selectorValue2: Float = 6
    
    var body: some View {
        SampleWithFixedHeader(
            showFixedHeader: $showFixedHeader,
            content: {
                Card(action: {
                    showFixedHeader.toggle()
                }) {
                    VStack(spacing: 8) {
                        ForEach(IndicatorSelectorStyleCase.allCases, id: \.rawValue) { style in
                            VStack(spacing: 12) {
                                Text(style.rawValue)
                                    .font(fonts.small)
                                    .foregroundColor(colors.contentA)
                                
                                IndicatorSelector(
                                    text: "%.1f kg",
                                    selectedValue: Double(selectorValue1),
                                    minValue: 10,
                                    maxValue: 300,
                                    step: 0.1
                                )
                                .indicatorSelectorStyle(style.style())
                                
                                IndicatorSelector(
                                    text: "%.f Meses",
                                    selectedValue: Double(selectorValue2),
                                    minValue: 1,
                                    maxValue: 12,
                                    step: 1
                                )
                                .indicatorSelectorStyle(style.style())
                            }
                        }
                    }
                    .padding()
                }
                .padding()
            },
            config: {
                VStack(spacing: 16) {
                    Text("Valores selecionados")
                        .font(fonts.mediumBold)
                        .foregroundColor(colors.contentA)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Peso: \(String(format: "%.1f", selectorValue1)) kg")
                            .font(fonts.medium)
                            .foregroundColor(colors.contentA)
                        
                        Text("Meses: \(Int(selectorValue2))")
                            .font(fonts.medium)
                            .foregroundColor(colors.contentA)
                    }
                    .padding()
                    .background(colors.backgroundB.opacity(0.3))
                    .cornerRadius(8)
                    
                    CodePreviewSection(generateCode: generateCode)
                }
                .padding()
            }
        )
    }
    
    private func generateCode() -> String {
        """
        IndicatorSelector(
            text: "%.1f kg", 
            selectedValue: \(String(format: "%.1f", selectorValue1)), 
            minValue: 10, 
            maxValue: 300, 
            step: 0.1,
            onChange: { newValue in
                // Atualiza o valor selecionado
            }
        )
        .indicatorSelectorStyle(.default())
        """
    }
}
