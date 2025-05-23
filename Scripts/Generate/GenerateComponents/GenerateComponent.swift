import Foundation

struct GenerateComponentConfiguration {
    var styleFunctions = Set<StyleParameter>()
    var styleParameters = Set<StyleParameter>()
    var styleParams = String()
    var initParams: [InitParameter]
    
    init(_ componentInfo: ComponentInfo) {
        var styleFunctions = Set<StyleParameter>()
        componentInfo.styleFunctions.forEach { function in
            function.parameters.forEach { parameter in
                styleFunctions.insert(parameter)
            }
        }
        var styleParameters = Set<StyleParameter>()
        componentInfo.styleParameters.forEach { function in
            function.parameters.forEach { parameter in
                styleParameters.insert(parameter)
            }
        }
        self.styleFunctions = styleFunctions
        self.styleParameters = styleParameters
        styleParams = "\(styleParameters.isEmpty ? "" : ",")"
        styleParams += Array(styleParameters).joined()
        initParams = componentInfo.publicInitParams
        if componentInfo.hasMultipleInits, let firstInit = componentInfo.initializerInfos.first {
            // Coletar todos os parâmetros de todos os inicializadores para garantir que temos todas as variáveis necessárias
            var allParameters = Set<String>()
            var allInitParams: [InitParameter] = []
            
            componentInfo.initializerInfos.forEach { initInfo in
                initInfo.parameters.forEach { param in
                    if !allParameters.contains(param.name) {
                        allParameters.insert(param.name)
                        allInitParams.append(param)
                    }
                }
            }

            initParams = allInitParams
        }
    }
}

final class GenerateComponent {
    let componentInfo: ComponentInfo
    let config: GenerateComponentConfiguration
    init(_ componentInfo: ComponentInfo) {
        self.componentInfo = componentInfo
        self.config = .init(componentInfo)
    }
    
    // MARK: - Geração de arquivos
    func generateNativeComponentSample() -> String {
        var fullContent = startOfFile()
        fullContent += stateVarsGenerated()
        fullContent += sampleDefaultOptions()
        fullContent += body()
        fullContent += preview()
        fullContent += configurationSection()
        fullContent += allStyles()
        fullContent += generateCode()
        if componentInfo.hasMultipleInits {
            fullContent += generateGetInit()
        }
        
        fullContent += generateGetStyle()
        
        // Adicionar o enum de estilos
        fullContent += generateEnumStyle()
        
        // Adicionar o enum de inicializadores e função getInit se o componente tiver múltiplos inicializadores
        if componentInfo.hasMultipleInits {
            fullContent += generateEnumInit()
        }
        
        return fullContent
    }
    
    func startOfFile() -> String {
        let componentName = componentInfo.name
        let sampleName = "\(componentName)Sample"
        // Importações básicas
        let imports = """
        import SwiftUI
        import Zenith
        import ZenithCoreInterface
        import SFSafeSymbols
        """
        
        // Início da estrutura
        let structStart = """
        
        struct \(sampleName): View, @preconcurrency BaseThemeDependencies {
            @Dependency(\\.themeConfigurator) var themeConfigurator
        """
        
        var content = imports
        content += structStart
        return content
    }
    
    func stateVarsGenerated() -> String {
        // Estados básicos padronizados
        var states: [String] = []
        
        if componentInfo.hasDefaultSampleText {
            // Estado para texto de exemplo padronizado para todos os componentes
            states.append("\n    @State private var sampleText = \"Exemplo de texto\"")
        }
        
        // Estados específicos para tipo de componente
        states.append("\n    @State private var style: Generate\(componentInfo.name)SampleEnum = .\(componentInfo.styleFunctions.first!.name)")
        
        // Adicionar estado para seleção de inicializador se o componente tiver múltiplos inicializadores
        if componentInfo.hasMultipleInits, let firstInit = componentInfo.initializerInfos.first {
            states.append("\n    @State private var selectedInit: Generate\(componentInfo.name)InitEnum = .\(firstInit.name)")
            
            // Coletar todos os parâmetros de todos os inicializadores para garantir que temos todas as variáveis necessárias
            var allParameters = Set<String>()
            var allInitParams: [InitParameter] = []
            
            componentInfo.initializerInfos.forEach { initInfo in
                initInfo.parameters.forEach { param in
                    if !allParameters.contains(param.name) {
                        allParameters.insert(param.name)
                        allInitParams.append(param)
                    }
                }
            }
            
            
            // Adicionar estados para todos os parâmetros de todos os inicializadores
            states.append(contentsOf: stateVars(allInitParams))
        } else {
            states.append(contentsOf: stateVars(config.initParams))
        }
        states.append(contentsOf: stateVars(Array(config.styleFunctions)))
        states.append(contentsOf: stateVars(Array(config.styleParameters)))
        
        return "\(states.joined(separator: "\n"))\n"
    }
    
