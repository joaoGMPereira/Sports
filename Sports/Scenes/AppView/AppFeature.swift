//
//  AppStartFeature.swift
//  Sports
//
//  Created by joao gabriel medeiros pereira on 07/05/23.
//

import ComposableArchitecture

@Reducer
struct AppFeature {
    @ObservableState
    struct State: Equatable {
        var workoutsTab = WorkoutsFeature.State()
        var selectedTab = Tab.workouts
    }
    
    enum Action: Equatable {
        case workoutsTab(WorkoutsFeature.Action)
        case selectedTabChanged(Tab)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .selectedTabChanged(tab):
                state.selectedTab = tab
                return .none
            case .workoutsTab:
                return .none
            }
        }
        Scope(state: \.workoutsTab, action: \.workoutsTab) {
            WorkoutsFeature()
        }
    }
}

enum Tab: Hashable {
  case workouts
}
