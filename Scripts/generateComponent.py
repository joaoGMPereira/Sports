import os
import sys
import time
import re
import subprocess

# Cores para o terminal
class Colors:
    HEADER = '\033[95m'
    BLUE = '\033[94m'
    CYAN = '\033[96m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    END = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

def clear_screen():
    """Limpa a tela do terminal"""
    os.system('cls' if os.name == 'nt' else 'clear')

def print_header():
    """Imprime o cabeçalho do programa"""
    clear_screen()
    print(f"{Colors.HEADER}{Colors.BOLD}======================================================{Colors.END}")
    print(f"{Colors.HEADER}{Colors.BOLD}         GERADOR DE COMPONENTES SWIFT               {Colors.END}")
    print(f"{Colors.HEADER}{Colors.BOLD}======================================================{Colors.END}")
    print()

def print_success(message):
    """Imprime mensagem de sucesso"""
    print(f"{Colors.GREEN}{message}{Colors.END}")

def print_warning(message):
    """Imprime mensagem de aviso"""
    print(f"{Colors.YELLOW}{message}{Colors.END}")

def print_error(message):
    """Imprime mensagem de erro"""
    print(f"{Colors.RED}{message}{Colors.END}")

def print_info(message):
    """Imprime mensagem informativa"""
    print(f"{Colors.CYAN}{message}{Colors.END}")
    
def create_native_style_configuration(component_name):
    """Cria o arquivo [Component]StyleConfiguration.swift para componentes nativos"""
    return f"""import SwiftUI
import ZenithCoreInterface

public struct Any{component_name}Style: {component_name}Style & Sendable & Identifiable {{
    public let id: UUID = .init()
    
    private let _makeBody: @Sendable ({component_name}StyleConfiguration) -> AnyView
    
    public init<S: {component_name}Style>(_ style: S) {{
        _makeBody = {{ @Sendable configuration in
            AnyView(style.makeBody(configuration: configuration))
        }}
    }}
    
    public func makeBody(configuration: {component_name}StyleConfiguration) -> some View {{
        _makeBody(configuration)
    }}
}}

public protocol {component_name}Style: StyleProtocol & Identifiable {{
    typealias Configuration = {component_name}StyleConfiguration
}}

public struct {component_name}StyleConfiguration {{
    let content: {component_name}
    
    init(content: {component_name}) {{
        self.content = content
    }}
}}

public struct {component_name}StyleKey: EnvironmentKey {{
    public static let defaultValue: any {component_name}Style = Primary{component_name}Style()
}}

public extension EnvironmentValues {{
    var {component_name.lower()}Style : any {component_name}Style {{
        get {{ self[{component_name}StyleKey.self] }}
        set {{ self[{component_name}StyleKey.self] = newValue }}
    }}
}}

public extension {component_name}Style {{
    @MainActor
    func resolve(configuration: Configuration) -> some View {{
        Resolved{component_name}Style(style: self, configuration: configuration)
    }}
}}

private struct Resolved{component_name}Style<Style: {component_name}Style>: View {{
    let style: Style
    let configuration: Style.Configuration
    
    var body: some View {{
        style.makeBody(configuration: configuration)
    }}
}}
"""

