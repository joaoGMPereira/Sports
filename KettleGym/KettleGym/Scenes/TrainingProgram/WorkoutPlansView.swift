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
    @Environment(Router<WorkoutPlanRoute>.self) var workoutPlanRoute
    
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    
    var body: some View {
        PrincipalToolbarView.push(trainingProgram.title) {
            List {
                ForEach(trainingProgram.workoutSessions.sorted(by: { $0.name < $1.name })) { session in
                    Card(alignment: .leading, type: .fill, action: {
                        workoutPlanRoute.navigate(to: .workoutSession(session))
                    }) {
                        VStack(spacing: spacings.medium) {
                            HStack(alignment: .top) {
                                Text(session.name)
                                    .textStyle(.mediumBold(.contentA))
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
                                        .textStyle(.small(.contentA))
                                }
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text("Exercícios")
                                        .font(fonts.small)
                                        .foregroundStyle(Color.init(hex: "#BCBCBC")) // TODO COLOR
                                    Text("\(session.workoutExercises.count)x")
                                        .textStyle(.small(.contentA))
                                }
                            }
                            
                        }
                    }.listRowSeparator(.hidden)
                    
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
    }
}