    func stateVars(_ parameters: [ParameterProtocol]) -> [String] {
        var states: [String] = []
        parameters.forEach { parameter in
            if let defaultValue = parameter.defaultValue {
                if parameter.component.name == "() -> some View" {
                    states.append("\n    private func \(parameter.name)\(parameter.component.name) { Text(\"CustomComponent\").textStyle(.medium()) }")
                } else {
                    if parameter.component.type == .String && (defaultValue.isEmpty || defaultValue == "\"\"") {
                        states.append("\n    @State private var \(parameter.name): \(parameter.component.name) = \"Sample text\"")
                    } else {
                        if parameter.component.name == "StringImageEnum" {
                            states.append(
                            """
                            @State private var \(parameter.name): String = \"figure.run\"
                            @State private var symbolSearch = ""
                            var filteredSymbols: [String] {
                                if symbolSearch.isEmpty {
                                    return SFSymbol.allSymbols.map{ $0.rawValue }.sorted()
                                }
                                return SFSymbol.allSymbols
                                    .filter { $0.rawValue.lowercased().contains(symbolSearch.lowercased()) }
                                    .map { $0.rawValue }
                                    .prefix(100)
                                    .sorted()
                            }
                            """
                            )
                        } else if parameter.component.type.complexType {
                            // Tratar componentes complexos com innerParameters
                            states.append("\n    @State private var \(parameter.name): \(parameter.component.name) = \(defaultValue)")
                            
                            if let innerParams = getInnerParameters(parameter) {
                                // Adicionar estados para os parâmetros internos
                                innerParams.forEach { innerParam in
                                    let innerVarName = "\(parameter.name)_\(innerParam.name)"
                                    let innerDefaultValue = innerParam.defaultValue ?? determineDefaultValueForType(innerParam.type)
                                    states.append("\n    @State private var \(innerVarName): \(innerParam.type) = \(innerDefaultValue)")
                                }
                                
                                // Adicionar um método para configurar o componente complexo
                                states.append(createConfigureComplexTypeMethod(parameter, innerParams))
                            }
                        } else {
                            states.append("\n    @State private var \(parameter.name): \(parameter.component.name) = \(defaultValue)")
                        }
                    }
                }
            } else {
                states.append(defaultUnsetVar(parameter))
            }
        }
        return states
    }
    
    // Método auxiliar para extrair os innerParameters de um ParameterProtocol
    private func getInnerParameters(_ parameter: ParameterProtocol) -> [ComponentProperty]? {
        if let initParam = parameter as? InitParameter {
            return initParam.innerParameters.isEmpty ? nil : initParam.innerParameters
        } else if let styleParam = parameter as? StyleParameter {
            return styleParam.innerParameters.isEmpty ? nil : styleParam.innerParameters
        }
        return nil
    }
    
    // Método para criar um método que configura um tipo complexo a partir de seus innerParameters
    private func createConfigureComplexTypeMethod(_ parameter: ParameterProtocol, _ innerParams: [ComponentProperty]) -> String {
        var methodCode = """
        
            // Método para configurar \(parameter.name) com seus parâmetros internos
            private func configure\(parameter.name.capitalized)() -> \(parameter.component.name) {
                \(parameter.component.name)(
        """
        
        for (index, innerParam) in innerParams.enumerated() {
            let innerVarName = "\(parameter.name)_\(innerParam.name)"
            methodCode += "\n            \(innerParam.name): \(innerVarName)"
            if index < innerParams.count - 1 {
                methodCode += ","
            }
        }
        
        methodCode += "\n        )"
        methodCode += "\n    }"
        
        return methodCode
    }
    
