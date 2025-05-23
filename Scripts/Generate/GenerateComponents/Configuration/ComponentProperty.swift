import Foundation

struct ComponentProperty: Hashable {
    let name: String
    let type: String
    let component: any ComponentProtocol
    let defaultValue: String?
    // Propriedades aninhadas para tipos complexos (structs ou classes)
    var innerParameters: [ComponentProperty] = []
    
    static func == (lhs: ComponentProperty, rhs: ComponentProperty) -> Bool {
        // Compare all properties except 'component' which is an existential type
        return lhs.name == rhs.name &&
               lhs.type == rhs.type &&
               lhs.defaultValue == rhs.defaultValue &&
               lhs.component.name == rhs.component.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(type)
        hasher.combine(component.name)
        hasher.combine(defaultValue)
    }
}
