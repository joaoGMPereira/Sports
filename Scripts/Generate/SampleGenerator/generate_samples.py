#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import sys
import re
import argparse
import logging
from typing import List, Dict, Optional, Tuple, Set, Any, Callable, Type

"""
Script para gerar arquivos Sample para componentes do Zenith
Este script analisa arquivos View, Configuration e Styles de um componente
e gera automaticamente um arquivo Sample para demonstrar o uso do componente.
"""

# Configuração de logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger('generate_samples')

# Definição prévia da função create_button_sample_file para evitar erros de referência
def create_button_sample_file() -> str:
    """Cria um conteúdo fixo para o arquivo de amostra do Button."""
    return '''import SwiftUI
import Zenith
import ZenithCoreInterface

struct ButtonSample: View, @preconcurrency BaseThemeDependencies {
    @Dependency(\\.themeConfigurator) var themeConfigurator
    @State private var selectedStyle = ButtonStyleCase.contentA
    @State private var buttonTitle = "Botão de Exemplo"
    @State private var showAllStyles = false
    @State private var useContrastBackground = true
    @State private var showFixedHeader = false
    
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
                                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 8) {
                                        ForEach(ButtonStyleCase.allCases, id: \\.self) { style in
                                            VStack {
                                                Text(String(describing: style))
                                                    .font(fonts.small)
                                                    .foregroundColor(colors.contentA)
                                                    .padding(.bottom, 2)
                                                
                                                Button(buttonTitle) {
                                                    // Ação vazia para exemplo
                                                }
                                                .buttonStyle(style.style())
                                                .padding(8)
                                                .frame(maxWidth: .infinity)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 4)
                                                        .fill(getContrastBackground(for: getColorFromStyle(style)))
                                                )
                                            }
                                        }
                                    }
                                }
                            }
                            .frame(maxHeight: 200)
                        }
                    }
                }
                .padding(.horizontal)
            }
        )
    }

    // Preview do componente com as configurações selecionadas
    private var previewComponent: some View {
        VStack {
            // Preview do componente com as configurações atuais
            Button(buttonTitle) {
                print("Botão pressionado")
            }
            .buttonStyle(selectedStyle.style())
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(useContrastBackground ? colors.backgroundA : colors.backgroundB.opacity(0.2))
            )
        }
    }

    // Área de configuração
    private var configurationSection: some View {
        VStack(spacing: 16) {
            // Campo para texto do botão
            TextField("Texto do botão", text: $buttonTitle)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            // Seletor de estilo
            EnumSelector<ButtonStyleCase>(
                title: "Estilo",
                selection: $selectedStyle,
                columnsCount: 3,
                height: 120
            )
            
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
    
    // Gera o código Swift para o componente configurado
    private func generateSwiftCode() -> String {
        // Aqui você pode personalizar a geração de código com base no componente
        var code = "// Código gerado automaticamente\\n"
        
        code += """
        Button("\\(buttonTitle)") {
            // Ação do botão aqui
        }
        .buttonStyle(selectedStyle.style())
        """
        
        return code
    }
    
    // Helper para obter o estilo correspondente à função selecionada
    private func getSelectedStyle() -> some ButtonStyle {
        return selectedStyle.style()
    }
    
    // Obtém a cor associada a um StyleCase
    private func getColorFromStyle<T>(_ style: T) -> ColorName {
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
}'''

# Configurações
REPO_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../../"))
ZENITH_PATH = os.path.join(REPO_ROOT, "Packages/Zenith")
ZENITH_SAMPLE_PATH = os.path.join(REPO_ROOT, "Packages/ZenithSample")
COMPONENTS_PATH = os.path.join(ZENITH_PATH, "Sources/Zenith")
SAMPLES_PATH = os.path.join(ZENITH_SAMPLE_PATH, "ZenithSample")
TESTS_PATH = os.path.join(ZENITH_PATH, "Tests/ZenithTests")

# Configurações adicionais
INDENT_SIZE = 4
GENERATE_TESTS = False  # Por padrão, não gera testes

# Estrutura para armazenar informações do componente
class ComponentInfo:
    def __init__(self, name: str, type_path: str):
        self.name: str = name
        self.type_path: str = type_path  # BaseElements/Natives ou Components/Customs
        self.view_path: str = ""
        self.config_path: str = ""
        self.styles_path: str = ""
        self.properties: List[Dict] = []
        self.style_cases: List[str] = []  # Para compatibilidade
        self.style_functions: List[Dict] = []  # Funções de estilo como small(), medium(), etc.
        self.enum_properties: List[Dict] = []  # Propriedades que são enums
        self.text_properties: List[Dict] = []  # Propriedades de texto
        self.bool_properties: List[Dict] = []  # Propriedades booleanas
        self.number_properties: List[Dict] = []  # Propriedades numéricas
        self.closure_properties: List[Dict] = []  # Propriedades que são closures (ações)
        self.complex_properties: List[Dict] = []  # Propriedades complexas (tipos personalizados)
        self.public_init_params: List[Dict] = []  # Parâmetros do inicializador público
        self.has_action_param: bool = False  # Se o componente tem um parâmetro de ação
        self.component_type: Optional[str] = None  # Tipo do componente (Button, Text, etc.)
        
    def __str__(self):
        return f"Component: {self.name} (Type: {self.type_path})"
        
    def get_property_by_name(self, name: str) -> Optional[Dict]:
        """Retorna uma propriedade pelo nome"""
        for prop in self.properties:
            if prop['name'] == name:
                return prop
        return None

