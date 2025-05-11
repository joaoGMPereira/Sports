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
                .environment(\.colorScheme, .dark)
        }
    }
}
