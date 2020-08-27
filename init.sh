#!/usr/bin/env bash

# Use Zsh
chsh -s `which zsh`

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
brew install zsh zsh-completions wget tfenv
git clone https://github.com/powerline/fonts.git
(cd fonts && ./install.sh)
(cd .oh-my-zsh/custom && git clone https://github.com/romkatv/powerlevel10k.git themes/powerlevel10k)

brew tap homebrew/cask-fonts
brew cask install font-hack-nerd-font

# Install node/npm
./dotfiles/install_nvm.sh

# update rc
./dotfiles/link.sh
touch ~/.localrc