# Registro de tipos de componentes
class ComponentTypeRegistry:
    """Registro para configurações específicas de diferentes tipos de componentes."""
    
    def __init__(self):
        self.component_types = {}
        self.native_component_examples = {}
        # Registro de tipos padrão será feito após a definição de todas as funções
        
    def _register_default_types(self):
        """Registra os tipos de componentes padrão."""
        self.register_component_type(
            "Button",
            has_content_param=False,
            is_button_type=True,
            style_modifier="buttonStyle",
            style_type="ButtonStyle",
            style_case_type="ButtonStyleCase",
            preview_generator=generate_button_preview,
            code_generator=generate_button_code,
            default_style_cases=["contentA", "highlightA", "backgroundD"]
        )
        
        self.register_component_type(
            "Text",
            has_content_param=True,
            is_button_type=False,
            style_modifier="textStyle",
            style_type="TextStyle",
            style_case_type="TextStyleCase",
            preview_generator=None,  # Usa o gerador padrão
            code_generator=None,     # Usa o gerador padrão
            default_style_cases=["smallContentA", "mediumContentA", "largeContentA"]
        )
        
        self.register_native_example("Text", "Exemplo de texto")
        self.register_native_example("Button", "Botão de Exemplo")
        
    def register_component_type(self, name: str, has_content_param: bool, is_button_type: bool,
                               style_modifier: str, style_type: str, style_case_type: str,
                               preview_generator: Optional[Callable] = None,
                               code_generator: Optional[Callable] = None,
                               default_style_cases: Optional[List[str]] = None):
        """Registra um novo tipo de componente."""
        self.component_types[name] = {
            "has_content_param": has_content_param,
            "is_button_type": is_button_type,
            "style_modifier": style_modifier,
            "style_type": style_type,
            "style_case_type": style_case_type,
            "preview_generator": preview_generator,
            "code_generator": code_generator,
            "default_style_cases": default_style_cases or []
        }
        
    def register_native_example(self, component_name: str, example_content: str):
        """Registra um exemplo para um componente nativo."""
        self.native_component_examples[component_name] = example_content
        
    def get_native_example(self, component_name: str) -> str:
        """Retorna o exemplo para um componente nativo."""
        return self.native_component_examples.get(component_name, "Exemplo")
        
    def get_component_type(self, name: str) -> Dict:
        """Retorna as configurações para um tipo de componente."""
        if name not in self.component_types:
            logger.info(f"Componente {name} não registrado, usando configuração genérica")
            return self._create_generic_config(name)
        return self.component_types[name]
        
    def _create_generic_config(self, name: str) -> Dict:
        """Cria uma configuração genérica para um componente não registrado."""
        return {
            "has_content_param": False,  # Será atualizado durante a análise
            "is_button_type": False,     # Será atualizado durante a análise
            "style_modifier": f"{name.lower()}Style",
            "style_type": f"{name}Style",
            "style_case_type": f"{name}StyleCase",
            "preview_generator": None,
            "code_generator": None,
            "default_style_cases": []
        }
        
    def update_component_config(self, component_info: ComponentInfo) -> Dict:
        """Atualiza a configuração do componente com base na análise."""
        config = self.get_component_type(component_info.name).copy()
        
        # Atualizar configuração com base na análise do componente
        if component_info.has_action_param:
            config["is_button_type"] = True
            
        # Verificar se o componente tem parâmetro de conteúdo
        for param in component_info.public_init_params:
            if param.get('name') == 'content' or param.get('name') == 'text':
                config["has_content_param"] = True
                break
                
        # Para componentes nativos, verificar se tem funções de estilo com is_native=True
        for style_func in component_info.style_functions:
            if style_func.get('is_native'):
                # Atualizar o modificador de estilo para o nome da função
                config["style_modifier"] = style_func['name']
                break
                
        return config

# Instância global do registro de componentes
component_registry = ComponentTypeRegistry()

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
    style_functions = []
    
    # Procura por extensões como: public extension TextStyle where Self == BaseTextStyle
    extension_pattern = rf'public\s+extension\s+{component_name}Style\s+where\s+Self\s+==\s+Base{component_name}Style'
    extension_match = re.search(extension_pattern, content)
    
    direct_extension_pattern = rf'public\s+extension\s+{component_name}'
    direct_extension_match = re.search(direct_extension_pattern, content)
    
    # Procura também por extensões estáticas para componentes nativos
    static_extension_pattern = rf'public\s+extension\s+{component_name}Style'
    static_extension_match = re.search(static_extension_pattern, content)
    
    # Processa a extensão principal se encontrada
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
    
    # Para componentes nativos, procurar funções de estilo na extensão direta
    elif direct_extension_match:
        # Encontrar abertura de chave após a extensão
        opening_brace_pos = content.find('{', direct_extension_match.end())
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
                
                # Extrair funções de estilo para componentes nativos
                # Padrão para funções como: func textStyle(_ style: some TextStyle) -> some View
                function_pattern = r'func\s+(\w+Style)\s*\(\s*(?:_\s+)?(\w+)\s*:\s*(?:some\s+)?(\w+)(?:\s*(?:,|\)|\s))?'
                for match in re.finditer(function_pattern, extension_content):
                    func_name = match.group(1)  # Nome da função (ex: textStyle)
                    param_name = match.group(2)  # Nome do parâmetro (ex: style)
                    param_type = match.group(3)  # Tipo do parâmetro (ex: TextStyle)
                    
                    style_functions.append({
                        'name': func_name,
                        'param_name': param_name,
                        'param_type': param_type,
                        'is_native': True
                    })
    
    # Procurar também por extensões estáticas para componentes nativos
    if static_extension_match and not extension_match:
        # Encontrar abertura de chave após a extensão
        opening_brace_pos = content.find('{', static_extension_match.end())
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
                
                # Extrair funções de estilo estáticas
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