    // Método auxiliar para gerar código para parâmetros complexos
    private func generateComplexTypeCode(_ parameter: ParameterProtocol) -> String {
        guard let innerParams = getInnerParameters(parameter) else {
            return "\(parameter.name): \(parameter.component.name)()"
        }
        
        var code = "\(parameter.name): \(parameter.component.name)("
        
        for (index, innerParam) in innerParams.enumerated() {
            let innerVarName = "\(parameter.name)_\(innerParam.name)"
            code += "\(innerParam.name): \(innerVarName)"
            
            if index < innerParams.count - 1 {
                code += ", "
            }
        }
        
        code += ")"
        return code
    }
    
    // Determina um valor padrão apropriado para um tipo específico
    private func determineDefaultValueForType(_ type: String) -> String {
        let trimmedType = type.trimmingCharacters(in: .whitespaces)
        
        if trimmedType.hasSuffix("?") {
            return "nil"
        }
        
        switch trimmedType {
        case "String":
            return "\"\""
        case "Int", "Int8", "Int16", "Int32", "Int64",
             "UInt", "UInt8", "UInt16", "UInt32", "UInt64":
            return "0"
        case "Float", "Double", "CGFloat":
            return "0.0"
        case "Bool":
            return "false"
        case let arrayType where arrayType.hasPrefix("[") && arrayType.hasSuffix("]"):
            return "[]"
        case let dictType where dictType.hasPrefix("[") && dictType.contains(":"):
            return "[:]"
        default:
            // Se for um tipo personalizado
            if trimmedType.first?.isUppercase == true &&
                !trimmedType.contains("->") &&
                !trimmedType.contains("<") {
                return "\(trimmedType)()"
            }
            return "nil"
        }
    }
    
    func defaultUnsetVar(_ parameter: ParameterProtocol) -> String {
        let firstStyle = componentInfo.styleFunctions.first!
        var defaultParameters = ""
        defaultParameters += firstStyle.parameters.joined()
        let defaultCase = ".\(firstStyle.name)(\(defaultParameters))"
        
        // Verificar se o parâmetro é um componente complexo com innerParameters
        if parameter.component.type.complexType, let innerParams = getInnerParameters(parameter) {
            // Criar o estado para o componente complexo
            var result = "\n    @State private var \(parameter.name): \(parameter.component.name) = .init()"
            
            // Adicionar estados para os parâmetros internos
            innerParams.forEach { innerParam in
                let innerVarName = "\(parameter.name)_\(innerParam.name)"
                let innerDefaultValue = innerParam.defaultValue ?? determineDefaultValueForType(innerParam.type)
                result += "\n    @State private var \(innerVarName): \(innerParam.type) = \(innerDefaultValue)"
            }
            
            // Adicionar um método para configurar o componente complexo
            result += createConfigureComplexTypeMethod(parameter, innerParams)
            
            return result
        }
        
        return switch parameter.component.name {
        case "String":
            "\n    @State private var \(parameter.name): \(parameter.component.name) = \"Sample text\""
        case "StringImageEnum":
            """
            @State private var \(parameter.name): String = \"figure.run\"
            @State private var symbolSearch = ""
            var filteredSymbols: [String] {
                if symbolSearch.isEmpty {
                    return SFSymbol.allSymbols.map{ $0.rawValue }.sorted()
                }
                return SFSymbol.allSymbols
                    .filter { $0.rawValue.lowercased().contains(symbolSearch.lowercased()) }
                    .map { $0.rawValue }
                    .prefix(100)
                    .sorted()
            }
            """
        case "Bool":
            "\n    @State private var \(parameter.name): \(parameter.component.name) = false"
        case "Int":
            "\n    @State private var \(parameter.name): \(parameter.component.name) = 1"
        case "Double":
            "\n    @State private var \(parameter.name): \(parameter.component.name) = 0.01"
        case "CGFloat":
            "\n    @State private var \(parameter.name): \(parameter.component.name) = 1"
        default:
            if parameter.component.name.contains("->") || parameter.component.name.contains("escaping") {
                "\n    @State private var \(parameter.name): \(parameter.component.name) = {}"
            } else {
                if parameter.component.type.complexType {
                    "\n    @State private var \(parameter.name): \(parameter.component.name) = .init()"
                } else {
                    "\n    @State private var \(parameter.name): \(parameter.component.name) = \(defaultCase)"
                }
            }
        }
    }
    
    func sampleDefaultOptions() -> String {
        // Toggles para opções de visualização´
        return """
        
            @State private var showAllStyles = false
            @State private var useContrastBackground = true
            @State private var showFixedHeader = false\n
        """
    }
    
