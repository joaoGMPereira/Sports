import SwiftUI

public enum StackArrangementCase: String, Decodable, CaseIterable, Equatable {
    case verticalCenter
    case verticalLeading
    case horizontalCenter
    case horizontalTop
    
    func style() -> StackArrangement {
        switch self {
        case .verticalCenter:
            .vertical(alignment: .center)
        case .verticalLeading:
            .vertical(alignment: .leading)
        case .horizontalCenter:
            .horizontal(alignment: .center)
        case .horizontalTop:
            .horizontal(alignment: .top)
        }
    }
    
    func alignment() -> Alignment {
        switch self {
        case .verticalCenter:
            .center
        case .verticalLeading:
            .leading
        case .horizontalCenter:
            .leading
        case .horizontalTop:
            .top
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

struct Stack<Content: View>: View {
    let arrangement: StackArrangement
    let spacing: CGFloat?
    let content: Content
    init(
        arrangement: StackArrangement,
        
        spacing: CGFloat? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.arrangement = arrangement
        self.spacing = spacing
        self.content = content()
    }
    var body: some View {
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