def create_native_styles(component_name):
    """Cria o arquivo [Component]Styles.swift para componentes nativos"""
    return f"""import SwiftUI
import ZenithCoreInterface

public extension {component_name} {{
    func {component_name.lower()}Style(_ style: some {component_name}Style) -> some View {{
        AnyView(
            style.resolve(
                configuration: {component_name}StyleConfiguration(
                    content: self
                )
            ).environment(\\.{component_name.lower()}Style, style)
        )
    }}
}}

public struct Primary{component_name}Style: @preconcurrency {component_name}Style, BaseThemeDependencies {{
    public var id = String(describing: Self.self)
    
    @Dependency(\\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    
    @MainActor
    public func makeBody(configuration: Configuration) -> some View {{
        configuration
            .content
            .foregroundStyle(colors.textPrimary)
    }}
}}

public struct Secondary{component_name}Style: @preconcurrency {component_name}Style, BaseThemeDependencies {{
    public var id = String(describing: Self.self)
    
    @Dependency(\\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    
    @MainActor
    public func makeBody(configuration: Configuration) -> some View {{
        configuration
            .content
            .foregroundStyle(colors.textSecondary)
    }}
}}

public struct Tertiary{component_name}Style: @preconcurrency {component_name}Style, BaseThemeDependencies {{
    public var id = String(describing: Self.self)
    
    @Dependency(\\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    
    @MainActor
    public func makeBody(configuration: Configuration) -> some View {{
        configuration
            .content
            .foregroundStyle(colors.primary)
    }}
}}

public extension {component_name}Style where Self == Primary{component_name}Style {{
    static func primary() -> Self {{ Primary{component_name}Style() }}
}}

public extension {component_name}Style where Self == Secondary{component_name}Style {{
    static func secondary() -> Self {{ Secondary{component_name}Style() }}
}}

public extension {component_name}Style where Self == Tertiary{component_name}Style {{
    static func tertiary() -> Self {{ Tertiary{component_name}Style() }}
}}

public enum {component_name}StyleCase: CaseIterable, Identifiable {{
    case primary
    case secondary
    case tertiary
    
    public var id: Self {{ self }}
    
    public func style() -> Any{component_name}Style {{
        switch self {{
        case .primary:
            .init(.primary())
        case .secondary:
            .init(.secondary())
        case .tertiary:
            .init(.tertiary())
        }}
    }}
}}
"""

def create_style_configuration(component_name):
    """Cria o arquivo [Component]StyleConfiguration.swift"""
    return f"""import SwiftUI
import ZenithCoreInterface

public struct Any{component_name}Style: {component_name}Style & Sendable & Identifiable {{
    public let id: UUID = .init()
    
    private let _makeBody: @Sendable ({component_name}StyleConfiguration) -> AnyView
    
    public init<S: {component_name}Style>(_ style: S) {{
        _makeBody = {{ @Sendable configuration in
            AnyView(style.makeBody(configuration: configuration))
        }}
    }}
    
    public func makeBody(configuration: {component_name}StyleConfiguration) -> some View {{
        _makeBody(configuration)
    }}
}}

public protocol {component_name}Style: StyleProtocol & Identifiable {{
    typealias Configuration = {component_name}StyleConfiguration
}}

public struct {component_name}StyleConfiguration {{
    let text: String
    
    init(text: String) {{
        self.text = text
    }}
}}

public struct {component_name}StyleKey: EnvironmentKey {{
    public static let defaultValue: any {component_name}Style = Primary{component_name}Style()
}}

public extension EnvironmentValues {{
    var {component_name.lower()}Style : any {component_name}Style {{
        get {{ self[{component_name}StyleKey.self] }}
        set {{ self[{component_name}StyleKey.self] = newValue }}
    }}
}}

public extension {component_name}Style {{
    @MainActor
    func resolve(configuration: Configuration) -> some View {{
        Resolved{component_name}Style(style: self, configuration: configuration)
    }}
}}

private struct Resolved{component_name}Style<Style: {component_name}Style>: View {{
    let style: Style
    let configuration: Style.Configuration
    
    var body: some View {{
        style.makeBody(configuration: configuration)
    }}
}}
"""