    func body() -> String {
        """
            
            var body: some View {
                SampleWithFixedHeader(
                    showFixedHeader: $showFixedHeader,
                    content: {
                        Card(action: {
                            showFixedHeader.toggle()
                        }) {
                            VStack(spacing: 16) {
                                // Preview do componente com configurações atuais
                                previewComponent
                            }
                            .padding()
                        }
                        .padding()
                    },
                    config: {
                        VStack(spacing: 16) {
                            // Área de configuração
                            configurationSection
                            
                            // Preview do código gerado
                            CodePreviewSection(generateCode: generateSwiftCode)
                            
                            // Exibição de todos os estilos (opcional)
                            if showAllStyles {
                                Divider().padding(.vertical, 4)
                                
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Todos os Estilos")
                                        .font(fonts.mediumBold)
                                        .foregroundColor(colors.contentA)
                                    
                                    allStyles
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                )
            }
        """
    }
    
    func preview() -> String {
        var previewComponent = """
            
            // Preview do componente com as configurações selecionadas
            private var previewComponent: some View {
                VStack {
                    // Preview do componente com as configurações atuais
        """
        
        // Se o componente tem múltiplos inicializadores, usamos get{Component}Init
        if componentInfo.hasMultipleInits {
            previewComponent += """
            
                    get\(componentInfo.name)Init(selectedInit.rawValue)
                    .\(componentInfo.name.firstLowerCased)Style(get\(componentInfo.name)Style(style.rawValue)\(config.styleParams))
            """
        } else {
            previewComponent += """
            
                    \(componentInfo.exampleCode)
                    .\(componentInfo.name.firstLowerCased)Style(get\(componentInfo.name)Style(style.rawValue)\(config.styleParams))
            """
        }
        
        previewComponent += """
                    \n .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(useContrastBackground ? colors.backgroundA : colors.backgroundB.opacity(0.2))
                    )
                }
            }
        """
        return previewComponent
    }
    
    func configurationSection() -> String {
        var sampleText = ""
        if componentInfo.hasDefaultSampleText {
            sampleText = """
            // Campo para texto de exemplo
            TextField("", text: $sampleText)
                .textFieldStyle(.contentA(), placeholder: "Texto de exemplo")
                .padding(.horizontal)
            """
        }
        
        // Adicionar seletor de inicializador se o componente tiver múltiplos inicializadores
        var initSelector = ""
        if componentInfo.hasMultipleInits {
            initSelector = """
            VStack(alignment: .leading) {
                Text("\(componentInfo.name) Inicializadores")
                    .font(fonts.smallBold)
                    .foregroundColor(colors.contentA)
                    .padding(.horizontal, 8)
                
                EnumSelector<Generate\(componentInfo.name)InitEnum>(
                    title: "Selecione um inicializador",
                    selection: $selectedInit,
                    columnsCount: 1,
                    height: 160
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(colors.highlightA.opacity(0.3), lineWidth: 1)
                )
            }
            .padding(.horizontal)
            """
        }
        
        var configurationSection = """
            
            // Área de configuração
            private var configurationSection: some View {
                VStack(spacing: 16) {
                    \(sampleText)
                    \(initSelector)
                    EnumSelector<Generate\(componentInfo.name)SampleEnum>(
                        title: "\(componentInfo.name) Estilos",
                        selection: $style,
                        columnsCount: 3,
                        height: 120
                    )
                    .padding(.horizontal)\n
        """

        configurationSection += interactiveComponents(Array(config.styleFunctions))
        configurationSection += interactiveComponents(Array(config.styleParameters))
        configurationSection += interactiveComponents(config.initParams)
        
        // Adicionar toggles para opções de visualização para todos os componentes
        configurationSection += """
                    // Toggles para opções
                    VStack {
                        Toggle("Usar fundo contrastante", isOn: $useContrastBackground)
                            .toggleStyle(.default(.highlightA))
                        
                        Toggle("Mostrar Todos os Estilos", isOn: $showAllStyles)
                            .toggleStyle(.default(.highlightA))
                    }
                    .padding(.horizontal)
                }
            }
        """
        return configurationSection
    }
    
