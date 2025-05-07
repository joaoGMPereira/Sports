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
    private var previousStepCallback: ((Int) -> Void)?
    private var nextStepCallback: ((Int) -> Void)?
    @Binding private var canMoveToPreviousStep: Bool
    @Binding private var canMoveToNextStep: Bool
    
    // Inicializador que utiliza um binding externo para currentStep
    public init(
        totalSteps: Int,
        currentStep: Binding<Int>,
        canMoveToPreviousStep: Binding<Bool>,
        canMoveToNextStep: Binding<Bool>,
        previousStepCallback: ((Int) -> Void)? = nil,
        nextStepCallback: ((Int) -> Void)? = nil,
        @ViewBuilder content: @escaping (Int) -> Content
    ) {
        self._currentStep = currentStep
        self._internalStep = State(initialValue: currentStep.wrappedValue)
        self.totalSteps = totalSteps
        self.content = content
        self.previousStepCallback = previousStepCallback
        self.nextStepCallback = nextStepCallback
        self._canMoveToPreviousStep = canMoveToPreviousStep
        self._canMoveToNextStep = canMoveToNextStep
        self.useExternalBinding = true
    }
    
    // Inicializador com estado interno (para compatibilidade)
    public init(
        initialStep: Int = 0,
        totalSteps: Int,
        @ViewBuilder content: @escaping (Int) -> Content
    ) {
        self._currentStep = .constant(initialStep)
        self._internalStep = State(initialValue: initialStep)
        self.totalSteps = totalSteps
        self.content = content
        self.useExternalBinding = false
        self._canMoveToPreviousStep = .constant(false)
        self._canMoveToNextStep = .constant(false)
        
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
                    canMoveToNextStep: useExternalBinding ? canMoveToNextStep : (internalStep < totalSteps - 1),
                    canMoveToPreviousStep: useExternalBinding ? canMoveToPreviousStep : (internalStep > 0)
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
            nextStepCallback?(useExternalBinding ? currentStep : internalStep)
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
            
            previousStepCallback?(useExternalBinding ? currentStep : internalStep)
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
