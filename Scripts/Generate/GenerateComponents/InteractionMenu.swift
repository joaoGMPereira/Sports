import Foundation

final class InteractionMenu {
    
    func mainMenu(exitCompletion: (() -> Void)) {
        clearConsole()
        ConsoleUI.printTitle("KettleGym - Gerador de Componentes Zenith")
        
        let options = [
            "Gerar Sample para um componente específico",
            "Listar componentes disponíveis",
            "Gerar Samples para todos os componentes nativos",
            "Gerar Sample para componente personalizado",
            "Sair"
        ]
        
        let choice = ConsoleUI.promptForChoice("Escolha uma opção:", options: options)
        
        switch choice {
        case 1:
            componentSelectionMenu(exitCompletion: exitCompletion)
        case 2:
            listAvailableComponents(exitCompletion: exitCompletion)
        case 3:
            generateAllNativeComponentSamples(exitCompletion: exitCompletion)
        case 4:
            createCustomComponentSample(exitCompletion: exitCompletion)
        case 5:
            print("Saindo do programa.")
            exitCompletion()
        default:
            ConsoleUI.printError("Opção inválida.")
            mainMenu(exitCompletion: exitCompletion)
        }
    }
    
    func componentSelectionMenu(exitCompletion: (() -> Void)) {
        clearConsole()
        ConsoleUI.printTitle("Selecionar Componente")
        
        let components = findAvailableComponents()
        let paginationSize = 10
        var page = 0
        let totalPages = (components.count - 1) / paginationSize + 1
        
        while true {
            clearConsole()
            ConsoleUI.printTitle("Selecionar Componente (Página \(page + 1) de \(totalPages))")
            
            let startIndex = page * paginationSize
            let endIndex = min(startIndex + paginationSize, components.count)
            
            for i in startIndex..<endIndex {
                ConsoleUI.printOption(i - startIndex + 1, components[i])
            }
            
            print("\n\(ConsoleUI.yellow)[N]\(ConsoleUI.reset) Próxima página")
            print("\(ConsoleUI.yellow)[P]\(ConsoleUI.reset) Página anterior")
            print("\(ConsoleUI.yellow)[V]\(ConsoleUI.reset) Voltar ao menu principal")
            
            let input = ConsoleUI.promptForInput("Escolha um componente ou uma opção")
            
            if input.lowercased() == "n" {
                page = (page + 1) % totalPages
            } else if input.lowercased() == "p" {
                page = (page - 1 + totalPages) % totalPages
            } else if input.lowercased() == "v" {
                mainMenu(exitCompletion: exitCompletion)
                return
            } else if let choice = Int(input), choice >= 1, choice <= endIndex - startIndex {
                let selectedComponent = components[startIndex + choice - 1]
                processComponent(selectedComponent, exitCompletion: exitCompletion)
                return
            } else {
                ConsoleUI.printError("Opção inválida.")
                pauseForAction()
            }
        }
    }
    
    func listAvailableComponents(exitCompletion: (() -> Void)) {
        clearConsole()
        ConsoleUI.printTitle("Componentes Disponíveis")
        
        let components = findAvailableComponents()
        
        if components.isEmpty {
            ConsoleUI.printInfo("Nenhum componente encontrado.")
        } else {
            // Criar colunas para melhor visualização
            let columnsCount = 3
            let rows = (components.count + columnsCount - 1) / columnsCount
            
            for row in 0..<rows {
                var rowOutput = ""
                for col in 0..<columnsCount {
                    let index = row + col * rows
                    if index < components.count {
                        let component = components[index]
                        // Padronizar tamanho para alinhamento em colunas
                        let paddedComponent = component.padding(toLength: 25, withPad: " ", startingAt: 0)
                        rowOutput += paddedComponent
                    }
                }
                print(rowOutput)
            }
        }
        
        pauseForAction()
        mainMenu(exitCompletion: exitCompletion)
    }
    
    func findAvailableComponents() -> [String] {
        var components: [String] = []
        
        // 1. Procurar componentes nativos
        components.append(contentsOf: Array(NATIVE_COMPONENTS.keys).sorted())
        
        // 2. Procurar componentes customizados
        do {
            // BaseElements/Natives
            if let entries = try? FileManager.default.contentsOfDirectory(atPath: "\(COMPONENTS_PATH)/BaseElements/Natives") {
                for entry in entries {
                    if !entry.hasPrefix(".") && !components.contains(entry) {
                        components.append(entry)
                    }
                }
            }
            
            // Components/Customs
            if let entries = try? FileManager.default.contentsOfDirectory(atPath: "\(COMPONENTS_PATH)/Components/Customs") {
                for entry in entries {
                    if !entry.hasPrefix(".") && !components.contains(entry) {
                        components.append(entry)
                    }
                }
            }
        }
        
        return components.sorted()
    }
    