def create_component_styles(component_name):
    """Cria o arquivo [Component]Styles.swift"""
    return f"""import SwiftUI
import ZenithCoreInterface


public extension View {{
    func {component_name.lower()}Style(_ style: some {component_name}Style) -> some View {{
        environment(\\.{component_name.lower()}Style, style)
    }}
}}

public struct Primary{component_name}Style: @preconcurrency {component_name}Style, BaseThemeDependencies {{
    public var id = String(describing: Self.self)
    
    @Dependency(\\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    
    public init() {{}}
    
    @MainActor
    public func makeBody(configuration: Configuration) -> some View {{
        Base{component_name}(configuration: configuration)
            .foregroundColor(colors.textPrimary)
    }}
}}

public struct Secondary{component_name}Style: @preconcurrency {component_name}Style, BaseThemeDependencies {{
    public var id = String(describing: Self.self)
    
    @Dependency(\\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    
    public init() {{}}
    
    @MainActor
    public func makeBody(configuration: Configuration) -> some View {{
        Base{component_name}(configuration: configuration)
            .foregroundColor(colors.textSecondary)
    }}
}}

public extension {component_name}Style where Self == Primary{component_name}Style {{
    static func primary() -> Self {{ .init() }}
}}

public extension {component_name}Style where Self == Secondary{component_name}Style {{
    static func secondary() -> Self {{ .init() }}
}}

public enum {component_name}StyleCase: CaseIterable, Identifiable {{
    case primary
    case secondary
    
    public var id: Self {{ self }}
    
    public func style() -> Any{component_name}Style {{
        switch self {{
        case .primary:
            .init(.primary())
        case .secondary:
            .init(.secondary())
        }}
    }}
}}

private struct Base{component_name}: View, @preconcurrency BaseThemeDependencies {{
    @Dependency(\\.themeConfigurator) public var themeConfigurator: any ThemeConfiguratorProtocol
    
    let configuration: {component_name}StyleConfiguration
    
    init(configuration: {component_name}StyleConfiguration) {{
        self.configuration = configuration
    }}
    
    var body: some View {{
        Text(configuration.text)
            .font(fonts.small.font)
    }}
}}
"""

def create_component(component_name):
    """Cria o arquivo [Component].swift"""
    return f"""import Dependencies
import SwiftUI
import ZenithCoreInterface

public struct {component_name}: View {{
    @Environment(\\.{component_name.lower()}Style) private var style
    let text: String
    
    public init(
        _ text: String
    ) {{
        self.text = text
    }}
    
    public var body: some View {{
        AnyView(
            style.resolve(
                configuration: {component_name}StyleConfiguration(
                    text: text
                )
            )
        )
    }}
}}
"""

def create_component_sample(component_name):
    """Cria o arquivo [Component]Sample.swift para o ZenithSample"""
    return f"""import SwiftUI
import Zenith

struct {component_name}Sample: View {{
    @State var isExpanded = false
    
    var body: some View {{
        SectionView(title: "{component_name.upper()}", isExpanded: $isExpanded) {{
            ForEach({component_name}StyleCase.allCases, id: \\.self) {{ style in
                {component_name}("Sample {component_name}")
                    .{component_name.lower()}Style(style.style())
            }}
        }}
    }}
}}
"""

def update_sample_view(zenith_sample_path, component_name):
    """Atualiza o arquivo ZenithSampleView.swift para incluir o novo sample"""
    view_file_path = os.path.join(zenith_sample_path, "ZenithSampleView.swift")
    
    if not os.path.exists(view_file_path):
        print_warning(f"Arquivo ZenithSampleView.swift não encontrado em {zenith_sample_path}")
        return False
    
    try:
        with open(view_file_path, 'r') as file:
            content = file.read()
        
        # Encontra a posição para adicionar o novo componente
        marker = "//AQUI{Component}"
        if marker in content:
            updated_content = content.replace(marker, f"{component_name}Sample()\n                {marker}")
        else:
            # Tenta encontrar o último componente na lista para adicionar após ele
            components_pattern = r'(.*?Sample\(\))'
            components = re.findall(components_pattern, content)
            if components:
                last_component = components[-1]
                updated_content = content.replace(last_component, f"{last_component}\n                {component_name}Sample()")
            else:
                print_warning("Não foi possível localizar o ponto de inserção no arquivo ZenithSampleView.swift")
                return False
        
        # Escreve o conteúdo atualizado
        with open(view_file_path, 'w') as file:
            file.write(updated_content)
        
        return True
    
    except Exception as e:
        print_error(f"Erro ao atualizar ZenithSampleView.swift: {str(e)}")
        return False

def find_zenith_path():
    """Encontra o caminho para Packages/Zenith/Sources/Zenith a partir do diretório atual"""
    # Começando do diretório do script
    current_dir = os.path.dirname(os.path.abspath(__file__))
    
    # Tenta encontrar o diretório subindo até 3 níveis
    for _ in range(4):
        # Caminho alvo para buscar
        target_path = os.path.join(current_dir, "Packages", "Zenith", "Sources", "Zenith")
        
        if os.path.exists(target_path) and os.path.isdir(target_path):
            return current_dir, target_path
        
        # Sobe um nível
        parent_dir = os.path.dirname(current_dir)
        if parent_dir == current_dir:  # Chegou à raiz
            break
        current_dir = parent_dir
    
    # Se não encontrou, retorna None
    return None, None

