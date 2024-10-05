//
//  FormView.swift
//  Sports
//
//  Created by joao gabriel medeiros pereira on 01/04/23.
//

import ComposableArchitecture
import SwiftUI

struct FormModel: Equatable, Hashable {
    let name: String
    var options: IdentifiedArrayOf<SelectableModel>
}

protocol Selectable {}

struct SelectableModel: Identifiable, Hashable, Equatable {
    
    static func == (
        lhs: SelectableModel,
        rhs: SelectableModel
    ) -> Bool {
        lhs.name == rhs.name && lhs.id == rhs.id && lhs.selected == rhs.selected
    }
    
    func hash(
        into hasher: inout Hasher
    ) {
        hasher.combine(
            name
        )
        hasher.combine(
            id
        )
        hasher.combine(
            selected
        )
    }
    
    let name: String
    let id: String
    var selected: Bool = false
    let model: Selectable
}
extension Tag {
    var option: SelectableModel {
        .init(
            name: name,
            id: id.uuidString,
            model: self
        )
    }
}

extension Exercise {
    var option: SelectableModel {
        .init(
            name: name,
            id: id.uuidString,
            model: self
        )
    }
}

extension Array where Element == Tag {
    var options: IdentifiedArrayOf<SelectableModel> {
        .init(
            uniqueElements: map {
                $0.option
            }
        )
    }
}

extension Array where Element == Exercise {
    var options: IdentifiedArrayOf<SelectableModel> {
        .init(
            uniqueElements: map {
                $0.option
            }
        )
    }
}

@Reducer
struct FormFeature {
    @Dependency(\.storage) var storage
    @Dependency(\.dismiss) var dismiss
    
    @ObservableState
    struct State: Equatable, Identifiable, Hashable {
        var name: String
        var selectors: IdentifiedArrayOf<MultiSelectorFeature.State>
        var id: String
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(name)
            hasher.combine(id)
        }
        
        init(
            id: UUID = .init(),
            name: String = String(),
            selectors: IdentifiedArrayOf<MultiSelectorFeature.State> = []
        ) {
            self.id = id.uuidString
            self.name = name
            
            self.selectors = selectors
        }
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case selectors(_ selectors: IdentifiedActionOf<MultiSelectorFeature>)
        case save(name: String, selectors: IdentifiedArrayOf<MultiSelectorFeature.State>)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce(self.core).forEach(\.selectors, action: \.selectors) {
            MultiSelectorFeature()
        }
    }
    
    
    private func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .binding:
            return .none
        case .selectors:
            return .none
        case .save:
            return .run { send in await self.dismiss() }
        }
    }
}

struct FormView: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var store: StoreOf<FormFeature>
    
    var body: some View {
            VStack {
                Form {
                    Section {
                        TextField(
                            "Nome do Treino",
                            text: $store.name
                                .removeDuplicates()
                        )
                        ForEach(
                            self.store.scope(
                                state: \.selectors,
                                action: \.selectors
                            )
                        ) {
                            MultiSelector(store: $0)
                        }
                    }
                    
                    Section {
                        Button("Salvar") {
                            store.send(.save(name: store.name, selectors: store.selectors))
                        }.tint(Asset.primary.swiftUIColor).frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationTitle("Formulário")
            .eraseToAnyView()
    }
}
