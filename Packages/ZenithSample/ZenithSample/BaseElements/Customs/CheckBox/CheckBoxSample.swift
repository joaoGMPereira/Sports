import SwiftUI
import Zenith
import ZenithCoreInterface

struct CheckBoxSample: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator
    
    @State private var isChecked = true
    @State private var showFixedHeader = false
    @State private var selectedItems: Set<Int> = []
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isDisabled = true
    @State private var isDisabledSelected = false
    @State private var isSelectedWithoutText = false
    
    var body: some View {
        SampleWithFixedHeader(
            showFixedHeader: $showFixedHeader,
            content: {
                Card(action: {
                    showFixedHeader.toggle()
                }) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Preview do CheckBox")
                            .font(fonts.mediumBold)
                            .foregroundColor(colors.contentA)
                        
                        CheckBox(
                            isSelected: $isChecked,
                            text: "CheckBox de Exemplo"
                        )
                    }
                    .padding()
                }
                .padding()
            },
            config: {
                VStack(spacing: 16) {
                    // Configurações
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Configurações")
                            .font(fonts.mediumBold)
                            .foregroundColor(colors.contentA)
                        
                        Toggle("Checked", isOn: $isChecked)
                            .toggleStyle(.default(.highlightA))
                    }
                    .padding()
                    .background(colors.backgroundB.opacity(0.3))
                    .cornerRadius(10)
                    
                    // Exemplos
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Exemplos")
                            .font(fonts.mediumBold)
                            .foregroundColor(colors.contentA)
                        
                        // Exemplo com lista de tarefas
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Lista de Tarefas")
                                .font(fonts.smallBold)
                                .foregroundColor(colors.contentA)
                            
                            ForEach(0..<4) { index in
                                CheckBox(
                                    isSelected: Binding(
                                        get: { selectedItems.contains(index) },
                                        set: { isSelected in
                                            if isSelected {
                                                selectedItems.insert(index)
                                            } else {
                                                selectedItems.remove(index)
                                            }
                                        }
                                    ),
                                    text: "Tarefa \(index + 1)"
                                )
                                .checkBoxStyle(.default())
                            }
                            
                            Button("Mostrar selecionados") {
                                showSelectedCount()
                            }
                            .buttonStyle(.highlightA())
                            .padding(.top, 8)
                        }
                        .padding()
                        .background(colors.backgroundB.opacity(0.3))
                        .cornerRadius(8)
                        
                        // Exemplo com diferentes estilos
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Diferentes Estilos")
                                .font(fonts.smallBold)
                                .foregroundColor(colors.contentA)
                            
                            ForEach(CheckBoxStyleCase.allCases, id: \.self) { style in
                                HStack {
                                    Text(String(describing: style))
                                        .font(fonts.small)
                                        .foregroundColor(colors.contentA)
                                        .frame(width: 120, alignment: .leading)
                                    
                                    CheckBox(
                                        isSelected: $isChecked
                                    )
                                    .checkBoxStyle(style.style())
                                }
                            }
                        }
                        .padding()
                        .background(colors.backgroundB.opacity(0.3))
                        .cornerRadius(8)
                        
                        // Exemplo com diferentes cores
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Diferentes Cores")
                                .font(fonts.smallBold)
                                .foregroundColor(colors.contentA)
                            
                            HStack(spacing: 16) {
                                VStack {
                                    CheckBox(
                                        isSelected: .constant(true),
                                        text: "HighlightA"
                                    )
                                    
                                    CheckBox(
                                        isSelected: .constant(true),
                                        text: "ContentA"
                                    )
                                }
                                
                                VStack {
                                    CheckBox(
                                        isSelected: .constant(true),
                                        text: "Attention"
                                        
                                    )
                                    
                                    CheckBox(
                                        isSelected: .constant(true),
                                        text: "Danger"
                                    )
                                }
                            }
                        }
                        .padding()
                        .background(colors.backgroundB.opacity(0.3))
                        .cornerRadius(8)
                        
                        // Exemplo com disable
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Desabilitado")
                                .font(fonts.smallBold)
                                .foregroundColor(colors.contentA)
                            
                            CheckBox(
                                isSelected: .constant(true),
                                text: "Opção desabilitada (checked)"
                            )
                            .checkBoxStyle(.default())
                            .disabled(true)
                            
                            CheckBox(
                                isSelected: .constant(false),
                                text: "Opção desabilitada (unchecked)"
                            )
                            .checkBoxStyle(.default())
                            .disabled(true)
                            
                            CheckBox(
                                isSelected: $isDisabledSelected,
                                text: "Opção com estado dinâmico de desabilitado"
                            )
                            .checkBoxStyle(.default())
                            .disabled(isDisabled)
                            
                            Button("Alternar estado de desabilitado") {
                                isDisabled.toggle()
                            }
                            .buttonStyle(.highlightA())
                            .padding(.top, 8)
                        }
                        .padding()
                        .background(colors.backgroundB.opacity(0.3))
                        .cornerRadius(8)
                    }
                    
                    // Código
                    CodePreviewSection(generateCode: generateCode)
                }
                .padding()
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Contagem de Seleções"),
                        message: Text(alertMessage),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
        )
        .onAppear {
            Task {
                // Delay para simular mudança de estado após um tempo
                try? await Task.sleep(for: .seconds(3))
                
                await MainActor.run {
                    isDisabled = false
                }
            }
        }
    }
    
    // Geração de código
    private func generateCode() -> String {
        """
        @State private var isChecked = \(isChecked ? "true" : "false")
        
        CheckBox(
            isSelected: $isChecked,
            text: "CheckBox de Exemplo"
        )
        
        // Para múltipla seleção com Set
        @State private var selectedItems: Set<Int> = []
        
        CheckBox(
            isSelected: Binding(
                get: { selectedItems.contains(id) },
                set: { isSelected in
                    if isSelected {
                        selectedItems.insert(id)
                    } else {
                        selectedItems.remove(id)
                    }
                }
            ),
            text: "Item selecionável"
        )
        .checkBoxStyle(.default())
        """
    }
    
    private func showSelectedCount() {
        alertMessage = "Itens selecionados: \(selectedItems.count)"
        showAlert = true
    }
}
