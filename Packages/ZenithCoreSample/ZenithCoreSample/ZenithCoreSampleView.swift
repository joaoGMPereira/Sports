import SwiftUI
import ZenithCoreInterface

struct ZenithCoreSampleView: View {
    @Dependency(\.themeConfigurator) var themeConfigurator
    var fonts: any FontsProtocol {
        themeConfigurator.theme.fonts
    }
    var colors: any ColorsProtocol {
        themeConfigurator.theme.colors
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(
                    header: Text("Themes").font(fonts.bigBold.font).foregroundStyle(colors.contentA)
                ) {
                    ForEach(ThemeName.allCases) { theme in
                        Button(theme.rawValue) {
                            themeConfigurator.change(theme)
                        }
                        .font((fonts.small.font))
                        .tint(colors.contentA)
                    }
                }.listRowBackground(colors.backgroundB)
                Section(
                    header: Text("Fonts").font(fonts.bigBold.font).foregroundStyle(colors.contentA)
                ) {
                    FontExampleView()
                }.listRowBackground(colors.backgroundB)
                Section(
                    header: Text("Colors").font(fonts.bigBold.font).foregroundStyle(colors.contentA)
                ) {
                    ColorExampleView()
                }.listRowBackground(colors.backgroundB)
                Section(
                    header: Text("Spacing").font(fonts.bigBold.font).foregroundStyle(colors.contentA)
                ) {
                    SpacingExampleView()
                }.listRowBackground(colors.backgroundB)
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Sample")
                        .font(fonts.mediumBold.font)
                        .foregroundColor(colors.contentA)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .scrollContentBackground(.hidden)
            .background(colors.backgroundA)
        }
    }
}

// MARK: - Fonts Example
struct FontExampleView: View {
    @Dependency(\.themeConfigurator) var themeConfigurator
    var fonts: any FontsProtocol {
        themeConfigurator.theme.fonts
    }
    var colors: any ColorsProtocol {
        themeConfigurator.theme.colors
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(FontName.allCases, id: \.rawValue) { font in
                Text(font.rawValue)
                    .foregroundStyle(colors.contentA)
                    .font(fonts.font(by: font)?.font)
            }
        }
        .padding()
    }
}

// MARK: - Colors Example
struct ColorExampleView: View {
    @Dependency(\.themeConfigurator) var themeConfigurator
    var fonts: any FontsProtocol {
        themeConfigurator.theme.fonts
    }
    var colors: any ColorsProtocol {
        themeConfigurator.theme.colors
    }
    
    var body: some View {
        VStack {
            ForEach(ColorName.allCases, id: \.rawValue) { color in
                HStack {
                    Text(color.rawValue)
                        .foregroundStyle(colors.contentA)
                        .font(fonts.small.font)
                        .frame(width: 100, alignment: .leading)
                    RoundedRectangle(cornerRadius: 6)
                        .fill(colors.color(by: color) ?? .clear)
                        .frame(width: 40, height: 20)
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.black.opacity(0.1)))
                }
            }
        }
        .padding()
    }
}

// MARK: - Spacing Example
struct SpacingExampleView: View {
    @Dependency(\.themeConfigurator) var themeConfigurator
    var fonts: any FontsProtocol {
        themeConfigurator.theme.fonts
    }
    var colors: any ColorsProtocol {
        themeConfigurator.theme.colors
    }
    var spacings: any SpacingsProtocol {
        themeConfigurator.theme.spacings
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(SpacingName.allCases, id: \.rawValue) { spacing in
                HStack {
                    Text(spacing.rawValue)
                        .foregroundStyle(colors.contentA)
                        .frame(width: 100, alignment: .leading)
                    Rectangle()
                        .fill(colors.contentB)
                        .frame(width: spacings.spacing(by: spacing), height: 10)
                }
            }
        }
        .padding()
    }
}

// MARK: - Preview
struct ZenithCoreSampleView_Previews: PreviewProvider {
    static var previews: some View {
        ZenithCoreSampleView()
    }
}