    func interactiveComponents(_ parameters: [ParameterProtocol]) -> String {
        var interactiveComponents = ""
        parameters.forEach { parameter in
            // Verificar se o parâmetro é um componente complexo com innerParameters
            if parameter.component.type.complexType, let innerParams = getInnerParameters(parameter) {
                // Criar um editor expandível para o tipo complexo
                interactiveComponents += createComplexParameterEditor(parameter, innerParams)
            } else {
                let parameterComponent = switch parameter.component.name {
                case "String":
                    """
                    TextField("", text: $\(parameter.name))
                        .textFieldStyle(.contentA(), placeholder: "\(parameter.name)")
                        .padding(.horizontal)\n
                    """
                case "StringImageEnum":
                    """
                    Text("Ícone")
                        .font(fonts.smallBold)
                        .foregroundColor(colors.contentA)
                    
                    TextField("Buscar símbolo", text: $symbolSearch)
                        .textFieldStyle(.roundedBorder)
                    
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 8) {
                            ForEach(filteredSymbols, id: \\.self) { symbol in
                                VStack {
                                    Image(systemName: symbol)
                                        .font(.system(size: 22))
                                        .frame(width: 44, height: 44)
                                        .background(
                                            Circle()
                                                .fill(symbol == \(parameter.name) ?
                                                      colors.highlightA : colors.backgroundB)
                                        )
                                        .foregroundColor(symbol == \(parameter.name) ?
                                                         colors.contentC : colors.contentA)
                                    
                                    Text(symbol)
                                        .font(fonts.small)
                                        .foregroundColor(colors.contentA)
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                }
                                .frame(width: 80, height: 80)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    \(parameter.name) = symbol
                                }
                            }
                        }
                    }
                    .frame(height: 200)
                    .background(colors.backgroundB.opacity(0.5))
                    .cornerRadius(8)
                    """
                case "Bool":
                    """
                    Toggle("\(parameter.name)", isOn: $\(parameter.name))
                        .toggleStyle(.default(.highlightA))
                        .padding(.horizontal)\n
                    """
                case "Int":
                        """
                        
                        VStack(alignment: .leading) {
                        Text("\(parameter.name): $\\(String(format: "%.2f", \(parameter.name)))")
                            .font(fonts.smallBold)
                            .foregroundColor(colors.contentA) 
                            .padding(.horizontal)
                        Slider(value: $\(parameter.name), in: -100...100, step: 1)
                            .accentColor(colors.highlightA)
                            .padding(.horizontal)
                        }
                        
                        """
                case "Double":
                        """
                        
                        VStack(alignment: .leading) {
                        Text("\(parameter.name): $\\(String(format: "%.2f", \(parameter.name)))")
                             .font(fonts.smallBold)
                             .foregroundColor(colors.contentA)  
                             .padding(.horizontal)
                        Slider(value: $\(parameter.name), in: -1...1, step: 0.01)
                            .accentColor(colors.highlightA)
                            .padding(.horizontal)
                        }
                        
                        """
                case "CGFloat":
                        """
                        
                        VStack {
                        Text("\(parameter.name): $\\(String(format: "%.2f", \(parameter.name)))")
                            .font(fonts.smallBold)
                            .foregroundColor(colors.contentA)  
                            .padding(.horizontal)
                        Slider(value: $\(parameter.name), in: -100...100, step: 0.1)
                            .accentColor(colors.highlightA)
                            .padding(.horizontal)
                        }
                        
                        """
                default:
                    if parameter.component.name.contains("->") {
                        ""
                    } else {
                        if parameter.component.type.complexType {
                            // Em vez do ComplexTypeEditor, usamos diretamente as propriedades internas
                            // Isso é tratado pelo método createComplexParameterEditor
                            """
                            VStack(alignment: .leading, spacing: 8) {
                                Text("\(parameter.name)")
                                    .font(fonts.mediumBold)
                                    .foregroundColor(colors.contentA)
                                
                                Text("\(parameter.component.name)")
                                    .font(fonts.small)
                                    .foregroundColor(colors.contentB)
                                
                                Button(action: {
                                    \(parameter.name) = configure\(parameter.name.capitalized)()
                                }) {
                                    Text("Atualizar \(parameter.name)")
                                        .font(fonts.smallBold)
                                        .padding(.vertical, 6)
                                        .padding(.horizontal, 12)
                                        .background(colors.highlightA)
                                        .foregroundColor(colors.contentC)
                                        .cornerRadius(8)
                                }
                                .padding(.vertical, 8)
                            }
                            .padding()
                            .background(colors.backgroundA.opacity(0.5))
                            .cornerRadius(8)
                            .padding(.horizontal)\n
                            """
                        } else {
                            """
                            EnumSelector<\(parameter.component.name)>(
                                title: "\(parameter.component.name)",
                                selection: $\(parameter.name),
                                columnsCount: 3,
                                height: 120
                            )
                            .padding(.horizontal)\n
                            """
                        }
                    }
                }
                interactiveComponents += parameterComponent
            }
        }
        return interactiveComponents
    }
    
