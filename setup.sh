#!/usr/bin/env zsh
########################
# setup.sh
#
# This script attempts to install Prezto and link my dotfiles to the correct places.
# 
# Must be executed by zsh (NOT bash or sh)
# Assumes sudo is installed
#
# EXIT CODES:
# 1 - Not running linux
# 2 - Unable to determine which package manager to use
########################
setopt EXTENDED_GLOB

datetime=$(date +%Y%M%d%H%M%S)

# define some functions
setup_debian () {
    sudo apt update
    sudo apt install -y git
}

# Check that we're running linux
platform=$(uname)

if [[ $platform != 'Linux' ]]; then
    "Looks like you aren't running Linux. Support for other platforms is not yet complete."
    exit 1
fi

# Attempt to determine which distro we're running
if [ -f /etc/os-release ]; then
    source /etc/os-release
fi

# Automatically install git and dependencies, if possible
case $ID_LIKE in
    ('debian')
        echo "Installing dependencies..."
        setup_debian
        ;;
    (*)
        echo 'Unable to automate setup.'
        exit 2
        ;;
esac

# Backup existing dotfiles
echo "Backing up existing dotfiles to ~/dotfiles_old"
mkdir -p ~/dotfiles_old/$datetime
for dotfile in "${ZDOTDIR:-$HOME}"/dotfiles/runcoms/^README.md(.N); do
    mv "${ZDOTDIR:-$HOME}/.${dotfile:t}" "$HOME/dotfiles_old/$datetime"
    if [[ -h "$HOME/.${dotfile:t}" ]]; then
        rm "$HOME/.${dotfile:t}"
    fi
done

# Install Prezto
echo "Installing Prezto..."
if [[ -d "${ZDOTDIR:-$HOME}/.zprezto" ]]; then
    echo "Prezto already installed. Checking for updates..."
else
    git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
fi


# Symlink dotfiles
echo "Linking dotfiles..."
for rcfile in "${ZDOTDIR:-$HOME}"/dotfiles/runcoms/^README.md(.N); do
  ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done

# Set ZSH as default shell
echo "Setting ZSH as default shell..."
chsh -s $(which zsh)

# Success!
exit 0

