import SwiftUI
import Zenith
import ZenithCoreInterface

@Observable
final class CreateWorkoutPlanViewModel {
    var currentStep = 0
    var canMoveToPreviousStep = false
    var canMoveToNextStep = false
    var basicInfo = CreateWorkoutPlanBasicInfoViewModel()
    
    func setStep(_ step: Int) {
        currentStep = step
        updateNavigationState()
    }
    
    func updateNavigationState() {
        canMoveToPreviousStep = currentStep > 0
        
        // Validação para permitir avançar para o próximo passo
        canMoveToNextStep = switch currentStep {
        case 0:
            basicInfo.name.isNotEmpty
        case 1, 2:
            true // Lógica para os outros passos será implementada
        default:
            false
        }
    }
    
    func updateBasicInfo(_ basicInfo: CreateWorkoutPlanBasicInfoViewModel) {
        self.basicInfo = basicInfo
        updateNavigationState()
    }
}

struct CreateWorkoutPlanView: View, BaseThemeDependencies {
    @Environment(Router<WorkoutPlanRoute>.self) var workoutPlanRoute
    @State private var viewModel = CreateWorkoutPlanViewModel()
    
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    
    var body: some View {
        PrincipalToolbarView.push("Sessão de Treino") {
            StepsTemplate(
                totalSteps: 3,
                currentStep: $viewModel.currentStep,
                canMoveToPreviousStep: $viewModel.canMoveToPreviousStep,
                canMoveToNextStep: $viewModel.canMoveToNextStep,
                previousStepCallback: { step in viewModel.setStep(step) },
                nextStepCallback: { step in viewModel.setStep(step) }
            ) { step in
                Card(
                    action: {
                        hideKeyboard()
                    }
                ) {
                    Stack(arrangement: .vertical(alignment: .center)) {
                        header(step)
                        stepContent(step)
                    }
                }
                .padding(.top, spacings.medium)
                
            }
            .stepsTemplateStyle(.default())
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                HStack {
                    Spacer()
                    Button("OK") {
                        hideKeyboard()
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func header(_ step: Int) -> some View {
        let title = switch step {
        case 0:
            "Dados Básicos"
        default:
            "Passo não encontrado"
        }
        
        HStack {
            Text(title)
                .textStyle(.mediumBold(.highlightA))
                .multilineTextAlignment(.leading)
            Spacer()
        }
    }
    
    @ViewBuilder
    private func stepContent(_ step: Int) -> some View {
        switch step {
        case 0:
            CreateWorkoutPlanBasicInfoView(
                viewModel: $viewModel.basicInfo
            ) { basicInfo in
                viewModel.updateBasicInfo(basicInfo)
            }
            
        default:
            Text("Passo não encontrado")
                .foregroundColor(.red)
        }
    }
}
