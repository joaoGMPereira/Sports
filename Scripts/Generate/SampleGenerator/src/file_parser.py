#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Funções para analisar arquivos Swift

Este módulo contém funções para ler arquivos Swift e extrair propriedades
e outros metadados usando expressões regulares. A análise é focada em
identificar propriedades, seu tipo e valores padrão.

Principais funções:
- parse_swift_file: Lê um arquivo Swift
- extract_properties: Extrai propriedades usando regex
- categorize_properties: Classifica propriedades por tipo (enums, texto, bool, números)
"""

from typing import List, Dict, Tuple

def parse_swift_file(file_path: str) -> str:
    """
    Lê e retorna o conteúdo de um arquivo Swift.
    
    Args:
        file_path: Caminho completo para o arquivo Swift
        
    Returns:
        str: Conteúdo do arquivo como string
    """
    try:
        with open(file_path, 'r') as file:
            return file.read()
    except Exception as e:
        print(f"Erro ao ler o arquivo {file_path}: {e}")
        return ""

def extract_properties(content: str) -> List[Dict]:
    """
    Extrai propriedades de uma estrutura/classe Swift usando regex.
    
    Args:
        content: Conteúdo do arquivo Swift
        
    Returns:
        List[Dict]: Lista de dicionários, cada um representando uma propriedade
                   com 'type' (var/let), 'name', 'data_type' e 'default_value'
                   
    Exemplo de propriedade encontrada:
    {
        'type': 'var',
        'name': 'text',
        'data_type': 'String',
        'default_value': '"Hello"'
    }
    """
    import re
    # Padrão para localizar propriedades
    # Captura: (var|let) (nome) : (tipo) [= (valor padrão)]
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

def categorize_properties(properties: List[Dict]) -> Tuple[List[Dict], List[Dict], List[Dict], List[Dict]]:
    """
    Categoriza propriedades por tipo para usar controles apropriados na interface.
    
    Args:
        properties: Lista de propriedades extraídas pelo extract_properties
        
    Returns:
        Tuple: Contendo quatro listas de propriedades classificadas como:
               (enums, texto, booleanas, numéricas)
               
    A classificação é baseada no tipo de dados da propriedade:
    - Enums: Contém 'Case' no tipo ou é 'FontName'/'ColorName'
    - Texto: Contém 'String' no tipo
    - Booleanas: Contém 'Bool' no tipo
    - Numéricas: Contém 'Int', 'Double', 'CGFloat' ou 'Float' no tipo
    """
    from src.utils import IGNORED_PROPERTIES
    
    enum_props = []
    text_props = []
    bool_props = []
    number_props = []
    
    for prop in properties:
        if prop['name'] in IGNORED_PROPERTIES:
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