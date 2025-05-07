import SwiftUI
import Zenith
import ZenithCoreInterface
import SFSafeSymbols

struct CommingSoonFeatureView: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator
    @Environment(\.dismiss) private var dismiss
    
    let featureName: String
    let description: String
    let imageName: SFSymbol
    let showBackButton: Bool
    
    init(
        featureName: String = "Novo Recurso",
        description: String = "Este recurso está sendo desenvolvido e estará disponível em breve. Estamos trabalhando para proporcionar a melhor experiência possível.",
        imageName: SFSymbol = .sparkles,
        showBackButton: Bool = true
    ) {
        self.featureName = featureName
        self.description = description
        self.imageName = imageName
        self.showBackButton = showBackButton
    }
    
    var body: some View {
        PrincipalToolbarView.push("Em Breve") {
            VStack {
                Spacer()
                
                // Ícone animado
                DynamicImage(imageName)
                    .dynamicImageStyle(.medium(.highlightA))
                    .font(.system(size: 80))
                    .padding(40)
                    .background(
                        Circle()
                            .fill(colors.backgroundB)
                            .shadow(color: colors.backgroundC.opacity(0.3), radius: 10)
                    )
                    .overlay(
                        Circle()
                            .stroke(colors.highlightA.opacity(0.3), lineWidth: 2)
                            .scaleEffect(1.1)
                    )
                    .overlay(
                        ZStack {
                            ForEach(0..<3) { i in
                                Circle()
                                    .stroke(colors.highlightA.opacity(0.3), lineWidth: 1)
                                    .scaleEffect(1 + Double(i) * 0.1)
                            }
                        }
                    )
                
                // Textos informativos
                Text(featureName)
                    .textStyle(.bigBold(.contentA))
                    .padding(.top, spacings.large)
                
                Text("Em breve")
                    .textStyle(.medium(.highlightA))
                    .padding(.top, spacings.extraSmall)
                
                Text(description)
                    .textStyle(.small(.contentA))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, spacings.large)
                    .padding(.top, spacings.medium)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    CommingSoonFeatureView(
        featureName: "Acompanhamento de Treinos",
        description: "Este recurso está sendo desenvolvido para você acompanhar seu progresso e desempenho nos treinos. Em breve estará disponível para uso!",
        imageName: .dumbbell
    )
}
