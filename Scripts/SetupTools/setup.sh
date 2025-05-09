#!/bin/sh

# Set permissions for *.sh
find Scripts -name '*.sh' -exec chmod +x {} +

# Jump to repository root
cd "$(git rev-parse --show-toplevel)"

# Install Homebrew dependencies
installHomebrew='/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'
command -v brew >/dev/null 2>&1 || eval $installHomebrew


brew update

brew install xcodegen || (brew upgrade xcodegen && brew cleanup xcodegen)
brew install sourcery || (brew upgrade sourcery && brew cleanup sourcery)
brew install rbenv || (brew upgrade rbenv && brew cleanup rbenv)
brew install openssl || (brew upgrade openssl && brew cleanup openssl)

# Install Ruby
rbenv init

# Detectar versão do macOS e configurar ambiente apropriadamente
MACOS_VERSION=$(sw_vers -productVersion)
echo "Versão detectada do macOS: $MACOS_VERSION"

# Instalar dependências específicas baseadas na versão do macOS
if [[ "$MACOS_VERSION" > "14" ]]; then
    echo "macOS Sequoia (14.x) ou superior detectado - instalando dependências específicas..."
    brew install openssl@3 readline libyaml
    export LDFLAGS="-L$(brew --prefix openssl@3)/lib -L$(brew --prefix readline)/lib -L$(brew --prefix libyaml)/lib"
    export CPPFLAGS="-I$(brew --prefix openssl@3)/include -I$(brew --prefix readline)/include -I$(brew --prefix libyaml)/include"
    export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@3)"
    # Use Ruby 3.2.x para versões mais recentes do macOS
    TARGET_RUBY_VERSION="3.2.3"
elif [[ "$MACOS_VERSION" > "13" ]]; then
    echo "macOS Sonoma (13.x) detectado - instalando dependências específicas..."
    brew install openssl@1.1 readline
    export LDFLAGS="-L$(brew --prefix openssl@1.1)/lib -L$(brew --prefix readline)/lib"
    export CPPFLAGS="-I$(brew --prefix openssl@1.1)/include -I$(brew --prefix readline)/include"
    export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@1.1)"
    # Use Ruby 3.1.x para Sonoma
    TARGET_RUBY_VERSION="3.1.4"
else
    echo "macOS Ventura ou anterior detectado - usando configuração padrão..."
    brew install openssl@1.1
    export LDFLAGS="-L$(brew --prefix openssl@1.1)/lib"
    export CPPFLAGS="-I$(brew --prefix openssl@1.1)/include"
    export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@1.1)"
    # Use Ruby 3.0.x para versões mais antigas
    TARGET_RUBY_VERSION="3.0.6"
fi

# Garantir que ruby-build está atualizado
brew update
brew install ruby-build || brew upgrade ruby-build

# Tentar instalar a versão target do Ruby primeiro
echo "Tentando instalar Ruby $TARGET_RUBY_VERSION com configurações específicas para macOS $MACOS_VERSION..."
rbenv install -s $TARGET_RUBY_VERSION

# Se falhar, tente versões alternativas
if [ $? -ne 0 ]; then
    echo "Falha ao instalar Ruby $TARGET_RUBY_VERSION. Tentando versões alternativas..."
    
    # Versões alternativas por ordem de preferência
    for ruby_version in "3.2.2" "3.1.4" "3.0.6" "2.7.8"; do
        # Pule a versão target que já tentamos
        if [ "$ruby_version" = "$TARGET_RUBY_VERSION" ]; then
            continue
        fi
        
        echo "Tentando Ruby $ruby_version..."
        rbenv install -s $ruby_version
        
        if [ $? -eq 0 ]; then
            echo "Ruby $ruby_version instalado com sucesso!"
            rbenv global $ruby_version
            break
        fi
    done
else
    echo "Ruby $TARGET_RUBY_VERSION instalado com sucesso!"
    rbenv global $TARGET_RUBY_VERSION
fi

# Verificar instalação do Ruby
if ! command -v ruby &> /dev/null; then
    echo "ATENÇÃO: Ruby não foi instalado ou não está no PATH."
    echo "Instalando Ruby via Homebrew como solução alternativa..."
    brew install ruby
    echo 'export PATH="$(brew --prefix ruby)/bin:$PATH"' >> ~/.zshrc
    echo 'export PATH="$(brew --prefix ruby)/bin:$PATH"' >> ~/.bashrc
fi

# Instalar nkf via Homebrew para contornar problemas de compilação
brew install nkf || brew upgrade nkf

