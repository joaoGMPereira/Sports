import SwiftUI
import ComposableArchitecture

@Reducer
struct MultiSelectorFeature {
    @Dependency(\.storage) var storage
    
    @ObservableState
    struct State: Equatable, Identifiable {
        var featureType: FeatureType
        var listState: CreateTagFeature.State
        @Presents var destination: Destination.State?
        
        var selected: IdentifiedArrayOf<SelectableModel> {
            listState.options.filter { $0.selected }
        }
        
        var id: String
        init(
            uuid: UUID = .init(),
            featureType: FeatureType,
            options: IdentifiedArrayOf<SelectableModel>
        ) {
            self.id = uuid.uuidString
            self.featureType = featureType
            self.listState = .init(
                featureType: featureType,
                options: options
            )
        }
    }
    
    enum Action: Equatable {
        case goToSelection
        case destination(PresentationAction<Destination.Action>)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .goToSelection:
                return .none
            case let .destination(.presented(.tagSelection(.delegate(delegate)))):
                switch delegate {
                case let .update(selectable):
                    guard let existingIndex = state.listState.options.firstIndex(where: { $0.id == selectable.id }) else { return .none }
                    state.listState.options[existingIndex] = selectable
                case let .set(selectable):
                    state.listState.options.append(selectable)
                }
                return .none
            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination) {
            Destination()
        }
        
    }
    
    @Reducer
    struct Destination {
        enum State: Equatable, Identifiable {
            case tagSelection(CreateTagFeature.State)
            case exerciseSelection(CreateExerciseFeature.State)
            var id: AnyHashable {
                switch self {
                case let .tagSelection(state):
                    return state.id
                case let .exerciseSelection(state):
                    return state.id
                }
            }
        }
        enum Action: Equatable {
            case tagSelection(CreateTagFeature.Action)
            case exerciseSelection(CreateExerciseFeature.Action)
        }
        var body: some ReducerOf<Self> {
            Scope(state: \.tagSelection, action: \.tagSelection) {
                CreateTagFeature()
            }
            Scope(state: \.exerciseSelection, action: \.exerciseSelection) {
                CreateExerciseFeature()
            }
        }
    }
}

struct MultiSelector: View {
    @Bindable var store: StoreOf<MultiSelectorFeature>
    
    let columns = [
        GridItem(.adaptive(minimum: 60))
    ]
    
    
    init(
        store: StoreOf<MultiSelectorFeature>
    ) {
        self.store = store
    }
    
    var body: some View {
        Button(
            action: {
                store.send(.goToSelection)
            },
            label: {
                VStack(alignment: .leading) {
                    Text(store.featureType.name)
                    if !store.selected.isEmpty {
                        ScrollView(.horizontal) {
                            LazyHGrid(rows: columns, alignment: .top, spacing: 12) {
                                ForEach(store.selected, id: \.self) { item in
                                    Text(item.name)
                                        .font(.callout)
                                        .foregroundColor(.white)
                                        .fontWeight(.medium)
                                        .padding(8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(Asset.primary.swiftUIColor)
                                        )
                                }
                            }
                        }
                        .frame(maxHeight: 100)
                    }
                }
            }
        )
        .navigationDestination(
          item: $store.scope(
            state: \.destination?.tagSelection,
            action: \.destination.tagSelection
          )
        ) { store in
            CreateTag(store: store)
        }
        .navigationDestination(
          item: $store.scope(
            state: \.destination?.exerciseSelection,
            action: \.destination.exerciseSelection
          )
        ) { store in
            CreateExercise(store: store)
        }
        .eraseToAnyView()
    }
    
#if DEBUG
    @ObservedObject var iO = injectionObserver
#endif
}

struct MultiSelector_Previews: PreviewProvider {
    struct IdentifiableString: Identifiable, Hashable {
        let string: String
        var id: String { string }
    }
    
    static var previews: some View {
        NavigationView {
            Form {
                MultiSelector(
                    store: .init(
                        initialState: MultiSelectorFeature.State(
                            featureType: .exercise,
                            options: []
                        )
                    ) {
                        MultiSelectorFeature()
                    }
                )
            }.navigationTitle("Title")
        }
    }
}
