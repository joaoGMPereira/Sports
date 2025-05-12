import SwiftUI
import Zenith
import ZenithCoreInterface

struct FloatingCardExample: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator
    
    @State private var showCard = false
    @State private var selectedExercise: String? = nil
    @State private var sliderValue: Double = 50
    
    let exercises = [
        "Agachamento", "Supino", "Levantamento Terra", 
        "Rosca Direta", "Prancha", "Corrida", 
        "Natação", "Ciclismo", "Yoga", "Pilates"
    ]
    
    var body: some View {
        ZStack {
            // Conteúdo principal com ScrollView
            ScrollView {
                VStack(spacing: 20) {
                    Text("Lista de Exercícios")
                        .font(fonts.largeBold)
                        .foregroundColor(colors.contentA)
                        .padding(.top, 20)
                    
                    // Lista de exercícios
                    ForEach(exercises, id: \.self) { exercise in
                        exerciseCard(exercise)
                    }
                    
                    // Slider simples para garantir que o scrolling funcione
                    VStack(alignment: .leading) {
                        Text("Configuração: \(Int(sliderValue))")
                            .font(fonts.medium)
                            .foregroundColor(colors.contentA)
                        
                        Slider(value: $sliderValue, in: 0...100)
                            .accentColor(colors.highlightA)
                            .padding(.horizontal)
                    }
                    .padding()
                    .background(colors.backgroundB)
                    .cornerRadius(8)
                    .padding(.horizontal)
                }
                .padding(.bottom, 40)
            }
        }
        // Aplicamos o novo FloatingCardModifier na View principal
        .floatingCard(
            isPresented: $showCard,
            backgroundOpacity: 0.7,
            backgroundBlur: 5,
            scale: 1.05,
            isDraggable: true
        ) {
            // Este é o conteúdo que será mostrado quando o card estiver flutuando
            if let exercise = selectedExercise {
                detailedExerciseCard(exercise)
            }
        }
    }
    
    // Card básico para cada exercício
    private func exerciseCard(_ exercise: String) -> some View {
        Button(action: {
            selectedExercise = exercise
            withAnimation(.spring()) {
                showCard = true
            }
        }) {
            HStack {
                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.system(size: 24))
                    .foregroundColor(colors.highlightA)
                    .padding(.trailing, 10)
                
                Text(exercise)
                    .font(fonts.medium)
                    .foregroundColor(colors.contentA)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(colors.contentB)
            }
            .padding()
            .background(colors.backgroundB)
            .cornerRadius(8)
            .shadow(radius: 2)
            .padding(.horizontal)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // Card detalhado que aparece quando flutuando
    private func detailedExerciseCard(_ exercise: String) -> some View {
        VStack(spacing: 16) {
            Text(exercise)
                .font(fonts.largeBold)
                .foregroundColor(colors.contentA)
            
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: 60))
                .foregroundColor(colors.highlightA)
                .padding()
            
            Text("Este exercício faz parte do seu programa de treino. Toque no botão abaixo para ver detalhes.")
                .font(fonts.small)
                .foregroundColor(colors.contentA)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                // Ação do botão
            }) {
                Text("Ver Detalhes")
                    .font(fonts.mediumBold)
                    .foregroundColor(colors.contentC)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(colors.highlightA)
                    .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.top, 10)
        }
        .padding(24)
        .background(colors.backgroundA)
        .cornerRadius(16)
        .shadow(radius: 10)
        .padding(.horizontal, 20)
    }
}

struct FloatingCardExample_Previews: PreviewProvider {
    static var previews: some View {
        FloatingCardExample()
    }
}
