import Foundation

final class ComponentConfiguration {
    func findComponentFiles(_ componentName: String) -> ComponentInfo? {
        // Verificar primeiro se é um componente nativo
        if let nativeComponent = NATIVE_COMPONENTS[componentName] {
            return findNativeComponent(nativeComponent, name: componentName)
        }
        
        return findCustomComponent(componentName)
    }
    
    func findNativeComponent(_ nativeComponent: NativeComponent, name: String) -> ComponentInfo {
        Log.log("Componente nativo encontrado: \(name)")
        var componentInfo = ComponentInfo(name: name, typePath: nativeComponent.typePath)
        componentInfo.isNative = true
        componentInfo.contextualModule = nativeComponent.contextualModule
        
        // Converter init params do formato nativo para o formato interno
        for (index, param) in nativeComponent.initParams.enumerated() {
            var isUsedAsBinding = false
            var type = param.type
            if param.type.contains("Binding") {
                type = param.type.replacingOccurrences(of: "Binding<", with: "").replacingOccurrences(of: ">", with: "")
                isUsedAsBinding = true
            }
            
            var initParam = InitParameter(
                order: index,
                hasObfuscatedArgument: (param.label ?? "").starts(with: "_"),
                isUsedAsBinding: isUsedAsBinding,
                label: param.label,
                name: param.name,
                component: ComponentFinder(type: type).findComponentType(),
                defaultValue: param.defaultValue,
                isAction: param.isAction
            )
            
            // Se for um componente complexo, preencher innerParameters
            fillInnerParameters(parameter: &initParam)
            
            componentInfo.publicInitParams.append(initParam)
        }
        
        componentInfo.exampleCode = nativeComponent.exampleCode
        componentInfo.generateCode = nativeComponent.generateCode
        
        // Se for componente nativo, procurar apenas pelo arquivo de estilos
        let possiblePaths = [
            "\(COMPONENTS_PATH)/BaseElements/Natives/\(name)"
        ]
        
        for path in possiblePaths {
            if FileManager.default.fileExists(atPath: path) {
                do {
                    let files = try FileManager.default.contentsOfDirectory(atPath: path)
                    for file in files {
                        if let styledComponentInfo = configStyles(
                            componentInfo: componentInfo,
                            name: name,
                            file: file,
                            path: path
                        ) {
                            componentInfo = styledComponentInfo
                            break
                        }
                    }
                } catch {
                    Log.log("Erro ao listar arquivos em \(path): \(error)", level: .error)
                }
            }
        }
        
        return componentInfo
    }
    
    func findCustomComponent(_ name: String) -> ComponentInfo? {
        // Para componentes não nativos, seguir o fluxo normal
        var componentInfo: ComponentInfo?

        let possiblePaths = [
            "\(COMPONENTS_PATH)/BaseElements/Customs/\(name)",
            "\(COMPONENTS_PATH)/Components/Customs/\(name)",
            "\(COMPONENTS_PATH)/Templates/\(name)",
        ]
        
        // Verificar se algum dos caminhos possíveis existe
        var foundPath: String?
        for basePath in possiblePaths {
            if FileManager.default.fileExists(atPath: basePath) {
                Log.log("Componente encontrado em: \(basePath)")
                foundPath = basePath
                var typePath = "BaseElements/Customs"
                if basePath.contains("BaseElements/Customs") {
                    typePath = "BaseElements/Customs"
                }
                if basePath.contains("Components/Customs") {
                    typePath = "Components/Customs"
                }
                componentInfo = ComponentInfo(name: name, typePath: typePath)
                break
            }
        }
        
        guard var componentInfo = componentInfo, let foundPath = foundPath else {
            Log.log("Componente '\(name)' não encontrado. Caminhos verificados: \(possiblePaths)", level: .error)
            return nil
        }
        
        // Localizar arquivos View, Configuration e Styles
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: foundPath)
            Log.log("Arquivos encontrados no diretório do componente: \(files)")
            
