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
        self.style_cases = []
        self.configurations = []
        
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
    
    # Extrair propriedades e casos de estilo
    if component_info.view_path:
        content = parse_swift_file(component_info.view_path)
        component_info.properties = extract_properties(content)
    
    if component_info.styles_path:
        content = parse_swift_file(component_info.styles_path)
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
    for prop in component_info.properties:
        if prop['name'] not in ['body', 'colors', 'fonts']:
            # Determinar um valor padrão adequado com base no tipo
            default_value = ""
            if "String" in prop['data_type']:
                default_value = '"Exemplo"'
            elif "Int" in prop['data_type']:
                default_value = "0"
            elif "Bool" in prop['data_type']:
                default_value = "false"
            elif "Double" in prop['data_type'] or "CGFloat" in prop['data_type']:
                default_value = "0.0"
            elif prop['default_value']:
                default_value = prop['default_value']
            
            if default_value:
                states.append(f'    @State private var {prop["name"]} = {default_value}')
    
    # Estado para o estilo selecionado
    if component_info.style_cases and len(component_info.style_cases) > 0:
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
    
    # Adicionar visualização de todos os estilos, se houver
    if component_info.style_cases and len(component_info.style_cases) > 0:
        body += f"""                                    ForEach({component_info.name}StyleCase.allCases, id: \\.self) {{ style in
                                        Text("\\(String(describing: style))")
                                            .padding(.vertical, 4)
                                            .padding(.horizontal, 8)
                                            .background(
                                                RoundedRectangle(cornerRadius: 4)
                                                    .fill(colors.backgroundB.opacity(0.5))
                                            )
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
            // Aqui vai o código para exibir o componente com as configurações selecionadas
            Text("Preview do componente")
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
    
    # Adicionar controles para cada propriedade
    for prop in component_info.properties:
        if prop['name'] not in ['body', 'colors', 'fonts']:
            if "String" in prop['data_type']:
                configuration_section += f"""            // Campo para editar {prop['name']}
            TextField("{prop['name'].capitalize()}", text: ${prop['name']})
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
"""
            elif "Int" in prop['data_type']:
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
            elif "Bool" in prop['data_type']:
                configuration_section += f"""            // Toggle para {prop['name']}
            Toggle("{prop['name'].capitalize()}", isOn: ${prop['name']})
                .toggleStyle(.default(.highlightA))
                .padding(.horizontal)
"""
            elif "Double" in prop['data_type'] or "CGFloat" in prop['data_type']:
                configuration_section += f"""            // Slider para {prop['name']}
            VStack(alignment: .leading) {{
                Text("{prop['name'].capitalize()}: \\({prop['name']}, specifier: "%.1f")")
                Slider(value: ${prop['name']}, in: 0...1)
            }}
            .padding(.horizontal)
"""
    
    # Adicionar seletor de estilo, se houver estilos
    if component_info.style_cases and len(component_info.style_cases) > 0:
        configuration_section += f"""
            // Seletor de estilo
            EnumSelector<{component_info.name}StyleCase>(
                title: "Estilo",
                selection: $selectedStyle,
                columnsCount: 3,
                height: 120
            )
"""
    
    # Adicionar toggles para opções de visualização
    configuration_section += """
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
        # Usando string simples para evitar problemas com a interpolação Swift
        generate_code += "        Text(\"Exemplo de texto\")\n"
        generate_code += "            .textStyle(.mediumContentA)\n"
    else:
        generate_code += f"        {component_info.name}()\n"
        generate_code += "            // Adicione propriedades e configurações aqui\n"
    
    generate_code += '''
        """
        
        return code
    }
'''
    
    # Helper para obter o nome do estilo (apenas para Text)
    helper_methods = ""
    if component_info.name == "Text":
        helper_methods = """
    // Helper para obter o nome do TextStyle correspondente
    private func getTextStyleName() -> String {
        // Identificamos o TextStyleCase mais próximo com base na fonte e cor selecionadas
        return String(describing: selectedStyle).lowercased()
    }
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
    
    return full_content

def create_sample_file(component_name: str):
    """Cria um arquivo Sample para um componente especificado."""
    component_info = find_component_files(component_name)
    
    if not component_info:
        return False
    
    # Determinar o caminho para salvar o arquivo Sample
    # O caminho deve seguir a mesma estrutura do componente original
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