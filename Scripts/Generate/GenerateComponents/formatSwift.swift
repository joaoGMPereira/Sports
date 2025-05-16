import Foundation

/// Classe responsável por formatar arquivos Swift
/// Fornece múltiplas estratégias de formatação, incluindo ferramentas externas e AppleScript
public class SwiftFormatter {
    
    /// Enum para rastrear o resultado da formatação
    public enum FormatResult {
        case success(String)    // Formatação bem-sucedida com mensagem
        case failure(String)    // Falha na formatação com mensagem de erro
        
        public var isSuccess: Bool {
            switch self {
            case .success: return true
            case .failure: return false
            }
        }
        
        public var message: String {
            switch self {
            case .success(let message): return message
            case .failure(let error): return error
            }
        }
    }
    
    /// Opções de formatação disponíveis
    public struct FormatOptions {
        /// Define se deve usar AppleScript como última opção quando outras ferramentas falharem
        public var useAppleScriptFallback: Bool
        /// Define se deve usar o formatador interno básico quando ferramentas externas falharem
        public var useInternalFormatter: Bool
        /// Define nível de indentação para o formatador interno
        public var indentSize: Int
        
        public init(
            useAppleScriptFallback: Bool = true,
            useInternalFormatter: Bool = true,
            indentSize: Int = 4
        ) {
            self.useAppleScriptFallback = useAppleScriptFallback
            self.useInternalFormatter = useInternalFormatter
            self.indentSize = indentSize
        }
        
        /// Opções padrão
        public static let `default` = FormatOptions()
    }
    
    // MARK: - Propriedades
    
    /// Opções de formatação
    private let options: FormatOptions
    
    /// Função de log para registrar mensagens
    private let logger: (String, LogLevel) -> Void
    
    // MARK: - Inicialização
    
    /// Inicializa o formatador com opções personalizadas
    /// - Parameters:
    ///   - options: Opções de formatação
    ///   - logger: Função para registrar logs
    init(
        options: FormatOptions = .default,
        logger: @escaping (String, LogLevel) -> Void = { message, level in
            let prefix: String
            switch level {
            case .info: prefix = "INFO"
            case .warning: prefix = "WARNING"
            case .error: prefix = "ERROR"
            }
            print("\(prefix) - \(message)")
        }
    ) {
        self.options = options
        self.logger = logger
    }
    
    // MARK: - API Pública
    
    /// Formata um arquivo Swift no caminho especificado
    /// - Parameters:
    ///   - filePath: Caminho absoluto do arquivo a ser formatado
    ///   - spacingOptions: Opções de espaçamento para a formatação (padrão: .default)
    /// - Returns: Resultado da formatação
    public func formatFile(
        at filePath: String
    ) -> FormatResult {
        logger("Formatando arquivo: \(filePath)", .info)
        
        // Verificar se o arquivo existe
        if !FileManager.default.fileExists(atPath: filePath) {
            return .failure("Arquivo não encontrado: \(filePath)")
        }
        
        // Tentar formatar usando ferramentas externas
        if let result = tryExternalFormatters(for: filePath, indentSize: options.indentSize) {
            return result
        }
        
        // Tentar formatar usando AppleScript e Xcode
        if options.useAppleScriptFallback, let result = tryAppleScriptFormatter(for: filePath) {
            return result
        }
        
        return .failure("Não foi possível formatar o arquivo. Nenhum método de formatação disponível funcionou.")
    }
    
    // MARK: - Métodos Privados
    
    /// Tenta formatar o arquivo usando ferramentas externas como swift-format, swiftformat, etc.
    /// - Parameters:
    ///   - filePath: Caminho do arquivo
    ///   - indentSize: Tamanho da indentação desejada
    /// - Returns: Resultado da formatação ou nil se todas as ferramentas falharem
    private func tryExternalFormatters(for filePath: String, indentSize: Int = 4) -> FormatResult? {
        // 1. Tentar SwiftFormat (agora com --swiftversion 6.0.0)
        if let result = runFormatter(
            executable: "/usr/bin/env",
            arguments: ["swiftFormat", filePath, "--swiftversion", "6.0.0"],
            successMessage: "Arquivo formatado com sucesso usando SwiftFormat (Swift 6.0.0)"
        ) {
            return result
        }
        
        return nil
    }
    
