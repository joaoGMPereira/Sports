#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Funções para gerar o conteúdo do arquivo Sample
"""

from src.component_info import ComponentInfo

def generate_sample_file(component_info: ComponentInfo) -> str:
    """Gera o conteúdo do arquivo Sample com base nas informações do componente."""
    # Gera cada parte do arquivo
    imports = generate_imports()
    struct_start = generate_struct_start(component_info)
    states = generate_states(component_info)
    view_options = generate_view_options()
    body = generate_body(component_info)
    preview_component = generate_preview_component(component_info)
    configuration_section = generate_configuration_section(component_info)
    generate_code = generate_swift_code_section(component_info)
    helper_methods = generate_helper_methods(component_info)
    enum_declaration = generate_enum_declaration(component_info)
    
    # Combina todas as partes para formar o conteúdo completo do arquivo
    full_content = imports + struct_start
    full_content += "\n".join(states)
    full_content += "\n" + view_options
    full_content += body
    full_content += preview_component
    full_content += configuration_section
    full_content += generate_code
    full_content += helper_methods
    full_content += "\n}"  # Fechar a struct
    
    # Adicionar a declaração do enum no final do arquivo (fora da struct)
    full_content += enum_declaration
    
    return full_content

def generate_imports() -> str:
    """Gera a seção de imports."""
    return """import SwiftUI
import Zenith
import ZenithCoreInterface
"""

def generate_struct_start(component_info: ComponentInfo) -> str:
    """Gera o início da estrutura."""
    sample_name = f"{component_info.name}Sample"
    return f"""
struct {sample_name}: View, @preconcurrency BaseThemeDependencies {{
    @Dependency(\\.themeConfigurator) var themeConfigurator
    """

def generate_states(component_info: ComponentInfo) -> list:
    """Gera os estados (properties) para o componente."""
    states = []
    
    # Estado para texto de exemplo se for componente Text
    if component_info.name == "Text":
        states.append('    @State private var sampleText = "Exemplo de texto"')
    
    # Estados para propriedades de texto
    for prop in component_info.text_properties:
        if prop['default_value']:
            states.append(f'    @State private var {prop["name"]} = {prop["default_value"]}')
        else:
            states.append(f'    @State private var {prop["name"]} = "Exemplo"')
    
    # Estados para propriedades booleanas
    for prop in component_info.bool_properties:
        if prop['default_value']:
            states.append(f'    @State private var {prop["name"]} = {prop["default_value"]}')
        else:
            states.append(f'    @State private var {prop["name"]} = false')
    
    # Estados para propriedades numéricas
    for prop in component_info.number_properties:
        if prop['default_value']:
            states.append(f'    @State private var {prop["name"]} = {prop["default_value"]}')
        elif 'Int' in prop['data_type']:
            states.append(f'    @State private var {prop["name"]} = 0')
        else:
            states.append(f'    @State private var {prop["name"]} = 0.0')
    
    # Estado para propriedades enum
    for prop in component_info.enum_properties:
        if prop['default_value']:
            states.append(f'    @State private var {prop["name"]} = {prop["default_value"]}')
        else:
            # Use um valor padrão baseado no tipo
            enum_type = prop['data_type'].strip()
            if 'FontName' in enum_type:
                states.append(f'    @State private var {prop["name"]}: {enum_type} = .medium')
            elif 'ColorName' in enum_type:
                states.append(f'    @State private var {prop["name"]}: {enum_type} = .highlightA')
            else:
                states.append(f'    @State private var {prop["name"]}: {enum_type} = .{enum_type.split(".")[-1].lower()}')
    
    # Estados para estilos
    if component_info.style_functions and len(component_info.style_functions) > 0:
        # Usar a primeira função de estilo como padrão
        default_style = component_info.style_functions[0]
        if default_style['param_type'] == 'ColorName':
            states.append(f'    @State private var selectedColorName: ColorName = .contentA')
            states.append(f'    @State private var selectedStyleFunction = "{default_style["name"]}"')
            states.append(f'    @State private var selectedBackgroundColor: ColorName = .backgroundA')
    elif component_info.style_cases and len(component_info.style_cases) > 0:
        # Fallback para StyleCase se não houver funções de estilo
        default_style = component_info.style_cases[0]
        states.append(f'    @State private var selectedStyle = {component_info.name}StyleCase.{default_style}')
    
    return states

def generate_view_options() -> str:
    """Gera as opções de visualização."""
    return """    @State private var showAllStyles = false
    @State private var useContrastBackground = true
    @State private var showFixedHeader = false
    """

def generate_body(component_info: ComponentInfo) -> str:
    """Gera o corpo da view."""
    body = """
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
                            