def extract_init_params(content: str, component_name: str) -> List[Dict]:
    """Extrai os parâmetros dos inicializadores públicos de um componente."""
    # Padrão para localizar inicializadores públicos
    init_pattern = rf'public\s+init\s*\((.*?)\)'
    
    init_params = []
    public_inits = re.finditer(init_pattern, content, re.DOTALL)
    
    for match in public_inits:
        params_str = match.group(1).strip()
        if not params_str:
            continue
            
        # Dividir pelos parâmetros individuais (isso é complexo devido a possíveis closures aninhadas)
        param_level = 0
        param_start = 0
        params = []
        
        for i, char in enumerate(params_str):
            if char == '(' or char == '<':
                param_level += 1
            elif char == ')' or char == '>':
                param_level -= 1
            # Se estamos no nível superior e encontramos uma vírgula, temos um parâmetro completo
            elif char == ',' and param_level == 0:
                params.append(params_str[param_start:i].strip())
                param_start = i + 1
                
        # Adicionar o último parâmetro
        if param_start < len(params_str):
            params.append(params_str[param_start:].strip())
            
        # Processar cada parâmetro para extrair nome, tipo e valor padrão
        for param in params:
            # Padrão para extrair detalhes do parâmetro
            param_parts = re.match(r'(?:(\w+)\s+)?(\w+)\s*:\s*([^=]+)(?:\s*=\s*(.+))?', param)
            
            if param_parts:
                # Extrair nome, tipo e valor padrão
                label = param_parts.group(1)  # Label externo (opcional)
                name = param_parts.group(2)  # Nome do parâmetro
                param_type = param_parts.group(3).strip()  # Tipo
                default_value = param_parts.group(4)  # Valor padrão (opcional)
                
                # Determinar se é um parâmetro de closure/ação
                is_action = False
                if '->' in param_type:
                    is_action = True
                
                init_params.append({
                    'label': label,
                    'name': name,
                    'type': param_type,
                    'default_value': default_value.strip() if default_value else None,
                    'is_action': is_action
                })
            
    return init_params

def detect_button_component(component_name: str, init_params: List[Dict]) -> bool:
    """Detecta se um componente é um botão ou similar que precisa de tratamento especial."""
    # Verifica se é um Button pelo nome
    if component_name == "Button":
        return True
    
    # Verifica se tem um parâmetro de ação típico de botões
    for param in init_params:
        if param.get('is_action') and 'Void' in param.get('type', ''):
            return True
            
    return False

def analyze_component(component_info: ComponentInfo) -> ComponentInfo:
    """Analisa um componente em detalhes para detectar seus tipos de parâmetros e necessidades específicas."""
    # Ler o conteúdo do arquivo View se existir
    view_content = ""
    if component_info.view_path and os.path.exists(component_info.view_path):
        view_content = parse_swift_file(component_info.view_path)
    else:
        logger.info(f"Arquivo View não encontrado para {component_info.name}, usando configuração padrão")
    
    # Extrair parâmetros do inicializador se tiver conteúdo
    if view_content:
        component_info.public_init_params = extract_init_params(view_content, component_info.name)
    
    # Se não tiver arquivo View mas tiver arquivo Styles, extrair informações do arquivo Styles
    if not view_content and component_info.styles_path and os.path.exists(component_info.styles_path):
        styles_content = parse_swift_file(component_info.styles_path)
        
        # Para componentes nativos, extrair parâmetros da estrutura BaseStyle
        base_style_pattern = rf'public\s+struct\s+Base{component_info.name}Style'
        base_style_match = re.search(base_style_pattern, styles_content)
        
        if base_style_match:
            # Encontrar abertura de chave após a estrutura
            opening_brace_pos = styles_content.find('{', base_style_match.end())
            if opening_brace_pos > 0:
                # Encontrar chave de fechamento correspondente
                brace_count = 1
                i = opening_brace_pos + 1
                while i < len(styles_content) and brace_count > 0:
                    if styles_content[i] == '{':
                        brace_count += 1
                    elif styles_content[i] == '}':
                        brace_count -= 1
                    i += 1
                    
                if brace_count == 0:
                    base_style_content = styles_content[opening_brace_pos:i]
                    
                    # Extrair propriedades da estrutura BaseStyle
                    properties = extract_properties(base_style_content)
                    
                    # Adicionar propriedades encontradas
                    component_info.properties.extend(properties)
                    
                    # Extrair parâmetros do inicializador
                    init_params = extract_init_params(base_style_content, f"Base{component_info.name}Style")
                    
                    # Adicionar como parâmetros públicos
                    if init_params:
                        component_info.public_init_params.extend(init_params)
                        
                        # Verificar se tem parâmetro de conteúdo
                        for param in init_params:
                            if param.get('name') in ['content', 'text']:
                                # Marcar como componente com parâmetro de conteúdo
                                component_registry.update_component_config(component_info)
    
    # Verificar se é um componente do tipo Button
    is_button = detect_button_component(component_info.name, component_info.public_init_params)
    
    # Para componentes do tipo Button, armazenar informações adicionais
    if is_button:
        logger.info(f"Componente {component_info.name} identificado como tipo Button")
        for param in component_info.public_init_params:
            if param.get('is_action'):
                component_info.has_action_param = True
                component_info.closure_properties.append(param)
                logger.info(f"Parâmetro de ação encontrado: {param['name']}")
    
    # Categorizar propriedades
    if component_info.properties:
        # Categorizar propriedades
        (component_info.enum_properties,
         component_info.text_properties,
         component_info.bool_properties,
         component_info.number_properties) = categorize_properties(component_info.properties)
    
    # Categorizar propriedades complexas (que não são tipos simples)
    for prop in component_info.properties:
        if prop['data_type'] not in ['String', 'Bool', 'Int', 'Double', 'CGFloat', 'Float'] and not any(t in prop['data_type'] for t in ['Case', 'FontName', 'ColorName']):
            if '->' in prop['data_type']:  # É uma closure
                component_info.closure_properties.append(prop)
            else:
                component_info.complex_properties.append(prop)
    
    return component_info

