import SwiftUI
import ComposableArchitecture

@Reducer
struct CreateExerciseFeature {
    @Dependency(\.storage) var storage
    
    @ObservableState
    struct State: Equatable, Identifiable, Hashable {
        var featureType: FeatureType
        var name: String = String()
        var options: IdentifiedArrayOf<SelectableModel>
        var id: String
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(name)
            hasher.combine(id)
        }
        
        init(
            id: UUID = .init(),
            featureType: FeatureType,
            options: IdentifiedArrayOf<SelectableModel> = []
        ) {
            self.id = id.uuidString
            self.featureType = featureType
            self.options = options
        }
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case select(_ selectable: SelectableModel)
        case save
        case delegate(Delegate)
    }
    
    enum Delegate: Equatable {
        case update(_ selectable:SelectableModel)
        case set(_ selectable:SelectableModel)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case let .select(selectable):
                guard let existingIndex = state.options.firstIndex(where: { $0.id == selectable.id }) else { return .none }
                state.options[existingIndex].selected.toggle()
                return .send(.delegate(.update(state.options[existingIndex])))
            case .delegate:
                return .none
            case .binding:
                return .none
            case .save:
                var selectable: SelectableModel?
                switch state.featureType {
                case .exercise:
                    let exercise = Exercise(name: state.name)
                    selectable = exercise.option
                    state.options.append(exercise.option)
                    storage.provider.save(exercise)
                case .tag:
                    let tag = Tag(name: state.name)
                    selectable = tag.option
                    state.options.append(tag.option)
                    storage.provider.save(tag)
                case .none: break
                }
                state.name = ""
                guard let selectable else {
                    return .none
                }
                return .send(.delegate(.set(selectable)))
            }
        }
    }
}

struct CreateExercise: View {
    @Bindable var store: StoreOf<CreateExerciseFeature>
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Criar Opção")) {
                    TextField(
                        "Nome do Treino",
                        text: $store.name.removeDuplicates()
                    )
                    Button("Salvar") {
                        store.send(.save)
                    }.tint(Asset.primary.swiftUIColor).frame(maxWidth: .infinity)
                }
                Section(header: Text("Opções")) {
                        ForEach(store.options) { selectable in
                            Button(
                                action: {
                                    store.send(.select(selectable))
                                }
                            ) {
                                HStack {
                                    Text(selectable.name)
                                    Spacer()
                                    if selectable.selected {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(Asset.primary.swiftUIColor)
                                    }
                                }
                            }
                            .tint(.init(uiColor: .label))
                            .tag(selectable.id)
                        }
                }
            }
        }
        .eraseToAnyView()
                    
    }
    
#if DEBUG
    @ObservedObject var iO = injectionObserver
#endif
}

struct CreateExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CreateExercise(
                store: .init(
                    initialState: CreateExerciseFeature.State(
                        featureType: .none
                    )
                ) {
                    CreateExerciseFeature()
                }
            )
        }
    }
}
