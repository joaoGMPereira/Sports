//
//  WorkoutPlan.swift
//  KettleGym
//
//  Created by joao gabriel medeiros pereira on 15/04/25.
//
import SwiftUI
import Zenith
import ZenithCoreInterface

struct WorkoutPlansView: View, BaseThemeDependencies {
    let trainingProgram: TrainingProgram
    @Environment(\.dismiss) private var dismiss
    @Environment(Router<TrainingProgramRoute>.self) var trainingProgrammingRouter
    
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    
    var body: some View {
        List {
            ForEach(trainingProgram.workoutSessions.sorted(by: { $0.name < $1.name })) { session in
                BaseCard(alignment: .leading, type: .fill, action: {
                    trainingProgrammingRouter.navigate(to: .workoutSession(session))
                }) {
                    VStack(spacing: spacings.medium) {
                        HStack(alignment: .top) {
                            Text(session.name)
                                .textStyle(.mediumBold(.textPrimary))
                            Spacer()
                            Text("Precisa de evoluir")
                                .textStyle(.small(.highlightA))
                        }
                        HStack(alignment: .top) {
                            VStack(alignment: .leading) {
                                Text("Tempo")
                                    .font(fonts.small)
                                    .foregroundStyle(Color.init(hex: "#BCBCBC")) // TODO COLOR
                                Text("35 a 40min")
                                    .textStyle(.small(.textPrimary))
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text("Exercícios")
                                    .font(fonts.small)
                                    .foregroundStyle(Color.init(hex: "#BCBCBC")) // TODO COLOR
                                Text("\(session.workoutExercises.count)x")
                                    .textStyle(.small(.textPrimary))
                            }
                        }
                        
                    }
                }.listRowSeparator(.hidden)

            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(colors.background, ignoresSafeAreaEdges: .all)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(trainingProgram.title)
                    .font(fonts.mediumBold)
                    .foregroundColor(colors.textPrimary)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(colors.textPrimary)
                }
            }
        }
    }
}


extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: Double
        switch hex.count {
        case 6:
            (a, r, g, b) = (1, Double((int >> 16) & 0xFF) / 255, Double((int >> 8) & 0xFF) / 255, Double(int & 0xFF) / 255)
        case 8:
            (a, r, g, b) = (Double((int >> 24) & 0xFF) / 255, Double((int >> 16) & 0xFF) / 255, Double((int >> 8) & 0xFF) / 255, Double(int & 0xFF) / 255)
        default:
            (a, r, g, b) = (1, 0, 0, 0)
        }
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}
