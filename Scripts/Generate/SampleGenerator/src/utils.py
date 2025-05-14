#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Constantes e funções utilitárias

Este módulo contém constantes globais, caminhos de diretórios e outras
utilidades compartilhadas entre os diferentes módulos do script de geração.
Centralizar estas definições facilita a manutenção e adaptação do script
para diferentes estruturas de projeto.
"""

import os

# Caminhos base para o projeto
ROOT_DIR = os.path.expanduser("~/KettleGym")
PACKAGES_DIR = os.path.join(ROOT_DIR, "Packages")
ZENITH_DIR = os.path.join(PACKAGES_DIR, "Zenith")
COMPONENTS_PATH = os.path.join(ZENITH_DIR, "Sources", "Zenith", "Source")
SAMPLES_PATH = os.path.join(PACKAGES_DIR, "ZenithSample")

# Tipos de componentes
COMPONENT_TYPE_BASE = "BaseElements"
COMPONENT_TYPE_CUSTOM = "Components"

# Propriedades a serem ignoradas na extração (não utilizadas no arquivo Sample)
IGNORED_PROPERTIES = [
    "body",
    "colors",
    "fonts",
    "themeConfigurator",
]

def get_component_dir(component_name, type_path):
    """
    Retorna o caminho completo para o diretório de um componente.
    
    Args:
        component_name: Nome do componente
        type_path: Tipo do componente (BaseElements ou Components)
        
    Returns:
        str: Caminho completo para o diretório do componente
    """
    return os.path.join(COMPONENTS_PATH, type_path, component_name)