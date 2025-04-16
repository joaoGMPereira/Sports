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
        backgroundColor ?? colors.backgroundSecondary
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
        } header: {
            Label(
                title: {
                    Text(title)
                        .textStyle(.mediumBold(.primary))
                },
                icon: {
                    Image(systemSymbol: .chevronDown)
                        .rotationEffect(.init(degrees: isExpanded.wrappedValue ? 180 : 0))
                })
            .font(fonts.mediumBold)
            .foregroundStyle(colors.textPrimary)
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