def find_component_files(component_name: str) -> Optional[ComponentInfo]:
    """Localiza os arquivos View, Configuration e Styles de um componente."""
    component_info = None
    
    # Determinar o tipo de componente (BaseElements/Natives, BaseElements/Customs ou Components/Customs)
    possible_paths = [
        os.path.join(COMPONENTS_PATH, "BaseElements/Natives", component_name),
        os.path.join(COMPONENTS_PATH, "BaseElements/Customs", component_name),
        os.path.join(COMPONENTS_PATH, "Components/Customs", component_name),
        os.path.join(COMPONENTS_PATH, "BaseElements", "Natives", component_name),
        os.path.join(COMPONENTS_PATH, "BaseElements", "Customs", component_name),
        os.path.join(COMPONENTS_PATH, "Components", "Customs", component_name)
    ]
    
    # Verificar se algum dos caminhos possíveis existe
    found_path = None
    for base_path in possible_paths:
        if os.path.exists(base_path):
            logger.info(f"Componente encontrado em: {base_path}")
            found_path = base_path
            type_path = "BaseElements/Natives" if "BaseElements" in base_path else "Components/Customs"
            component_info = ComponentInfo(component_name, type_path)
            break
    
    if not component_info:
        logger.error(f"Componente '{component_name}' não encontrado. Caminhos verificados: {possible_paths}")
        return None
    
    # Localizar arquivos View, Configuration e Styles
    try:
        if found_path:  # Verificar se found_path não é None
            files = os.listdir(found_path)
            logger.info(f"Arquivos encontrados no diretório do componente: {files}")
        else:
            logger.error(f"Caminho não encontrado para o componente {component_name}")
            return component_info
    except Exception as e:
        logger.error(f"Erro ao listar arquivos do componente: {e}")
        return component_info
    
    for file in files:
        if found_path:  # Verificar se found_path não é None
            file_path = os.path.join(found_path, file)
            logger.info(f"Verificando arquivo: {file_path}")
            
            if f"{component_name}View" in file:
                component_info.view_path = file_path
                logger.info(f"View encontrada: {file_path}")
            elif f"{component_name}Configuration" in file:
                component_info.config_path = file_path
                logger.info(f"Configuration encontrada: {file_path}")
            elif f"{component_name}Styles" in file:
                component_info.styles_path = file_path
                logger.info(f"Styles encontrada: {file_path}")
    
    # Verificar se encontrou os arquivos necessários
    if not component_info.view_path:
        logger.warning(f"View não encontrada para o componente {component_name}")
        
        # Para componentes nativos, verificar se é um componente que só tem arquivo Styles
        if component_info.styles_path and "BaseElements/Natives" in found_path:
            logger.info(f"Componente {component_name} identificado como nativo com apenas arquivo Styles")
            
            # Verificar se o componente está registrado
            component_type_config = component_registry.get_component_type(component_name)
            if component_name not in component_registry.component_types:
                logger.info(f"Registrando {component_name} como componente nativo")
                component_registry.register_component_type(
                    component_name,
                    has_content_param=True,  # Assumir que componentes nativos têm parâmetro de conteúdo
                    is_button_type=False,
                    style_modifier=f"{component_name.lower()}Style",
                    style_type=f"{component_name}Style",
                    style_case_type=f"{component_name}StyleCase",
                    preview_generator=None,
                    code_generator=None,
                    default_style_cases=[]
                )
    
    # Extrair propriedades, funções de estilo e casos de estilo
    if component_info.view_path and os.path.exists(component_info.view_path):
        logger.info(f"Analisando view: {component_info.view_path}")
        content = parse_swift_file(component_info.view_path)
        component_info.properties = extract_properties(content)
        
        # Categorizar propriedades
        (component_info.enum_properties,
         component_info.text_properties,
         component_info.bool_properties,
         component_info.number_properties) = categorize_properties(component_info.properties)
    
    if component_info.styles_path and os.path.exists(component_info.styles_path):
        logger.info(f"Analisando arquivo de estilos: {component_info.styles_path}")
        content = parse_swift_file(component_info.styles_path)
        component_info.style_functions = extract_style_functions(content, component_name)
        
        # Se não encontrou funções de estilo, tenta extrair do StyleCase (para compatibilidade)
        if not component_info.style_functions:
            logger.info("Tentando extrair casos de estilo (StyleCase)")
            component_info.style_cases = extract_style_cases(content)
            logger.info(f"Casos de estilo encontrados: {component_info.style_cases}")
            
        # Para componentes nativos sem arquivo View, extrair propriedades do arquivo Styles
        if not component_info.view_path or not os.path.exists(component_info.view_path):
            # Extrair propriedades da estrutura BaseStyle
            base_style_pattern = rf'public\s+struct\s+Base{component_name}Style'
            base_style_match = re.search(base_style_pattern, content)
            
            if base_style_match:
                logger.info(f"Extraindo propriedades da estrutura Base{component_name}Style")
                
                # Encontrar abertura de chave após a estrutura
                opening_brace_pos = content.find('{', base_style_match.end())
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
                        base_style_content = content[opening_brace_pos:i]
                        
                        # Extrair propriedades da estrutura BaseStyle
                        style_properties = extract_properties(base_style_content)
                        
                        # Adicionar propriedades encontradas
                        component_info.properties.extend(style_properties)
                        
                        # Categorizar propriedades
                        (component_info.enum_properties,
                         component_info.text_properties,
                         component_info.bool_properties,
                         component_info.number_properties) = categorize_properties(component_info.properties)
    
    # Obter configurações específicas do tipo de componente
    component_type_config = component_registry.get_component_type(component_name)
    
    # Se não tiver casos de estilo, usar os padrões do tipo de componente
    if not component_info.style_cases and component_type_config["default_style_cases"]:
        component_info.style_cases = component_type_config["default_style_cases"]
        logger.info(f"Definindo casos de estilo padrão para {component_name}: {component_info.style_cases}")
    
    # Definir o tipo do componente
    component_info.component_type = component_name
    
    return component_info

