import SwiftUI
import ZenithCoreInterface

// MARK: - Main StepsTemplate Component
public struct StepsTemplate<Content: View>: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    
    @Environment(\.stepsTemplateStyle) private var style
    @Binding private var currentStep: Int
    @State private var internalStep: Int
    
    private let totalSteps: Int
    private let content: (Int) -> Content
    private let useExternalBinding: Bool
    
    // Inicializador que utiliza um binding externo para currentStep
    public init(totalSteps: Int, currentStep: Binding<Int>, @ViewBuilder content: @escaping (Int) -> Content) {
        self._currentStep = currentStep
        self._internalStep = State(initialValue: currentStep.wrappedValue)
        self.totalSteps = totalSteps
        self.content = content
        self.useExternalBinding = true
    }
    
    // Inicializador com estado interno (para compatibilidade)
    public init(initialStep: Int = 0, totalSteps: Int, @ViewBuilder content: @escaping (Int) -> Content) {
        self._currentStep = .constant(initialStep)
        self._internalStep = State(initialValue: initialStep)
        self.totalSteps = totalSteps
        self.content = content
        self.useExternalBinding = false
    }
    
    public var body: some View {
        AnyView(
            style.resolve(
                configuration: StepsTemplateStyleConfiguration(
                    currentStep: useExternalBinding ? $currentStep : $internalStep,
                    totalSteps: totalSteps,
                    content: AnyView(content(useExternalBinding ? currentStep : internalStep)),
                    moveToNextStep: moveToNextStep,
                    moveToPreviousStep: moveToPreviousStep,
                    moveToStep: moveToStep,
                    canMoveToNextStep: (useExternalBinding ? currentStep : internalStep) < totalSteps - 1,
                    canMoveToPreviousStep: (useExternalBinding ? currentStep : internalStep) > 0
                )
            )
        )
    }
    
    private func moveToNextStep() {
        withAnimation(.easeInOut(duration: 0.3)) {
            if useExternalBinding {
                if currentStep < totalSteps - 1 {
                    currentStep += 1
                }
            } else {
                if internalStep < totalSteps - 1 {
                    internalStep += 1
                }
            }
        }
    }
    
    private func moveToPreviousStep() {
        withAnimation(.easeInOut(duration: 0.3)) {
            if useExternalBinding {
                if currentStep > 0 {
                    currentStep -= 1
                }
            } else {
                if internalStep > 0 {
                    internalStep -= 1
                }
            }
        }
    }
    
    private func moveToStep(_ step: Int) {
        withAnimation(.easeInOut(duration: 0.3)) {
            if step >= 0 && step < totalSteps {
                if useExternalBinding {
                    currentStep = step
                } else {
                    internalStep = step
                }
            }
        }
    }
}
