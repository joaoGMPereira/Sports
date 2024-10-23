import SwiftUI

public struct DSFillButton: View {
    var title: String
    var color: Color
    var isEnabled: Bool
    var callback: () -> Void
    
    public init(title: String, isEnabled: Bool = true, color: Color = Asset.primary.swiftUIColor, callback: @escaping () -> Void) {
        self.title = title
        self.isEnabled = isEnabled
        self.color = color
        self.callback = callback
    }
    
    public var body: some View {
        Button(action: {
            if isEnabled {
                callback()
            }
        })
        {
            Text(title)
                .frame(maxWidth: .infinity) // Define a largura máxima
                .cornerRadius(8)
        }
        .buttonStyle(FillButtonStyle(color: color, isEnabled: isEnabled))
    }
}

public struct DSContentButton: View {
    var title: String
    var isEnabled: Bool
    var color: Color
    var horizontalPadding: CGFloat
    var verticalPadding: CGFloat
    var callback: () -> Void
     
    public init(
        title: String,
        isEnabled: Bool = true,
        color: Color = Asset.primary.swiftUIColor,
        horizontalPadding: CGFloat = 8,
        verticalPadding: CGFloat = 8,
        callback: @escaping () -> Void
    ) {
        self.title = title
        self.isEnabled = isEnabled
        self.color = color
        self.horizontalPadding = horizontalPadding
        self.verticalPadding = verticalPadding
        self.callback = callback
    }
    
    public var body: some View {
        Button(action: {
            if isEnabled {
                callback()
            }
        })
        {
            Text(title)
                .padding(.horizontal, horizontalPadding)
                .padding(.vertical, verticalPadding)
                .cornerRadius(8)
        }
        .buttonStyle(ContentButtonStyle(color: color, isEnabled: isEnabled))
    }
}


public struct DSBorderedButton: View {
    var title: String
    var isEnabled: Bool
    var color: Color
    var horizontalPadding: CGFloat
    var verticalPadding: CGFloat
    var callback: () -> Void
     
    public init(
        title: String,
        isEnabled: Bool = true,
        color: Color = Asset.primary.swiftUIColor,
        horizontalPadding: CGFloat = 8,
        verticalPadding: CGFloat = 8,
        callback: @escaping () -> Void
    ) {
        self.title = title
        self.isEnabled = isEnabled
        self.color = color
        self.horizontalPadding = horizontalPadding
        self.verticalPadding = verticalPadding
        self.callback = callback
    }
    
    public var body: some View {
        Button(action: {
            if isEnabled {
                callback()
            }
        })
        {
            Text(title)
                .padding(.horizontal, horizontalPadding)
                .padding(.vertical, verticalPadding)
                .cornerRadius(8)
        }
        .buttonStyle(DSBorderedButtonStyle(color: color, isEnabled: isEnabled))
    }
}
