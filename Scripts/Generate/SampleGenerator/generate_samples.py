#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import sys
import re
import argparse
from typing import List, Dict, Optional, Tuple

"""
Script para gerar arquivos Sample para componentes do Zenith
Este script analisa arquivos View, Configuration e Styles de um componente
e gera automaticamente um arquivo Sample para demonstrar o uso do componente.
"""

# Configurações
ZENITH_PATH = os.path.expanduser("~/KettleGym/Packages/Zenith")
ZENITH_SAMPLE_PATH = os.path.expanduser("~/KettleGym/Packages/ZenithSample")
COMPONENTS_PATH = os.path.join(ZENITH_PATH, "Sources/Zenith")
SAMPLES_PATH = os.path.join(ZENITH_SAMPLE_PATH, "ZenithSample")

# Estrutura para armazenar informações do componente
class ComponentInfo:
    def __init__(self, name: str, type_path: str):
        self.name = name
        self.type_path = type_path  # BaseElements/Natives ou Components/Customs
        self.view_path = ""
        self.config_path = ""
        self.styles_path = ""
        self.properties = []
        self.style_cases = []  # Para compatibilidade
        self.style_functions = []  # Funções de estilo como small(), medium(), etc.
        self.enum_properties = []  # Propriedades que são enums
        self.text_properties = []  # Propriedades de texto
        self.bool_properties = []  # Propriedades booleanas
        self.number_properties = []  # Propriedades numéricas
        
    def __str__(self):
        return f"Component: {self.name} (Type: {self.type_path})"

def parse_swift_file(file_path: str) -> str:
    """Lê e retorna o conteúdo de um arquivo Swift."""
    try:
        with open(file_path, 'r') as file:
            return file.read()
    except Exception as e:
        print(f"Erro ao ler o arquivo {file_path}: {e}")
        return ""

def extract_properties(content: str) -> List[Dict]:
    """Extrai propriedades de uma estrutura/classe Swift."""
    # Padrão para localizar propriedades
    property_pattern = r'(var|let)\s+(\w+)\s*:\s*([^{=\n]+)(?:\s*=\s*([^{\n]+))?'
    properties = []
    
    for match in re.finditer(property_pattern, content):
        prop_type = match.group(1)  # var ou let
        prop_name = match.group(2)  # nome da propriedade
        prop_data_type = match.group(3).strip()  # tipo de dados
        default_value = match.group(4)  # valor padrão, se houver
        
        if default_value:
            default_value = default_value.strip()
        
        properties.append({
            'type': prop_type,
            'name': prop_name,
            'data_type': prop_data_type,
            'default_value': default_value
        })
    
    return properties

def extract_style_functions(content: str, component_name: str) -> List[Dict]:
    """Extrai funções de estilo de um arquivo de estilos."""
    # Procura por extensões como: public extension TextStyle where Self == BaseTextStyle
    extension_pattern = rf'public\s+extension\s+{component_name}Style\s+where\s+Self\s+==\s+Base{component_name}Style'
    style_functions = []
    
    extension_match = re.search(extension_pattern, content)
    if extension_match:
        # Encontrar abertura de chave após a extensão
        opening_brace_pos = content.find('{', extension_match.end())
        if opening_brace_pos > 0:
            # Encontrar chave de fechamento correspondente
            brace_count = 1
            i = opening_brace_pos + 1
            while i < len(content) and brace_count > 0:
                if content[i] == '{':
                    brace_count += 1
                elif content[i] == '}':
                    brace_count -= 1
                i += 1
                
            if brace_count == 0:
                extension_content = content[opening_brace_pos:i]
                
                # Extrair funções de estilo
                function_pattern = r'static\s+func\s+(\w+)\s*\(\s*(?:_\s+)?(\w+)\s*:\s*(\w+)(?:\s*(?:,|\)|\s))?'
                for match in re.finditer(function_pattern, extension_content):
                    func_name = match.group(1)  # Nome da função
                    param_name = match.group(2)  # Nome do parâmetro
                    param_type = match.group(3)  # Tipo do parâmetro
                    
                    style_functions.append({
                        'name': func_name,
                        'param_name': param_name,
                        'param_type': param_type
                    })
    
    return style_functions

