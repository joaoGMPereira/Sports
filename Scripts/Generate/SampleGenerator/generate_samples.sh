#!/usr/bin/env bash

# Este script invoca o gerador de samples modular

COMPONENT=$1

if [ -z "$COMPONENT" ]; then
    echo "Erro: É necessário informar o nome do componente."
    echo "Uso: make generate_sample COMPONENT=Text"
    exit 1
fi

# Invoca o script modular principal
python3 ~/KettleGym/Scripts/Generate/SampleGenerator/main.py "$COMPONENT"