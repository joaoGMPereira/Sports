import Foundation
import SwiftUI

extension View {
    @inlinable func padding(
        top: CGFloat = 0,
        bottom: CGFloat = 0,
        leading: CGFloat = 0,
        trailing: CGFloat = 0
    ) -> some View {
        self.padding(EdgeInsets(top: top, leading: leading, bottom: bottom, trailing: trailing))
    }
    
    @inlinable func zeroPadding() -> some View { padding() }
}
