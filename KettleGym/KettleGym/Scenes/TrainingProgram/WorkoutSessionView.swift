//
//  WorkoutPlan.swift
//  KettleGym
//
//  Created by joao gabriel medeiros pereira on 15/04/25.
//
import SwiftUI
import Zenith
import ZenithCoreInterface

struct WorkoutSessionView: View, BaseThemeDependencies {
    let session: WorkoutSession
    @Environment(\.dismiss) private var dismiss
    
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    
    var body: some View {
        List {
            ForEach(session.workoutExercises.sorted(by: { ($0.position ?? 0) < ($1.position ?? 0) })) { workoutExercise in
                if let exercise = workoutExercise.exercise, let setPlan = workoutExercise.setPlan {
                    Card(alignment: .leading, type: .fill, action: {
                    }) {
                        contentCard(exercise, setPlan)
                    }.listRowSeparator(.hidden)
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(colors.backgroundA, ignoresSafeAreaEdges: .all)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(session.name)
                    .font(fonts.mediumBold)
                    .foregroundColor(colors.contentA)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(colors.contentA)
                }
            }
        }
    }
    
    func contentCard(_ exercise: Exercise, _ setPlan: SetPlan) -> some View {
        HStack(spacing: spacings.medium) {
            VStack(alignment: .leading, spacing: spacings.medium) {
                Text("Leg Press 45º")
                    .textStyle(.small(.contentA))
                Text("\(setPlan.quantity ?? 0) séries de \(setPlan.minRep ?? 0) - \(setPlan.maxRep ?? 0) repetições")
                    .font(fonts.small)
                    .foregroundStyle(Color.init(hex: "#BCBCBC")) // TODO COLOR
            }
            Spacer()
            Button {
                
            } label: {
                DynamicImage(.checkmark)
                    .dynamicImageStyle(.medium(.highlightA))
            }
            .buttonStyle(.highlightA())
            .allowsHitTesting(false)
        }
    }
}
