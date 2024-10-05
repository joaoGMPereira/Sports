import ComposableArchitecture
import SwiftUI
import CoreData
import SFSafeSymbols

@Reducer
struct WorkoutsFeature {
    @Dependency(\.storage) var storage
    @ObservableState
    struct State: Equatable {
        var workouts: IdentifiedArrayOf<Workout> = []
        var path = StackState<Path.State>()
        init(workouts: IdentifiedArrayOf<Workout> = []) {
            self.workouts = workouts
        }
    }
    
    enum Action: Equatable {
        case onAppear
        case clear
        case onDelete(_ ids: IndexSet)
        case add
        case addMock
        case path(StackAction<Path.State, Path.Action>)
    }
    
    
    var body: some ReducerOf<Self> {
        Reduce {
            state,
            action in
            switch action {
            case .onAppear:
                state.workouts = .init(uniqueElements: storage.provider.workouts())
                let tags = storage.provider.tags()
                let exercises = storage.provider.exercises()
                return .none
            case .clear:
                withAnimation {
                    storage.provider.clearAll()
                    state.workouts = .init(uniqueElements: storage.provider.workouts())
                }
                return .none
            case let .onDelete(indexSet):
                storage.provider.remove(indexSet.map { state.workouts[$0].id })
                state.workouts = .init(uniqueElements: storage.provider.workouts())
                return .none
            case .addMock:
                withAnimation {
                    storage.provider.addMock()
                    state.workouts = .init(uniqueElements: storage.provider.workouts())
                }
                return .none
            case .add:
                let tags: [Tag] = storage.provider.tags()
                let exercises: [Exercise] = storage.provider.exercises()
                state.path.append(
                    .addItem(
                        FormFeature.State(
                            selectors: [
                                .init(
                                    featureType: .tag,
                                    options: tags.options
                                ),
                                .init(
                                    featureType: .exercise,
                                    options: exercises.options
                                )
                            ]
                        )
                    )
                )
                return .none
            case let .path(action):
                switch action {
                    
                case .element(_, action: let action):
                    guard case let .addItem(addAction) = action,
                          case let .save(name, selectors) = addAction else {
                        return .none
                    }
                    let selectedTags = selectors.first?.listState.options.filter{ $0.selected }.compactMap { $0.model as? Tag } ?? []
                    let selectedExercises = selectors.last?.listState.options.filter{ $0.selected }.compactMap { $0.model as? Exercise } ?? []
                    let workout = Workout(
                        name: name,
                        tags: selectedTags,
                        exercises: selectedExercises
                    )
                    storage.provider.save(workout)
                    state.workouts = .init(uniqueElements: storage.provider.workouts())
                    return .none
                default:
                    return .none
                }
            }
        }
        .forEach(\.path, action: \.path) {
            Path()
        }
    }
    
    @Reducer
    struct Path {
        @ObservableState
        enum State: Equatable, Identifiable, Hashable {
            case addItem(FormFeature.State)
            var id: AnyHashable {
                switch self {
                case let .addItem(state):
                    return state.id
                }
            }
            
            var name: String {
                switch self {
                case let .addItem(state):
                    return state.name
                }
            }
        }
        enum Action: Equatable {
            case addItem(FormFeature.Action)
        }
        var body: some ReducerOf<Self> {
            Scope(state: \.addItem, action: \.addItem) {
                FormFeature()
            }
        }
    }
}


struct WorkoutsView: View {
    @Bindable var store: StoreOf<WorkoutsFeature>
    
    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            List {
                Section(header: Text("Workouts")) {
                    ForEach(store.workouts) { workout in
                        ExpandableView(item: WorkoutsFeature.Path.State.addItem(FormFeature.State(name: workout.name)))
                    }
                    .onDelete { indexSet in
                        store.send(.onDelete(indexSet))
                    }
                }
            }
            .eraseToAnyView()
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(
                        action: {
                            store.send(.add)
                        }
                    ) {
                        Label("Add Item", systemImage: "plus")
                            .foregroundColor(Asset.primary.swiftUIColor).eraseToAnyView()
                    }
                }
                ToolbarItem {
                    Button {
                        store.send(.addMock)
                    } label: {
                        Label("Eita", systemImage: SFSymbol.app.rawValue)
                    }
                }
                ToolbarItem {
                    Button {
                        store.send(.clear)
                    } label: {
                        Label("Clear", systemImage: "minus").eraseToAnyView()
                    }
                }
                
            }
            //                .navigationDestination(
            //                    store: self.store.scope(
            //                        state: \.destination, action: WorkoutsFeature.Action.destination
            //                    ),
            //                    state: /WorkoutsFeature.Destination.State.addItem,
            //                    action: WorkoutsFeature.Destination.Action.addItem
            //                ) { store in
            //                    FormView(store: store)
            //                        .toolbarRole(.editor)
            //                        .eraseToAnyView()
            //                }
            //                .navigationDestination(for: Workout.self) { workout in
            //                    Text(workout.name)
            //                        .toolbarRole(.editor)
            //                        .eraseToAnyView()
            //                }
            //                .navigationDestination(for: Exercise.self) { exercise in
            //                    Text(exercise.name) .toolbarRole(.editor).eraseToAnyView()
            //                }
        } destination: { store in
            
                if let store = store.scope(state: \.addItem, action: \.addItem) {
                    FormView(store: store)
                        .toolbarRole(.editor)
                        .eraseToAnyView()
                }
        }
        .onAppear {
            store.send(.onAppear)
        }
        .tint(Asset.primary.swiftUIColor)
        .eraseToAnyView()
    }
    
    private func deleteExercises(offsets: IndexSet) {
        //        withAnimation {
        //            offsets.map { exercises[$0] }.forEach(viewContext.delete)
        //
        //            do {
        //                try viewContext.save()
        //            } catch {
        //                // Replace this implementation with code to handle the error appropriately.
        //                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        //                let nsError = error as NSError
        //                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        //            }
        //        }
    }
    
    private func deleteTags(offsets: IndexSet) {
        //        withAnimation {
        //            offsets.map { tags[$0] }.forEach(viewContext.delete)
        //
        //            do {
        //                try viewContext.save()
        //            } catch {
        //                // Replace this implementation with code to handle the error appropriately.
        //                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        //                let nsError = error as NSError
        //                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        //            }
        //        }
    }
#if DEBUG
    @ObservedObject var iO = injectionObserver
#endif
}

struct WorkoutsView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutsView(
            store: Store(
                initialState: WorkoutsFeature.State()
            ) {
                WorkoutsFeature()
            }
        )
    }
}
