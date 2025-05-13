import SwiftUI
import Zenith
import ZenithCoreInterface

/**
 # SampleWithFixedHeader
 
 Um componente reutilizável que permite exibir um header fixo no topo da tela
 quando o usuário interage com o conteúdo de exemplo.
 
 ## Funcionalidades
 
 - Exibe um componente fixo no topo da tela quando ativado
 - Gerencia automaticamente as margens para garantir que o conteúdo não fique escondido
 - Controla o scroll para manter a experiência do usuário suave
 - Adapta-se ao headerHeight definido pelo ambiente
 
 ## Como usar
 
 ```swift
 @State private var showFixedHeader = false
 
 SampleWithFixedHeader(
     showFixedHeader: $showFixedHeader,
     content: {
         // Seu componente principal aqui (será exibido no fluxo normal)
         MeuComponente()
             .onTapGesture {
                 showFixedHeader.toggle() // Alterna o header fixo
             }
     },
     config: {
         // configuracoes do seu componente
         ConfigDoComponente()
     }
 )
 ```
 
 ## Observações
 
 - O componente usa o `headerHeight` do ambiente para calcular as margens adequadas
 - Utilize o `captureHeight` para capturar corretamente a altura do conteúdo
 - Ajuste o `Spacer(minLength:)` no overlay para criar espaço para o componente principal
 */
struct SampleWithFixedHeader<Content: View, Config: View>: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator
    
    // IDs para o ScrollViewReader
    private let topContentId = "topContentId"
    private let configSectionId = "configSectionId"
    
    let content: () -> Content
    let config: () -> Config
    
    // Estado para controlar a visibilidade do header fixo
    @Binding var showFixedHeader: Bool
    
    // Estado para capturar a altura do conteúdo
    @State private var contentHeight: CGFloat = 0
    
    // Acesso à altura do header via environment
    @Environment(\.headerHeight) private var headerHeight
    
    // Margem superior dinâmica que se ajusta conforme o header fixo
    var topMargin: CGFloat {
        var margin = headerHeight
        if showFixedHeader {
            margin += contentHeight + spacings.medium
        }
        return margin
    }
    
    init(
        showFixedHeader: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder config: @escaping () -> Config
    ) {
        self._showFixedHeader = showFixedHeader
        self.content = content
        self.config = config
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            // Header fixo que aparece na parte superior quando ativado
            if showFixedHeader {
                content()
                    .padding(.top, headerHeight)
                    .padding(.bottom, spacings.small)
                    .background(colors.backgroundA.opacity(0.9).cornerRadius(10, corners: .allCorners))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(colors.backgroundA, lineWidth: 2)
                    )
                    .shadow(color: colors.backgroundB.opacity(0.8), radius: 10)
                    .zIndex(1000)
            }
            
            // Conteúdo principal com scroll
            ScrollViewReader { reader in
                ScrollView {
                    VStack(alignment: .leading, spacing: spacings.medium) {
                        if showFixedHeader == false {
                            content()
                                .captureHeight($contentHeight)
                                .id(topContentId)
                        }
                        config()
                            .id(configSectionId) 
                    }
                }
                .scrollIndicators(.hidden)
                .contentMargins(.top, topMargin)
                .onChange(of: self.showFixedHeader, {
                    if showFixedHeader == false {
                        reader.scrollTo(topContentId, anchor: .top)
                    } else {
                        reader.scrollTo(configSectionId, anchor: .top)
                    }
                })
                .onAppear {
                    reader.scrollTo(topContentId, anchor: .top)
                }
            }
        }
    }
}
