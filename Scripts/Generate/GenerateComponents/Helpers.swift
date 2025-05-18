import Foundation


/**
 Script para gerar arquivos Sample para componentes do Zenith
 Este script analisa arquivos View, Configuration e Styles de um componente
 e gera automaticamente um arquivo Sample para demonstrar o uso do componente.
 */

// MARK: - Constantes e configurações

let homeDir = FileManager.default.homeDirectoryForCurrentUser.path
let CLEAN_PACKAGES_DIR = false // Define se deve limpar mudanças no diretório de pacotes
let CHECKOUT_REPO = false // Define se deve fazer checkout do repositório antes de executar
let ZENITH_PATH = "\(homeDir)/KettleGym/Packages/Zenith"
let ZENITH_SAMPLE_PATH = "\(homeDir)/KettleGym/Packages/ZenithSample"
let COMPONENTS_PATH = "\(ZENITH_PATH)/Sources/Zenith"
let SAMPLES_PATH = "\(ZENITH_SAMPLE_PATH)/ZenithSample"
let TESTS_PATH = "\(ZENITH_PATH)/Tests/ZenithTests"

let INDENT_SIZE = 4
let GENERATE_TESTS = false // Por padrão, não gera testes

// Detectar se estamos executando em modo debug no Xcode
// Isso permitirá desabilitar os códigos de cores ANSI que não funcionam no console do Xcode
#if DEBUG
let IS_RUNNING_IN_XCODE = true
#else
let IS_RUNNING_IN_XCODE = ProcessInfo.processInfo.environment["XPC_SERVICE_NAME"]?.contains("com.apple.dt.Xcode") ?? false
#endif

// MARK: - UI e Interação com Usuário


func clearConsole() {
    // ANSI escape code para limpar a tela
    if IS_RUNNING_IN_XCODE == false {
        print("\u{001B}[2J\u{001B}[H", terminator: "")
    }
}

func pauseForAction() {
    print("\nPressione ENTER para continuar...", terminator: "")
    _ = readLine()
}


struct ConsoleUI {
    // ANSI Color Codes - serão usados apenas quando não estiver no Xcode
    static let reset = IS_RUNNING_IN_XCODE ? "" : "\u{001B}[0m"
    static let bold = IS_RUNNING_IN_XCODE ? "" : "\u{001B}[1m"
    static let red = IS_RUNNING_IN_XCODE ? "" : "\u{001B}[31m"
    static let green = IS_RUNNING_IN_XCODE ? "" : "\u{001B}[32m"
    static let yellow = IS_RUNNING_IN_XCODE ? "" : "\u{001B}[33m"
    static let blue = IS_RUNNING_IN_XCODE ? "" : "\u{001B}[34m"
    static let magenta = IS_RUNNING_IN_XCODE ? "" : "\u{001B}[35m"
    static let cyan = IS_RUNNING_IN_XCODE ? "" : "\u{001B}[36m"
    
    static func printTitle(_ title: String) {
        let line = String(repeating: "=", count: title.count + 4)
        print("\n\(bold)\(blue)\(line)\(reset)")
        print("\(bold)\(blue)| \(title) |\(reset)")
        print("\(bold)\(blue)\(line)\(reset)\n")
    }
    
    static func printOption(_ index: Int, _ text: String) {
        print("\(yellow)[\(index)]\(reset) \(text)")
    }
    
    static func printSuccess(_ message: String) {
        print("\(green)✓ \(message)\(reset)")
    }
    
    static func printError(_ message: String) {
        print("\(red)✗ \(message)\(reset)")
    }
    
    static func printInfo(_ message: String) {
        print("\(cyan)ℹ \(message)\(reset)")
    }
    
    static func promptForInput(_ prompt: String) -> String {
        print("\(prompt): ", terminator: "")
        return readLine() ?? ""
    }
    
    static func promptForChoice(_ prompt: String, options: [String]) -> Int {
        print(prompt)
        for (index, option) in options.enumerated() {
            printOption(index + 1, option)
        }
        
        while true {
            let input = promptForInput("Escolha uma opção (1-\(options.count))")
            if let choice = Int(input), choice >= 1, choice <= options.count {
                return choice
            }
            printError("Opção inválida. Tente novamente.")
        }
    }
}

// MARK: - Funções utilitárias

// Função para fazer checkout do repositório
func checkoutRepositoryIfNeeded() {
    if CHECKOUT_REPO {
        let repoDir = "\(homeDir)/KettleGym"
        
        Log.log("Executando checkout do repositório em: \(repoDir)", level: .info)
        
        do {
            // Executa git checkout . no diretório raiz
            let process = Process()
            process.currentDirectoryURL = URL(fileURLWithPath: repoDir)
            process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
            process.arguments = ["checkout", "Packages/"]
            
            try process.run()
            process.waitUntilExit()
        } catch {
            Log.log("Erro ao fazer checkout do repositório: \(error.localizedDescription)", level: .error)
        }
    }
}
