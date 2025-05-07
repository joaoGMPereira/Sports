final class ThemeConfiguratorSpy: ThemeConfiguratorProtocol {
    var theme: Theme = Theme(
        name: .dark,
        colors: ColorsMock(),
        fonts: FontsMock(),
        spacings: SpacingsMock(),
        constants: ConstantsMock()
    )
    
    public private(set) var messages: [Message] = []
    
    enum Message: Equatable {
        case changeThemeName(_ theme: ThemeName)
    }
    
    func change(_ theme: ThemeName) {
        self.theme = Theme(
            name: theme,
            colors: ColorsMock(),
            fonts: FontsMock(),
            spacings: SpacingsMock(),
            constants: ConstantsMock()
        )
        messages.append(.changeThemeName(theme))
    }
}
