//
//  BackTitleModifier.swift
//  Sports
//
//  Created by joao gabriel medeiros pereira on 02/04/23.
//

import SwiftUI
import SFSafeSymbols

struct BackButtonModifier: ViewModifier {
    @Environment(\.presentationMode) var presentation
    let title: String?
    
    init(title: String? = nil) {
        self.title = title
    }
    @ViewBuilder @MainActor func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button(action: { presentation.wrappedValue.dismiss() }) {
                Image(systemName: SFSymbol.chevronLeft.rawValue)
                    .fontWeight(.semibold)
                    .imageScale(.large)
                if let title {
                    Text(title)
                        .padding(leading: -3)
                        .foregroundColor(Asset.primary.swiftUIColor)
                }
            }.padding(leading: -8))
            .contentShape(Rectangle())
            .gesture(
                DragGesture(coordinateSpace: .local)
                    .onEnded { value in
                        if value.translation.width > .zero
                            && value.translation.height > -30
                            && value.translation.height < 30 {
                            presentation.wrappedValue.dismiss()
                        }
                    }
            )
            .eraseToAnyView()
    }
}

extension View {
    func hideBackTitle() -> some View {
        modifier(BackButtonModifier())
    }
    
    func backTitle(_ title: String) -> some View {
        modifier(BackButtonModifier(title: title))
    }
}
