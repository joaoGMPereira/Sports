import SwiftUI

struct CustomizedNavigationLink<Value: Hashable>: View {
    let value: Value
    let labelView: AnyView?
    let label: String?
    let hasArrow: Bool
    
    init(value: Value, label: AnyView) {
        self.value = value
        self.labelView = label
        self.label = nil
        self.hasArrow = false
    }
    
    init(value: Value, label: String, hasArrow: Bool = true) {
        self.value = value
        self.labelView = nil
        self.label = label
        self.hasArrow = hasArrow
    }
    
    var view: some View {
        return Group {
            if let labelView = self.labelView {
                labelView
            } else {
                HStack {
                    Text(label ?? String())
                    Spacer()
                    if hasArrow {
                        Image(systemName: "chevron.right")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 7)
                            .foregroundColor(Asset.primary.swiftUIColor)
                    }
                }
            }
        }
    }
    var body: some View {
        ZStack {
            NavigationLink(state: value) { EmptyView() }
            view
        }
    }
}
