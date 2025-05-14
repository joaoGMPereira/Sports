#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Classe para armazenar informações do componente

Este módulo define a classe ComponentInfo, que é o modelo de dados central
usado para armazenar todas as informações relevantes de um componente.
A classe coleta e organiza as propriedades, estilos e caminhos para os arquivos
necessários para gerar um arquivo Sample.
"""

from typing import List, Dict, Optional

class ComponentInfo:
    """
    Classe para armazenar informações de um componente do Zenith.
    
    Esta classe serve como um contêiner estruturado para todas as 
    informações extraídas sobre um componente, incluindo suas propriedades,
    estilos, e caminhos para os arquivos relevantes.
    
    Attributes:
        name (str): Nome do componente (ex: "Text", "Button")
        type_path (str): Tipo do componente (BaseElements ou Components)
        view_path (str): Caminho para o arquivo View
        config_path (str): Caminho para o arquivo Configuration (se existir)
        styles_path (str): Caminho para o arquivo Styles (se existir)
        properties (List[Dict]): Lista de propriedades gerais
        enum_properties (List[Dict]): Propriedades de tipo enum
        text_properties (List[Dict]): Propriedades de texto (String)
        bool_properties (List[Dict]): Propriedades booleanas
        number_properties (List[Dict]): Propriedades numéricas (Int, Float, etc)
        style_functions (List[Dict]): Funções de estilo (small, medium, etc)
        style_cases (List[str]): Casos de estilo para fallback
    """
    
    def __init__(self, name: str, type_path: str):
        """
        Inicializa uma nova instância de ComponentInfo.
        
        Args:
            name: Nome do componente
            type_path: Tipo do componente (pasta onde está localizado)
        """
        self.name: str = name
        self.type_path: str = type_path
        
        # Caminhos para os arquivos
        self.view_path: Optional[str] = None
        self.config_path: Optional[str] = None
        self.styles_path: Optional[str] = None
        
        # Propriedades extraídas
        self.properties: List[Dict] = []
        
        # Propriedades categorizadas
        self.enum_properties: List[Dict] = []
        self.text_properties: List[Dict] = []
        self.bool_properties: List[Dict] = []
        self.number_properties: List[Dict] = []
        
        # Informações de estilo
        self.style_functions: List[Dict] = []
        self.style_cases: List[str] = []
        
    def __str__(self):
        return f"Component: {self.name} (Type: {self.type_path})"