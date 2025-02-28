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
    
    fileprivate func section(
        title: String,
        isExpanded: Binding<Bool>,
        @ViewBuilder content: () -> some View
    ) -> some View {
        return Section(isExpanded: isExpanded) {
            content()
        } header: {
            Label(
                title: {
                    Text(title)
                        .textStyle(.mediumBold(.primary))
                },
                icon: {
                    Image(systemSymbol: .chevronDown)
                        .rotationEffect(.init(degrees: imagesIsExpanded ? 180 : 0))
                })
            .font(fonts.mediumBold.font)
            .foregroundStyle(colors.textPrimary)
            .animation(.smooth, value: imagesIsExpanded)
            .onTapGesture {
                withAnimation {
                    imagesIsExpanded.toggle()
                }
            }
        }
        .listRowBackground(colors.backgroundSecondary)
    }
    
    var body: some View {
        NavigationView {
            List {
                section(title: "IMAGES", isExpanded: $imagesIsExpanded) {
                    ForEach(DynamicImageStyleColor.allCases, id: \.self) { style in
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
                section(title: "BUTTONS", isExpanded: $buttonsIsExpanded) {
                    Button("Primary") {
                        print("caiu aqui")
                    }
                    .buttonStyle(.primary)
                    Button("Secondary") {
                        print("caiu aqui")
                    }
                    .buttonStyle(.secondary)
                }
                
                section(title: "TEXTS", isExpanded: $textsIsExpanded) {
                    ForEach(TextStyleCase.allCases, id: \.self) { style in
                        Text("teste")
                            .modifier(style.modifier())
                    }
                }
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
