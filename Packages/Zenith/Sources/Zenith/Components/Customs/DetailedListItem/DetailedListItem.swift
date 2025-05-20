import Dependencies
import SFSafeSymbols
import SwiftUI
import ZenithCoreInterface

public struct DetailedListItem: View {
    @Environment(\.detailedListItemStyle) private var style
    let configuration: DetailedListItemStyleConfiguration
    
    public init(
        title: String,
        description: String = String(),
        leftInfo: DetailedListItemInfo,
        rightInfo: DetailedListItemInfo,
        blurConfig: BlurConfig = .standard(),
        action: @escaping () -> Void
    ) {
        self.configuration = .init(
            title: title,
            description: description,
            leftInfo: leftInfo,
            rightInfo: rightInfo,
            action: action,
            blurConfig: blurConfig
        )
    }
    
    public init(
        _ configuration: DetailedListItemStyleConfiguration
    ) {
        self.configuration = configuration
    }
    
    public init<TrailingContent: View>(
        title: String,
        description: String = String(),
        leftInfo: DetailedListItemInfo,
        rightInfo: DetailedListItemInfo,
        blurConfig: BlurConfig = .standard(),
        action: @escaping () -> Void,
        @ViewBuilder trailingContent: () -> TrailingContent
    ) {
        self.configuration = .init(
            title: title,
            description: description,
            leftInfo: leftInfo,
            rightInfo: rightInfo,
            action: action,
            trailingContent: AnyView(trailingContent()),
            blurConfig: blurConfig
        )
    }
    
    public init(
        title: String,
        description: String = String(),
        leftInfo: DetailedListItemInfo,
        rightInfo: DetailedListItemInfo,
        action: @escaping () -> Void,
        progressText: String,
        blurConfig: BlurConfig = .standard()
    ) {
        self.configuration = .init(
            title: title,
            description: description,
            leftInfo: leftInfo,
            rightInfo: rightInfo,
            action: action,
            progressText: progressText,
            blurConfig: blurConfig
        )
    }
    
    public init(
        title: String,
        description: String = String(),
        leftInfo: DetailedListItemInfo,
        rightInfo: DetailedListItemInfo,
        action: @escaping () -> Void,
        progress: Double,
        size: CGFloat = 54,
        showText: Bool = true,
        animated: Bool = true,
        blurConfig: BlurConfig = .standard()
    ) {
        let config = CircularProgressStyleConfiguration(
            text: "",
            progress: progress,
            size: size,
            showText: showText,
            isAnimating: false,
            animated: animated
        )
        self.configuration = .init(
            title: title,
            description: description,
            leftInfo: leftInfo,
            rightInfo: rightInfo,
            action: action,
            progressConfig: config,
            blurConfig: blurConfig
        )
    }
    
    public init(
        title: String,
        description: String = String(),
        leftInfo: DetailedListItemInfo,
        rightInfo: DetailedListItemInfo,
        action: @escaping () -> Void,
        progressConfig: CircularProgressStyleConfiguration
    ) {
        self.configuration = .init(
            title: title,
            description: description,
            leftInfo: leftInfo,
            rightInfo: rightInfo,
            action: action,
            progressConfig: progressConfig
        )
    }
    
    // Inicializador com BlurConfig personalizado
    public init(
        title: String,
        description: String = String(),
        leftInfo: DetailedListItemInfo,
        rightInfo: DetailedListItemInfo,
        action: @escaping () -> Void,
        blurConfig: BlurConfig
    ) {
        self.configuration = .init(
            title: title,
            description: description,
            leftInfo: leftInfo,
            rightInfo: rightInfo,
            action: action,
            blurConfig: blurConfig
        )
    }
    
    // Inicializador com BlurConfig personalizado e progressConfig
    public init(
        title: String,
        description: String = String(),
        leftInfo: DetailedListItemInfo,
        rightInfo: DetailedListItemInfo,
        action: @escaping () -> Void,
        progressConfig: CircularProgressStyleConfiguration,
        blurConfig: BlurConfig
    ) {
        self.configuration = .init(
            title: title,
            description: description,
            leftInfo: leftInfo,
            rightInfo: rightInfo,
            action: action,
            progressConfig: progressConfig,
            blurConfig: blurConfig
        )
    }
    
    // Inicializador com BlurConfig personalizado e conteúdo trailing customizado
    public init<TrailingContent: View>(
        title: String,
        description: String = String(),
        leftInfo: DetailedListItemInfo,
        rightInfo: DetailedListItemInfo,
        action: @escaping () -> Void,
        blurConfig: BlurConfig,
        @ViewBuilder trailingContent: () -> TrailingContent
    ) {
        self.configuration = .init(
            title: title,
            description: description,
            leftInfo: leftInfo,
            rightInfo: rightInfo,
            action: action,
            trailingContent: AnyView(trailingContent()),
            blurConfig: blurConfig
        )
    }
    
    public var body: some View {
        AnyView(
            style.resolve(
                configuration: configuration
            )
        )
    }
}

public struct DetailedListItemInfo: Decodable {
    let title: String
    let description: String
    
    public init(title: String = "", description: String = "") {
        self.title = title
        self.description = description
    }
}
