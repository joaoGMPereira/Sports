# Gerador de Samples do Zenith

Script modular para gerar arquivos Sample para os componentes do Zenith Design System.

## Estrutura do Projeto

```
SampleGenerator/
├── main.py                   # Ponto de entrada principal
├── generate_samples.sh       # Script shell para integração com Makefile
├── src/                      # Módulos do script
│   ├── __init__.py           # Torna src um pacote Python
│   ├── component_info.py     # Classe para armazenar informações do componente
│   ├── component_finder.py   # Funções para localizar arquivos de componentes
│   ├── file_parser.py        # Funções para analisar arquivos Swift
│   ├── style_extractor.py    # Funções para extrair informações de estilo
│   ├── content_generator.py  # Funções para gerar o conteúdo do arquivo Sample
│   └── utils.py              # Constantes e utilitários gerais
```

## Como Usar

O script pode ser executado diretamente:

```bash
python main.py Text
```

Ou através do Makefile:

```bash
make generate_sample COMPONENT=Text
```

## Funcionamento

O script segue o seguinte fluxo:

1. Recebe o nome do componente como argumento
2. Localiza os arquivos View, Configuration e Styles do componente
3. Extrai as propriedades e informações de estilo do componente
4. Gera um arquivo Sample com uma interface interativa
5. Salva o arquivo no caminho apropriado dentro do ZenithSample

## Responsabilidades dos Módulos

- **component_info.py**: Define a classe que armazena todas as informações do componente.
- **component_finder.py**: Localiza os arquivos do componente e popula o objeto ComponentInfo.
- **file_parser.py**: Analisa os arquivos Swift e extrai as propriedades usando regex.
- **style_extractor.py**: Extrai funções de estilo e casos de estilo do arquivo Styles.
- **content_generator.py**: Gera o conteúdo do arquivo Sample com base nas informações do componente.
- **utils.py**: Contém constantes, caminhos e outras utilidades compartilhadas.

## Manutenção

Para adicionar suporte a novos tipos de componentes ou recursos, considere:

1. Modificar `content_generator.py` para gerar código especializado para o tipo de componente
2. Ajustar `file_parser.py` se precisar extrair novas propriedades ou metadados
3. Atualizar `utils.py` para configurar novos caminhos ou constantes

## Compatibilidade

O script suporta dois tipos de componentes:
- Componentes básicos (em BaseElements/Natives)
- Componentes personalizados (em Components/Customs)

E dois tipos de estilo:
- Funções de estilo (como small(), medium())
- Casos de estilo (StyleCase)