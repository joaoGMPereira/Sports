import SwiftUI

public struct DSFillButton: View {
    var title: String
    var color: Color
    var isEnabled: Bool
    var completion: () -> Void
    
    public init(title: String, isEnabled: Bool = true, color: Color = .purple, completion: @escaping () -> Void) {
        self.title = title
        self.isEnabled = isEnabled
        self.color = color
        self.completion = completion
    }
    
    public var body: some View {
        Button(action: {
            if isEnabled {
                completion()
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
    var completion: () -> Void
     
    public init(
        title: String,
        isEnabled: Bool = true,
        color: Color = .purple,
        horizontalPadding: CGFloat = 8,
        verticalPadding: CGFloat = 8,
        completion: @escaping () -> Void
    ) {
        self.title = title
        self.isEnabled = isEnabled
        self.color = color
        self.horizontalPadding = horizontalPadding
        self.verticalPadding = verticalPadding
        self.completion = completion
    }
    
    public var body: some View {
        Button(action: {
            if isEnabled {
                completion()
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
    var maxWidth: Bool
    var color: Color
    var horizontalPadding: CGFloat
    var verticalPadding: CGFloat
    var completion: () -> Void
     
    public init(
        title: String,
        isEnabled: Bool = true,
        maxWidth: Bool = false,
        color: Color = .purple,
        horizontalPadding: CGFloat = 8,
        verticalPadding: CGFloat = 8,
        completion: @escaping () -> Void
    ) {
        self.title = title
        self.maxWidth = maxWidth
        self.isEnabled = isEnabled
        self.color = color
        self.horizontalPadding = horizontalPadding
        self.verticalPadding = verticalPadding
        self.completion = completion
    }
    
    public var body: some View {
        Button(action: {
            if isEnabled {
                completion()
            }
        })
        {
            Text(title)
                .applyIf(maxWidth, apply: {
                    $0.frame(maxWidth: .infinity)
                })
                .padding(.horizontal, horizontalPadding)
                .padding(.vertical, verticalPadding)
                .cornerRadius(8)
        }
        .buttonStyle(DSBorderedButtonStyle(color: color, isEnabled: isEnabled))
    }
}
