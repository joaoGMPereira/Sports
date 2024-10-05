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
export LDFLAGS="-L$(brew --prefix openssl)/lib"
export CPPFLAGS="-I$(brew --prefix openssl)/include"
CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl)" RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl)" rbenv install `cat .ruby-version`

# Install bundler dependencies
. Scripts/Bundler/installBundler.sh

# Install swiftgen
. Scripts/SetupTools/swiftgen.sh

# Install MVVM-C Scene template
echo "\nInstalling MVVM-C Scene Template"
make template

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
