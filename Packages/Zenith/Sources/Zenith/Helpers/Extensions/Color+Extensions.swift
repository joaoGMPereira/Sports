import SwiftUI

extension Color {
    func darker(amount: Double = 0.2) -> Color {
        Color(uiColor: UIColor(self).darker(by: amount))
    }
}

extension UIColor {
    func darker(by percentage: Double = 0.2) -> UIColor {
        return adjustBrightness(by: -abs(percentage))
    }

    private func adjustBrightness(by percentage: Double) -> UIColor {
        var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, alpha: CGFloat = 0
        guard getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) else { return self }
        return UIColor(hue: hue, saturation: saturation, brightness: max(brightness + CGFloat(percentage), 0), alpha: alpha)
    }
}
