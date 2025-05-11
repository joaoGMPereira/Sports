import SwiftUI
import Zenith
import ZenithCoreInterface

struct SectionView<T: View>: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator
    
    let title: String
    let isExpanded: Binding<Bool>
    let backgroundColor: Color?
    let content: T
    
    var color: Color {
        backgroundColor ?? colors.backgroundB
    }
    
    init(
        title: String,
        isExpanded: Binding<Bool>,
        backgroundColor: Color? = nil,
        @ViewBuilder content: @escaping () -> T
    ) {
        self.title = title
        self.isExpanded = isExpanded
        self.content = content()
        self.backgroundColor = backgroundColor
    }
    
    var body: some View {
        Section(isExpanded: isExpanded) {
            content
                .listRowSeparator(.hidden)
        } header: {
            HStack(alignment: .center) {
                Image(systemSymbol: .chevronDown)
                    .rotationEffect(.init(degrees: isExpanded.wrappedValue ? 180 : 0))
                    .foregroundStyle(colors.contentA)
                Text(title.uppercased())
                    .textStyle(.mediumBold(.highlightA))
                    .padding(.top, 4)
            }
            .animation(.smooth, value: isExpanded.wrappedValue)
            .onTapGesture {
                withAnimation {
                    isExpanded.wrappedValue.toggle()
                }
            }
        }
        .listRowBackground(color)
    }
}
