import SwiftUI
import ZenithCoreInterface
import Dependencies

// MARK: - Styles Enum
public enum StepsTemplateStyleCase: CaseIterable, Identifiable {
    case `default`
    
    public var id: Self { self }
    
    public func style() -> AnyStepsTemplateStyle {
        switch self {
        case .default:
            return AnyStepsTemplateStyle(DefaultStepsTemplateStyle())
        }
    }
}

// MARK: - Default Style
public struct DefaultStepsTemplateStyle: @preconcurrency StepsTemplateStyle, BaseThemeDependencies {
    public var id = String(describing: Self.self)

    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol

    public init() {}

    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        let previousState: DSState = configuration.canMoveToPreviousStep ? .enabled : .disabled
        let nextState: DSState = configuration.canMoveToNextStep ? .enabled : .disabled
        VStack(spacing: spacings.medium) {
            // Step Indicators
            ScrollView {
                VStack {
                    StepIndicators(
                        currentStep: configuration.currentStep.wrappedValue,
                        totalSteps: configuration.totalSteps,
                        onStepTapped: configuration.moveToStep,
                        activeColor: colors.highlightA,
                        inactiveColor: colors.backgroundB
                    )
                    .id("step-indicator")
                    .padding([.top, .horizontal], spacings.extraSmall)
                    Spacer()

                    configuration.content
                        .id("content-\\(configuration.currentStep.wrappedValue)")
                        .frame(maxWidth: .infinity)
                        .animation(.easeIn, value: configuration.currentStep.wrappedValue)
                }
            }
            Spacer()
            // Navigation Buttons
            HStack {
                Button(action: configuration.moveToPreviousStep) {
                    DynamicImage(.chevronLeft)
                        .dynamicImageStyle(
                            .medium(
                                .contentA,
                                state: previousState
                            )
                        )
                }
                .buttonStyle(
                    .contentA(
                        shape: .circle,
                        state: previousState
                    )
                )
                .id("prev-button")
                Spacer()
                Button(action: configuration.moveToNextStep) {
                    DynamicImage(.chevronRight)
                        .dynamicImageStyle(
                            .medium(
                                .highlightA,
                                state: nextState
                            )
                        )
                }
                .buttonStyle(
                    .highlightA(
                        shape: .circle,
                        state: nextState
                    )
                )
                .id("next-button")
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
        .padding()
    }
}

struct StepIndicators: View {
    let currentStep: Int
    let totalSteps: Int
    let onStepTapped: (Int) -> Void
    let activeColor: Color
    let inactiveColor: Color
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<totalSteps, id: \.self) { index in
                Circle()
                    .fill(currentStep >= index ? activeColor : inactiveColor)
                    .frame(width: 12, height: 12)
                    .overlay(
                        Circle()
                            .stroke(activeColor, lineWidth: 1.5)
                            .opacity(currentStep == index ? 1 : 0)
                    )
                    .scaleEffect(currentStep == index ? 1.2 : 1.0)
                    .animation(.easeInOut, value: currentStep)
                    .contentShape(Rectangle()) // Melhora área de toque
                    .onTapGesture {
                        onStepTapped(index)
                    }
                    .id("step-indicator-\(index)") // Identificador estável
                
                if index < totalSteps - 1 {
                    Rectangle()
                        .fill(currentStep > index ? activeColor : inactiveColor)
                        .frame(height: 2)
                        .frame(maxWidth: .infinity)
                        .scaleEffect(x: currentStep > index ? 1.0 : 0.0, y: 1.0, anchor: .leading)
                        .animation(.easeInOut, value: currentStep)
                        .id("step-connector-\(index)") // Identificador estável
                }
            }
        }
    }
}

// MARK: - Helper extensions
public extension StepsTemplateStyle where Self == DefaultStepsTemplateStyle {
    static func `default`() -> Self { .init() }
}
