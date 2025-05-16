import Foundation

enum Log {
    case info, warning, error, success
    
    // Cores para Xcode baseadas no artigo do Medium
    private struct XcodeColors {
        // emoji + método para colorir
        static let reset = "💠"     // Emoji para identificar reset
        static let black = "⚫️"     // Preto
        static let red = "🔴"      // Vermelho
        static let green = "🟢"    // Verde
        static let yellow = "🟡"   // Amarelo
        static let blue = "🔵"     // Azul
        static let magenta = "🟣"  // Magenta
        static let cyan = "🟡"     // Ciano
        static let white = "⚪️"     // Branco
        
        // Formatar texto com cores para Xcode
        static func colorize(_ text: String, with color: String) -> String {
            return "\(color) \(text) \(reset)"
        }
    }
    
    // Cores para Terminal
    private struct TerminalColors {
        static let reset = "\u{001B}[0m"
        static let black = "\u{001B}[30m"
        static let red = "\u{001B}[31m"
        static let green = "\u{001B}[32m"
        static let yellow = "\u{001B}[33m"
        static let blue = "\u{001B}[34m"
        static let magenta = "\u{001B}[35m"
        static let cyan = "\u{001B}[36m"
        static let white = "\u{001B}[37m"
        
        // Formatar texto com cores para Terminal
        static func colorize(_ text: String, with color: String) -> String {
            return "\(color)\(text)\(reset)"
        }
    }
    
    func log(_ message: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let timestamp = dateFormatter.string(from: Date())
        
        var prefix: String
        var formattedMessage: String
        
        if IS_RUNNING_IN_XCODE {
            // Versão colorida para Xcode usando emojis
            switch self {
            case .info:
                prefix = XcodeColors.colorize("INFO", with: XcodeColors.blue)
                formattedMessage = message
            case .warning:
                prefix = XcodeColors.colorize("WARNING", with: XcodeColors.yellow)
                formattedMessage = XcodeColors.colorize(message, with: XcodeColors.yellow)
            case .error:
                prefix = XcodeColors.colorize("ERROR", with: XcodeColors.red)
                formattedMessage = XcodeColors.colorize(message, with: XcodeColors.red)
            case .success:
                prefix = XcodeColors.colorize("SUCCESS", with: XcodeColors.green)
                formattedMessage = XcodeColors.colorize(message, with: XcodeColors.green)
            }
        } else {
            // Versão colorida para terminal usando códigos ANSI
            switch self {
            case .info:
                prefix = TerminalColors.colorize("INFO", with: TerminalColors.blue)
                formattedMessage = message
            case .warning:
                prefix = TerminalColors.colorize("WARNING", with: TerminalColors.yellow)
                formattedMessage = TerminalColors.colorize(message, with: TerminalColors.yellow)
            case .error:
                prefix = TerminalColors.colorize("ERROR", with: TerminalColors.red)
                formattedMessage = TerminalColors.colorize(message, with: TerminalColors.red)
            case .success:
                prefix = TerminalColors.colorize("SUCCESS", with: TerminalColors.green)
                formattedMessage = TerminalColors.colorize(message, with: TerminalColors.green)
            }
        }
        
        print("\(timestamp) - \(prefix) - \(formattedMessage)")
    }
    
    static func log(_ message: String, level: Log = .info) {
        level.log(message)
    }
}

