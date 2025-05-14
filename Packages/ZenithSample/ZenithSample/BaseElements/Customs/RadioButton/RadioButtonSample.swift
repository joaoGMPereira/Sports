import SwiftUI
import Zenith

enum Option: Sendable {
    case a, b, c
}

struct RadioButtonSample: View {
    @State var isSelected = false
    @State var isSelectedWithoutText = false
    @State var isDisabledSelected = false
    @State var selectedOption: Option? = nil
    @State var isDisabled = true
    @State var showFixedHeader = false
    
    var body: some View {
        SampleWithFixedHeader(
            showFixedHeader: $showFixedHeader,
            content: {
                Card(action: {
                    showFixedHeader.toggle()
                }) {
                    RadioButton(
                        isSelected: $isSelected,
                        text: "Radio Button com Text"
                    )
                    .radioButtonStyle(.default())
                    .padding()
                }
                .padding()
            },
            config: {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Exemplos de RadioButton")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.bottom, 8)
                        
                        ForEach(RadioButtonStyleCase.allCases, id: \.self) { style in
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Estilo: \(String(describing: style))")
                                    .font(.headline)
                                    .padding(.bottom, 4)
                                
                                RadioButton(
                                    isSelected: $isSelected,
                                    text: "Single Radio Button With Text"
                                )
                                .radioButtonStyle(
                                    style.style()
                                )
                                
                                Text("Com múltiplas opções:")
                                    .font(.subheadline)
                                    .padding(.top, 8)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    RadioButton(
                                        tag: .a,
                                        selection: $selectedOption,
                                        text: "Opção A"
                                    )
                                    .radioButtonStyle(
                                        style.style()
                                    )
                                    
                                    RadioButton(
                                        tag: .b,
                                        selection: $selectedOption,
                                        text: "Opção B"
                                    )
                                    .radioButtonStyle(
                                        style.style()
                                    )
                                    
                                    RadioButton(
                                        tag: .c,
                                        selection: $selectedOption,
                                        text: "Opção C"
                                    )
                                    .radioButtonStyle(
                                        style.style()
                                    )
                                }
                                
                                Text("Sem texto:")
                                    .font(.subheadline)
                                    .padding(.top, 8)
                                
                                RadioButton(
                                    isSelected: $isSelectedWithoutText
                                )
                                .radioButtonStyle(
                                    style.style()
                                )
                                
                                Text("Desabilitado:")
                                    .font(.subheadline)
                                    .padding(.top, 8)
                                
                                RadioButton(
                                    isSelected: .constant(false),
                                    text: "RadioButton desabilitado"
                                )
                                .radioButtonStyle(
                                    style.style()
                                )
                                .disabled(true)
                                
                                RadioButton(
                                    isSelected: $isDisabledSelected,
                                    text: "RadioButton com estado de desabilitado dinâmico"
                                )
                                .radioButtonStyle(
                                    style.style()
                                )
                                .disabled(isDisabled)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        }
                        
                        Button("Alternar estado de desabilitado") {
                            isDisabled.toggle()
                        }
                        .buttonStyle(.highlightA())
                        .padding(.vertical, 12)
                        
                        // Código para uso do componente
                        CodePreviewSection(generateCode: generateCode)
                    }
                    .padding()
                }
            }
        )
    }
    
    private func generateCode() -> String {
        """
        // RadioButton único com binding para isSelected
        @State var isSelected = false
        
        RadioButton(
            isSelected: $isSelected,
            text: "Radio Button com texto"
        )
        .radioButtonStyle(.contentA())
        
        // RadioButton em grupo com selection
        @State var selectedOption: Option? = nil
        
        RadioButton(
            tag: .a,
            selection: $selectedOption,
            text: "Opção A"
        )
        .radioButtonStyle(.contentA())
        
        RadioButton(
            tag: .b,
            selection: $selectedOption,
            text: "Opção B"
        )
        .radioButtonStyle(.contentA())
        
        RadioButton(
            tag: .c,
            selection: $selectedOption,
            text: "Opção C"
        )
        .radioButtonStyle(.contentA())
        """
    }
}