                            ScrollView {
                                VStack(alignment: .leading, spacing: 8) {
"""
    
    # Adicionar visualização de todos os estilos, baseado no tipo de estilo disponível
    if component_info.style_functions and len(component_info.style_functions) > 0:
        # Usando uma organização vertical com estilos organizados por função
        body += """                                    VStack(alignment: .leading, spacing: 16) {
"""
        # Para cada função de estilo (small, medium, etc), mostrar todas as cores possíveis
        for style_func in component_info.style_functions:
            body += f"""                                        VStack(alignment: .leading) {{
                                            Text("{style_func['name']}()")
                                                .font(fonts.smallBold)
                                                .foregroundColor(colors.contentA)
                                                .padding(.bottom, 4)
                                            
                                            // Lista de exemplos de este estilo em todas as cores
                                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 8) {{
                                                ForEach(ColorName.allCases, id: \\.self) {{ color in
                                                    Text(String(describing: color))
                                                        .textStyle(.{style_func['name']}(color))
                                                        .padding(8)
                                                        .frame(maxWidth: .infinity)
                                                        .background(
                                                            RoundedRectangle(cornerRadius: 4)
                                                                .fill(getContrastBackground(for: color))
                                                        )
                                                }}
                                            }}
                                        }}
                                        .padding(.vertical, 8)
"""
        body += """                                    }
"""
    elif component_info.style_cases and len(component_info.style_cases) > 0:
        # Fallback para StyleCase
        body += f"""                                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 8) {{
                                        ForEach({component_info.name}StyleCase.allCases, id: \\.self) {{ style in
                                            Text(String(describing: style))
                                                .textStyle(style.style())
                                                .padding(8)
                                                .frame(maxWidth: .infinity)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 4)
                                                        .fill(getContrastBackground(for: getColorFromStyle(style)))
                                                )
                                        }}
                                    }}
"""
    
    body += """                                }
                            }
                            .frame(maxHeight: 200)
                        }
                    }
                }
                .padding(.horizontal)
            }
        )
    }
"""
    
    return body

def generate_preview_component(component_info: ComponentInfo) -> str:
    """Gera o componente de preview."""
    preview_component = """
    // Preview do componente com as configurações selecionadas
    private var previewComponent: some View {
        VStack {
"""

    # Baseado no componente, criar uma preview apropriada
    if component_info.name == "Text":
        # Verificar se usamos funções de estilo ou StyleCase
        if component_info.style_functions and len(component_info.style_functions) > 0:
            preview_component += """            // Preview do Text com o estilo selecionado
            Text(sampleText)
                .textStyle(getSelectedTextStyle())
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(useContrastBackground ? getContrastBackground(for: selectedColorName) : colors.backgroundB.opacity(0.2))
                )
"""
        else:
            # Fallback para StyleCase
            preview_component += """            // Preview do Text com o estilo selecionado
            Text(sampleText)
                .textStyle(selectedStyle.style())
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(useContrastBackground ? getContrastBackground(for: getColorFromStyle(selectedStyle)) : colors.backgroundB.opacity(0.2))
                )
