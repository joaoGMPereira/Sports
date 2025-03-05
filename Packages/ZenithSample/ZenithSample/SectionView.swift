import SwiftUI
import Zenith
import ZenithCoreInterface

struct SectionView<T: View>: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator
    
    let title: String
    let isExpanded: Binding<Bool>
    let content: T
    
    init(
        title: String,
        isExpanded: Binding<Bool>,
        @ViewBuilder content: @escaping () -> T
    ) {
        self.title = title
        self.isExpanded = isExpanded
        self.content = content()
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
            .font(fonts.mediumBold.font)
            .foregroundStyle(colors.textPrimary)
            .animation(.smooth, value: isExpanded.wrappedValue)
            .onTapGesture {
                withAnimation {
                    isExpanded.wrappedValue.toggle()
                }
            }
        }
        .listRowBackground(colors.backgroundSecondary)
    }
}
