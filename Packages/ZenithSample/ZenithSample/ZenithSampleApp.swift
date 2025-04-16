//
//  ZenithCoreSampleApp.swift
//  ZenithCoreSample
//
//  Created by joao gabriel medeiros pereira on 15/02/25.
//

import SwiftUI
import ZenithCore

@main
struct ZenithSampleApp: App {
    var body: some Scene {
        WindowGroup {
            ZenithSampleView()
        }
    }
}


struct SampleView: View {
    // MARK: - Data Models
    
    enum TabType: String, CaseIterable, Identifiable {
        case menu = "Menu"
        
        var id: String { self.rawValue }
    }
    
    @State private var selectedTab: TabType = .menu
    
    // MARK: - Element Definitions
    
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(TabType.allCases) { tabType in
                tabContent(for: tabType)
                    .tabItem {
                        Text(tabType.rawValue)
                    }
                    .tag(tabType)
            }
        }
        .accentColor(.purple)
    }
    
    // MARK: - Tab Content
    @State var items = ["item 1", "item 2", "item 3"]
    @State var paths: [String] = []
    private func tabContent(for tabType: TabType) -> some View {
        NavigationStack.init(path: $paths) {
            List {
                ForEach(items, id: \.self) {
                    NavigationLink("Go to \($0)", value: $0)
                }
            }
            .listRowSeparator(.hidden)
            .listSectionSeparator(.hidden)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(tabType.rawValue)
                        .font(.largeTitle)
                        .foregroundColor(.white)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .scrollContentBackground(.hidden)
            .background(.background)
            .navigationDestination(for: String.self) { destination in
                Detail.init(title: destination)
            }
        }
    }
}

struct Detail: View {
    let title: String
    
    init(title: String) {
        self.title = title
    }
    
    var body: some View {
        Text(title)
    }
}