def extract_style_cases(content: str) -> List[str]:
    """Extrai casos de estilo de um arquivo StyleCase."""
    # Padrão para localizar enum cases em SwiftUI
    case_pattern = r'case\s+(\w+)'
    cases = []
    
    # Verifica se há um enum de StyleCase
    enum_match = re.search(r'enum\s+(\w+StyleCase)', content)
    if enum_match:
        # Extrair todos os casos dentro deste enum
        enum_name = enum_match.group(1)
        enum_content = re.search(rf'{enum_name}[^{{]*{{(.*?)}}', content, re.DOTALL)
        
        if enum_content:
            cases_content = enum_content.group(1)
            for match in re.finditer(case_pattern, cases_content):
                cases.append(match.group(1))
    
    return cases

def categorize_properties(properties: List[Dict]) -> Tuple[List[Dict], List[Dict], List[Dict], List[Dict]]:
    """Categoriza propriedades por tipo para usar controles apropriados."""
    enum_props = []
    text_props = []
    bool_props = []
    number_props = []
    
    for prop in properties:
        if prop['name'] in ['body', 'colors', 'fonts']:
            continue
            
        # Detecta propriedades de enum
        if 'Case' in prop['data_type'] or prop['data_type'] in ['FontName', 'ColorName']:
            enum_props.append(prop)
        # Detecta propriedades de texto
        elif 'String' in prop['data_type']:
            text_props.append(prop)
        # Detecta propriedades booleanas
        elif 'Bool' in prop['data_type']:
            bool_props.append(prop)
        # Detecta propriedades numéricas
        elif any(t in prop['data_type'] for t in ['Int', 'Double', 'CGFloat', 'Float']):
            number_props.append(prop)
    
    return enum_props, text_props, bool_props, number_props

def find_component_files(component_name: str) -> ComponentInfo:
    """Localiza os arquivos View, Configuration e Styles de um componente."""
    component_info = None
    
    # Determinar o tipo de componente (BaseElements/Natives ou Components/Customs)
    possible_paths = [
        os.path.join(COMPONENTS_PATH, "BaseElements/Natives", component_name),
        os.path.join(COMPONENTS_PATH, "Components/Customs", component_name)
    ]
    
    for base_path in possible_paths:
        if os.path.exists(base_path):
            type_path = "BaseElements/Natives" if "BaseElements" in base_path else "Components/Customs"
            component_info = ComponentInfo(component_name, type_path)
            break
    
    if not component_info:
        print(f"Componente '{component_name}' não encontrado.")
        return None
    
    # Localizar arquivos View, Configuration e Styles
    files = os.listdir(os.path.join(COMPONENTS_PATH, component_info.type_path, component_name))
    
    for file in files:
        file_path = os.path.join(COMPONENTS_PATH, component_info.type_path, component_name, file)
        
        if f"{component_name}View" in file:
            component_info.view_path = file_path
        elif f"{component_name}Configuration" in file:
            component_info.config_path = file_path
        elif f"{component_name}Styles" in file:
            component_info.styles_path = file_path
    
    # Extrair propriedades, funções de estilo e casos de estilo
    if component_info.view_path:
        content = parse_swift_file(component_info.view_path)
        component_info.properties = extract_properties(content)
        
        # Categorizar propriedades
        (component_info.enum_properties, 
         component_info.text_properties, 
         component_info.bool_properties, 
         component_info.number_properties) = categorize_properties(component_info.properties)
    
    if component_info.styles_path:
        content = parse_swift_file(component_info.styles_path)
        component_info.style_functions = extract_style_functions(content, component_name)
        
        # Se não encontrou funções de estilo, tenta extrair do StyleCase (para compatibilidade)
        if not component_info.style_functions:
            component_info.style_cases = extract_style_cases(content)
    
    return component_info

