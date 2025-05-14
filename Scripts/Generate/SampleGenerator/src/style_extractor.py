#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Funções para extrair informações de estilo

Este módulo contém funções para extrair dados relacionados ao estilo 
dos componentes. Ele lida com dois tipos principais de estilo no Zenith:

1. Funções de estilo: São funções como .small(), .medium(), etc, que aceitam
   um parâmetro de cor e aplicam um estilo de texto ou componente

2. Casos de estilo (StyleCase): Uma abordagem baseada em enum para estilos,
   usada em alguns componentes mais antigos
"""

import re
from typing import List, Dict

def extract_style_functions(content: str, component_name: str) -> List[Dict]:
    """
    Extrai funções de estilo de um arquivo Swift.
    
    Args:
        content: Conteúdo do arquivo Swift de estilos
        component_name: Nome do componente
        
    Returns:
        List[Dict]: Lista de dicionários com informações de cada função de estilo
                   Cada dicionário contém 'name' e 'param_type'
                   
    Exemplo:
    [
        {'name': 'small', 'param_type': 'ColorName'},
        {'name': 'medium', 'param_type': 'ColorName'}
    ]
    """
    style_functions = []
    
    # Padrão para funções de estilo como: static func small(_ color: ColorName) -> TextStyle
    function_pattern = rf'static\s+func\s+(\w+)\s*\(\s*_\s+\w+\s*:\s*(\w+)\s*\)\s*->\s*{component_name}Style'
    
    for match in re.finditer(function_pattern, content):
        func_name = match.group(1)
        param_type = match.group(2)
        
        style_functions.append({
            'name': func_name,
            'param_type': param_type
        })
    
    return style_functions

def extract_style_cases(content: str) -> List[str]:
    """
    Extrai casos de estilo (enum) de um arquivo Swift, para componentes que usam StyleCase.
    Esta é uma abordagem de fallback para componentes mais antigos.
    
    Args:
        content: Conteúdo do arquivo Swift de estilos
        
    Returns:
        List[str]: Lista de nomes de casos de estilo
                  
    Exemplo:
    ['smallContentA', 'mediumContentA', 'largeContentB']
    """
    style_cases = []
    
    # Padrão para enum StyleCase: case smallContentA, mediumContentA
    enum_pattern = r'enum\s+\w+StyleCase\s*:.*?{(.*?)}'
    case_pattern = r'case\s+(\w+)'
    
    # Encontrar o bloco da enum StyleCase
    enum_match = re.search(enum_pattern, content, re.DOTALL)
    if enum_match:
        enum_block = enum_match.group(1)
        
        # Encontrar todos os casos dentro do bloco da enum
        for case_match in re.finditer(case_pattern, enum_block):
            case_name = case_match.group(1)
            style_cases.append(case_name)
    
    return style_cases