# Instalar fastlane diretamente se necessário
if ! command -v fastlane &> /dev/null; then
    echo "Instalando fastlane via Homebrew como backup..."
    brew install fastlane
fi

# Função para verificar e instalar bundle
setup_bundle() {
    # Tenta resolver o problema do NKF especificamente para macOS com Xcode 16
    echo "Configurando ambiente para compilar gems nativas..."
    
    # Instalar nkf via Homebrew como alternativa
    if brew list nkf &>/dev/null; then
        echo "nkf já está instalado via Homebrew."
    else
        echo "Instalando nkf via Homebrew como alternativa..."
        brew install nkf
    fi
    
    # Adicionar uma versão falsa do nkf para enganar o bundler
    mkdir -p "$MONOREPO_ROOT/vendor/bundle-workaround/gems/nkf-0.2.0"
    if [ ! -f "$MONOREPO_ROOT/vendor/bundle-workaround/gems/nkf-0.2.0/nkf.rb" ]; then
        echo "Criando stub para nkf..."
        cat > "$MONOREPO_ROOT/vendor/bundle-workaround/gems/nkf-0.2.0/nkf.rb" << 'EOL'
#!/usr/bin/env ruby
# Esta é uma versão de stub do nkf que usa a versão do sistema
# instalada pelo Homebrew
module NKF
  def self.nkf(opt, str)
    IO.popen(['nkf', opt], 'r+') do |io|
      io.print str
      io.close_write
      io.read
    end
  end
end
EOL
    fi

    # Adicionar a detecção específica de versão do macOS
    MACOS_VERSION=$(sw_vers -productVersion)
    echo "Versão detectada do macOS: $MACOS_VERSION"
    
    # Ajustes específicos para diferentes versões do macOS
    if [[ "$MACOS_VERSION" > "14" ]]; then
        echo "macOS Sequoia (14.x) ou superior detectado - ajustando configurações..."
        # Sonoma e mais recentes podem precisar de configurações específicas
        export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@3)"
        export LDFLAGS="-L$(brew --prefix openssl@3)/lib -L$(brew --prefix readline)/lib -L$(brew --prefix libyaml)/lib"
        export CPPFLAGS="-I$(brew --prefix openssl@3)/include -I$(brew --prefix readline)/include -I$(brew --prefix libyaml)/include"
        
        # Instalar dependências específicas do macOS 14+
        brew install openssl@3 readline libyaml
    elif [[ "$MACOS_VERSION" > "13" ]]; then
        echo "macOS Sonoma (13.x) detectado - ajustando configurações..."
        export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@1.1)"
        export LDFLAGS="-L$(brew --prefix openssl@1.1)/lib -L$(brew --prefix readline)/lib"
        export CPPFLAGS="-I$(brew --prefix openssl@1.1)/include -I$(brew --prefix readline)/include"
        
        # Instalar dependências para Sonoma
        brew install openssl@1.1 readline
    else
        echo "macOS Ventura ou anterior detectado."
        export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@1.1)"
        export LDFLAGS="-L$(brew --prefix openssl@1.1)/lib"
        export CPPFLAGS="-I$(brew --prefix openssl@1.1)/include"
    fi
    
    # Verificar se rbenv está disponível
    if command -v rbenv &> /dev/null; then
        echo "Utilizando rbenv para configuração do ambiente Ruby..."
        
        # Atualizar ruby-build para garantir compatibilidade com macOS mais recente
        echo "Atualizando ruby-build para compatibilidade com macOS recente..."
        brew upgrade ruby-build || brew install ruby-build
        
        # Definir variáveis de ambiente necessárias para compilação no macOS recente
        export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@1.1)"
        export LDFLAGS="-L$(brew --prefix openssl@1.1)/lib"
        export CPPFLAGS="-I$(brew --prefix openssl@1.1)/include"
        
        # Verificar se temos uma versão recente do Ruby instalada (3.0.0 ou superior)
        if rbenv versions | grep -E "3\.[0-9]+\.[0-9]+" > /dev/null; then
            # Pegar a versão mais recente do Ruby 3.x instalada
            NEWEST_RUBY=$(rbenv versions | grep -E "3\.[0-9]+\.[0-9]+" | sort -V | tail -1 | sed 's/^[[:space:]]*\* //' | xargs)
            echo "Usando Ruby $NEWEST_RUBY para evitar problemas de compatibilidade..."
            rbenv shell $NEWEST_RUBY
        else
            # Se não tiver Ruby 3.x, tentar opções de instalação
            echo "Tentando instalar Ruby 3.0.0 com rbenv..."
            
            # Tentar instalar diferentes versões começando com a mais recente recomendada
            for ruby_version in "3.1.4" "3.0.6" "2.7.8"; do
                echo "Tentando instalar Ruby $ruby_version..."
                RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@1.1)" rbenv install -s $ruby_version
                
                # Se a instalação foi bem-sucedida, usar essa versão
                if [ $? -eq 0 ]; then
                    echo "Ruby $ruby_version instalado com sucesso!"
                    rbenv shell $ruby_version
                    break
                else
                    echo "Falha ao instalar Ruby $ruby_version. Tentando outra versão..."
                fi
            done
            
            # Verificar se alguma versão foi instalada
            if ! rbenv versions | grep -E "[23]\.[0-9]+\.[0-9]+" > /dev/null; then
                echo "AVISO: Não foi possível instalar nenhuma versão do Ruby. Usando alternativa..."
                
                # Tentar usar a versão do sistema ou Homebrew como alternativa
                if command -v ruby &> /dev/null; then
                    echo "Usando Ruby do sistema ou Homebrew."
                    brew install fastlane || brew upgrade fastlane
                    return 0
                else
                    echo "ERRO: Nenhuma versão do Ruby disponível. Instalando via brew..."
                    brew install ruby
                    brew install fastlane
                    return 0
                fi
            fi
        fi
        
        # Verificar se a versão atual é 3.x
        CURRENT_RUBY_VERSION=$(ruby -e "puts RUBY_VERSION")
        if [[ ! $CURRENT_RUBY_VERSION =~ ^3\. ]]; then
            echo "AVISO: Ainda usando Ruby $CURRENT_RUBY_VERSION. Pode haver problemas de compatibilidade."
            echo "Considere atualizar manualmente para Ruby 3.x com: rbenv install 3.0.0 && rbenv global 3.0.0"
        fi
    else
        # Se rbenv não estiver disponível, instalar com brew
        echo "rbenv não encontrado. Instalando fastlane diretamente com Homebrew..."
        brew install fastlane
        return 0
    fi

    # Instalar bundler
    echo "Instalando bundler..."
    gem install bundler

    # Modificar Gemfile temporariamente para evitar nkf
    if [ -f "$MONOREPO_ROOT/Gemfile" ]; then
        echo "Modificando Gemfile temporariamente para resolver problema com nkf..."
        cp "$MONOREPO_ROOT/Gemfile" "$MONOREPO_ROOT/Gemfile.bak"
        echo 'source "https://rubygems.org"