    /// Executa uma ferramenta de formatação externa
    /// - Parameters:
    ///   - executable: Caminho do executável
    ///   - arguments: Argumentos para o comando
    ///   - successMessage: Mensagem a ser exibida em caso de sucesso
    /// - Returns: Resultado da formatação ou nil se falhar
    private func runFormatter(
        executable: String,
        arguments: [String],
        successMessage: String
    ) -> FormatResult? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments
        
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        
        do {
            try process.run()
            process.waitUntilExit()
            
            if process.terminationStatus == 0 {
                logger(successMessage, .info)
                return .success(successMessage)
            } else {
                let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                if let errorOutput = String(data: errorData, encoding: .utf8), !errorOutput.isEmpty {
                    logger("Erro ao executar \(arguments[0]): \(errorOutput)", .warning)
                }
            }
        } catch {
            logger("Falha ao executar \(arguments[0]): \(error.localizedDescription)", .warning)
        }
        
        return nil
    }
    
    /// Tenta formatar o arquivo usando AppleScript e o Xcode
    /// - Parameter filePath: Caminho do arquivo
    /// - Returns: Resultado da formatação ou nil se falhar
    private func tryAppleScriptFormatter(for filePath: String) -> FormatResult? {
        // Obter o caminho absoluto do arquivo
        let absoluteFilePath: String
        if filePath.starts(with: "/") {
            absoluteFilePath = filePath
        } else {
            if let currentPath = FileManager.default.currentDirectoryPath as String? {
                absoluteFilePath = currentPath + "/" + filePath
            } else {
                logger("Erro: Não foi possível determinar o caminho absoluto do arquivo", .error)
                return nil
            }
        }
        
        // Criar o AppleScript para formatar o arquivo no Xcode
        let scriptText = """
        tell application "Xcode"
            activate
            open "\(absoluteFilePath)"
            delay 1
            tell application "System Events"
                keystroke "a" using {command down}
                delay 0.5
                keystroke "i" using {control down}
            end tell
        end tell
        """
        
        // Executar o AppleScript
        let script = NSAppleScript(source: scriptText)
        var errorDict: NSDictionary? = nil
        let result = script?.executeAndReturnError(&errorDict)
        
        if let error = errorDict {
            logger("Erro ao executar o AppleScript: \(error)", .warning)
            return nil
        } else {
            let message = "Arquivo formatado com sucesso usando AppleScript e Xcode!"
            logger(message, .info)
            return .success(message)
        }
    }
}

// MARK: - Função auxiliar para uso via linha de comando

/// Função principal para uso do script via linha de comando
public func mainFormatSwift() {
    // Parse command line arguments
    if CommandLine.arguments.count < 2 {
        print("""
        Uso: \(CommandLine.arguments[0]) <caminho-do-arquivo>
        
        Este script formata um arquivo Swift usando várias estratégias:
        1. Ferramentas externas (swift-format, swiftformat, etc)
        2. Formatador interno básico
        3. AppleScript com Xcode (Cmd+A, Ctrl+I)
        """)
        exit(1)
    }
    
    // Obter o caminho do arquivo dos argumentos da linha de comando
    let filePath = CommandLine.arguments[1]
    
    // Criar o formatador e formatar o arquivo
    let formatter = SwiftFormatter()
    let result = formatter.formatFile(at: filePath)
    
    // Exibir o resultado
    switch result {
    case .success(let message):
        print("✓ \(message)")
        exit(0)
    case .failure(let error):
        print("✗ \(error)")
        exit(1)
    }
}

//// Executar a função principal apenas se este arquivo for executado diretamente
//if CommandLine.arguments[0].contains("formatSwift") {
//    mainFormatSwift()
//}