"""
    else:
        # Gerar preview genérica para outros componentes
        preview_component += f"""            // Preview do componente com as configurações atuais
            {component_info.name}("""
        
        # Adicionar parâmetros baseados nas propriedades
        params = []
        
        # Adicionar texto se for relevante
        if component_info.text_properties:
            for prop in component_info.text_properties:
                params.append(f'{prop["name"]}: {prop["name"]}')
        
        # Adicionar booleanos
        for prop in component_info.bool_properties:
            params.append(f'{prop["name"]}: {prop["name"]}')
            
        # Adicionar numéricos
        for prop in component_info.number_properties:
            params.append(f'{prop["name"]}: {prop["name"]}')
            
        # Adicionar enums
        for prop in component_info.enum_properties:
            params.append(f'{prop["name"]}: {prop["name"]}')
        
        preview_component += ", ".join(params)
        
        preview_component += """)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(useContrastBackground ? colors.backgroundA : colors.backgroundB.opacity(0.2))
                )
"""
    
    preview_component += """        }
    }
"""
    
    return preview_component

def generate_configuration_section(component_info: ComponentInfo) -> str:
    """Gera a seção de configuração."""
    configuration_section = """
    // Área de configuração
    private var configurationSection: some View {
        VStack(spacing: 16) {
"""
    
    # Se for Text, adicionar campo para texto de exemplo
    if component_info.name == "Text":
        configuration_section += """            // Campo para texto de exemplo
            TextField("Texto de exemplo", text: $sampleText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                
"""
    
    # Adicionar controles para cada propriedade de texto
    for prop in component_info.text_properties:
        configuration_section += f"""            // Campo para editar {prop['name']}
            TextField("{prop['name'].capitalize()}", text: ${prop['name']})
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                
"""
    
    # Adicionar controles para propriedades booleanas
    for prop in component_info.bool_properties:
        configuration_section += f"""            // Toggle para {prop['name']}
            Toggle("{prop['name'].capitalize()}", isOn: ${prop['name']})
                .toggleStyle(.default(.highlightA))
                .padding(.horizontal)
                
"""
    
    # Adicionar controles para propriedades numéricas
    for prop in component_info.number_properties:
        if 'Int' in prop['data_type']:
            configuration_section += f"""            // Slider para {prop['name']}
            VStack(alignment: .leading) {{
                Text("{prop['name'].capitalize()}: \\({prop['name']})")
                Slider(value: Binding(
                    get: {{ Double({prop['name']}) }},
                    set: {{ {prop['name']} = Int($0) }}
                ), in: 0...100)
            }}
            .padding(.horizontal)
            
"""
        else:
            configuration_section += f"""            // Slider para {prop['name']}
            VStack(alignment: .leading) {{
                Text("{prop['name'].capitalize()}: \\({prop['name']}, specifier: "%.1f")")
                Slider(value: ${prop['name']}, in: 0...1)
            }}
            .padding(.horizontal)
            
"""
    
    # Adicionar seletores para propriedades enum
    for prop in component_info.enum_properties:
        enum_type = prop['data_type'].strip()
        configuration_section += f"""            // Seletor para {prop['name']}
            EnumSelector<{enum_type}>(
                title: "{prop['name'].capitalize()}",
                selection: ${prop['name']},
                columnsCount: 3,
                height: 120
            )
            
"""
    
    # Adicionar seletor de estilo
    if component_info.style_functions and len(component_info.style_functions) > 0:
        # Seletor para funções de estilo usando EnumSelector
        style_func_names = [func['name'] for func in component_info.style_functions]
        
        # Referência à enum que será declarada no final do arquivo
        configuration_section += f"""            // Seletor para função de estilo
            EnumSelector<StyleFunctionName>(
                title: "Estilo",
                selection: Binding(
                    get: {{ StyleFunctionName(rawValue: selectedStyleFunction) ?? .{style_func_names[0]} }},
                    set: {{ selectedStyleFunction = $0.rawValue }}
                ),
                columnsCount: 3,
                height: 120
            )
            
            // Seletor para cor
            EnumSelector<ColorName>(
                title: "Cor",
                selection: $selectedColorName,
                columnsCount: 3,
                height: 120
            )
            
"""
    elif component_info.style_cases and len(component_info.style_cases) > 0:
        # Fallback para StyleCase
        configuration_section += f"""            // Seletor de estilo
            EnumSelector<{component_info.name}StyleCase>(
                title: "Estilo",
                selection: $selectedStyle,
                columnsCount: 3,
                height: 120
            )
            
"""
    
    # Adicionar toggles para opções de visualização
    configuration_section += """            // Toggles para opções
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
    
    return configuration_section

def generate_swift_code_section(component_info: ComponentInfo) -> str:
    """Gera a seção para geração de código Swift."""
    generate_code = '''
    // Gera o código Swift para o componente configurado
    private func generateSwiftCode() -> String {
        // Aqui você pode personalizar a geração de código com base no componente
        var code = "// Código gerado automaticamente\\n"
        
        code += """
'''
    
    # Adicionar exemplo de código gerado
    if component_info.name == "Text":
        # Verificar se usamos funções de estilo ou StyleCase
        if component_info.style_functions and len(component_info.style_functions) > 0:
            generate_code += "        Text(sampleText)\n"
            generate_code += "            .textStyle(." + "\\(selectedStyleFunction)" + "(." + "\\(String(describing: selectedColorName))" + "))\n"
        else:
            # Fallback para StyleCase
            generate_code += "        Text(sampleText)\n"
            generate_code += "            .textStyle(selectedStyle.style())\n"
    else:
        # Gerar código para outros componentes
        generate_code += f"        {component_info.name}("
        
        # Adicionar parâmetros do init
        params = []
        
        # Adicionar texto se for relevante
        if component_info.text_properties:
            for prop in component_info.text_properties:
                params.append(f'{prop["name"]}: {prop["name"]}')
        
        # Adicionar booleanos
        for prop in component_info.bool_properties:
            params.append(f'{prop["name"]}: {prop["name"]}')
            
        # Adicionar numéricos
        for prop in component_info.number_properties:
            params.append(f'{prop["name"]}: {prop["name"]}')
            
        # Adicionar enums
        for prop in component_info.enum_properties:
            params.append(f'{prop["name"]}: {prop["name"]}')
            
        generate_code += ", ".join(params)
        
        generate_code += ")\n"
    
    generate_code += '''
        """
        
        return code
    }
'''
    
    return generate_code

def generate_helper_methods(component_info: ComponentInfo) -> str:
    """Gera os métodos auxiliares."""
    helper_methods = ""
    if component_info.name == "Text" and component_info.style_functions and len(component_info.style_functions) > 0:
        helper_methods = """
    // Helper para obter o TextStyle correspondente à função selecionada
    private func getSelectedTextStyle() -> some TextStyle {
        switch selectedStyleFunction {
"""
        for func_info in component_info.style_functions:
            helper_methods += f"""        case "{func_info['name']}":
            return .{func_info['name']}(selectedColorName)
"""
        
        helper_methods += """        default:
            return .small(selectedColorName)
        }
    }
    
    // Gera um fundo de contraste adequado para a cor especificada
    private func getContrastBackground(for colorName: ColorName) -> Color {
        let color = colors.color(by: colorName) ?? colors.backgroundB
        
        // Extrair componentes RGB da cor
        let uiColor = UIColor(color)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        // Calcular luminosidade da cor (fórmula perceptual)
        let luminance = 0.299 * red + 0.587 * green + 0.114 * blue
        
        // Tratamento específico para cinzas médios (como backgroundC)
        if colorName == .backgroundC || (abs(red - green) < 0.1 && abs(green - blue) < 0.1 && luminance > 0.2 && luminance < 0.4) {
            // Para o cinza médio, criar um contraste mais definido e claro
            return Color.white.opacity(0.3)
        }
        
        // Para cores com luminância média (nem claras nem escuras)
        if luminance > 0.3 && luminance < 0.7 {
            // Verificar se é mais para o claro ou para o escuro
            if luminance < 0.5 {
                // Tendendo ao escuro, usar um contraste claro mais forte
                return Color.white.opacity(0.35)
            } else {
                // Tendendo ao claro, usar um contraste escuro mais forte
                return Color.black.opacity(0.2)
            }
        }
        
        // Para cores bem escuras, usar um contraste bem claro
        if luminance < 0.3 {
            return Color.white.opacity(0.4)
        }
        
        // Para cores bem claras, usar um contraste escuro
        return Color(red: max(red - 0.3, 0.0), 
                    green: max(green - 0.3, 0.0), 
                    blue: max(blue - 0.3, 0.0))
                .opacity(0.25)
    }
"""
    elif component_info.name == "Text":
        helper_methods = """
    // Helper para obter o nome do TextStyle correspondente
    private func getTextStyleName() -> String {
        // Identificamos o TextStyleCase mais próximo com base na fonte e cor selecionadas
        return String(describing: selectedStyle).lowercased()
    }
    
    // Obtém a cor associada a um StyleCase
    private func getColorFromStyle(_ style: TextStyleCase) -> ColorName {
        let styleName = String(describing: style)
        
        if styleName.contains("HighlightA") {
            return .highlightA
        } else if styleName.contains("BackgroundA") {
            return .backgroundA
        } else if styleName.contains("BackgroundB") {
            return .backgroundB
        } else if styleName.contains("BackgroundC") {
            return .backgroundC
        } else if styleName.contains("BackgroundD") {
            return .backgroundD
        } else if styleName.contains("ContentA") {
            return .contentA
        } else if styleName.contains("ContentB") {
            return .contentB
        } else if styleName.contains("ContentC") {
            return .contentC
        } else if styleName.contains("Critical") {
            return .critical
        } else if styleName.contains("Attention") {
            return .attention
        } else if styleName.contains("Danger") {
            return .danger
        } else if styleName.contains("Positive") {
            return .positive
        } else {
            return .none
        }
    }
    
    // Gera um fundo de contraste adequado para a cor especificada
    private func getContrastBackground(for colorName: ColorName) -> Color {
        let color = colors.color(by: colorName) ?? colors.backgroundB
        
        // Extrair componentes RGB da cor
        let uiColor = UIColor(color)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        // Calcular luminosidade da cor (fórmula perceptual)
        let luminance = 0.299 * red + 0.587 * green + 0.114 * blue
        
        // Tratamento específico para cinzas médios (como backgroundC)
        if colorName == .backgroundC || (abs(red - green) < 0.1 && abs(green - blue) < 0.1 && luminance > 0.2 && luminance < 0.4) {
            // Para o cinza médio, criar um contraste mais definido e claro
            return Color.white.opacity(0.3)
        }
        
        // Para cores com luminância média (nem claras nem escuras)
        if luminance > 0.3 && luminance < 0.7 {
            // Verificar se é mais para o claro ou para o escuro
            if luminance < 0.5 {
                // Tendendo ao escuro, usar um contraste claro mais forte
                return Color.white.opacity(0.35)
            } else {
                // Tendendo ao claro, usar um contraste escuro mais forte
                return Color.black.opacity(0.2)
            }
        }
        
        // Para cores bem escuras, usar um contraste bem claro
        if luminance < 0.3 {
            return Color.white.opacity(0.4)
        }
        
        // Para cores bem claras, usar um contraste escuro
        return Color(red: max(red - 0.3, 0.0), 
                    green: max(green - 0.3, 0.0), 
                    blue: max(blue - 0.3, 0.0))
                .opacity(0.25)
    }
"""
    
    return helper_methods

def generate_enum_declaration(component_info: ComponentInfo) -> str:
    """Gera a declaração de enum no final do arquivo."""
    enum_declaration = ""
    if component_info.style_functions and len(component_info.style_functions) > 0:
        style_func_names = [func['name'] for func in component_info.style_functions]
        enum_declaration = f"""
// Enum para seleção das funções de estilo
fileprivate enum StyleFunctionName: String, CaseIterable, Identifiable {{
    case {", ".join([f'{name} = "{name}"' for name in style_func_names])}
    
    var id: Self {{ self }}
}}
"""
    
    return enum_declaration