gem "fastlane"
gem "CFPropertyList", "~> 3.0.5"' > "$MONOREPO_ROOT/Gemfile"
    fi

    # Instalar fastlane diretamente
    echo "Instalando fastlane gem..."
    gem install fastlane

    # Restaurar Gemfile
    if [ -f "$MONOREPO_ROOT/Gemfile.bak" ]; then
        mv "$MONOREPO_ROOT/Gemfile.bak" "$MONOREPO_ROOT/Gemfile"
    fi

    return 0
}

setup_bundle

# Install bundler dependencies
. Scripts/Bundler/installBundler.sh

# Install swiftgen
. Scripts/SetupTools/swiftgen.sh

# Install xgen command
xgenAlias="alias xgen=\"make generate; echo; echo xgen command is deprecated, use \'make generate\'\""

touch ~/.zshrc
sed -i '' '/^alias\ xgen=/d' ~/.zshrc
echo $xgenAlias >> ~/.zshrc

touch ~/.bashrc
sed -i '' '/^alias\ xgen=/d' ~/.bashrc
echo $xgenAlias >> ~/.bashrc

# Make sure rbenv is at the rc files
if [ -f ~/.zshrc ] && ! grep -q "rbenv init" ~/.zshrc
then
    echo "if which rbenv > /dev/null; then eval \"\$(rbenv init -)\"; fi" >> ~/.zshrc
fi

if [ -f ~/.bashrc ] && ! grep -q "rbenv init" ~/.bashrc
then
    echo "if which rbenv > /dev/null; then eval \"\$(rbenv init -)\"; fi" >> ~/.bashrc
fi

# Generate project
echo "\nGenerating project..."
make clean
make generate

# Post setup info
echo "\nTo manually generate the project run the command 'make generate'\n"
echo "Restart the terminal or open a new tab to apply the changes.\n"
