import SwiftUI
import ZenithCoreInterface

public struct ChipGridView: View {
    // Lista de chips
    @Binding var chips: [String]
    let isSelectable: Bool
    @EquatableBinding
    @Binding var chipSelected: String?
    @State private var internalChipSelected: String? = nil
    let onClick: (String) -> Void
    let onRemove: ((String) -> Void)?
    static let internalStateKey = "internalStateKey"
    let internalState = EquatableBinding<String?>(wrappedValue: .constant(Self.internalStateKey))

    public init(
        chips: Binding<[String]>,
        isSelectable: Bool = false,
        onRemove: ((String) -> Void)? = nil,
        onClick: @escaping (String) -> Void
    ) {
        self._chips = chips
        self._chipSelected = .init(wrappedValue: .constant(Self.internalStateKey))
        self.isSelectable = isSelectable
        self.onRemove = onRemove
        self.onClick = onClick
    }
    
    public init(
        chips: Binding<[String]>,
        chipSelected: Binding<String?>,
        isSelectable: Bool = false,
        onRemove: ((String) -> Void)? = nil,
        onClick: @escaping (String) -> Void
    ) {
        self._chips = chips
        self._chipSelected = .init(wrappedValue: chipSelected)
        self.isSelectable = isSelectable
        self.onRemove = onRemove
        self.onClick = onClick
    }

    // Computed property to determine if the internal state should be used
    private var selectedChip: String? {
        _chipSelected == internalState ? internalChipSelected : chipSelected
    }

    public var body: some View {
        ScrollView {
            Grid(alignment: .leading, horizontalSpacing: 8, verticalSpacing: 8) {
                ForEach(chips.divided(into: 3), id: \.self) { chipsPart in
                    GridRow {
                        ForEach(chipsPart, id: \.self) { chip in
                            ChipView(label: chip, isSelected: selectedChip == chip, onRemove: onRemove)
                                .onTapGesture {
                                    if isSelectable {
                                        updateSelectedChip(chip)
                                    } else {
                                        updateSelectedChip(chip)
                                    }
                                    onClick(selectedChip ?? "")
                                }
                        }
                    }
                }
            }
        }
    }

    private func updateSelectedChip(_ chip: String) {
        if _chipSelected == internalState {
            internalChipSelected = chip == internalChipSelected ? nil : chip
        } else {
            chipSelected = chip == chipSelected ? nil : chip
        }
    }
}

public enum ChipStyle {
    case normal
    case small
    
    var font: Font {
        self == .normal ? .body : .footnote
    }
    
    var horizontalPadding: CGFloat {
        self == .normal ? 12 : 8
    }
    
    var verticalPadding: CGFloat {
        self == .normal ? 8 : 4
    }
    
    var corner: CGFloat {
        self == .normal ? 20 : 10
    }
}

public struct ChipView: View {
    var label: String
    var isSelected: Bool
    var style: ChipStyle
    var onRemove: ((String) -> Void)?
    
    public init(
        label: String,
        isSelected: Bool,
        style: ChipStyle = .normal,
        onRemove: ((String) -> Void)? = nil
    ) {
        self.label = label
        self.isSelected = isSelected
        self.style = style
        self.onRemove = onRemove
    }
    
    public var body: some View {
        HStack(spacing: 2) {
            Text(label)
                .font(style.font)
            if let onRemove {
                Image(systemName: "xmark")
                    .font(.footnote)
                    .onTapGesture {
                        onRemove(label)
                    }
            }
        }
        .padding(.horizontal, style.horizontalPadding)
        .padding(.vertical, style.verticalPadding)
        .background(isSelected ? .purple.opacity(0.6) : .purple.opacity(0.2))
        .cornerRadius(style.corner)
        .overlay(
            RoundedRectangle(cornerRadius: style.corner)
                .stroke(.purple, lineWidth: 1)
        )
        .foregroundColor(.purple)
        .padding(2)
    }
}
