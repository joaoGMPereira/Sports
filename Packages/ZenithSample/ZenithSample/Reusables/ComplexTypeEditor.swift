import SwiftUI
import Zenith
import ZenithCoreInterface


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


enum ComponentType: String, Equatable, CaseIterable {
    case `class`
    case `struct`
    case `enum`
    case `protocol`
    case `extension`
    case `typealias`
    case StringImageEnum
    case Primitive
    case ColorName
    case FontName
    case SFSymbol
    case Closure
    case Int, UInt, Int8, UInt8, Int16, UInt16, Int32, UInt32, Int64, UInt64, Float, Double, Bool, String, Character, Void, Optional, Array, Dictionary, Set, Data, Date, URL, CGFloat
    case notFound
    
    var complexType: Bool {
        self == .class || self == .struct
    }
}

/// Componente que edita tipos complexos (struct/class) diretamente na view
/// sem a necessidade de abrir um sheet
struct ComplexTypeEditor<T: Any>: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator
    
    // MARK: - Propriedades
    
    /// O tipo de componente
    let componentType: ComponentType
    
    /// A instância do valor atual
    @Binding var value: T
    
    /// Estado para armazenar as propriedades extraídas do tipo complexo
    @State private var properties: [PropertyViewModel] = []
    
    /// Controla se as propriedades estão expandidas
    @State private var isExpanded: Bool = false
    
    //let completion: ([String: Any]) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Botão para expandir/recolher as propriedades
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
                
                // Carregar propriedades quando expandir
                if isExpanded && properties.isEmpty {
                    loadProperties()
                }
            }) {
                HStack {
                    Image(systemSymbol: isExpanded ? .chevronDown : .chevronRight)
                        .foregroundColor(colors.contentA)
                    
                    Text("Propriedades")
                        .font(fonts.smallBold)
                        .foregroundColor(colors.contentA)
                    
                    Spacer()
                }
            }
            
            if isExpanded {
                if properties.isEmpty {
                    Text("Carregando propriedades...")
                        .font(fonts.small)
                        .foregroundColor(colors.contentB)
                        .padding(.leading, 16)
                } else {
                    VStack(spacing: 12) {
                        ForEach(properties) { propertyViewModel in
                            propertyEditor(for: propertyViewModel)
                        }
                    }
                }
            }
        }
    }
    
    /// Cria o editor apropriado para cada tipo de propriedade
    @ViewBuilder
    private func propertyEditor(for propertyViewModel: PropertyViewModel) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("\(propertyViewModel.name): \(propertyViewModel.type.rawValue)")
                .font(fonts.smallBold)
                .foregroundColor(colors.contentA)
            
            switch propertyViewModel.type {
            case .String:
                TextField("Valor", text: Binding(
                    get: { propertyViewModel.stringValue },
                    set: { 
                        if let index = self.properties.firstIndex(where: { $0.id == propertyViewModel.id }) {
                            self.properties[index].stringValue = $0
                            applyChanges()
                        }
                    }
                ))
                .textFieldStyle(.contentA(), placeholder: "Texto")
                
            case .Int, .UInt, .Int8, .UInt8, .Int16, .UInt16, .Int32, .UInt32, .Int64, .UInt64:
                HStack {
                    TextField("Valor", text: Binding(
                        get: { String(propertyViewModel.intValue) },
                        set: { 
                            if let intValue = Int($0),
                               let index = self.properties.firstIndex(where: { $0.id == propertyViewModel.id }) {
                                self.properties[index].intValue = intValue
                                applyChanges()
                            }
                        }
                    ))
                    .textFieldStyle(.contentA(), placeholder: "0")
                    .keyboardType(.numberPad)
                    
                    Stepper("", value: Binding(
                        get: { propertyViewModel.intValue },
                        set: {
                            if let index = self.properties.firstIndex(where: { $0.id == propertyViewModel.id }) {
                                self.properties[index].intValue = $0
                                applyChanges()
                            }
                        }
                    ))
                }
                
            case .Float, .Double, .CGFloat:
                VStack(spacing: 4) {
                    TextField("Valor", text: Binding(
                        get: { String(format: "%.2f", propertyViewModel.doubleValue) },
                        set: { 
                            if let doubleValue = Double($0),
                               let index = self.properties.firstIndex(where: { $0.id == propertyViewModel.id }) {
                                self.properties[index].doubleValue = doubleValue
                                applyChanges()
                            }
                        }
                    ))
                    .textFieldStyle(.contentA(), placeholder: "0.0")
                    .keyboardType(.decimalPad)
                    
                    Slider(value: Binding(
                        get: { propertyViewModel.doubleValue },
                        set: {
                            if let index = self.properties.firstIndex(where: { $0.id == propertyViewModel.id }) {
                                self.properties[index].doubleValue = $0
                                applyChanges()
                            }
                        }
                    ), in: 0...1)
                }
                
            case .Bool:
                Toggle(propertyViewModel.name, isOn: Binding(
                    get: { propertyViewModel.boolValue },
                    set: { 
                        if let index = self.properties.firstIndex(where: { $0.id == propertyViewModel.id }) {
                            self.properties[index].boolValue = $0
                            applyChanges()
                        }
                    }
                ))
                .toggleStyle(.default(.highlightA))
                
            case .enum:
                if let enumCases = propertyViewModel.enumCases, !enumCases.isEmpty {
                    Picker(propertyViewModel.name, selection: Binding(
                        get: { propertyViewModel.enumValue ?? enumCases[0] },
                        set: { 
                            if let index = self.properties.firstIndex(where: { $0.id == propertyViewModel.id }) {
                                self.properties[index].enumValue = $0
                                applyChanges()
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
                        .font(fonts.small)
                        .foregroundColor(colors.contentB)
                }
                
            default:
                Text("Tipo não suportado: \(propertyViewModel.type.rawValue)")
                    .font(fonts.small)
                    .foregroundColor(colors.contentB)
            }
        }
        .padding(8)
        .background(colors.backgroundB.opacity(0.3))
        .cornerRadius(6)
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
    
    /// Determina o tipo de componente com base no mirror
    private func determineComponentType(from mirror: Mirror) -> ComponentType {
        let typeName = String(describing: mirror.subjectType)
        
        // Tipos primitivos
        switch typeName {
        case "String":
            return .String
        case "Int":
            return .Int
        case "UInt":
            return .UInt
        case "Int8":
            return .Int8
        case "UInt8":
            return .UInt8
        case "Int16":
            return .Int16
        case "UInt16":
            return .UInt16
        case "Int32":
            return .Int32
        case "UInt32":
            return .UInt32
        case "Int64":
            return .Int64
        case "UInt64":
            return .UInt64
        case "Float":
            return .Float
        case "Double":
            return .Double
        case "Bool":
            return .Bool
        case "CGFloat":
            return .CGFloat
        default:
            break
        }
        
        // Verificar outros tipos
        if typeName.contains("Enum") {
            return .enum
        } else if typeName.contains("struct") {
            return .struct
        } else if typeName.contains("class") {
            return .class
        }
        
        return .notFound
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
    
    /// Tenta obter os casos de um enum (limitado a enums "standard")
    private func getEnumCases(for value: Any) -> [String]? {
        // Este é um método simplificado para tentar obter os casos de um enum
        // Para enums customizados, precisaria de uma abordagem mais robusta
        let typeName = String(describing: type(of: value))
        let enumValue = String(describing: value)
        
        // Casos comuns
        switch typeName {
        case "ColorName":
            return ["contentA", "contentB", "contentC", "contentD", "highlightA", "highlightB", "status", "danger", "success", "warning"]
        case "FontName":
            return ["small", "medium", "large", "smallBold", "mediumBold", "largeBold"]
        default:
            // Tentar extrair o caso atual
            if let dotIndex = enumValue.firstIndex(of: ".") {
                let caseName = String(enumValue[enumValue.index(after: dotIndex)...])
                return [caseName]
            }
            return nil
        }
    }
    
    /// Aplica as alterações ao objeto original
    private func applyChanges() {
//        completion([
//            "valueType": componentType.rawValue,
//            "properties": properties.map {
//                var propertyData: [String: Any] = [
//                    "name": $0.name,
//                    "type": $0.type.rawValue
//                ]
//                
//                switch $0.type {
//                case .String:
//                    propertyData["value"] = $0.stringValue
//                case .Int, .UInt, .Int8, .UInt8, .Int16, .UInt16, .Int32, .UInt32, .Int64, .UInt64:
//                    propertyData["value"] = $0.intValue
//                case .Float, .Double, .CGFloat:
//                    propertyData["value"] = $0.doubleValue
//                case .Bool:
//                    propertyData["value"] = $0.boolValue
//                case .enum:
//                    propertyData["value"] = $0.enumValue as Any
//                default:
//                    break
//                }
//                
//                return propertyData
//            }
//        ])
    }
}
