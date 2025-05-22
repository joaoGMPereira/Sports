import SwiftUI
import Zenith
import ZenithCoreInterface

/// Sheet para configuração de tipos complexos (struct/class)
struct ComplexTypeConfigSheet<T: Any>: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator
    
    // MARK: - Propriedades
    
    /// Título do componente
    let title: String
    
    /// O tipo de componente
    let componentType: ComponentType
    
    /// A instância do valor atual
    @Binding var value: T
    
    /// Para fechar a sheet
    @Environment(\.dismiss) var dismiss
    
    // MARK: - Estado
    
    /// Armazena as propriedades do tipo complexo
    @State private var properties: [PropertyViewModel] = []
    
    /// Flag para indicar se houve mudanças
    @State private var hasChanges = false
    
    // MARK: - Corpo da View
    
    var body: some View {
        ZStack(alignment: .top) {
            colors.backgroundA.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Informações do tipo
                    typeInfo
                    
                    // Lista de propriedades
                    propertiesList
                }
                .padding()
            }
            .scrollContentBackground(.hidden)
            .onAppear {
                loadProperties()
            }
        }
    }
    
    // MARK: - Views
    
    /// Exibe informações sobre o tipo
    private var typeInfo: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label {
                Text(title)
                    .font(fonts.mediumBold)
                    .foregroundColor(colors.contentA)
            } icon: {
                Image(systemSymbol: componentType == .struct ? .squareGrid2x2 : .squareGrid3x3)
                    .foregroundColor(colors.highlightA)
            }
            
            Text(componentType.rawValue)
                .font(fonts.small)
                .foregroundColor(colors.contentB)
                .padding(.leading, 24)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(colors.backgroundB.opacity(0.5))
        .cornerRadius(8)
    }
    
    /// Lista as propriedades do tipo complexo
    private var propertiesList: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Propriedades")
                .font(fonts.mediumBold)
                .foregroundColor(colors.contentA)
            
            if properties.isEmpty {
                Text("Nenhuma propriedade editável encontrada")
                    .font(fonts.small)
                    .foregroundColor(colors.contentB)
                    .padding()
            } else {
                ForEach(properties) { propertyViewModel in
                    propertyEditor(for: propertyViewModel)
                }
            }
        }
    }
    
    /// Cria o editor apropriado para cada tipo de propriedade
    @ViewBuilder
    private func propertyEditor(for propertyViewModel: PropertyViewModel) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(propertyViewModel.name): \(propertyViewModel.type.rawValue)")
                .font(fonts.smallBold)
                .foregroundColor(colors.contentA)
            
            switch propertyViewModel.type {
            case .String:
                TextField("", text: Binding(
                    get: { propertyViewModel.stringValue },
                    set: { 
                        if let index = self.properties.firstIndex(where: { $0.id == propertyViewModel.id }) {
                            self.properties[index].stringValue = $0
                            self.hasChanges = true
                        }
                    }
                ))
                .textFieldStyle(.highlightA(), placeholder: "Valor")
                
            case .Int, .UInt, .Int8, .UInt8, .Int16, .UInt16, .Int32, .UInt32, .Int64, .UInt64:
                HStack {
                    TextField("Valor", text: Binding(
                        get: { String(propertyViewModel.intValue) },
                        set: { 
                            if let intValue = Int($0),
                               let index = self.properties.firstIndex(where: { $0.id == propertyViewModel.id }) {
                                self.properties[index].intValue = intValue
                                self.hasChanges = true
                            }
                        }
                    ))
                    .textFieldStyle(.highlightA(), placeholder: "Valor")
                    .keyboardType(.numberPad)
                    
                    Stepper("", value: Binding(
                        get: { propertyViewModel.intValue },
                        set: {
                            if let index = self.properties.firstIndex(where: { $0.id == propertyViewModel.id }) {
                                self.properties[index].intValue = $0
                                self.hasChanges = true
                            }
                        }
                    ))
                }
                
            case .Float, .Double, .CGFloat:
                HStack {
                    TextField("", text: Binding(
                        get: { String(format: "%.2f", propertyViewModel.doubleValue) },
                        set: { 
                            if let doubleValue = Double($0),
                               let index = self.properties.firstIndex(where: { $0.id == propertyViewModel.id }) {
                                self.properties[index].doubleValue = doubleValue
                                self.hasChanges = true
                            }
                        }
                    ))
                    .textFieldStyle(.highlightA(), placeholder: "Valor")
                    .keyboardType(.decimalPad)
                    
                    Slider(value: Binding(
                        get: { propertyViewModel.doubleValue },
                        set: {
                            if let index = self.properties.firstIndex(where: { $0.id == propertyViewModel.id }) {
                                self.properties[index].doubleValue = $0
                                self.hasChanges = true
                            }
                        }
                    ), in: 0...1)
                    .frame(width: 100)
                }
                
            case .Bool:
                Toggle(propertyViewModel.name, isOn: Binding(
                    get: { propertyViewModel.boolValue },
                    set: { 
                        if let index = self.properties.firstIndex(where: { $0.id == propertyViewModel.id }) {
                            self.properties[index].boolValue = $0
                            self.hasChanges = true
                        }
                    }
                ))
                .toggleStyle(.default())
                
            case .class, .struct:
                if let complexValue = propertyViewModel.complexValue {
                    ComplexTypeSelectorView(
                        title: propertyViewModel.name,
                        componentType: propertyViewModel.type,
                        value: Binding<Any>(
                            get: { complexValue },
                            set: { 
                                if let index = self.properties.firstIndex(where: { $0.id == propertyViewModel.id }) {
                                    self.properties[index].complexValue = $0
                                    self.hasChanges = true
                                }
                            }
                        )
                    )
                }
                
            case .enum:
                if let enumCases = propertyViewModel.enumCases, !enumCases.isEmpty {
                    Picker(propertyViewModel.name, selection: Binding(
                        get: { propertyViewModel.enumValue ?? enumCases[0] },
                        set: { 
                            if let index = self.properties.firstIndex(where: { $0.id == propertyViewModel.id }) {
                                self.properties[index].enumValue = $0
                                self.hasChanges = true
                            }
                        }
                    )) {
                        ForEach(enumCases, id: \.self) { enumCase in
                            Text(enumCase)
                                .tag(enumCase)
                        }
                    }
                    .pickerStyle(.menu)
                } else {
                    Text("Enum não suportado")
                        .foregroundColor(colors.contentB)
                }
                
            default:
                Text("Tipo não suportado: \(propertyViewModel.type.rawValue)")
                    .foregroundColor(colors.contentB)
            }
        }
        .padding()
        .background(colors.backgroundB.opacity(0.3))
        .cornerRadius(8)
    }
    
    // MARK: - Funções
    
    /// Carrega as propriedades do tipo complexo usando reflection
    private func loadProperties() {
        // Usando Mirror para obter propriedades
        let mirror = Mirror(reflecting: value)
        
        properties = mirror.children.compactMap { child in
            guard let label = child.label else { return nil }
            
            // Remove o underscore que o Swift adiciona em propriedades stored
            let propertyName = label.hasPrefix("_") ? String(label.dropFirst()) : label
            
            // Determinar o tipo e o valor atual
            let childMirror = Mirror(reflecting: child.value)
            let propertyType = determineComponentType(from: childMirror)
            
            // Criar um viewModel para a propriedade
            return createPropertyViewModel(name: propertyName, type: propertyType, value: child.value)
        }
    }
    
    /// Cria um view model para uma propriedade
    private func createPropertyViewModel(name: String, type: ComponentType, value: Any) -> PropertyViewModel {
        // Inicializa com valores padrão
        var viewModel = PropertyViewModel(
            id: UUID(),
            name: name,
            type: type,
            originalValue: value,
            stringValue: "",
            intValue: 0,
            doubleValue: 0.0,
            boolValue: false
        )
        
        // Configura valores específicos por tipo
        switch type {
        case .String:
            if let strValue = value as? String {
                viewModel.stringValue = strValue
            }
        case .Int, .UInt, .Int8, .UInt8, .Int16, .UInt16, .Int32, .UInt32, .Int64, .UInt64:
            if let intValue = value as? Int {
                viewModel.intValue = intValue
            } else if let intValue = Int("\(value)") {
                viewModel.intValue = intValue
            }
        case .Float, .Double, .CGFloat:
            if let doubleValue = value as? Double {
                viewModel.doubleValue = doubleValue
            } else if let floatValue = value as? Float {
                viewModel.doubleValue = Double(floatValue)
            } else if let cgFloatValue = value as? CGFloat {
                viewModel.doubleValue = Double(cgFloatValue)
            } else if let doubleValue = Double("\(value)") {
                viewModel.doubleValue = doubleValue
            }
        case .Bool:
            if let boolValue = value as? Bool {
                viewModel.boolValue = boolValue
            }
        case .class, .struct:
            viewModel.complexValue = value
        case .enum:
            viewModel.enumValue = "\(value)"
            viewModel.enumCases = getEnumCases(for: value)
        default:
            break
        }
        
        return viewModel
    }
    
    /// Tenta obter os casos de um enum usando reflection
    private func getEnumCases(for enumValue: Any) -> [String] {
        // Isso é uma simplificação, enums no Swift podem ser complexos
        // Na prática, precisaríamos de uma abordagem mais robusta
        let mirror = Mirror(reflecting: type(of: enumValue))
        let typeName = String(describing: mirror.subjectType)
        
        // Abordagem simplificada para retornar alguns valores
        // Numa implementação real, seria necessário analisar o tipo com mais profundidade
        // ou manter um registro manual de enums conhecidos
        return ["Caso1", "Caso2", "Caso3"]
    }
    
    /// Determina o tipo de componente a partir do espelho
    private func determineComponentType(from mirror: Mirror) -> ComponentType {
        let typeName = String(describing: mirror.subjectType)
        
        // Verificar tipos primitivos comuns
        if typeName.contains("String") { return .String }
        if typeName.contains("Int") && !typeName.contains("UInt") { return .Int }
        if typeName.contains("UInt") { return .UInt }
        if typeName.contains("Float") { return .Float }
        if typeName.contains("Double") { return .Double }
        if typeName.contains("CGFloat") { return .CGFloat }
        if typeName.contains("Bool") { return .Bool }
        
        // Verificar estruturas ou classes
        if mirror.displayStyle == .struct { return .struct }
        if mirror.displayStyle == .class { return .class }
        if mirror.displayStyle == .enum { return .enum }
        
        // Valor padrão
        return .notFound
    }
    
    /// Aplica as alterações ao objeto original
    private func applyChanges() {
        // Esta é a parte mais desafiadora devido às limitações do Swift com reflection e mutabilidade
        
        if componentType == .class, let valueObject = value as? NSObject {
            // Para classes que herdam de NSObject, podemos usar KVC
            for property in properties {
                applyPropertyToNSObject(property, to: valueObject)
            }
        } else {
            // Para structs, usamos uma abordagem diferente: notificação
            notifyStructChanges()
        }
        
        // Indicamos que aplicamos as alterações
        hasChanges = false
    }
    
    /// Aplica uma propriedade a um objeto NSObject usando KVC
    private func applyPropertyToNSObject(_ property: PropertyViewModel, to object: NSObject) {
        switch property.type {
        case .String:
            object.setValue(property.stringValue, forKey: property.name)
        case .Int, .UInt, .Int8, .UInt8, .Int16, .UInt16, .Int32, .UInt32, .Int64, .UInt64:
            object.setValue(property.intValue, forKey: property.name)
        case .Float:
            object.setValue(Float(property.doubleValue), forKey: property.name)
        case .Double:
            object.setValue(property.doubleValue, forKey: property.name)
        case .CGFloat:
            object.setValue(CGFloat(property.doubleValue), forKey: property.name)
        case .Bool:
            object.setValue(property.boolValue, forKey: property.name)
        case .enum:
            if let enumValue = property.enumValue {
                // Aqui seria necessário converter a string de volta para um valor enum
                object.setValue(enumValue, forKey: property.name)
            }
        case .class, .struct:
            if let complexValue = property.complexValue {
                object.setValue(complexValue, forKey: property.name)
            }
        default:
            break
        }
    }
    
    /// Notifica sobre alterações em structs
    private func notifyStructChanges() {
        print("Aplicando alterações para \(title). Valor atual: \(String(describing: value))")
        
        // Para visualização e depuração
        for property in properties {
            print("Propriedade: \(property.name), Tipo: \(property.type.rawValue)")
            switch property.type {
            case .String:
                print("Valor: \(property.stringValue)")
            case .Int, .UInt, .Int8, .UInt8, .Int16, .UInt16, .Int32, .UInt32, .Int64, .UInt64:
                print("Valor: \(property.intValue)")
            case .Float, .Double, .CGFloat:
                print("Valor: \(property.doubleValue)")
            case .Bool:
                print("Valor: \(property.boolValue)")
            default:
                print("Outro valor")
            }
        }
        
        // Notifica sobre alterações usando NotificationCenter
        NotificationCenter.default.post(
            name: Notification.Name("ComplexTypeValueChanged"),
            object: nil,
            userInfo: [
                "propertyName": title,
                "valueType": componentType.rawValue,
                "properties": properties.map { 
                    var propertyData: [String: Any] = [
                        "name": $0.name,
                        "type": $0.type.rawValue
                    ]
                    
                    switch $0.type {
                    case .String:
                        propertyData["value"] = $0.stringValue
                    case .Int, .UInt, .Int8, .UInt8, .Int16, .UInt16, .Int32, .UInt32, .Int64, .UInt64:
                        propertyData["value"] = $0.intValue
                    case .Float, .Double, .CGFloat:
                        propertyData["value"] = $0.doubleValue
                    case .Bool:
                        propertyData["value"] = $0.boolValue
                    case .enum:
                        propertyData["value"] = $0.enumValue as Any
                    default:
                        break
                    }
                    
                    return propertyData
                }
            ]
        )
    }
}

/// Model para visualização e edição de propriedades
class PropertyViewModel: Identifiable, ObservableObject {
    let id: UUID
    let name: String
    let type: ComponentType
    let originalValue: Any
    
    // Propriedades para armazenar os valores editados
    var stringValue: String
    var intValue: Int
    var doubleValue: Double
    var boolValue: Bool
    var complexValue: Any?
    var enumValue: String?
    var enumCases: [String]?
    
    init(id: UUID, name: String, type: ComponentType, originalValue: Any, 
         stringValue: String, intValue: Int, doubleValue: Double, boolValue: Bool) {
        self.id = id
        self.name = name
        self.type = type
        self.originalValue = originalValue
        self.stringValue = stringValue
        self.intValue = intValue
        self.doubleValue = doubleValue
        self.boolValue = boolValue
    }
}

extension Binding where Value == Any {
    init<T>(get: @escaping () -> T, set: @escaping (T) -> Void) {
        self.init(
            get: { get() as Any },
            set: { set($0 as! T) }
        )
    }
}
