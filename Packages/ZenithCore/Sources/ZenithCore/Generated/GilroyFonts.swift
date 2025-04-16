// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import UIKit.UIFont
import SwiftUI

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Fonts

// swiftlint:disable identifier_name line_length type_body_length
public enum FontFamily {
    public enum Gilroy {
        public static let regular = FontConvertible(name: "Gilroy-Regular", family: "Gilroy-Regular", path: "Gilroy-Regular.ttf")
        public static let medium = FontConvertible(name: "Gilroy-Medium", family: "Gilroy-Medium", path: "Gilroy-Medium.ttf")
        public static let semibold = FontConvertible(name: "Gilroy-Semibold", family: "Gilroy-Semibold", path: "Gilroy-SemiBold.ttf")
        public static let all: [FontConvertible] = [regular, medium, semibold]
    }
    public static let allCustomFonts: [FontConvertible] = [Gilroy.all].flatMap { $0 }
    public static func registerAllCustomFonts() {
        allCustomFonts.forEach { $0.register() }
    }
}
// swiftlint:enable identifier_name line_length type_body_length

// MARK: - Implementation Details

public struct FontConvertible : Sendable {
    public let name: String
    public let family: String
    public let path: String
    
    public typealias Font = UIFont
    
    public func font(size: CGFloat) -> Font {
        guard let font = Font(font: self, size: size) else {
            fatalError("Unable to initialize font '\(name)' (\(family))")
        }
        return font
    }
    
    @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
    public func swiftUIFont(size: CGFloat) -> SwiftUI.Font {
        return SwiftUI.Font.custom(self, size: size)
    }
    
    @available(iOS 14.0, tvOS 14.0, watchOS 7.0, macOS 11.0, *)
    public func swiftUIFont(fixedSize: CGFloat) -> SwiftUI.Font {
        return SwiftUI.Font.custom(self, fixedSize: fixedSize)
    }
    
    @available(iOS 14.0, tvOS 14.0, watchOS 7.0, macOS 11.0, *)
    public func swiftUIFont(size: CGFloat, relativeTo textStyle: SwiftUI.Font.TextStyle) -> SwiftUI.Font {
        return SwiftUI.Font.custom(self, size: size, relativeTo: textStyle)
    }
    
    public func register() {
        // swiftlint:disable:next conditional_returns_on_newline
        guard let url = url else { return }
        CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
    }
    
    fileprivate func registerIfNeeded() {
        if !UIFont.fontNames(forFamilyName: family).contains(name) {
            register()
        }
    }
    
    fileprivate var url: URL? {
        // swiftlint:disable:next implicit_return
        return BundleToken.bundle.url(forResource: path, withExtension: nil)
    }
}

public extension FontConvertible.Font {
    convenience init?(font: FontConvertible, size: CGFloat) {
        font.registerIfNeeded()
        self.init(name: font.name, size: size)
    }
}

@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
public extension SwiftUI.Font {
    static func custom(_ font: FontConvertible, size: CGFloat) -> SwiftUI.Font {
        font.registerIfNeeded()
        return custom(font.name, size: size)
    }
}

@available(iOS 14.0, tvOS 14.0, watchOS 7.0, macOS 11.0, *)
public extension SwiftUI.Font {
    static func custom(_ font: FontConvertible, fixedSize: CGFloat) -> SwiftUI.Font {
        font.registerIfNeeded()
        return custom(font.name, fixedSize: fixedSize)
    }
    
    static func custom(
        _ font: FontConvertible,
        size: CGFloat,
        relativeTo textStyle: SwiftUI.Font.TextStyle
    ) -> SwiftUI.Font {
        font.registerIfNeeded()
        return custom(font.name, size: size, relativeTo: textStyle)
    }
}

// swiftlint:disable convenience_type
private final class BundleToken {
    static let bundle: Bundle = {
#if SWIFT_PACKAGE
        return Bundle.module
#else
        return Bundle(for: BundleToken.self)
#endif
    }()
}
// swiftlint:enable convenience_type
