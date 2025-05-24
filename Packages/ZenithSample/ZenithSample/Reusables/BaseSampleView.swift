import SwiftUI
import Zenith
import ZenithCoreInterface

/// Define o tipo de visualização da amostra
enum SampleViewType {
    /// Exibe o conteúdo em uma seção expansível dentro da lista
    case section
    /// Exibe o conteúdo em uma nova tela de navegação
    case pushed
}

/// View base para todas as amostras de componentes
/// Substitui o uso direto da SectionView nas amostras
struct BaseSampleView<Content: View>: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator
    
    // MARK: - Propriedades
    
    let title: String
    let viewType: SampleViewType
    let content: Content
    let backgroundColor: Color?
    let overrideList: Bool
    
    // MARK: - Inicializadores
    
    /// Inicializador para exibição em seção expansível
    init(
        title: String,
        viewType: SampleViewType = .section,
        backgroundColor: Color? = nil,
        overrideList: Bool,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.viewType = viewType
        self.content = content()
        self.backgroundColor = backgroundColor
        self.overrideList = overrideList
    }
    
    // MARK: - Body
    
    var body: some View {
        switch viewType {
        case .section:
            // Usando a SectionView existente
            sectionContent
        case .pushed:
            // Link de navegação para PushedListView
            pushedNavigationLink
        }
    }
    
    // MARK: - Views
    
    private var color: Color {
        backgroundColor ?? colors.backgroundB
    }
    
    private var sectionContent: some View {
        Section {
            SectionView(
                title: title,
                backgroundColor: backgroundColor
            ) {
                content
            }
        }
    }
    
    private var pushedNavigationLink: some View {
        HStack {
            Text(title.uppercased())
                .textStyle(.mediumBold(.highlightA))
                .padding(.top, 2)
            Spacer()
            Image(systemSymbol: .chevronRight)
                .foregroundColor(colors.contentA)
                .font(.system(size: 14))
        }
        .background {
            NavigationLink {
                PushedListView(title, overrideList: overrideList) {
                    content
                }
            } label: {
                EmptyView()
            }
        }
        .listRowBackground(color)
    }
}
