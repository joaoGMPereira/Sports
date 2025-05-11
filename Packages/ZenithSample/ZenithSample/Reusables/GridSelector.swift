import SwiftUI
import Zenith
import ZenithCoreInterface

/// A reusable component for item selection in a grid layout
/// `T` must be a type that is Identifiable, Hashable and CaseIterable
struct GridSelector<T: Identifiable & Hashable & CaseIterable>: View, @preconcurrency BaseThemeDependencies where T: RawRepresentable, T.RawValue == String {
    @Dependency(\.themeConfigurator) var themeConfigurator
    
    @Binding var selectedItem: T
    let title: String
    let columnsCount: Int
    let height: CGFloat
    let itemLabel: ((T) -> String)?
    
    init(
        title: String,
        selection: Binding<T>,
        columnsCount: Int = 2,
        height: CGFloat = 120,
        itemLabel: ((T) -> String)? = nil
    ) {
        self.title = title
        self._selectedItem = selection
        self.columnsCount = columnsCount
        self.height = height
        self.itemLabel = itemLabel
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .textStyle(.largeBold(.contentA))
                .padding(.horizontal)
            
            ScrollView(.vertical, showsIndicators: false) {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: columnsCount), spacing: 8) {
                    ForEach(Array(T.allCases) as! [T], id: \.self) { item in
                        itemButton(for: item)
                    }
                }
            }
            .frame(height: height)
        }
    }
    
    private func itemButton(for item: T) -> some View {
        let label = itemLabel?(item) ?? item.rawValue
        
        return Button(action: {
            selectedItem = item
        }) {
            Text(label)
                .font(fonts.small)
                .foregroundColor(selectedItem == item ? colors.highlightA : colors.contentA)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(selectedItem == item ? colors.highlightA.opacity(0.2) : colors.backgroundB)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(selectedItem == item ? colors.highlightA : colors.backgroundC, lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}