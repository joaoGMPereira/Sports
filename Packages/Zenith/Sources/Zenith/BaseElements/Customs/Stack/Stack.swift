import SwiftUI

public enum StackArrangementCase: String, Decodable, CaseIterable, Equatable {
    case verticalCenter
    case verticalLeading
    case horizontalCenter
    case horizontalLeading
    
    func arrangement() -> StackArrangement {
        switch self {
        case .verticalCenter:
            .vertical(alignment: .center)
        case .verticalLeading:
            .vertical(alignment: .leading)
        case .horizontalCenter:
            .horizontal(alignment: .center)
        case .horizontalLeading:
            .horizontal(alignment: .center)
        }
    }
    
    func alignment() -> Alignment {
        switch self {
        case .verticalCenter:
            .center
        case .verticalLeading:
            .leading
        case .horizontalCenter:
            .center
        case .horizontalLeading:
            .leading
        }
    }
}

public enum StackArrangement: @preconcurrency CaseIterable, Equatable {
    @MainActor
    public static let allCases: [StackArrangement] = [
        .vertical(alignment: .center),
        .vertical(alignment: .leading),
        .vertical(alignment: .listRowSeparatorLeading),
        .vertical(alignment: .listRowSeparatorTrailing),
        .vertical(alignment: .trailing),
        .horizontal(alignment: .center),
        .horizontal(alignment: .bottom),
        .horizontal(alignment: .firstTextBaseline),
        .horizontal(alignment: .lastTextBaseline),
        .horizontal(alignment: .top)
    ]
    
    case vertical(alignment: HorizontalAlignment = .center)
    case horizontal(alignment: VerticalAlignment = .center)
}

public struct Stack<Content: View>: View {
    let arrangement: StackArrangement
    let spacing: CGFloat?
    let content: Content
    
    public init(
        arrangement: StackArrangement,
        spacing: CGFloat? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.arrangement = arrangement
        self.spacing = spacing
        self.content = content()
    }
    
    public var body: some View {
        Group {
            switch arrangement {
            case let .vertical(alignment):
                VStack(alignment: alignment, spacing: spacing) {
                    content
                }
            case let .horizontal(alignment):
                HStack(alignment: alignment, spacing: spacing) {
                    content
                }
            }
        }
    }
}