    // Cria um editor para tipos complexos usando seus innerParameters
    private func createComplexParameterEditor(_ parameter: ParameterProtocol, _ innerParams: [ComponentProperty]) -> String {
        var editor = """
        VStack(alignment: .leading, spacing: 8) {
            Text("\(parameter.name)")
                .font(fonts.mediumBold)
                .foregroundColor(colors.contentA)
            
            Text("\(parameter.component.name)")
                .font(fonts.small)
                .foregroundColor(colors.contentB)
            
            // Campos para propriedades internas
            VStack(alignment: .leading, spacing: 12) {
        """
        
        // Adicionar editores para cada propriedade interna
        for innerParam in innerParams {
            let innerVarName = "\(parameter.name)_\(innerParam.name)"
            
            editor += """
            
                VStack(alignment: .leading, spacing: 4) {
            
            """
            
            // Escolher o editor apropriado para o tipo da propriedade interna
            let editorComponent = switch innerParam.type {
            case "String":
                """

                    Text("\(innerParam.name): \\(\(innerVarName))")
                        .font(fonts.small)
                        .foregroundColor(colors.contentA)
                    TextField("", text: $\(innerVarName))
                        .textFieldStyle(.contentA(), placeholder: "\(innerParam.name)")
                        .onChange(of: \(innerVarName)) {
                            \(parameter.name) = configure\(parameter.name.capitalized)()
                        }
                """
            case "Bool":
                """
                    Text("\(innerParam.name): \\(\(innerVarName))")
                        .font(fonts.small)
                        .foregroundColor(colors.contentA)
                    Toggle("\(innerParam.name)", isOn: $\(innerVarName))
                        .toggleStyle(.default(.highlightA))
                        .onChange(of: \(innerVarName)) {
                            \(parameter.name) = configure\(parameter.name.capitalized)()
                        }
                """
            case "Int", "Int8", "Int16", "Int32", "Int64",
                 "UInt", "UInt8", "UInt16", "UInt32", "UInt64":
                        """
                        Text("\(innerParam.name): \\(String(format: "%.2f",\(innerVarName)))")
                            .font(fonts.small)
                            .foregroundColor(colors.contentA)                        
                        Slider(value: $\(innerVarName), in: -100...100, step: 1)
                            .accentColor(colors.highlightA)
                            .onChange(of: \(innerVarName)) {
                                \(parameter.name) = configure\(parameter.name.capitalized)()
                            }
                            
                        """
            case "Double":
                    """
                    Text("\(innerParam.name): \\(String(format: "%.2f",\(innerVarName)))")
                        .font(fonts.small)
                        .foregroundColor(colors.contentA)                                    
                    Slider(value: $\(innerVarName), in: -1...1, step: 0.01)
                            .accentColor(colors.highlightA)
                            .onChange(of: \(innerVarName)) {
                                \(parameter.name) = configure\(parameter.name.capitalized)()
                            }

                    """
            case "CGFloat":
                    """
                    Text("\(innerParam.name): \\(String(format: "%.2f",\(innerVarName)))")
                        .font(fonts.small)
                        .foregroundColor(colors.contentA)                    
                    Slider(value: $\(innerVarName), in: -100...100, step: 0.1)
                            .accentColor(colors.highlightA)
                            .onChange(of: \(innerVarName)) {
                                \(parameter.name) = configure\(parameter.name.capitalized)()
                            }
                    
                    """
            default:
                if innerParam.type.hasSuffix("Enum") || innerParam.type.contains("Case") {
                    """
                    
                        EnumSelector<\(innerParam.type)>(
                            title: "\(innerParam.name)",
                            selection: $\(innerVarName),
                            columnsCount: 3,
                            height: 120
                        )
                        .onChange(of: \(innerVarName)) {
                            \(parameter.name) = configure\(parameter.name.capitalized)()
                        }
                    """
                } else {
                    """
                    
                        TextField("", text: $\(innerVarName))
                            .textFieldStyle(.contentA(), placeholder: "\(innerParam.name)")
                            .onChange(of: \(innerVarName)) {
                                \(parameter.name) = configure\(parameter.name.capitalized)()
                            }
                    """
                }
            }
            
            editor += editorComponent
            editor += """
                
                }
            """
        }
        
        editor += """
            
            }
        }
        .padding()
        .background(colors.backgroundA.opacity(0.5))
        .cornerRadius(8)
        .padding(.horizontal)\n
        """
        
        return editor
    }
    
