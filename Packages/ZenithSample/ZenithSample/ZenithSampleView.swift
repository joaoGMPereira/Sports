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
    
    var body: some View {
        NavigationView {
            List {
                Section(isExpanded: $imagesIsExpanded) {
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
                } header: {
                    Label(
                        title: {
                            Text("Images")
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
                Section(isExpanded: $buttonsIsExpanded) {
                    Button("Primary") {
                        print("caiu aqui")
                    }
                    .buttonStyle(.primary)
                    Button("Secondary") {
                        print("caiu aqui")
                    }
                    .buttonStyle(.secondary)
                } header: {
                    Label(
                        title: {
                            Text("Buttons")
                                .textStyle(.mediumBold(.primary))
                        },
                        icon: {
                            Image(systemSymbol: .chevronDown)
                                .rotationEffect(.init(degrees: buttonsIsExpanded ? 180 : 0))
                        })
                    .font(fonts.mediumBold.font)
                    .foregroundStyle(colors.textPrimary)
                    .animation(.smooth, value: buttonsIsExpanded)
                    .onTapGesture {
                        withAnimation {
                            buttonsIsExpanded.toggle()
                        }
                    }
                }
                .listRowBackground(colors.backgroundSecondary)
                Section(isExpanded: $textsIsExpanded) {
                    ForEach(TextStyleCase.allCases, id: \.self) { style in
                        Text("teste")
                            .modifier(style.modifier())
                    }
                } header: {
                    Label(
                        title: {
                            Text("Texts")
                                .textStyle(.mediumBold(.primary))
                        },
                        icon: {
                            Image(systemSymbol: .chevronDown)
                                .rotationEffect(.init(degrees: textsIsExpanded ? 180 : 0))
                        })
                    .font(fonts.mediumBold.font)
                    .foregroundStyle(colors.textPrimary)
                    .animation(.smooth, value: textsIsExpanded)
                    .onTapGesture {
                        withAnimation {
                            textsIsExpanded.toggle()
                        }
                    }
                }
                .listRowBackground(colors.backgroundSecondary)
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
