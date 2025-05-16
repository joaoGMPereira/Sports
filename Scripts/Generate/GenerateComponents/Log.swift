import Foundation

enum Log {
    case info, warning, error
    
    func log(_ message: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let timestamp = dateFormatter.string(from: Date())
        
        let prefix: String
        if IS_RUNNING_IN_XCODE {
            // Usar versão sem cores para o Xcode
            switch self {
            case .info:
                prefix = "INFO"
            case .warning:
                prefix = "WARNING"
            case .error:
                prefix = "ERROR"
            }
        } else {
            // Usar versão colorida para terminal
            switch self {
            case .info:
                prefix = "\u{001B}[32mINFO\u{001B}[0m" // Verde
            case .warning:
                prefix = "\u{001B}[33mWARNING\u{001B}[0m" // Amarelo
            case .error:
                prefix = "\u{001B}[31mERROR\u{001B}[0m" // Vermelho
            }
        }
        
        print("\(timestamp) - \(prefix) - \(message)")
    }
    
    static func log(_ message: String, level: Log = .info) {
        level.log(message)
    }
}

