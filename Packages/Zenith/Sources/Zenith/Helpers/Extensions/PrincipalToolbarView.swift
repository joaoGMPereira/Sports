import SwiftUI
import ZenithCoreInterface
import SFSafeSymbols

// Environment key para o headerHeight
private struct HeaderHeightKey: EnvironmentKey {
    static let defaultValue: CGFloat = 0
}

// Extension para acessar o headerHeight
extension EnvironmentValues {
    public var headerHeight: CGFloat {
        get { self[HeaderHeightKey.self] }
        set { self[HeaderHeightKey.self] = newValue }
    }
}

// Extension para view modifier para definir o headerHeight
extension View {
    public func headerHeight(_ height: CGFloat) -> some View {
        environment(\.headerHeight, height)
    }
}

enum PresentationType: String, Decodable, CaseIterable {
    case start, push
}

public struct PrincipalToolbarView<Content: View>: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) public var themeConfigurator
    @Environment(\.dismiss) private var dismiss
    
    let content: Content
    let title: String
    let showBackButton: Bool
    let trailingImage: SFSymbol?
    let trailingAction: (() -> Void)?
    let type: PresentationType
    @State private var localHeaderHeight: CGFloat = 0
    
    init(
        _ title: String,
        type: PresentationType,
        showBackButton: Bool = true,
        trailingImage: SFSymbol?,
        trailingAction: (() -> Void)?,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.type = type
        self.title = title
        self.showBackButton = showBackButton
        self.trailingImage = trailingImage
        self.trailingAction = trailingAction
    }
    
    public static func start(
        _ title: String,
        trailingImage: SFSymbol? = nil,
        trailingAction: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) -> Self {
        .init(
            title,
            type: .start,
            showBackButton: false,
            trailingImage: trailingImage,
            trailingAction: trailingAction,
            content: content
        )
    }
    
    public static func push(
        _ title: String,
        trailingImage: SFSymbol? = nil,
        trailingAction: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) -> Self {
        .init(
            title,
            type: .push,
            showBackButton: true,
            trailingImage: trailingImage,
            trailingAction: trailingAction,
            content: content
        )
    }
    
    public var body: some View {
        ZStack(alignment: .top) {
            colors.backgroundA.ignoresSafeArea()
            
            content
                .contentMargins(.top, localHeaderHeight)
            
            VStack {
                HeaderTitle(title, image: trailingImage?.rawValue ?? "", action: trailingAction)
                    .background(colors.backgroundA.opacity(0.9))
                    .zIndex(1) // Garante que o título fique por cima
                    .onPreferenceChange(HeightKey.self) { height in
                        self.localHeaderHeight = height
                    }
                
                Spacer()
            }
        }
        .headerHeight(localHeaderHeight) // Definindo o valor do environment
        .navigationBarBackButtonHidden(showBackButton)
        .toolbarTitleDisplayMode(.inline)
        .scrollContentBackground(.hidden)
        .toolbarBackground(Color.clear, for: .navigationBar)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            if showBackButton {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemSymbol: .chevronLeft)
                            .foregroundColor(colors.contentA)
                    }
                }
            }
            /// Para sempre ter o espaço da navigationBar
            ToolbarItem(placement: .principal) {
                Text(String())
            }
        }
    }
}
