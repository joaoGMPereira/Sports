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
            .background(colors.background, ignoresSafeAreaEdges: .all)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("KettleGym")
                        .font(fonts.mediumBold)
                        .foregroundColor(colors.textPrimary)
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
            BaseCard(alignment: .leading, type: .fill, action: {
                trainingAction(trainingProgram)
            }) {
                HStack(spacing: spacings.medium) {
                    Text(trainingProgram.title)
                        .textStyle(.mediumBold(.textPrimary))
                    Spacer()
                    Button {
                        
                    } label: {
                        Text("25%")
                            .textStyle(.small(.textPrimary))
                            .padding(spacings.extraSmall)
                    }
                    .buttonStyle(.highlightA(shape: .circle))
                    .allowsHitTesting(false)
                }
            }
        }
        BaseCard(
            alignment: .center,
            type: .bordered,
            action: newTrainingAction
        ) {
            Stack(arrangement: .horizontal(alignment: .center)) {
                Text("Adicionar treino")
                    .textStyle(.small(.textPrimary))
                Spacer()
                DynamicImage(.plus)
                    .dynamicImageStyle(.medium(.primary))
            }
            .frame(maxHeight:.infinity)
        }
        .background {
            RoundedRectangle(cornerRadius: 24) // TODO RADIUS
                .stroke(colors.textPrimary, lineWidth: 1)
        }
        Card(
            image: .figureRun,
            title: "Entre aqui para contratar sua propaganda",
            arrangement: .verticalLeading
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
            .textStyle(.medium(.textPrimary))
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
        
        Card.emptyState(
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
