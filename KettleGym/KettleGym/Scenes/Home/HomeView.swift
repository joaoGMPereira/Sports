import SwiftUI
import SwiftData
import Zenith
import ZenithCoreInterface

struct HomeView: View, BaseThemeDependencies {
    @State private var trainingProgrammingRouter: Router<TrainingProgramRoute> = .init()
    @Environment(\.modelContext) private var modelContext
    @Query private var trainingPrograms: [TrainingProgram]
    
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    
    var body: some View {
        RoutingView(stack: $trainingProgrammingRouter.stack) {
            List {
                Group {
                    if trainingPrograms.isNotEmpty {
                        HomeWithTrainingsView(
                            trainingPrograms: trainingPrograms,
                            trainingAction: { trainingProgram in
                                trainingProgrammingRouter.navigate(to: .workoutPlans(trainingProgram))
                            },
                            newTrainingAction: {
                                addItem()
                            }) {
                                
                            }
                    } else {
                        HomeEmptyView {
                            addItem()
                        }
                    }
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
            .listRowSeparator(.hidden)
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(colors.backgroundA, ignoresSafeAreaEdges: .all)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("KettleGym")
                        .font(fonts.mediumBold)
                        .foregroundColor(colors.contentA)
                }
            }
        }
        .environment(trainingProgrammingRouter)
        .onAppear {
        }
    }
    
    private func addItem() {
        trainingProgrammingRouter.navigate(to: .trainingProgram)
    }
}

struct HomeWithTrainingsView: View, BaseThemeDependencies {
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    
    let trainingPrograms: [TrainingProgram]
    
    let trainingAction: (TrainingProgram) -> Void
    let newTrainingAction: () -> Void
    let bannerAction: () -> Void
    
    var body: some View {
        ForEach(trainingPrograms) { trainingProgram in
//            ActionCard(title: trainingProgram.title, description: "Frequências: \(trainingProgram.workoutSessions.count) vezes na semana", image: .play, tags: trainingProgram.workoutSessions.map { $0.name }) {
//                trainingAction(trainingProgram)
//            }
            Card(alignment: .leading, type: .fill, action: {
                trainingAction(trainingProgram)
            }) {
                HStack(spacing: spacings.medium) {
                    Text(trainingProgram.title)
                        .textStyle(.mediumBold(.contentA))
                    Spacer()
                    Button {
                        
                    } label: {
                        Text("25%")
                            .textStyle(.small(.contentA))
                            .padding(spacings.extraSmall)
                    }
                    .buttonStyle(.highlightA(shape: .circle))
                    .allowsHitTesting(false)
                }
            }
        }
        Card(
            alignment: .center,
            type: .bordered,
            action: newTrainingAction
        ) {
            Stack(arrangement: .horizontal(alignment: .center)) {
                Text("Adicionar treino")
                    .textStyle(.small(.contentA))
                Spacer()
                DynamicImage(.plus)
                    .dynamicImageStyle(.medium(.contentA))
            }
            .frame(maxHeight:.infinity)
        }
        .background {
            RoundedRectangle(cornerRadius: 24) // TODO RADIUS
                .stroke(colors.contentA, lineWidth: 1)
        }
        BasicCard(
            image: .figureRun,
            title: "Entre aqui para contratar sua propaganda",
            arrangement: .horizontalLeading,
            contentLayout: .imageText
        ) {
            bannerAction()
        }
    }
}

struct HomeEmptyView: View {
    let callback: () -> Void
    
    var body: some View {
        HStack {
            Spacer()
            DynamicImage(.logo)
                .frame(width: 200)
                .scaledToFit()
            Spacer()
        }
        Text("Você ainda não pussui um treino.")
            .textStyle(.medium(.contentA))
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
        
        BasicCard.emptyState(
            image: .figureRun,
            title: "Criar treino"
        ) {
            callback()
        }
        .cardStyle(
            .bordered()
        )
    }
}
