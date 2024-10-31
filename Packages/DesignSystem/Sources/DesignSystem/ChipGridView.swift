import SwiftUI

public struct ChipGridView: View {
    // Lista de chips
    let chips: [String]
    let isSelectable: Bool
    @State var chipSelected: String?
    let onClick: (String) -> Void
    
    public init(chips: [String], isSelectable: Bool = false, onClick: @escaping (String) -> Void) {
        self.chips = chips
        self.isSelectable = isSelectable
        self.onClick = onClick
    }
    
    public var body: some View {
        ScrollView {
            Grid(alignment: .leading, horizontalSpacing: 8, verticalSpacing: 8) {
                ForEach(chips.divided(into: 3), id: \.self) { chipsPart in
                    GridRow {
                        ForEach(chipsPart, id: \.self) { chip in
                            ChipView(label: chip, isSelected: chipSelected == chip)
                                .onTapGesture {
                                    if isSelectable {
                                        chipSelected = chip == chipSelected ? nil : chip
                                    } else {
                                        chipSelected = chip
                                    }
                                    onClick(chipSelected ?? String())
                                }
                        }
                    }
                }
            }
        }
    }
}

struct ChipView: View {
    var label: String
    var isSelected: Bool
    
    var body: some View {
        Text(label)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Asset.primary.swiftUIColor.opacity(0.6) : Asset.primary.swiftUIColor.opacity(0.2))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Asset.primary.swiftUIColor, lineWidth: 1)
            )
            .foregroundColor(Asset.primary.swiftUIColor)
            .padding(2)
    }
}
