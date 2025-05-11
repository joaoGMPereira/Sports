import SwiftUI
import Zenith
import ZenithCoreInterface

struct CircularProgressSample: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator
    @State var isExpanded = false
    @State private var progress: Double = 0.25
    @State private var size: Double = 54
    @State private var showText: Bool = true
    @State private var animated: Bool = true
    
    // Estados para exemplos de transição
    @State private var progress1: Double = 0.0
    @State private var progress2: Double = 0.75
    @State private var progress3: Double = 0.20
    
    var body: some View {
        SectionView(title: "CIRCULAR PROGRESS", isExpanded: $isExpanded) {
            VStack(spacing: 20) {
                // Configurações interativas
                VStack(alignment: .leading, spacing: 8) {
                    Text("Configurações")
                        .font(fonts.mediumBold)
                        .foregroundColor(colors.contentA)
                    
                    HStack {
                        Text("Progresso: \(Int(progress * 100))%")
                            .font(fonts.small)
                            .foregroundColor(colors.contentA)
                        Spacer()
                    }
                    
                    Slider(value: $progress, in: 0...1, step: 0.01)
                        .accentColor(colors.highlightA)
                    
                    HStack {
                        Text("Tamanho: \(Int(size))px")
                            .font(fonts.small)
                            .foregroundColor(colors.contentA)
                        Spacer()
                    }
                    
                    Slider(value: $size, in: 30...150, step: 1)
                        .accentColor(colors.highlightA)
                    
                    Toggle("Mostrar texto", isOn: $showText)
                        .toggleStyle(.default(.highlightA))
                        .foregroundColor(colors.contentA)
                    
                    Toggle("Animado", isOn: $animated)
                        .toggleStyle(.default(.highlightA))
                        .foregroundColor(colors.contentA)
                }
                .padding()
                .background(colors.backgroundB.opacity(0.5))
                .cornerRadius(10)
                
                // Demonstração dos estilos
                Text("Exemplos")
                    .font(fonts.mediumBold)
                    .foregroundColor(colors.contentA)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 20) {
                    ForEach(CircularProgressStyleCase.allCases, id: \.self) { style in
                        VStack(spacing: 10) {
                            CircularProgress(
                                progress: progress,
                                size: size,
                                showText: showText,
                                animated: animated
                            )
                            .circularProgressStyle(style.style())
                            
                            Text(String(describing: style))
                                .font(fonts.small)
                                .foregroundColor(colors.contentA)
                        }
                        .padding()
                        .background(colors.backgroundB.opacity(0.3))
                        .cornerRadius(10)
                    }
                }
                
                // Exemplos de uso prático
                VStack(alignment: .leading, spacing: 12) {
                    Text("Exemplos de Uso")
                        .font(fonts.mediumBold)
                        .foregroundColor(colors.contentA)
                    
                    HStack(spacing: 20) {
                        // Progresso de treino
                        exampleCard(
                            title: "Treino",
                            value: "75%",
                            style: .highlightA,
                            progress: 0.75
                        )
                        
                        // Progresso de dieta
                        exampleCard(
                            title: "Dieta",
                            value: "52%",
                            style: .contentA,
                            progress: 0.52
                        )
                        
                        // Progresso de água
                        exampleCard(
                            title: "Água",
                            value: "30%",
                            style: .contentB,
                            progress: 0.3
                        )
                    }
                }
                .padding()
                .background(colors.backgroundB.opacity(0.5))
                .cornerRadius(10)
                
                // Exemplos de transição animada
                VStack(alignment: .leading, spacing: 12) {
                    Text("Transições Animadas")
                        .font(fonts.mediumBold)
                        .foregroundColor(colors.contentA)
                    
                    VStack(spacing: spacings.medium) {
                        // 0% para 50%
                        animatedTransitionCard(
                            title: "0% → 50%",
                            progress: $progress1,
                            initialValue: 0.0,
                            targetValue: 0.5,
                            style: .highlightA
                        )
                        
                        // 75% para 100%
                        animatedTransitionCard(
                            title: "75% → 100%",
                            progress: $progress2,
                            initialValue: 0.75,
                            targetValue: 1.0,
                            style: .contentA
                        )
                        
                        // 20% para 40%
                        animatedTransitionCard(
                            title: "20% → 40%",
                            progress: $progress3,
                            initialValue: 0.2,
                            targetValue: 0.4,
                            style: .contentB
                        )
                    }
                }
                .padding()
                .background(colors.backgroundB.opacity(0.5))
                .cornerRadius(10)
                
                // Usando o componente reutilizável para visualização e cópia de código
                CodePreviewSection(generateCode: generateCode)
            }
            .padding(.horizontal)
            .onAppear {
                // Reset para valores iniciais, caso tenha sido alterado
                progress1 = 0.0
                progress2 = 0.75
                progress3 = 0.20
            }
        }
    }
    
    private func generateCode() -> String {
        let styleCase = CircularProgressStyleCase.allCases.first!
        let styleName = String(describing: styleCase)
        let showTextString = showText ? "true" : "false"
        let animatedString = animated ? "true" : "false"
        
        return """
        CircularProgress(
            progress: \(String(format: "%.2f", progress)),
            size: \(Int(size)),
            showText: \(showTextString),
            animated: \(animatedString)
        )
        .circularProgressStyle(.\(styleName)())
        """
    }
    
    private func exampleCard(title: String, value: String, style: CircularProgressStyleCase, progress: Double) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .font(fonts.smallBold)
                .foregroundColor(colors.contentA)
            
            CircularProgress(
                progress: progress,
                size: 50,
                showText: false
            )
            .circularProgressStyle(style.style())
            
            Text(value)
                .font(fonts.small)
                .foregroundColor(colors.contentA)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(colors.backgroundC.opacity(0.5))
        .cornerRadius(8)
    }
    
    private func animatedTransitionCard(
        title: String,
        progress: Binding<Double>,
        initialValue: Double,
        targetValue: Double,
        style: CircularProgressStyleCase
    ) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .font(fonts.smallBold)
                .foregroundColor(colors.contentA)
            
            CircularProgress(
                progress: progress.wrappedValue,
                size: size,
                showText: showText,
                animated: animated
            )
            .circularProgressStyle(style.style())
            
            Button(action: {
                if progress.wrappedValue == initialValue {
                    progress.wrappedValue = targetValue
                } else {
                    progress.wrappedValue = initialValue
                }
            }) {
                Text("Alternar")
                    .font(fonts.small)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
            }
            .buttonStyle(.highlightA())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(colors.backgroundC.opacity(0.5))
        .cornerRadius(8)
    }
}

#Preview {
    CircularProgressSample()
}
