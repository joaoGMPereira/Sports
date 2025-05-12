//
//  ZenithCoreSampleApp.swift
//  ZenithCoreSample
//
//  Created by joao gabriel medeiros pereira on 15/02/25.
//

import SwiftUI
import Zenith
import ZenithCore

@main
struct ZenithSampleApp: App {
    // Estado compartilhado para o componente flutuante
    @StateObject private var floatingViewState = FloatingViewState()
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                // Conteúdo principal do aplicativo
                ZenithSampleView()
                    .environment(\.colorScheme, .dark)
                
                // Container de visualização flutuante em nível de aplicativo
                FloatingViewContainer(floatingViewState: floatingViewState)
            }
            // Disponibiliza o estado floatingViewState para toda a hierarquia de views
            .environmentObject(floatingViewState)
            .environment(\.floatingViewState, floatingViewState)
        }
    }
}