def generate_sample_file(component_info: ComponentInfo) -> str:
    """Gera o conteúdo do arquivo Sample com base nas informações do componente."""
    sample_name = f"{component_info.name}Sample"
    
    # Imports
    imports = """import SwiftUI
import Zenith
import ZenithCoreInterface
"""
    
    # Início da estrutura
    struct_start = f"""
struct {sample_name}: View, @preconcurrency BaseThemeDependencies {{
    @Dependency(\\.themeConfigurator) var themeConfigurator
    """
    
    # Estados para propriedades e estilo
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
    elif component_info.style_cases and len(component_info.style_cases) > 0:
        # Fallback para StyleCase se não houver funções de estilo
        default_style = component_info.style_cases[0]
        states.append(f'    @State private var selectedStyle = {component_info.name}StyleCase.{default_style}')
    
    # Toggles para opções de visualização
    view_options = """    @State private var showAllStyles = false
    @State private var useContrastBackground = true
    @State private var showFixedHeader = false
    """
    
    # Implementação do body
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
    
    # Implementação do previewComponent
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
    
    # Implementação da configurationSection
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
    
    # Implementação da função generateSwiftCode
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
    
    # Helper para obter o estilo selecionado
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
        
        // Verificar se estamos lidando com a cor backgroundC ou cores com luminosidade similar
        if (abs(luminance - 0.27) < 0.1) { // 0.27 é aproximadamente a luminosidade de #444444
            // Para cinzas médios como backgroundC, criar um contraste mais definido
            if luminance < 0.3 {
                // Para cinzas que tendem ao escuro, usar um contraste bem claro
                return Color.white.opacity(0.25)
            } else {
                // Para cinzas que tendem ao claro, usar um contraste bem escuro
                return Color.black.opacity(0.15)
            }
        }
        
        // Para as demais cores, manter a lógica anterior mas aumentar o contraste
        if luminance < 0.5 {
            // Para cores escuras, gerar um contraste claro
            return Color(red: min(red + 0.4, 1.0), 
                        green: min(green + 0.4, 1.0), 
                        blue: min(blue + 0.4, 1.0))
                .opacity(0.35)
        } else {
            // Para cores claras, gerar um contraste escuro
            return Color(red: max(red - 0.25, 0.0), 
                        green: max(green - 0.25, 0.0), 
                        blue: max(blue - 0.25, 0.0))
                .opacity(0.2)
        }
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
        
        // Verificar se estamos lidando com a cor backgroundC ou cores com luminosidade similar
        if (abs(luminance - 0.27) < 0.1) { // 0.27 é aproximadamente a luminosidade de #444444
            // Para cinzas médios como backgroundC, criar um contraste mais definido
            if luminance < 0.3 {
                // Para cinzas que tendem ao escuro, usar um contraste bem claro
                return Color.white.opacity(0.25)
            } else {
                // Para cinzas que tendem ao claro, usar um contraste bem escuro
                return Color.black.opacity(0.15)
            }
        }
        
        // Para as demais cores, manter a lógica anterior mas aumentar o contraste
        if luminance < 0.5 {
            // Para cores escuras, gerar um contraste claro
            return Color(red: min(red + 0.4, 1.0), 
                        green: min(green + 0.4, 1.0), 
                        blue: min(blue + 0.4, 1.0))
                .opacity(0.35)
        } else {
            // Para cores claras, gerar um contraste escuro
            return Color(red: max(red - 0.25, 0.0), 
                        green: max(green - 0.25, 0.0), 
                        blue: max(blue - 0.25, 0.0))
                .opacity(0.2)
        }
    }
"""
    
    # Adicionar a declaração da enum StyleFunctionName no final do arquivo (fora da struct)
    # para componentes com funções de estilo
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
    
    # Combinar tudo
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

def create_sample_file(component_name: str):
    """Cria um arquivo Sample para um componente especificado."""
    component_info = find_component_files(component_name)
    
    if not component_info:
        return False
    
    # Determinar o caminho para salvar o arquivo Sample
    sample_path = os.path.join(SAMPLES_PATH, component_info.type_path, component_name)
    
    # Criar os diretórios, se necessário
    os.makedirs(sample_path, exist_ok=True)
    
    # Gerar o conteúdo do arquivo Sample
    sample_content = generate_sample_file(component_info)
    
    # Salvar o arquivo
    sample_file_path = os.path.join(sample_path, f"{component_name}Sample.swift")
    try:
        with open(sample_file_path, 'w') as file:
            file.write(sample_content)
        print(f"Arquivo Sample criado com sucesso: {sample_file_path}")
        return True
    except Exception as e:
        print(f"Erro ao criar o arquivo Sample: {e}")
        return False

def main():
    """Função principal."""
    parser = argparse.ArgumentParser(description='Gerador de arquivos Sample para componentes Zenith')
    parser.add_argument('component', help='Nome do componente para gerar o Sample (ex: Text, Button, etc.)')
    
    args = parser.parse_args()
    
    create_sample_file(args.component)

if __name__ == "__main__":
    main()