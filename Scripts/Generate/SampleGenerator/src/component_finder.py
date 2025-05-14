#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Funções para buscar arquivos de componentes

Este módulo contém funções para localizar os arquivos relevantes de um componente
Zenith (View, Configuration e Styles) e extrair suas propriedades e metadados.

Fluxo principal:
1. Determina se o componente está em BaseElements/Natives ou Components/Customs
2. Localiza os arquivos .swift relevantes dentro da pasta do componente
3. Extrai propriedades, funções de estilo e casos de estilo
4. Retorna um objeto ComponentInfo com todas as informações extraídas
"""

import os
from typing import Optional

from src.utils import COMPONENTS_PATH, COMPONENT_TYPE_BASE, COMPONENT_TYPE_CUSTOM
from src.component_info import ComponentInfo
from src.file_parser import parse_swift_file, extract_properties, categorize_properties
from src.style_extractor import extract_style_functions, extract_style_cases

def find_component_files(component_name: str) -> Optional[ComponentInfo]:
    """
    Localiza os arquivos View, Configuration e Styles de um componente.
    
    Args:
        component_name: Nome do componente (ex: "Text", "Button")
        
    Returns:
        ComponentInfo: Objeto com as informações do componente, ou None se não encontrado
        
    O método realiza as seguintes operações:
    1. Determina o tipo do componente (BaseElements/Natives ou Components/Customs)
    2. Localiza os arquivos View, Configuration e Styles
    3. Extrai propriedades, funções de estilo e casos de estilo
    4. Organiza tudo em um objeto ComponentInfo
    """
    component_info = None
    
    # Determinar o tipo de componente (BaseElements/Natives ou Components/Customs)
    possible_paths = [
        os.path.join(COMPONENTS_PATH, COMPONENT_TYPE_BASE, component_name),
        os.path.join(COMPONENTS_PATH, COMPONENT_TYPE_CUSTOM, component_name)
    ]
    
    for base_path in possible_paths:
        if os.path.exists(base_path):
            type_path = COMPONENT_TYPE_BASE if COMPONENT_TYPE_BASE in base_path else COMPONENT_TYPE_CUSTOM
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