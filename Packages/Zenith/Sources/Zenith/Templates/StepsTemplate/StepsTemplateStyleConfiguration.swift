// filepath: /Users/ipereira.mazzatech/SportsGitHub/Packages/Zenith/Sources/Zenith/Templates/StepsTemplate/StepsTemplateStyleConfiguration.swift
import SwiftUI
import ZenithCoreInterface

public struct AnyStepsTemplateStyle: StepsTemplateStyle & Sendable & Identifiable {
    public let id: UUID = .init()
    
    private let _makeBody: @Sendable (StepsTemplateStyleConfiguration) -> AnyView
    
    public init<S: StepsTemplateStyle>(_ style: S) {
        _makeBody = { @Sendable configuration in
            AnyView(style.makeBody(configuration: configuration))
        }
    }
    
    public func makeBody(configuration: StepsTemplateStyleConfiguration) -> some View {
        _makeBody(configuration)
    }
}

public protocol StepsTemplateStyle: StyleProtocol & Identifiable {
    typealias Configuration = StepsTemplateStyleConfiguration
}

public struct StepsTemplateStyleConfiguration {
    public let currentStep: Binding<Int>
    public let totalSteps: Int
    public let content: AnyView
    public let moveToNextStep: () -> Void
    public let moveToPreviousStep: () -> Void
    public let moveToStep: (Int) -> Void
    public let canMoveToNextStep: Bool
    public let canMoveToPreviousStep: Bool
    
    public init(
        currentStep: Binding<Int>,
        totalSteps: Int,
        content: AnyView,
        moveToNextStep: @escaping () -> Void,
        moveToPreviousStep: @escaping () -> Void,
        moveToStep: @escaping (Int) -> Void,
        canMoveToNextStep: Bool,
        canMoveToPreviousStep: Bool
    ) {
        self.currentStep = currentStep
        self.totalSteps = totalSteps
        self.content = content
        self.moveToNextStep = moveToNextStep
        self.moveToPreviousStep = moveToPreviousStep
        self.moveToStep = moveToStep
        self.canMoveToNextStep = canMoveToNextStep
        self.canMoveToPreviousStep = canMoveToPreviousStep
    }
}

public struct StepsTemplateStyleKey: EnvironmentKey {
    public static let defaultValue: any StepsTemplateStyle = DefaultStepsTemplateStyle()
}

public extension EnvironmentValues {
    var stepsTemplateStyle: any StepsTemplateStyle {
        get { self[StepsTemplateStyleKey.self] }
        set { self[StepsTemplateStyleKey.self] = newValue }
    }
}

public extension StepsTemplateStyle {
    @MainActor
    func resolve(configuration: Configuration) -> some View {
        ResolvedStepsTemplateStyle(style: self, configuration: configuration)
    }
}

private struct ResolvedStepsTemplateStyle<Style: StepsTemplateStyle>: View {
    let style: Style
    let configuration: Style.Configuration
    
    var body: some View {
        style.makeBody(configuration: configuration)
    }
}

public extension View {
    func stepsTemplateStyle(_ style: some StepsTemplateStyle) -> some View {
        environment(\.stepsTemplateStyle, style)
    }
}