def generate_sample_file(component_info: ComponentInfo, component_config: Optional[Dict] = None) -> str:
    """Gera o conteúdo do arquivo Sample com base nas informações do componente."""
    # Analisa o componente em detalhes para detectar tipos específicos
    component_info = analyze_component(component_info)
    
    sample_name = f"{component_info.name}Sample"
    
    if component_config is None:
        # Obter configurações específicas do tipo de componente
        component_config = component_registry.get_component_type(component_info.name)
        
        # Atualizar a configuração com base na análise do componente
        component_config = component_registry.update_component_config(component_info)
    
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
    
    # Estado para texto de exemplo se o componente precisar de conteúdo
    if component_config["has_content_param"]:
        # Usar exemplo registrado para componentes nativos
        example_content = component_registry.get_native_example(component_info.name)
        states.append(f'    @State private var sampleText = "{example_content}"')
    
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
        states.append(f'    @State private var selectedStyle = {component_config["style_case_type"]}.{default_style}')
    
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
                                                    VStack {{
                                                        Text(color.rawValue)
                                                            .font(fonts.small)
                                                            .foregroundColor(colors.contentA)
                                                            .padding(.bottom, 2)
                                                        
                                                        {component_info.name}"""
            
            # Adicionar parâmetro se o componente tiver conteúdo
            body += "(" + ("sampleText" if component_config["has_content_param"] else "") + ")"
                
            body += f"""
                                                            .{component_config["style_modifier"]}(.{style_func['name']}(color))
                                                            .padding(8)
                                                            .frame(maxWidth: .infinity)
                                                            .background(
                                                                RoundedRectangle(cornerRadius: 4)
                                                                    .fill(getContrastBackground(for: color))
                                                            )
                                                    }}
                                                }}
                                            }}
                                        }}
                                        .padding(.vertical, 8)
"""
        body += """                                    }
"""
    elif component_info.style_cases and len(component_info.style_cases) > 0:
        # Fallback para StyleCase - versão corrigida para diferenciar entre Button e outros componentes
        if component_config["is_button_type"]:
            # Para Button ou componentes que aceitam closure de ação
            body += f"""                                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 8) {{
                                        ForEach({component_config["style_case_type"]}.allCases, id: \\.self) {{ style in
                                            VStack {{
                                                Text(String(describing: style))
                                                    .font(fonts.small)
                                                    .foregroundColor(colors.contentA)
                                                    .padding(.bottom, 2)
                                                
                                                Button(buttonTitle) {{
                                                    // Ação vazia para exemplo
                                                }}
                                                .buttonStyle(style.style())
                                                .padding(8)
                                                .frame(maxWidth: .infinity)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 4)
                                                        .fill(getContrastBackground(for: getColorFromStyle(style)))
                                                )
                                            }}
                                        }}
                                    }}
