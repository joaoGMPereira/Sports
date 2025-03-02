import SwiftUI
import Zenith
import SFSafeSymbols
import ZenithCoreInterface

struct ZenithSampleView: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator
    
    @State
    var imagesIsExpanded: Bool = false
    @State
    var buttonsIsExpanded: Bool = false
    @State
    var textsIsExpanded: Bool = false
    @State
    var dividersIsExpanded: Bool = false
    @State
    var tagsIsExpanded: Bool = false
    
    var body: some View {
        NavigationView {
            List {
                SectionView(title: "IMAGES", isExpanded: $imagesIsExpanded) {
                    ForEach(DynamicImageColor.allCases, id: \.self) { style in
                        DynamicImage("checkmark")
                            .dynamicImageStyle(.small(style))
                        DynamicImage(._2hCircleFill)
                            .dynamicImageStyle(.small(style))
                        DynamicImage("https://example.com/icon.png")
                            .dynamicImageStyle(.small(style))
                        DynamicImage("checkmark")
                            .dynamicImageStyle(.medium(style))
                        DynamicImage(._2hCircleFill)
                            .dynamicImageStyle(.medium(style))
                        DynamicImage("https://example.com/icon.png")
                            .dynamicImageStyle(.medium(style))
                    }
                }
                SectionView(title: "BUTTONS", isExpanded: $buttonsIsExpanded) {
                    Button("Primary") {
                        print("caiu aqui")
                    }
                    .buttonStyle(.primary)
                    Button("Secondary") {
                        print("caiu aqui")
                    }
                    .buttonStyle(.secondary)
                }
                
                SectionView(title: "TEXTS", isExpanded: $textsIsExpanded) {
                    ForEach(TextStyleCase.allCases, id: \.self) { style in
                        Text("teste")
                            .modifier(style.modifier())
                    }
                }
                
                SectionView(title: "DIVIDERS", isExpanded: $dividersIsExpanded) {
                    ForEach(DividerStyleCase.allCases, id: \.self) { style in
                        Divider()
                            .modifier(style.style())
                    }
                }
                TagsView()
                
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Sample")
                        .font(fonts.mediumBold.font)
                        .foregroundColor(colors.textPrimary)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .scrollContentBackground(.hidden)
            .background(colors.background)
        }
    }
}

// MARK: - Preview
struct ZenithSampleView_Previews: PreviewProvider {
    static var previews: some View {
        ZenithSampleView()
    }
}

struct TagsView: View {
    @State var isExpanded = false
    
    var body: some View {
            SectionView(title: "TAGS", isExpanded: $isExpanded) {
                ForEach(TagStyleCase.allCases) { style in
                    Tag("checkmark")
                        .tagStyle(style.style())
                }
            }
    }
}

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
