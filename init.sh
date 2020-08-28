#!/usr/bin/env bash

# Use Zsh
chsh -s `which zsh`

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh) --skip-chsh"
brew install zsh zsh-completions wget

# Install fonts
./dotfiles/install_fonts

# Install oh-my-zsh
(cd .oh-my-zsh/custom && git clone --depth=1 https://github.com/romkatv/powerlevel10k.git themes/powerlevel10k)
# Fix "insecure directories" warning
sudo chmod -R 755 ~/.oh-my-zsh

brew tap homebrew/cask-fonts
brew cask install font-hack-nerd-font

# Install node/npm
./dotfiles/install_nvm.sh

# update rc
./dotfiles/link.sh
touch ~/.localrc