"""
        else:
            # Para componentes sem parâmetros de closure, como Divider
            body += f"""                                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 8) {{
                                        ForEach({component_config["style_case_type"]}.allCases, id: \\.self) {{ style in
                                            VStack {{
                                                Text(String(describing: style))
                                                    .font(fonts.small)
                                                    .foregroundColor(colors.contentA)
                                                    .padding(.bottom, 2)
                                                
                                                {component_info.name}()
                                                    .{component_config["style_modifier"]}(style.style())
                                                    .padding(8)
                                                    .frame(maxWidth: .infinity)
                                                    .background(
                                                        RoundedRectangle(cornerRadius: 4)
                                                            .fill(getContrastBackground(for: getColorFromStyle(style)))
                                                    )
                                            }}
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
            // Preview do componente com as configurações atuais
"""

    # Inicialização do componente
    preview_component += f"            {component_info.name}("
    
    # Adicionar conteúdo (sampleText) se for aplicável
    if component_config["has_content_param"]:
        preview_component += "sampleText"
        
    # Adicionar parâmetros baseados nas propriedades
    params = []
    
    # Adicionar texto se for relevante
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
    
    # Adicionar vírgula se o componente já tiver um parâmetro e tiver mais parâmetros para adicionar
    if component_config["has_content_param"] and params:
        preview_component += ", "
        
    preview_component += ", ".join(params)
    preview_component += ")"
    
    # Adicionar o modificador de estilo apropriado
    if component_info.style_functions and len(component_info.style_functions) > 0:
        # Para componentes com funções de estilo
        preview_component += f"\n                .{component_config['style_modifier']}(getSelectedStyle())"
    elif component_info.style_cases and len(component_info.style_cases) > 0:
        # Para componentes com StyleCase
        preview_component += f"\n                .{component_config['style_modifier']}(selectedStyle.style())"
        
    preview_component += """
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(useContrastBackground ? colors.backgroundA : colors.backgroundB.opacity(0.2))
                )
        }
    }
"""
    
    # Implementação da configurationSection
    configuration_section = """
    // Área de configuração
    private var configurationSection: some View {
        VStack(spacing: 16) {
"""

    # Se componente tem conteúdo, adicionar campo para texto de exemplo
    if component_config["has_content_param"]:
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
            EnumSelector<{component_config["style_case_type"]}>(
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
    
    # Início do componente no código gerado
    generate_code += f"        {component_info.name}("
    
    # Adicionar conteúdo (sampleText) se aplicável
    if component_config["has_content_param"]:
        generate_code += "sampleText"

    # Adicionar parâmetros do init
    params = []
    
    # Adicionar texto se for relevante
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
    
    # Adicionar vírgula se o componente já tiver um parâmetro e tiver mais parâmetros para adicionar
    if component_config["has_content_param"] and params:
        generate_code += ", "
        
    generate_code += ", ".join(params)
    generate_code += ")"
    
    # Adicionar modificador de estilo se aplicável
    if component_info.style_functions and len(component_info.style_functions) > 0:
        generate_code += f"\n            .{component_config['style_modifier']}(." + "\\(selectedStyleFunction)" + "(." + "\\(String(describing: selectedColorName))" + "))"
    elif component_info.style_cases and len(component_info.style_cases) > 0:
        generate_code += f"\n            .{component_config['style_modifier']}(selectedStyle.style())"
    
    generate_code += '''

        """
        
        return code
    }
'''
    
    # Helper para obter o estilo selecionado (genérico)
    helper_methods = f"""
    // Helper para obter o estilo correspondente à função selecionada
    private func getSelectedStyle() -> some {component_config["style_type"]} {{
"""
    
    if component_info.style_functions and len(component_info.style_functions) > 0:
        helper_methods += """        switch selectedStyleFunction {
"""
        for func_info in component_info.style_functions:
            helper_methods += f"""        case "{func_info['name']}":
            return .{func_info['name']}(selectedColorName)
"""
        
        helper_methods += f"""        default:
            return .{component_info.style_functions[0]['name']}(selectedColorName)
        }}
"""
    elif component_info.style_cases and len(component_info.style_cases) > 0:
        helper_methods += f"""        return selectedStyle.style()
"""
    else:
        # Fallback para componentes sem estilo
        helper_methods += f"""        // Componente não tem estilos configurados
        struct DefaultStyle: {component_config["style_type"]} {{}}
        return DefaultStyle()
"""
        
    helper_methods += """    }
    
    // Obtém a cor associada a um StyleCase
    private func getColorFromStyle<T>(_ style: T) -> ColorName {
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

def find_button_specific_files() -> ComponentInfo:
    """Procura especificamente por arquivos do Button quando ele é um tipo nativo do SwiftUI."""
    component_name = "Button"
    logger.info("Procurando especificamente por arquivos do Button")
    
    # Como o Button é um tipo do SwiftUI, precisamos procurar seus arquivos de estilo em locais específicos
    styles_path = None
    button_paths = [
        os.path.join(COMPONENTS_PATH, "BaseElements/Natives", component_name),
        os.path.join(COMPONENTS_PATH, "BaseElements", "Natives", component_name)
    ]
    
    # Procurar pelo arquivo de estilos do Button
    for path in button_paths:
        if os.path.exists(path):
            files = os.listdir(path)
            for file in files:
                if "ButtonStyles.swift" in file:
                    styles_path = os.path.join(path, file)
                    logger.info(f"Arquivo de estilos do Button encontrado: {styles_path}")
                    break
        if styles_path:
            break
    
    # Criar um ComponentInfo para o Button
    component_info = ComponentInfo("Button", "BaseElements/Natives")
    if styles_path:
        component_info.styles_path = styles_path
    
    # Obter configurações específicas do tipo de componente
    component_type_config = component_registry.get_component_type("Button")
    
    # Definir valores padrão específicos para o Button
    if component_type_config["default_style_cases"]:
        component_info.style_cases = component_type_config["default_style_cases"]
    else:
        component_info.style_cases = ["contentA", "highlightA", "backgroundD"]
    
    logger.info(f"Definindo casos de estilo padrão para Button: {component_info.style_cases}")
    
    # Adicionar parâmetros de inicialização padrão para Button
    component_info.public_init_params = [
        {
            'label': None,
            'name': 'title',
            'type': 'String',
            'default_value': None,
            'is_action': False
        },
        {
            'label': None,
            'name': 'action',
            'type': '() -> Void',
            'default_value': None,
            'is_action': True
        }
    ]
    
    # Marcar o componente como tendo parâmetro de ação
    component_info.has_action_param = True
    
    # Definir o tipo do componente
    component_info.component_type = "Button"
    
    return component_info

def generate_button_preview(component_info: ComponentInfo) -> str:
    """Gera o código de preview específico para componentes do tipo Button."""
    component_name = component_info.name
    
    # Obtendo a inicialização específica para Button
    preview = f"""
    // Preview do componente com as configurações selecionadas
    private var previewComponent: some View {{
        VStack {{
            // Preview do componente com as configurações atuais
            {component_name}(buttonTitle) {{
                print("Botão pressionado")
            }}
            .buttonStyle(selectedStyle.style())
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(useContrastBackground ? colors.backgroundA : colors.backgroundB.opacity(0.2))
            )
        }}
    }}
    """
    
    return preview

def generate_button_code(component_info: ComponentInfo) -> str:
    """Gera o código Swift para inicialização específica de componentes do tipo Button."""
    # Gerar código específico para Button
    code = '''
    // Gera o código Swift para o componente configurado
    private func generateSwiftCode() -> String {
        // Aqui você pode personalizar a geração de código com base no componente
        var code = "// Código gerado automaticamente\\n"
        
        code += """
        Button("\\(buttonTitle)") {
            // Ação do botão aqui
        }
        .buttonStyle(selectedStyle.style())
        """
        
        return code
    }
    '''
    
    return code

def customize_component_generation(component_info: ComponentInfo, template: str) -> str:
    """Customiza a geração de componente baseado no tipo específico."""
    # Verifica se o componente é do tipo Button
    is_button = component_info.name == "Button" or component_info.has_action_param
    
    if is_button:
        logger.info(f"Customizando template para o componente de botão: {component_info.name}")
        
        # Substituir a seção do preview component pelo específico para Button
        button_preview = generate_button_preview(component_info)
        button_code = generate_button_code(component_info)
        
        # Adicionar estado para o título do botão
        title_state = '@State private var buttonTitle = "Botão de Exemplo"'
        
        # Corrigir espaçamento no @State (remover espaço antes do @State)
        template = re.sub(r'\s+@State', r'@State', template)
        
        # Substituir seções no template
        template = re.sub(r'// Preview do componente com as configurações selecionadas.*?}$',
                         button_preview, template, flags=re.DOTALL | re.MULTILINE)
        
        # Substituir a função de geração de código
        template = re.sub(r'// Gera o código Swift para o componente configurado.*?}$',
                         button_code, template, flags=re.DOTALL | re.MULTILINE)
        
        # Adicionar estado para o título do botão logo após os outros estados
        template = template.replace('@State private var showAllStyles = false',
                                   f'{title_state}\n    @State private var showAllStyles = false')
        
        # Corrigir a seção de configuração para envolver tudo em um VStack
        config_section = """
    // Área de configuração
    private var configurationSection: some View {
        VStack(spacing: 16) {
            // Campo para texto do botão
            TextField("Texto do botão", text: $buttonTitle)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            // Seletor de estilo
            EnumSelector<ButtonStyleCase>(
                title: "Estilo",
                selection: $selectedStyle,
                columnsCount: 3,
                height: 120
            )
            
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
        # Substituir a seção de configuração inteira
        template = re.sub(r'// Área de configuração.*?}$',
                         config_section, template, flags=re.DOTALL | re.MULTILINE)
        
        # Remover qualquer chave extra após o previewComponent
        template = re.sub(r'}\s*\n\s*}\s*\n\s*//\s*Área de configuração',
                         '}\n\n    // Área de configuração', template)
        
    return template

def create_sample_file(component_name: str):
    """Cria um arquivo Sample para um componente especificado."""
    logger.info(f"Criando amostra para o componente: {component_name}")
    
    # Obter configurações específicas do tipo de componente
    component_type_config = component_registry.get_component_type(component_name)
    
    # Verificar se deve usar o template hard-coded para Button
    use_hardcoded_template = (component_name == "Button" and not os.environ.get("FORCE_DYNAMIC_GENERATION"))
    
    if use_hardcoded_template:
        # Para Button, por padrão usamos um template hard-coded que sabemos que funciona
        content = create_button_sample_file()
        
        # Determinar o caminho para salvar o arquivo Sample
        sample_path = os.path.join(SAMPLES_PATH, "BaseElements/Natives", component_name)
        
        # Criar os diretórios, se necessário
        os.makedirs(sample_path, exist_ok=True)
        
        # Salvar o arquivo
        sample_file_path = os.path.join(sample_path, f"{component_name}Sample.swift")
        try:
            with open(sample_file_path, 'w') as file:
                file.write(content)
            logger.info(f"Arquivo Sample para Button criado com sucesso: {sample_file_path}")
            return True
        except Exception as e:
            logger.error(f"Erro ao criar o arquivo Sample para Button: {e}")
            return False
    else:
        # Para outros componentes ou se forçar geração dinâmica para Button
        logger.info(f"Usando geração dinâmica para o componente: {component_name}")
        
        # Tentar encontrar os arquivos do componente
        component_info = None
        
        # Verificar se é um componente especial que precisa de tratamento específico
        if component_name == "Button" and os.environ.get("FORCE_DYNAMIC_GENERATION"):
            component_info = find_button_specific_files()
        else:
            component_info = find_component_files(component_name)
        
        if not component_info:
            logger.error(f"Não foi possível encontrar o componente: {component_name}")
            return False
        
        component_info = analyze_component(component_info)
        
        # Atualizar a configuração do componente com base na análise
        component_config = component_registry.update_component_config(component_info)
        
        # Determinar o caminho para salvar o arquivo Sample
        sample_path = os.path.join(SAMPLES_PATH, component_info.type_path, component_name)
        
        # Criar os diretórios, se necessário
        os.makedirs(sample_path, exist_ok=True)
        
        # Gerar o conteúdo do arquivo Sample
        sample_content = generate_sample_file(component_info)
        
        # Verificar se é um componente que precisa de customização
        if component_info.has_action_param or component_type_config["is_button_type"]:
            logger.info(f"Aplicando customizações para o componente tipo button: {component_name}")
            sample_content = customize_component_generation(component_info, sample_content)
        elif component_type_config["preview_generator"]:
            # Usar gerador de preview específico para o tipo de componente
            logger.info(f"Aplicando customizações específicas para o componente: {component_name}")
            preview_generator = component_type_config["preview_generator"]
            code_generator = component_type_config["code_generator"]
            
            if preview_generator:
                preview_content = preview_generator(component_info)
                # Substituir a seção de preview no template
                sample_content = re.sub(r'// Preview do componente com as configurações selecionadas.*?}$',
                                      preview_content, sample_content, flags=re.DOTALL | re.MULTILINE)
            
            if code_generator:
                code_content = code_generator(component_info)
                # Substituir a função de geração de código
                sample_content = re.sub(r'// Gera o código Swift para o componente configurado.*?}$',
                                      code_content, sample_content, flags=re.DOTALL | re.MULTILINE)
        
        # Salvar o arquivo
        sample_file_path = os.path.join(sample_path, f"{component_name}Sample.swift")
        try:
            with open(sample_file_path, 'w') as file:
                file.write(sample_content)
            logger.info(f"Arquivo Sample criado com sucesso: {sample_file_path}")
            return True
        except Exception as e:
            logger.error(f"Erro ao criar o arquivo Sample: {e}")
            return False

def auto_register_components():
    """Detecta e registra automaticamente todos os componentes nativos e customizados."""
    logger.info("Detectando e registrando componentes automaticamente...")
    
    zenith_base_path = os.path.join(REPO_ROOT, "Packages", "Zenith", "Sources", "Zenith")
    
    # Detectar componentes nativos
    natives_path = os.path.join(zenith_base_path, "BaseElements", "Natives")
    if os.path.exists(natives_path):
        for component_dir in os.listdir(natives_path):
            component_path = os.path.join(natives_path, component_dir)
            if os.path.isdir(component_path):
                component_name = component_dir
                logger.info(f"Detectado componente nativo: {component_name}")
                
                # Verificar se já está registrado
                if component_name not in component_registry.component_types:
                    # Verificar arquivos de estilo
                    styles_file = os.path.join(component_path, f"{component_name}Styles.swift")
                    style_config_file = os.path.join(component_path, f"{component_name}StyleConfiguration.swift")
                    
                    if os.path.exists(styles_file):
                        styles_content = parse_swift_file(styles_file)
                        style_functions = extract_style_functions(styles_content, component_name)
                        style_cases = extract_style_cases(styles_content)
                        
                        # Determinar o modificador de estilo
                        style_modifier = f"{component_name.lower()}Style"
                        for style_func in style_functions:
                            if style_func.get('is_native'):
                                style_modifier = style_func['name']
                                break
                        
                        # Registrar o componente
                        component_registry.register_component_type(
                            component_name,
                            has_content_param=component_name in ["Text", "TextField"],
                            is_button_type=component_name in ["Button", "Toggle"],
                            style_modifier=style_modifier,
                            style_type=f"{component_name}Style",
                            style_case_type=f"{component_name}StyleCase",
                            preview_generator=None,
                            code_generator=None,
                            default_style_cases=style_cases[:3] if style_cases else []
                        )
                        
                        default_examples = {
                            "Text": "Exemplo de texto",
                            "Button": "Botão de Exemplo",
                            "TextField": "Campo de texto",
                            "Toggle": "Alternador",
                            "Divider": "Divisor"
                        }
                        example_content = default_examples.get(component_name, f"Exemplo de {component_name}")
                        component_registry.register_native_example(component_name, example_content)
    
    # Detectar componentes customizados (opcional)
    customs_base_paths = [
        os.path.join(zenith_base_path, "BaseElements", "Customs"),
        os.path.join(zenith_base_path, "Components", "Customs")
    ]
    
    for customs_path in customs_base_paths:
        if os.path.exists(customs_path):
            for component_dir in os.listdir(customs_path):
                component_path = os.path.join(customs_path, component_dir)
                if os.path.isdir(component_path):
                    component_name = component_dir
                    logger.info(f"Detectado componente customizado: {component_name}")
                    
                    # Verificar se já está registrado
                    if component_name not in component_registry.component_types:
                        # Verificar arquivos do componente
                        view_file = os.path.join(component_path, f"{component_name}.swift")
                        styles_file = os.path.join(component_path, f"{component_name}Styles.swift")
                        
                        if os.path.exists(view_file) or os.path.exists(styles_file):
                            styles_content = ""
                            if os.path.exists(styles_file):
                                styles_content = parse_swift_file(styles_file)
                            
                            style_cases = extract_style_cases(styles_content)
                            
                            component_registry.register_component_type(
                                component_name,
                                has_content_param=False,  # Será atualizado durante a análise
                                is_button_type=False,     # Será atualizado durante a análise
                                style_modifier=f"{component_name.lower()}Style",
                                style_type=f"{component_name}Style",
                                style_case_type=f"{component_name}StyleCase",
                                preview_generator=None,
                                code_generator=None,
                                default_style_cases=style_cases[:3] if style_cases else []
                            )
    
    logger.info(f"Registro automático concluído. {len(component_registry.component_types)} componentes registrados.")

# Inicializar o registro de componentes após a definição de todas as funções
component_registry = ComponentTypeRegistry()
component_registry._register_default_types()

def main():
    """Função principal."""
    parser = argparse.ArgumentParser(description='Gerador de arquivos Sample para componentes Zenith')
    parser.add_argument('component', help='Nome do componente para gerar o Sample (ex: Text, Button, etc.)')
    parser.add_argument('--auto-register', action='store_true', help='Detectar e registrar automaticamente todos os componentes')
    
    args = parser.parse_args()
    
    if args.auto_register:
        auto_register_components()
    
    create_sample_file(args.component)

if __name__ == "__main__":
    auto_register_components()
    main()
