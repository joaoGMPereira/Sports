#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Script para gerar arquivos Sample para os componentes do Zenith.
Este é o ponto de entrada principal do script.

Uso:
    python main.py Text
    
Onde 'Text' é o nome do componente para o qual queremos gerar um Sample.

O script irá:
1. Localizar os arquivos View, Configuration e Styles do componente
2. Extrair propriedades, funções de estilo e outros metadados
3. Gerar um arquivo Sample.swift com uma interface interativa
4. Salvar o arquivo no caminho apropriado

Autor: Time de Design System - Kettle
"""

import os
import sys
import argparse

from src.utils import SAMPLES_PATH
from src.component_finder import find_component_files
from src.content_generator import generate_sample_file

def main():
    """
    Função principal do script.
    
    Processa os argumentos de linha de comando, localiza os arquivos do componente,
    extrai as informações necessárias e gera o arquivo Sample correspondente.
    """
    # Configurar parser de argumentos
    parser = argparse.ArgumentParser(description='Gera arquivos Sample para os componentes do Zenith.')
    parser.add_argument('component', help='Nome do componente (ex: Text, Button)')
    args = parser.parse_args()
    
    component_name = args.component
    
    # Encontrar os arquivos do componente
    component_info = find_component_files(component_name)
    
    if not component_info:
        print(f"Erro: Não foi possível encontrar o componente '{component_name}'.")
        sys.exit(1)
    
    print(f"Gerando Sample para o componente: {component_info.name}")
    print(f"Tipo: {component_info.type_path}")
    print(f"View: {os.path.basename(component_info.view_path)}")
    print(f"Config: {os.path.basename(component_info.config_path) if component_info.config_path else 'N/A'}")
    print(f"Styles: {os.path.basename(component_info.styles_path) if component_info.styles_path else 'N/A'}")
    
    # Gerar conteúdo do arquivo Sample
    sample_content = generate_sample_file(component_info)
    
    # Caminho para o arquivo Sample
    samples_component_dir = os.path.join(SAMPLES_PATH, "Scenes", "Samples", component_name)
    sample_file_path = os.path.join(samples_component_dir, f"{component_name}Sample.swift")
    
    # Verificar se o diretório existe, caso contrário, criar
    if not os.path.exists(samples_component_dir):
        os.makedirs(samples_component_dir)
    
    # Escrever conteúdo no arquivo
    with open(sample_file_path, 'w') as file:
        file.write(sample_content)
    
    print(f"Arquivo Sample gerado com sucesso: {sample_file_path}")

if __name__ == "__main__":
    main()