    func allStyles() -> String {
        var allStyles = "\n\n"
        allStyles += """
            private var allStyles: some View {
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        // Mostrar todas as funções de estilo disponíveis
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 8) {
                            ForEach(\(componentInfo.name)StyleCase.allCases, id: \\.self) { style in
                                VStack {
                                    \(componentInfo.exampleCode)
                                    .\(componentInfo.name.firstLowerCased)Style(style.style()\(config.styleParams))
                                    .padding(8)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(colors.backgroundB.opacity(0.2))
                                    )
                                }
                            }
                        }
                    }
                }
                .frame(maxHeight: 200)
            }
            """
        return allStyles
    }
    
    func generateCode() -> String {
        var generateCode = """
            
            // Gera o código Swift para o componente configurado
            private func generateSwiftCode() -> String {
                var code = "// Código gerado automaticamente\\n"
                
        """
        var styleFunctionsCases: [String] = []
        componentInfo.styleFunctions.forEach { styleFunction in
            var parameters = ""
            parameters += styleFunction.parameters.sampleJoined()
            styleFunctionsCases.append("\".\(styleFunction.name)(\(parameters))\"")
        }
        
        var styleParametersCases: String = ""
        componentInfo.styleParameters.forEach { styleParameter in
            var parameters = styleParameter.parameters.isEmpty ? "" : ", "
            parameters += styleParameter.parameters.sampleJoined()
            styleParametersCases.append(parameters)
        }
        
        // Se tiver múltiplos inicializadores, gerar código para selecionar o correto
        if componentInfo.hasMultipleInits {
            generateCode += """
            let styleFunctionsCases = [\(styleFunctionsCases.joined(separator: ", "))]
            let selectedStyle = styleFunctionsCases.first(where: { $0.contains(style.rawValue) }) ?? \".\\(style.rawValue)()\"
            
            // Gerar código para o inicializador selecionado
            var initCode = ""
            switch selectedInit {
            """
            
            // Adicionar casos para cada inicializador
            for initInfo in componentInfo.initializerInfos {
                // Gerar uma string que representa o inicializador e seus parâmetros
                var initializerCode = "\(componentInfo.name)("
                
                // Iterar pelos parâmetros ordenados por ordem
                for (idx, param) in initInfo.parameters.sorted(by: { $0.order < $1.order }).enumerated() {
                    let paramName = param.name
                    var paramValue = ""
                    
                    // Formatar baseado no tipo
                    if param.hasObfuscatedArgument {
                        paramValue = "\\(\(paramName))"
                    } else {
                        let innerParams = getInnerParameters(param)
                        paramValue = formatParameterValue(
                            paramName: paramName,
                            paramValue: paramName,
                            component: param.component,
                            hasObfuscatedArgument: param.hasObfuscatedArgument,
                            innerParams: innerParams
                        )
                    }
                    
                    // Adicionar à string do inicializador
                    initializerCode += paramValue
                    
                    // Adicionar vírgula se não for o último parâmetro
                    if idx < initInfo.parameters.count - 1 {
                        initializerCode += ", "
                    }
                }
                
                initializerCode += ")"
                
                generateCode += """
                
                case .\(initInfo.name):
                    initCode = "\(initializerCode)"
                """
            }
            
            generateCode += """
            
            }
            
            code += \"\"\"
            \\(initCode)
            .\(componentInfo.name.firstLowerCased)Style(\\(selectedStyle)\(styleParametersCases))
            \"\"\"\n
            """
        } else {
            // Código original para componentes com um único inicializador
            generateCode += """
            let styleFunctionsCases = [\(styleFunctionsCases.joined(separator: ", "))]
            let selectedStyle = styleFunctionsCases.first(where: { $0.contains(style.rawValue) }) ?? \".\\(style.rawValue)()\"
            code += \"\"\"
            \(componentInfo.generateCode)
            .\(componentInfo.name.firstLowerCased)Style(\\(selectedStyle)\(styleParametersCases))
            \"\"\"\n
            """
        }
        
        generateCode += """
                return code
            }
        """
        
        return generateCode
    }
    