    func generateAllNativeComponentSamples(exitCompletion: (() -> Void)) {
        clearConsole()
        ConsoleUI.printTitle("Gerando Samples para Componentes Nativos")
        
        let nativeComponents = Array(NATIVE_COMPONENTS.keys).sorted()
        var success = 0
        var failure = 0
        
        for component in nativeComponents {
            ConsoleUI.printInfo("Processando: \(component)")
            let result = createSampleFile(for: component)
            if result {
                ConsoleUI.printSuccess("Sample gerado com sucesso para: \(component)")
                success += 1
            } else {
                ConsoleUI.printError("Falha ao gerar sample para: \(component)")
                failure += 1
            }
        }
        
        print("\nResumo:")
        ConsoleUI.printSuccess("Total de samples gerados com sucesso: \(success)")
        if failure > 0 {
            ConsoleUI.printError("Total de falhas: \(failure)")
        }
        
        pauseForAction()
        mainMenu(exitCompletion: exitCompletion)
    }
    
    func createCustomComponentSample(exitCompletion: (() -> Void)) {
        clearConsole()
        ConsoleUI.printTitle("Criar Sample para Componente Personalizado")
        
        let componentName = ConsoleUI.promptForInput("Digite o nome do componente personalizado")
        
        if componentName.isEmpty {
            ConsoleUI.printError("Nome do componente não pode ser vazio.")
            pauseForAction()
            mainMenu(exitCompletion: exitCompletion)
            return
        }
        
        ConsoleUI.printInfo("Tentando criar sample para: \(componentName)")
        let result = createSampleFile(for: componentName)
        
        if result {
            ConsoleUI.printSuccess("Sample criado com sucesso para: \(componentName)")
        } else {
            ConsoleUI.printError("Falha ao criar sample para: \(componentName)")
        }
        
        pauseForAction()
        mainMenu(exitCompletion: exitCompletion)
    }
    
    func processComponent(_ componentName: String, exitCompletion: (() -> Void)) {
        clearConsole()
        ConsoleUI.printTitle("Processando Componente: \(componentName)")
        
        ConsoleUI.printInfo("Analisando componente...")
        let result = createSampleFile(for: componentName)
        
        if result {
            ConsoleUI.printSuccess("Sample criado com sucesso para: \(componentName)")
        } else {
            ConsoleUI.printError("Falha ao criar sample para: \(componentName)")
        }
        
        pauseForAction()
        mainMenu(exitCompletion: exitCompletion)
    }
    
    func createSampleFile(for componentName: String) -> Bool {
        Log.log("Criando amostra para o componente: \(componentName)")
        
        // Procurar informações do componente
        guard let componentInfo = componentConfiguration.findComponentFiles(componentName) else {
            Log.log("Não foi possível encontrar o componente: \(componentName)", level: .error)
            return false
        }
        
        // Determinar o caminho para salvar o arquivo Sample
        let samplePath = "\(SAMPLES_PATH)/\(componentInfo.typePath)/\(componentName)"
        
        // Criar os diretórios, se necessário
        do {
            try FileManager.default.createDirectory(atPath: samplePath, withIntermediateDirectories: true)
        } catch {
            Log.log("Erro ao criar diretórios: \(error)", level: .error)
            return false
        }
        
        // Gerar o conteúdo do arquivo Sample
        var sampleContent: String
        
        if componentInfo.isNative {
            sampleContent = generateComponent.generateNativeComponentSample(componentInfo)
        } else {
            // Esta parte implementaria o método generateSampleFile, que é mais complexo
            // Para simplificar, podemos usar o mesmo método para componentes nativos por enquanto
            sampleContent = generateComponent.generateNativeComponentSample(componentInfo)
        }
        
        // Salvar o arquivo
        let sampleFilePath = "\(samplePath)/\(componentName)Sample.swift"
        do {
            try sampleContent.write(toFile: sampleFilePath, atomically: true, encoding: .utf8)
            Log.log("Arquivo Sample criado com sucesso: \(sampleFilePath)")
            
            // Formatar o arquivo gerado usando swiftformat
            formatSwiftFile(sampleFilePath)
            
            return true
        } catch {
            Log.log("Erro ao criar o arquivo Sample: \(error)", level: .error)
            return false
        }
    }
    
    func formatSwiftFile(_ filePath: String) {
        Log.log("Formatando o arquivo: \(filePath)")
        
        // Usar a classe SwiftFormatter para formatar o arquivo
        let formatter = SwiftFormatter(logger: { message, level in
            Log.log(message, level: level)
        })
        
        let result = formatter.formatFile(at: filePath)
        
        switch result {
        case .success(let message):
            Log.log(message, level: .info)
        case .failure(let error):
            Log.log(error, level: .warning)
            Log.log("Use Command+A seguido de Control+I no Xcode para formatar o arquivo manualmente.", level: .warning)
        }
    }

}