def get_custom_path():
    """Solicita um caminho personalizado ao usuário"""
    print_info("Informe o caminho completo para a pasta raiz do projeto:")
    print_info("Ex: /Users/seu_usuario/Projetos/MeuApp")
    root_path = input("> ")
    
    zenith_path = os.path.join(root_path, "Packages", "Zenith", "Sources", "Zenith")
    
    if os.path.exists(zenith_path) and os.path.isdir(zenith_path):
        return root_path, zenith_path
    else:
        print_error("Caminho Zenith não encontrado ou inválido!")
        return None, None

def check_makefile_exists(directory):
    """Verifica se existe um Makefile no diretório especificado"""
    makefile_path = os.path.join(directory, "Makefile")
    makefile_path_lower = os.path.join(directory, "makefile")
    
    return os.path.exists(makefile_path) or os.path.exists(makefile_path_lower)

def check_generate_target(directory):
    """Verifica se o Makefile contém o target 'generate'"""
    try:
        # Mudar para o diretório do Makefile
        original_dir = os.getcwd()
        os.chdir(directory)
        
        # Executar 'make -n generate' para verificar se o target existe
        # O argumento -n faz o make simular a execução sem realmente executar comandos
        process = subprocess.Popen(["make", "-n", "generate"],
                                   stdout=subprocess.PIPE,
                                   stderr=subprocess.PIPE,
                                   text=True)
        _, stderr = process.communicate()
        
        # Voltar ao diretório original
        os.chdir(original_dir)
        
        # Se retornar 0, o target existe
        return process.returncode == 0
    except Exception as e:
        # Garantir que voltamos ao diretório original mesmo em caso de erro
        if original_dir:
            os.chdir(original_dir)
        return False

def run_make_generate(root_path):
    """Executa o comando 'make generate' na pasta raiz do projeto"""
    try:
        # Obter o diretório que contém o Makefile (uma pasta antes da pasta de scripts)
        script_dir = os.path.dirname(os.path.abspath(__file__))
        
        # Tentar diferentes diretórios para encontrar o Makefile
        possible_dirs = [
            os.path.dirname(root_path),  # Uma pasta antes da raiz do projeto
            root_path,                    # Na raiz do projeto
            os.path.dirname(script_dir)   # Uma pasta antes do script
        ]
        
        makefile_dir = None
        for directory in possible_dirs:
            if check_makefile_exists(directory):
                if check_generate_target(directory):
                    makefile_dir = directory
                    break
                else:
                    print_warning(f"Makefile encontrado em '{directory}' mas não contém o target 'generate'")
        
        if not makefile_dir:
            print_error("Makefile com o target 'generate' não encontrado em nenhum diretório relevante")
            return False
        
        print_info(f"\nExecutando 'make generate' em {makefile_dir}...")
        
        # Mudar para o diretório do Makefile
        original_dir = os.getcwd()
        os.chdir(makefile_dir)
        
        # Executar o comando make generate
        process = subprocess.Popen(["make", "generate"],
                                   stdout=subprocess.PIPE,
                                   stderr=subprocess.PIPE,
                                   text=True)
        
        # Capturar saída e erro
        stdout, stderr = process.communicate()
        
        # Voltar ao diretório original
        os.chdir(original_dir)
        
        # Verificar o resultado
        if process.returncode == 0:
            print_success("✓ Comando 'make generate' executado com sucesso!")
            return True
        else:
            print_error(f"Erro ao executar 'make generate': {stderr}")
            return False
    
    except Exception as e:
        print_error(f"Erro ao executar 'make generate': {str(e)}")
        # Garantir que voltamos ao diretório original mesmo em caso de erro
        try:
            if 'original_dir' in locals() and original_dir:
                os.chdir(original_dir)
        except:
            pass
        return False