    func generateGetStyle() -> String {
        let name = componentInfo.name
        var cases = ""
        componentInfo.styleFunctions.forEach { styleFunction in
            var parameters = ""
            parameters += styleFunction.parameters.joined()
            cases += "case \"\(styleFunction.name)\":\n"
            cases += "    .\(styleFunction.name)(\(parameters))\n"
        }
        
        let firstStyle = componentInfo.styleFunctions.first!
        var defaultParameters = ""
        defaultParameters += firstStyle.parameters.joined()
        let prefix = componentInfo.contextualModule ? "Zenith." : ""
        let defaultCase = """
            default:
                .\(firstStyle.name)(\(defaultParameters))
        """
        return """
        
            private func get\(name)Style(_ style: String) -> Any\(name)Style {
                let style: any \(prefix)\(componentInfo.name)Style = switch style {
                \(cases)
                \(defaultCase)
                }
                return Any\(name)Style(style)
            }
        \n}
        """
    }
    
    func generateEnumStyle() -> String {
        var cases = ""
        componentInfo.styleFunctions.forEach { styleFunction in
            var parameters = ""
            parameters += styleFunction.parameters.joined()
            var name = styleFunction.name
            if styleFunction.name == "default" {
                name = "`\(name)`"
            }
            cases += "case \(name)\n"
        }
        
        return """
        
            enum Generate\(componentInfo.name)SampleEnum: String, CaseIterable, Identifiable {
                public var id: Self { self }
        
                \(cases)
            }
        """
    }
    
    // Novo método para gerar o enum de inicializadores
    func generateEnumInit() -> String {
        var cases = ""
        componentInfo.initializerInfos.forEach { initInfo in
            cases += "case \(initInfo.name)\n"
        }
        
        return """
        
            enum Generate\(componentInfo.name)InitEnum: String, CaseIterable, Identifiable {
                public var id: Self { self }
        
                \(cases)
            }
        """
    }
    
    // Novo método para gerar o getter de inicializadores
    func generateGetInit() -> String {
        let name = componentInfo.name
        var cases = ""
        
        componentInfo.initializerInfos.forEach { initInfo in
            let parameters = initInfo.parameters.joined()
            cases += "case \"\(initInfo.name)\":\n"
            cases += "    \(name)(\(parameters))\n"
        }
        
        if let firstInit = componentInfo.initializerInfos.first {
            let defaultParameters = firstInit.parameters.joined()
            
            return """
            
                private func get\(name)Init(_ initType: String) -> some View {
                    switch initType {
                    \(cases)
                    default:
                        \(name)(\(defaultParameters))
                    }
                }
            """
        }
        
        // Caso não haja inicializadores definidos, retornar string vazia
        return ""
    }
    
    // Função para formatar o valor de um parâmetro baseado em seu tipo
    private func formatParameterValue(paramName: String, paramValue: String, component: any ComponentProtocol, hasObfuscatedArgument: Bool = false, innerParams: [ComponentProperty]? = nil) -> String {
        if hasObfuscatedArgument {
            return "\\(\(paramName))"
        }
        
        switch component.type {
        case .String, .StringImageEnum:
            return "\(paramName): \\\"\\(\(paramValue))\\\""
        case .Bool, .Int, .Double, .CGFloat:
            return "\(paramName): \\(\(paramValue))"
        default:
            if component.name.contains("->") {
                return "\(paramName): {}"
            } else if component.type.complexType, let innerParams = innerParams, !innerParams.isEmpty {
                // Usar código específico para parâmetros complexos
                var innerCode = "\(paramName): \(component.name)("
                
                for (innerIdx, innerParam) in innerParams.enumerated() {
                    let innerVarName = "\(innerParam.name)"
                    let paramValue = "\(paramName)_\(innerParam.name)"
                    innerCode += formatParameterValue(
                        paramName: innerVarName,
                        paramValue: paramValue,
                        component: innerParam.component,
                        hasObfuscatedArgument: false,
                        innerParams: innerParam.innerParameters
                    )
                    
                    if innerIdx < innerParams.count - 1 {
                        innerCode += ", "
                    }
                }
                
                innerCode += ")"
                return innerCode
            } else {
                return "\(paramName): .\\(\(paramName)).rawValue"
            }
        }
    }
}
