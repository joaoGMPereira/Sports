import SwiftUI
import Zenith
import ZenithCoreInterface

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

/// Componente que exibe um botão para configurar tipos complexos (struct/class)
struct ComplexTypeSelectorView<T: Any>: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\.themeConfigurator) var themeConfigurator
    
    // MARK: - Propriedades
    
    /// Título do componente
    let title: String
    
    /// O tipo de componente
    let componentType: ComponentType
    
    /// A instância do valor atual
    @Binding var value: T
    
    /// Flag para controlar a abertura da sheet
    @State private var showingConfigSheet = false
    
    // MARK: - Corpo da View
    
    var body: some View {
        Button(action: {
            showingConfigSheet = true
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(fonts.mediumBold)
                        .foregroundColor(colors.contentA)
                    
                    Text(componentType.rawValue)
                        .font(fonts.small)
                        .foregroundColor(colors.contentB)
                }
                
                Spacer()
                
                Image(systemSymbol: .gearshape)
                    .foregroundColor(colors.contentA)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(colors.backgroundB.opacity(0.7))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(colors.backgroundC, lineWidth: 1)
            )
        }
        .sheet(isPresented: $showingConfigSheet) {
            ComplexTypeConfigSheet(
                title: title,
                componentType: componentType,
                value: $value
            )
        }
    }
}
