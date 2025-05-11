import SwiftUI
import SwiftData
import Zenith
import ZenithCoreInterface

struct HomeView: View, @preconcurrency BaseThemeDependencies {
    @State private var workoutPlanRoute: Router<WorkoutPlanRoute> = .init()
    @Environment(\.modelContext) private var modelContext
    @Query private var trainingPrograms: [TrainingProgram]
    
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    
    var body: some View {
        RoutingView(stack: $workoutPlanRoute.stack) {
            PrincipalToolbarView.start(
                "Meu treinos",
                trailingImage: .sliderHorizontal3,
                trailingAction: {
                    workoutPlanRoute.navigate(to: .commingSoonFeature)
                }
            ) {
                List {
                    Group {
                        if trainingPrograms.isNotEmpty {
                            HomeWithTrainingsView(
                                trainingPrograms: trainingPrograms,
                                trainingAction: { trainingProgram in
                                    workoutPlanRoute.navigate(to: .workoutPlans(trainingProgram))
                                },
                                newTrainingAction: {
                                    addItem()
                                },
                                oldTrainingAction: {
                                    addOldItem()
                                },
                                bannerAction: {}
                            )
                        } else {
                            HomeEmptyView {
                                addItem()
                            }
                        }
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
            }
        }
        .toolbarTitleDisplayMode(.inline)
        .environment(workoutPlanRoute)
    }
    
    private func addItem() {
        workoutPlanRoute.navigate(to: .createWorkoutPlan)
    }
    
    private func addOldItem() {
        workoutPlanRoute.navigate(to: .createWorkoutPlanOld)
    }
}

struct HomeWithTrainingsView: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    
    let trainingPrograms: [TrainingProgram]
    
    let trainingAction: (TrainingProgram) -> Void
    let newTrainingAction: () -> Void
    let oldTrainingAction: () -> Void
    let bannerAction: () -> Void
    
    var body: some View {
        ForEach(trainingPrograms) { trainingProgram in
            Card(alignment: .leading, type: .fill, action: {
                trainingAction(trainingProgram)
            }) {
                ZStack(alignment: .topTrailing) {
                    // Terceira camada de blur (maior e mais suave)
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(hex: "#80B6FB2D"))
                        .frame(width: 100, height: 50)
                        .blur(radius: 50)
                        .offset(x: -20, y: 20)
                    
                    // Segunda camada de blur (média)
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(hex: "#80B6FB2D"))
                        .frame(width: 80, height: 40)
                        .blur(radius: 40)
                        .offset(x: -20, y: 20)
                    
                    // Primeira camada de blur (menor e mais próxima)
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(hex: "#A6ADFF09").opacity(0.9))
                        .frame(width: 42, height: 24)
                        .blur(radius: 20)
                        .offset(x: -25, y: 25)
                    
                    // Conteúdo original
                    VStack(alignment: .leading, spacing: .zero) {
                        
                        HStack(spacing: spacings.medium) {
                            Text(trainingProgram.title)
                                .textStyle(.largeBold(.contentA))
                            Spacer()
                            Button {
                                
                            } label: {
                                Text("25%")
                                    .textStyle(.small(.highlightA))
                                    .padding(spacings.extraSmall)
                            }
                            .buttonStyle(.highlightA(shape: .circle))
                            .allowsHitTesting(false)
                        }
                        .padding(spacings.medium)
                        VStack(alignment: .leading, spacing: spacings.small) {
                            Text("Dias")
                                .font(fonts.smallBold)
                                .foregroundStyle(colors.backgroundC)
                            Text("3x")
                                .textStyle(.small(.contentA))
                        }.padding(spacings.medium)
                    }
                }
                .mask(
                    // Esta máscara garante que o blur respeite as bordas arredondadas
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                )
            }
        }
        BasicCard(
            image: .plus,
            title: "Adicionar treino",
            arrangement: .horizontalCenter,
            contentLayout: .textSpacerImage,
            action: newTrainingAction
        )
        
        BasicCard(
            image: .plus,
            title: "Adicionar treino Antigo",
            arrangement: .horizontalCenter,
            contentLayout: .textSpacerImage,
            action: oldTrainingAction
        )
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
            DynamicImage(.logo, resizable: true)
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