def generate_component():
    """Função principal de geração de componente"""
    print_header()
    
    # 1. Escolher o tipo de componente (Nativo ou Customizado)
    print_info("Escolha o tipo de componente:")
    print("1. Nativo")
    print("2. Customizado")
    
    component_type = input("> ")
    
    if component_type not in ["1", "2"]:
        print_error("Opção inválida!")
        time.sleep(1.5)
        return False
    
    is_native = component_type == "1"
    
    # 2. Obter nome do componente
    print_info("Digite o nome do componente (ex: Button, Card, Avatar):")
    component_name = input("> ")
    
    if not component_name:
        print_error("Nome de componente inválido!")
        time.sleep(1.5)
        return False
    
    # Garantir que a primeira letra seja maiúscula
    component_name = component_name[0].upper() + component_name[1:] if component_name else ''
    
    # 3. Selecionar o tipo de componente
    print_info("\nOnde deseja salvar o componente?")
    print("1. BaseElements")
    print("2. Components")
    print("3. Outro diretório")
    
    choice = input("> ")
    
    if choice == "1":
        folder_type = "BaseElements"
    elif choice == "2":
        folder_type = "Components"
    elif choice == "3":
        print_info("\nDigite o nome da pasta para salvar:")
        folder_type = input("> ")
        if not folder_type:
            print_error("Nome de pasta inválido!")
            time.sleep(1.5)
            return False
    else:
        print_error("Opção inválida!")
        time.sleep(1.5)
        return False
    
    # 4. Encontrar o caminho de destino
    print_info("\nProcurando diretório Zenith...")
    root_path, zenith_path = find_zenith_path()
    
    if not zenith_path:
        print_warning("Caminho Zenith não encontrado automaticamente.")
        print_info("\nO que deseja fazer?")
        print("1. Informar o caminho manualmente")
        print("2. Criar em uma pasta simulada no diretório atual")
        
        option = input("> ")
        
        if option == "1":
            root_path, zenith_path = get_custom_path()
            if not zenith_path:
                return False
        elif option == "2":
            print_warning("Criando em pasta simulada...")
            root_path = os.getcwd()
            zenith_path = os.path.join(root_path, "Simulado_Zenith")
        else:
            print_error("Opção inválida!")
            time.sleep(1.5)
            return False
    
    # 5. Criar diretório de saída para o componente principal
    if is_native:
        output_dir = os.path.join(zenith_path, folder_type, "Natives", component_name)
    else:
        output_dir = os.path.join(zenith_path, folder_type, "Customs", component_name)
    
    try:
        if not os.path.exists(output_dir):
            os.makedirs(output_dir)
    except Exception as e:
        print_error(f"Erro ao criar diretório: {str(e)}")
        time.sleep(1.5)
        return False
    
    # 6. Adicionar o método lower() ao nome do componente para uso em variáveis
    component_name_obj = type('obj', (object,), {
        'lower': lambda: component_name[0].lower() + component_name[1:] if component_name else '',
        'upper': lambda: component_name.upper() if component_name else ''
    })
    
    # 7. Gerar conteúdo dos arquivos principais
    print_info("\nGerando arquivos do componente...")
    
    if is_native:
        files = {
            f"{component_name}StyleConfiguration.swift": create_native_style_configuration(component_name),
            f"{component_name}Styles.swift": create_native_styles(component_name)
        }
    else:
        files = {
            f"{component_name}StyleConfiguration.swift": create_style_configuration(component_name),
            f"{component_name}Styles.swift": create_component_styles(component_name),
            f"{component_name}.swift": create_component(component_name)
        }

    
    # 8. Escrever cada arquivo do componente principal
    try:
        for filename, content in files.items():
            file_path = os.path.join(output_dir, filename)
            with open(file_path, 'w') as f:
                f.write(content)
            print_success(f"✓ {filename} criado")
            time.sleep(0.3)  # Pequena pausa para efeito visual
    except Exception as e:
        print_error(f"Erro ao escrever arquivo: {str(e)}")
        time.sleep(1.5)
        return False
    
    # 9. Criar e configurar o arquivo de amostra para ZenithSample
    print_info("\nConfigurando amostra para ZenithSample...")
    
    # Determinar o caminho do ZenithSample
    zenith_sample_path = os.path.join(root_path, "Packages", "ZenithSample", "ZenithSample")
    
    # Criar o diretório para o tipo de componente se não existir
    if is_native:
        sample_component_type_dir = os.path.join(zenith_sample_path, folder_type, "Natives")
    else:
        sample_component_type_dir = os.path.join(zenith_sample_path, folder_type, "Customs")
    
    if not os.path.exists(sample_component_type_dir):
        try:
            os.makedirs(sample_component_type_dir)
            print_success(f"✓ Diretório {folder_type}/{'Natives' if is_native else 'Customs'} criado em ZenithSample")
        except Exception as e:
            print_error(f"Erro ao criar diretório em ZenithSample: {str(e)}")
            print_warning("Continuando sem criar arquivo de amostra...")
            
            # Mostrar resumo dos arquivos já criados
            print("\n" + "=" * 50)
            print_success(f"Componente {component_name} gerado com sucesso!")
            print_info(f"Localização: {output_dir}")
            print_warning("Arquivo de amostra não foi criado.")
            print("=" * 50)
            
            # Opção para executar make generate
            print_info("\nDeseja executar 'make generate' para atualizar o projeto?")
            print("1. Sim")
            print("2. Não")
            
            make_choice = input("> ")
            if make_choice == "1":
                run_make_generate(root_path)
            
            return True
    
    # Criar um diretório específico para o componente dentro do tipo de componente
    sample_component_dir = os.path.join(sample_component_type_dir, component_name)
    if not os.path.exists(sample_component_dir):
        try:
            os.makedirs(sample_component_dir)
            print_success(f"✓ Diretório {component_name} criado em {folder_type}/{'Natives' if is_native else 'Customs'}")
        except Exception as e:
            print_error(f"Erro ao criar diretório do componente em ZenithSample: {str(e)}")
            # Continue mesmo com erro, tentando criar o arquivo diretamente no diretório pai
            sample_component_dir = sample_component_type_dir
    
    # Criar o arquivo de amostra no diretório específico do componente
    sample_file_path = os.path.join(sample_component_dir, f"{component_name}Sample.swift")
    try:
        with open(sample_file_path, 'w') as f:
            f.write(create_component_sample(component_name))
        print_success(f"✓ {component_name}Sample.swift criado em {folder_type}/{'Natives' if is_native else 'Customs'}/{component_name}")
        
        # Atualizar o ZenithSampleView.swift para incluir o novo componente
        if update_sample_view(zenith_sample_path, component_name):
            print_success(f"✓ ZenithSampleView.swift atualizado com {component_name}Sample")
        else:
            print_warning("ZenithSampleView.swift não foi atualizado")
    except Exception as e:
        print_error(f"Erro ao criar arquivo de amostra: {str(e)}")
        print_warning("O componente principal foi criado, mas o arquivo de amostra falhou.")
    
    # 10. Mostrar resumo
    print("\n" + "=" * 50)
    print_success(f"Componente {component_name} gerado com sucesso!")
    print_info(f"Localização do componente: {output_dir}")
    print_info(f"Tipo de componente: {'Nativo' if is_native else 'Customizado'}")
    print_info(f"Pasta: {folder_type}/{'Natives' if is_native else 'Customs'}/{component_name}")
    print("=" * 50)
    
    # 11. Nova opção para executar make generate
    print_info("\nDeseja executar 'make generate' para atualizar o projeto?")
    print("1. Sim")
    print("2. Não")
    
    make_choice = input("> ")
    if make_choice == "1":
        run_make_generate(root_path)
    
    return True

def main_menu():
    """Menu principal do programa"""
    while True:
        print_header()
        print("1. Gerar novo componente")
        print("2. Sair")
        print()
        choice = input("Escolha uma opção: ")
        
        if choice == "1":
            generate_component()
            print("\nPressione Enter para continuar...")
            input()
        elif choice == "2":
            print_info("Saindo...")
            time.sleep(0.5)
            clear_screen()
            break
        else:
            print_error("Opção inválida!")
            time.sleep(1)

if __name__ == "__main__":
    try:
        main_menu()
    except KeyboardInterrupt:
        clear_screen()
        print_info("Programa encerrado pelo usuário.")