            for file in files {
                let filePath = "\(foundPath)/\(file)"
                Log.log("Verificando arquivo: \(filePath)")
                
                if file.contains("\(name).swift") {
                    componentInfo.viewPath = filePath
                    componentInfo.hasDefaultSampleText = false
                    Log.log("View encontrada: \(filePath)")
                    if let content = componentInfo.viewPath.readFile() {
                        let initParser = InitParser(content: content, componentName: name)
                        
                        // Extrair informações sobre múltiplos inicializadores
                        let initializers = initParser.extractMultipleInits()
                        componentInfo.initializerInfos = initializers
                        for i in 0..<componentInfo.publicInitParams.count {
                            fillInnerParameters(parameter: &componentInfo.publicInitParams[i])
                        }
                        
                        // Verificar se temos múltiplos inicializadores
                        componentInfo.hasMultipleInits = initializers.count > 1
                        Log.log("Componente com múltiplos inicializadores: \(componentInfo.hasMultipleInits) - Quantidade: \(initializers.count)")
                        
                        // Para compatibilidade, mantemos os publicInitParams com o primeiro inicializador
                        if let firstInit = initializers.first {
                            componentInfo.publicInitParams = firstInit.parameters
                            
                            // Preencher innerParameters para parâmetros complexos
                            for i in 0..<componentInfo.publicInitParams.count {
                                fillInnerParameters(parameter: &componentInfo.publicInitParams[i])
                            }
                        } else {
                            // Se não encontrou inicializadores, usar o método antigo
                            componentInfo.publicInitParams = initParser.extractInitParams()
                            
                            // Preencher innerParameters para parâmetros complexos
                            for i in 0..<componentInfo.publicInitParams.count {
                                fillInnerParameters(parameter: &componentInfo.publicInitParams[i])
                            }
                        }
                        
                        componentInfo.exampleCode = """
                        \(name)(\(componentInfo.publicInitParams.joined()))
                        """
                        componentInfo.generateCode = """
                        \(name)(\(componentInfo.publicInitParams.sampleJoined()))
                        """
                    }
                }
                if let styledComponentInfo = configStyles(
                    componentInfo: componentInfo,
                    name: name,
                    file: file,
                    path: foundPath
                ) {
                    componentInfo = styledComponentInfo
                    Log.log("Styles encontrada: \(filePath)")
                }
            }
        } catch {
            Log.log("Erro ao listar arquivos do componente: \(error)", level: .error)
            return componentInfo
        }

        return componentInfo
    }
    
    func configStyles(componentInfo: ComponentInfo, name: String, file: String, path: String) -> ComponentInfo? {
        if file.contains("\(name)Styles.swift") {
            componentInfo.stylesPath = "\(path)/\(file)"
            Log.log("Arquivo de estilos encontrado: \(componentInfo.stylesPath)")
            
            // Extrair casos de estilo do arquivo de estilos
            if let content = componentInfo.stylesPath.readFile() {
                let styleParser = StyleParser(content: content, componentName: name)
                componentInfo.styleCases = styleParser.extractStyleCases()
                componentInfo.styleFunctions = styleParser.extractStyleFunctions()
                componentInfo.styleParameters = styleParser.extractStyleParameters()
                
                // Preencher innerParameters para parâmetros de estilo complexos
                for i in 0..<componentInfo.styleParameters.count {
                    for j in 0..<componentInfo.styleParameters[i].parameters.count {
                        fillStyleParameters(parameter: &componentInfo.styleParameters[i].parameters[j])
                    }
                }
                
                Log.log("Parametros da função de estilo encontrados: \(componentInfo.styleParameters.map { $0.name })")
                Log.log("Casos de estilo encontrados: \(componentInfo.styleCases)")
                Log.log("Funções de estilo encontradas: \(componentInfo.styleFunctions.map { $0.name })")
            }
            
            return componentInfo
        }
        return nil
    }
}
